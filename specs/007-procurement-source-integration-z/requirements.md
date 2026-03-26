# Procurement / Source Integration Z — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-07 — Procurement / Source Integration Z

> **Option B Compliance:** CD-07 creates Z lease contracts (`ZRIF16_CONTRACT`, Domain 1) directly from source documents. RE-FX is NOT used as a procurement integration point. Source document links are stored in Z integration references (Domain 6). Failed integrations are logged in Z error tables (Domain 8).

---

## Business Objective

Implement a framework for creating lease contracts automatically from procurement source data (purchase order-based or equivalent). When a purchase order or other source document with a lease indicator is posted, a draft Z lease contract is created and queued for completion by a RE Contract Manager. The link between the source document and the lease contract is maintained in Z integration reference tables for full traceability.

---

## Business Rationale

Many lease contracts originate from a procurement process — a purchase order for a vehicle lease, equipment rental, or facility. Without an integration framework, the RE Contract Manager must manually recreate contract data that already exists in the procurement document, creating duplication risk and data quality issues. CD-07 provides a structured intake path from procurement to lease contract, reducing manual entry and ensuring that all leases arising from procurement are captured in the IFRS 16 process.

---

## In-Scope (v1)

- Purchase order with lease indicator → draft Z lease contract creation
- Draft contract queue: list of all draft contracts pending RE Contract Manager completion
- Completion workflow: RE Contract Manager reviews, enriches, and activates a draft contract
- Source document link stored in `ZRIF16_INT_REF` (Domain 6): PO number ↔ Z contract ID
- Error queue: failed source integrations logged in `ZRIF16_ERR_LOG` (Domain 8) with reprocessing capability
- Integration interface definition: the Z function module or BAdI that receives source document data

---

## Out-of-Scope (v1)

- Automatic lease identification from procurement data (IFRS 16 para 9-11 assessment is a Lease Accountant responsibility — not automated)
- Integration with non-SAP procurement systems (Phase 2 or separate project)
- Automatic PO budget commitment integration
- Retroactive source document linking for existing legacy contracts

---

## Actors

| Actor | Role |
|-------|------|
| System (SAP MM/Procurement) | Triggers the Z integration interface when a PO with lease indicator is posted |
| RE Contract Manager | Reviews and completes draft contracts created from source documents |
| Lease Accountant | Classifies the draft contract for IFRS 16 scope after completion by the manager |
| System (Z error handler) | Logs failed integrations; makes them available for reprocessing |
| IT/Basis | Configures the source document integration interface and monitors error queue |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-PI-01 | System | When a purchase order with a lease indicator is posted, a draft Z lease contract is automatically created | Given a PO with lease indicator field set is posted in SAP MM, when the Z integration interface is triggered, then a draft `ZRIF16_CONTRACT` record is created with status "Draft — Pending Completion", populated with available PO data (vendor, start date, amount, company code), and the PO number is stored in `ZRIF16_INT_REF` | — | CD-07 |
| US-PI-02 | RE Contract Manager | I can review and complete a draft contract created from a source document so that the contract is ready for IFRS 16 classification | Given a draft contract exists in the draft queue, when the manager opens it, then all data sourced from the PO is pre-populated (read-only or editable per field rules) and mandatory IFRS 16 fields not available from the PO are empty and required before the contract can be activated | — | CD-07 |
| US-PI-03 | System | The link between source document (PO) and lease contract is maintained in Z integration references | Given a PO has created a Z contract, when the contract is viewed or reported on, then the source PO number is visible in the contract display and stored in `ZRIF16_INT_REF`, and the link is auditable | — | CD-07 |
| US-PI-04 | System | Failed source integrations are logged in the error queue with reprocessing capability | Given a source document triggers the Z integration interface but the contract creation fails (e.g., validation error), when the failure occurs, then the error is logged in `ZRIF16_ERR_LOG` with: source document number, error type, error message, timestamp, and a reprocess button is available for IT/operations use | — | CD-07 |

---

## Process Flow

