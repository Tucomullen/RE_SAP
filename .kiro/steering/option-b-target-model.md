---
inclusion: always
description: Option B target operating model — the Z addon fully replaces RE-FX as system of record; non-negotiable architectural constraints and the 9 capability domains.
---

# Option B — Official Target Operating Model

## THIS IS THE ARCHITECTURAL LAW OF THE PROJECT

**Decision Date:** 2026-03-26
**Status:** APPROVED — Non-negotiable architectural constraint
**ADR Reference:** ADR-006 (see docs/governance/decision-log.md)
**Overrides:** All previous assumptions about RE-FX as system of record

---

## Option B: The Z Addon Fully Replaces SAP RE-FX as the Contract System of Record

The target solution is the construction of a **standalone Z Lease Management Addon** for SAP ECC that:

1. **Stores all contract master data exclusively in Z tables** — not in RE-FX contract objects, not in RECN* tables, not in VICNCOND, not in VIOBJHEAD.
2. **Presents all end-user interactions through custom Z/Fiori-ready screens** — users never navigate to RE-FX transactions.
3. **Calculates all IFRS 16 valuation results inside Z logic** — no dependency on RE-FX valuation engine.
4. **Posts all FI-GL accounting documents directly** using standard SAP FI BAPIs/services — no dependency on RE-FX accounting engine.
5. **Creates and manages FI-AA assets (ROU) directly** using standard SAP FI-AA BAPIs/services — no dependency on RE-FX asset integration.
6. **Manages the full contract lifecycle (creation, modification, extension, termination, novation)** inside Z event structures — RE-FX change events do not drive the IFRS 16 lifecycle.

---

## What RE-FX Is NOT in This Project

| RE-FX Capability | Status in Option B |
|------------------|--------------------|
| Contract repository | NOT USED — Z tables replace this |
| Contract condition types | NOT USED — Z payment model replaces this |
| Cash flow projection engine | NOT USED — Z valuation engine replaces this |
| Contract modification tracking | NOT USED — Z event engine replaces this |
| Valuation / IFRS 16 accounting engine | NOT USED — Z valuation engine replaces this |
| FI/CO posting generation | NOT USED — direct FI BAPIs replace this |
| FI-AA asset integration | NOT USED — direct FI-AA BAPIs replace this |
| Option/termination date management | NOT USED — Z contract lifecycle replaces this |
| RE-FX user transactions (RECN, etc.) | NOT USED — Z workspace transactions replace these |

**RE-FX may exist in the system landscape but it is not the operational core.** If a client has existing RE-FX contracts, those are handled via a one-time migration/read-out, not ongoing dependency.

---

## What SAP ECC Still Provides (Read-Only or BAPI Integration)

The addon integrates with SAP ECC standard modules **only** for the following purposes:

| Module | Integration | Direction | Purpose |
|--------|-------------|-----------|---------|
| FI-GL (New GL) | Standard BAPIs / posting FMs | **WRITE** | Create lease liability, ROU recognition, interest accrual, amortization, payment postings |
| FI-AA | Standard BAPIs (e.g., BAPI_FIXEDASSET_CHANGE, create sub-asset) | **WRITE** | Create and manage ROU asset sub-numbers; trigger depreciation |
| CO (Controlling) | Account assignment on postings | **WRITE** | Cost center / profit center on all lease accounting documents |
| FI-AP | Existing invoice / payment matching | **READ** | Match cash lease payments to existing vendor invoice flow |
| SLG1 / Application Log | BAL_* framework | **WRITE** | Audit trail logging |
| CTS | Transport management | **STANDARD** | All Z object transports |
| SAP Message framework | Standard messages | **STANDARD** | Validation and error messages |

**No other SAP standard module is a runtime dependency of the addon.**

---

## The 9 Mandatory Capability Domains

All design, specs, agents, skills, and hooks must align to these 9 capability domains. Every feature belongs to at least one domain.

