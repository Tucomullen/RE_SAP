# Reporting & Audit Z — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-09 — Reporting & Audit Z

> **Option B Compliance:** CD-09 reads exclusively from Z tables across all domains (Domains 1–10). RE-FX reporting functions are NOT used at runtime. All IFRS 16 rollforward, disclosure, and audit evidence data comes from the Z persistence layer. Contract-level reporting granularity is guaranteed by the Z schedule table `ZRIF16_SCHED`.

---

## Business Objective

Implement the complete reporting, rollforward, disclosure, and audit evidence layer for the IFRS 16 Z addon. This domain provides Finance Controllers, Lease Accountants, and Auditors with all data required for IFRS 16 disclosure notes, period-end close management, external audit support, and operational contract monitoring. Every report reads from the Z persistence layer with full traceability to source contracts, events, calculations, and FI documents.

---

## Business Rationale

IFRS 16 imposes significant disclosure requirements including lease liability rollforward, ROU asset rollforward, maturity analysis, and weighted average discount rate disclosure. In the legacy environment, these disclosures were compiled manually with high effort and error risk. CD-09 provides automated, contract-level reporting that satisfies both the disclosure requirements and the operational monitoring needs of the RE team — directly addressing PP-G (contract-level amortization visibility) and PP-F (FI document traceability per contract).

---

## In-Scope (v1)

- Lease liability rollforward report: by period, company code, and asset class
- ROU asset rollforward report: by period, company code, and asset class
- Amortization schedule per contract: contract-level, period-by-period (liability, interest, depreciation, payment, balance)
- Posting history per contract: all FI documents linked to a contract with amounts and references
- Audit evidence pack: downloadable per contract (creation, events, calculations, postings)
- Period-end close status dashboard: by company code and period (processed, failed, pending contracts)
- Contract portfolio summary: all active, exempt, and terminated contracts with key IFRS 16 data
- Export to spreadsheet: all reports exportable via ALV OO standard download

---

## Out-of-Scope (v1)

- Automated IFRS 16 disclosure note generation in document format (Phase 2 or separate project)
- External regulatory reporting submission (out of scope — Finance team responsibility)
- Real-time BI dashboard / SAP Analytics Cloud integration (Phase 3)
- Weighted average discount rate calculation across portfolio (Phase 2)

---

## Actors

| Actor | Role |
|-------|------|
| Finance Controller | Views rollforward reports; uses close status dashboard; approves disclosure figures |
| Lease Accountant | Views contract-level amortization schedule; monitors posting history per contract; resolves period-end errors |
| Auditor | Accesses audit evidence packs; reviews contract history, events, calculations, and postings |
| RE Contract Manager | Views contract portfolio summary; monitors contract status |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-RA-01 | Finance Controller | I can view a lease liability rollforward for any period, company code, and asset class | Given postings exist for the selected period, when the controller runs the rollforward report with selection criteria, then the report shows: opening balance, additions (initial recognitions), modifications, interest accrual, payments, terminations, closing balance — by asset class — and is exportable to spreadsheet | — | CD-09 |
| US-RA-02 | Finance Controller | I can view a ROU asset rollforward for any period | Given ROU assets exist for the selected period, when the controller runs the ROU rollforward report, then the report shows: opening carrying amount, additions, depreciation, modifications, derecognitions, closing carrying amount — by asset class — and is exportable to spreadsheet | — | CD-09 |
| US-RA-03 | Lease Accountant | I can view all posting history for a specific contract, linked to FI documents | Given a contract has FI documents, when the accountant views the posting history, then all FI documents are listed with: document type, posting date, period, debit/credit amounts, FI document number (clickable), and event reference — sourced from `ZRIF16_POST_LOG` (Domain 4) | PP-F | CD-09 |
| US-RA-04 | Auditor | I can download an audit evidence pack for any contract showing: creation, events, calculations, postings | Given a contract exists, when the auditor requests an audit evidence pack, then the system generates a structured document (PDF or ALV export) containing: contract header data, event timeline with before/after snapshots, all calculation runs with inputs snapshots, all FI documents with amounts and references | — | CD-09 |
| US-RA-05 | Finance Controller | I can view the period-end close status dashboard — processed, failed, pending contracts | Given the period-end batch has run for a period, when the controller opens the close status dashboard, then contracts are shown in three categories: Fully Processed (all period entries posted), Failed (one or more errors — with error summary), Pending (not yet processed) — with totals and drill-down to per-contract detail | PP-C | CD-09 |
| US-RA-06 | Lease Accountant | I can view the amortization schedule per contract (not just by asset class) so that I can verify the calculation at contract level | Given a contract has an approved calculation run, when the accountant opens the contract amortization schedule, then a period-by-period table shows: opening liability, interest accrual, lease payment, closing liability, and ROU depreciation — for the full lease term — sourced from `ZRIF16_SCHED` — and is exportable to spreadsheet | PP-G | CD-09 |

---

## Process Flow

**Rollforward Report:**
1. Finance Controller selects report: Lease Liability Rollforward or ROU Asset Rollforward.
2. Controller enters selection: period (from/to), company code, asset class (optional).
3. System reads from Z posting log (Domain 4) and Z schedule (Domain 3).
4. System groups amounts by movement type (additions, modifications, accruals, payments, terminations).
5. Rollforward table displayed; export to spreadsheet available.

