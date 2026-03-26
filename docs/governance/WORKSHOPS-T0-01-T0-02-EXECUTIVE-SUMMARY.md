# Executive Summary: T0-01 & T0-02 Workshop Deliverables
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** DRAFT — Ready for Workshop Execution | **Owner:** Project Governance Lead

---

## Overview

This document summarizes the complete set of deliverables prepared for the T0-01 (Accounting Policy) and T0-02 (Blueprint & Coverage) workshops. All documents are ready for presentation and completion in the workshops.

**Total Deliverables:** 6 documents + 1 summary (this document)
**Target Workshops:** T0-01 (2026-04-XX), T0-02 (2026-04-XX)
**Approval Required:** IFRS 16 Accountant, Finance Controller, SAP RE Functional Consultant, ABAP Architect, Project Governance Lead

---

## Deliverable 1: IFRS 16 Accounting Policy Document (T0-01)

**File:** `docs/governance/T0-01-accounting-policy-template.md`
**Purpose:** Template for the client's formal IFRS 16 accounting policy
**Status:** DRAFT — Ready for T0-01 completion
**Owner:** IFRS 16 Accountant

### Contents
- Lease identification and scope determination
- Short-term and low-value exemptions
- Lease term determination (renewal/termination options)
- Discount rate selection (implicit rate vs. IBR)
- Initial direct costs (IDC) tracking
- Lease payment components (fixed, variable, index-based)
- Linearization of stepped rents
- Lease modifications and remeasurement
- Derecognition and early termination
- Country-specific rules (Poland advance payments)
- Disclosure requirements

### Open Questions to Resolve in T0-01
- **OQ-ACC-01:** Is the IFRS 16 accounting policy formally signed off by the client?
- **OQ-ACC-02:** Is linearization of stepped rents required (or optional)?
- **OQ-ACC-03:** How is the Incremental Borrowing Rate (IBR) determined per company code / currency?
- **OQ-ACC-04:** Is the REASONABLY CERTAIN threshold for renewal options defined?
- **OQ-ACC-05:** Are initial direct costs (IDC) tracked and to be included in ROU calculation?

### Approval Required
- IFRS 16 Accountant (signature)
- Finance Controller (signature)

---

## Deliverable 2: Accounting Policy Decision Matrix (T0-01)

**File:** `docs/governance/T0-01-accounting-policy-decision-matrix.md`
**Purpose:** Matrix mapping every IFRS 16 accounting policy decision to IFRS 16 paragraphs, options, and design impact
**Status:** DRAFT — Ready for T0-01 completion
**Owner:** IFRS 16 Accountant

### Contents
- 27 accounting policy decisions (B-01 to B-27)
- IFRS 16 paragraph references for each decision
- Options considered for each decision
- Proposed decision (to be completed in T0-01)
- Impact on CD-03 (Valuation Engine) and CD-04 (Accounting Engine)
- Blocker if decision is not made

### Key Decisions to Finalize
- Lease identification criteria
- Short-term exemption election
- Low-value exemption election + threshold
- Lease term assessment (renewal/termination options)
- Discount rate determination (implicit vs. IBR)
- IBR determination method and update frequency
- Lease payment classification (fixed, variable, index-based)
- Initial direct costs tracking
- Linearization of stepped rents
- Modification classification
- Remeasurement triggers
- Derecognition treatment
- Country-specific rules

### Approval Required
- IFRS 16 Accountant (signature)
- Finance Controller (signature)

---

## Deliverable 3: Option B Blueprint (T0-02)

**File:** `docs/architecture/T0-02-option-b-blueprint.md`
**Purpose:** Complete Option B architecture and functional coverage analysis
**Status:** DRAFT — Ready for T0-02 completion
**Owner:** SAP RE Functional Consultant + ABAP Architect

### Contents
- Why Option B? (Option A vs. Option B comparison)
- Option B architecture overview (logical diagram)
- The 9 capability domains (CD-01 to CD-09)
- Functional coverage analysis by domain
- Coverage summary (88% Phase 1, 12% Phase 2)
- Open coverage questions (OQ-COV-01 to OQ-COV-08)
- Migration strategy (if applicable)
- Architectural constraints (Option B governance rules)

### Key Sections
1. **Section 1:** Why Option B? — Business case for Z addon as system of record
2. **Section 2:** Architecture Overview — Logical diagram and 9 capability domains
3. **Section 3:** Functional Coverage Analysis — Detailed mapping of current ECC capabilities to Option B
4. **Section 4:** Open Coverage Questions — 8 questions to be resolved in T0-02
5. **Section 5:** Migration Strategy — If existing RE-FX contracts need migration
6. **Section 6:** Architectural Constraints — Non-negotiable Option B rules

