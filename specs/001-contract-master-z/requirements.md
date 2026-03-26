# Contract Master Z — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-01 — Contract Master Z / CD-02 — Lease Object Master Z

> **Option B Compliance:** CD-01 and CD-02 replace RE-FX contract and object hierarchy entirely. `ZRIF16_CONTRACT` is the primary contract master table (Domain 1). `ZRIF16_LEASE_OBJ` is the lease object master (Domain 2). RE-FX is NOT accessed at runtime for contract or object data.

---

## Business Objective

Define and implement the Z contract master data model that serves as the system of record for all lease contracts under Option B. This domain covers the creation, maintenance, and lifecycle management of lease contracts (CD-01) and the physical/non-physical assets being leased (CD-02), capturing all fields required for IFRS 16 identification, classification, and measurement.

---

## Business Rationale

Under Option B (ADR-006), the Z addon owns the contract record entirely. There is no dependency on RE-FX contract data at runtime. The contract master must capture every IFRS 16-relevant attribute at inception and support the full lifecycle including modifications, extensions, terminations, and exemption elections. The lease object master provides asset classification data used by the FI-AA engine to determine the ROU asset class.

---

## In-Scope (v1)

- Z contract master table `ZRIF16_CONTRACT` — full schema definition
- Z lease object master table `ZRIF16_LEASE_OBJ` — full schema definition
- Contract creation transaction (single and mass upload)
- Contract display and maintenance transaction
- Exemption election (short-term / low-value) with documented rationale
- Supporting document attachment to contract record
- Lease object creation and assignment to contract
- Contract lifecycle status management (Not Assessed → Active → Exempt / Rescinded / Blocked)
- Change document logging for all contract and object field changes

---

## Out-of-Scope (v1)

- Procurement-triggered contract creation (CD-07 — specs/007-procurement-source-integration-z/)
- Contract modification / remeasurement processing (CD-06 — specs/006-contract-event-lifecycle-z/)
- Valuation calculation (CD-03 — specs/003-valuation-engine-z/)
- FI-GL posting (CD-04 — specs/004-accounting-engine-z/)
- FI-AA asset creation (CD-05 — specs/005-fi-aa-integration-z/)

---

## Actors

| Actor | Role |
|-------|------|
| RE Contract Manager | Creates, maintains, and classifies lease contracts and lease objects |
| Lease Accountant | Reviews contracts for IFRS 16 applicability; elects exemptions |
| Finance Controller | Approves contract data before initial valuation is triggered |
| Auditor | Read-only access to contract record, change history, and exemption rationale |
| System (batch) | Assigns contract status; triggers downstream valuation on status change |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-CM-01 | RE Contract Manager | I can create a new lease contract with all IFRS 16-relevant fields so that the contract is the basis for all calculations | Given a new lease agreement exists, when the manager enters contract data and saves, then a new `ZRIF16_CONTRACT` record is created with status "Not Assessed" and all mandatory IFRS 16 fields are populated | — | CD-01 |
| US-CM-02 | RE Contract Manager | I can create multiple contracts via mass upload (Excel/CSV) for portfolio onboarding | Given a valid upload template, when the manager uploads a file with N rows, then N contract records are created or an error report is shown per failing row (no partial silent failures) | PP-A | CD-01 |
| US-CM-03 | RE Contract Manager | I can view the full lifecycle status of any contract at a glance | Given a contract exists, when the manager opens the contract display, then the current lifecycle status is shown prominently with the date of last status change | PP-D | CD-01 |
| US-CM-04 | Lease Accountant | I can classify a lease as exempt (short-term/low-value) with documented rationale so that the exemption decision is auditable | Given an active contract, when the accountant elects an exemption and enters rationale, then the contract status changes to "Exempt", no valuation is triggered, and the rationale is stored in `ZRIF16_AUDIT` | — | CD-01 |
| US-CM-05 | RE Contract Manager | I can attach supporting documents to a contract record | Given a contract record exists, when the manager attaches a document via GOS (SAP Generic Object Services), then the document is linked to the contract and visible in the document list | — | CD-01 |
| US-CM-06 | RE Contract Manager | I can create and manage a lease object (the physical/non-physical asset being leased) | Given no lease object exists for an asset, when the manager creates a lease object with type, subtype, and asset class, then a `ZRIF16_LEASE_OBJ` record is created and can be linked to one or more contracts | — | CD-02 |

