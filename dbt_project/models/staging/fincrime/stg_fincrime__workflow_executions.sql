{{ config(
    tags=['daily']
) }}

SELECT
    id AS workflow_execution_id,
    workflow_id,
    result AS workflow_execution_result,
    context AS workflow_execution_context,
    NULLIF(context:user_id::STRING, '') AS user_id,
    NULLIF(context:transaction_id::STRING, '') AS transaction_id,
    created_at,
    started_at,
    ended_at,
    error AS workflow_execution_error,
    actions AS workflow_execution_actions
FROM {{ SOURCE('fincrime', 'workflow_executions') }}