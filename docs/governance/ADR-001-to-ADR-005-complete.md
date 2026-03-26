# Architecture Decision Records (ADR) — ADR-001 to ADR-005
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** PROPOSED — Ready for Project Governance Lead Review | **Owner:** Project Governance Lead

---

## Overview

This document contains the complete text of ADR-001 through ADR-005. These decisions are foundational to the RE-SAP IFRS 16 Addon project. They require formal approval from the Project Governance Lead before implementation begins.

**ADR-006 (Option B) is already ACCEPTED and is not included here — see `docs/governance/decision-log.md`.**

---

## ADR-001: ABAP OO Mandate for All Z Development

**Date:** 2026-03-24
**Status:** PROPOSED
**Owner:** ABAP Architect (pending approval)
**Governance Impact:** HIGH — affects all Z development practices

### Context

The RE-SAP IFRS 16 Addon requires a long-lived, maintainable, testable ABAP codebase. The project will be delivered over multiple phases and may require maintenance and enhancements for 5+ years. 

**Current State:**
- SAP ECC supports both procedural ABAP and ABAP Object-Oriented (OO) programming.
- Many legacy Z objects in the client's system use procedural ABAP.
- Some ABAP developers on the project team may have limited OO experience.

**Problem:**
- Procedural ABAP is harder to unit test, creates tight coupling, and is not aligned with SAP's strategic direction (ABAP Clean Code, S/4HANA development standards).
- Mixing procedural and OO code creates inconsistency and increases maintenance burden.
- Procedural code is more difficult to refactor and extend as requirements change.

### Decision

**All new Z ABAP development for the IFRS 16 addon will use ABAP Object-Oriented programming exclusively.**

**Scope:**
- All business logic classes (calculation engine, posting logic, data access) must be OO.
- All Z transactions and reports must use OO ALV (SALV) or OO dialog programming.
- Exception: Wrapper classes over legacy standard SAP function modules are acceptable where the FM cannot be replaced with a BAPI.

**Rationale:**
1. **Testability:** OO code is unit-testable via ABAP Unit; procedural code is not.
2. **S/4 Alignment:** S/4HANA ABAP Cloud restricts procedural ABAP; OO code is forward-compatible.
3. **Maintainability:** OO design patterns (factory, strategy, decorator) reduce coupling and improve code clarity.
4. **Team Consistency:** Single approach reduces cognitive load and code review complexity.

### Alternatives Considered

| Alternative | Rationale for Rejection |
|-------------|------------------------|
| Procedural ABAP for quick delivery | Creates technical debt; untestable; not S/4 aligned; contradicts long-term maintenance goals |
| Mixed approach (OO for complex, procedural for simple) | Inconsistency increases maintenance burden; no clear boundary; developers must decide on every module |
| Procedural ABAP with wrapper classes | Wrappers add complexity without solving testability or S/4 alignment issues |

### Consequences

**Positive:**
- All Z code is unit-testable; minimum 80% coverage target for calculation engine.
- Code is S/4HANA-compatible; migration to S/4 is simplified.
- Design patterns (factory, strategy) enable easy replacement of implementations (e.g., different IBR calculation strategies).
- Code reviews are consistent; all developers follow the same patterns.

**Negative:**
- Requires ABAP developers with OO competency; may require training.
- Slight learning curve for developers used to procedural ABAP.
- Initial development may be slightly slower than procedural approach (offset by reduced debugging and maintenance time).

### Implementation

1. **Training:** All ABAP developers on the project must complete ABAP OO training (internal or external) before Phase 1 development begins.
2. **Code Review:** All Z code is reviewed for OO compliance before merge to main branch.
3. **Testing:** All business logic classes must have ABAP Unit tests; minimum 80% coverage for calculation engine.
4. **Documentation:** All Z classes must have class-level documentation explaining purpose, dependencies, and usage.

### Governance

