---
inclusion: auto
---

# SAP ECC Integration Boundaries — Z Lease Management Addon

> **ARCHITECTURAL MANDATE:** This project operates under Option B. RE-FX is NOT the system of record. This document defines the ONLY permitted integration points between the Z addon and SAP ECC standard modules. See `.kiro/steering/option-b-target-model.md` for the full architectural constraint.

---

## ECC Integration Map — Permitted at Runtime

| Module | Integration Direction | BAPI / FM / Mechanism | Purpose | Confirmation Status |
|--------|-----------------------|----------------------|---------|---------------------|
| FI-GL (New GL) | WRITE | `BAPI_ACC_DOCUMENT_POST` or equivalent | Post lease liability recognition, interest accrual, amortization, payment matching | [TO BE CONFIRMED — FI Architect] |
| FI-GL | WRITE | Document reversal FM | Reverse previously posted lease documents | [TO BE CONFIRMED — FI Architect] |
| FI-AA | WRITE | `BAPI_FIXEDASSET_CREATE1` / sub-asset creation | Create ROU asset sub-numbers linked to Z contract ID | [TO BE CONFIRMED — FI-AA Specialist] |
| FI-AA | WRITE | Asset depreciation activation | Activate depreciation run for ROU assets | [TO BE CONFIRMED] |
| FI-AA | READ | Asset master reads | Validate asset exists before depreciation posting | Standard |
| CO (Controlling) | WRITE via FI | Account assignment on FI document (KOSTL, PRCTR) | Cost center / profit center assignment on lease entries | Standard FI posting feature |
| FI-AP | READ | Vendor line item tables | Match cash lease payments to vendor invoices (Phase 2) | [TO BE CONFIRMED — Phase 2] |
| SLG1 | WRITE | `BAL_LOG_CREATE`, `BAL_LOG_MSG_ADD`, `BAL_DB_SAVE` | Application-level audit logging for all addon runs | Standard |
| Number ranges | READ/WRITE | `NUMBER_GET_NEXT` | Z contract ID, Z run ID, Z event ID number ranges | Standard |
| Authorization | CHECK | `AUTHORITY-CHECK OBJECT` | All authorization object checks for addon transactions | Standard |
| CTS | STANDARD | Transport requests | All Z object deployments | Standard |
| Batch processing | WRITE | `JOB_OPEN` / `JOB_SUBMIT` / `JOB_CLOSE` | Period-end batch jobs for reclassification + posting | Standard |

---

## ECC Integration Map — NOT Permitted (Option B)

| Module / Table | Status | Reason |
|---------------|--------|--------|
| RE-FX (RECN* tables) | **PROHIBITED AT RUNTIME** | Z tables replace this — see OB-01 |
| VICNCOND / VIOBJHEAD | **PROHIBITED AT RUNTIME** | Z lease object master replaces this |
| RE-FX BAPIs (BAPI_RE_*) | **PROHIBITED** | No RE-FX processing in Option B |
| RE-FX condition types | **PROHIBITED** | Z payment model replaces condition type logic |
| RE-FX cash flow projection | **PROHIBITED** | Z valuation engine replaces this |
| RE-FX accounting engine | **PROHIBITED** | Direct FI BAPIs replace this |
| RE-FX option/notice dates at runtime | **PROHIBITED** | Z contract master manages these dates |

> **Exception — Migration Only:** During the one-time data migration (if client has existing RE-FX contracts), a dedicated migration program may READ RE-FX tables to extract and load into Z tables. This is a batch-only, one-time operation, not a runtime integration.

---

## FI-GL Integration Design Principles

1. **Direct document creation:** Every lease accounting event (recognition, interest, amortization, payment, reversal) creates a FI document directly via standard BAPI — no intermediate RE-FX step.
2. **Reference traceability:** Every FI document must carry the Z contract ID and Z calculation run ID in reference fields (XBLNR, BKTXT, or custom reference fields — [TO BE CONFIRMED]).
3. **Ledger approach:** If the client uses parallel ledgers for IFRS 16 vs. local GAAP, determine ledger configuration at T0-04 workshop. See `docs/governance/decision-log.md` ADR-004.
4. **Document splitting:** Test early with FI team — document splitting rules may interact with Z-generated postings.
5. **Simulation before posting:** All posting logic must support a simulation mode (no FI document created) for preview purposes.
6. **Error isolation:** If one contract fails to post, it must not block the entire batch. Error log per contract is mandatory.

---

## FI-AA Integration Design Principles

