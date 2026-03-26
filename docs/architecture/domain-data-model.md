# Domain Data Model — Z Lease Management Addon
**Version:** 1.0 | **Date:** 2026-03-26 | **Status:** Draft — Confirm at T0-04

> This document defines the **conceptual domain separation** for Z persistence. Technical table names (ZRIF16_*) are illustrative and subject to ABAP Architect confirmation at T0-03. The separation of domains is NON-NEGOTIABLE under Option B governance rule OB-05.

---

## Domain Separation Principle

```
┌──────────────────────────────────────────────────────────────────┐
│  DOMAIN 1         │  DOMAIN 2         │  DOMAIN 3               │
│  Contract Truth   │  Lease Object     │  Valuation Results      │
│  (Master Data)    │  Master           │  (Calculated Data)      │
│                   │                   │                          │
│  Who, what,       │  What is being    │  How much liability,    │
│  when, where,     │  leased — type,   │  ROU, schedule,         │
│  how much to pay  │  class, location  │  interest, IBR          │
└───────────────────┴───────────────────┴──────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│  DOMAIN 4         │  DOMAIN 5         │  DOMAIN 6               │
│  Posting History  │  Contract Events  │  Integration Refs       │
│                   │  (Lifecycle)      │                          │
│  What FI docs     │  What happened    │  Links to FI-AA assets, │
│  were created,    │  to the contract  │  FI docs, source POs    │
│  when, status     │  over time        │  error log              │
└───────────────────┴───────────────────┴──────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│  DOMAIN 7         │  DOMAIN 8         │  DOMAIN 9               │
│  Supporting       │  Error &          │  Configuration /        │
│  Documents /      │  Process Logs     │  Accounting             │
│  Evidence         │                   │  Determination          │
│                   │                   │                          │
│  Attachments,     │  Run errors,      │  GL account mapping,    │
│  approvals,       │  retry queues,    │  posting rules, param   │
│  sign-offs        │  batch logs       │  tables, IBR config     │
└───────────────────┴───────────────────┴──────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│  DOMAIN 10                                                        │
│  Reclassification Configuration and Execution History            │
│                                                                   │
│  Rules for current vs non-current split, reclassification runs,  │
│  history of FI reclassification documents per contract per period │
└───────────────────────────────────────────────────────────────────┘
```

---

## Domain 1 — Contract Truth / Contract Master

**Purpose:** The single source of truth for every lease contract managed by the addon.
**Governance:** This is the "contract of record." No contract exists in the system unless it exists here.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Identity | Z Contract ID (system-generated), external reference, company code |
| Parties | Lessor (vendor/creditor), lessee (company code entity) |
| Object reference | FK to Domain 2 (Lease Object Master) |
| Dates | Start date, end date, non-cancellable end date, renewal options, termination options, notice dates |
| Payment schedule | Payment amount, frequency, first payment date, payment-in-advance flag |
| Currency | Payment currency, reporting currency, exchange rate type |
| IFRS 16 scope | Scope flag (in-scope / exempt / short-term / low-value), exemption reason |
| IBR | Incremental borrowing rate used, effective date |
| Controlling | Cost center, profit center, business area, WBS element (if applicable) |
| Status | DRAFT / PENDING_VALUATION / CALCULATED / APPROVED / ACTIVE / MODIFIED / TERMINATED / EXPIRED |
| Metadata | Created by, created on, last modified by, last modified on, migration flag |
| Source | Source document type (manual / PO / migration), source document number |

**Key Tables (Conceptual):**
- `ZRIF16_CONTRACT` — Contract header (1 row per contract)
- `ZRIF16_PYMT_SCHED` — Payment schedule lines (N rows per contract)
- `ZRIF16_CONTRACT_H` — Contract change document header (non-destructive change tracking)

---

## Domain 2 — Lease Object Master

**Purpose:** Describes the physical or non-physical asset being leased.
**Governance:** Reusable master — one object can appear in multiple contracts over time.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Identity | Z Object ID, description |
| Classification | Asset category (land / building / vehicle / equipment / software / other) |
| Asset subtype | Subtype within category (e.g., vehicle → car / truck / van) |
| Physical attributes | Location (country, city, address), floor/unit (for real estate) |
| Control attributes | Cost center default, responsible person |
| Metadata | Created by, created on |

**Key Tables (Conceptual):**
- `ZRIF16_LEASE_OBJ` — Lease object master (1 row per object)
- `ZRIF16_LOBJ_CLASS` — Object classification config (asset categories / subtypes)

---

## Domain 3 — Valuation Results

**Purpose:** Contains all IFRS 16 calculation outputs — completely separate from master data.
**Governance:** Valuation results are never modified in place. A new calculation run creates new records. Old records are retained for history.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Run identity | Calculation run ID, run date, run type (initial / periodic / remeasurement), triggered by event ID |
| Contract scope | Contract ID, calculation effective date, calculation inputs snapshot |
| Initial recognition | Lease liability at commencement, ROU asset at commencement, discount rate used |
| Schedule rows | Period, opening balance (liability), interest, payment, closing balance (liability), opening balance (ROU), amortization, closing balance (ROU) |
| Run status | SIMULATED / CALCULATED / APPROVED / SUPERSEDED |

**Key Tables (Conceptual):**
- `ZRIF16_CALC_RUN` — Calculation run header (1 row per run)
- `ZRIF16_CALC_ITEM` — Per-contract result in a run (1 row per contract per run)
- `ZRIF16_SCHEDULE` — Amortization/interest schedule (N rows per contract per run version)

---

## Domain 4 — Posting History

**Purpose:** Complete record of every FI-GL document created by the addon, linked to the contract and calculation run that generated it.
**Governance:** Append-only. No row is deleted or updated — only status is changed (POSTED / REVERSED / ERROR).

