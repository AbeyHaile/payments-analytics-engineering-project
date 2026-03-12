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