**Audit Evidence Pack:**
1. Auditor selects a contract and requests an audit evidence pack.
2. System reads: contract header (Domain 1), event history (Domain 5), calculation runs (Domain 3), posting log (Domain 4).
3. System assembles the pack in a structured ALV or PDF layout.
4. Pack downloaded by Auditor; access logged in `ZRIF16_AUDIT`.

---

## Edge Cases

- Rollforward requested for a period with no postings: system returns zero balances (not an error); displays "No postings found for selected criteria" message.
- Contract with multiple calculation runs (remeasurements): audit evidence pack includes ALL calculation runs, not just the latest.
- Audit evidence pack requested for an Exempt contract: pack shows contract data and exemption rationale; no calculation or posting sections (exempt contracts have neither).
- Period-end close status dashboard queried before batch has run for a period: system shows all contracts as "Pending" — not as "Processed".
- Amortization schedule for a very long lease (e.g., 25-year property lease): report must handle large row counts without timeout; pagination or on-demand generation required.

---

## Accounting Implications

- IFRS 16 para 53-58: Disclosure requirements — lessee must disclose: depreciation charge by class, interest expense, short-term/low-value lease expense, total cash outflow, ROU asset additions, maturity analysis, weighted average discount rate.
- The rollforward reports (US-RA-01, US-RA-02) are the primary source for compiling these disclosures.
- All rollforward amounts must tie exactly to the FI general ledger — the reports must be reconcilable to FI-GL balances.
- Audit evidence packs must be sufficient for an external auditor to independently verify any contract's IFRS 16 accounting without requiring access to SAP transactions.

---

## Integration Implications

- Domain 1 (Contract Master): Contract header data in rollforward and audit evidence packs.
- Domain 3 (Valuation Results): `ZRIF16_SCHED` — primary source for amortization schedules and rollforward movement amounts.
- Domain 4 (Posting History): `ZRIF16_POST_LOG` — FI document references and amounts.
- Domain 5 (Contract Events): `ZRIF16_EVENTS` — event timeline for audit evidence packs.
- SAP FI-AA: ROU asset rollforward data must be reconcilable to FI-AA asset balances.
- CD-08 (Reclassification Engine): Reclassification history (`ZRIF16_RECLASSIF`, Domain 10) included in rollforward reports.

---

## UX Implications

- All rollforward reports must be exportable to Excel with a single click — finance teams need this for disclosure compilation.
- Audit evidence pack must be self-contained and readable by someone without SAP access (auditor use case).
- Period-end close status dashboard must use a traffic-light design (green/amber/red) — not a flat table.
- Amortization schedule must show the full lease term (not just the current period) with year-end subtotals.
- Contract amortization schedule must be accessible directly from the contract display (linked navigation) — addresses PP-G.
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- All upstream domains (CD-01 through CD-08): CD-09 reads from all Z tables across all domains; data quality in upstream domains directly affects reporting accuracy.
- IFRS 16 Accountant: Must validate that rollforward movement types match the disclosure note structure required by the company's IFRS 16 accounting policy.
- Finance Controller: Must confirm the rollforward presentation format (column structure, movement type labels) before Phase 2 development.
- FI Architect: Must confirm that FI-AA depreciation data is accessible in Z reports (FI-AA tables read directly, or via existing FI-AA reports).

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-RA-01 | What is the exact rollforward movement type structure required for the company's IFRS 16 disclosure note? (Standard vs. entity-specific presentation) | Rollforward report column design | IFRS 16 Accountant + Finance Controller |
| OQ-RA-02 | Should the audit evidence pack be generated as a PDF, an ALV export, or a Word document? Auditor tool preference? | Pack generation technology | Auditor representative + IT |
| OQ-RA-03 | Is a weighted average discount rate disclosure report required in Phase 1 or Phase 2? | Report scope for Phase 1 | Finance Controller + IFRS 16 Accountant |
| OQ-RA-04 | Does the FI-AA ROU asset rollforward data need to be pulled from FI-AA tables directly, or is there a standard FI-AA report that can be exported and reconciled? | ROU rollforward design | FI-AA Architect |
| OQ-RA-05 | What is the required data retention period for audit evidence packs? (Affects whether packs are generated on-demand or archived) | Pack storage and archiving design | Legal/DGO |

---

## Design Risks

- **Risk:** Rollforward amounts do not tie to FI-GL balances → disclosure figures are unreliable. Mitigation: rollforward reconciliation test is a mandatory UAT scenario before Phase 2 go-live.
- **Risk:** Audit evidence pack does not include all required elements → external audit qualification. Mitigation: pack contents reviewed and approved by Auditor representative in Phase 2 UAT.
- **Risk:** Amortization schedule for long leases causes ABAP program timeout → report unavailable for key contracts. Mitigation: schedule report uses asynchronous processing or pagination for lease terms > 5 years; tested with realistic data volumes in Phase 2 performance testing.
- **Risk:** PP-G pain point not fully resolved if schedule data is stored at aggregate level rather than line level. Mitigation: `ZRIF16_SCHED` design mandate (one row per period per contract) is a non-negotiable constraint from the master design (section 11.4).