1. A procurement user creates a purchase order in SAP MM with the lease indicator field set.
2. On PO posting (user exit or BAdI), the Z integration interface is triggered.
3. Interface validates the PO data against Z contract mandatory field requirements.
4. If validation passes: draft `ZRIF16_CONTRACT` is created with status "Draft — Pending Completion"; PO link written to `ZRIF16_INT_REF`.
5. If validation fails: error logged in `ZRIF16_ERR_LOG`; draft contract NOT created.
6. RE Contract Manager receives notification (workflow or task list) of new draft contracts.
7. Manager opens draft contract, reviews PO-sourced data, completes missing IFRS 16 fields.
8. Manager submits for activation → contract transitions to "Not Assessed" in CD-01.
9. Lease Accountant classifies the contract per standard CD-01 process.

---

## Edge Cases

- PO posted without a lease indicator (standard purchase) triggers the integration by mistake: system filters by lease indicator field — only POs with the flag set trigger contract creation.
- Duplicate PO posting (re-posting after reversal): system checks `ZRIF16_INT_REF` for existing link; blocks duplicate contract creation with explicit message.
- PO data contains fields that conflict with Z contract validation rules: specific field-level error messages in the error queue.
- Draft contract abandoned (PO cancelled before manager completes it): draft contract must be cleanly cancelled with PO link preserved for audit; source document cancellation does NOT automatically delete the draft contract.
- Error queue reprocessing triggered for a PO that has already been reprocessed: system checks for existing link before creating a new contract.

---

## Accounting Implications

- IFRS 16 para 9-11: Lease identification — a PO does not automatically imply the existence of an IFRS 16 lease. The Lease Accountant must assess whether the contract contains a lease. CD-07 creates a draft contract; it does NOT pre-classify it as an IFRS 16 lease.
- The draft contract has no accounting impact until it is activated and classified by the Lease Accountant.
- Source document links must be preserved in the audit trail even if the contract is ultimately classified as exempt.

---

## Integration Implications

- CD-01 (Contract Master): Draft contracts created by CD-07 transition into CD-01 on manager completion.
- SAP MM: BAdI or user exit point must be identified in the ECC system to trigger the Z interface on PO posting. This must be confirmed with the MM Functional Consultant.
- Domain 6 (`ZRIF16_INT_REF`): Source document links; must support multiple source types in Phase 2 (not just PO).
- Domain 8 (`ZRIF16_ERR_LOG`): Error and process logs; shared with other domains for general error logging.

---

## UX Implications

- Draft contract queue must show clearly: source document number, PO date, vendor, amount, completion status.
- Draft contracts must be visually distinguished from active contracts in all list views.
- Error queue must be accessible to operations/IT and show actionable error messages — not raw ABAP dumps.
- Reprocess button in error queue must require explicit user confirmation before triggering.
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- CD-01 (Contract Master): Z contract schema must be finalised before CD-07 can define which fields are sourced from the PO and which require manual completion.
- SAP MM configuration: Lease indicator field on PO must be confirmed with MM Functional Consultant. [TO BE CONFIRMED — field availability in ECC MM]
- BAdI/user exit: The integration trigger point in MM must be confirmed and tested in Phase 0 spike.

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-PI-01 | Is there an existing lease indicator field on SAP MM POs in the ECC system, or does one need to be added? | MM configuration scope | MM Functional Consultant |
| OQ-PI-02 | Which BAdI or user exit should be used to trigger the Z integration interface on PO posting in ECC? | Technical integration design | ABAP Architect + MM Functional Consultant |
| OQ-PI-03 | Are there non-PO source document types that also require CD-07 integration in Phase 1 (e.g., contracts in SAP SD or vendor agreements)? | Integration scope | SAP RE Functional Consultant + IFRS 16 Accountant |
| OQ-PI-04 | What data fields are available on the PO that are relevant to the Z contract master schema? | Field mapping design | MM Functional Consultant + Contract Model Architect |

---

## Design Risks

- **Risk:** Lease indicator field not available on ECC POs → significant MM configuration or enhancement required. Mitigation: MM field availability confirmed in Phase 0 before CD-07 design is committed.
- **Risk:** BAdI trigger fires too broadly (all POs) → performance degradation and false contract creation. Mitigation: strict filtering on lease indicator before any Z logic is executed.
- **Risk:** Error queue not monitored → leases created from POs go unprocessed and are missed. Mitigation: error queue monitoring is included in the operations runbook; daily monitoring task defined.
