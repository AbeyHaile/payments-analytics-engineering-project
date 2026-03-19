{{ CONFIG(
    TAGS=['hourly']
) }}

SELECT
    id AS recipient_account_id,
    account_number,
    bank_code,
    bank_name,
    country,
    created_at,
    currency,
    operator,
    phone_number,
    recipient_id,
    type AS recipient_account_type,
    updated_at
FROM
    {{ SOURCE('backend', 'transactions_recipient_account') }}