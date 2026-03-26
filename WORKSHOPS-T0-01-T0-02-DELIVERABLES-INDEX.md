# T0-01 & T0-02 Workshops — Complete Deliverables Index
**Version:** 1.0 | **Date:** 2026-03-26 | **Status:** READY FOR WORKSHOPS | **Owner:** Project Governance Lead

---

## Executive Summary

This index consolidates all deliverables prepared for the T0-01 (Accounting Policy IFRS 16) and T0-02 (Blueprint SAP RE-FX / Cobertura Funcional Option B) workshops.

**Total Deliverables:** 7 documents + 1 index (this document)
**Total Pages:** 150+ pages
**Total Decisions to Finalize:** 28 critical decisions
**Total Open Questions:** 13 questions (OQ-ACC-01 to OQ-ACC-05, OQ-COV-01 to OQ-COV-08)
**Approval Required:** 5 roles (IFRS 16 Accountant, Finance Controller, SAP RE Functional Consultant, ABAP Architect, Project Governance Lead)

---

## Deliverables Overview

### 1. IFRS 16 Accounting Policy Document (T0-01)
**File:** `docs/governance/T0-01-accounting-policy-template.md`
**Purpose:** Template for the client's formal IFRS 16 accounting policy
**Status:** DRAFT — Ready for T0-01 completion
**Owner:** IFRS 16 Accountant
**Approval Required:** IFRS 16 Accountant + Finance Controller

**Contents:**
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

**Open Questions to Resolve:**
- OQ-ACC-01: Is the IFRS 16 accounting policy formally signed off?
- OQ-ACC-02: Is linearization of stepped rents required?
- OQ-ACC-03: How is the IBR determined per company code / currency?
- OQ-ACC-04: What is the REASONABLY CERTAIN threshold for renewal options?
- OQ-ACC-05: Are initial direct costs (IDC) tracked and included in ROU?

---

### 2. Accounting Policy Decision Matrix (T0-01)
**File:** `docs/governance/T0-01-accounting-policy-decision-matrix.md`
**Purpose:** Matrix mapping every IFRS 16 accounting policy decision to IFRS 16 paragraphs, options, and design impact
**Status:** DRAFT — Ready for T0-01 completion
**Owner:** IFRS 16 Accountant
**Approval Required:** IFRS 16 Accountant + Finance Controller

**Contents:**
- 27 accounting policy decisions (B-01 to B-27)
- IFRS 16 paragraph references for each decision
- Options considered for each decision
- Proposed decision (to be completed in T0-01)
- Impact on CD-03 (Valuation Engine) and CD-04 (Accounting Engine)
- Blocker if decision is not made

**Key Decisions to Finalize:**
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

---

### 3. Option B Blueprint (T0-02)
**File:** `docs/architecture/T0-02-option-b-blueprint.md`
**Purpose:** Complete Option B architecture and functional coverage analysis
**Status:** DRAFT — Ready for T0-02 completion
**Owner:** SAP RE Functional Consultant + ABAP Architect
**Approval Required:** SAP RE Functional Consultant + ABAP Architect + Project Governance Lead

**Contents:**
- Why Option B? (Option A vs. Option B comparison)
- Option B architecture overview (logical diagram)
- The 9 capability domains (CD-01 to CD-09)
- Functional coverage analysis by domain
- Coverage summary (88% Phase 1, 12% Phase 2)
- Open coverage questions (OQ-COV-01 to OQ-COV-08)
- Migration strategy (if applicable)
- Architectural constraints (Option B governance rules)

**Key Sections:**
1. **Section 1:** Why Option B? — Business case for Z addon as system of record
2. **Section 2:** Architecture Overview — Logical diagram and 9 capability domains
3. **Section 3:** Functional Coverage Analysis — Detailed mapping of current ECC capabilities to Option B
4. **Section 4:** Open Coverage Questions — 8 questions to be resolved in T0-02
5. **Section 5:** Migration Strategy — If existing RE-FX contracts need migration
6. **Section 6:** Architectural Constraints — Non-negotiable Option B rules

**Open Questions to Resolve:**
- OQ-COV-01: Are there RE-FX contract types that don't fit CD-01/CD-02?
- OQ-COV-02: Is linearization required by accounting policy?
- OQ-COV-03: Is FI-AP matching in Phase 1 or Phase 2?
- OQ-COV-04: Are initial direct costs tracked in current ECC?
- OQ-COV-05: Is Poland advance payment the only country-specific rule?
- OQ-COV-06: Is parallel ledger for local GAAP currently active?
- OQ-COV-07: Is procurement/PO-to-contract pattern in scope?
- OQ-COV-08: Are there vehicle fleet leases with specific attributes?