| Conceptual Field Group | Examples |
|------------------------|---------|
| Identity | Posting log ID, contract ID, calculation run ID, event ID (if triggered by event) |
| FI document reference | FI company code, FI fiscal year, FI document number |
| Posting type | Initial recognition / interest accrual / amortization / payment / remeasurement / reversal / reclassification |
| Period | Fiscal year, posting period |
| Amounts | Liability DR/CR, ROU DR/CR, interest expense, cash outflow |
| Status | SIMULATED / POSTED / REVERSED / ERROR |
| Metadata | Posted by, posted on, approved by, approved on |

**Key Tables (Conceptual):**
- `ZRIF16_POST_LOG` — Posting log (1 row per FI document per contract per event)

---

## Domain 5 — Contract Events / Lifecycle

**Purpose:** Non-destructive record of every lifecycle event that changed a contract.
**Governance:** Events are NEVER overwritten. Each event is immutable once created. This is the event journal.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Identity | Event ID, contract ID, event sequence number |
| Event type | CREATED / EXTENDED / MODIFIED / TERMINATED_EARLY / NOVATED / CC_CHANGED / CURRENCY_CHANGED / RATE_UPDATED / REMEASUREMENT |
| Effective date | Date from which the event takes effect |
| Before snapshot | Key fields before the event (JSON or Z history table FK) |
| After snapshot | Key fields after the event |
| Triggered recalculation | FK to ZRIF16_CALC_RUN (the run that this event triggered) |
| Approval | Approved by, approved on |
| Metadata | Created by, created on |

**Key Tables (Conceptual):**
- `ZRIF16_EVENT` — Contract event header (1 row per event)
- `ZRIF16_EVENT_SNAP` — Before/after field snapshots per event

---

## Domain 6 — Integration References

**Purpose:** Cross-reference table linking Z contracts to external SAP objects (FI-AA assets, source POs, migration source IDs).
**Governance:** Read/write. Links are created when the external object is created/linked.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Z Contract ID | FK to Domain 1 |
| Reference type | FI_ASSET / SOURCE_PO / MIGRATION_REFX / VENDOR_INVOICE |
| External reference | External document number (asset number, PO number, etc.) |
| Company code | ECC company code of the external object |
| Status | ACTIVE / CLOSED / MIGRATED |

**Key Tables (Conceptual):**
- `ZRIF16_INTG_REF` — Integration reference map

---

## Domain 7 — Supporting Documents / Evidence

**Purpose:** Document attachments and approval evidence linked to contracts.
**Governance:** Metadata stored in Z; physical files stored in SAP GOS (Generic Object Services) or external DMS.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Z Contract ID | FK to Domain 1 |
| Document type | CONTRACT_SCAN / BOARD_APPROVAL / AUDIT_EVIDENCE / UAT_EVIDENCE |
| Reference | GOS object key or external URL |
| Metadata | Uploaded by, uploaded on |

**Key Tables (Conceptual):**
- `ZRIF16_DOC_REF` — Document reference metadata

---

## Domain 8 — Error and Process Logs

**Purpose:** All run errors, retry queues, and batch process logs.
**Governance:** Append-only. Errors are logged at item level — one failed contract never silences another.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Run ID / Batch job ID | FK to calculation run or posting run |
| Contract ID | Which contract failed |
| Error code | Z error code |
| Error message | Human-readable message |
| Stack/context | Technical detail for ABAP developer |
| Retry status | PENDING_RETRY / RETRIED_OK / PERMANENTLY_FAILED |
| Metadata | Logged at timestamp |

**Key Tables (Conceptual):**
- `ZRIF16_ERROR_LOG` — Error log (links to SLG1 for full application log)

---

## Domain 9 — Configuration / Accounting Determination

**Purpose:** All customizing/configuration tables that control addon behavior.
**Governance:** Changed via IMG/config transactions, not by end users. Every change is transport-tracked.

| Conceptual Field Group | Examples |
|------------------------|---------|
| GL account determination | Company code + posting type → GL account mapping |
| IBR config | Company code + currency + validity period → IBR rate |
| Approval threshold | Amount threshold for controller approval |
| Period-end config | Fiscal year variant, posting period rules |
| Low-value threshold | Per-company-code low-value threshold (IFRS 16 exemption) |
| Short-term threshold | Standard 12-month threshold config |
| Asset class mapping | Z object category → FI-AA asset class |

**Key Tables (Conceptual):**
- `ZRIF16_GL_MAP` — GL account determination
- `ZRIF16_IBR_RATE` — IBR rate configuration
- `ZRIF16_PARAM` — General parameters per company code
- `ZRIF16_ASSET_CLS` — Asset class mapping

---

## Domain 10 — Reclassification Configuration and History

**Purpose:** Configuration of current/non-current split logic and execution history of reclassification runs.
**Governance:** Config via IMG. Run history append-only.

| Conceptual Field Group | Examples |
|------------------------|---------|
| Reclassification config | Company code + rule (months = current portion, e.g., 12) |
| Run header | Reclassification run ID, date, period, company code |
| Run items | Contract ID, current portion amount, non-current portion amount, FI document ref |

**Key Tables (Conceptual):**
- `ZRIF16_RECLS_CFG` — Reclassification config
- `ZRIF16_RECLS_RUN` — Reclassification run header
- `ZRIF16_RECLS_ITEM` — Reclassification run items per contract

---

## Domain Separation Enforcement

> **Rule OB-05 (from option-b-target-model.md):** Contract master data, valuation data, posting data, and event data MUST be in separate domain tables. Cross-domain joins via FK are permitted. Merging domain data into single tables is prohibited.

The `contract-lifecycle-integrity-check` hook validates that proposed designs maintain this separation.
