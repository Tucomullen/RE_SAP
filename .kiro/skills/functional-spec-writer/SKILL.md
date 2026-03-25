---
name: functional-spec-writer
description: >-
  Produce or update a functional specification for an IFRS 16 addon feature, covering business process, data requirements, UX, integration, and approval/audit trail design.
---

# Skill: Functional Specification Writer

## Title
Functional Specification Writer — IFRS 16 Z Addon Feature Specification

## Description
This skill produces or updates a functional specification document for a specific feature or epic of the IFRS 16 Z addon. Functional specs are the bridge between business requirements and technical design — they describe what the system must do without prescribing the technical implementation. All functional specs must align with the master requirements and master functional design.

## When to Use
- When a new epic or user story is ready for detailed functional design.
- When a functional spec needs to be updated following a change in requirements, an approved ADR, or UAT findings.
- When the team needs a functional spec to hand off to the ABAP Architect for technical design.
- When preparing documentation for a client blueprint sign-off workshop.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| Epic and stories to specify | The requirements being specified | specs/000-master-ifrs16-addon/requirements.md |
| SAP RE object mapping | How the requirement maps to RE-FX data and Z objects | SAP RE Object Mapping output |
| IFRS 16 domain analysis | Accounting rules and validation points | IFRS 16 Contract Analysis output or domain agent |
| Approved ADRs | Design decisions already confirmed | docs/governance/decision-log.md |
| UX designs (if available) | Screen designs from Stitch or description | knowledge/ux-stitch/ |
| Client process constraints | Known SAP landscape constraints | knowledge/sap-functional/ |

---

## Steps

### Step 1: Establish Context and Scope
Define clearly:
- Feature name and spec ID (e.g., SPEC-001-CONTRACT-INTAKE).
- Which Epic(s) and Story(ies) from requirements.md this spec covers.
- What is explicitly in scope and out of scope for this spec.
- Dependencies on other specs (what must be designed first).

### Step 2: Business Process Description
Describe the end-to-end business process this feature supports:
- Who does what, when, and why (actor + action + trigger + purpose).
- Use a process flow description or Mermaid flowchart.
- Note which steps are manual, which are system-automated, and which require an approval.

### Step 3: Functional Requirements Detail
For each user story in scope, write:
- **Given / When / Then** format for acceptance criteria.
- System behavior for the happy path.
- System behavior for each error/exception scenario.
- Validation rules (field-level and business rule level).
- IFRS 16 accounting rule applied (with paragraph reference).

### Step 4: Data Requirements
Specify:
- All input data fields (label, type, length, mandatory/optional, source, validation rule, IFRS 16 relevance).
- All output data (what the system produces, where it is stored, who sees it).
- Data transformation rules (how input data is converted to calculation inputs).
- Data retention requirements [TO BE CONFIRMED — retention policy].

### Step 5: User Interface Requirements
Describe:
- Screen layout concept (wizard, form, list, report).
- Field grouping and progressive disclosure approach.
- Mandatory vs. optional field presentation.
- Smart default behavior (pre-population from RE-FX data).
- Validation messages in plain language (not SAP message IDs).
- Key actions (buttons, workflow triggers).
- Role-based field visibility.

### Step 6: Integration Points
Describe:
- What data is read from RE-FX (standard objects and fields — to be confirmed).
- What data is written to Z tables.
- What events trigger FI/AA/CO integration.
- What approval workflow steps are required before FI posting.

### Step 7: Approval and Audit Trail
Describe:
- Which actions require human approval and who approves.
- What audit trail is generated for each action.
- How an auditor would retrieve evidence for this process step.

### Step 8: Out-of-Scope and Assumptions
Explicitly list:
- What is NOT covered by this spec (to prevent scope creep).
- Assumptions made in this spec with validation status.

---

## Expected Outputs

1. **Functional Specification Document** — Complete spec following the steps above, saved in `specs/` or updated in `docs/functional/master-functional-design.md`.
2. **Open Items List** — Items requiring human validation before the spec is complete.
3. **Traceability Matrix** — Links from spec sections to requirements Epic/Story IDs and ADR numbers.
4. **Ready-for-Technical-Design Checklist** — Confirmation that all inputs for technical design are present.

---

## Quality Checks

- [ ] Every requirement from the target Epic/Stories is addressed.
- [ ] All acceptance criteria are in Given/When/Then format with concrete values.
- [ ] All IFRS 16 rules cited with paragraph numbers.
- [ ] Data fields table complete with type, validation, and source.
- [ ] Approval gates and audit trail requirements documented.
- [ ] Out-of-scope list explicit.
- [ ] Assumptions registered in docs/governance/assumptions-register.md.
- [ ] No technical implementation detail in the functional spec (that belongs in technical design).
- [ ] Traceability footer added to every section.

---

## Handoff to Next Role/Agent

- **SAP RE Functional Consultant (Human):** Review and sign off the functional spec before technical design begins.
- **IFRS 16 Accountant (Human):** Validate all IFRS 16 accounting rule applications in the spec.
- **ABAP Architecture Specialist (abap-architecture):** Use the approved functional spec as input to the technical design.
- **Docs Continuity Agent (docs-continuity):** Ensure docs/functional/master-functional-design.md is updated to reflect the new spec.
- **QA/Audit Controls Agent (qa-audit-controls):** Use the acceptance criteria to start building the UAT scenario pack.