---

## Process Flow

1. Contract Manager initiates a new contract in the Z intake transaction.
2. System validates mandatory fields (pre-flight validation — see design.md section 11.1).
3. Contract Manager assigns a lease object (existing or newly created).
4. Contract is saved with status "Not Assessed".
5. Lease Accountant reviews and classifies the contract:
   - If IFRS 16 in scope: status → "Active"; triggers CD-03 valuation intake.
   - If short-term exemption: status → "Exempt"; rationale recorded.
   - If low-value exemption: status → "Exempt"; rationale recorded.
6. Finance Controller approval (if required by policy).
7. All field changes logged in change document.

---

## Edge Cases

- Attempt to activate a contract with incomplete mandatory IFRS 16 fields: system blocks with per-field error messages (PP-A pattern).
- Mass upload with duplicate contract IDs: system rejects duplicates with explicit row-level error.
- Exemption elected after valuation was already run: system warns, requires explicit override with Controller approval.
- Lease object assigned to a terminated contract: system blocks with explicit message.
- Attempt to delete a contract record: deletion is NOT permitted; contracts may only be set to "Cancelled" status with audit trail.

---

## Accounting Implications

- IFRS 16 para 5: Short-term and low-value exemptions are elected at policy level or contract level; rationale must be documented and auditable.
- IFRS 16 para 9-11: Lease identification — contract manager must confirm that the contract contains a lease per IFRS 16 definition before classification.
- Contract commencement date, lease term (including renewal options), and lease payments must all be captured accurately as inputs to the CD-03 valuation engine.
- Exemption elections have zero accounting impact (no ROU asset, no liability); this must be explicitly confirmed by the Lease Accountant.

---

## Integration Implications

- CD-03 (Valuation Engine): Contract master record is the primary input to all valuation runs. Schema must be validated against CD-03 input requirements before Phase 1 development.
- CD-05 (FI-AA): Lease object asset class determines the FI-AA asset class for the ROU asset sub-number.
- CD-06 (Contract Event Engine): Contract events write back to the contract master record (status field, last modified date).
- CD-07 (Procurement Integration): Draft contracts created by CD-07 are sourced into CD-01 for completion.
- GOS (SAP Generic Object Services): Document attachment uses standard SAP GOS; confirm availability in the ECC landscape.

---

## UX Implications

- Contract list view must show lifecycle status prominently (color-coded) — addresses PP-D.
- Mass upload must provide a downloadable error report per row — addresses PP-A.
- Exemption election must require explicit rationale text field (not just a checkbox).
- Contract display must show: header data, IFRS 16 classification, linked lease object, valuation runs (read-only link), event history (read-only link), attached documents.
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- ADR-006 Option B: Z contract master is the system of record — no RE-FX dependency at runtime.
- Domain data model (docs/architecture/domain-data-model.md): Domain 1 and Domain 2 schemas.
- docs/architecture/option-b-architecture.md: Overall Option B architectural constraints.
- specs/003-valuation-engine-z/requirements.md: Defines what input fields the valuation engine needs from CD-01.

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-CM-01 | What is the full list of mandatory IFRS 16 fields required at contract creation vs. allowed at a later stage? | Schema design and pre-flight validation rules | IFRS 16 Accountant |
| OQ-CM-02 | Is a parallel contract number (mapping to legacy or source system) required in the Z contract master? | Mass migration and integration design | SAP RE Functional Consultant |
| OQ-CM-03 | What GOS object type and archiving link object should be used for Z contract document attachments? | ECC technical design | ABAP Architect |
| OQ-CM-04 | Is Finance Controller approval required for all new contracts, or only above a materiality threshold? | Approval workflow design (CD-04 dependency) | Finance Controller + IFRS 16 Accountant |

---

## Design Risks

- **Risk:** Contract master schema is designed without full alignment with CD-03 valuation engine input requirements → valuation engine cannot consume the data. Mitigation: validate schema against CD-03 before committing to Phase 1 build.
- **Risk:** Mass upload template designed without input from end users → high rejection rate during portfolio onboarding. Mitigation: validate template with RE Contract Managers before Phase 0 completion.
- **Risk:** Change document logging not implemented from day one → audit gap for Day 1 contracts. Mitigation: change document must be part of the Phase 1 MVP, not a Phase 2 enhancement.
