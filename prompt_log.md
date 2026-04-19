# AI Collaboration Log

## AI Usage Principles

AI was used under strict constraints to ensure outputs remained aligned with production-grade analytics engineering standards:

- Outputs were treated as drafts and never accepted without validation
- All generated logic was reviewed against defined modelling standards (grain, joins, incremental logic)
- AI was not permitted to introduce new assumptions beyond provided requirements
- Final implementations were manually verified for correctness, performance, and consistency

## 1. Repository and Deliverables Structure

**Prompt**
> I want to structure this project as a GitHub repo with clear separation between dbt models, documentation, and supporting materials.
> Do not introduce assumptions that contradict the source material unless explicitly instructed.

**How it was used**
- Defined the repository structure and separation between dbt models and documentation.
- Led to the creation of: `architecture.md`, `source_to_target_mapping.md`, and `prompt_log.md`

---

## 2. Project Framing

**Prompt**
> This project is focused on design and modelling rather than execution.

**How it was used**
- Defined the scope of the project
- Led to the inclusion of a clear note explaining why the project is not runnable
- Ensured focus remained on architecture, modelling, and data design

---

## 3. README Structure and Positioning

**Prompt**
> Improve the README to clearly communicate the project structure, use cases, and modelling approach.

**How it was used**
- Improved clarity and structure of the README
- Strengthened positioning as a portfolio project rather than a task
- Aligned README with engineering best practices

---

## 4. Architecture Document Structure

**Prompt**
> Create an architecture document with clear sections covering data sources, transformation layers, and modelling approach.

**How it was used**
Defined structure of `docs/architecture.md`

Introduced sections for:
  
- data sources  
- transformation layers  
- materialisation strategy  
- orchestration  
- testing approach  
---

## 5. Source-to-Target Mapping Design

**Prompt**
> Design a structured mapping between source data and analytics outputs.

**How it was used**
- Clarified mapping requirements
- Highlighted need for column-level lineage and transformation logic
- Informed decision to document transformations directly in dbt models and YAML

---

### 6. YAML Schema Documentation

**Prompt**

> Generate dbt YAML documentation for the staging model with column descriptions and data tests.
> Include:
>
> * `not_null` and `unique` tests for primary keys
> * `relationships` tests for foreign keys
> * `accepted_values` tests for enum columns defined in the documentation

**How it was used**

* Generated initial YAML schema files, which were then reviewed and refined to ensure completeness and adherence to testing standards
* Ensured consistent documentation format across the project
* Helped identify missing validation tests

---

### 7. Relationship Identification

**Prompt**

> Identify foreign key relationships across the dataset.

**How it was used**

* Validated relationships between models
* Ensured accurate relationships tests
* Prevented incorrect joins on non-key fields

---

### 8. Scheduling Strategy

**Prompt**

> Recommend model execution frequency based on data volume and update patterns.

**How it was used**

* Informed orchestration strategy
* Balanced data freshness with compute cost
* Supported definition of refresh frequencies (e.g. hourly, daily)

---

### 9. Data Quality Review

**Prompt**

> Review models and identify missing data quality checks.

**How it was used**

* Validated that enum columns include accepted_values tests and corrected any inconsistencies
* Verified that primary keys include `not_null` and `unique` tests
* Identified missing relationship validations between models

---

## 🎯 Key Takeaway

AI was used as a controlled assistant to accelerate development, not as a source of truth.

All outputs were critically reviewed, validated, and adapted to ensure alignment with:
- business requirements  
- data modelling principles (grain, joins, incremental logic)  
- production-grade analytics engineering standards  

The final implementation reflects deliberate engineering decisions rather than generated outputs.
