# Accounting Engine Z (FI-GL) — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-04 — Accounting Engine Z (FI-GL)

> **Option B Compliance:** CD-04 posts directly to FI-GL via SAP FI BAPIs. RE-FX accounting functions are NOT used at runtime. All FI documents are generated entirely from Z calculation data. Account determination is driven by Z configuration tables, not RE-FX Customizing.

---

## Business Objective

Implement a direct FI-GL posting engine that generates all IFRS 16 accounting entries from approved Z calculation runs. The engine must support initial recognition, period-end interest accrual, amortization, remeasurement adjustments, and lease termination entries. Every FI document generated must carry the Z contract ID and Z calculation run ID as reference data for complete traceability.

---

## Business Rationale

Under Option B, FI-GL accounting is driven entirely by the Z addon. There is no dependency on RE-FX automatic account determination or posting logic. The posting engine must interface directly with SAP FI via standard BAPIs (BAPI_ACC_DOCUMENT_POST or equivalent), ensuring that all IFRS 16 entries are posted with full audit trail, reversal capability, and account determination transparency. This directly addresses PP-B (unexplained special postings) and PP-F (missing FI document context).

---

## In-Scope (v1)

- Initial recognition posting: lease liability credit, ROU asset debit, initial direct costs
- Period-end posting batch: interest accrual (debit interest expense, credit lease liability), amortization (debit depreciation, credit accumulated depreciation ROU asset)
- Reversal of posted FI documents with full audit trail
- Account determination configuration table (`ZRIF16_ACCT_DET`) — posting keys, GL accounts by posting type and company code
- Posting preview (simulation): display FI document lines before posting without creating the document
- FI document reference fields: Z contract ID + calculation run ID stored in assignment or reference field
- Posting authorization: Finance Controller must approve initial recognition postings
- Posting log: all posting events stored in `ZRIF16_POST_LOG` (Domain 4)

---

## Out-of-Scope (v1)

- FI-AA depreciation posting (CD-05 — specs/005-fi-aa-integration-z/)
- Reclassification postings — current vs. non-current split (CD-08 — specs/008-reclassification-engine-z/)
- Lease termination / derecognition posting (Phase 2)
- Multi-currency posting (OQ-07 — pending confirmation for v1 scope)

---

## Actors

| Actor | Role |
|-------|------|
| Finance Controller | Reviews and approves initial recognition postings; approves period-end batch |
| Lease Accountant | Triggers and monitors posting runs; reviews FI document output; initiates reversals |
| System (batch) | Executes period-end interest accrual and amortization postings for all active contracts |
| Auditor | Read-only access to posting log, FI document list per contract, account determination |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-AE-01 | Finance Controller | I can preview (simulate) the FI document lines before approving a posting so that I can verify the accounting entries before they hit the ledger | Given an approved calculation run exists, when the controller triggers posting preview, then the system displays the full FI document line layout (posting key, GL account, amount, text) without creating a real FI document, and the preview is labelled "Simulation — Not Posted" | PP-B | CD-04 |
| US-AE-02 | Finance Controller | I can approve and trigger the initial recognition FI posting so that the lease liability and ROU asset are recognised in FI-GL | Given a posting preview has been reviewed and approved, when the controller triggers the posting, then the system creates the FI document via BAPI, stores the FI document number in `ZRIF16_POST_LOG`, and updates the contract status to "Recognised" | — | CD-04 |
| US-AE-03 | System | The period-end batch automatically creates interest accrual and amortization FI documents for all active contracts | Given the period-end batch is triggered for a period, when the batch runs, then it processes all active contracts in `ZRIF16_CONTRACT`, creates FI documents for each, and logs results (success/fail) per contract in `ZRIF16_POST_LOG` | PP-C | CD-04 |
| US-AE-04 | Lease Accountant | I can reverse a previously posted FI document with full audit trail so that corrections can be made with complete transparency | Given a posted FI document exists, when the accountant initiates a reversal, then the system creates a reversal FI document, links it to the original in `ZRIF16_POST_LOG`, and both documents reference the Z contract ID | PP-F | CD-04 |
| US-AE-05 | System | Every FI document generated contains the Z contract ID and Z calculation run ID as reference data | Given any IFRS 16 FI posting is created, when the FI document is posted, then the Z contract ID is stored in the FI document assignment field (or reference field) and the Z calculation run ID is stored in the document header text or item text | PP-B, PP-F | CD-04 |
| US-AE-06 | Lease Accountant | I can view all FI documents generated for a specific contract so that the posting history is transparent | Given a contract exists with posted FI documents, when the accountant opens the contract posting history view, then all FI documents (initial recognition, accruals, amortizations, reversals) are listed with date, type, amount, and FI document number | PP-F | CD-04 |

---

## Process Flow

