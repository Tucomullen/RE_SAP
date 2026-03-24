# Knowledge Base: Project Decisions and ADRs

**Priority Level:** 3 (binding for this project once Accepted)
**Location:** `knowledge/project-decisions/`
**Managed by:** Project Governance Lead + RAG Knowledge Curator Agent

---

## Purpose
This folder mirrors and extends the ADR entries in `docs/governance/decision-log.md`. While the decision log is the authoritative record table, this folder stores the **full ADR content** as individual knowledge files, enabling agents to retrieve detailed decision rationale, alternatives considered, and consequences without reading the full decision log.

Every Accepted ADR must have a corresponding file in this folder.

---

## File Structure

Each decision file follows this naming convention:
```
ADR-NNN-YYYY-MM-DD-[short-title].md
```
Example: `ADR-001-2026-03-24-abap-oo-mandate.md`

### Required File Content

```markdown
---
source-type: project-decision
source-name: ADR-NNN — [Short Title]
source-date: YYYY-MM-DD
source-version: v1.0
priority: 3
confidence: high
status: [current | superseded | deprecated]
tags: [keywords]
cited-in: []
added-by: [name]
added-date: YYYY-MM-DD
validated-by: [Project Governance Lead name]
validation-date: YYYY-MM-DD
---

# ADR-NNN — [Full Title]

## Status: [Proposed | Accepted | Rejected | Superseded]
## Date: YYYY-MM-DD
## Owner: [Human role who approved]

## Context
[Why this decision was needed; what problem it solves; what constraints apply]

## Decision
[Exactly what was decided, in specific, actionable terms]

## Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| [Option A] | [Specific rejection reason] |
| [Option B] | [Specific rejection reason] |

## Consequences
[Expected outcomes: positive, negative, trade-offs, follow-up actions required]

## Dependencies
- Depends on: [ADR-NNN or None]
- Depended upon by: [ADR-NNN or None]
```

---

## How to Add a New Decision

1. A decision is first recorded as `Proposed` in `docs/governance/decision-log.md`.
2. When the Project Governance Lead approves it (status → `Accepted`), create the full ADR file here.
3. Apply the required frontmatter with `validated-by` field.
4. Update `cited-in` field when other documents reference this ADR.
5. Update this README index.

---

## Transition Between Statuses

| From | To | Trigger | Action |
|------|---|---------|--------|
| Proposed | Accepted | Governance Lead approval | File created here; status current |
| Accepted | Superseded | A new ADR replaces this | Add `superseded-by: ADR-NNN`; status → superseded |
| Accepted | Deprecated | Decision no longer applies | Note reason; status → deprecated |
| Proposed | Rejected | Decision rejected | File created here with status Rejected; document reason |

---

## Index of Current Decisions

| ADR | Title | Status | Date | Key Area |
|-----|-------|--------|------|---------|
| ADR-001 | ABAP OO mandate for all Z development | Proposed | 2026-03-24 | Technical architecture |
| ADR-002 | Z object naming convention adoption | Proposed | 2026-03-24 | Development standards |
| ADR-003 | Application logging via SAP SLG1 + Z audit table | Proposed | 2026-03-24 | Auditability |
| ADR-004 | Human approval gate mandatory before FI posting | Proposed | 2026-03-24 | Governance/controls |
| ADR-005 | S/4HANA compatibility by design — no deprecated ABAP | Proposed | 2026-03-24 | Technical architecture |

> All above are Proposed. They require Project Governance Lead approval to move to Accepted. File full ADR content when approved.

---

## Rejected Decisions
Rejected decisions are retained here to prevent re-opening settled debates. They are tagged `status: rejected` and include the rejection rationale.
