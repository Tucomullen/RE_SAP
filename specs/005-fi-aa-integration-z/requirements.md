# Asset Engine Z (FI-AA) — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-05 — Asset Engine Z (FI-AA)

> **Option B Compliance:** CD-05 manages ROU assets directly in SAP FI-AA from the Z addon. RE-FX asset management is NOT used at runtime. The Z contract ID drives all FI-AA asset lifecycle operations. Asset class determination comes from the Z lease object master (CD-02).

---

## Business Objective

Implement direct FI-AA right-of-use (ROU) asset management from the Z addon. This domain covers the automatic creation of ROU asset sub-numbers on initial recognition, the maintenance of asset useful life on remeasurement, and the automatic retirement of ROU assets on lease termination. All FI-AA operations are driven by Z contract data and linked back to the Z contract ID in Z reference tables.

---

## Business Rationale

Under Option B, the Z addon is the system of record for all lease data including the ROU asset lifecycle. FI-AA asset creation, modification, and retirement must be triggered automatically by Z events (initial recognition, remeasurement, termination) rather than by manual FI-AA transactions. This eliminates the risk of FI-AA asset records becoming out of sync with lease contract data — a key operational pain point under the legacy approach.

---

## In-Scope (v1)

- ROU asset sub-number creation in FI-AA on initial recognition (triggered by CD-04 posting approval)
- Z reference table `ZRIF16_AA_LINK` (Domain 6): stores the Z contract ID ↔ FI-AA asset number/sub-number link
- Automatic asset useful life update in FI-AA on lease remeasurement (triggered by CD-06 modification event)
- Automatic ROU asset retirement in FI-AA on lease termination (triggered by CD-06 termination event)
- FI-AA asset display link from Z contract display (navigate to AS03 from contract)
- Asset class determination from lease object category (CD-02 → `ZRIF16_OBJ_CLASS` configuration table)

---

## Out-of-Scope (v1)

- FI-AA depreciation key configuration (FI/AA configuration team responsibility)
- FI-AA asset master data maintenance beyond what is required for IFRS 16 (e.g., insurance values)
- ROU asset impairment testing (Phase 2 or out of scope — IFRS 36 consideration)
- Component depreciation for ROU assets (out of scope unless requested)

---

## Actors

| Actor | Role |
|-------|------|
| System (Z addon) | Triggers FI-AA asset creation, useful life update, and retirement automatically on contract events |
| Finance Controller | Reviews and approves initial recognition (CD-04 approval gate) which triggers FI-AA asset creation |
| FI-AA Administrator | Configures asset classes, depreciation keys, and number ranges prior to go-live |
| Lease Accountant | Monitors FI-AA asset creation results; resolves errors |
| Auditor | Read-only access to FI-AA asset number per contract and asset change history |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-AA-01 | System | When initial recognition is posted (CD-04), a ROU asset sub-number is created in FI-AA automatically | Given a CD-04 initial recognition posting is successful, when the system completes the posting, then it automatically calls the FI-AA BAPI to create a ROU asset sub-number under the correct asset class, stores the asset number in `ZRIF16_AA_LINK`, and logs the creation in `ZRIF16_AUDIT` | — | CD-05 |
| US-AA-02 | System | The Z contract ID is linked to the FI-AA asset number in Z reference tables so that traceability is complete | Given a ROU asset is created for a contract, when the asset is created in FI-AA, then the Z contract ID and FI-AA asset number/sub-number are stored in `ZRIF16_AA_LINK` (Domain 6), and this link is visible in the Z contract display | PP-F | CD-05 |
| US-AA-03 | System | When a lease terminates (CD-06 termination event), the ROU asset is retired in FI-AA automatically | Given a termination event is confirmed in CD-06, when the event is processed, then the system calls the FI-AA retirement BAPI for the linked ROU asset, records the retirement date, and updates `ZRIF16_AA_LINK` with retirement status | — | CD-05 |
| US-AA-04 | System | When a lease is remeasured (CD-06 modification event), the FI-AA asset useful life is updated to reflect the new lease term | Given a remeasurement event modifies the lease term (extension or shortening), when the event is processed and a new CD-03 calculation run is approved, then the system calls the FI-AA BAPI to update the asset's planned depreciation end date to match the new lease end date | — | CD-05 |

---

## Process Flow

**Initial Recognition (FI-AA creation):**
1. Finance Controller approves initial recognition posting in CD-04.
2. CD-04 posts FI document successfully.
3. System reads: Z contract ID → `ZRIF16_AA_LINK` → confirms no asset already exists (duplicate guard).
4. System reads: lease object category → `ZRIF16_OBJ_CLASS` → determines FI-AA asset class.
5. System calls FI-AA BAPI (BAPI_FIXEDASSET_CREATE or equivalent) with: asset class, description, Z contract ID as reference, capitalization date = lease commencement date, planned useful life = lease term in months.
6. FI-AA returns asset number; system stores in `ZRIF16_AA_LINK`.
7. Creation event logged in `ZRIF16_AUDIT`.

