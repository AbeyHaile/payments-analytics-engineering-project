{{ config(
    tags=['daily']
) }}

SELECT
    id AS rule_execution_id,
    rule_id,
    workflow_execution_id,
    result AS rule_execution_result,
    condition_result,
    context AS rule_execution_context,
    NULLIF(context:user_id::STRING, '') AS user_id,
    NULLIF(context:transaction_id::STRING, '') AS transaction_id,
    created_at,
    started_at,
    ended_at,
    error AS rule_execution_error,
    review AS rule_review_status,
    review_comment,
    reviewer_id,
    reviewed_at
FROM
    {{ SOURCE('fincrime', 'rule_executions') }}