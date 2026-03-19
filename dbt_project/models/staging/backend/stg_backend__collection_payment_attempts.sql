{{ config(
    tags=['hourly']
) }}

SELECT
    id AS payment_attempt_id,
    amount AS payment_attempt_amount,
    collection_id,
    created_at,
    currency,
    error,
    payment_method_type,
    provider_name,
    state AS payment_attempt_state,
    updated_at
FROM
    {{ source('backend', 'collection_payment_attempts') }}