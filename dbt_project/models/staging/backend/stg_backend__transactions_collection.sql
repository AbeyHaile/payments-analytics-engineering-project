{{ config(
    tags=['hourly']
) }}

SELECT
    id AS collection_id,
    account_id,
    amount AS collection_amount,
    created_at AS collection_created_at,
    currency,
    state AS collection_state,
    to_wallet_id,
    transaction_id,
    updated_at AS collection_updated_at
FROM
    {{ source('backend', 'transactions_collection') }}