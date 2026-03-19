{{ CONFIG(
    TAGS=['hourly']
) }}

SELECT
    id AS recipient_id,
    account_id,
    created_at,
    first_name,
    last_name,
    type AS recipient_type,
    updated_at
FROM {{ SOURCE('backend', 'transactions_recipient') }}