**Initial Recognition:**
1. Lease Accountant triggers posting preview for an approved calculation run (CD-03).
2. System reads account determination from `ZRIF16_ACCT_DET` and builds FI document lines.
3. Preview is displayed to Finance Controller.
4. Finance Controller approves.
5. System calls FI BAPI (BAPI_ACC_DOCUMENT_POST) with the document lines.
6. FI document number is stored in `ZRIF16_POST_LOG`; contract status updated.

**Period-End Batch:**
1. Finance Controller triggers period-end batch for a period and company code.
2. System selects all active contracts with no period entry for the target period.
3. For each contract: reads schedule from `ZRIF16_SCHED`, builds FI lines, calls BAPI.
4. Results logged per contract in `ZRIF16_POST_LOG`.
5. Batch report shows: posted, failed (with per-contract error), already processed.

---

## Edge Cases

- Attempt to post when no approved calculation run exists: system blocks with explicit message.
- Period-end batch failure for a subset of contracts: per-contract error logged; successful contracts are posted; failed contracts re-processable individually (addresses PP-C).
- Attempt to post the same period twice: system detects duplicate via `ZRIF16_POST_LOG`; blocks with explicit message.
- Account determination missing for a posting type/company code combination: system blocks with configuration error; does not post with wrong accounts.
- Reversal of a document that has already been reversed: system blocks.
- FI BAPI returns an error: system logs the error per contract in `ZRIF16_POST_LOG`; does not silently fail.

---

## Accounting Implications

- IFRS 16 para 26-28: Initial recognition — DR ROU Asset / CR Lease Liability at present value; plus initial direct costs and dismantling if applicable.
- IFRS 16 para 36: Subsequent measurement of liability — effective interest method; interest accrual each period.
- IFRS 16 para 31: ROU asset depreciation — straight-line over the shorter of lease term and useful life.
- All postings must comply with the parallel ledger requirements confirmed in OQ-02 (main ledger vs. IFRS ledger).
- Account determination must be reviewed and approved by Finance Controller before Phase 1 go-live.

---

## Integration Implications

- CD-03 (Valuation Engine): Only runs with status "Approved" can be posted; `ZRIF16_CALC.STATUS` gate.
- CD-05 (FI-AA Asset Engine): Initial recognition in CD-04 triggers ROU asset creation in CD-05; the two must be coordinated in the same processing unit.
- CD-08 (Reclassification Engine): Reclassification postings use the same posting infrastructure but different account determination entries.
- SAP FI: BAPI_ACC_DOCUMENT_POST (or BAPI_ACC_GL_POSTING_POST) — exact BAPI selection to be confirmed with FI Architect (OQ-02).

---

## UX Implications

- Posting preview must clearly show: GL account, description, posting key, amount, cost center, profit center — not just raw line items.
- Every FI document in the contract posting history view must be clickable (navigate to FI document display).
- Period-end batch must show a clear traffic-light status dashboard (green/amber/red per contract) — not just a log file.
- Explanation texts for posted documents must be accessible from the contract posting history view (PP-B pattern — design.md section 11.2).
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- CD-03 (Valuation Engine): Approved calculation runs are a prerequisite for any posting.
- CD-05 (FI-AA Asset Engine): Initial recognition sequence must be coordinated.
- OQ-02 (Master Design): Parallel ledger decision must be made before account determination design is locked.
- FI Architect: Must confirm BAPI selection and document number range assignment.
- Finance Controller: Must approve account determination configuration before Phase 1 go-live.

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-AE-01 | Which FI BAPI should be used for IFRS 16 postings — BAPI_ACC_DOCUMENT_POST, BAPI_ACC_GL_POSTING_POST, or direct FI_DOCUMENT_CREATE? | Core posting engine design | FI Architect |
| OQ-AE-02 | Where in the FI document should the Z contract ID and calculation run ID be stored (assignment field, reference, item text)? | Traceability design and search capability | FI Architect + Auditor representative |
| OQ-AE-03 | Is a document number range required exclusively for IFRS 16 documents, or can they share a standard range? | FI configuration | FI Architect |
| OQ-AE-04 | Multi-currency: in scope for v1? (OQ-07 from master design — pending) | Account determination and BAPI parameters | IFRS 16 Accountant + FI Architect |

---

## Design Risks

- **Risk:** BAPI selection not validated until Phase 1 development → integration fails late. Mitigation: BAPI prototype/spike is a Phase 0 prerequisite task.
- **Risk:** Account determination table designed without Finance Controller input → wrong GL accounts used in production. Mitigation: account determination sign-off is a mandatory Phase 0 gate.
- **Risk:** Period-end batch processes contracts partially (some succeed, some fail silently) → ledger imbalance. Mitigation: all failures are per-contract explicit errors with no silent skipping (PP-C pattern enforcement).
