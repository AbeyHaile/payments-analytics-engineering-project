{{ config(
    tags=['daily']
) }}

SELECT
    id AS disbursement_id,
    account_id,
    amount AS disbursement_amount,
    created AS disbursement_created_at,
    currency AS disbursement_currency,
    reference,
    status AS disbursement_status,
    transaction_id,
    updated AS disbursement_updated_at
FROM
    {{ source('backend', 'disbursements') }}