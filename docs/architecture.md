# Architecture Document

## 1. Overview


This document outlines the analytics architecture designed to transform raw backend, Fincrime, and Amplitude data into a governed, consumption-ready layer in Snowflake.

The design prioritizes:
- **Idempotency**
- **Auditability**
- **Semantic consistency**

This ensures the platform supports both **human stakeholders** and **AI agents**.

## 2. Snowflake Provisioning & Role Hierarchy

### Databases

- `RAW`  
  Ingestion layer for CDC (Backend/Fincrime) and batch (Amplitude) data

- `ANALYTICS`  
  Primary transformation and consumption layer

### Warehouses

- `DBT_TRANSFORM_WH`  
  X-Small (Standard) for routine transformations, optimized for cost

- `REPORTING_WH`  
  Multi-cluster warehouse to support concurrent BI and Semantic Layer workloads

### Roles

Functional roles enforce a **least-privilege model**:

- `LOADER`
- `TRANSFORMER`
- `REPORTING`

---

## 3. dbt Layering & Materialization Strategy

The project follows a modular, three-tier dbt structure:

| Layer | Materialization | Rationale |
| --- | --- | --- |
| **Staging** | `view` | Renaming, casting, and initial CDC deduplication. |
| **Intermediate** | `view` / `ephemeral` | Complex joins and cross-source entity resolution (e.g., Task-to-Workflow mapping). |
| **Marts** | `incremental` | Aggregated, stakeholder-facing tables optimized for performance. |

---

### 3.1 Incremental Strategy: `delete+insert`

All performance marts (Fincrime, Ops, Finance) use the **`delete+insert` strategy** with a **3-day lookback window**.

#### Rationale

Fintech workflows are asynchronous:
- A transaction created on Day 1 may only complete on Day 2–3
- Late-arriving updates must be captured reliably

#### Implementation

- Use a high-water mark (`max(metric_date)`)
- Reprocess **last 3 days**
- Ensures:
  - No missed updates
  - No full table scans
  - Deterministic outputs

---

## 4. Data Integrity & Surrogate Keys

To support idempotent loading and high-performance joins, every Mart model utilizes a deterministic **Surrogate Key (`kpi_report_pk`)**.

### Method:
* `HASH()` of the aggregation grain (e.g., `date`, `provider`, `corridor`).
### Benefits

1. Enables `unique_key` for dbt incremental models  
2. Simplifies debugging and traceability  
3. Improves join performance vs multi-column joins 

## 5. Cross-Source Enrichment (Requirement 4)

A key challenge is linking:

- **Fincrime workflows (automated decisions)**
- **Backend tasks (manual interventions)**

### Approach

- Extract identifiers from JSON metadata:
  - `transaction_id`
  - `user_id`
- Perform entity resolution in **Intermediate layer**

### Join Strategy

- Prioritize `transaction-level matches` 
- Fallback to `user-level matches`
- Using `QUALIFY ROW_NUMBER()` to ensure the most granular correlation is preserved.

## 6. Testing & Quality Standards

Data trust is enforced through a multi-layered testing strategy:

### Schema Tests

- `not_null`
- `unique`
- `accepted_values`
  
### Business Logic Tests
Using `dbt_utils.expression_is_true`:
* **Relational Logic Tests:** We utilize `dbt_utils.expression_is_true` to enforce business rules, such as:
* **Temporal Sanity:** `activation_at >= signup_at`.
* **Outcome Consistency:** Ensuring "False Positives" only occur when the system result was "FAIL".


## 7. Semantic Layer (MetricFlow)

Metrics are exposed via the **dbt Semantic Layer** to ensure consistent definitions.

### Key Principle: Ratio Safety

Metrics like: `false_positive_rate = false_positives / total_cases` 
are defined as **ratios of measures**, not pre-calculated fields.

### Why this matters

When slicing by dimensions (e.g., country, rule):

- Numerator and denominator are aggregated first
- Division happens afterward

This prevents incorrect aggregations.

Metrics are exposed via the **dbt Semantic Layer** to ensure "Single Source of Truth" definitions.

## 8. Orchestration & CI/CD

* **Schedule:** Hourly runs for Staging/Intermediate; Daily morning refreshes for Marts/Semantic layers.

---

### 9. Key Assumptions

* **CDC Handling:** We assume upstream ingestion provides a `_streamserve_timestamp` or similar for deduplication.
* **ID Stability:** We assume `user_id` and `transaction_id` are stable across systems.
* **Timezones:** All timestamps are standardized to `UTC` in the staging layer.

### 10. Requirements Mapping
## 13. Requirements Mapping

| Requirement | dbt Model | Implementation Detail |
| :--- | :--- | :--- |
| **1. Finance Performance** | `fct_daily_corridor_performance` | Aggregates outbound disbursements by corridor; includes success/fail/error volumes. |
| **2. Ops Performance** | `fct_daily_disbursement_provider_performance` | Tracks provider-specific health with SLA time-banding (e.g., `< 1 min`, `1-5 mins`). |
| **3. Fincrime Ops** | `fct_daily_rule_performance` | Calculates False Positive Rates (FPR) and Volume per rule name and category. |
| **4. Fincrime Pipeline** | `int_fincrime__task_workflow_mapping` | Primary "Heavy Lifting" model correlating Source 1 (Tasks) with Source 2 (Workflows). |
| **5. Growth (Exploratory)** | `dim_users` | Tracks onboarding milestones and `signup_to_first_transaction_hours` for funnel analysis. |
