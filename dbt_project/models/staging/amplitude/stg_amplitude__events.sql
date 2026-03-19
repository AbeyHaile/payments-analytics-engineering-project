{{ config(
    tags=['daily']
) }}

SELECT
    event_id,
    user_id,
    device_id,
    event_type,
    event_time,
    event_properties,
    user_properties,
    platform,
    os_name,
    country,
    city,
    app_version,
    session_id,
    server_upload_time
FROM
    {{ source('amplitude', 'events') }}