- **Enforced by:** Code review process; automated linting (if available).
- **Monitored by:** ABAP Architect; reported in phase-end quality metrics.
- **Escalation:** Any procedural code in business logic layers is flagged as a blocker and must be refactored before merge.

---

## ADR-002: Z Object Naming Convention Adoption

**Date:** 2026-03-24
**Status:** PROPOSED
**Owner:** ABAP Architect (pending approval)
**Governance Impact:** MEDIUM — affects all Z object creation

### Context

The project will create many Z objects: tables, classes, programs, transactions, and function modules. Consistent naming conventions prevent namespace collisions, support searchability, and communicate object purpose.

**Current State:**
- The client's SAP system has existing Z objects with varying naming conventions.
- The project needs a clear, consistent naming standard before any Z objects are created.
- The standard must comply with the client's SAP transport landscape and namespace policies.

### Decision

**Adopt the naming conventions defined in `.kiro/steering/structure.md` as the mandatory standard for all Z objects in the IFRS 16 addon.**

**Naming Convention Summary:**

| Object Type | Pattern | Example |
|------------|---------|---------|
| Development Package | `ZRIF16` (root) or `ZRIF16_[DOMAIN]` | `ZRIF16_CORE`, `ZRIF16_DATA`, `ZRIF16_UI` |
| Z Table | `ZRIF16_[DOMAIN]_[ENTITY]` | `ZRIF16_CONTRACT`, `ZRIF16_SCHED`, `ZRIF16_CALC` |
| Z Class | `ZCL_RIF16_[DOMAIN]_[PURPOSE]` | `ZCL_RIF16_CALC_ENGINE`, `ZCL_RIF16_POSTING` |
| Z Interface | `ZIF_RIF16_[DOMAIN]_[PURPOSE]` | `ZIF_RIF16_CALC_STRATEGY`, `ZIF_RIF16_DATA_PROVIDER` |
| Z Exception | `ZCX_RIF16_[ERROR_TYPE]` | `ZCX_RIF16_ERROR`, `ZCX_RIF16_CALC_ERROR` |
| Z Transaction | `ZRE_IFRS16_[FUNCTION]` | `ZRE_IFRS16_INTAKE`, `ZRE_IFRS16_CALC` |
| Z Program | `ZRIF16_[FUNCTION]_[TYPE]` | `ZRIF16_PERIOD_END_CALC`, `ZRIF16_POSTING_RUN` |

**Rationale:**
1. **Clarity:** Prefix `ZRIF16` immediately identifies objects as part of the IFRS 16 addon.
2. **Searchability:** Consistent naming enables easy search and discovery.
3. **Namespace Safety:** Reduces collision risk with other Z objects in the system.
4. **Maintainability:** Future developers can understand object purpose from the name.

### Alternatives Considered

| Alternative | Rationale for Rejection |
|-------------|------------------------|
| Client-provided naming convention | Not yet confirmed; use project standard until confirmed; update if client has conflicting requirements |
| Unstructured naming (e.g., ZIFRS16_ABC, ZIFRS16_XYZ) | Creates immediate maintenance and searchability problems |
| Abbreviated naming (e.g., ZRE_CALC, ZRE_POST) | Loses clarity; multiple objects could have the same abbreviation |

### Consequences

**Positive:**
- All Z objects are clearly identifiable as part of the IFRS 16 addon.
- Naming is consistent across all domains and object types.
- Future developers can understand object purpose from the name.
- Searchability is improved; developers can find related objects easily.

**Negative:**
- Naming convention must be confirmed with the client's Basis team to ensure no namespace conflict.
- Developers must follow the convention consistently; code review must enforce it.

### Implementation

1. **Confirmation:** ABAP Architect confirms naming convention with client's Basis team before creating first Z object.
2. **Documentation:** Naming convention is documented in the project's ABAP development guide.
3. **Code Review:** All Z objects are reviewed for naming compliance before merge.
4. **Transport:** All Z objects are assigned to the correct development package per the naming convention.

### Governance

