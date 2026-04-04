{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='transaction_id'
) }}

WITH transactions AS (
    SELECT
        transaction_id,
        user_id,
        recipient_account_id,
        transaction_type,
        transaction_state,
        sent_amount,
        sent_currency,
        received_amount,
        received_currency,
        created_at,
        updated_at
    FROM 
        {{ ref('stg_backend__transactions') }}

    {% if is_incremental() %}
        WHERE updated_at >= (
            SELECT DATEADD('day', -3, MAX(transaction_updated_at))
            FROM {{ this }}
        )
    {% endif %}

),

users AS (

    SELECT
        user_id,
        sender_country
    FROM
        {{ ref('stg_backend__users') }}

),

recipient_accounts AS (

    SELECT
        recipient_account_id,
        country
    FROM
        {{ ref('stg_backend__transactions_recipient_account') }}

)

SELECT
    t.transaction_id,
    DATE(t.created_at) AS metric_date,
    t.created_at AS transaction_created_at,
    t.updated_at AS transaction_updated_at,
    u.sender_country AS source_country,
    ra.country AS destination_country,
    CONCAT(u.sender_country, '-', ra.country) AS corridor,
    t.transaction_type,
    t.transaction_state,
    t.sent_amount,
    t.sent_currency,
    t.received_amount,
    t.received_currency,
    CASE
        WHEN t.transaction_type in (
            'DISBURSEMENT',
            'CONVERSION_DISBURSEMENT',
            'COLLECTION_CONVERSION_DISBURSEMENT'
        ) THEN 1
        ELSE 0
    END AS is_volume_qualifying
FROM 
    transactions t
LEFT JOIN users u
    ON t.user_id = u.user_id
LEFT JOIN recipient_accounts ra
    ON t.recipient_account_id = ra.recipient_account_id