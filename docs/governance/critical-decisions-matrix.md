# Critical Decisions Matrix — ADR-001 to ADR-006 + Accounting Policy
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** DRAFT — Ready for Workshop Review | **Owner:** Project Governance Lead

---

## Purpose

This matrix consolidates all critical architectural, technical, and accounting policy decisions for the RE-SAP IFRS 16 Addon project. It provides a single view of:
1. All ADRs (ADR-001 to ADR-006)
2. All accounting policy decisions (OQ-ACC-01 to OQ-ACC-05)
3. Impact on addon design
4. Blockers if not decided
5. Approval status

**Workshop Objective:** Obtain formal approval for all decisions before Phase 1 development begins.

---

## Decision Matrix

| # | Decision | Type | ADR/OQ | Current Status | Impact on Design | Blocker if Not Decided | Approval Required | Target Approval Date |
|---|----------|------|--------|----------------|------------------|----------------------|-------------------|----------------------|
| **D-001** | ABAP OO mandate for all Z development | Technical | ADR-001 | PROPOSED | All Z classes must be OO; enables unit testing; S/4 compatible | Cannot start ABAP development | ABAP Architect | T0-03 Workshop |
| **D-002** | Z object naming convention (ZRIF16_*) | Technical | ADR-002 | PROPOSED | All Z objects follow naming standard; improves searchability | Cannot create Z objects | ABAP Architect | T0-03 Workshop |
| **D-003** | Application logging (SLG1 + ZRIF16_AUDIT) | Technical | ADR-003 | PROPOSED | Dual logging framework; compliance audit trail; 7-year retention | Cannot implement logging | ABAP Architect | T0-03 Workshop |
| **D-004** | Human approval gate before FI posting | Governance | ADR-004 | PROPOSED | Two-level approval (Accountant + Controller); segregation of duties | Cannot post FI documents | Project Governance Lead | T0-02 Workshop |
| **D-005** | S/4HANA compatibility by design | Technical | ADR-005 | PROPOSED | Modern ABAP; CDS views; interface abstraction; ECC-specific flags | Cannot ensure S/4 readiness | ABAP Architect | T0-03 Workshop |
| **D-006** | Option B: Z addon replaces RE-FX as system of record | Architecture | ADR-006 | **ACCEPTED** | All contract data in Z tables; no RE-FX runtime dependency; direct FI/FI-AA BAPIs | Cannot proceed with design | Project Governance Lead | 2026-03-26 ✓ |
| **D-007** | Lease identification criteria (all three required) | Accounting | OQ-ACC-01 | OPEN | Scope determination logic; contract marked IN_SCOPE or OUT_OF_SCOPE | Cannot determine scope | IFRS 16 Accountant | T0-01 Workshop |
| **D-008** | Short-term exemption election (≤12 months) | Accounting | OQ-ACC-01 | OPEN | If elected: contracts ≤12 months marked EXEMPT; no calculation run | Cannot determine exemption | IFRS 16 Accountant | T0-01 Workshop |
| **D-009** | Low-value exemption election + threshold | Accounting | OQ-ACC-01 | OPEN | If elected: contracts with asset value ≤ threshold marked EXEMPT | Cannot determine exemption | IFRS 16 Accountant | T0-01 Workshop |
| **D-010** | Lease term: renewal option "reasonably certain" threshold | Accounting | OQ-ACC-04 | OPEN | Renewal periods included in lease term if probability ≥ threshold | Wrong lease term → wrong liability | IFRS 16 Accountant | T0-01 Workshop |
| **D-011** | Lease term: termination option "reasonably certain" threshold | Accounting | OQ-ACC-04 | OPEN | Lease term shortened if termination is reasonably certain | Wrong lease term → wrong liability | IFRS 16 Accountant | T0-01 Workshop |
| **D-012** | Discount rate: IBR determination method | Accounting | OQ-ACC-03 | OPEN | IBR lookup table (ZRIF16_PARAM) populated per method; system applies rate | Cannot calculate liability without IBR | IFRS 16 Accountant + Treasury | T0-01 Workshop |
| **D-013** | Discount rate: IBR update frequency | Accounting | OQ-ACC-03 | OPEN | If updated: remeasurement triggered; new calc run | Wrong rate → wrong liability | IFRS 16 Accountant | T0-01 Workshop |
| **D-014** | Lease payments: index-based variable payments | Accounting | OQ-ACC-01 | OPEN | Variable payment flag on contract; included in liability at commencement rate | Wrong payment classification → wrong liability | IFRS 16 Accountant | T0-01 Workshop |
| **D-015** | Lease payments: non-index variable payments | Accounting | OQ-ACC-01 | OPEN | Non-index variable payment flag; excluded from liability calculation | Wrong payment classification → wrong liability | IFRS 16 Accountant | T0-01 Workshop |
| **D-016** | Initial direct costs (IDC) tracking | Accounting | OQ-ACC-05 | OPEN | If included: IDC field on contract; added to ROU asset at commencement | Incomplete ROU asset if IDC not tracked | IFRS 16 Accountant | T0-01 Workshop |
| **D-017** | Linearization of stepped rents | Accounting | OQ-ACC-02 | OPEN | If linearized: system calculates average payment; used in liability calculation | Wrong liability if linearization required but not applied | IFRS 16 Accountant | T0-01 Workshop |
| **D-018** | Lease modifications: separate lease criteria | Accounting | OQ-ACC-01 | OPEN | Modification event type = SEPARATE_LEASE or ADJUSTMENT; new calc run if separate | Wrong accounting treatment if criteria misapplied | IFRS 16 Accountant | T0-01 Workshop |
| **D-019** | Remeasurement triggers: option exercise | Accounting | OQ-ACC-01 | OPEN | Lease term updated; new calc run | Wrong liability if option exercise not remeasured | IFRS 16 Accountant | T0-01 Workshop |
| **D-020** | Remeasurement triggers: index adjustment | Accounting | OQ-ACC-01 | OPEN | Payment schedule updated; new calc run | Wrong liability if index change not remeasured | IFRS 16 Accountant | T0-01 Workshop |
| **D-021** | Remeasurement triggers: IBR change | Accounting | OQ-ACC-03 | OPEN | If triggered: new calc run with updated IBR | Wrong liability if IBR change not remeasured | IFRS 16 Accountant | T0-01 Workshop |
| **D-022** | Country-specific rules (Poland advance payments) | Accounting | OQ-ACC-01 | OPEN | Advance payment flag on contract; ROU reduced by advance amount | Wrong ROU asset if advance payment not handled | IFRS 16 Accountant | T0-01 Workshop |
| **D-023** | Parallel ledger for local GAAP | Accounting | OQ-FI-01 | OPEN | Z posting engine: support multi-ledger (if configured) | Local GAAP non-compliant if not supported | FI Architect | T0-04 Workshop |
| **D-024** | FI-GL posting approach (main ledger vs. parallel) | Technical | OQ-FI-01 | OPEN | Posting logic designed per approach; FI document structure | Cannot design posting engine | FI Architect | T0-04 Workshop |
| **D-025** | FI-AA ROU asset creation method | Technical | OQ-FI-05 | OPEN | Z: direct FI-AA BAPI call; ROU asset number mapping | Cannot create ROU assets | FI-AA Specialist | T0-04 Workshop |
| **D-026** | Approval workflow technology (SAP WS vs. Z table) | Technical | ADR-004 | OPEN | Workflow engine selected; approval screens designed | Cannot implement approval gate | ABAP Architect | T0-03 Workshop |
| **D-027** | Z namespace confirmation (ZRIF16_*) | Technical | ADR-002 | OPEN | Namespace confirmed with Basis team; no collision risk | Cannot create Z objects | ABAP Architect + Basis | T0-03 Workshop |
| **D-028** | ABAP version and feature availability | Technical | ADR-005 | OPEN | ABAP 7.4+ confirmed; CDS views available; OO features available | Cannot design ABAP architecture | ABAP Architect | T0-03 Workshop |

