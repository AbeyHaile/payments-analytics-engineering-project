{{ config(
    unique_key='kpi_report_pk'
) }}

WITH daily_stats AS (
    SELECT
        DATE(created_at) AS metric_date,
        sent_currency AS source_country,
        destination_country,
        corridor,
        COUNT(transaction_id) AS qualifying_transaction_attempts,
        COUNT(CASE WHEN transaction_state = 'COMPLETED' THEN transaction_id END) AS completed_qualifying_transactions,
        SUM(CASE WHEN transaction_state = 'COMPLETED' THEN sent_amount ELSE 0 END) AS completed_transaction_volume
    FROM 
        {{ ref('int_backend__transactions_joined') }}
    WHERE transaction_type IN ('DISBURSEMENT', 'CONVERSION_DISBURSEMENT', 'COLLECTION_CONVERSION_DISBURSEMENT')
    
    {% if is_incremental() %}
    AND updated_at >= DATEADD('day', -3, MAX(updated_at))
        FROM {{ this }}
    )
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
    (completed_qualifying_transactions / NULLIF(qualifying_transaction_attempts, 0)) * 100 AS transaction_success_rate_pct
FROM
    daily_stats