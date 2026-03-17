{{ config(
    tags=['hourly']
) }}

SELECT
    id AS rule_id,
    name AS rule_name,
    title AS rule_title,
    description AS rule_description,
    type AS rule_type,
    category AS rule_category,
    team AS rule_team,
    condition AS rule_condition,
    version AS rule_version,
    created_at,
    updated_at,
    deleted_at
FROM 
    {{ source('fincrime', 'rules') }}