---

## Decision Status Summary

| Status | Count | Details |
|--------|-------|---------|
| **ACCEPTED** | 1 | ADR-006 (Option B) — approved 2026-03-26 |
| **PROPOSED** | 5 | ADR-001 to ADR-005 — pending Project Governance Lead review |
| **OPEN** | 22 | Accounting policy + technical decisions — pending workshop resolution |
| **TOTAL** | **28** | |

---

## Critical Path Dependencies

### Phase 0 Gate (Before Phase 1 Design Begins)

**Must be decided before Phase 1 design:**
- D-006: Option B ✓ ACCEPTED
- D-001: ABAP OO mandate
- D-002: Z naming convention
- D-003: Application logging
- D-004: Approval gate
- D-005: S/4 compatibility
- D-007 to D-022: All accounting policy decisions
- D-024: FI-GL posting approach
- D-025: FI-AA ROU asset creation
- D-026: Approval workflow technology
- D-027: Z namespace confirmation
- D-028: ABAP version confirmation

**Blockers if not decided:**
- Cannot start ABAP development without D-001, D-002, D-027, D-028.
- Cannot design valuation engine without D-007 to D-022.
- Cannot design posting engine without D-024, D-025.
- Cannot design approval workflow without D-004, D-026.

### T0-01 Workshop (Accounting Policy)

**Decisions to be finalized:**
- D-007 to D-022: All accounting policy decisions (OQ-ACC-01 to OQ-ACC-05)
- D-023: Parallel ledger approach (if applicable)

