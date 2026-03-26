# Reclassification Engine Z — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-08 — Reclassification Engine Z

> **Option B Compliance:** CD-08 is a fully autonomous Z reclassification engine. It reads the Z amortization schedule (`ZRIF16_SCHED`, Domain 3) to determine the current/non-current split. It posts FI reclassification documents via standard FI BAPIs — not via RE-FX. Reclassification history is stored in `ZRIF16_RECLASSIF` (Domain 10).

---

## Business Objective

Implement a reliable, transparent reclassification engine that computes the current and non-current portions of the lease liability for each active contract and posts the required FI reclassification entries. The engine must operate per-contract, provide a preview before posting, and fail explicitly per contract with actionable error messages — directly addressing the silent failure pattern documented in pain point PP-C.

---

## Business Rationale

IFRS 16 requires the lease liability to be split into current (due within 12 months) and non-current (due beyond 12 months) portions on the balance sheet. This reclassification must be performed at each reporting period end. Under the legacy approach (PP-C), reclassification failures were silent — some contracts were skipped without any notification, leading to balance sheet misstatements. CD-08 eliminates this by enforcing explicit per-contract error reporting and providing full period-end visibility to the Lease Accountant.

---

## In-Scope (v1)

- Reclassification engine: reads `ZRIF16_SCHED` (Domain 3) per active contract for the target period
- Current portion: lease liability payments due within 12 months of the reporting date
- Non-current portion: lease liability payments due beyond 12 months of the reporting date
- Reclassification preview: display current/non-current split per contract before any posting
- Reclassification posting: FI documents for current/non-current split via FI BAPIs
- Approval gate: Finance Controller approval required before reclassification is posted
- Per-contract error reporting: explicit error with reason for every contract that cannot be reclassified
- Reclassification history table: `ZRIF16_RECLASSIF` (Domain 10) — per contract, per period
- Reversal capability: reverse a posted reclassification document with audit trail

---

## Out-of-Scope (v1)

- ROU asset reclassification (ROU assets do not have a current/non-current split under IFRS 16 — out of scope)
- Reclassification of interest payable (handled by CD-04 period-end batch)
- Automated reclassification without human approval (governance rule — non-negotiable)

---

## Actors

| Actor | Role |
|-------|------|
| Lease Accountant | Runs reclassification engine for a period; reviews per-contract results; resolves errors |
| Finance Controller | Reviews and approves the reclassification posting before FI documents are created |
| System (batch — optional) | Can run the reclassification computation (preview mode) automatically at period-end; posting requires human approval |
| Auditor | Read-only access to reclassification history per contract and per period |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-RC-01 | Lease Accountant | I can run the reclassification engine for a period and see the current/non-current split per contract before posting | Given active contracts with approved calculation runs exist, when the accountant runs the reclassification engine for a period, then the system displays a per-contract table showing: contract ID, total liability, current portion (12m), non-current portion, and any errors — before any FI document is created | PP-C | CD-08 |
| US-RC-02 | System | The reclassification engine posts FI documents for the current/non-current split automatically upon Finance Controller approval | Given the reclassification preview has been reviewed and approved by the Finance Controller, when the approval is given, then the system creates FI reclassification documents for all contracts in the approved run, logs results per contract in `ZRIF16_RECLASSIF`, and reports final status (posted, failed) | PP-C | CD-08 |
| US-RC-03 | Lease Accountant | I can see the reclassification history for any contract per period | Given a reclassification run has been posted for a period, when the accountant queries a specific contract and period, then the reclassification amounts (current/non-current) and FI document reference are shown from `ZRIF16_RECLASSIF` | — | CD-08 |
| US-RC-04 | System | Reclassification fails with explicit per-contract errors (not silently) — addressing PP-C pain point | Given a reclassification run is executed and contract X cannot be processed (e.g., no approved schedule, calculation run missing), when the run completes, then contract X appears in an error section with an explicit error reason, all other contracts are processed normally, and the error is logged in `ZRIF16_RECLASSIF` with error type and message | PP-C | CD-08 |

---

## Process Flow

1. Lease Accountant triggers reclassification engine for a reporting period and company code.
2. System selects all active contracts with status "Recognised" and no reclassification for the target period.
3. For each contract: reads `ZRIF16_SCHED` for the target period; computes current portion (payments in next 12 months) and non-current portion (remaining).
4. Results stored as "Preview" in `ZRIF16_RECLASSIF` (not yet posted).
5. Preview is displayed: per-contract table with amounts + error contracts listed separately with explicit error reasons.
6. Finance Controller reviews preview and approves.
7. On approval: system creates FI reclassification documents for all non-error contracts.
8. `ZRIF16_RECLASSIF` records updated to "Posted" with FI document reference.
9. Error contracts remain in "Preview — Error" status; Lease Accountant resolves and re-runs individually.