- **Enforced by:** Code review process; transport management.
- **Monitored by:** ABAP Architect; reported in phase-end quality metrics.
- **Escalation:** Any Z object with non-compliant naming is flagged as a blocker and must be renamed before merge.

---

## ADR-003: Application Logging via SAP SLG1 + Z Audit Table

**Date:** 2026-03-24
**Status:** PROPOSED
**Owner:** ABAP Architect (pending approval)
**Governance Impact:** HIGH — affects auditability and compliance

### Context

IFRS 16 is a compliance-driven process requiring long-term audit trail retention. Every significant action (scope decision, calculation approval, posting) must be logged and retrievable for audit purposes.

**Current State:**
- SAP provides SLG1 (Application Log) framework for operational logging.
- SLG1 has configurable retention limits (typically 30–90 days).
- The client's data governance policy requires 7-year retention for financial records.
- Manual spreadsheet processes have no audit trail.

**Problem:**
- SLG1 retention limits may not meet audit requirements.
- SLG1 is designed for operational monitoring, not compliance evidence.
- A single logging mechanism may not satisfy both operational and compliance needs.

### Decision

**Use a two-tier logging approach:**

1. **SAP SLG1 (Operational Logging)**
   - Log object: `ZRIF16`
   - Purpose: Operational monitoring, error tracking, performance analysis.
   - Retention: Standard SAP retention (configurable, typically 30–90 days).
   - Scope: All calculation runs, batch jobs, errors, warnings.

2. **ZRIF16_AUDIT (Z Audit Table — Compliance Logging)**
   - Purpose: Compliance-critical events requiring long-term retention.
   - Retention: 7 years (per data governance policy — to be confirmed).
   - Scope: Scope decisions, approvals, calculation confirmations, posting approvals, disclosure sign-offs.
   - Design: Append-only; no updates or deletes; immutable audit trail.

### Rationale

1. **Dual Purpose:** Operational logging (SLG1) and compliance logging (Z table) serve different needs.
2. **Retention:** Z table provides long-term retention for audit evidence.
3. **Immutability:** Append-only design ensures audit trail cannot be altered.
4. **Compliance:** Separate compliance table demonstrates commitment to audit trail integrity.

### Alternatives Considered

| Alternative | Rationale for Rejection |
|-------------|------------------------|
| SLG1 only | Retention limits may not meet audit requirements; cannot guarantee immutability |
| Custom table only | Duplicates SLG1 monitoring capability; adds maintenance burden for operational monitoring |
| Database-level audit trail | Expensive; requires database administrator involvement; not SAP-native |

### Consequences

**Positive:**
- Operational logging is available for real-time monitoring and debugging.
- Compliance logging is immutable and long-term retained.
- Audit trail is complete and traceable.
- Meets data governance requirements for financial record retention.

**Negative:**
- Dual maintenance burden is accepted because compliance and operational requirements differ.
- Retention policy for ZRIF16_AUDIT must be defined by Legal/DGO — currently TBC.
- Archiving strategy for ZRIF16_AUDIT is required (Phase 2 or Phase 3).

### Implementation

1. **SLG1 Configuration:** Log object `ZRIF16` is configured in the target system.
2. **Z Table Design:** ZRIF16_AUDIT table is designed with append-only semantics.
3. **Logging Code:** All business logic classes call logging methods for both SLG1 and ZRIF16_AUDIT.
4. **Retention Policy:** Legal/DGO defines retention policy for ZRIF16_AUDIT (Phase 0 gate).
5. **Archiving:** Archiving strategy for ZRIF16_AUDIT is designed in Phase 2.

### Governance

- **Enforced by:** Code review; logging framework design.
- **Monitored by:** ABAP Architect; reported in phase-end quality metrics.
- **Escalation:** Any compliance-critical event not logged to ZRIF16_AUDIT is flagged as a blocker.

---

## ADR-004: Human Approval Gate Mandatory Before FI Posting

