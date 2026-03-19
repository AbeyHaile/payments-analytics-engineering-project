{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='task_id'
) }}

WITH tasks AS (
    SELECT
        task_id,
        created_at AS task_created_date,
        primary_entity_id,
        task_state,
        resolution,
        last_updated_at AS task_updated_at
    FROM {{ ref('stg_backend__tasks_task') }}
    WHERE service = 'fincrime'
    {% if is_incremental() %}
        -- 3-day lookback on task_updated_at to capture status changes
        WHERE last_updated_at >= (SELECT DATEADD('day', -3, MAX(task_updated_at)) FROM {{ this }})
    {% endif %}
),

workflows AS (
    SELECT
        workflow_execution_id,
        workflow_execution_result,
        transaction_id,
        user_id,
        created_at AS workflow_created_at
    FROM
        {{ ref('stg_fincrime__workflow_executions') }}
)

SELECT
    t.task_id,
    DATE(t.task_created_date) AS task_created_date,
    CASE 
        WHEN w_txn.transaction_id IS NOT NULL THEN 'TRANSACTION'
        WHEN w_usr.user_id IS NOT NULL THEN 'USER'
        ELSE 'UNKNOWN'
    END AS primary_entity_type,
    COALESCE(w_txn.workflow_execution_id, w_usr.workflow_execution_id) AS workflow_execution_id,
    COALESCE(w_txn.workflow_execution_result, w_usr.workflow_execution_result) AS workflow_execution_result,        
    t.task_state,
    t.resolution,
    DATEDIFF('minute', t.task_created_date, t.task_updated_at) AS minutes_to_resolution,
    t.task_updated_at
FROM 
    tasks t
LEFT JOIN workflows w_txn ON t.primary_entity_id = w_txn.transaction_id
LEFT JOIN workflows w_usr ON t.primary_entity_id = w_usr.user_id AND w_txn.transaction_id IS NULL
    
-- Prioritize Transaction matches over User matches if duplicates exist for a task
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY t.task_id 
    ORDER BY (CASE WHEN primary_entity_type = 'TRANSACTION' THEN 1 ELSE 2 END) ASC, 
    ABS(DATEDIFF('second', t.task_created_date, workflow_created_at)) ASC
) = 1