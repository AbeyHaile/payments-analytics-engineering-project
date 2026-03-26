{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='user_id'
) }}

WITH backend_users AS (

    SELECT
        user_id,
        sender_country,
        created_at AS signed_up_at,
        DATE(created_at) AS signup_date,
        user_allowed_at AS kyc_approved_at
    FROM 
        {{ ref('stg_backend__users') }}

    {% if is_incremental() %}
        WHERE created_at >= (
            SELECT DATEADD('day', -3, MAX(signed_up_at))
            FROM {{ this }})
    {% endif %}

),

amplitude_events AS (

    SELECT
        user_id,
        MIN(CASE WHEN event_type = 'sign_up.completed' THEN event_time END) AS amplitude_signup_at,
        MIN(CASE WHEN event_type = 'transaction.completed' THEN event_time END) AS first_transaction_at,
        MAX(server_upload_time) AS latest_server_upload_time
    FROM 
        {{ ref('stg_amplitude__events') }}

    {% if is_incremental() %}
        WHERE server_upload_time >= (
            SELECT DATEADD('day', -3, MAX(signed_up_at))
            FROM {{ this }}
        )
    {% endif %}

    GROUP BY user_id

),

joined AS (

    SELECT
        bu.user_id,
        bu.sender_country,
        bu.signed_up_at,
        bu.signup_date,
        bu.kyc_approved_at,
        ae.amplitude_signup_at,
        ae.first_transaction_at
    FROM 
        backend_users bu
    LEFT JOIN 
        amplitude_events ae
    ON 
        bu.user_id = ae.user_id

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
    joined