---

### 4. Coverage Gaps Analysis Matrix (T0-02)
**File:** `docs/architecture/T0-02-coverage-gaps-matrix.md`
**Purpose:** Identify functional gaps between current ECC and Option B Phase 1
**Status:** DRAFT — Ready for T0-02 completion
**Owner:** ECC Coverage Analyst
**Approval Required:** ECC Coverage Analyst + Project Governance Lead

**Contents:**
- Gap Category A: Capabilities deferred to Phase 2 (3 gaps)
- Gap Category B: New capabilities in Phase 1 (6 capabilities)
- Gap Category C: Capabilities with reduced scope (3 capabilities)
- Gap Category D: Capabilities with enhanced scope (4 capabilities)
- Risk assessment for deferred capabilities
- Decisions required in T0-02
- Coverage summary after gap resolution

**Key Gaps to Resolve:**
- GAP-A-01: Vendor invoice matching (FI-AP integration) — defer to Phase 2?
- GAP-A-02: Disclosure pack export (Excel/PDF) — defer to Phase 2?
- GAP-A-03: Procurement/PO-to-contract pattern — defer to Phase 2?
- GAP-A-04: Impairment of ROU assets — defer to Phase 3?
- GAP-C-01: Parallel ledger for local GAAP — conditional on configuration
- GAP-C-02: Country-specific rules (Poland) — conditional on policy
- GAP-C-03: Linearization of stepped rents — conditional on policy

---

### 5. Complete Architecture Decision Records (ADR-001 to ADR-005)
**File:** `docs/governance/ADR-001-to-ADR-005-complete.md`
**Purpose:** Complete Architecture Decision Records for foundational project decisions
**Status:** PROPOSED — Ready for Project Governance Lead review
**Owner:** Project Governance Lead
**Approval Required:** ABAP Architect (ADR-001, ADR-002, ADR-003, ADR-005) + Project Governance Lead (ADR-004)

**ADRs Included:**

| ADR | Title | Status | Owner | Target Approval |
|-----|-------|--------|-------|-----------------|
| ADR-001 | ABAP OO Mandate for All Z Development | PROPOSED | ABAP Architect | T0-03 |
| ADR-002 | Z Object Naming Convention Adoption | PROPOSED | ABAP Architect | T0-03 |
| ADR-003 | Application Logging via SAP SLG1 + Z Audit Table | PROPOSED | ABAP Architect | T0-03 |
| ADR-004 | Human Approval Gate Mandatory Before FI Posting | PROPOSED | Project Governance Lead | T0-02 |
| ADR-005 | S/4HANA Compatibility by Design | PROPOSED | ABAP Architect | T0-03 |
| ADR-006 | Option B — Z Addon Replaces RE-FX as System of Record | **ACCEPTED** | Project Governance Lead | 2026-03-26 ✓ |

**Key Decisions:**
1. **ADR-001:** All Z code must be ABAP OO (not procedural)
2. **ADR-002:** All Z objects follow ZRIF16_* naming convention
3. **ADR-003:** Dual logging: SLG1 (operational) + ZRIF16_AUDIT (compliance, 7-year retention)
4. **ADR-004:** Two-level approval required before FI posting (Accountant + Controller)
5. **ADR-005:** All Z code must be S/4HANA-compatible (modern ABAP, CDS views, interface abstraction)
6. **ADR-006:** Z addon is system of record; RE-FX not used at runtime (ACCEPTED)

---

### 6. Critical Decisions Matrix
**File:** `docs/governance/critical-decisions-matrix.md`
**Purpose:** Consolidated view of all critical decisions (ADRs + accounting policy + technical)
**Status:** DRAFT — Ready for workshop review
**Owner:** Project Governance Lead
**Approval Required:** Project Governance Lead (overall)

**Contents:**
- 28 critical decisions (ADR-001 to ADR-006 + accounting policy + technical)
- Current status (ACCEPTED, PROPOSED, OPEN)
- Impact on addon design
- Blocker if not decided
- Approval required
- Target approval date
- Critical path dependencies
- Approval workflow by workshop
- Risk assessment

**Decision Status Summary:**
- **ACCEPTED:** 1 (ADR-006 — Option B)
- **PROPOSED:** 5 (ADR-001 to ADR-005)
- **OPEN:** 22 (Accounting policy + technical decisions)
- **TOTAL:** 28

