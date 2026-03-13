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

**How it was used**
- Helped refine the README structure and presentation
- Improved clarity, architecture framing, and requirement traceability
- Supported the decision to include high-level architecture, key data sources, repository structure, and execution note sections

---


