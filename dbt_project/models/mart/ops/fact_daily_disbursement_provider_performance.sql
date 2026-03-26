{{ config(
    unique_key='kpi_report_pk'
) }}

WITH provider_stats AS (

    SELECT
        metric_date,
        disbursement_provider,

        COUNT(disbursement_attempt_id) AS total_attempts,

        COUNT(CASE WHEN disbursement_attempt_state = 'COMPLETED' THEN 1 END) AS total_successes,
        COUNT(CASE WHEN disbursement_attempt_state = 'FAILED' THEN 1 END) AS total_failures,

        AVG(minutes_to_complete) AS avg_minutes_to_complete,
        AVG(minutes_to_fail) AS avg_minutes_to_fail,

        COUNT(CASE WHEN processing_time_band = 'under_1_minute' THEN 1 END) AS attempts_under_1_minute,
        COUNT(CASE WHEN processing_time_band = '1_to_5_minutes' THEN 1 END) AS attempts_1_to_5_minutes,
        COUNT(CASE WHEN processing_time_band = '5_to_30_minutes' THEN 1 END) AS attempts_5_to_30_minutes,
        COUNT(CASE WHEN processing_time_band = '30_minutes_to_1_hour' THEN 1 END) AS attempts_30_to_60_minutes,
        COUNT(CASE WHEN processing_time_band = '1_to_24_hours' THEN 1 END) AS attempts_1_to_24_hours,
        COUNT(CASE WHEN processing_time_band = 'over_24_hours' THEN 1 END) AS attempts_over_24_hours

    FROM
        {{ ref('int_backend__disbursement_attempts_reporting') }}

    {% if is_incremental() %}
        WHERE metric_date >= (
            SELECT DATEADD('day', -3, MAX(metric_date)) 
            FROM {{ this }})
    {% endif %}

    GROUP BY
        metric_date,
        disbursement_provider
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['metric_date','disbursement_provider']) }} AS kpi_report_pk,
    metric_date,
    disbursement_provider,
    total_attempts,
    total_successes,
    total_failures,

    ROUND(
        100.0 * total_successes / NULLIF(total_attempts, 0),
        2
    ) AS success_rate_pct,

    ROUND(avg_minutes_to_complete, 2) AS avg_minutes_to_complete,
    ROUND(avg_minutes_to_fail, 2) AS avg_minutes_to_fail,

    attempts_under_1_minute,
    attempts_1_to_5_minutes,
    attempts_5_to_30_minutes,
    attempts_30_to_60_minutes,
    attempts_1_to_24_hours,
    attempts_over_24_hours

FROM 
    provider_stats