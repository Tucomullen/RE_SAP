---
inclusion: always
description: Orchestration policy — master orchestrator rules, delivery pipelines by change type, specialist agent activation conditions, and Definition of Done.
---

# Orchestration Policy — RE-SAP IFRS 16 Addon

## ARCHITECTURAL MANDATE
All orchestration operates under **Option B** — the Z addon is the system of record. RE-FX is NOT the source of contract truth. Any pipeline stage that previously referenced `sap-re-ifrs16` for RE-FX object mapping now routes to `ecc-coverage-analyst` for business coverage preservation analysis. See `.kiro/steering/option-b-target-model.md`.

Every request must be tagged to at least one of the 9 Capability Domains (CD-01 to CD-09) defined in `option-b-target-model.md`. The capability domain tag is part of the classification output at Step 0.

---

## Principle: All Relevant Requests Enter Through the Master Orchestrator

Every relevant project request — new feature, functional change, screen or UX change, bugfix, technical architecture decision, documentation update, or any combination — must enter through the `orchestrator-ifrs16` agent first.

The orchestrator classifies the request, determines impact, activates the correct pipeline of specialist agents, chains required artifacts between stages, and enforces the Definition of Done. Users do not need to name which specialist to use. The orchestrator decides.

---

## Change Classification Taxonomy

| Type | Definition |
|------|------------|
| `new_feature` | New functional capability not yet described in specs/000-master-ifrs16-addon/requirements.md |
| `functional_change` | Changing the behavior of an existing feature, no new UI screens |
| `ui_change` | Any screen, layout, or UX change — may or may not involve functional change |
| `technical_change` | Architecture, ABAP design, Z objects, or integration — no user-visible behavior change |
| `bugfix` | Correcting incorrect or missing behavior |
| `documentation_change` | Updating docs, knowledge base, or specs without changing the product |
| `mixed_change` | Two or more types combined — the orchestrator decomposes and sequences sub-pipelines |

The orchestrator classifies every incoming request before taking any other action. If classification is ambiguous, it escalates to the human rather than guessing.

---

## Delivery Pipelines by Change Type

### Pipeline A — New Feature
Stages: A1 (US + AC in spec — tag capability domain CD-0x) → A2 (ifrs16-domain: accounting rules) → A3 (ecc-coverage-analyst: confirm business coverage preserved) → A4 (ux-stitch, if UI) → A5 (ui5-fiori-bridge, if screen.html exists) → A6 (abap-architecture, if ABAP needed) → A7 (tasks.md update) → A8 (docs-continuity) → A9 (qa-audit-controls) → A10 (governance check: Option B guard + capability domain mapped).

### Pipeline B — Functional Change (no UI)
Stages: B1 (spec impact + capability domain tag) → B2 (ifrs16-domain) → B3 (ecc-coverage-analyst: confirm coverage preserved) → B4 (abap-architecture, if needed) → B5 (spec/tasks update) → B6 (docs-continuity) → B7 (qa-audit-controls) → B8 (governance check: Option B guard).

### Pipeline C — UI / UX Change
Stages: C1 (spec + design contract check) → C2 (ux-stitch) → C3 (ui5-fiori-bridge, if screen.html exists) → C4 (ifrs16-domain, if accounting judgment exposed) → C5 (spec/tasks update) → C6 (docs-continuity) → C7 (qa-audit-controls) → C8 (UX traceability check).

### Pipeline D — Bugfix
Stages: D1 (reproduce + classify bug type) → D2 (run sub-pipeline B/C/E as appropriate) → D3 (qa-audit-controls: regression + prevention) → D4 (docs-continuity, if user-visible) → D5 (tasks.md closure).

### Pipeline E — Technical Change
Stages: E1 (abap-architecture) → E2 (ecc-coverage-analyst, if ECC integration boundaries impacted) → E3 (spec/doc impact check + Option B guard) → E4 (docs-continuity) → E5 (qa-audit-controls) → E6 (ADR proposal if architectural).

### Pipeline F — Documentation Change
Stages: F1 (docs-continuity: cross-layer alignment) → F2 (rag-knowledge, if knowledge/ affected) → F3 (traceability footers + version headers).

### Pipeline G — Mixed Change
Decompose into constituent types, announce the decomposition and sequence, run pipelines in dependency order, apply a single shared closure gate at the end.

---

## Specialist Agents and Activation Conditions

| Agent | When activated |
|-------|----------------|
| `ifrs16-domain` | Any change involving IFRS 16 accounting rules, lease identification, measurement, disclosures |
| `ecc-coverage-analyst` | Any change requiring analysis of current ECC business functionality to preserve in Option B |
| `abap-architecture` | Any change involving Z objects, ABAP classes, tables, batch jobs, or integration patterns |
| `ux-stitch` | Any UI or UX design work — screen review, pain-point validation, Stitch prompt creation |
| `ui5-fiori-bridge` | When screen.html from a Stitch export is available and a UI5 spec is needed |
| `qa-audit-controls` | Every pipeline — UAT scenarios, regression scope, audit evidence requirements |
| `docs-continuity` | Every pipeline — documentation alignment after any change |
| `rag-knowledge` | When knowledge/ base content changes, new sources are added, or a health check is needed |

The orchestrator names the specialist explicitly and states the required output. Users do not need to know which agent to call.

---

