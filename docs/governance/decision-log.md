# Decision Log — RE-SAP IFRS 16 Addon

This log records all significant architectural, functional, and governance decisions made during the RE-SAP IFRS 16 addon project. Decisions are recorded in ADR (Architecture Decision Record) format.

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial decision log — first 5 ADRs proposed |
| 0.2 | 2026-03-26 | Project Governance Lead | Added ADR-006 (Option B — ACCEPTED); added Critical Path Dependencies section; updated index |

---

## Decision Index

| ADR | Date | Status | Title | Area |
|-----|------|--------|-------|------|
| ADR-006 | 2026-03-26 | **ACCEPTED** | Option B — Z addon fully replaces SAP RE-FX as system of record | Architecture |
| ADR-001 | 2026-03-24 | Proposed | ABAP OO mandate for all Z development | Technical Architecture |
| ADR-002 | 2026-03-24 | Proposed | Z object naming convention adoption | Development Standards |
| ADR-003 | 2026-03-24 | Proposed | Application logging via SAP SLG1 + Z audit table | Auditability |
| ADR-004 | 2026-03-24 | Proposed | Human approval gate mandatory before FI posting | Governance/Controls |
| ADR-005 | 2026-03-24 | Proposed | S/4HANA compatibility by design — no deprecated ABAP | Technical Architecture |

> **ADR-006 is ACCEPTED and immediately effective.** It overrides any prior design assumption about RE-FX as system of record.
> ADR-001 through ADR-005 are still **Proposed**. They require Project Governance Lead review. Create full ADR files in `knowledge/project-decisions/` when approved.

---

## ADR-001: ABAP OO Mandate for All Z Development

**Date:** 2026-03-24
**Status:** Proposed
**Owner:** ABAP Architect (pending)

### Context
The project requires a long-lived, maintainable, testable ABAP codebase. Procedural ABAP is harder to unit test, creates tight coupling, and is not aligned with SAP's strategic direction (ABAP Clean Code, S/4HANA development standards).

### Decision
All new Z ABAP development for the IFRS 16 addon will use ABAP Object-Oriented programming exclusively. No new procedural code in business logic layers. Exception: wrapper classes over legacy standard SAP function modules are acceptable where the FM cannot be replaced.

### Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| Procedural ABAP for quick delivery | Creates technical debt; untestable; not S/4 aligned |
| Mixed approach (OO for complex, procedural for simple) | Inconsistency increases maintenance burden; no clear boundary |

### Consequences
- Requires ABAP developers with ABAP OO competency.
- Enables unit testing via ABAP Unit.
- Aligns with S/4HANA ABAP Cloud restrictions.
- Slight learning curve for developers used to procedural ABAP.

---

## ADR-006: Option B — Z Addon Fully Replaces SAP RE-FX as System of Record

**Date:** 2026-03-26
**Status:** ACCEPTED — Effective immediately. Non-negotiable architectural constraint.
**Owner:** Project Governance Lead
**Supersedes:** All prior design assumptions about RE-FX as system of record

### Context
During architectural review on 2026-03-26, it was determined that:
1. End users have strong UX objections to SAP RE-FX screens — complexity, lack of usability, poor adoption.
2. The project owners require custom screens for both individual and mass lease contract creation.
3. RE-FX as a backend (Option A) still creates runtime dependencies on RE-FX data structures, condition types, and event model, creating fragility and limiting UX freedom.
4. Option B (Z addon as standalone system) eliminates all RE-FX runtime dependencies and enables full UX control, cleaner data model, and better S/4HANA compatibility.

### Decision
The RE-SAP IFRS 16 Addon will be built as a **standalone Z Lease Management System** under Option B:
- All contract master data stored exclusively in Z tables.
- All IFRS 16 valuation logic implemented in Z.
- All FI-GL documents posted directly via standard FI BAPIs from Z logic.
- All FI-AA ROU asset management executed via standard FI-AA BAPIs from Z logic.
- No dependency on RE-FX as a system of record, processing engine, or accounting engine at runtime.
- End users interact exclusively with Z workspace transactions — RE-FX user transactions are not used.

### Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| Option A (RE-FX as backend, Z screens as front-end) | Creates ongoing RE-FX table structure dependency; condition type configuration overhead; RE-FX event model constraints; S/4 migration risk from RE-FX table changes |
| Option C (Coexistence — new in Z, legacy in RE-FX) | Dual system complexity; reconciliation overhead; unclear system of record; ongoing RE-FX runtime dependency |

### Consequences
- RE-FX is not used at runtime after go-live (except one-time migration read-out if applicable).
- Z tables must cover all contract master data, payment schedules, and object master data.
- FI-GL and FI-AA integration must be validated via BAPIs directly.
- A one-time migration program may be needed if existing contracts exist in RE-FX.
- The `sap-re-ifrs16` agent is repurposed as `ecc-coverage-analyst` — its mission is now preserving business coverage, not mapping to RE-FX objects.
- New steering file `option-b-target-model.md` is the authoritative constraint document.
- See full Option B design in `docs/architecture/option-b-architecture.md`.

### Governance Impact
- Enforced by hook: `option-b-architecture-guard`
- Steered by: `.kiro/steering/option-b-target-model.md`
- Monitored by: `ecc-coverage-analyst` agent at every pipeline stage

---

## ADR-002: Z Object Naming Convention Adoption

**Date:** 2026-03-24
**Status:** Proposed
**Owner:** ABAP Architect (pending)

### Context
Consistent naming conventions prevent namespace collisions, support searchability, and communicate object purpose. The project needs a naming standard before any Z objects are created.

### Decision
Adopt the naming conventions defined in `.kiro/steering/structure.md` as the mandatory standard. All Z tables, classes, programs, and transactions follow the `ZRIF16_` prefix pattern. Full naming convention is in the steering document.

### Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| Client-provided naming convention | Not yet confirmed; use project standard until confirmed; update if client has conflicting requirements |
| Unstructured naming | Creates immediate maintenance and searchability problems |

### Consequences
- All Z objects are clearly identifiable as part of this project.
- Naming must be confirmed with the client's Basis team to ensure no namespace conflict.
- **Action required:** Confirm with client Basis team before creating first Z object.

---

## ADR-003: Application Logging via SAP SLG1 + Z Audit Table

**Date:** 2026-03-24
**Status:** Proposed
**Owner:** ABAP Architect (pending)

### Context
IFRS 16 is a compliance-driven process requiring long-term audit trail retention. SAP SLG1 provides structured application logging but has configurable retention limits. A supplementary Z audit table provides immutable long-term retention for compliance events.

### Decision
Use a two-tier logging approach:
1. **SAP SLG1** (log object ZRIF16) for operational logging — run summaries, warnings, errors. Standard retention applies.
2. **ZRIF16_AUDIT** (Z table) for compliance-critical events — scope decisions, approvals, calculation confirmations. Append-only. Long-term retention per data governance policy.

### Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| SLG1 only | Retention limits may not meet audit requirements; cannot guarantee immutability |
| Custom table only | Duplicates SLG1 monitoring capability; adds maintenance burden for operational monitoring |

### Consequences
- Dual maintenance burden is accepted because compliance and operational requirements differ.
- Retention policy for ZRIF16_AUDIT must be defined by Legal/DGO — currently TBC.
- Archiving strategy for ZRIF16_AUDIT is required.

---

## ADR-004: Human Approval Gate Mandatory Before FI Posting

**Date:** 2026-03-24
**Status:** Proposed
**Owner:** Project Governance Lead (pending)

### Context
IFRS 16 calculations directly affect financial statements. Automated posting without human review creates compliance and accuracy risk. The IFRS 16 Accountant and Finance Controller must review calculation results before any FI entry is created.

### Decision
No IFRS 16 FI posting may be executed without explicit human approval at two levels:
1. **Lease Accountant approval** of the calculation result (per contract or per run).
2. **Finance Controller approval** of the posting run (aggregate review).

The system enforces this at the authorization level — posting cannot be executed in the same user session as approval, and the posting function requires a separate authorization object.

### Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| Fully automated posting | Unacceptable compliance risk; contradicts AI governance policy |
| Single approver (Accountant only) | Insufficient SOD; Controller must have visibility before entries hit GL |
| Post and reverse if wrong | Creates audit complexity and reconciliation burden |

