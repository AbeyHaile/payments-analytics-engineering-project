{{ config(
    materialized='view',
    tags=['hourly']
) }}

SELECT
    rule_id,
    rule_name,
    rule_title,
    rule_category,
    rule_type,
    rule_version,
    created_at AS rule_created_at
FROM 
    {{ ref('stg_fincrime__rules') }}
WHERE 
    deleted_at IS NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY rule_name
    ORDER BY rule_version DESC, created_at DESC
) = 1