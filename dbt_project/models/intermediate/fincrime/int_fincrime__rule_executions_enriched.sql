{{ config(
    materialized='incremental',
    unique_key='rule_execution_id',
    incremental_strategy='merge'
) }}

WITH current_rules AS (
    -- Reference to the intermediate rule-vane to get metadata
    SELECT 
        rule_id,
        rule_name,
        rule_category
    FROM 
        {{ ref('int_fincrime__current_rules') }}
),

latest_reviews AS (
    -- Deduplicate reviews to get the most recent decision per execution
    SELECT
        rule_execution_id,
        review_outcome,
        reviewed_at
    FROM 
        {{ ref('stg_fincrime__rule_execution_reviews') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY rule_execution_id ORDER BY reviewed_at DESC) = 1
),

rule_executions AS (
    SELECT
        rule_execution_id,
        rule_id,
        workflow_execution_id,
        rule_execution_result,
        rule_review_status,
        created_at,
        rule_execution_error
    FROM 
        {{ ref('stg_fincrime__rule_executions') }}

    {% if is_incremental() %}
        -- 3-day lookback on created_at to capture late-processed reviews
        WHERE created_at >= (SELECT DATEADD('day', -3, MAX(rule_execution_created_at)) FROM {{ this }})
    {% endif %}
)

SELECT
    re.rule_execution_id,
    re.rule_id,
    re.workflow_execution_id,
    cr.rule_name,
    cr.rule_category,
    DATE(re.created_at) AS metric_date,
    re.rule_execution_result,
    re.rule_review_status,
    lr.review_outcome AS human_review_result,
    -- execution_status_category logic as per YAML requirements
    CASE 
        WHEN re.rule_execution_error IS NOT NULL THEN 'RULE_ERROR'
        WHEN re.rule_execution_result = 'PASS' THEN 'PASSED_AUTOMATICALLY'
        WHEN re.rule_execution_result = 'FAIL' AND re.rule_review_status = 'PENDING' THEN 'PENDING_REVIEW'
        WHEN lr.review_outcome = 'APPROVED' THEN 'FALSE_POSITIVE'
        WHEN lr.review_outcome = 'REJECTED' THEN 'CONFIRMED_FRAUD'
        WHEN re.rule_execution_result = 'FAIL' AND lr.review_outcome IS NULL THEN 'REVIEW_RESULT_MISSING'
        ELSE 'UNEXPECTED_STATE'
    END AS execution_status_category,
    re.created_at AS rule_execution_created_at,
    lr.reviewed_at AS human_reviewed_at,
    DATEDIFF('minute', re.created_at, lr.reviewed_at) AS minutes_to_review

FROM 
    rule_executions re
LEFT JOIN current_rules cr 
    ON re.rule_id = cr.rule_id
LEFT JOIN latest_reviews lr 
    ON re.rule_execution_id = lr.rule_execution_id