**Remeasurement (useful life update):**
1. CD-06 modification event confirmed; CD-03 remeasurement run approved.
2. System reads new lease end date from approved CD-03 run.
3. System reads linked asset number from `ZRIF16_AA_LINK`.
4. System calls FI-AA BAPI to update planned useful life / depreciation end date.
5. Update logged in `ZRIF16_AUDIT`.

**Termination (asset retirement):**
1. CD-06 termination event confirmed.
2. System reads linked asset number from `ZRIF16_AA_LINK`.
3. System calls FI-AA retirement BAPI with: asset number, retirement date = lease end date.
4. `ZRIF16_AA_LINK` status updated to "Retired".
5. Retirement logged in `ZRIF16_AUDIT`.

---

## Edge Cases

- FI-AA asset creation fails (e.g., asset class not configured): system logs the error in `ZRIF16_AUDIT` per contract; the CD-04 posting is NOT rolled back (the FI document stands); the FI-AA creation is re-processable individually.
- Attempt to create a second ROU asset for a contract that already has one: system detects via `ZRIF16_AA_LINK` and blocks with explicit message.
- FI-AA useful life update fails on remeasurement: system logs error; Lease Accountant is alerted; manual FI-AA correction is guided by the system.
- ROU asset retired in FI-AA before the Z termination event is recorded: system detects mismatch during period-end reconciliation (upgrade impact detection — design.md section 11.5).
- Lease object category has no FI-AA asset class configured: system blocks initial recognition with explicit configuration error.

---

## Accounting Implications

- IFRS 16 para 22-24: ROU asset is measured at the amount of the lease liability plus initial direct costs, lease incentives paid, and dismantling obligations. The ROU asset carrying amount in FI-AA must match the CD-03 calculated value at inception.
- IFRS 16 para 31: ROU asset depreciation is straight-line over the lease term (or useful life if shorter). The FI-AA depreciation key and useful life must be set correctly at asset creation.
- IFRS 16 para 46: On modification that results in a new or additional right-of-use asset, a new sub-number may need to be created rather than updating the existing asset.
- ROU asset depreciation postings are handled by standard FI-AA depreciation runs — NOT by the Z addon. The Z addon only creates/modifies/retires the asset record.

---

## Integration Implications

- CD-02 (Lease Object Master): Asset class determination depends on `ZRIF16_OBJ_CLASS` configuration.
- CD-03 (Valuation Engine): ROU asset amount and lease term are taken from the approved CD-03 run.
- CD-04 (FI-GL Posting Engine): Initial recognition posting in CD-04 triggers the FI-AA creation step. The two must be coordinated in the same processing context.
- CD-06 (Contract Event Engine): Remeasurement and termination events trigger FI-AA updates.
- SAP FI-AA: BAPIs to be confirmed with FI-AA Architect (BAPI_FIXEDASSET_CREATE, BAPI_FIXEDASSET_CHANGE, BAPI_FIXEDASSET_RETIRE or direct RFC function modules).

---

## UX Implications

- Z contract display must show the linked FI-AA asset number (with navigation link to AS03) — addresses PP-F.
- FI-AA creation/update/retirement results must be visible in the contract event history.
- Error states (e.g., FI-AA creation failed after FI-GL posting succeeded) must be surfaced clearly in the contract status display — not buried in a log file.
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- CD-02 (Lease Object Master): Asset class configuration in `ZRIF16_OBJ_CLASS` — Phase 0 prerequisite.
- CD-03 (Valuation Engine): ROU asset amount — must be available in the approved calculation run.
- CD-04 (FI-GL Posting Engine): Initial recognition posting coordination.
- CD-06 (Contract Event Engine): Remeasurement and termination event signals.
- FI-AA Architect: Must confirm BAPI selection, asset class configuration, and depreciation key setup.

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-AA-01 | Which FI-AA BAPIs are available in the ECC system for asset create/change/retire? Confirm with FI-AA Architect. | Core FI-AA integration design | FI-AA Architect |
| OQ-AA-02 | Should ROU assets be created as sub-numbers under an existing main asset number or as standalone main assets? | FI-AA asset structure design | FI-AA Architect + Finance Controller |
| OQ-AA-03 | What is the depreciation key to be used for IFRS 16 ROU assets (straight-line monthly)? | FI-AA configuration | FI-AA Architect |
| OQ-AA-04 | When a modification results in a scope increase (new right-of-use asset under IFRS 16 para 44), should a new sub-number be created or should the existing asset be updated? | Remeasurement event handling | IFRS 16 Accountant + FI-AA Architect |

---

## Design Risks

- **Risk:** FI-AA BAPI not available or requires special authorisation in ECC landscape → integration must be redesigned using direct RFC calls. Mitigation: BAPI availability confirmed in Phase 0 technical spike.
- **Risk:** FI-AA asset creation succeeds but FI-GL initial recognition fails (or vice versa) → inconsistent state. Mitigation: define clear error recovery and reconciliation procedure; document in operations guide.
- **Risk:** Depreciation key misconfigured for ROU assets → wrong depreciation amounts → audit findings. Mitigation: FI-AA Architect must sign off on depreciation key before Phase 1 go-live.
