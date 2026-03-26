# Valuation Engine Z — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-03 — Valuation Engine Z

> **Option B Compliance:** CD-03 is a fully autonomous Z calculation engine. It reads exclusively from Z contract master (`ZRIF16_CONTRACT`, Domain 1) and Z lease object (`ZRIF16_LEASE_OBJ`, Domain 2). RE-FX is NOT used as an input to any calculation. All results are stored in Z tables (Domain 3).

---

## Business Objective

Implement the full IFRS 16 calculation engine in Z. This engine computes the initial lease liability, right-of-use asset, full amortization schedule, and all period entries (interest accrual, amortization, remeasurement adjustments) from Z contract master data. The engine stores all inputs, results, and run history in Z tables to provide complete reproducibility and audit traceability.

---

## Business Rationale

The valuation engine is the computational core of the IFRS 16 addon. Under Option B, it operates entirely on Z data — there is no dependency on RE-FX calculation or scheduling. The engine must support the full range of IFRS 16 measurement scenarios including initial recognition, lease modifications, remeasurements triggered by index changes, interest rate revisions, and country-specific calculation variants (e.g., advance payment contracts in Poland — OQ-08).

---

## In-Scope (v1)

- Initial lease liability calculation (present value of future lease payments at IBR)
- Right-of-use asset calculation (lease liability + initial direct costs + dismantling)
- Full amortization schedule generation (period-by-period: liability, interest, payment, closing balance)
- Short-term and low-value exemption — no schedule generated, no liability recognised
- Calculation run storage: inputs snapshot, results, run ID, approval status
- Simulation mode: calculate without committing results
- Remeasurement triggered by contract modification events (CD-06)
- Country-specific calculation flag: advance payment variant (Poland — OQ-08 pending confirmation)
- Calculation run approval gate (Lease Accountant must approve before posting is permitted)

---

## Out-of-Scope (v1)

- FI-GL posting of calculation results (CD-04 — specs/004-accounting-engine-z/)
- FI-AA ROU asset creation (CD-05 — specs/005-fi-aa-integration-z/)
- IFRS 16 disclosure aggregation (CD-09 — specs/009-reporting-audit-z/)
- Variable lease payment recalculation (Phase 2)

---

## Actors

| Actor | Role |
|-------|------|
| Lease Accountant | Reviews calculation inputs; approves or rejects calculation runs |
| System (batch) | Triggers period-end recalculation for all active contracts |
| System (event-driven) | Triggers remeasurement calculation on IFRS 16 modification events from CD-06 |
| Finance Controller | Escalation approver for calculation run disputes |
| Auditor | Read-only access to all calculation runs, inputs snapshots, and schedule data |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-VE-01 | Lease Accountant | I can trigger initial valuation for a contract and see the calculated liability, ROU, and full amortization schedule | Given an active contract with all mandatory IFRS 16 fields populated, when the accountant triggers initial valuation, then the system calculates lease liability (PV of payments at IBR), ROU asset, and stores the full schedule in `ZRIF16_SCHED` with status "Pending Approval" | — | CD-03 |
| US-VE-02 | Lease Accountant | I can simulate a calculation before committing it so that I can verify the result before it enters the approval flow | Given an active contract, when the accountant triggers simulation mode, then the system displays the full calculation result without writing any records to `ZRIF16_CALC` or `ZRIF16_SCHED`, and explicitly labels the output as "Simulation — Not Committed" | — | CD-03 |
| US-VE-03 | System | When a contract event triggers remeasurement (CD-06), a new calculation run is automatically initiated | Given an IFRS 16 modification event is recorded in CD-06, when the event is confirmed, then the system automatically creates a new calculation run for the affected contract using the updated contract data, with status "Pending Approval" | — | CD-03 |
| US-VE-04 | Lease Accountant | I can view the inputs snapshot for any historical calculation run so that I can reproduce and audit historical results | Given a calculation run exists in `ZRIF16_CALC`, when the accountant opens the run display, then all inputs used (lease payments, IBR, lease term, commencement date, country variant) are shown exactly as they were at the time of calculation | PP-G | CD-03 |
| US-VE-05 | Lease Accountant | I can apply country-specific calculation rules (e.g., advance payment flag for Poland) so that local accounting requirements are met | Given a contract with Poland company code and advance payment flag set, when the calculation engine runs, then it applies the advance payment variant (payment at period start rather than period end) and the schedule reflects this correctly | PP-K | CD-03 |

---

## Process Flow

