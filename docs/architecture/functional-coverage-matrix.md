# Functional Coverage Matrix — ECC to Option B
**Version:** 1.0 | **Date:** 2026-03-26 | **Status:** Draft — Requires SAP Functional Consultant review (T0-02 revised)

> This matrix maps every known functional capability of the current ECC lease management solution to its Option B replacement. It is the governance artifact that ensures no critical business functionality is silently lost during the migration from RE-FX (or manual spreadsheets) to the Z addon.
>
> **Owner:** ECC Coverage Analyst + Lease Accountant + RE Contract Manager
> **Updated:** Whenever a new ECC capability is discovered or an Option B design decision is made.

---

## Section A — Contract Master / Lease Master Data

| # | Current ECC Capability | Current Implementation | Option B Domain | Target Implementation | Improvement | Auto. Opp. | Priority | Risk if Omitted | Notes / Open Questions |
|---|----------------------|----------------------|-----------------|----------------------|-------------|-----------|----------|-----------------|----------------------|
| A-01 | Company code assignment | RE-FX contract header | CD-01 | Z contract master | None — replicated | None | Must | Contracts not company-segregated | |
| A-02 | Contract type (land / building / vehicle / equipment) | RE-FX contract category + object type | CD-01 + CD-02 | Z contract header + Z lease object master | Simplified classification | Validation auto | Must | Wrong IFRS 16 classification | Confirm all current contract types used |
| A-03 | Lessor (vendor/creditor) | RE-FX business partner (BP) | CD-01 | Z contract: vendor number (SAP vendor master FK) | None | Vendor lookup | Must | Payment matching broken | |
| A-04 | Leased asset description | RE-FX object hierarchy | CD-02 | Z lease object master (simplified) | No hierarchy overhead | None | Must | Object not classifiable | |
| A-05 | Start date / end date | RE-FX contract valid from/to | CD-01 | Z contract master dates | None | Date validation | Must | Wrong lease term → wrong IFRS 16 |  |
| A-06 | Non-cancellable period | Manually derived from RE-FX dates | CD-01 | Explicit field in Z contract | **Improvement: explicit field** | IFRS 16 term wizard | Must | Wrong IFRS 16 liability | PP-A, PP-L pain points |
| A-07 | Renewal options | RE-FX option date fields | CD-01 | Z contract: renewal option flag + probability | **Improvement: structured option analysis** | Probability prompt | Must | Wrong lease term | IFRS 16 REASONABLY CERTAIN judgment |
| A-08 | Termination options | RE-FX notice/termination dates | CD-01 | Z contract: termination option flag + probability | Same | Same | Must | Wrong lease term | |
| A-09 | Payment amount and frequency | RE-FX condition types | CD-01 | Z payment schedule table | **Improvement: explicit Z structure** | Auto-schedule generation | Must | Wrong liability calculation | No dependency on condition type config |
| A-10 | Payment in advance flag | RE-FX condition purpose | CD-01 | Explicit Z flag on payment schedule | **Improvement: visible, no config interpretation** | None | Must | Wrong first payment discounting | PP-K for Poland advance payments |
| A-11 | Currency (payment + reporting) | RE-FX contract currency | CD-01 | Z contract: payment currency + reporting currency | None | FX rate auto-fetch | Must | Wrong liability in reporting currency | PP-I |
| A-12 | Cost center assignment | RE-FX partner/object assignment | CD-01 | Explicit Z field on contract | **Improvement: always visible** | CC validation | Must | Wrong CO assignment on postings | |
| A-13 | Profit center assignment | RE-FX partner/object assignment | CD-01 | Explicit Z field on contract | Same | PC validation | Must | Segment reporting errors | |
| A-14 | Vendor invoice matching | FI-AP + RE-FX | CD-04 | Z posting log ↔ FI-AP read (Phase 2) | Phase 2 | Matching automation | Should | Payment not tracked | Phase 2 — confirm scope |
| A-15 | Contract document attachments | SAP GOS on RE-FX object | CD-07 | Z doc reference + SAP GOS on Z contract | None | None | Should | Audit evidence incomplete | |
| A-16 | Mass contract creation | Not supported (manual only) | CD-01 | Z mass upload (Excel/CSV + guided UI) | **Major improvement: new capability** | Full automation | Must | Portfolio onboarding impossible | New capability under Option B |

