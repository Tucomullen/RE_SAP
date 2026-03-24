# Master Technical Design — IFRS 16 Z Addon for SAP RE/RE-FX

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial technical design baseline |

---
Traceability:
- Spec: specs/000-master-ifrs16-addon/design.md
- Decision: docs/governance/decision-log.md — ADR-001 to ADR-005 (Proposed)
- Last updated: 2026-03-24
- Updated by: Bootstrap Agent
---

## 1. Architecture Principles

The technical architecture of the RE-SAP IFRS 16 addon is governed by the following non-negotiable principles:

1. **ABAP OO exclusively:** All business logic implemented in ABAP classes and interfaces. No procedural code in business logic layers. (ADR-001 — Proposed)
2. **No standard modification:** SAP standard objects are never modified. Only BAdI implementations, user exits, and enhancement framework usage.
3. **S/4HANA compatible by design:** No deprecated ABAP statements. CDS views for reporting. Migration path documented for every Z object. (ADR-005 — Proposed)
4. **Testability as architecture requirement:** All calculation logic behind interfaces; factory patterns for instantiation; ABAP Unit test classes mandatory for calculation classes.
5. **Auditability at every layer:** Every data write that impacts IFRS 16 conclusions is logged with user, timestamp, and reason.
6. **Performance-aware design:** No unbounded table scans; parallelization for batch; index strategy mandatory for all Z tables with batch access patterns.

---

## 2. System Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                               │
│  ZRE_IFRS16_INTAKE  ZRE_IFRS16_REVIEW  ZRE_IFRS16_POST          │
│  ZRE_IFRS16_DISC    ZRE_IFRS16_AUDIT   ZRE_IFRS16_ADMIN         │
├──────────────────────────────────────────────────────────────────┤
│  ORCHESTRATION LAYER                                              │
│  ZCL_RIF16_WORKFLOW  (approval state machine)                     │
│  ZRIF16_PERIOD_END_CALC  (batch job)                              │
├──────────────────────────────────────────────────────────────────┤
│  BUSINESS LOGIC LAYER                                             │
│  ZCL_RIF16_CALC_ENGINE    ZIF_RIF16_CALC_STRATEGY                 │
│  ZCL_RIF16_DISCLOSURE     ZCL_RIF16_POSTING                       │
│  ZCL_RIF16_MODIFICATION   ZCL_RIF16_SCOPE_CHECKER                 │
├──────────────────────────────────────────────────────────────────┤
│  DATA ACCESS LAYER                                                │
│  ZCL_RIF16_CONTRACT_DATA  ZIF_RIF16_DATA_PROVIDER                 │
│  ZCL_RIF16_LOGGER         ZCL_RIF16_AUDIT_WRITER                  │
├──────────────────────────────────────────────────────────────────┤
│  DATA LAYER                                                       │
│  Z Tables: ZRIF16_CNTRT  ZRIF16_SCHED  ZRIF16_CALC  ZRIF16_CALCI│
│            ZRIF16_PARAM  ZRIF16_AUDIT  ZRIF16_MODF               │
├──────────────────────────────────────────────────────────────────┤
│  INTEGRATION LAYER                                                │
│  RE-FX reads [tables TBC]  FI-GL posting [FM TBC]                 │
│  FI-AA posting [BAPI TBC]  SAP SLG1 logging                       │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. Z Object Catalog (Initial Baseline)

### 3.1 Z Tables

All Z tables include mandatory system fields: `MANDT`, `CREATED_BY`, `CREATED_AT`, `CHANGED_BY`, `CHANGED_AT`.

