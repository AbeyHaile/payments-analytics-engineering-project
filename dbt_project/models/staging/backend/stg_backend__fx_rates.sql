{{ config(
    tags=['hourly']
) }}

SELECT
    id AS fx_rate_id,
    amount,
    created_at,
    destination_currency,
    provider_name,
    rate,
    source_currency
FROM
    {{ SOURCE('backend', 'fx_rates') }}