**Date:** 2026-03-24
**Status:** PROPOSED
**Owner:** Project Governance Lead (pending approval)
**Governance Impact:** CRITICAL — affects financial controls and segregation of duties

### Context

IFRS 16 calculations directly affect financial statements. Automated posting without human review creates compliance and accuracy risk. The IFRS 16 Accountant and Finance Controller must review calculation results before any FI entry is created.

**Current State:**
- Current manual process: Accountant calculates → Controller reviews → Manual FI posting.
- Risk: Manual posting is error-prone and lacks audit trail.
- Requirement: Automated posting must maintain the same control structure.

**Problem:**
- Fully automated posting without human review is unacceptable from a compliance perspective.
- Single approver (Accountant only) is insufficient segregation of duties.
- Post-and-reverse approach creates audit complexity.

### Decision

**No IFRS 16 FI posting may be executed without explicit human approval at two levels:**

1. **Lease Accountant Approval (Calculation Review)**
   - Reviews the calculation result per contract or per run.
   - Confirms that inputs are correct and calculation is accurate.
   - Approves or rejects the calculation.
   - Status: Calculation → APPROVED or REJECTED.

2. **Finance Controller Approval (Posting Review)**
   - Reviews the pre-posting summary (entries by account, contract, and amount).
   - Confirms that posting is appropriate and complete.
   - Approves or rejects the posting run.
   - Status: Posting Run → READY_FOR_POSTING or REJECTED.

**System Enforcement:**
- Posting cannot be executed in the same user session as approval (segregation of duties).
- Posting function requires a separate authorization object (e.g., `ZRE_IFRS16_POST`).
- Approval records are logged to ZRIF16_AUDIT with timestamp and user ID.

### Rationale

1. **Compliance:** Two-level approval maintains segregation of duties and demonstrates control.
2. **Accuracy:** Accountant review catches calculation errors; Controller review catches posting errors.
3. **Auditability:** Approval records provide evidence of review and authorization.
4. **Risk Mitigation:** Reduces risk of posting errors or unauthorized entries.

### Alternatives Considered

| Alternative | Rationale for Rejection |
|-------------|------------------------|
| Fully automated posting | Unacceptable compliance risk; contradicts AI governance policy |
| Single approver (Accountant only) | Insufficient segregation of duties; Controller must have visibility |
| Post and reverse if wrong | Creates audit complexity and reconciliation burden; not acceptable |
| Approval by IT/Basis team | Inappropriate; financial approval must be by Finance personnel |

### Consequences

**Positive:**
- Segregation of duties is maintained; compliance risk is reduced.
- Approval records provide audit evidence.
- Accountant and Controller have visibility and control.

**Negative:**
- Period-end process requires at least one additional business day for approval workflow.
- Approval workflow technology must be selected and configured (SAP WS vs. Z table — pending ADR).
- All users must understand their approval role before go-live.
- Approval bottleneck if approvers are unavailable.

### Implementation

1. **Workflow Technology:** Select and configure approval workflow (SAP WS or Z table — pending ADR).
2. **Authorization Objects:** Create Z authorization objects for calculation approval and posting approval.
3. **Approval UI:** Design approval screens for Accountant and Controller.
4. **Logging:** All approvals are logged to ZRIF16_AUDIT.
5. **Training:** All users are trained on their approval role and responsibilities.

### Governance

- **Enforced by:** Authorization objects; workflow engine.
- **Monitored by:** Project Governance Lead; reported in phase-end quality metrics.
- **Escalation:** Any posting without proper approval is flagged as a critical control failure.

---

## ADR-005: S/4HANA Compatibility by Design

**Date:** 2026-03-24
**Status:** PROPOSED
**Owner:** ABAP Architect (pending approval)
**Governance Impact:** MEDIUM — affects long-term maintainability

### Context

The client is on SAP ECC today. S/4HANA migration is a future consideration (timeline TBC). If the IFRS 16 addon is built without migration awareness, it will create technical debt that makes the S/4 migration more expensive and risky.