---

## Edge Cases

- Contract with no approved calculation run: explicit error message; contract skipped from posting; does NOT silently post zero.
- Contract where current portion equals total liability (lease ending within 12 months): entire liability classified as current; explicit display of this edge case.
- Contract already reclassified for the target period: system detects via `ZRIF16_RECLASSIF`; blocks duplicate run with explicit message.
- Period-end batch run while a reclassification run is in progress: system serialises; second run is queued.
- Finance Controller rejects the reclassification preview: entire run is cancelled; `ZRIF16_RECLASSIF` preview records deleted; Accountant must investigate and re-run.
- Reversal of a reclassification: system creates a reversal FI document and records the reversal in `ZRIF16_RECLASSIF`; the next period's run starts from a clean state.

---

## Accounting Implications

- IFRS 16 para 47-48: Balance sheet presentation — the lease liability must be split into current and non-current portions. The current portion is the amount of the liability that is expected to be settled within 12 months of the reporting date.
- The reclassification entry does not change the total lease liability — it only reclassifies between current and non-current balance sheet lines. The entry is: DR Non-Current Lease Liability / CR Current Lease Liability.
- The reclassification is a presentation adjustment — it is reversed at the beginning of the following period (or re-run at the next period end with updated amounts).
- GL accounts for current and non-current lease liability lines must be defined in `ZRIF16_ACCT_DET` before Phase 2 go-live.

---

## Integration Implications

- CD-03 (Valuation Engine): `ZRIF16_SCHED` is the source for current/non-current computation; approved calculation runs are a prerequisite.
- CD-04 (FI-GL Posting Engine): Reclassification uses the same FI posting infrastructure (BAPIs, account determination framework) as CD-04 but with its own posting type entries in `ZRIF16_ACCT_DET`.
- CD-09 (Reporting): Reclassification history (`ZRIF16_RECLASSIF`) feeds the rollforward reports showing opening balance, current/non-current split per period.

---

## UX Implications

- Reclassification preview must show a clear two-section layout: (1) contracts ready to post with amounts, and (2) contracts with errors with explicit per-contract error descriptions (PP-C pattern).
- Error contracts must have a "Resolve" guidance link — not just an error code.
- Finance Controller approval must be an explicit action — not a default "all approved if no rejection" pattern.
- Reclassification history per contract must be accessible from the contract display (link to `ZRIF16_RECLASSIF`).
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- CD-03 (Valuation Engine): Approved calculation runs and `ZRIF16_SCHED` — Phase 1 prerequisite.
- CD-04 (FI-GL Posting Engine): Account determination framework and BAPI posting infrastructure.
- Finance Controller: Must approve reclassification GL account assignments before Phase 2 go-live.
- docs/architecture/domain-data-model.md: Domain 10 schema for `ZRIF16_RECLASSIF`.

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-RC-01 | Is reclassification performed at each month-end, each quarter-end, or only at year-end? Confirm reporting frequency requirement. | Reclassification engine scheduling and `ZRIF16_RECLASSIF` period key design | Finance Controller + IFRS 16 Accountant |
| OQ-RC-02 | Should the reclassification be reversed automatically at period start, or is it a permanent reclassification with a new run each period? | Reversal design and period-end close sequence | FI Architect + IFRS 16 Accountant |
| OQ-RC-03 | What are the specific GL accounts for current and non-current lease liability reclassification in each company code? | `ZRIF16_ACCT_DET` configuration | Finance Controller |

---

## Design Risks

- **Risk:** Reclassification computation uses the wrong schedule data (e.g., pending rather than approved runs) → incorrect balance sheet split. Mitigation: engine reads only from approved calculation runs; explicit gate check before computation.
- **Risk:** Reclassification fails for all contracts in a period but no notification is sent → period-end close missed. Mitigation: run completion always produces a summary report with explicit counts (total contracts, posted, failed); notification sent to Lease Accountant.
- **Risk:** PP-C recurrence — some contracts silently skipped. Mitigation: all-or-explicit-error model enforced at engine design level; silent skipping is a blocked code pattern in the ABAP architecture spec.
