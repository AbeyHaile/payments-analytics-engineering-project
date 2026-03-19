{{ CONFIG(
    TAGS=['hourly']
) }}

SELECT
    id AS wallet_id,
    account_id,
    created_at,
    currency_code,
    enabled AS is_enabled,
    provider_name,
    updated_at,
    type AS wallet_type
FROM
    {{ SOURCE('backend', 'wallets') }}