{{ CONFIG(
    TAGS=['hourly']
) }}

SELECT
    id AS user_id,
    allowed AS user_allowed_at,
    client_properties AS user_client_properties,
    created AS created_at,
    profile_picture,
    sender_country,
    source AS user_source,
    status AS user_status,
    used_invitation_code_id,
    usage AS user_usage
FROM 
    {{ SOURCE('backend', 'users') }}