1. Lease Accountant (or system event from CD-06) initiates a calculation run for a contract.
2. System reads all inputs from `ZRIF16_CONTRACT` (Domain 1) — pre-flight validates completeness.
3. System creates a calculation run header in `ZRIF16_CALC` with status "Running".
4. System stores the inputs snapshot in `ZRIF16_CALCI` (immutable — written once).
5. System computes: lease liability (PV), ROU asset, full amortization schedule.
6. Schedule is written to `ZRIF16_SCHED` (period-by-period, contract ID as key).
7. Calculation run status set to "Pending Approval".
8. Lease Accountant reviews the run: inputs snapshot, schedule, summary totals.
9. Accountant approves → status "Approved"; downstream CD-04 posting is now permitted.
10. Accountant rejects → status "Rejected" with rejection reason; no posting permitted.

---

## Edge Cases

- Contract missing IBR at time of calculation: system blocks with pre-flight error; IBR is a mandatory input.
- Calculation run triggered on an Exempt contract: system blocks with explicit message.
- Two simultaneous calculation runs triggered for the same contract: system enforces locking; second run is queued or rejected with explicit message.
- Remeasurement run where new lease liability is lower than previous: system handles negative adjustment correctly (gain on modification).
- Advance payment variant selected for a contract with no advance payment amount: system warns (soft validation, not hard block).
- Period-end batch fails for a subset of contracts: system reports per-contract errors with explicit reason; does not silently skip (addresses PP-C pattern).

---

## Accounting Implications

- IFRS 16 para 26: Initial measurement of lease liability = PV of future lease payments discounted at IBR (or implicit rate if determinable).
- IFRS 16 para 23-25: ROU asset = lease liability + initial direct costs + lease incentives paid + estimated dismantling costs.
- IFRS 16 para 36-46: Subsequent measurement — effective interest method for liability; straight-line depreciation for ROU asset (unless another basis is more representative).
- IFRS 16 para 39-46: Modification accounting — remeasurement events must be classified (new lease, scope increase, other modification) by the Lease Accountant before the valuation engine can compute the adjustment.
- IBR is a human judgment — must be approved by IFRS 16 Accountant before use in any run (human approval gate, non-negotiable).

---

## Integration Implications

- CD-01 (Contract Master): All calculation inputs read from `ZRIF16_CONTRACT`; schema must be aligned before Phase 1 build.
- CD-04 (FI-GL Posting Engine): Only approved calculation runs may be posted; `ZRIF16_CALC` status "Approved" is the gate.
- CD-05 (FI-AA Asset Engine): ROU asset amount from CD-03 is the input for initial FI-AA asset capitalization.
- CD-06 (Contract Event Engine): Modification events from CD-06 trigger remeasurement runs in CD-03.
- CD-09 (Reporting): `ZRIF16_SCHED` (schedule table) is the source for rollforward reports and disclosure aggregation.

---

## UX Implications

- Calculation run display must show: inputs snapshot (all parameters), summary totals (liability, ROU, total payments), and full amortization schedule in tabular format.
- Simulation mode must be visually distinct from committed runs (clear "Simulation" watermark or banner).
- Approval/rejection must require explicit Lease Accountant action — no auto-approval.
- Schedule export to spreadsheet must be available (ALV OO standard download) — addresses PP-G.
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- CD-01 (Contract Master): Contract master schema must be finalised before calculation engine development begins.
- IBR configuration: IBR values must be maintainable in `ZRIF16_PARAM` before any calculation can run.
- docs/architecture/domain-data-model.md: Domain 3 schema for valuation results.
- IFRS 16 Accountant sign-off on calculation methodology before Phase 1 build (human approval gate).

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-VE-01 | What is the full list of calculation variants required beyond standard amortization and advance payment (Poland)? | Calculation engine strategy pattern design | IFRS 16 Accountant + Project Governance Lead |
| OQ-VE-02 | How is the IBR determination process managed — is there a single IBR per currency/term or a per-contract IBR? | IBR input design and `ZRIF16_PARAM` schema | IFRS 16 Accountant + Treasury |
| OQ-VE-03 | Is variable lease payment recalculation in scope for v1 or Phase 2? | Calculation engine scope | Project Governance Lead |
| OQ-VE-04 | What precision (decimal places) is required for present value calculations? | ABAP DECFLOAT vs. standard CURR type decision | ABAP Architect + IFRS 16 Accountant |

---

## Design Risks

- **Risk:** IBR determination process not formalised before Phase 1 build → calculation engine cannot be tested with realistic data. Mitigation: IBR process is a Phase 0 gate item (OQ-03 from master design).
- **Risk:** Calculation engine precision errors due to ABAP type selection → audit failures. Mitigation: precision requirements confirmed with IFRS 16 Accountant before ABAP class design.
- **Risk:** Inputs snapshot not written atomically with calculation run → audit gap. Mitigation: inputs snapshot write and calculation run header write are in the same database commit unit (LUW).
