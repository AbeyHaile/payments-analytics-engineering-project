{{ config(
    unique_key='kpi_report_pk'
) }}

WITH daily_rules AS (
    SELECT
        metric_date,
        rule_id,
        rule_name,
        rule_category,
        COUNT(rule_execution_id) AS total_rule_executions,
        COUNT(CASE WHEN rule_execution_result = 'FAIL' THEN 1 END) AS total_rule_failures,
        COUNT(CASE WHEN rule_execution_result = 'PASS' THEN 1 END) AS total_rule_passes,
        COUNT(CASE WHEN execution_status_category = 'RULE_ERROR' THEN 1 END) AS total_rule_errors,
        COUNT(human_review_result) AS total_reviewed_executions,
        COUNT(CASE WHEN execution_status_category = 'FALSE_POSITIVE' THEN 1 END) AS total_false_positives,
        COUNT(CASE WHEN execution_status_category = 'CONFIRMED_FRAUD' THEN 1 END) AS total_true_positives,
        COUNT(CASE WHEN execution_status_category = 'REVIEW_INCONCLUSIVE' THEN 1 END) AS total_inconclusive_reviews,
        AVG(minutes_to_review) AS avg_minutes_to_review
    FROM {{ ref('int_fincrime__rule_executions_enriched') }}
    
    {% if is_incremental() %}
   
    WHERE rule_execution_created_at >= (
        SELECT DATEADD('day', -3, MAX(rule_execution_created_at))
        FROM {{ this }}
    )
    {% endif %}

    GROUP BY
        metric_date,
        rule_id,
        rule_name,
        rule_category
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['metric_date', 'rule_id', 'rule_name', 'rule_category']) }} AS kpi_report_pk,
    *,
    (total_false_positives / NULLIF(total_reviewed_executions, 0)) * 100 AS false_positive_rate_pct
FROM 
    daily_rules