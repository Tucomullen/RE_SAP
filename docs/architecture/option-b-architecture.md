# Option B Architecture Overview
**Version:** 1.0 | **Date:** 2026-03-26 | **Status:** APPROVED (ADR-006)

---

## 1. Architectural Statement

The RE-SAP IFRS 16 Addon is a **standalone Z Lease Management System** built on SAP ECC. It does not depend on SAP RE-FX as a system of record, processing engine, or accounting engine. The addon owns its data, its calculations, and its accounting outputs end-to-end.

---

## 2. Logical Architecture

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

---

## 3. The 9 Capability Domains

### CD-01 — Contract Master Z
**Owns:** Full lease contract master data for all contracts managed by the addon.
**Z Data:** Contract header (company code, contract type, dates, currency, parties), payment schedule, controlling assignment, document references, status.
**Replaces:** RECN* / VICNCOND in RE-FX.
**Spec:** `specs/001-contract-master-z/`

### CD-02 — Lease Object Master Z
**Owns:** Classification and description of the leased asset/object.
**Z Data:** Object type (land, building, vehicle, equipment, software, other), object subtype, physical description, location, cost center default.
**Replaces:** RE-FX object hierarchy (Business Entity / Land / Building / Rental Unit).
**Spec:** `specs/002-lease-object-z/`

### CD-03 — Valuation Engine Z
**Owns:** All IFRS 16 calculations — initial recognition and subsequent measurement.
**Z Data:** Calculation run header, calculation items per contract, amortization schedule (liability + ROU), interest schedule, incremental borrowing rate, lease term determination, option analysis results.
**Replaces:** RE-FX valuation engine (and manual spreadsheets).
**Spec:** `specs/003-valuation-engine-z/`

### CD-04 — Accounting Engine Z (FI-GL)
**Owns:** All FI-GL document creation — lease accounting entries posted directly to FI.
**Z Data:** Posting log per contract per period, FI document reference, posting status, simulation results, reversal log, error log.
**Replaces:** RE-FX accounting engine + manual FI postings.
**Spec:** `specs/004-accounting-engine-z/`

### CD-05 — Asset Engine Z (FI-AA)
**Owns:** ROU asset lifecycle — creation, depreciation activation, derecognition.
**Z Data:** Z contract ↔ FI-AA asset number mapping, ROU asset creation log, derecognition log.
**Replaces:** RE-FX FI-AA integration.
**Spec:** `specs/005-fi-aa-integration-z/`

### CD-06 — Contract Event Engine Z
**Owns:** Non-destructive contract lifecycle — all changes captured as events.
**Z Data:** Event log (event type, effective date, before/after snapshot, triggered recalculation run, user, timestamp), remeasurement triggers, modification classification results.
**Replaces:** RE-FX contract amendment / change history.
**Spec:** `specs/006-contract-event-lifecycle-z/`

### CD-07 — Procurement / Source Integration Z
**Owns:** Pattern for creating lease contracts from upstream procurement data (PO, purchase order, source document).
**Z Data:** Source document reference, draft contract created, error log, reprocessing queue.
**No direct RE-FX equivalent** — this is a net-new capability.
**Spec:** `specs/007-procurement-source-integration-z/`

### CD-08 — Reclassification Engine Z
**Owns:** Periodic reclassification of lease liability from non-current to current portion.
**Z Data:** Reclassification run, per-contract current/non-current split, reclassification FI documents, configuration (how many months = current portion).
**Replaces:** ZRE009 / RE-FX reclassification (PP-C pain point).
**Spec:** `specs/008-reclassification-engine-z/`

### CD-09 — Reporting & Audit Z
**Owns:** All reporting, rollforward, reconciliation, and audit output.
**Z Data:** CDS views over all Z persistence tables. Report variants per company code / period / asset class / contract type.
**Replaces:** RE-FX standard reports (fragmented, asset-class-only — PP-G pain point) + manual disclosure spreadsheets.
**Spec:** `specs/009-reporting-audit-z/`

---

## 4. Data Flow — New Contract End-to-End

```
1. USER: Creates contract via Z Workspace (CD-01 + CD-02)
   → ZRIF16_CONTRACT (master) + ZRIF16_LEASEOBJ (object) written
   → Status: DRAFT

2. USER/SYSTEM: IFRS 16 scope assessment
   → Exemption check (short-term / low-value)
   → If exempt: Status EXEMPT, no further processing
   → If in-scope: Status PENDING_VALUATION

3. USER: Triggers initial valuation (CD-03)
   → ZRIF16_CALC_RUN written (run header)
   → ZRIF16_CALC_ITEM written (this contract in this run)
   → ZRIF16_SCHEDULE written (N rows — amortization/interest schedule)
   → Status: CALCULATED

4. APPROVER: Reviews and approves calculation
   → ZRIF16_APPROVAL written (approver, timestamp, decision)
   → Status: APPROVED

5. ACCOUNTANT: Posts initial recognition (CD-04 + CD-05)
   → FI-GL BAPI called → BKPF/BSEG created (ROU asset DR / Lease liability CR)
   → FI-AA BAPI called → ROU sub-asset created → ZRIF16_ASSET_MAP written
   → ZRIF16_POSTING_LOG written (FI doc reference, run ID, contract ID)
   → Status: ACTIVE

6. PERIOD-END BATCH: Monthly accruals (CD-04 + CD-08)
   → Interest accrual: FI document created
   → Amortization: FI-AA depreciation activated (or direct FI entry)
   → Reclassification run (CD-08): current/non-current split FI documents
   → ZRIF16_POSTING_LOG updated per entry
   → Status: ACTIVE (unchanged)

7. AUDIT: Full traceability available (CD-09)
   → Contract → Events → Calculations → Postings → FI Documents
   → All linked via Z contract ID throughout
```

---

## 5. Key Architectural Decisions

| Decision | Choice | ADR |
|----------|--------|-----|
| System of record for contracts | Z tables (Option B) | ADR-006 |
| FI-GL integration method | Standard BAPI / direct posting FM | ADR-004 |
| FI-AA integration method | Standard FI-AA BAPI | TBC — confirm at T0-04 |
| Approval workflow technology | Z table workflow vs SAP standard workflow | TBC — confirm at T0-04 |
| Parallel ledger approach | Main ledger vs IFRS parallel ledger | ADR-003 (pending) |
| Contract change model | Non-destructive event model | ADR-005 (pending) |
| Batch processing parallelization | ABAP parallel work processes | TBC — confirm at T0-03 |
| Z namespace | ZRE_IFRS16_ prefix (to be confirmed) | TBC — confirm at T0-03 |

---

## 6. What Changes vs. Previous Design (Option A → Option B)

| Aspect | Option A (Previous) | Option B (Current) |
|--------|--------------------|--------------------|
| Contract data source | RE-FX (RECN* tables) | Z tables (ZRIF16_CONTRACT*) |
| Payment schedule source | RE-FX condition types | Z payment schedule table |
| IFRS 16 trigger | RE-FX contract event | Z contract event |
| Accounting engine | RE-FX accounting | Direct FI BAPI |
| FI-AA integration | Via RE-FX | Direct FI-AA BAPI |
| User transactions | RE-FX + Z wizard | Z Workspace only |
| Data migration | Not needed | One-time RE-FX extract (if applicable) |
| S/4 readiness | RE-FX table risk | Cleaner — Z tables self-owned |