1. **ROU asset = sub-asset:** Each Z lease contract that generates a ROU asset maps to one FI-AA sub-asset number. The link between Z contract ID and asset sub-number is stored in Z integration reference table.
2. **Asset class:** A dedicated asset class for ROU assets must be configured in FI-AA. This is a client configuration activity, not an addon development activity. Flag as `[TO BE CONFIRMED — FI-AA Configuration]`.
3. **Depreciation key:** The depreciation method for ROU assets (straight-line over lease term) must align with the asset class depreciation key. Confirm with FI-AA team.
4. **No manual asset transactions:** ROU asset creation, depreciation, and derecognition are driven exclusively by the Z addon. Users do not manually post to ROU assets via standard FI-AA transactions.
5. **Asset derecognition on termination:** When a lease terminates, the addon derecognizes the ROU asset via FI-AA BAPIs, not manually.

---

## CO Integration Design Principles

1. **Account assignment propagation:** Cost center, profit center, and business area assignments from the Z contract master are propagated to all FI-GL documents at posting time.
2. **No separate CO posting step:** CO assignments flow via the FI document (account assignment objects on line items) — no separate CO posting needed.
3. **Profit center ledger:** If profit center ledger is active, confirm whether parallel postings are required — [TO BE CONFIRMED — FI/CO Architect].

---

## Technical Debt and ECC-Specific Risks

| Risk | Description | Mitigation Under Option B |
|------|-------------|--------------------------|
| FI-GL BAPI limitations | `BAPI_ACC_DOCUMENT_POST` may have field constraints for complex multi-ledger scenarios | Identify constraints in T0-04 workshop; design wrapper class early |
| FI-AA BAPI coverage gaps | Sub-asset creation, impairment, partial derecognition may have BAPI limitations | Identify in T0-04; document escalation path to SAP Notes |
| New GL document splitting | Splitting rules can reject Z-generated documents | Test early; document splitting scenarios per lease accounting entry type |
| Number range conflicts | Z number range objects must not conflict with standard SAP ranges | Define Z-specific number range objects at T0-03 |
| Authorization object design | Custom auth objects must not conflict with RE-FX auth objects still in system | Design Z_RIF16_AUTH_* objects cleanly separate from SAP_RE_* |
| S/4 FI-GL BAPI changes | FI BAPIs may change in S/4; migration compatibility required | Wrap all FI calls in adapter classes; flag each with `[ECC-SPECIFIC: Review for S/4 migration]` |

---

## UX Design Principles (Option B — Z Workspace)

Since Option B replaces RE-FX UI entirely, the UX must be designed ground-up for usability:

1. **Dedicated Z Workspace:** All lease management activities happen in a single Z workspace transaction. Users do not navigate to RECN, FBL3N directly for lease management.
2. **Role-based entry points:** Different views for RE Contract Manager, Lease Accountant, Finance Controller — each sees only their tasks.
3. **Guided contract creation:** Wizard-style creation for both individual and mass contract intake.
4. **Mass upload support:** Excel/CSV-based mass creation for portfolio onboarding.
5. **Simulation before action:** Every calculation and posting can be previewed before execution.
6. **Event history visibility:** Users always see the full lifecycle of a contract, not just current state.
7. **Accounting preview:** Before posting, show the exact FI document lines that will be created.
8. **Status indicators:** Every contract shows its IFRS 16 lifecycle status at a glance.
9. **No SAP message codes to users:** All validation errors shown in plain business language.
10. **S/4 Fiori-ready design:** Z transactions designed to be wrappable in Fiori apps for S/4 — even if Fiori is not built for ECC v1.

---

## S/4HANA Migration Awareness Under Option B

Option B is architecturally cleaner for S/4 migration than Option A:

| Aspect | Option A Risk | Option B Status |
|--------|---------------|-----------------|
| RE-FX table changes in S/4 | HIGH — RECN* structures change | NOT APPLICABLE — Z tables owned |
| RE-FX BAPIs in S/4 | MEDIUM — RE-FX APIs change | NOT APPLICABLE |
| FI-GL BAPIs in S/4 | LOW — FI APIs stable | SAME — standard FI BAPIs used |
| FI-AA BAPIs in S/4 | LOW-MEDIUM | SAME — flag each with ECC-SPECIFIC |
| Z table migration | Moderate — needs FK cleanup | CLEAN — Z tables self-owned |
| CDS view reporting | Compatible | Compatible — build CDS from start |

Flag every ECC-specific FI/FI-AA assumption with: `[ECC-SPECIFIC: Review for S/4 migration — see migration notes in technical design]`
