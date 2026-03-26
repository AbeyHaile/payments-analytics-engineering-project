{{ config(
    unique_key='kpi_report_pk'
) }}

WITH pipeline AS (
    SELECT
        task_created_date,
        primary_entity_type,
        workflow_execution_result,
        COUNT(task_id) AS total_tasks_created,
        COUNT(CASE WHEN task_state = 'RESOLVED' THEN 1 END) AS total_tasks_resolved,
        AVG(CASE WHEN task_state = 'RESOLVED' THEN minutes_to_resolution END) AS avg_minutes_to_resolution,
        COUNT(CASE WHEN workflow_execution_result = 'FAIL' AND resolution = 'APPROVED' THEN 1 END) AS total_false_positives,
        COUNT(CASE WHEN workflow_execution_result = 'FAIL' AND resolution = 'REJECTED' THEN 1 END) AS total_true_positives
    FROM 
        {{ ref('int_fincrime__task_workflow_mapping') }}
    
    {% if is_incremental() %}
    WHERE task_created_date >= (
        SELECT DATEADD('day', -3, MAX(task_created_date))
        FROM {{ this }})
    {% endif %}
    
    GROUP BY
        task_created_date,
        primary_entity_type,
        workflow_execution_result
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['task_created_date', 'primary_entity_type', 'workflow_execution_result']) }} AS kpi_report_pk,
    *,
    ROUND((total_tasks_resolved / NULLIF(total_tasks_created, 0)), 2) AS resolution_rate
FROM 
    pipeline