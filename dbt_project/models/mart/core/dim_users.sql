{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='user_id'
) }}

SELECT
    user_id,
    sender_country,
    user_created_at AS signup_at,
    DATE(user_created_at) AS signup_date,
    user_allowed_at AS activation_at,
    DATE(user_allowed_at) AS activation_date,
    CASE WHEN user_allowed_at IS NOT NULL THEN 1 ELSE 0 END AS is_activated,
    CASE WHEN user_allowed_at IS NOT NULL THEN 'Activated' ELSE 'Pending' END AS activation_status,
    registration_to_account_minutes AS signup_to_first_transaction_hours 
FROM 
    {{ ref('int_backend__user_onboarding') }}
{% if is_incremental() %}
WHERE user_created_at >= DATEADD('day', -3, CURRENT_DATE)
{% endif %}