| Table | Purpose | Primary Key Fields | Change Doc | Buffering | Notes |
|-------|---------|-------------------|------------|-----------|-------|
| ZRIF16_CNTRT | IFRS 16 contract extension | MANDT + BUKRS + RECNNR (contract number — field TBC) | Yes | No | Core extension table; grows with contracts |
| ZRIF16_SCHED | Amortization schedule | MANDT + RUN_ID + PERIOD + CONTRACT_ID | No | No | Large volume table; index on CONTRACT_ID |
| ZRIF16_CALC | Calculation run header | MANDT + RUN_ID | Yes | No | One row per calculation run |
| ZRIF16_CALCI | Calculation run items | MANDT + RUN_ID + CONTRACT_ID | No | No | One row per contract per run |
| ZRIF16_PARAM | IFRS 16 parameters | MANDT + BUKRS + PARAM_KEY + VALID_FROM | No | Full | Configuration table; small and stable |
| ZRIF16_AUDIT | IFRS 16 audit trail | MANDT + AUDIT_ID (UUID) | No | No | Append-only; never update; archiving required |
| ZRIF16_MODF | Modification/remeasurement log | MANDT + MOD_ID + CONTRACT_ID | Yes | No | One row per modification event |

> **Note:** All field names and table names above follow the naming convention in `.kiro/steering/structure.md`. Final names must be confirmed with ABAP Architect before creation. Contract number field reference (`RECNNR`) must be confirmed with SAP RE Functional Consultant.

### 3.2 Z Classes and Interfaces

| Object | Type | Purpose | Package |
|--------|------|---------|---------|
| ZIF_RIF16_DATA_PROVIDER | Interface | Data provider interface — abstraction over RE-FX reads | ZRIF16_DATA |
| ZIF_RIF16_CALC_STRATEGY | Interface | Strategy interface for calculation algorithms | ZRIF16_CORE |
| ZIF_RIF16_POSTING_HANDLER | Interface | Strategy interface for FI posting | ZRIF16_POST |
| ZCL_RIF16_CONTRACT_DATA | Class | Implements ZIF_RIF16_DATA_PROVIDER; reads RE-FX data | ZRIF16_DATA |
| ZCL_RIF16_CALC_ENGINE | Class | Orchestrates calculation using strategy pattern | ZRIF16_CORE |
| ZCL_RIF16_AMORT_STRATEGY | Class | Implements ZIF_RIF16_CALC_STRATEGY — standard amortization | ZRIF16_CORE |
| ZCL_RIF16_EXEMPT_HANDLER | Class | Short-term and low-value exemption logic | ZRIF16_CORE |
| ZCL_RIF16_MODIFICATION | Class | Modification detection and classification logic | ZRIF16_CORE |
| ZCL_RIF16_POSTING | Class | Implements ZIF_RIF16_POSTING_HANDLER — FI posting | ZRIF16_POST |
| ZCL_RIF16_DISCLOSURE | Class | Disclosure aggregation and output | ZRIF16_DISC |
| ZCL_RIF16_WORKFLOW | Class | Approval state management | ZRIF16_CORE |
| ZCL_RIF16_LOGGER | Class | SLG1 logging utility | ZRIF16_UTILS |
| ZCL_RIF16_AUDIT_WRITER | Class | Writes to ZRIF16_AUDIT table | ZRIF16_UTILS |
| ZCX_RIF16_ERROR | Exception | Root exception class | ZRIF16_UTILS |
| ZCX_RIF16_DATA_ERROR | Exception | Data validation exception | ZRIF16_UTILS |
| ZCX_RIF16_CALC_ERROR | Exception | Calculation exception | ZRIF16_UTILS |
| ZCX_RIF16_AUTH_ERROR | Exception | Authorization exception | ZRIF16_UTILS |

### 3.3 Z Transactions and Programs