**Critical Path:**
- **Phase 0 Gate:** All 28 decisions must be approved before Phase 1 design begins
- **T0-01 Workshop:** Accounting policy decisions (D-007 to D-022)
- **T0-02 Workshop:** Approval gate + coverage gaps (D-004, coverage decisions)
- **T0-03 Workshop:** ABAP architecture + ADRs (D-001, D-002, D-003, D-005, D-026, D-027, D-028)
- **T0-04 Workshop:** FI integration (D-024, D-025, D-023)

---

### 7. Executive Summary: T0-01 & T0-02 Workshop Deliverables
**File:** `docs/governance/WORKSHOPS-T0-01-T0-02-EXECUTIVE-SUMMARY.md`
**Purpose:** Summary of all deliverables and workshop execution plan
**Status:** DRAFT — Ready for workshop review
**Owner:** Project Governance Lead

**Contents:**
- Overview of all 6 deliverables
- Workshop execution plan (T0-01, T0-02)
- Pre-workshop preparation checklist
- Post-workshop actions
- Document locations
- Key metrics
- Success criteria

---

### 8. Workshops Quick Reference Guide
**File:** `docs/governance/WORKSHOPS-QUICK-REFERENCE.md`
**Purpose:** Quick navigation and reference for workshop participants
**Status:** READY FOR USE
**Owner:** Project Governance Lead

**Contents:**
- Quick navigation to T0-01 and T0-02 workshops
- The 9 capability domains (CD-01 to CD-09)
- Critical decisions summary
- Open questions by workshop
- Pre-workshop checklist
- Document editing during workshops
- Approval sign-off process
- Key contacts
- Escalation path
- Success metrics
- Useful links
- Tips for workshop facilitators

---

## The 9 Capability Domains (CD-01 to CD-09)

| Domain | ID | What It Does | Replaces | Phase 1 Coverage |
|--------|----|----|----------|-----------------|
| Contract Master Z | CD-01 | Full lease contract master data | RECN* / VICNCOND in RE-FX | 100% |
| Lease Object Master Z | CD-02 | Classification and description of leased asset | RE-FX object hierarchy | 100% |
| Valuation Engine Z | CD-03 | All IFRS 16 calculations | RE-FX valuation + manual spreadsheets | 100% |
| Accounting Engine Z (FI-GL) | CD-04 | All FI-GL document creation | RE-FX accounting + manual FI postings | 88% (GAP-A-01 deferred) |
| Asset Engine Z (FI-AA) | CD-05 | ROU asset lifecycle | RE-FX FI-AA integration | 100% |
| Contract Event Engine Z | CD-06 | Non-destructive contract lifecycle | RE-FX contract amendment history | 100% |
| Procurement / Source Integration Z | CD-07 | PO-to-contract pattern | None (new capability) | 0% (Phase 2) |
| Reclassification Engine Z | CD-08 | Current/non-current liability reclassification | ZRE009 / RE-FX reclassification | 100% |
| Reporting & Audit Z | CD-09 | All reporting, rollforward, reconciliation | RE-FX reports + manual disclosure | 90% (GAP-A-02 deferred) |

---

## Open Questions Summary

### T0-01 Workshop (Accounting Policy)
**OQ-ACC-01 to OQ-ACC-05** — 5 questions

| OQ ID | Question | Owner | Status |
|-------|----------|-------|--------|
| OQ-ACC-01 | Is the IFRS 16 accounting policy formally signed off by the client? | IFRS 16 Accountant | OPEN |
| OQ-ACC-02 | Is linearization of stepped rents required (or optional) under the client's policy? | IFRS 16 Accountant | OPEN |
| OQ-ACC-03 | How is the Incremental Borrowing Rate (IBR) determined per company code / currency? | IFRS 16 Accountant + Treasury | OPEN |
| OQ-ACC-04 | Is the REASONABLY CERTAIN threshold for renewal options defined in client policy? | IFRS 16 Accountant | OPEN |
| OQ-ACC-05 | Are initial direct costs (IDC) tracked and to be included in ROU calculation? | IFRS 16 Accountant | OPEN |

### T0-02 Workshop (Blueprint & Coverage)
**OQ-COV-01 to OQ-COV-08** — 8 questions

