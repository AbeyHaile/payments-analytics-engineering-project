# NALA Analytics Engineering Assessment

This repository contains my solution for the **NALA Senior Analytics Engineer technical assessment**. 

The goal of this submission is to design a scalable analytics architecture and dbt transformation layer that integrates multiple operational data sources and exposes reliable business metrics through a semantic layer.

## Project Focus
- Data modelling best practices
- Clear separation of transformation layers
- Documentation of assumptions and architecture
- Traceability between requirements and implementation
- Production-ready dbt project structure

---
## 🗺️ Project Navigation

To review the specific deliverables for the Senior Analytics Engineer assessment, please use the links below:

### 📖 Documentation & Strategy
* **[Architecture Decision Log](docs/architecture.md)**: Detailed reasoning for Snowflake provisioning, `delete+insert` incremental strategies, and the 3-day lookback logic.
* **[AI Agent Handbook (AGENTS.md)](AGENTS.md)**: Operational instructions and standards for AI agents interacting with this repository.
* **[AI Prompt Log (PROMPT_LOG.md)](prompt_log.md)**: A transparent record of AI collaboration used to develop this project (Deliverable 3).

### 📊 Requirement Mapping (Models)
| Business Requirement | Primary dbt Model |
| :--- | :--- |
| **1. Finance Performance** | `fct_daily_corridor_performance.sql` |
| **2. Ops Performance** | `fct_daily_disbursement_provider_performance.sql` |
| **3. Fincrime Ops** | `fct_daily_rule_performance.sql` |
| **4. Fincrime Pipeline** | `int_fincrime__task_workflow_mapping.sql` |
| **5. Growth POC** | `dim_users.sql` |

### 🧠 Semantic Layer
* **[Semantic Model Definitions](models/semantic/semantic_models.yml)**: MetricFlow definitions for Success Rates, False Positive Rates, and Activation Funnels.

## Assessment Instructions

The original assessment brief provided by NALA is included for reference.

See: `assessment/nala_assessment_instructions.pdf`
[NALA Assessment Instructions](assessment/senior_ae_take_home.pdf)

This repository contains my proposed analytics architecture, dbt project structure, and documentation addressing the requirements outlined in the brief.

## High-Level Architecture
The analytics layer follows a structured transformation flow to ensure data quality and lineage:

```
Raw Sources
   ↓
Staging Layer
   ↓
Intermediate Layer
   ↓
Marts Layer
   ↓
Semantic Layer
```

## Key Data Sources
The architecture integrates three primary operational systems:

• **Backend Transaction System**
- Core payments
- Users
- Transfers
- Disbursements

• **Fincrime Platform**
- Fraud detection workflows
- Task queues
- Rule evaluations.

• **Amplitude**
- Product analytics events used for exploratory behavioural analysis.

---

## Repository Structure
```text
nala-analytics-assessment/
├── README.md
├── .gitignore
├── assessment/
│   └── nala_assessment_instructions.pdf
├── docs/
│   ├── architecture.md
│   ├── source_to_target_mapping.md
│   ├── poc_requirements.md
│   ├── assumptions.md
│   └── prompt_log.md
└── dbt_project/
    ├── dbt_project.yml
    ├── models/
    │   ├── staging/
    │   ├── intermediate/
    │   ├── marts/
    │   └── semantic/
    ├── tests/
    ├── seeds/
    └── macros/
```
---

## Mapping to Assessment Requirements
Requirement                | Location
---------------------------|----------------------------------
Architecture description   | docs/architecture.md
Source → target mapping    | docs/source_to_target_mapping.md
POC documentation          | docs/poc_requirements.md
Model documentation (YAML) | dbt_project/models
AI prompt log              | docs/prompt_log.md

---

## Design Principles

The design of this solution follows several analytics engineering principles:

• **Layered transformation architecture**
(staging → intermediate → marts → semantic)

• **Clear grain definition for each model**

• **Reusable intermediate models**

• **Separation of production vs exploratory models**

• **Explicit documentation of assumptions**

• **Testing and data quality checks embedded in dbt models**

---

## Execution Note
This repository represents the **design and architecture** for the assessment.

The project is intentionally **not runnable** because:

- Source datasets were not provided
- External systems (Backend, Fincrime, Amplitude) are not accessible
- The objective of the assessment is to evaluate architecture, modelling, and documentation rather than executable pipelines.

All models are written as they would appear in a **production dbt project**.