| Object | Type | Purpose |
|--------|------|---------|
| ZRE_IFRS16_INTAKE | Transaction | Guided data capture wizard |
| ZRE_IFRS16_REVIEW | Transaction | Calculation review and approval |
| ZRE_IFRS16_POST | Transaction | Posting execution with approval gate |
| ZRE_IFRS16_DISC | Transaction | Disclosure report generation |
| ZRE_IFRS16_AUDIT | Transaction | Audit trail viewer |
| ZRE_IFRS16_ADMIN | Transaction | Administration and parameter maintenance |
| ZRIF16_PERIOD_END_CALC | Program (batch) | Period-end calculation batch |
| ZRIF16_POSTING_RUN | Program (batch) | Batch posting program |
| ZRIF16_DISCLOSURE_GEN | Program (batch) | Disclosure pack generation |
| ZRIF16_DATA_CONSISTENCY | Program | Data consistency check |

---

## 4. Integration Design

### 4.1 RE/RE-FX Data Reading
- **Approach:** Z data provider class (`ZCL_RIF16_CONTRACT_DATA`) wraps all RE-FX reads.
- **Tables accessed:** [TO BE CONFIRMED with SAP RE Functional Consultant — specific RE-FX tables]
- **Data extracted:** Contract header, condition records, option dates, partner data, cash flow projections.
- **S/4 migration note:** When S/4HANA is adopted, only the data provider class implementation needs to change — business logic remains unaffected.
- **Error handling:** If RE-FX data is incomplete, `ZCX_RIF16_DATA_ERROR` is raised with specific field identification.

`[ECC-SPECIFIC: RE-FX table names and reading approach may change in S/4HANA RE-FX — review for S/4 migration]`

### 4.2 FI-GL Posting
- **Approach:** [TO BE CONFIRMED — options: BAPI_ACC_DOCUMENT_POST, standard accounting interface, or Z FM wrapper]
- **Documents generated:** Interest accrual, liability reduction, ROU depreciation, commencement entry, modification entries.
- **Reference field:** Every FI document carries the IFRS 16 run ID in the reference field.
- **Parallel ledger:** If a parallel IFRS ledger is configured, posting approach must support it. [TO BE CONFIRMED with FI Architect — ADR-TBC]
- **Rollback:** If posting fails mid-run, all partial postings must be reversed or rolled back. Approach TBC.

### 4.3 FI-AA (Asset Accounting — ROU Asset)
- **Approach:** [TO BE CONFIRMED — BAPI for asset creation and depreciation posting. Specific BAPI names not confirmed.]
- **ROU asset:** Created as a sub-number of the relevant asset class, linked to the RE contract.
- **Depreciation:** Calculated by the Z addon (straight-line over lease term); posted as a journal entry [vs. letting FI-AA depreciate automatically — TO BE CONFIRMED with FI team].

`[TO BE CONFIRMED — FI-AA integration architecture is a key design decision. ADR required before development begins.]`

### 4.4 Approval Workflow
- **Approach:** [TO BE CONFIRMED — SAP Business Workflow (WS) vs. Z approval table with workflow notifications. ADR-004 required.]
- **States:** Data Captured → Accountant Review → Calculation Ready → Controller Approval → Ready for Posting → Posted.
- **Notification:** Email or SAP inbox notification when approval is pending. [TO BE CONFIRMED — notification technology]

---

## 5. Logging and Audit Architecture

### 5.1 Application Log (SLG1)
- Log object: `ZRIF16`
- Sub-objects: `INTAKE`, `CALC`, `POSTING`, `MODIFICATION`, `DISCLOSURE`, `ADMIN`
- Every batch run produces a log accessible via SLG1 for the run ID.
- Log retention: SAP standard SLG1 retention schedule [TO BE CONFIRMED with Basis team].

### 5.2 IFRS 16 Audit Table (ZRIF16_AUDIT)
- Append-only table — no UPDATE statements ever.
- Every IFRS 16 process event writes one row: event type, user, timestamp, contract reference, event data (serialized).
- Long-term retention beyond SLG1 cycle.
- Accessible via `ZRE_IFRS16_AUDIT` transaction.
- Archiving strategy: [TO BE CONFIRMED — data retention policy]

---

## 6. Authorization Concept (Initial Design)

