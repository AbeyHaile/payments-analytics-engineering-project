{{ config(
    tags=['daily']
) }}

SELECT
    workflow_id,
    rule_id
FROM
    {{ SOURCE('fincrime', 'workflow_rules') }}