**Deliverables:**
- Completed accounting policy document (signed by IFRS 16 Accountant + Finance Controller)
- Accounting policy decision matrix (all cells completed)

### T0-02 Workshop (Blueprint & Coverage)

**Decisions to be finalized:**
- D-004: Approval gate (confirm two-level approach)
- Coverage gap decisions (GAP-A-01 to GAP-C-03)
- Migration strategy (if applicable)

**Deliverables:**
- Option B blueprint (signed by SAP RE Functional Consultant + ABAP Architect)
- Coverage gaps matrix (all gaps assessed and decisions made)

### T0-03 Workshop (ABAP Architecture)

**Decisions to be finalized:**
- D-001: ABAP OO mandate (confirm training plan)
- D-002: Z naming convention (confirm with Basis team)
- D-003: Application logging (confirm SLG1 + ZRIF16_AUDIT design)
- D-005: S/4 compatibility (confirm ABAP guidelines)
- D-026: Approval workflow technology (select SAP WS or Z table)
- D-027: Z namespace confirmation
- D-028: ABAP version confirmation

**Deliverables:**
- ABAP architecture design (signed by ABAP Architect)
- ABAP development guidelines (including OO, naming, logging, S/4 compatibility)

### T0-04 Workshop (FI Integration)

**Decisions to be finalized:**
- D-024: FI-GL posting approach
- D-025: FI-AA ROU asset creation
- D-023: Parallel ledger (if applicable)

**Deliverables:**
- FI integration design (signed by FI Architect + FI-AA Specialist)

---

## Approval Workflow

### Step 1: ADR Review (T0-03 Workshop)

| ADR | Owner | Status | Approval Date |
|-----|-------|--------|----------------|
| ADR-001 | ABAP Architect | PROPOSED | [T0-03] |
| ADR-002 | ABAP Architect | PROPOSED | [T0-03] |
| ADR-003 | ABAP Architect | PROPOSED | [T0-03] |
| ADR-004 | Project Governance Lead | PROPOSED | [T0-02] |
| ADR-005 | ABAP Architect | PROPOSED | [T0-03] |
| ADR-006 | Project Governance Lead | **ACCEPTED** | 2026-03-26 ✓ |

### Step 2: Accounting Policy Review (T0-01 Workshop)

| Decision | Owner | Status | Approval Date |
|----------|-------|--------|----------------|
| D-007 to D-022 | IFRS 16 Accountant | OPEN | [T0-01] |
| D-023 | FI Architect | OPEN | [T0-04] |

### Step 3: Technical Design Review (T0-03 Workshop)

| Decision | Owner | Status | Approval Date |
|----------|-------|--------|----------------|
| D-024, D-025 | FI Architect + FI-AA Specialist | OPEN | [T0-04] |
| D-026, D-027, D-028 | ABAP Architect | OPEN | [T0-03] |

---

## Risk Assessment

| Decision | Risk if Not Decided | Mitigation |
|----------|-------------------|-----------|
| D-001 (ABAP OO) | Code quality issues; untestable code; S/4 migration risk | Enforce in code review; training required |
| D-002 (Naming) | Namespace collisions; searchability issues | Confirm with Basis team early |
| D-003 (Logging) | Audit trail gaps; compliance risk | Dual logging framework; 7-year retention |
| D-004 (Approval) | Segregation of duties failure; posting errors | Two-level approval; authorization objects |
| D-005 (S/4) | Migration debt; expensive rework | Modern ABAP; interface abstraction; ECC-specific flags |
| D-006 (Option B) | RE-FX runtime dependency; fragile design | ✓ ACCEPTED — enforced by option-b-architecture-guard hook |
| D-007 to D-022 (Accounting) | Wrong calculations; audit findings; compliance risk | IFRS 16 Accountant sign-off required |
| D-024, D-025 (FI) | Posting errors; FI-AA integration failures | FI Architect + FI-AA Specialist sign-off required |
| D-026 (Workflow) | Approval bottleneck; user confusion | Select technology early; design approval UI |
| D-027, D-028 (Technical) | Z object creation blocked; ABAP feature unavailable | Confirm with Basis team early |

---

## Approval Sign-Off

This critical decisions matrix is approved by:

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Governance Lead | _________________ | _________________ | _______ |
| IFRS 16 Accountant | _________________ | _________________ | _______ |
| ABAP Architect | _________________ | _________________ | _______ |
| FI Architect | _________________ | _________________ | _______ |

---

**Document Status:** DRAFT — Ready for Workshop Review
**Next Action:** Obtain approvals for all decisions through T0-01, T0-02, T0-03, T0-04 workshops.
**Target Completion:** All decisions approved before Phase 1 development begins (2026-04-XX)

