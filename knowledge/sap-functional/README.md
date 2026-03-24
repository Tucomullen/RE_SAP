# Knowledge Base: SAP Functional Documentation

**Priority Level:** 4 (SAP official) and 5 (internal SAP process documentation)
**Location:** `knowledge/sap-functional/`
**Managed by:** SAP RE Functional Consultant (content) + RAG Knowledge Curator Agent (maintenance)

---

## Purpose
This folder stores SAP RE/RE-FX process documentation, object references, configuration screenshots, SAP Notes, and other technical SAP materials used to design the IFRS 16 Z addon. It provides agents with accurate information about SAP standard behavior without requiring live system access.

---

## Source Categories

| Sub-type | Priority | Examples | Notes |
|----------|---------|---------|-------|
| SAP official help documentation | 4 | `sap-refx-contract-management-overview.md` | From help.sap.com; cite URL or document ID |
| SAP Notes | 4 | `sap-note-[number]-[topic].md` | Cite SAP Note number; check validity for ECC version |
| SAP RE-FX configuration documentation | 5 | `refx-condition-types-client-config.md` | Client-specific; validate with RE Consultant |
| RE-FX data model documentation | 5 | `refx-key-tables-field-mapping.md` | Must be confirmed against actual system |
| Process maps and flow diagrams | 5 | `refx-contract-lifecycle-process-map.md` | Describe or reference actual client process |
| Object catalog screenshots | 5 | `refx-contract-screen-fields-client.md` | From actual system — never invent field names |

---

## How to Add a New Source

1. **Confirm priority:** SAP official documentation (Priority 4) vs. internal process documentation (Priority 5).
2. **Never invent field names or table names.** If a field or table is not confirmed in the actual system, mark it `[TO BE CONFIRMED]`.
3. **Prepare frontmatter:**

```yaml
---
source-type: [sap-official | sap-internal]
source-name: [Full title]
source-date: YYYY-MM-DD
source-version: [SAP release applicability, e.g., "ECC 6.0 EhP7"]
priority: [4 or 5]
confidence: [high | medium]
status: [current | under-review | superseded]
tags: [re-fx, contract, conditions, cash-flow, etc.]
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

## Key SAP RE-FX Topics to Document (Minimum Required Before Phase 1)

The following documentation must exist before the RE-FX field mapping design is approved:

- [ ] RE-FX contract object structure — key tables and fields used for IFRS 16 data [specific tables TBC]
- [ ] RE-FX condition types — how payment types are modeled and which are IFRS 16-relevant
- [ ] RE-FX cash flow generation — how projected cash flows are generated and where they are stored [tables TBC]
- [ ] RE-FX option date management — how extension and termination options are stored and tracked
- [ ] RE-FX contract amendment process — what change types are possible and how they are recorded
- [ ] RE-FX to FI integration — how RE-FX generates FI postings (standard process)
- [ ] RE-FX to FI-AA integration — how RE-FX links to asset accounting
- [ ] RE-FX BAdI/User exit inventory — available enhancement spots for contract save and change events [to be confirmed]
- [ ] Client-specific RE-FX configuration — asset classes, business entity structure, condition type setup

---

## S/4HANA Compatibility Notes
For each documented SAP RE-FX behavior, note whether it is:
- `[SAME IN S/4]` — same behavior confirmed in S/4HANA RE-FX
- `[CHANGED IN S/4 — see note]` — behavior changes in S/4HANA
- `[S/4 UNKNOWN]` — not yet investigated

This tagging enables the Phase 3 S/4HANA compatibility assessment.

---

## Index of Current Sources

| File | Title | Priority | Status | SAP Version | Key Topics |
|------|-------|---------|--------|-------------|-----------|
| *(To be populated as SAP RE Functional Consultant provides documentation)* | | | | | |
