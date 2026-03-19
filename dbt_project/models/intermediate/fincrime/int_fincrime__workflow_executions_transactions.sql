{{ config(
    materialized='incremental',
    unique_key='workflow_execution_id',
    incremental_strategy='merge'
) }}

WITH workflows AS (
    SELECT
        workflow_execution_id,
        workflow_id,
        user_id,
        transaction_id,
        workflow_execution_result,
        created_at,
        ended_at AS workflow_updated_at
    FROM 
        {{ ref('stg_fincrime__workflow_executions') }}
    {% if is_incremental() %}
        WHERE ended_at >= (SELECT DATEADD('day', -3, MAX(workflow_updated_at)) FROM {{ this }})
    {% endif %}
),

transactions AS (
    SELECT
        transaction_id,
        sent_currency,
        received_currency,
        transaction_state,
        -- Assuming sender country is stored in users or can be inferred from currency for this corridor logic
        sent_currency AS source_country, -- Simplification based on typical NALA patterns
        received_currency AS destination_country
    FROM 
        {{ ref('stg_backend__transactions') }}
)

SELECT
    w.workflow_execution_id,
    w.workflow_id,
    w.user_id,
    w.transaction_id,
    w.workflow_execution_result,
    t.source_country,
    t.destination_country,
    CONCAT(t.source_country, '-', t.destination_country) AS corridor,
    t.transaction_state,
    DATE(w.created_at) AS metric_date,
    w.workflow_updated_at
FROM 
    workflows w
INNER JOIN transactions t ON w.transaction_id = t.transaction_id