### Open Questions to Resolve in T0-02
- **OQ-COV-01:** Are there RE-FX contract types that don't fit CD-01/CD-02 classification?
- **OQ-COV-02:** Is linearization required by accounting policy?
- **OQ-COV-03:** Is FI-AP matching in scope for Phase 1 or Phase 2?
- **OQ-COV-04:** Are initial direct costs tracked in current ECC solution?
- **OQ-COV-05:** Is Poland advance payment the only country-specific rule?
- **OQ-COV-06:** Is parallel ledger for local GAAP currently active?
- **OQ-COV-07:** Is procurement/PO-to-contract pattern in scope?
- **OQ-COV-08:** Are there vehicle fleet leases with specific attributes?

### Approval Required
- SAP RE Functional Consultant (signature)
- ABAP Architect (signature)
- Project Governance Lead (signature)

---

## Deliverable 4: Coverage Gaps Analysis Matrix (T0-02)

**File:** `docs/architecture/T0-02-coverage-gaps-matrix.md`
**Purpose:** Identify functional gaps between current ECC and Option B Phase 1
**Status:** DRAFT — Ready for T0-02 completion
**Owner:** ECC Coverage Analyst

### Contents
- Gap Category A: Capabilities deferred to Phase 2 (3 gaps)
- Gap Category B: New capabilities in Phase 1 (6 capabilities)
- Gap Category C: Capabilities with reduced scope (3 capabilities)
- Gap Category D: Capabilities with enhanced scope (4 capabilities)
- Risk assessment for deferred capabilities
- Decisions required in T0-02
- Coverage summary after gap resolution

### Key Gaps to Resolve
- **GAP-A-01:** Vendor invoice matching (FI-AP integration) — defer to Phase 2?
- **GAP-A-02:** Disclosure pack export (Excel/PDF) — defer to Phase 2?
- **GAP-A-03:** Procurement/PO-to-contract pattern — defer to Phase 2?
- **GAP-A-04:** Impairment of ROU assets — defer to Phase 3?
- **GAP-C-01:** Parallel ledger for local GAAP — conditional on configuration
- **GAP-C-02:** Country-specific rules (Poland) — conditional on policy
- **GAP-C-03:** Linearization of stepped rents — conditional on policy

### Approval Required
- ECC Coverage Analyst (signature)
- Project Governance Lead (signature)

---

## Deliverable 5: Complete ADRs (ADR-001 to ADR-005)

**File:** `docs/governance/ADR-001-to-ADR-005-complete.md`
**Purpose:** Complete Architecture Decision Records for foundational project decisions
**Status:** PROPOSED — Ready for Project Governance Lead review
**Owner:** Project Governance Lead

### ADRs Included

| ADR | Title | Status | Owner | Target Approval |
|-----|-------|--------|-------|-----------------|
| ADR-001 | ABAP OO Mandate for All Z Development | PROPOSED | ABAP Architect | T0-03 |
| ADR-002 | Z Object Naming Convention Adoption | PROPOSED | ABAP Architect | T0-03 |
| ADR-003 | Application Logging via SAP SLG1 + Z Audit Table | PROPOSED | ABAP Architect | T0-03 |
| ADR-004 | Human Approval Gate Mandatory Before FI Posting | PROPOSED | Project Governance Lead | T0-02 |
| ADR-005 | S/4HANA Compatibility by Design | PROPOSED | ABAP Architect | T0-03 |
| ADR-006 | Option B — Z Addon Replaces RE-FX as System of Record | **ACCEPTED** | Project Governance Lead | 2026-03-26 ✓ |

### Key Decisions
1. **ADR-001:** All Z code must be ABAP OO (not procedural)
2. **ADR-002:** All Z objects follow ZRIF16_* naming convention
3. **ADR-003:** Dual logging: SLG1 (operational) + ZRIF16_AUDIT (compliance, 7-year retention)
4. **ADR-004:** Two-level approval required before FI posting (Accountant + Controller)
5. **ADR-005:** All Z code must be S/4HANA-compatible (modern ABAP, CDS views, interface abstraction)
6. **ADR-006:** Z addon is system of record; RE-FX not used at runtime (ACCEPTED)

