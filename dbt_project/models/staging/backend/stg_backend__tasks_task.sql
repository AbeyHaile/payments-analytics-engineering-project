{{ config(
    tags=['daily']
) }}

SELECT
    id AS task_id,
    service,
    type AS task_type,
    state AS task_state,
    priority,
    staff_id,
    assignee_id,
    created_at,
    last_updated_at,
    resolution,
    -- associated_ids[0] = primary entity (user_id or transaction_id)
    associated_ids[0] AS primary_entity_id,
    -- associated_ids[2] = user_id for transaction tasks (optional)
    associated_ids[2] AS related_user_id,
    NULLIF(content:disbursement_id::STRING, '') AS disbursement_id,
    NULLIF(content:account_id::STRING, '') as account_id,
    NULLIF(content:provider_name::STRING, '') AS provider_name
FROM
    {{ SOURCE('backend', 'tasks_task') }}