| Domain | ID | Description |
|--------|----|-------------|
| Contract Master Z | CD-01 | Z contract master data — full lifecycle |
| Lease Object Master Z | CD-02 | Z lease objects — asset types, classifications |
| Valuation Engine Z | CD-03 | IFRS 16 calculation — liability, ROU, schedules |
| Accounting Engine Z (FI-GL) | CD-04 | Direct FI-GL posting from addon |
| Asset Engine Z (FI-AA) | CD-05 | Direct FI-AA ROU asset management |
| Contract Event Engine Z | CD-06 | Contract modifications, extensions, terminations |
| Procurement / Source Integration Z | CD-07 | PO-based or source-based contract creation patterns |
| Reclassification Engine Z | CD-08 | Current/non-current liability reclassification |
| Reporting & Audit Z | CD-09 | Rollforwards, reconciliation, disclosure support |

---

## Non-Negotiable Governance Rules Under Option B

These rules are enforced by steering, hooks, agents, and skills. Violation by any design proposal must be flagged immediately.

| Rule | Enforcement |
|------|-------------|
| **OB-01:** No Z table may use RECN* or VICNCOND* as a foreign key for operational data | hook: option-b-architecture-guard |
| **OB-02:** No agent, spec, or design may propose RE-FX as the source of contract truth | hook: option-b-architecture-guard |
| **OB-03:** No accounting document may be created by RE-FX accounting engine | hook: accounting-traceability-check |
| **OB-04:** Every feature must map to at least one of the 9 capability domains (CD-01 to CD-09) | hook: capability-coverage-check |
| **OB-05:** Contract master data, valuation data, posting data, and event data must be in separate domain tables | spec: domain-data-model |
| **OB-06:** No contract change may overwrite history — event model is non-destructive | hook: contract-lifecycle-integrity-check |
| **OB-07:** Every accounting output must be traceable to: source event + valuation run + calculation inputs | hook: accounting-traceability-check |
| **OB-08:** All critical business functionality from the current ECC solution must be preserved or explicitly deferred | skill: ecc-coverage-preservation |
| **OB-09:** No open question about architecture or accounting may be silently ignored | hook: open-questions-register-check |
| **OB-10:** Every major design decision must generate or reference an ADR | steering: decision-policy.md |

---

## Migration Constraint

If the client has **existing contracts in RE-FX**, the following migration constraint applies:

- A **one-time migration analysis** (T0-02 revised) must extract all relevant business data from RE-FX into Z tables at go-live.
- The migration is **not a runtime dependency** — it is a data extraction and load exercise.
- After migration, RE-FX is not updated by the addon.
- The functional coverage matrix (`docs/architecture/functional-coverage-matrix.md`) must map every RE-FX feature that existed to its Option B replacement.

---

## ECC-to-S/4 Compatibility Under Option B

Option B is **structurally more S/4-compatible** than Option A, because:
- No dependency on RE-FX table structures that change in S/4.
- Z tables are self-owned and can be migrated cleanly.
- FI-GL and FI-AA integration via BAPIs is compatible with S/4HANA.
- CDS view reporting layer is directly S/4-compatible.

Every Z object must still carry the flag `[ECC-SPECIFIC: Review for S/4 migration]` where applicable, but the scope of ECC-specific constraints is significantly reduced under Option B.

---

## Prohibited Design Patterns

Any design, spec, task, or code proposal that contains any of the following **must be immediately rejected** and the Option B Architecture Guard hook must be triggered:

- "Read from RECN*/VICNCOND/VIOBJHEAD at runtime"
- "Extension table on RE-FX contract object"
- "RE-FX cash flow projection consumed by addon"
- "RE-FX modification triggers IFRS 16 recalculation"
- "RE-FX accounting engine generates the FI document"
- "RE-FX condition type determines lease payment classification"
- "Z table has FK to RE-FX object at runtime"

**The only valid RE-FX interaction at runtime is reading historical/migrated data from a Z migration staging table, not from live RE-FX operational tables.**