### Approval Required
- ABAP Architect (for ADR-001, ADR-002, ADR-003, ADR-005)
- Project Governance Lead (for ADR-004, ADR-006)

---

## Deliverable 6: Critical Decisions Matrix

**File:** `docs/governance/critical-decisions-matrix.md`
**Purpose:** Consolidated view of all critical decisions (ADRs + accounting policy + technical)
**Status:** DRAFT — Ready for workshop review
**Owner:** Project Governance Lead

### Contents
- 28 critical decisions (ADR-001 to ADR-006 + accounting policy + technical)
- Current status (ACCEPTED, PROPOSED, OPEN)
- Impact on addon design
- Blocker if not decided
- Approval required
- Target approval date
- Critical path dependencies
- Approval workflow by workshop
- Risk assessment

### Decision Status Summary
- **ACCEPTED:** 1 (ADR-006 — Option B)
- **PROPOSED:** 5 (ADR-001 to ADR-005)
- **OPEN:** 22 (Accounting policy + technical decisions)
- **TOTAL:** 28

### Critical Path
- **Phase 0 Gate:** All 28 decisions must be approved before Phase 1 design begins
- **T0-01 Workshop:** Accounting policy decisions (D-007 to D-022)
- **T0-02 Workshop:** Approval gate + coverage gaps (D-004, coverage decisions)
- **T0-03 Workshop:** ABAP architecture + ADRs (D-001, D-002, D-003, D-005, D-026, D-027, D-028)
- **T0-04 Workshop:** FI integration (D-024, D-025, D-023)

### Approval Required
- Project Governance Lead (overall)
- IFRS 16 Accountant (accounting decisions)
- ABAP Architect (technical decisions)
- FI Architect (FI integration decisions)

---

## Workshop Execution Plan

### T0-01 Workshop: Accounting Policy (2026-04-XX)

**Duration:** 1–2 days
**Participants:** IFRS 16 Accountant, Finance Controller, Lease Accountant, Treasury (if applicable)
**Deliverables:**
1. Completed accounting policy document (signed)
2. Completed accounting policy decision matrix (all cells filled)
3. Approval sign-offs

**Key Decisions to Finalize:**
- OQ-ACC-01: Formal accounting policy sign-off
- OQ-ACC-02: Linearization requirement
- OQ-ACC-03: IBR determination method
- OQ-ACC-04: REASONABLY CERTAIN threshold
- OQ-ACC-05: Initial direct costs tracking

**Success Criteria:**
- All [HUMAN VALIDATION REQUIRED] cells completed
- All decisions documented with rationale
- Signed by IFRS 16 Accountant and Finance Controller
- No open questions remaining

---

### T0-02 Workshop: Blueprint & Coverage (2026-04-XX)

**Duration:** 1–2 days
**Participants:** SAP RE Functional Consultant, ABAP Architect, Project Governance Lead, ECC Coverage Analyst
**Deliverables:**
1. Completed Option B blueprint (signed)
2. Completed coverage gaps matrix (all gaps assessed)
3. Migration strategy (if applicable)
4. Approval sign-offs

**Key Decisions to Finalize:**
- OQ-COV-01 to OQ-COV-08: Coverage questions
- GAP-A-01 to GAP-C-03: Gap resolution decisions
- Migration scope (if applicable)

**Success Criteria:**
- All coverage questions answered
- All gaps assessed and decisions made (include/defer/eliminate)
- Migration strategy confirmed (if applicable)
- Signed by SAP RE Functional Consultant, ABAP Architect, Project Governance Lead
- No open questions remaining

---

## Pre-Workshop Preparation Checklist

### For T0-01 Workshop
- [ ] IFRS 16 Accountant reviews accounting policy template
- [ ] Finance Controller reviews accounting policy template
- [ ] Treasury prepares IBR determination method proposal
- [ ] Lease Accountant prepares list of current contract types
- [ ] All participants review open questions (OQ-ACC-01 to OQ-ACC-05)

### For T0-02 Workshop
- [ ] SAP RE Functional Consultant reviews Option B blueprint
- [ ] ABAP Architect reviews Option B blueprint
- [ ] ECC Coverage Analyst prepares coverage analysis
- [ ] RE Contract Manager prepares list of current contract types
- [ ] All participants review open questions (OQ-COV-01 to OQ-COV-08)

---

## Post-Workshop Actions