---

## Section B — IFRS 16 / Accounting Valuation

| # | Current ECC Capability | Current Implementation | Option B Domain | Target Implementation | Improvement | Auto. Opp. | Priority | Risk if Omitted | Notes |
|---|----------------------|----------------------|-----------------|----------------------|-------------|-----------|----------|-----------------|-------|
| B-01 | Initial lease liability | Manual spreadsheet or Z calc | CD-03 | Z valuation engine: PV of future payments | **Improvement: automated, auditable** | Full auto | Must | Liability wrong or manual error | Core IFRS 16 |
| B-02 | Right-of-use asset | Manual spreadsheet | CD-03 | Z valuation: ROU = liability + initial direct costs + prepaid | Same | Full auto | Must | Balance sheet wrong | |
| B-03 | Discount rate (IBR) | Manual input / spreadsheet | CD-03 | Z: IBR config table + contract-level override | **Improvement: governance-controlled** | Rate table auto-apply | Must | Wrong PV → wrong liability | IFRS 16 judgment — human validation required |
| B-04 | Amortization schedule (liability) | Spreadsheet | CD-03 | Z schedule table: period / interest / payment / balance | Full auto, audit trail | Full auto | Must | No period-end data | |
| B-05 | Amortization schedule (ROU) | Spreadsheet | CD-03 | Z schedule: period / amortization / balance | Full auto | Full auto | Must | No depreciation data | |
| B-06 | Interest accrual (monthly) | Manual FI posting | CD-04 | Z accounting engine → FI BAPI auto-post | **Major improvement** | Full auto | Must | Interest not posted | |
| B-07 | Advance payments / prepaid | Complex RE-FX config | CD-03 | Explicit Z field; included in ROU at commencement | **Improvement: explicit** | Auto-include | Must | Wrong ROU asset | PP-K |
| B-08 | Initial direct costs | Not currently tracked | CD-03 | Z field on contract; add to ROU | **New capability** | None | Should | Incomplete ROU | Confirm if in scope |
| B-09 | Rent increases (scheduled) | RE-FX condition steps | CD-03 | Z payment schedule: stepped amounts per period | **Improvement: no condition config needed** | Auto-schedule | Must | Wrong schedule | |
| B-10 | Remeasurement (modification) | Manual spreadsheet | CD-03 + CD-06 | Z event triggers new calc run; new schedule from event date | **Major improvement** | Auto-trigger | Must | Unmeasured modifications | PP-E |
| B-11 | Reassessment (option exercise) | Manual spreadsheet | CD-03 + CD-06 | Same as remeasurement, event type = OPTION_EXERCISED | Same | Auto-trigger | Must | Wrong lease term | |
| B-12 | Linearization | RE-FX or manual | CD-03 | Z valuation: straight-line option for stepped rents | Confirm if required by accounting policy | Conditional | Should | Non-IFRS compliant posting | Confirm with accountant — T0-01 |
| B-13 | Early termination | Manual + RE-FX | CD-06 + CD-04 | Z event: TERMINATED_EARLY → derecognition calculation → FI posting | Full automation | Full auto | Must | Liability not derecognized | |
| B-14 | Purchase option | Not in current RE-FX solution | CD-06 | Z event: PURCHASE_OPTION_EXERCISED → ROU becomes owned asset | New capability | Auto-trigger | Should | Lease continues incorrectly | Confirm if in scope |
| B-15 | Impairment / deterioration | Not in current solution | CD-03 | Z: impairment flag on ROU; FI posting for impairment write-down | New capability | None | Later | Under-valued ROU | Phase 3 |
| B-16 | Local GAAP parallel | RE-FX parallel ledger or manual | CD-04 | Z posting engine: support multi-ledger (if configured) | Preserves if needed | Conditional | Should | Local GAAP non-compliant | Confirm parallel ledger setup — T0-04 |
| B-17 | Country-specific rules (Poland) | Manual workaround | CD-03 | Z: country-specific valuation rule flag on company code | **Improvement: systematic** | Auto-apply | Should | Poland contracts wrong | PP-K |

---

## Section C — Direct Accounting Integration