### Consequences
- Period-end process requires at least one additional business day for approval workflow.
- Approval workflow technology must be selected and configured (SAP WS vs. Z table — pending ADR).
- All users must understand their approval role before go-live.

---

## ADR-005: S/4HANA Compatibility by Design

**Date:** 2026-03-24
**Status:** Proposed
**Owner:** ABAP Architect (pending)

### Context
The client is on SAP ECC today. S/4HANA migration is a future consideration. If the IFRS 16 addon is built without migration awareness, it will create technical debt that makes the S/4 migration more expensive. Early alignment with S/4 design principles preserves the investment.

### Decision
All Z development follows S/4HANA compatibility rules:
- No deprecated ABAP statements.
- Explicit field lists in all SELECT statements (no SELECT *).
- All RE-FX data access wrapped behind interfaces (ZIF_RIF16_DATA_PROVIDER) for easy replacement.
- CDS views for all reporting layer.
- ALV OO for UI (with Fiori-readiness notes for every transaction).
- Every ECC-specific constraint flagged with `[ECC-SPECIFIC: Review for S/4 migration]`.

### Alternatives Considered
| Alternative | Why Rejected |
|-------------|-------------|
| Optimize for ECC only | Creates migration debt; reduces lifetime ROI of the addon |
| Build for S/4 now | Premature; client is not yet on S/4; adds unnecessary complexity |

### Consequences
- Slight development overhead for interface abstraction.
- Phase 3 S/4 compatibility assessment will be streamlined because of this design discipline.
- Migration path for every Z table must be documented.

---

## Critical Path Dependencies

> These dependencies are blocking constraints. No phase may proceed until the dependency is resolved. Each dependency is linked to the open questions and risks it unblocks.

| ID | Dependency | Blocks | Owner | Target Resolution | Status | Linked OQ | Linked Risk |
|----|-----------|--------|-------|------------------|--------|-----------|------------|
| D-PHASE-01 | IFRS 16 accounting policy formally signed off (T0-01 complete) | All Phase 1 functional design; ADR-004 approval; CD-03 / CD-04 design | IFRS 16 Accountant | T0-01 Workshop | OPEN | OQ-ACC-01, OQ-ACC-02, OQ-ACC-03, OQ-ACC-04, OQ-ACC-05 | R-04 |
| D-PHASE-02 | SAP technical landscape confirmed (T0-03 complete) — ABAP version, namespace, transport, SLG1 | All Z object creation; ADR-001, ADR-002, ADR-003 approval | ABAP Architect + SAP Basis | T0-03 Workshop | OPEN | OQ-ABAP-01, OQ-ABAP-06, OQ-ABAP-07 | R-03, R-23 |
| D-PHASE-03 | IBR / discount rate determination process established | CD-03 calculation engine testing; initial measurements for any contract | IFRS 16 Accountant + Treasury | T0-01 Workshop | OPEN | OQ-ACC-03 | R-02 |
| D-PHASE-04 | FI-GL and FI-AA BAPI coverage confirmed (T0-04 complete) | CD-04 and CD-05 ABAP development; ADR-003 approval | FI Architect + FI-AA Specialist + ABAP Architect | T0-04 Workshop | OPEN | OQ-FI-01, OQ-FI-02, OQ-FI-05 | R-23, R-24 |
| D-PHASE-05 | Data governance / legal review initiated for AI service integration | Phase 3 AI assistant (T3-01); Epic 7 delivery | Legal/DGO + Project Governance Lead | Phase 1 start | OPEN | TBC-ORK-06 | R-06, R-10 |

> **Rule:** No task in Phase 1 may be marked In Progress if its blocking dependency is still OPEN. The orchestrator enforces this at every pipeline stage.

---

## Release Notes

### Bootstrap Release — 2026-03-24
Project workspace initialized. The following artifacts were created:
- Complete Kiro workspace structure (agents, steering, skills)
- Master specifications (requirements, design, tasks)
- Knowledge base framework
- Living documentation baseline
- First 5 ADRs proposed (pending governance approval)
- Risk register and assumptions register populated

**Next action:** Project Governance Lead to review and approve ADR-001 through ADR-005. Complete Phase 0 tasks before development begins.
