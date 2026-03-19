{{ config(
    tags=['daily']
) }}

SELECT
    id AS rule_execution_review_id,
    rule_execution_id,
    reviewer_id,
    review AS review_outcome,
    review_comment,
    reviewed_at
FROM
    {{ SOURCE('fincrime', 'rule_execution_reviews') }}