| # | Current ECC Capability | Current Implementation | Option B Domain | Target Implementation | Improvement | Auto. Opp. | Priority | Risk if Omitted |
|---|----------------------|----------------------|-----------------|----------------------|-------------|-----------|----------|-----------------|
| C-01 | Initial recognition FI document | RE-FX accounting engine or manual | CD-04 | Z engine → `BAPI_ACC_DOCUMENT_POST` | **Major improvement: direct, traceable** | Full auto | Must | Balance sheet not updated |
| C-02 | Interest accrual FI document | Manual posting | CD-04 | Z batch → FI BAPI auto | Full auto | Full auto | Must | P&L understated |
| C-03 | Amortization / depreciation FI | FI-AA depreciation run (manual trigger) | CD-05 | Z activates FI-AA depreciation + links to contract | Improved traceability | Auto-activation | Must | ROU not amortized |
| C-04 | Payment / cash flow FI | FI-AP standard + manual | CD-04 | Z records payment event; FI-AP matching Phase 2 | Phase 2 | Partial | Must | Liability not reduced |
| C-05 | Posting simulation | Not available | CD-04 | Z simulation mode: show FI lines without posting | **New capability** | Full auto | Must | Users can't preview impact |
| C-06 | Posting reversal | Manual FI reversal | CD-04 | Z reversal event → FI reversal BAPI | **Improvement: traceable** | Full auto | Must | No clean reversal path |
| C-07 | Posting error handling | None — silent failures | CD-04 | Z error log per contract + reprocessing queue | **Major improvement** | Auto-retry | Must | Silent failures — audit risk |
| C-08 | FI document ↔ contract traceability | None | CD-04 + CD-09 | Z contract ID in FI document reference fields | **New: full traceability** | Auto-embed | Must | Can't audit postings to contracts |

---

## Section D — Monthly / Periodic Operations

| # | Current ECC Capability | Current Implementation | Option B Domain | Target Implementation | Auto. Opp. | Priority |
|---|----------------------|----------------------|-----------------|----------------------|-----------|----------|
| D-01 | Monthly accrual batch | Semi-manual (REFX programs) | CD-04 | Z batch job: auto-calculate and post all active contracts | Full auto | Must |
| D-02 | Lease liability interest processing | Manual or RE-FX period-end | CD-04 | Z batch: interest accrual for all contracts in period | Full auto | Must |
| D-03 | ROU amortization activation | FI-AA depreciation run | CD-05 | Z: activate FI-AA depreciation per contract per period | Auto | Must |
| D-04 | Current/non-current reclassification | ZRE009 (fragile, PP-C) | CD-08 | Z reclassification engine: reliable, transparent, per-contract | Full auto + preview | Must |
| D-05 | Reversal logic | Manual FI reversal | CD-04 | Z reversal event type + FI reversal BAPI | Auto | Must |
| D-06 | Period-end controls | None | CD-09 | Z period-end checklist: all contracts processed / errors / pending | Dashboard | Must |
| D-07 | Reconciliation output | None — manual Excel | CD-09 | Z reconciliation report: liability rollforward per contract | Full auto | Must |

---

## Section E — Contract Change Event Management

| # | Current ECC Capability | Current Implementation | Option B Domain | Target Implementation | Priority |
|---|----------------------|----------------------|-----------------|----------------------|----------|
| E-01 | Contract extension | RE-FX contract change (PP-J) | CD-06 | Z event: EXTENDED — recalculate from extension date | Must |
| E-02 | Novation (change of lessor) | RE-FX amendment | CD-06 | Z event: NOVATED — update vendor + remeasure | Must |
| E-03 | Cost center / profit center reassignment | Manual RE-FX assignment change | CD-06 | Z event: CC_CHANGED — update contract + re-assign future postings | Must |
| E-04 | Partial scope change | Complex RE-FX | CD-06 | Z event: SCOPE_CHANGED — recalculate based on new scope | Should |
| E-05 | Effective-date recalculation | Manual spreadsheet | CD-06 + CD-03 | Z: event date → new calc run from that date forward | Must |
| E-06 | Historical event versions | None in current solution | CD-06 | Z: non-destructive event journal — all versions preserved | Must |
| E-07 | Extension / rescission out-of-sequence guard | None (PP-J) | CD-06 | Z: event sequencing validation — guided workflow enforcement | Must |

---

## Section F — Procurement / Upstream Integration

