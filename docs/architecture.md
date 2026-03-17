Here is the finalized, senior-level **Architecture Document** in Markdown format. This version is specifically tailored to the NALA assessment requirements, emphasizing the "why" behind your engineering choices.

---

# Architecture Document: NALA Payments Analytics

## 1. Overview

This document outlines the analytics architecture designed to transform raw backend, Fincrime, and Amplitude data into a governed, consumption-ready layer in Snowflake. The design prioritizes **idempotency**, **auditability**, and **semantic consistency** to support both human stakeholders and AI agents.

## 2. Snowflake Provisioning & Role Hierarchy

* **Databases:**
* `RAW`: Ingestion point for CDC (Backend/Fincrime) and Batch (Amplitude) data.
* `ANALYTICS`: Primary transformation and consumption database.


* **Warehouses:**
* `DBT_TRANSFORM_WH`: X-Small (Standard) for routine runs; optimized for cost.
* `REPORTING_WH`: Multi-cluster enabled to handle concurrent BI and Semantic Layer queries.


* **Roles:** Functional roles (`LOADER`, `TRANSFORMER`, `REPORTING`) ensure a "least-privilege" security model.

## 3. dbt Layering & Materialization Strategy

The project follows a modular, three-tier dbt structure:

| Layer | Materialization | Rationale |
| --- | --- | --- |
| **Staging** | `view` | Renaming, casting, and initial CDC deduplication. |
| **Intermediate** | `view` / `ephemeral` | Complex joins and cross-source entity resolution (e.g., Task-to-Workflow mapping). |
| **Marts** | `incremental` | Aggregated, stakeholder-facing tables optimized for performance. |

### 3.1 Incremental Strategy: `delete+insert`

For all performance marts (Fincrime, Ops, and Finance), we utilize the **`delete+insert` strategy** with a **3-day lookback window**.

* **Logic:** Fintech operations are often asynchronous. A transaction or task created on Day 1 may only reach a terminal state (Resolved/Failed) on Day 3.
* **Implementation:** We use `get_max_of_table_column` to identify the high-water mark and subtract 3 days to re-process potentially updated records, ensuring 100% data accuracy without full table scans.

## 4. Data Integrity & Surrogate Keys

To support idempotent loading and high-performance joins, every Mart model utilizes a deterministic **Surrogate Key (`kpi_report_pk`)**.

* **Method:** `HASH()` of the aggregation grain (e.g., `date`, `provider`, `corridor`).
* **Benefits:** 1.  Ensures a single `unique_key` for dbt incremental logic.
2.  Provides a singular "handle" for debugging data collisions.
3.  Optimizes Snowflake's join engine compared to multi-column joins.

## 5. Cross-Source Enrichment (Requirement 4)

The mapping between **Fincrime Workflows** and **Backend Tasks** is a core challenge addressed in the Intermediate layer.

* **Entity Resolution:** We extract polymorphic identifiers (Transaction IDs vs. User IDs) from JSON metadata to link manual human actions in the Backend to the automated triggers in the Fincrime system.
* **Join Logic:** We prioritize Transaction-level matches over User-level matches using `QUALIFY ROW_NUMBER()` to ensure the most granular correlation is preserved.

## 6. Testing & Quality Standards

Data trust is enforced through a multi-layered testing strategy:

* **Schema Tests:** `unique`, `not_null`, and `accepted_values` on all primary keys and status columns.
* **Relational Logic Tests:** We utilize `dbt_utils.expression_is_true` to enforce business rules, such as:
* **Temporal Sanity:** `activation_at >= signup_at`.
* **Outcome Consistency:** Ensuring "False Positives" only occur when the system result was "FAIL".



## 7. Semantic Layer (MetricFlow)

Metrics are exposed via the **dbt Semantic Layer** to ensure "Single Source of Truth" definitions.

* **Ratio Handling:** Metrics like `false_positive_rate` are defined as ratios of measures. This ensures that when a user slices data by "Country" or "Rule Category," the Semantic Layer aggregates the numerators and denominators *before* dividing, preventing mathematical errors associated with pre-calculated percentages.

## 8. Orchestration & CI/CD

* **Schedule:** Hourly runs for Staging/Intermediate; Daily morning refreshes for Marts/Semantic layers.
* **Slim CI:** Implementation of state-based testing in GitHub Actions to ensure only modified models and their downstream impacts are tested during development.

---

### 9. Key Assumptions

* **CDC Handling:** We assume upstream ingestion provides a `_streamserve_timestamp` or similar for deduplication.
* **ID Stability:** We assume `user_id` and `transaction_id` are stable across systems.
* **Timezones:** All timestamps are standardized to `UTC` in the staging layer.