**Current State:**
- Client is on SAP ECC 6.0.
- S/4HANA migration is planned but not yet scheduled.
- Many Z objects in the system are ECC-specific and will require rework for S/4.

**Problem:**
- ECC-specific code (deprecated ABAP, SELECT *, tight coupling to ECC tables) creates migration debt.
- Rework during S/4 migration is expensive and risky.
- Early alignment with S/4 design principles preserves the investment.

### Decision

**All Z development follows S/4HANA compatibility rules:**

1. **ABAP Language:**
   - No deprecated ABAP statements (no `MOVE`, `COMPUTE`, `PERFORM`, etc.).
   - Explicit field lists in all SELECT statements (no `SELECT *`).
   - Use modern ABAP syntax (inline declarations, method chaining, etc.).

2. **Data Access:**
   - All RE-FX data access wrapped behind interfaces (e.g., `ZIF_RIF16_DATA_PROVIDER`).
   - Enables easy replacement of data source during S/4 migration.
   - No direct SELECT from RE-FX tables in business logic.

3. **Reporting:**
   - CDS views for all reporting layer (not ALV-only).
   - Fiori-readiness notes for every transaction (even if ALV is used in ECC).

4. **Documentation:**
   - Every ECC-specific constraint flagged with `[ECC-SPECIFIC: Review for S/4 migration]`.
   - Migration path for every Z table documented.

### Rationale

1. **Future-Proofing:** S/4 migration is inevitable; early alignment reduces rework.
2. **Code Quality:** Modern ABAP is cleaner, more testable, and more maintainable.
3. **Reduced Risk:** Fewer surprises during S/4 migration; smoother transition.
4. **Investment Protection:** Addon remains valuable after S/4 migration.

### Alternatives Considered

| Alternative | Rationale for Rejection |
|-------------|------------------------|
| Optimize for ECC only | Creates migration debt; reduces lifetime ROI of the addon |
| Build for S/4 now | Premature; client is not yet on S/4; adds unnecessary complexity |
| Ignore S/4 compatibility | Shortsighted; migration is inevitable; creates expensive rework |

### Consequences

**Positive:**
- Code is S/4HANA-compatible; migration is simplified.
- Code quality is higher; more testable and maintainable.
- Addon remains valuable after S/4 migration.
- Reduced risk during S/4 migration.

**Negative:**
- Slight development overhead for interface abstraction.
- Developers must follow S/4 compatibility rules consistently.
- Code review must enforce S/4 compatibility.

### Implementation

1. **ABAP Guidelines:** Project ABAP development guide includes S/4 compatibility rules.
2. **Code Review:** All Z code is reviewed for S/4 compatibility before merge.
3. **Testing:** All code is tested on ECC; S/4 compatibility is verified in Phase 3 (if applicable).
4. **Documentation:** All ECC-specific constraints are flagged and documented.
5. **Migration Planning:** Phase 3 includes S/4 compatibility assessment and migration planning.

### Governance

- **Enforced by:** Code review process; automated linting (if available).
- **Monitored by:** ABAP Architect; reported in phase-end quality metrics.
- **Escalation:** Any deprecated ABAP or ECC-specific code is flagged as a blocker and must be refactored.

---

## Approval and Sign-Off

These ADRs are approved by:

| ADR | Role | Name | Signature | Date |
|-----|------|------|-----------|------|
| ADR-001 | ABAP Architect | _________________ | _________________ | _______ |
| ADR-002 | ABAP Architect | _________________ | _________________ | _______ |
| ADR-003 | ABAP Architect | _________________ | _________________ | _______ |
| ADR-004 | Project Governance Lead | _________________ | _________________ | _______ |
| ADR-005 | ABAP Architect | _________________ | _________________ | _______ |

---

**Document Status:** PROPOSED — Ready for Project Governance Lead Review
**Next Action:** Project Governance Lead to review and approve all ADRs.
**Target Approval:** Before Phase 1 development begins (2026-04-XX)

