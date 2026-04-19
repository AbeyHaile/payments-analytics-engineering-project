
# AGENTS.md

## 🤖 AI Agent Onboarding & Project Standards

This document defines how AI agents generate production-grade analytics code for this project, ensuring consistency, data correctness, and alignment with modelling and semantic layer principles.

All generated or modified code must adhere to these standards to ensure consistency, maintainability, and production readiness.

## 1. Core Technical Principles
*   **Idempotency First:** Every model must be re-runnable without creating duplicate data or side effects. 
*   **Performance Optimization:** Prioritize single-column joins using surrogate keys over multi-column composite joins.
*   **Metric Centralization:** Business logic must reside in the **Semantic Layer (MetricFlow)** rather than being hardcoded as pre-aggregated columns in physical tables.
*   **Explicit Grain Definition:** Every model must clearly define and preserve its grain to prevent fan-out and metric inconsistencies.
*   **Late-Arriving Data Handling:** All incremental models must account for delayed updates in upstream systems.

---

## 2. Naming Conventions & Layering

| Layer | Prefix | Materialization | Purpose |
| :--- | :--- | :--- | :--- |
| **Staging** | `stg_` | `view` | 1:1 mirroring of source; renaming and casting only. |
| **Intermediate** | `int_` | `view` / `ephemeral` | Complex joins, JSON parsing, and entity resolution. |
| **Marts** | `fct_` / `dim_` | `incremental` | Stakeholder-ready fact and dimension tables. |

---

## 3. SQL & Snowflake Standards
*   **Surrogate Keys:** Every Mart must have a `kpi_report_pk`. Generate this using a deterministic `HASH()` of the primary grain columns.
*   **Incremental Strategy:** Use `incremental_strategy='delete+insert'` with a 3-day lookback window to handle late-arriving operational updates in Fintech workflows.
*   **Safe Division:** Use `DIV0()` or `NULLIF()` to prevent "Divide by Zero" errors in financial reporting.
*   **JSON Extraction:** Use Snowflake's `:` notation or `GET_PATH()` for extraction from `variant` columns.
*   **Column Ordering:** Primary key first, followed by other columns in logical or alphabetical order for consistency.
*   **No Implicit Fan-out:** All joins must preserve the intended grain; use window functions or aggregation to prevent duplication.

---

## 4. dbt & Testing Standards
*   **YAML Documentation:** Every model must have a corresponding `.yml` file in the same directory defining its schema.
*   **Mandatory Tests:**
    *   **Primary Keys:** `unique`, `not_null`.
    *   **Foreign Keys:** `relationships`.
    *   **Status Columns:** `accepted_values`.
*   **Business Logic Tests:** Use `dbt_utils.expression_is_true` for temporal checks (e.g., `activation_at >= signup_at`).
*   **Critical Model Coverage:** Core fact tables must include data quality checks for row count stability and metric sanity where applicable.

---

## 5. Semantic Layer Rules
When modifying `models/semantic/semantic_models.yml`:
*   **Single Source of Truth:** All business-facing metrics must be defined in the Semantic Layer to ensure consistency across dashboards, experiments, and AI-driven querying.
*   **Measures:** Define raw aggregations (`sum`, `count`) as the base layer.
*   **Metric Types:** Use `ratio` for percentages. This ensures the engine aggregates the numerator and denominator *before* dividing, preventing incorrect "averages of averages."

---

## 6. Prohibited Patterns
*   ❌ **No `SELECT *`:** Always explicitly name columns in CTEs for lineage clarity.
*   ❌ **No Hardcoded IDs:** Use `ref()` or `var()` for all object references.
*   ❌ **No Static Ratios:** Never pre-calculate percentages in SQL for Marts; delegate this to the Semantic Layer to maintain filter-safe math.
*   ❌ **No Metric Duplication:** Business logic must not be redefined across multiple models or BI tools; all metrics must originate from the Semantic Layer.
