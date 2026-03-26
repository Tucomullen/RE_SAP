# T0-02 Blueprint: Option B Architecture and Functional Coverage
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** DRAFT — Ready for T0-02 Workshop | **Owner:** SAP RE Functional Consultant + ABAP Architect

---

## Executive Summary

This document presents the complete Option B blueprint for the RE-SAP IFRS 16 Addon. It is the authoritative reference for the T0-02 workshop, which will:

1. **Validate the Option B architectural choice** against current ECC business functionality.
2. **Map every current ECC capability** to its Option B replacement (CD-01 to CD-09).
3. **Identify and resolve functional coverage gaps** (OQ-COV-01 to OQ-COV-08).
4. **Confirm the migration strategy** if existing RE-FX contracts exist.
5. **Obtain sign-off** from SAP RE Functional Consultant, ABAP Architect, and Project Governance Lead.

---

## Section 1: Why Option B?

### 1.1 Option A vs. Option B Comparison

| Aspect | Option A (RE-FX Backend) | Option B (Z Standalone) | Winner |
|--------|------------------------|------------------------|--------|
| **System of Record** | RE-FX contract objects (RECN*) | Z tables (ZRIF16_*) | B — cleaner, self-owned |
| **User Experience** | RE-FX screens + Z wizard overlay | Z workspace only | B — consistent, no context switching |
| **Data Dependencies** | RE-FX condition types, object hierarchy | Z payment schedule, Z object master | B — no config interpretation needed |
| **Calculation Engine** | RE-FX valuation + Z IFRS 16 logic | Z valuation engine only | B — single source of truth |
| **Accounting Engine** | RE-FX accounting + Z posting logic | Z posting logic only | B — direct FI BAPI, no RE-FX dependency |
| **FI-AA Integration** | Via RE-FX | Direct FI-AA BAPI | B — cleaner, no RE-FX layer |
| **S/4 Migration Risk** | High — RE-FX table structures change in S/4 | Low — Z tables self-owned | B — future-proof |
| **Maintenance Burden** | Dual system (RE-FX + Z) | Single system (Z) | B — lower TCO |
| **Audit Trail** | Fragmented (RE-FX + Z + FI) | Unified (Z + FI) | B — complete traceability |

### 1.2 Decision: Option B Approved (ADR-006)

**Status:** ACCEPTED — Non-negotiable architectural constraint.
**Effective Date:** 2026-03-26
**Governance:** Enforced by hook `option-b-architecture-guard`

**Key Principle:** The Z addon is the system of record. RE-FX is NOT used at runtime after go-live (except one-time migration read-out if applicable).

---

## Section 2: Option B Architecture Overview

### 2.1 Logical Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    END USER WORKSPACE (Z)                        │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────────┐ │
│  │ Contract Mgmt  │  │ Lease Accountant│  │ Controller / Audit │ │
│  │ (RE Contract   │  │ (Calculation,  │  │ (Approval,         │ │
│  │  Manager)      │  │  Posting)      │  │  Disclosure)       │ │
│  └───────┬────────┘  └───────┬────────┘  └─────────┬──────────┘ │
└──────────┼───────────────────┼──────────────────────┼────────────┘
           │                   │                      │
┌──────────▼───────────────────▼──────────────────────▼────────────┐
│                    Z ADDON BUSINESS LOGIC LAYER                   │
│                                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐ │
│  │  CD-01        │  │  CD-03        │  │  CD-06                   │ │
│  │ Contract      │  │ Valuation     │  │ Contract Event           │ │
│  │ Master Z      │  │ Engine Z      │  │ Engine Z                 │ │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘ │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐ │
│  │  CD-02        │  │  CD-04        │  │  CD-07                   │ │
│  │ Lease Object  │  │ Accounting    │  │ Procurement /            │ │
│  │ Master Z      │  │ Engine Z      │  │ Source Integration Z     │ │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘ │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐ │
│  │  CD-05        │  │  CD-08        │  │  CD-09                   │ │
│  │ Asset         │  │ Reclassi-     │  │ Reporting &              │ │
│  │ Engine Z      │  │ fication Z    │  │ Audit Z                  │ │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
           │                   │                      │
