{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='disbursement_attempt_id'
) }}

WITH attempt AS (

    SELECT
        disbursement_attempt_id,
        disbursement_id,
        disbursement_provider,
        disbursement_attempt_state,
        created_at,
        updated_at
    FROM {{ ref('stg_backend__disbursement_attempts') }}

    {% if is_incremental() %}
        WHERE updated_at >= (
            SELECT DATEADD('day', -3, MAX(disbursement_attempt_updated_at))
            FROM {{ this }}
        )
    {% endif %}

),

final AS (
    SELECT
        disbursement_attempt_id,
        disbursement_id,
        disbursement_provider,
        disbursement_attempt_state,
        DATE(created_at) AS metric_date,
        created_at AS disbursement_attempt_created_at,
        updated_at AS disbursement_attempt_updated_at,
        DATEDIFF('minute', created_at, updated_at) AS minutes_to_latest_state
    FROM 
        attempt

)

SELECT
    disbursement_attempt_id,
    disbursement_id,
    disbursement_provider,
    disbursement_attempt_state,
    metric_date,
    disbursement_attempt_created_at,
    disbursement_attempt_updated_at,
    minutes_to_latest_state,
    CASE
        WHEN disbursement_attempt_state = 'COMPLETED'
            THEN DATEDIFF('minute', created_at, updated_at)
    END AS minutes_to_complete,
    CASE
        WHEN disbursement_attempt_state = 'FAILED'
            THEN DATEDIFF('minute', created_at, updated_at)
    END AS minutes_to_fail,
    
    -- Operational Time Bands
    CASE
        WHEN minutes_to_latest_state < 1 THEN 'under_1_minute'
        WHEN minutes_to_latest_state <= 5 THEN '1_to_5_minutes'
        WHEN minutes_to_latest_state <= 30 THEN '5_to_30_minutes'
        WHEN minutes_to_latest_state <= 60 THEN '30_minutes_to_1_hour'
        WHEN minutes_to_latest_state <= 1440 THEN '1_to_24_hours'
        ELSE 'over_24_hours'
    END AS processing_time_band
FROM
    final