| OQ ID | Question | Owner | Status |
|-------|----------|-------|--------|
| OQ-COV-01 | Are there RE-FX contract types used by the client that don't fit CD-01/CD-02 classification? | T0-02 Workshop | OPEN |
| OQ-COV-02 | Is linearization (B-12) required by the client's accounting policy? | T0-01 Accounting Workshop | OPEN |
| OQ-COV-03 | Is FI-AP matching (A-14) in scope for Phase 1 or Phase 2? | Project Governance Lead | OPEN |
| OQ-COV-04 | Are initial direct costs (B-08) tracked in current ECC solution? | Lease Accountant | OPEN |
| OQ-COV-05 | Is the Poland advance payment rule the only country-specific rule, or are there others? | Local Finance Users | OPEN |
| OQ-COV-06 | Is parallel ledger for local GAAP currently active? | FI Architect | OPEN |
| OQ-COV-07 | Is procurement/PO-to-contract pattern (Section F) in scope for this project? | Project Governance Lead | OPEN |
| OQ-COV-08 | Are there vehicle fleet leases with specific attributes not covered by current Z object model? | RE Contract Manager | OPEN |

---

## Critical Decisions Summary

### Already Approved
- **ADR-006:** Option B — Z addon replaces RE-FX as system of record ✓ ACCEPTED (2026-03-26)

### Pending Approval (ADR-001 to ADR-005)
| ADR | Title | Owner | Target Approval |
|-----|-------|-------|-----------------|
| ADR-001 | ABAP OO Mandate | ABAP Architect | T0-03 |
| ADR-002 | Z Naming Convention | ABAP Architect | T0-03 |
| ADR-003 | Application Logging (SLG1 + ZRIF16_AUDIT) | ABAP Architect | T0-03 |
| ADR-004 | Human Approval Gate Before FI Posting | Project Governance Lead | T0-02 |
| ADR-005 | S/4HANA Compatibility by Design | ABAP Architect | T0-03 |

### Accounting Policy Decisions (T0-01)
- 22 accounting policy decisions (D-007 to D-028)
- All require IFRS 16 Accountant approval
- All require Finance Controller approval

### Technical/Architectural Decisions (T0-02, T0-03, T0-04)
- 6 technical decisions (D-024, D-025, D-026, D-027, D-028, D-023)
- Require ABAP Architect, FI Architect, Project Governance Lead approval

---

## Workshop Schedule

| Workshop | Date | Duration | Participants | Deliverables |
|----------|------|----------|--------------|--------------|
| T0-01 | 2026-04-XX | 1–2 days | IFRS 16 Accountant, Finance Controller, Lease Accountant, Treasury | Accounting policy document (signed), Decision matrix (completed) |
| T0-02 | 2026-04-XX | 1–2 days | SAP RE Functional Consultant, ABAP Architect, Project Governance Lead, ECC Coverage Analyst | Option B blueprint (signed), Coverage gaps matrix (completed), Migration strategy |
| T0-03 | 2026-04-XX | 1–2 days | ABAP Architect, Project Governance Lead | ABAP architecture design (signed), Development guidelines |
| T0-04 | 2026-04-XX | 1–2 days | FI Architect, FI-AA Specialist, Project Governance Lead | FI integration design (signed) |

---

## Success Criteria

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
| Quick Reference Guide | `docs/governance/WORKSHOPS-QUICK-REFERENCE.md` | READY FOR USE |
| Deliverables Index | `WORKSHOPS-T0-01-T0-02-DELIVERABLES-INDEX.md` | THIS DOCUMENT |

---

## Next Steps

1. **Immediate:** Distribute all 8 documents to workshop participants for pre-workshop review
2. **T0-01 Workshop:** Complete accounting policy decisions and obtain sign-offs
3. **T0-02 Workshop:** Complete coverage decisions and obtain sign-offs
4. **T0-03 Workshop:** Approve ADRs and ABAP architecture decisions
5. **T0-04 Workshop:** Approve FI integration decisions
6. **Phase 0 Gate:** Obtain final approval for all 28 critical decisions
7. **Phase 1 Design:** Begin detailed design with all decisions approved

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Deliverables | 8 documents |
| Total Pages (estimated) | 150+ pages |
| Total Decisions to Finalize | 28 decisions |
| Accounting Policy Decisions | 22 decisions |
| Technical/Architectural Decisions | 6 decisions |
| Open Questions to Resolve | 13 questions |
| Approval Sign-Offs Required | 5 roles |
| Target Workshops | 4 workshops |
| Phase 1 Coverage | 85% (after gap resolution) |
| Phase 2 Coverage | 12% (deferred capabilities) |
| Phase 3 Coverage | 3% (later capabilities) |

---

## Approval Sign-Off

This deliverables index is approved by:

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Governance Lead | _________________ | _________________ | _______ |

---

**Document Status:** READY FOR WORKSHOPS
**Prepared by:** Project Governance Lead
**Date:** 2026-03-26
**Target Completion:** All workshops completed by 2026-04-XX

