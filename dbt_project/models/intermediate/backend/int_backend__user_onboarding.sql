{{ config(
    materialized='incremental',
    incremental_strategy='merg',
    unique_key='user_id'
) }}

WITH user_events AS (

    SELECT
        u.user_id,
        u.sender_country,
        u.created_at AS signed_up_at,
        DATE(u.created_at) AS signup_date,
        u.user_allowed_at AS kyc_approved_at,
        e.event_type,
        e.event_time,
        e.server_upload_time,

        MIN(
            CASE
                WHEN e.event_type = 'sign_up.completed' THEN e.event_time
            END
        ) OVER (
            PARTITION BY u.user_id
        ) AS amplitude_signup_at,

        MIN(
            CASE
                WHEN e.event_type = 'transaction.completed' THEN e.event_time
            END
        ) OVER (
            PARTITION BY u.user_id
        ) AS first_transaction_at,

    FROM
        {{ ref('stg_backend__users') }} u
    LEFT JOIN {{ ref('stg_amplitude__events') }} e
        ON u.user_id = e.user_id

    {% if is_incremental() %}
        WHERE u.created_at >= (
            SELECT DATEADD('day', -3, MAX(signed_up_at))
            FROM {{ this }}
        )
        OR e.server_upload_time >= (
            SELECT DATEADD('day', -3, MAX(signed_up_at))
            FROM {{ this }}
        )
    {% endif %}

    QUALIFY ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY u.user_id) = 1

)

SELECT
    user_id,
    sender_country,
    signed_up_at,
    signup_date,
    kyc_approved_at,
    amplitude_signup_at,
    first_transaction_at,
    DATE(first_transaction_at) AS activation_date,
    DATEDIFF('hour', signed_up_at, first_transaction_at) AS signup_to_first_transaction_hours,
    CASE
        WHEN first_transaction_at IS NOT NULL THEN 1
        ELSE 0
    END AS is_activated,
    CASE
        WHEN kyc_approved_at IS NOT NULL THEN 1
        ELSE 0
    END AS is_kyc_approved
FROM 
    user_events