## Artifact Chain — Required Checkpoints

Each artifact is a gate. The orchestrator does not advance to the next stage if the required artifact from the previous stage is missing.

| Artifact | Gate — must exist before |
|----------|--------------------------|
| US + AC in requirements.md | Any domain validation or design work |
| IFRS 16 domain validation | Any functional design involving accounting rules |
| SAP object mapping | Any ABAP architecture proposal |
| screen.html export OR explicit no-HTML confirmation | Requesting UI5 spec from ui5-fiori-bridge |
| XML View proposal from ui5-fiori-bridge | Adding UI5-related tasks to tasks.md |
| ABAP architecture proposal | Adding Z development tasks to tasks.md |
| tasks.md updated | Activating docs-continuity |
| docs updated | Running QA gate |
| QA criteria recorded | Closing the iteration |
| risk-register + assumptions-register reviewed | Closing the iteration |

---

## Human Escalation Policy

The orchestrator operates autonomously and reads all available repo artifacts before asking the user for input. It stops and asks the human only when:

1. **Real functional ambiguity** — The request cannot be safely classified and no inference from existing specs, docs, or context is reliable.
2. **IFRS 16 accounting judgment** — Any decision under ai-governance.md human approval gates: lease classification, discount rate, modification type, exemption application.
3. **Conflict between viable alternatives** — Two or more technically sound approaches exist and the tradeoff requires a business or architectural decision.
4. **High-impact approval** — An ADR, ABAP Architect sign-off, or Controller approval is required.
5. **Critical information gap** — Required information cannot be derived from any artifact in the repository.

In all other situations, the orchestrator proceeds without prompting the user.

---

## Definition of Done per Iteration

An iteration is not closed until all applicable items are satisfied:

- Change classified and correct pipeline executed
- requirements.md updated with new or modified user stories and acceptance criteria
- design.md updated if design patterns changed
- tasks.md updated with new or closed task rows
- Domain/SAP validation completed (Pipelines A, B, D when functionally impacted)
- Design artifacts available and linked (Pipelines A, C, G when UI impacted)
- UI5 spec produced if screen.html is available (Pipelines A, C)
- docs/functional, docs/technical, docs/user updated as applicable
- risk-register.md and assumptions-register.md reviewed and updated
- QA criteria defined and recorded
- All [HUMAN VALIDATION REQUIRED] items have an assigned owner
- No [TO BE CONFIRMED] items without an owner and target date
- Governance check output produced (session-governance-check hook fires at session end)

---

## Relationship to Hooks

The following hooks operate alongside the orchestrator. They are automatic quality checks, not replacements for orchestrator governance.

| Hook | Trigger | Purpose |
|------|---------|---------|
| `spec-quality-gate` | spec file saved | Validates structure, acceptance criteria, and traceability in requirements.md and design.md |
| `controlled-closure-check` | task marked complete | Enforces 5-point closure gate: spec, docs, governance, QA, next action |
| `session-governance-check` | agent session ends | Scans session for governance register items and reusable knowledge to capture |
| `ux-traceability-check` | UX/docs file saved | Verifies UX traceability across functional/user docs, ux-stitch artifacts, PAIN_POINTS_TRACEABILITY.md |
| `spec-documentation-guard` | technical/governance/architecture doc saved | Checks cross-doc implications when technical, governance, or architecture docs change |
| `option-b-architecture-guard` | any spec/design/steering/agent file saved | Rejects or flags designs that reintroduce RE-FX as source of truth or processing engine |
| `capability-coverage-check` | spec file saved | Ensures every feature maps to at least one of the 9 capability domains (CD-01 to CD-09) |
| `contract-lifecycle-integrity-check` | contract-related spec or design saved | Ensures contract master, event history, valuation, and posting traceability remain coherent |
| `accounting-traceability-check` | posting/accounting spec or design saved | Ensures every accounting output is traceable to source event + valuation run + audit trail |
| `open-questions-register-check` | session end / spec save | Ensures all open questions are registered in docs/architecture/open-questions-register.md |

The orchestrator is responsible for the delivery pipeline. Hooks are responsible for automated quality signals within that pipeline. They are complementary.

---

## Stitch MCP Integration Status

- **Workflow A (manual):** Fully operational as of 2026-03-25. User exports screens via Stitch web UI and places artifacts in `design/stitch/exports/<screen-name>/`.
- **Workflow B (MCP via Kiro):** Infrastructure validated. Requires user to complete `gcloud auth application-default login` (ADC setup) before MCP generation is available. See `design/stitch/README.md` section 2.
- **Primary implementation source:** `screen.html` from each screen export folder. `ui5-fiori-bridge` works from `screen.html`.
- **Trust rule:** All Stitch MCP output is untreated until human-validated. See `.kiro/steering/ai-governance.md`.

---

## What the Orchestrator Is Not

- **Not a specialist.** It does not perform IFRS 16 analysis, ABAP design, or UX design itself. It coordinates the agents that do.
- **Not a passive coordinator.** It does not merely suggest which agent to use. It runs the pipeline, chains artifacts, and enforces gates.
- **Not a second orchestrator.** There is one master orchestrator. Do not create parallel orchestration paths.
- **Not a replacement for human judgment.** Accounting decisions, architectural sign-offs, and ADR approvals remain human responsibilities as defined in `.kiro/steering/ai-governance.md`.
