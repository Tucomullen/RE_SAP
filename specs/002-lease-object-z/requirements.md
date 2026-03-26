# Lease Object Master Z — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-02 — Lease Object Master Z

> **Option B Compliance:** CD-02 replaces the RE-FX object hierarchy entirely. `ZRIF16_LEASE_OBJ` is the Z lease object master table (Domain 2). RE-FX real estate objects are NOT accessed at runtime for lease object data.

---

## Business Objective

Define and implement the Z lease object master that classifies and describes the asset being leased. The lease object provides asset type, subtype, and attribute data used to determine the FI-AA asset class for the ROU asset and to support IFRS 16 scope analysis (e.g., low-value asset threshold assessment by asset category).

---

## Business Rationale

Under Option B (ADR-006), the lease object is a standalone Z entity that is created independently of RE-FX. A lease object can be reused across multiple contracts (e.g., a vehicle fleet model shared by many individual vehicle leases). The lease object category drives downstream FI-AA asset class determination (CD-05), making it a foundational data element that must be defined before any valuation or posting can occur.

---

## In-Scope (v1)

- Z lease object master table `ZRIF16_LEASE_OBJ` — full schema definition
- Lease object creation and maintenance transaction
- Lease object type and subtype classification (e.g., Real Estate, Vehicle, Equipment, IT)
- Lease object attribute capture (description, location, registration number where applicable)
- Link between lease object and FI-AA asset class (via configuration table)
- Reuse of a lease object across multiple contracts (one-to-many relationship)
- Lease object display — showing all linked contracts

---

## Out-of-Scope (v1)

- ROU asset creation in FI-AA (CD-05 — specs/005-fi-aa-integration-z/)
- Valuation calculation (CD-03 — specs/003-valuation-engine-z/)
- Low-value threshold automated assessment (requires policy configuration — Phase 2)

---

## Actors

| Actor | Role |
|-------|------|
| RE Contract Manager | Creates and maintains lease objects; assigns them to contracts |
| Finance Controller | Reviews asset class assignment for new object types |
| System (batch) | Reads lease object category to determine FI-AA asset class during initial recognition |
| Auditor | Read-only access to lease object record and contract linkage |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-LO-01 | RE Contract Manager | I can register a new lease object with type, subtype, and attributes so that it can be assigned to a lease contract | Given no lease object exists for an asset, when the manager creates a new lease object with mandatory fields (type, subtype, description), then a `ZRIF16_LEASE_OBJ` record is created and is available for contract assignment | — | CD-02 |
| US-LO-02 | RE Contract Manager | I can reuse an existing lease object across multiple contracts so that fleet or portfolio objects are not duplicated | Given a lease object exists, when the manager assigns it to a new contract, then the object is linked to the new contract without requiring a new object record, and the object display shows all linked contracts | — | CD-02 |
| US-LO-03 | System | The lease object category determines the FI-AA asset class for the ROU asset at initial recognition | Given a lease object with category "Vehicle" is assigned to an active contract, when initial recognition is triggered (CD-05), then the system uses the category-to-asset-class mapping table to determine the FI-AA asset class, not a manual user entry | — | CD-02 |

---

## Process Flow

1. RE Contract Manager opens the lease object maintenance transaction.
2. Manager selects object type and subtype from configured value lists.
3. Manager enters required attributes (description, location, identifier where applicable).
4. System validates that the object type/subtype has a configured FI-AA asset class mapping.
5. Lease object is saved to `ZRIF16_LEASE_OBJ`.
6. Manager assigns the lease object to one or more contracts in the contract master (CD-01).
7. On initial recognition (CD-05), system reads lease object category to determine FI-AA asset class.

---

## Edge Cases

- Attempt to assign a lease object with no FI-AA asset class mapping: system blocks with explicit configuration error.
- Attempt to delete a lease object that is linked to active contracts: deletion blocked; object may only be deactivated.
- Lease object type not in the configured value list: system blocks; administrator must add the type before object creation is possible.
- Two contracts with different FI-AA asset class requirements assigned to the same lease object: system warns; analyst must review whether the reuse is appropriate.

---

## Accounting Implications

- IFRS 16 para 5(b): Low-value asset exemption is assessed by reference to the underlying asset type when new. The lease object category and its configured low-value threshold flag support this assessment.
- IFRS 16 para 47: ROU asset is presented by class of underlying asset (e.g., real estate, vehicles, other). The lease object category drives this presentation in CD-09 reporting.
- The lease object is an IFRS 16 data element — it does not represent a financial instrument by itself.

---

## Integration Implications

- CD-01 (Contract Master): Lease object is assigned to the contract; the link is stored in `ZRIF16_CONTRACT`.
- CD-05 (FI-AA Asset Engine): Lease object category drives the FI-AA asset class for ROU sub-number creation.
- CD-09 (Reporting): Lease object category drives the asset class grouping in rollforward reports.
- Configuration table required: `ZRIF16_OBJ_CLASS` (object type/subtype → FI-AA asset class mapping).

---

## UX Implications

- Lease object type and subtype must be searchable value lists (F4 help), not free-text fields.
- Lease object display must show all linked contracts (list with status and contract ID).
- FI-AA asset class mapping must be visible on the object record for transparency.
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- CD-01 (Contract Master Z): Lease object is a prerequisite for contract activation.
- CD-05 (FI-AA Integration): Asset class mapping configuration must be defined before Phase 1 go-live.
- docs/architecture/domain-data-model.md: Domain 2 schema.
- FI-AA asset class list: must be provided by FI Architect for configuration table population.

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-LO-01 | What is the complete taxonomy of lease object types and subtypes required for the portfolio? | Schema design for `ZRIF16_LEASE_OBJ` and configuration tables | SAP RE Functional Consultant + RE Contract Managers |
| OQ-LO-02 | Which FI-AA asset classes are available in the ECC system and how do they map to IFRS 16 asset categories? | CD-05 integration and CD-09 reporting groupings | FI Architect |
| OQ-LO-03 | Is there a requirement to support multiple FI-AA asset class assignments for the same lease object type (e.g., country-specific asset classes)? | Configuration table design | FI Architect |

---

## Design Risks

- **Risk:** Lease object type taxonomy is too narrow → new object types require configuration changes mid-project. Mitigation: collect full portfolio object type list in Phase 0 before schema design is locked.
- **Risk:** FI-AA asset class mapping not validated before Phase 1 build → initial recognition (CD-05) fails for all contracts. Mitigation: FI-AA configuration is a Phase 0 prerequisite gate item.