┌──────────▼───────────────────▼──────────────────────▼────────────┐
│               Z DATA PERSISTENCE LAYER                            │
│                                                                    │
│  Contract Master | Lease Objects | Valuation Results              │
│  Posting History | Contract Events | Integration Refs             │
│  Documents/Evidence | Error Logs | Configuration                  │
│  Reclassification History                                         │
└──────────────────────────────────────────────────────────────────┘
           │                                          │
┌──────────▼──────────────────────────────────────────▼────────────┐
│              SAP ECC INTEGRATION LAYER (PERMITTED ONLY)           │
│                                                                    │
│  FI-GL (BAPIs — WRITE)    FI-AA (BAPIs — WRITE)    CO (via FI)   │
│  SLG1 (Audit Log)         CTS (Transport)          Auth Objects   │
│                                                                    │
│  ╳ RE-FX: NOT USED AT RUNTIME                                     │
└───────────────────────────────────────────────────────────────────┘
```

### 2.2 The 9 Capability Domains (CD-01 to CD-09)

| Domain | ID | Description | Replaces | Spec |
|--------|----|----|----------|------|
| Contract Master Z | CD-01 | Full lease contract master data — all contracts managed by addon | RECN* / VICNCOND in RE-FX | specs/001-contract-master-z/ |
| Lease Object Master Z | CD-02 | Classification and description of leased asset/object | RE-FX object hierarchy | specs/002-lease-object-z/ |
| Valuation Engine Z | CD-03 | All IFRS 16 calculations — initial recognition and subsequent measurement | RE-FX valuation engine + manual spreadsheets | specs/003-valuation-engine-z/ |
| Accounting Engine Z (FI-GL) | CD-04 | All FI-GL document creation — lease accounting entries posted directly to FI | RE-FX accounting engine + manual FI postings | specs/004-accounting-engine-z/ |
| Asset Engine Z (FI-AA) | CD-05 | ROU asset lifecycle — creation, depreciation activation, derecognition | RE-FX FI-AA integration | specs/005-fi-aa-integration-z/ |
| Contract Event Engine Z | CD-06 | Non-destructive contract lifecycle — all changes captured as events | RE-FX contract amendment / change history | specs/006-contract-event-lifecycle-z/ |
| Procurement / Source Integration Z | CD-07 | Pattern for creating lease contracts from upstream procurement data (PO, source document) | No direct RE-FX equivalent — net-new capability | specs/007-procurement-source-integration-z/ |
| Reclassification Engine Z | CD-08 | Periodic reclassification of lease liability from non-current to current portion | ZRE009 / RE-FX reclassification | specs/008-reclassification-engine-z/ |
| Reporting & Audit Z | CD-09 | All reporting, rollforward, reconciliation, and audit output | RE-FX standard reports (fragmented) + manual disclosure spreadsheets | specs/009-reporting-audit-z/ |

---

## Section 3: Functional Coverage Analysis

### 3.1 Coverage by Domain

#### CD-01: Contract Master Z

**Current ECC Capability → Option B Implementation**

| Capability | Current State | Option B | Improvement | Priority |
|-----------|---------------|----------|------------|----------|
| Company code assignment | RE-FX contract header | Z contract master | None — replicated | Must |
| Contract type classification | RE-FX contract category + object type | Z contract header + Z lease object master | Simplified classification | Must |
| Lessor (vendor) | RE-FX business partner | Z contract: vendor number (SAP vendor master FK) | None | Must |
| Leased asset description | RE-FX object hierarchy | Z lease object master (simplified) | No hierarchy overhead | Must |
| Start date / end date | RE-FX contract valid from/to | Z contract master dates | None | Must |
| Non-cancellable period | Manually derived from RE-FX dates | Explicit field in Z contract | **Improvement: explicit field** | Must |
| Renewal options | RE-FX option date fields | Z contract: renewal option flag + probability | **Improvement: structured option analysis** | Must |
| Termination options | RE-FX notice/termination dates | Z contract: termination option flag + probability | Same | Must |
| Payment amount and frequency | RE-FX condition types | Z payment schedule table | **Improvement: explicit Z structure** | Must |
| Payment in advance flag | RE-FX condition purpose | Explicit Z flag on payment schedule | **Improvement: visible, no config interpretation** | Must |
| Currency (payment + reporting) | RE-FX contract currency | Z contract: payment currency + reporting currency | None | Must |
| Cost center assignment | RE-FX partner/object assignment | Explicit Z field on contract | **Improvement: always visible** | Must |
| Profit center assignment | RE-FX partner/object assignment | Explicit Z field on contract | Same | Must |
| Vendor invoice matching | FI-AP + RE-FX | Z posting log ↔ FI-AP read (Phase 2) | Phase 2 | Should |
| Contract document attachments | SAP GOS on RE-FX object | Z doc reference + SAP GOS on Z contract | None | Should |
| Mass contract creation | Not supported (manual only) | Z mass upload (Excel/CSV + guided UI) | **Major improvement: new capability** | Must |

**Coverage Status:** 14 MUST items, 2 SHOULD items → **100% coverage for Phase 1**

#### CD-02: Lease Object Master Z

| Capability | Current State | Option B | Priority |
|-----------|---------------|----------|----------|
| Object type (land / building / vehicle / equipment) | RE-FX object type | Z lease object master | Must |
| Object subtype | RE-FX object subtype | Z lease object master | Must |
| Physical description | RE-FX object description | Z lease object master | Should |
| Location | RE-FX object location | Z lease object master | Should |
| Cost center default | RE-FX object assignment | Z lease object master | Should |

**Coverage Status:** 2 MUST items, 3 SHOULD items → **100% coverage for Phase 1**

#### CD-03: Valuation Engine Z

| Capability | Current State | Option B | Improvement | Priority |
|-----------|---------------|----------|------------|----------|
| Initial lease liability | Manual spreadsheet or Z calc | Z valuation engine: PV of future payments | **Improvement: automated, auditable** | Must |
| Right-of-use asset | Manual spreadsheet | Z valuation: ROU = liability + initial direct costs + prepaid | Same | Must |
| Discount rate (IBR) | Manual input / spreadsheet | Z: IBR config table + contract-level override | **Improvement: governance-controlled** | Must |
| Amortization schedule (liability) | Spreadsheet | Z schedule table: period / interest / payment / balance | Full auto, audit trail | Must |
| Amortization schedule (ROU) | Spreadsheet | Z schedule: period / amortization / balance | Full auto | Must |
| Interest accrual (monthly) | Manual FI posting | Z accounting engine → FI BAPI auto-post | **Major improvement** | Must |
| Advance payments / prepaid | Complex RE-FX config | Explicit Z field; included in ROU at commencement | **Improvement: explicit** | Must |
| Initial direct costs | Not currently tracked | Z field on contract; add to ROU | **New capability** | Should |
| Rent increases (scheduled) | RE-FX condition steps | Z payment schedule: stepped amounts per period | **Improvement: no condition config needed** | Must |
| Remeasurement (modification) | Manual spreadsheet | Z event triggers new calc run; new schedule from event date | **Major improvement** | Must |
| Reassessment (option exercise) | Manual spreadsheet | Same as remeasurement, event type = OPTION_EXERCISED | Same | Must |
| Linearization | RE-FX or manual | Z valuation: straight-line option for stepped rents | Confirm if required by accounting policy | Should |
| Early termination | Manual + RE-FX | Z event: TERMINATED_EARLY → derecognition calculation → FI posting | Full automation | Must |
| Purchase option | Not in current RE-FX solution | Z event: PURCHASE_OPTION_EXERCISED → ROU becomes owned asset | New capability | Should |
| Impairment / deterioration | Not in current solution | Z: impairment flag on ROU; FI posting for impairment write-down | New capability | Later |
| Local GAAP parallel | RE-FX parallel ledger or manual | Z posting engine: support multi-ledger (if configured) | Preserves if needed | Should |
| Country-specific rules (Poland) | Manual workaround | Z: country-specific valuation rule flag on company code | **Improvement: systematic** | Should |

**Coverage Status:** 12 MUST items, 3 SHOULD items, 1 LATER item → **100% coverage for Phase 1**

#### CD-04: Accounting Engine Z (FI-GL)

| Capability | Current State | Option B | Improvement | Priority |
|-----------|---------------|----------|------------|----------|
| Initial recognition FI document | RE-FX accounting engine or manual | Z engine → `BAPI_ACC_DOCUMENT_POST` | **Major improvement: direct, traceable** | Must |
| Interest accrual FI document | Manual posting | Z batch → FI BAPI auto | Full auto | Must |
| Amortization / depreciation FI | FI-AA depreciation run (manual trigger) | Z activates FI-AA depreciation + links to contract | Improved traceability | Must |
| Payment / cash flow FI | FI-AP standard + manual | Z records payment event; FI-AP matching Phase 2 | Phase 2 | Must |
| Posting simulation | Not available | Z simulation mode: show FI lines without posting | **New capability** | Must |
| Posting reversal | Manual FI reversal | Z reversal event → FI reversal BAPI | **Improvement: traceable** | Must |
| Posting error handling | None — silent failures | Z error log per contract + reprocessing queue | **Major improvement** | Must |
| FI document ↔ contract traceability | None | Z contract ID in FI document reference fields | **New: full traceability** | Must |

**Coverage Status:** 8 MUST items → **100% coverage for Phase 1**

#### CD-05: Asset Engine Z (FI-AA)

| Capability | Current State | Option B | Priority |
|-----------|---------------|----------|----------|
| ROU asset creation | RE-FX FI-AA integration | Z: direct FI-AA BAPI call | Must |
| ROU asset depreciation activation | FI-AA depreciation run | Z: activate FI-AA depreciation per contract per period | Must |

**Coverage Status:** 2 MUST items → **100% coverage for Phase 1**

#### CD-06: Contract Event Engine Z

| Capability | Current State | Option B | Priority |
|-----------|---------------|----------|----------|
| Contract extension | RE-FX contract change | Z event: EXTENDED — recalculate from extension date | Must |
| Novation (change of lessor) | RE-FX amendment | Z event: NOVATED — update vendor + remeasure | Must |
| Cost center / profit center reassignment | Manual RE-FX assignment change | Z event: CC_CHANGED — update contract + re-assign future postings | Must |
| Partial scope change | Complex RE-FX | Z event: SCOPE_CHANGED — recalculate based on new scope | Should |
| Effective-date recalculation | Manual spreadsheet | Z: event date → new calc run from that date forward | Must |
| Historical event versions | None in current solution | Z: non-destructive event journal — all versions preserved | Must |
| Extension / rescission out-of-sequence guard | None | Z: event sequencing validation — guided workflow enforcement | Must |

**Coverage Status:** 6 MUST items, 1 SHOULD item → **100% coverage for Phase 1**

#### CD-07: Procurement / Source Integration Z

| Capability | Current State | Option B | Priority |
|-----------|---------------|----------|----------|
| Contract draft from PO | None — manual | Z: PO-to-contract draft generation pattern | Should |
| Error log and reprocessing | None | Z: source integration error queue + retry | Should |
| Traceability: PO → contract | None | Z integration reference: PO number linked to contract | Should |
| Reusable framework | None — vehicle-specific workaround | Z: configurable source integration framework | Should |

**Coverage Status:** 0 MUST items, 4 SHOULD items → **Phase 2 candidate**

#### CD-08: Reclassification Engine Z

| Capability | Current State | Option B | Priority |
|-----------|---------------|----------|----------|
| Current/non-current reclassification | ZRE009 (fragile, PP-C) | Z reclassification engine: reliable, transparent, per-contract | Must |
| Reversal logic | Manual FI reversal | Z reversal event type + FI reversal BAPI | Must |
| Period-end controls | None | Z period-end checklist: all contracts processed / errors / pending | Must |

**Coverage Status:** 3 MUST items → **100% coverage for Phase 1**

#### CD-09: Reporting & Audit Z

| Capability | Current State | Option B | Priority |
|-----------|---------------|----------|----------|
| Active contracts list | RE-FX report (non-user-friendly) | Z CDS view: active contracts with IFRS 16 status | Must |
| Maturity / expiry report | None | Z: contracts expiring in N months | Must |
| Liability rollforward | None — manual Excel | Z: auto rollforward from schedule table | Must |
| ROU rollforward | None — manual Excel | Z: auto ROU rollforward linked to FI-AA | Must |
| Posting history by contract | FBL3N (not contract-linked) | Z: contract-level posting history from ZRIF16_POST_LOG | Must |
| Pending modifications not posted | None | Z: dashboard — events without resulting postings | Must |
| Exception management | None | Z: exception list — errors, pending items, overdue reviews | Must |
| Contract-level amortization view | Only by asset class | Z: per-contract amortization report from schedule table | Must |
| Disclosure pack output | Manual Excel | Z: structured disclosure data + export (Phase 2) | Should |
| Audit evidence pack | None | Z: audit evidence per contract — events + calculations + FI docs | Must |

**Coverage Status:** 8 MUST items, 2 SHOULD items → **100% coverage for Phase 1**

### 3.2 Coverage Summary Table

| Domain | Must | Should | Later | Total | Phase 1 Coverage |
|--------|------|--------|-------|-------|-----------------|
| CD-01 Contract Master | 14 | 2 | 0 | 16 | 100% |
| CD-02 Lease Object | 2 | 0 | 0 | 2 | 100% |
| CD-03 Valuation Engine | 12 | 3 | 1 | 16 | 100% |
| CD-04 Accounting Engine | 8 | 0 | 0 | 8 | 100% |
| CD-05 Asset Engine | 2 | 0 | 0 | 2 | 100% |
| CD-06 Contract Events | 6 | 1 | 0 | 7 | 100% |
| CD-07 Procurement Integration | 0 | 4 | 0 | 4 | 0% (Phase 2) |
| CD-08 Reclassification | 3 | 0 | 0 | 3 | 100% |
| CD-09 Reporting & Audit | 8 | 2 | 0 | 10 | 100% |
| **TOTAL** | **55** | **12** | **1** | **68** | **88% (Phase 1)** |

---

## Section 4: Open Coverage Questions (OQ-COV-01 to OQ-COV-08)

| OQ ID | Question | Owner | Blocks | Status |
|-------|----------|-------|--------|--------|
| OQ-COV-01 | Are there RE-FX contract types used by the client that don't fit CD-01/CD-02 classification? | T0-02 Workshop | Domain 1+2 design | OPEN |
| OQ-COV-02 | Is linearization (B-12) required by the client's accounting policy? | T0-01 Accounting Workshop | CD-03 design | OPEN |
| OQ-COV-03 | Is FI-AP matching (A-14) in scope for Phase 1 or Phase 2? | Project Governance Lead | CD-04 scope | OPEN |
| OQ-COV-04 | Are initial direct costs (B-08) tracked in current ECC solution? | Lease Accountant | CD-03 design | OPEN |
| OQ-COV-05 | Is the Poland advance payment rule the only country-specific rule, or are there others? | Local Finance Users | CD-03 design | OPEN |
| OQ-COV-06 | Is parallel ledger for local GAAP currently active? | FI Architect | CD-04 design | OPEN |
| OQ-COV-07 | Is procurement/PO-to-contract pattern (Section F) in scope for this project? | Project Governance Lead | CD-07 scope | OPEN |
| OQ-COV-08 | Are there vehicle fleet leases with specific attributes not covered by current Z object model? | RE Contract Manager | CD-02 design | OPEN |

---

## Section 5: Migration Strategy (If Applicable)

### 5.1 Migration Scope

**Question:** [HUMAN VALIDATION REQUIRED — T0-02 Workshop]

Does the client have existing contracts in RE-FX that need to be migrated to Z tables?

**If YES:**
- **Scope:** How many contracts? Which company codes? Which asset classes?
- **Approach:** One-time migration program (Phase 0 or Phase 1 gate).
- **Validation:** Reconciliation between RE-FX source and Z target.
- **Cutover:** Big-bang or phased by company code?

**If NO:**
- **Approach:** No migration needed; Z addon is used for all new contracts from go-live.

### 5.2 Migration Data Flow (If Applicable)

```
RE-FX Contract Objects (RECN*, VICNCOND, etc.)
    ↓
