{{ config(
    materialized='view',
    tags=['hourly']
) }}

SELECT
    id AS disbursement_attempt_id,
    created_at,
    disbursement_id,
    error,
    provider_name AS disbursement_provider,
    state AS disbursement_attempt_state,
    last_updated_at AS updated_at
FROM
    {{ SOURCE('backend', 'disbursement_attempts') }}