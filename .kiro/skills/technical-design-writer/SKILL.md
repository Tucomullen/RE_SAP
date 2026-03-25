---
name: technical-design-writer
description: >-
  Produce or update an ABAP technical design for an IFRS 16 addon component, covering data model, class and interface design, integration, logging, authorization, and transport strategy.
---

# Skill: Technical Design Writer

## Title
Technical Design Writer — IFRS 16 Z Addon ABAP Technical Design

## Description
This skill produces or updates the technical design for a specific IFRS 16 addon component, based on an approved functional specification. Technical designs are consumed by ABAP developers to implement Z objects. All technical designs must respect the architecture principles in .kiro/steering/tech.md and .kiro/steering/sap-re-architecture.md and must be reviewed by the ABAP Architect before development begins.

## When to Use
- When a functional spec has been approved and technical design is the next step.
- When an existing technical design needs to be updated following a functional change or ADR.
- When reviewing technical debt or proposing an architectural refactoring.
- When preparing for an ABAP development kickoff.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| Approved functional specification | The functional spec for the component being designed | specs/ or docs/functional/ |
| Architecture principles | Current technical architecture baseline | docs/technical/master-technical-design.md |
| SAP RE object mapping | Z extension requirements and integration points | SAP RE Object Mapping output |
| Approved ADRs | Technical decisions already confirmed | docs/governance/decision-log.md |
| Naming conventions | Z object naming rules | .kiro/steering/structure.md |

---

## Steps

### Step 1: Component Context
Define:
- Component name and technical design ID.
- Which functional spec this implements (reference).
- Which ABAP package(s) this component belongs to.
- Dependencies on other Z components (what must exist before this can be built).
- S/4HANA compatibility considerations for this component.

### Step 2: Data Model Design
For each Z table or Z table extension:
- Table name (per naming convention — to be confirmed).
- Table purpose and ownership.
- Field list: field name, data type (ABAP Dictionary type or Z domain), length, key flag, description.
- Primary key design.
- Foreign key relationships.
- Index requirements (for batch performance).
- Change document requirement (yes/no + why).
- Buffering recommendation.
- Archiving consideration.
- Migration note for S/4HANA: `[ECC-SPECIFIC: ...]` if applicable.

Format: Mermaid ERD or structured table.

### Step 3: Class and Interface Design
For each Z class or interface:
- Class name and ABAP package.
- Purpose and responsibility (single responsibility principle).
- Public interface: method signatures with parameter names, types, and direction.
- Exception classes used.
- Dependencies (other classes/interfaces this uses).
- Unit testability note: how this class can be unit tested (mock dependencies via interface injection).
- Inheritance/composition relationships.

Format: Structured table or UML class diagram description.

### Step 4: Program/Job Design
For each Z program, batch job, or transaction:
- Program name and type (report, dialog, background).
- Entry point: transaction code or job step.
- Selection screen design: parameters, select-options, variants.
- Processing logic outline: numbered steps without ABAP code (design intent, not implementation).
- Error handling strategy: what errors are expected, how they are logged, what the user sees.
- Performance strategy: parallel processing approach, commit points, index usage.
- Authorization check: which authorization objects are checked and when.

### Step 5: Integration Design
For each integration point with RE-FX, FI-AA, FI-GL, or CO:
- Integration type: direct table read, BAPI call, FM call, BAdI implementation, user exit.
- Specific object name [TO BE CONFIRMED if not yet validated].
- Data read/written: exact fields.
- Error handling at integration boundary.
- Rollback/compensating transaction strategy for failed integrations.
- S/4HANA note if the integration method changes in S/4.

### Step 6: Logging and Auditability Design
Specify:
- SLG1 log object and sub-object for this component.
- Which events are logged at what severity level (Information, Warning, Error).
- Z audit table entries (if beyond SLG1 — for long-term retention).
- How an administrator monitors this component's execution.

### Step 7: Authorization Design
Specify:
- Which Z authorization objects apply.
- Which fields of each auth object are checked.
- Which roles should have which auth object values.
- Where authorization checks are performed in the code (method/program/transaction).

### Step 8: Transport Design
Specify:
- Transport type for each object: Workbench (programs, classes, tables) vs. Customizing (table contents, IMG entries).
- Transport sequence: which transports depend on others being imported first.
- Test data transport: what test data must exist before the transport can be tested in QA.

---

## Expected Outputs

1. **Technical Design Document** — Complete design per steps above, saved or merged into docs/technical/master-technical-design.md.
2. **Z Object Inventory** — Structured list of all new Z objects proposed (name, type, package, purpose).
3. **Open Technical Questions** — Items requiring ABAP Architect clarification or SAP landscape confirmation.
4. **Ready-for-Development Checklist** — Confirms all necessary inputs for ABAP development are present.

---

## Quality Checks

- [ ] All Z objects follow naming conventions from .kiro/steering/structure.md.
- [ ] Data model includes all fields required by functional spec.
- [ ] All classes use ABAP OO — no procedural code in business logic.
- [ ] Exception classes defined for all error paths.
- [ ] Unit testability addressed for calculation logic classes.
- [ ] All standard SAP integration points marked [TO BE CONFIRMED] if not yet validated.
- [ ] ECC-specific choices flagged with '[ECC-SPECIFIC: ...]'.
- [ ] Authorization objects defined for all sensitive operations.
- [ ] Transport sequence documented.
- [ ] Traceability footer links to functional spec and ADRs.

---

## Handoff to Next Role/Agent

- **ABAP Architect (Human):** Review and approve the technical design before development begins. Confirm Z object naming, package assignment, and transport strategy.
- **ABAP Developer (Human):** Use the approved technical design to implement Z objects.
- **Docs Continuity Agent (docs-continuity):** Merge approved design into docs/technical/master-technical-design.md.
- **QA/Audit Controls Agent (qa-audit-controls):** Use the component design to build unit test specifications and integration test scenarios.