Migration Staging Table (ZRIF16_MIGRATION_STAGING)
    ↓
Validation & Mapping Logic
    ↓
Z Contract Master (ZRIF16_CONTRACT)
Z Payment Schedule (ZRIF16_PAYMENT_SCHED)
Z Lease Object Master (ZRIF16_LEASEOBJ)
    ↓
Initial Valuation Run (CD-03)
    ↓
Z Calculation Results (ZRIF16_CALC, ZRIF16_SCHED)
    ↓
Initial Recognition FI Posting (CD-04)
    ↓
Z Posting Log (ZRIF16_POSTING_LOG)
```

---

## Section 6: Architectural Constraints (Non-Negotiable)

### 6.1 Option B Governance Rules

| Rule | Enforcement | Consequence if Violated |
|------|------------|------------------------|
| **OB-01:** No Z table may use RECN* or VICNCOND* as a foreign key for operational data | hook: option-b-architecture-guard | Design rejected; must use Z-native alternative |
| **OB-02:** No agent, spec, or design may propose RE-FX as the source of contract truth | hook: option-b-architecture-guard | Design rejected; reference ADR-006 |
| **OB-03:** No accounting document may be created by RE-FX accounting engine | hook: accounting-traceability-check | Design rejected; FI BAPI is the only permitted path |
| **OB-04:** Every feature must map to at least one of the 9 capability domains (CD-01 to CD-09) | hook: capability-coverage-check | Feature cannot be approved without mapping |
| **OB-05:** Contract master data, valuation data, posting data, and event data must be in separate domain tables | spec: domain-data-model | Design rejected; must separate by domain |
| **OB-06:** No contract change may overwrite history — event model is non-destructive | hook: contract-lifecycle-integrity-check | Design rejected; must use event model |
| **OB-07:** All accounting output must trace to: source event + valuation run + calculation inputs | hook: accounting-traceability-check | Design rejected; must add traceability |
| **OB-08:** All current ECC business functionality must be preserved or explicitly deferred | skill: ecc-coverage-preservation | Feature cannot be deferred without governance approval |
| **OB-09:** No open architecture/accounting question may be silently ignored | hook: open-questions-register-check | Question must be added to open-questions-register.md |
| **OB-10:** Every major design decision must generate or reference an ADR | steering: decision-policy.md | Decision cannot be approved without ADR |

---

## Section 7: Approval and Sign-Off

### 7.1 T0-02 Workshop Deliverables

This blueprint is complete when:

1. ✓ All OQ-COV-01 to OQ-COV-08 questions are answered and documented.
2. ✓ All 9 capability domains (CD-01 to CD-09) are mapped to current ECC capabilities.
3. ✓ Migration strategy (if applicable) is confirmed.
4. ✓ All Option B governance rules are acknowledged.
5. ✓ Sign-offs obtained from SAP RE Functional Consultant, ABAP Architect, and Project Governance Lead.

### 7.2 Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| SAP RE Functional Consultant | _________________ | _________________ | _______ |
| ABAP Architect | _________________ | _________________ | _______ |
| Project Governance Lead | _________________ | _________________ | _______ |

---

**Document Status:** DRAFT — Ready for T0-02 Workshop
**Next Action:** Complete all [HUMAN VALIDATION REQUIRED] sections and obtain sign-offs.
**Target Completion:** End of T0-02 Workshop (2026-04-XX)

