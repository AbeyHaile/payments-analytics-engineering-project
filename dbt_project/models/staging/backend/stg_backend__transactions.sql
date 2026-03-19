{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        tags=['daily']
    )
}}

SELECT
    id AS transaction_id,
    user_id,
    sent_amount,
    source_amount,
    received_amount,
    created_at,
    account_id,
    exchange_rate,
    from_wallet_id,
    recipient_account_id,
    recipient_id,
    received_currency,
    sent_currency,
    to_wallet_id,
    expires_at,
    fee_kind AS transaction_fee_kind,
    fee_label AS transaction_fee_label,
    memo AS transaction_memo,
    metadata AS transaction_metadata,
    purpose AS transaction_purpose,
    state AS transaction_state,
    summary AS transaction_summary,
    type AS transaction_type,
    updated_at,
    workflow_id
FROM 
    {{ SOURCE('backend', 'transactions_transaction') }}