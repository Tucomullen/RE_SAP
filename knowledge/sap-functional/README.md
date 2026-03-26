# Knowledge Base: SAP Functional Documentation

**Priority Level:** 4 (SAP official) and 5 (internal SAP process documentation)
**Location:** `knowledge/sap-functional/`
**Managed by:** SAP RE Functional Consultant (content) + RAG Knowledge Curator Agent (maintenance)

---

## Option B Context (ADR-006)

> **IMPORTANT:** Under Option B, RE-FX is NOT the system of record at runtime. The Z addon owns all contract master data, valuation, and accounting.
>
> SAP RE-FX documentation in this folder is retained for **two purposes only:**
> 1. **Migration analysis** — understanding what data exists in RE-FX that must be extracted into Z tables during the one-time migration (if applicable).
> 2. **Business coverage preservation** — confirming that all current ECC business capabilities are covered by the Option B design (CD-01 to CD-09).
>
> **RE-FX documentation must NOT be used as a runtime design reference.** Any design that proposes reading from live RE-FX tables at runtime violates ADR-006 and OB-01/OB-02.

---

## Purpose

This folder stores SAP ECC process documentation, BAPI references, FI/FI-AA integration documentation, and SAP RE-FX legacy documentation used for migration analysis. It provides agents with accurate information about SAP standard behavior without requiring live system access.

---

## Source Categories

| Sub-type | Priority | Option B Usage | Examples | Notes |
|----------|---------|---------------|---------|-------|
| SAP official FI/FI-AA BAPI documentation | 4 | **ACTIVE — runtime design** | `sap-bapi-acc-document-post.md` | From help.sap.com; cite URL or document ID |
| SAP Notes (FI/FI-AA) | 4 | **ACTIVE — runtime design** | `sap-note-[number]-[topic].md` | Cite SAP Note number; check validity for ECC version |
| SAP RE-FX contract management documentation | 5 | **MIGRATION ONLY** | `refx-contract-lifecycle-process-map.md` | Legacy source; migration analysis only; not runtime |
| SAP RE-FX data model documentation | 5 | **MIGRATION ONLY** | `refx-key-tables-field-mapping.md` | Migration extract reference; not runtime FK |
| SAP RE-FX configuration documentation | 5 | **MIGRATION ONLY** | `refx-condition-types-client-config.md` | Migration classification reference only |
| SAP ECC authorization framework | 4 | **ACTIVE — runtime design** | `sap-auth-object-framework.md` | For Z authorization object design |
| SAP SLG1 application log documentation | 4 | **ACTIVE — runtime design** | `sap-slg1-application-log.md` | For Z logging design (ADR-003) |

---

## How to Add a New Source

1. **Confirm Option B usage:** Is this source for runtime design (FI/FI-AA BAPIs, auth, logging) or migration analysis (RE-FX legacy)?
2. **Never invent field names or table names.** If a field or table is not confirmed in the actual system, mark it `[TO BE CONFIRMED]`.
3. **Prepare frontmatter:**

```yaml
---
source-type: [sap-official | sap-internal]
source-name: [Full title]
source-date: YYYY-MM-DD
source-version: [SAP release applicability, e.g., "ECC 6.0 EhP7"]
priority: [4 or 5]
option-b-usage: [runtime-design | migration-only]
confidence: [high | medium]
status: [current | under-review | superseded]
tags: [fi-bapi, fi-aa, re-fx-legacy, migration, auth, logging, etc.]
cited-in: []
added-by: [name]
added-date: YYYY-MM-DD
validated-by: [SAP RE Functional Consultant name — required for priority 4-5]
validation-date: YYYY-MM-DD
---
```

4. Priority 4-5 sources require validation by the SAP RE Functional Consultant before `status: current`.
5. Update this README index.

---

## Key Documentation Required Before Phase 1

### Runtime Design Documentation (Option B — Active)

The following documentation must exist before Phase 1 ABAP development begins:

- [ ] FI-GL BAPI documentation — `BAPI_ACC_DOCUMENT_POST` or equivalent: parameters, return codes, document splitting behavior [OQ-FI-02]
- [ ] FI-AA BAPI documentation — sub-asset creation and depreciation activation BAPIs [OQ-FI-05]
- [ ] SAP SLG1 framework — log object creation, BAL_* function module usage [OQ-ABAP-04]
- [ ] SAP authorization object framework — Z auth object creation and check patterns [OQ-ABAP-05]
- [ ] SAP parallel processing — CALL FUNCTION STARTING NEW TASK patterns for batch [OQ-ABAP-03]

### Migration Analysis Documentation (Option B — Migration Only)

The following RE-FX documentation is needed only if the client has existing RE-FX contracts to migrate:

- [ ] RE-FX contract object structure — key tables and fields for migration extract [OQ-CM-06]
- [ ] RE-FX condition types — payment type classification for migration mapping [A-07]
- [ ] RE-FX option date fields — extension and termination option data for migration [A-08]
- [ ] RE-FX contract amendment history — change events to be migrated as Z events [OQ-CM-06]

---

## S/4HANA Compatibility Notes

For each documented SAP behavior, note whether it is:
- `[SAME IN S/4]` — same behavior confirmed in S/4HANA
- `[CHANGED IN S/4 — see note]` — behavior changes in S/4HANA
- `[S/4 UNKNOWN]` — not yet investigated

This tagging enables the Phase 3 S/4HANA compatibility assessment.

---

## Index of Current Sources

| File | Title | Priority | Option B Usage | Status | SAP Version | Key Topics |
|------|-------|---------|---------------|--------|-------------|-----------|
| *(To be populated as SAP RE Functional Consultant and ABAP Architect provide documentation)* | | | | | | |

---

*Traceability: ADR-006 (Option B) | docs/architecture/option-b-architecture.md | Last updated: 2026-03-26 | Updated by: Project Governance Lead (reconciliation pass)*
