{{ CONFIG(
    TAGS=['hourly']
) }}

SELECT
    id AS account_id,
    client_properties AS account_client_properties,
    created AS account_created_at,
    deleted AS account_deleted_at,
    features AS account_features,
    last_updated AS account_last_updated_at,
    limit_level AS account_limit_level,
    name AS account_name,
    status AS account_status,
    type AS account_type,
    profile_id,
    owner_id AS user_id
FROM 
    {{ SOURCE('backend', 'users_account') }}