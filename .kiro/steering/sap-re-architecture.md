---
inclusion: auto
description: SAP RE architecture reference — ECC landscape assumptions, Z object strategy, and integration patterns for the IFRS 16 addon under Option B.
---

# SAP RE/RE-FX Architecture Steering — IFRS 16 Addon

## SAP RE-FX Complexity Themes
SAP RE-FX (Flexible Real Estate Management) is a mature but complex module with significant configuration depth. Key complexity themes affecting the IFRS 16 addon:

1. **Condition types and condition purposes:** RE-FX uses condition types to model rent, service charges, and other payments. The IFRS 16 addon must correctly classify which conditions constitute lease payments vs. non-lease components vs. variable payments. Condition type mapping is a critical configuration decision — **to be confirmed with SAP RE Functional Consultant.**

2. **Contract object hierarchy:** RE-FX organizes data as Business Entity → Land → Building → Rental Unit → Rental Object → Contract. The IFRS 16 unit of account is the contract (or a component of a contract). The addon must navigate this hierarchy to aggregate payment data at the correct level.

3. **Date management:** RE-FX contracts have multiple date fields (valid from/to, notice dates, option dates, activation dates). Mapping these to IFRS 16 non-cancellable period and option periods requires precise logic — misinterpretation is a high risk.

4. **Cash flow generation:** RE-FX generates planned cash flows from conditions. The addon must read these projected cash flows and identify which are IFRS 16-relevant. Direct table access to cash flow tables must be validated for currency and period handling — **specific table names and reading methods to be confirmed.**

5. **Contract modifications in RE-FX:** A contract amendment in RE-FX can be implemented in multiple ways (condition change, contract extension, new contract). The addon must detect which RE-FX change type constitutes an IFRS 16 modification event.

6. **Partner and object assignments:** Cost center, profit center, and asset assignments on RE contracts determine how ROU assets and lease liabilities are posted. These assignments must flow correctly into the FI-AA and FI-GL postings.

---

## Integration Touchpoints

| System | Integration Type | Purpose | Status |
|--------|-----------------|---------|--------|
| RE-FX (RECN* tables) | Direct Z read | Contract data, conditions, cash flows | To be confirmed — specific tables |
| FI-AA (Asset Accounting) | BAPI / standard FM | Create/update ROU asset sub-number | To be confirmed — BAPI name |
| FI-GL (New GL) | Standard posting FM | Journal entries for lease liability | To be confirmed — posting approach |
| FI-AP (Accounts Payable) | Read only (v1) | Match lease payments to vendor invoices | Phase 2 |
| CO (Controlling) | Read only | Cost assignment for ROU depreciation | Phase 1 |
| FI-SL (Special Ledger) | Potential use for IFRS parallel ledger | IFRS 16 postings in parallel ledger if applicable | To be confirmed with client FI team |
| SAP CTS | Transport management | All Z object transports | Standard |
| SAP SLG1 | Application logging | Audit trail for all runs | Standard |

---

## Expected Object Categories

### RE-FX Objects Consumed (Read)
- Contract headers and line data (`VIOBJHEAD`, `VICNCOND`, and related — **specific table names to be confirmed**).
- Condition schedules and payment projections.
- Option and termination date fields.
- Business partner and object assignment data.
- Contract change history.

### FI Objects Created/Updated
- Asset sub-numbers for ROU assets in FI-AA.
- GL postings for lease liability recognition, interest accrual, depreciation, payment processing.
- CO cost assignments for period-end entries.

### Z Objects Created (see full list in `docs/technical/master-technical-design.md`)
- Contract extension table (IFRS 16 fields not in standard RE-FX).
- Calculation run and result tables.
- Parameter and configuration tables.
- Audit and decision trail tables.
- Modification and remeasurement history tables.

---

## Technical Debt Risks

| Risk | Description | Mitigation |
|------|-------------|-----------|
| RE-FX cash flow table dependency | Direct reads of internal RE-FX tables may break on patches or upgrades | Wrap all RE-FX reads in Z data provider classes with documented table references |
| FI-AA BAPI limitations | Standard asset BAPIs may not support all ROU asset creation scenarios | Identify requirements gap early; escalate to SAP Note search if needed |
| New GL document splitting | Document splitting rules may interact unexpectedly with Z postings | Test early with FI team; document splitting scenarios in test plan |
| Date interpretation | RE-FX date fields have complex business rules; wrong mapping = wrong IFRS 16 term | Dedicated date mapping unit with explicit test cases for all edge cases |
| Large volume performance | Customers with thousands of RE contracts need batch processing that can complete within close window | Performance test early; design for parallelization from the start |
| S/4HANA table changes | RE-FX table structures may change in S/4HANA migration | Abstract all RE-FX reads behind interfaces; migration compatibility notes in every Z object |

---

## UX Simplification Principles
The current SAP RE-FX UX is designed for specialist users. The IFRS 16 addon must reduce cognitive load for contract managers:

1. **Progressive disclosure:** Show only the fields relevant to the current IFRS 16 step. Do not expose the full Z table structure to the user.
2. **Smart defaults:** Pre-populate fields from existing RE-FX contract data wherever possible. The user should only enter data that is genuinely new.
3. **Validation with explanation:** When a validation fails, explain why in plain language — not SAP message codes.
4. **Decision wizards:** For complex judgments (lease term, modification type), use a wizard pattern that walks through the relevant criteria with the user.
5. **Calculation preview:** Before any posting, show the user the impact in plain language: "This will create a ROU asset of [X] and a lease liability of [X], depreciated over [N] months."
6. **Status visibility:** Users must always be able to see the IFRS 16 status of any RE contract: Not assessed / Exempt / Active / Pending modification / Remeasurement required.

---

## Migration-Aware Design for Future S/4HANA Alignment
The addon must be designed with the following S/4HANA migration principles:

1. **No use of deprecated ABAP:** Use only clean ABAP syntax compatible with ABAP 7.5+ and S/4HANA ABAP platform.
2. **Data model compatibility:** Z extension tables use the same primary key structures as RE-FX contract tables to ease future migration to S/4HANA RE extensions or standard IFRS 16 functionality if available.
3. **No direct SELECT on RECN tables without wrapper:** All RE-FX data reads go through a Z data provider class/interface — swap the implementation for S/4 without changing business logic.
4. **CDS views for reporting:** All reporting layer queries use ABAP CDS views — compatible with S/4HANA embedded analytics.
5. **Document migration path:** For every Z table, include a section in `docs/technical/master-technical-design.md` describing how data would be migrated if moving to standard S/4HANA functionality.
6. **Fiori readiness note:** All Z transactions should note if a Fiori equivalent design exists or could be built — even if not built for ECC v1. This prevents UI debt from blocking S/4 adoption.

> Flag every design decision that creates an ECC-specific constraint with: `[ECC-SPECIFIC: Review for S/4 migration — see migration notes in technical design]`