| Authorization Object | Fields | Used In |
|---------------------|--------|---------|
| ZRIF16_DATA | ACTIVITY (01/02/03), BUKRS | Data capture and display |
| ZRIF16_CALC | ACTIVITY (01/06), BUKRS | Calculation execution and approval |
| ZRIF16_POST | ACTIVITY (01/06), BUKRS | Posting execution and approval |
| ZRIF16_DISC | ACTIVITY (03), BUKRS | Disclosure read/generation |
| ZRIF16_ADMIN | ACTIVITY (01/02/03) | Admin and parameter maintenance |
| ZRIF16_AUDIT | ACTIVITY (03) | Audit trail read |

**SOD Rules (initial):**
- A user with ZRIF16_DATA (capture) must NOT have ZRIF16_CALC (approval) for same BUKRS.
- A user with ZRIF16_CALC (approval) must NOT have ZRIF16_POST (posting) for same BUKRS.

`[TO BE CONFIRMED with Security Team before implementation — ADR required]`

---

## 7. Performance Design

### Batch Calculation
- Parallel processing using RFC parallel calls or work process parallelization. [Specific approach TBC with ABAP Architect]
- Target: Complete period-end calculation for 500 active leases within 30 minutes. [Performance target to be confirmed]
- Package commits: every 100 contracts, commit work to release locks.
- No `SELECT *` statements — explicit field lists on all Z table reads.

### Index Strategy
| Table | Index Fields |
|-------|-------------|
| ZRIF16_SCHED | CONTRACT_ID + PERIOD |
| ZRIF16_CALCI | CONTRACT_ID + RUN_ID |
| ZRIF16_AUDIT | CONTRACT_ID + AUDIT_DATE |
| ZRIF16_MODF | CONTRACT_ID + MOD_DATE |

---

## 8. Transport Strategy

| Transport Layer | Contents | Transport Type |
|----------------|---------|---------------|
| Data Dictionary | Z tables, structures, domains, data elements | Workbench |
| Repository objects | Classes, programs, transactions, function groups | Workbench |
| Authorization | Auth objects, profiles | Workbench |
| Customizing | Table entries (ZRIF16_PARAM baseline), IMG entries | Customizing |
| Test data | Test contract configuration | Separate transport — QA only |

**Transport sequence:**
1. Data Dictionary transports must be imported before Repository objects.
2. Auth objects before role assignments.
3. Customizing after Repository objects.

---

## 9. S/4HANA Compatibility Notes

| Z Object | ECC-Specific Risk | Migration Path |
|----------|-------------------|---------------|
| ZCL_RIF16_CONTRACT_DATA | Reads ECC RE-FX tables | Replace with S/4 RE-FX data provider implementation — same interface |
| ZRIF16_SCHED | ECC table design — compatible | Assess if S/4HANA IFRS 16 standard functionality supersedes this table |
| ZCL_RIF16_POSTING | Uses ECC posting FM | Replace with S/4 accounting API if available |
| All Z transactions | ALV-based — ECC UI | Plan Fiori equivalent for S/4 — not built in v1 |

---

## 10. Open Technical Decisions

All items below require an ADR before development begins:

| Item | Current Status | Required Action |
|------|---------------|----------------|
| RE-FX table reading approach | TBC | SAP RE Functional Consultant to confirm tables |
| FI-GL posting method | TBC | FI Architect to recommend |
| FI-AA integration method | TBC | FI Architect to confirm BAPI availability |
| Parallel ledger handling | TBC | FI Architect to confirm parallel ledger setup |
| Approval workflow technology | TBC | ABAP Architect to propose — ADR-004 |
| Parallelization approach | TBC | ABAP Architect to confirm |
| Multi-currency handling | TBC | IFRS 16 Accountant + FI to confirm scope |

---

*This document will be expanded as Phase 0 items are resolved and technical designs are approved. All updates follow the documentation policy in `.kiro/steering/documentation-policy.md`.*