| # | Current ECC Capability | Current Implementation | Option B Domain | Target Implementation | Priority |
|---|----------------------|----------------------|-----------------|----------------------|----------|
| F-01 | Contract draft from PO | None — manual | CD-07 | Z: PO-to-contract draft generation pattern | Should |
| F-02 | Error log and reprocessing | None | CD-07 | Z: source integration error queue + retry | Should |
| F-03 | Traceability: PO → contract | None | CD-07 + CD-06 | Z integration reference: PO number linked to contract | Should |
| F-04 | Reusable framework | None — vehicle-specific workaround | CD-07 | Z: configurable source integration framework | Should |

---

## Section G — Reporting / Control / Audit

| # | Current ECC Capability | Current Implementation | Option B Domain | Target Implementation | Priority |
|---|----------------------|----------------------|-----------------|----------------------|----------|
| G-01 | Active contracts list | RE-FX report (non-user-friendly) | CD-09 | Z CDS view: active contracts with IFRS 16 status | Must |
| G-02 | Maturity / expiry report | None | CD-09 | Z: contracts expiring in N months | Must |
| G-03 | Liability rollforward | None — manual Excel | CD-09 | Z: auto rollforward from schedule table | Must |
| G-04 | ROU rollforward | None — manual Excel | CD-09 | Z: auto ROU rollforward linked to FI-AA | Must |
| G-05 | Posting history by contract | FBL3N (not contract-linked) | CD-09 | Z: contract-level posting history from ZRIF16_POST_LOG | Must |
| G-06 | Pending modifications not posted | None | CD-09 | Z: dashboard — events without resulting postings | Must |
| G-07 | Exception management | None | CD-09 | Z: exception list — errors, pending items, overdue reviews | Must |
| G-08 | Contract-level amortization view | Only by asset class (PP-G) | CD-09 | Z: per-contract amortization report from schedule table | Must |
| G-09 | Disclosure pack output | Manual Excel | CD-09 | Z: structured disclosure data + export (Phase 2) | Should |
| G-10 | Audit evidence pack | None | CD-09 + CD-04 | Z: audit evidence per contract — events + calculations + FI docs | Must |

---

## Coverage Summary

| Domain | Must items | Should items | Later items | Total |
|--------|-----------|-------------|-------------|-------|
| CD-01 Contract Master | 14 | 2 | 0 | 16 |
| CD-02 Lease Object | 2 | 0 | 0 | 2 |
| CD-03 Valuation Engine | 12 | 3 | 1 | 16 |
| CD-04 Accounting Engine | 8 | 0 | 0 | 8 |
| CD-05 Asset Engine | 2 | 0 | 0 | 2 |
| CD-06 Contract Events | 7 | 1 | 0 | 8 |
| CD-07 Procurement Integration | 0 | 4 | 0 | 4 |
| CD-08 Reclassification | 3 | 0 | 0 | 3 |
| CD-09 Reporting & Audit | 8 | 2 | 0 | 10 |
| **Total** | **56** | **12** | **1** | **69** |

---

## Open Coverage Questions

| # | Question | Owner | Blocks |
|---|---------|-------|--------|
| OQ-COV-01 | Are there RE-FX contract types used by the client that don't fit CD-01/CD-02 classification? | T0-02 Workshop | Domain 1+2 design |
| OQ-COV-02 | Is linearization (B-12) required by the client's accounting policy? | T0-01 Accounting Workshop | CD-03 design |
| OQ-COV-03 | Is FI-AP matching (A-14) in scope for Phase 1 or Phase 2? | Project Governance Lead | CD-04 scope |
| OQ-COV-04 | Are initial direct costs (B-08) tracked in current ECC solution? | Lease Accountant | CD-03 design |
| OQ-COV-05 | Is the Poland advance payment rule the only country-specific rule, or are there others? | Local Finance Users | CD-03 design |
| OQ-COV-06 | Is parallel ledger for local GAAP currently active? | FI Architect | CD-04 design |
| OQ-COV-07 | Is procurement/PO-to-contract pattern (Section F) in scope for this project? | Project Governance Lead | CD-07 scope |
| OQ-COV-08 | Are there vehicle fleet leases with specific attributes not covered by current Z object model? | RE Contract Manager | CD-02 design |
