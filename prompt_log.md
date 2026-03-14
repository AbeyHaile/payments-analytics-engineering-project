# AI Prompt Log

This document records the substantive AI prompts used to support the completion of this assessment.

## 1. Repository and Deliverables Structure

**Prompt**
> I want to share my task as a GitHub repo. I want to create a README file, a source-to-target mapping document, a POC document for the requests from finance and other stakeholders, and YAML documentation for each model. Here is the design of course needs updating:
>
> `nala-analytics-assessment/`
> `├── dbt_project/`
> `├── docs/`
> `├── README.md`
> `└── .gitignore`

**How it was used**
- Helped define the initial repository structure
- Shaped the decision to separate documentation from dbt assets
- Led to the addition of dedicated files such as `architecture.md`, `source_to_target_mapping.md`, `poc_requirements.md`, and `prompt_log.md`

---

## 2. Assessment Repository Framing

**Prompt**
> You know this file won’t be runnable, right?

**How it was used**
- Helped define the execution note in the README
- Clarified that the submission should be presented as a design and architecture artefact rather than an executable project
- Informed the wording used to explain why real source systems and datasets were not included

---

## 3. README Structure and Positioning

**Prompt**
> Let’s add the instruction for the assessment PDF in the readme file.

**How it was used**
- Led to including the original assessment brief in the repository
- Helped improve README traceability between the brief and the solution
- Resulted in a dedicated “Assessment Instructions” section and requirement mapping table

---

## 4. Architecture Document Structure

**Prompt**
> Architecture Document created in docs and paste the subtitles.

**How it was used**
- Helped establish the structure of `docs/architecture.md`
- Produced the main sections covering overview, source systems, Snowflake provisioning, dbt layering, materialization strategy, CDC handling, cross-source enrichment, mart design, semantic layer, testing, orchestration, and assumptions

---

## 5. Source-to-Target Mapping Design

**Prompt**
> I want to do this in gsheet.

**How it was used**
- Helped decide that source-to-target mapping would be easier to maintain in spreadsheet format
- Confirmed that a tabular structure is appropriate for lineage and transformation documentation
- Informed the idea of storing a maintained mapping outside the core markdown docs while still referencing it from the repository

---

## 6. Source-to-Target Mapping Scope

**Prompt**
> Source should be staging layer model and target should be either semantic or analytics.

**How it was used**
- Refined the scope of the mapping from raw-source lineage to analytics-layer lineage
- Shifted the focus toward dbt staging models, analytics marts, and semantic outputs
- Helped align the mapping with the actual assessment deliverables rather than generic ingestion lineage

---

## 7. Column-Level Mapping Requirement

**Prompt**
> It’s not just targeting tables. It has to target columns. How are the aggregates computed from the staging column? Is it SUM, AVG, ...?

**How it was used**
- Clarified that the source-to-target mapping should be column-level rather than table-level
- Introduced the need to document transformation logic and aggregation rules explicitly
- Influenced the design of the mapping to include target column, source column, transformation logic, aggregation type, and business meaning

---

## 8. Staging-First Modelling Approach

**Prompt**
> Maybe we’re ahead of ourselves. Let’s do staging models and YAML first.

**How it was used**
- Reset the implementation sequence to start with the staging layer
- Reinforced a dbt-first workflow: sources → staging SQL → model YAML → downstream layers
- Helped prioritise the backend, fincrime, and amplitude staging models before moving to marts and semantic definitions

## 9. README Quality Review

**Prompt**
> Current status review

Your current **AI Prompt Log is already good**, but for an assessment it should show three things clearly:

1. **AI was used as an assistant, not as the author**
2. **Prompts were task-specific**
3. **You verified outputs against the assessment document**

Right now your log focuses mostly on **documentation prompts**, but most of the real AI assistance happened during:

* **dbt staging model generation**
* **YAML schema creation**
* **scheduling strategy**
* **data validation rules**

You should add those. Below are **additional entries that are strictly tied to the task work**.

---

# Additional AI Prompt Log Entries

### 10. Staging Model Generation

**Prompt**

> Generate a dbt staging model for a backend table described in the assessment document.
> Requirements:
>
> * Use the naming convention `stg_backend__<table_name>`
> * Rename `id` to `<entity>_id`
> * Keep standard columns (`created_at`, `updated_at`, `currency`, `provider_name`) unchanged
> * Do not transform data in staging
> * Order columns with the primary key first and remaining columns alphabetically

**How it was used**

* Accelerated the creation of consistent staging SQL models
* Ensured consistent naming conventions across backend staging tables
* Reduced manual effort when generating repetitive model structures

---

### 11. YAML Schema Documentation

**Prompt**

> Generate dbt YAML documentation for the staging model with column descriptions and data tests.
> Include:
>
> * `not_null` and `unique` tests for primary keys
> * `relationships` tests for foreign keys
> * `accepted_values` tests for enum columns defined in the documentation

**How it was used**

* Assisted in generating YAML schema files for each staging model
* Ensured consistent documentation format across the project
* Helped identify missing validation tests

---

### 12. Relationship Identification

**Prompt**

> Identify which columns in the backend schema represent foreign key relationships between tables.

**How it was used**

* Helped validate relationship tests between staging models
* Confirmed links such as `transaction_id`, `recipient_id`, and `account_id`
* Prevented incorrect relationships for non-key fields like `provider_name`

---

### 13. Scheduling Strategy

**Prompt**

> Based on table update frequency and approximate row counts, recommend scheduling tags (`hourly`, `four_hourly`, `daily`) for staging models.

**How it was used**

* Supported the scheduling strategy for the dbt project
* Identified operational tables requiring higher refresh frequency
* Balanced data freshness with warehouse compute cost

---

### 14. Scheduling Validation Using Table Volumes

**Prompt**

> Cross-validate the proposed scheduling strategy against table volumes and operational importance.

**How it was used**

* Confirmed that high-volume payment flow tables should run more frequently
* Justified a mixed scheduling strategy combining hourly and four-hourly runs
* Helped document orchestration reasoning

---

### 15. Data Quality Review

**Prompt**

> Review the staging YAML schemas and identify missing tests or validation rules.

**How it was used**

* Helped ensure enum columns include `accepted_values`
* Verified that primary keys include `not_null` and `unique` tests
* Identified missing relationship validations between models

---


