---
inclusion: auto
---

# Decision Policy — RE-SAP IFRS 16 Addon

## ADR-Style Decision Making
All significant decisions in this project are recorded as Architecture Decision Records (ADRs) in `docs/governance/decision-log.md`. An ADR is required for any decision that:

- Commits the project to a technical approach that would be costly to reverse.
- Establishes an accounting or compliance rule that will be implemented in code.
- Introduces a dependency on an external system, standard, or tool.
- Resolves a conflict between two valid approaches.
- Overrides a previous decision.

### ADR Structure
Each ADR entry must contain:

```
| Field | Content |
|-------|---------|
| ID | ADR-NNN (sequential) |
| Date | YYYY-MM-DD |
| Status | Proposed / Accepted / Rejected / Superseded / Deprecated |
| Title | Short imperative title (e.g., "Use effective interest method for liability amortization") |
| Context | Why this decision was needed; what forces are at play |
| Decision | What was decided and why |
| Alternatives Considered | Other options evaluated and why they were rejected |
| Consequences | Expected outcomes, trade-offs, and follow-up actions |
| Owner | Who approved this decision |
| Dependencies | ADRs that this depends on or that depend on this |
```

---

## When Agents Can Decide Autonomously
AI agents may proceed without human approval when the action falls within these boundaries:

| Autonomous Decision Type | Condition |
|--------------------------|-----------|
| Drafting a document section | For review only — clearly labeled "DRAFT — not approved" |
| Proposing a new ADR | Proposition only — not implementation |
| Adding a knowledge item to `knowledge/` | If source is internal and clearly labeled |
| Updating documentation to reflect an already-approved decision | When the ADR is in "Accepted" status |
| Creating or updating a test scenario | For UAT preparation — not for sign-off |
| Identifying risks and adding to risk register | For visibility only — risk severity must be human-validated |
| Proposing naming conventions or folder structure | For review — not enforced until approved |

---

## When Human Sign-Off is Mandatory
Human sign-off is required before an agent may advance past a proposal stage:

| Decision Requiring Sign-Off | Mandatory Approver(s) |
|-----------------------------|----------------------|
| IFRS 16 accounting rule codified as system logic | IFRS 16 Accountant |
| Functional spec approved for development | SAP RE Functional Consultant |
| Technical design approved for implementation | ABAP Architect |
| Any ADR moving from "Proposed" to "Accepted" | Project Governance Lead (+ domain lead if applicable) |
| Z object naming and package assignment finalized | ABAP Architect |
| Authorization concept approved | ABAP Architect + Security/Basis team |
| Test scenarios approved for UAT | QA Lead + IFRS 16 Accountant |
| Disclosure template approved | Controller |
| Phase completion / release sign-off | Project Governance Lead |
| Steering file modification | Project Governance Lead |

---

## How to Record Rejected Alternatives
Every ADR must document the alternatives that were considered and rejected. The purpose is to prevent revisiting settled debates and to provide future maintainers with context.

Format for rejected alternatives:

```
## Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| [Option A] | [Specific reason — not just "not suitable"] |
| [Option B] | [Specific reason] |
```

Rejected alternatives must be specific enough that a future team member can understand the reasoning without having to ask. Vague rejections like "too complex" or "not preferred" are not acceptable — explain the concrete trade-off.

---

## Dependency Tracking

### Cross-ADR Dependencies
When an ADR depends on another ADR being accepted first, this must be recorded in both ADRs:
- In the dependent ADR: "Depends on: ADR-NNN (must be accepted first)."
- In the prerequisite ADR: "Depended upon by: ADR-NNN."

### Cross-Spec Dependencies
When a spec item (task or story) depends on another being complete:
- Record in `specs/000-master-ifrs16-addon/tasks.md` in the "Dependencies" column.
- Block the dependent task until the prerequisite is marked "Done."

### External Dependencies
All external dependencies (SAP Notes, BAPI confirmations, legal/compliance sign-off) must be:
- Recorded in `docs/governance/assumptions-register.md` as an assumption requiring validation.
- Linked to the ADR or spec item that depends on them.
- Assigned an owner and target confirmation date.

---

## Decision Escalation Path
If a decision cannot be resolved within the immediate team:

1. Document the unresolved question as an open item in the relevant spec or ADR.
2. Assign it to the appropriate escalation owner (see escalation matrix below).
3. Set a target resolution date.
4. Block dependent work until resolved — do not proceed on unresolved blocking dependencies.

| Issue Type | Escalation Owner |
|------------|-----------------|
| IFRS 16 accounting interpretation disagreement | External IFRS 16 Accounting Advisor |
| SAP technical approach conflict | SAP Solution Architect |
| Project scope disagreement | Project Sponsor |
| Security / data governance conflict | Information Security Officer |
| Vendor/tool capability uncertainty | Vendor engagement — confirm with project lead |
