{{ config(
    unique_key='kpi_report_pk'
) }}

WITH corridor_stats AS (
    SELECT
        metric_date,
        source_country,
        destination_country,
        corridor,
        COUNT(DISTINCT transaction_id) AS total_attempt_transactions,
        COUNT(DISTINCT CASE WHEN workflow_execution_result = 'PASS' THEN transaction_id END) AS successful_passes,
        COUNT(DISTINCT CASE WHEN workflow_execution_result = 'FAIL' THEN transaction_id END) AS hard_rejections,
        COUNT(DISTINCT CASE WHEN workflow_execution_result = 'ERROR' THEN transaction_id END) AS technical_errors
    FROM 
        {{ ref('int_fincrime__workflow_executions_transactions') }}

    {% if is_incremental() %}
        WHERE workflow_updated_at >= (
            SELECT DATEADD('day', -3, MAX(workflow_updated_at))
            FROM {{ this }})
    {% endif %}

    GROUP BY
        metric_date,
        source_country,
        destination_country,
        corridor
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['metric_date', 'source_country', 'destination_country', 'corridor']) }} AS kpi_report_pk,
    *,
    (successful_passes / NULLIF(total_attempt_transactions, 0)) * 100 AS success_rate_pct,
    (hard_rejections / NULLIF(total_attempt_transactions, 0)) * 100 AS failure_rate_pct,
    (technical_errors / NULLIF(total_attempt_transactions, 0)) * 100 AS technical_error_rate_pct
FROM
    corridor_stats