### After T0-01 Workshop
1. Update accounting policy document with all decisions
2. Obtain final sign-offs from IFRS 16 Accountant and Finance Controller
3. Publish accounting policy document to knowledge base
4. Create ADR entries for any new accounting decisions
5. Update open-questions-register.md with resolved questions

### After T0-02 Workshop
1. Update Option B blueprint with all coverage decisions
2. Update coverage gaps matrix with gap resolution decisions
3. Obtain final sign-offs from SAP RE Functional Consultant, ABAP Architect, Project Governance Lead
4. Publish blueprint and gaps matrix to knowledge base
5. Update open-questions-register.md with resolved questions
6. Confirm migration strategy (if applicable)

### Before Phase 1 Design Begins
1. All ADRs (ADR-001 to ADR-005) approved by Project Governance Lead
2. All accounting policy decisions approved by IFRS 16 Accountant
3. All coverage decisions approved by SAP RE Functional Consultant
4. All critical decisions matrix approved by Project Governance Lead
5. Phase 0 gate sign-off obtained

---

## Document Locations

| Deliverable | File Path | Status |
|-------------|-----------|--------|
| Accounting Policy Template | `docs/governance/T0-01-accounting-policy-template.md` | DRAFT |
| Accounting Policy Decision Matrix | `docs/governance/T0-01-accounting-policy-decision-matrix.md` | DRAFT |
| Option B Blueprint | `docs/architecture/T0-02-option-b-blueprint.md` | DRAFT |
| Coverage Gaps Matrix | `docs/architecture/T0-02-coverage-gaps-matrix.md` | DRAFT |
| Complete ADRs | `docs/governance/ADR-001-to-ADR-005-complete.md` | PROPOSED |
| Critical Decisions Matrix | `docs/governance/critical-decisions-matrix.md` | DRAFT |
| Executive Summary | `docs/governance/WORKSHOPS-T0-01-T0-02-EXECUTIVE-SUMMARY.md` | DRAFT |

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Deliverables | 7 documents |
| Total Pages (estimated) | 150+ pages |
| Total Decisions to Finalize | 28 decisions |
| Accounting Policy Decisions | 22 decisions |
| Technical/Architectural Decisions | 6 decisions |
| Open Questions to Resolve | 13 questions (OQ-ACC-01 to OQ-ACC-05, OQ-COV-01 to OQ-COV-08) |
| Approval Sign-Offs Required | 5 roles (IFRS 16 Accountant, Finance Controller, SAP RE Functional Consultant, ABAP Architect, Project Governance Lead) |
| Target Workshops | 4 workshops (T0-01, T0-02, T0-03, T0-04) |

---

## Success Criteria for Workshop Completion

### T0-01 Workshop Success
- ✓ All accounting policy decisions documented and approved
- ✓ All OQ-ACC-01 to OQ-ACC-05 questions resolved
- ✓ Accounting policy document signed by IFRS 16 Accountant and Finance Controller
- ✓ No [HUMAN VALIDATION REQUIRED] items remaining
- ✓ No [TO BE CONFIRMED] items without owner and target date

### T0-02 Workshop Success
- ✓ All coverage questions answered and documented
- ✓ All gaps assessed and decisions made
- ✓ Migration strategy confirmed (if applicable)
- ✓ Option B blueprint signed by SAP RE Functional Consultant, ABAP Architect, Project Governance Lead
- ✓ No open questions remaining

### Phase 0 Gate Success (Before Phase 1 Design)
- ✓ All 28 critical decisions approved
- ✓ All ADRs (ADR-001 to ADR-005) approved by Project Governance Lead
- ✓ All accounting policy decisions approved by IFRS 16 Accountant
- ✓ All coverage decisions approved by SAP RE Functional Consultant
- ✓ Phase 0 gate sign-off obtained from Project Governance Lead

---

## Next Steps

1. **Immediate:** Distribute all 7 deliverables to workshop participants for pre-workshop review
2. **T0-01 Workshop:** Complete accounting policy decisions and obtain sign-offs
3. **T0-02 Workshop:** Complete coverage decisions and obtain sign-offs
4. **T0-03 Workshop:** Approve ADRs and ABAP architecture decisions
5. **T0-04 Workshop:** Approve FI integration decisions
6. **Phase 0 Gate:** Obtain final approval for all 28 critical decisions
7. **Phase 1 Design:** Begin detailed design with all decisions approved

---

**Document Status:** DRAFT — Ready for Workshop Execution
**Prepared by:** Project Governance Lead
**Date:** 2026-03-26
**Target Completion:** All workshops completed by 2026-04-XX

