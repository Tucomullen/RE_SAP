# Assumptions Register — RE-SAP IFRS 16 Addon

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial assumptions register |
| 0.2 | 2026-03-26 | Project Governance Lead | Added A-19 to A-24 (Option B normalization); updated A-07/A-08 to reflect Option B context |

---

## How This Register Works
An assumption is something the project accepts as true without formal confirmation. If an assumption turns out to be false, it may impact scope, design, or cost. Each assumption must be assigned a validation owner and a target date for confirmation.

**Validation Statuses:**
- `Unvalidated` — Assumed but not yet confirmed.
- `Confirmed` — Validated by the responsible human. Date and method recorded.
- `Rejected` — Found to be incorrect. Impact assessed and design updated.
- `Superseded` — Replaced by a more specific assumption.

---

## Assumptions Register

### A: SAP Landscape Assumptions

| ID | Assumption | Impact If Wrong | Owner | Status | Validation Date | Notes |
|----|-----------|----------------|-------|--------|----------------|-------|
| A-01 | SAP RE-FX (Flexible Real Estate) is the primary lease management system — no parallel legacy system or contract management tool running alongside | Design must be revised to integrate with additional systems; significant additional complexity | Project Governance Lead | **Unvalidated** | Target: Phase 0 T0-03 | Confirm with IT landscape owner |
| A-02 | SAP New GL (New General Ledger) is active in the system; document splitting may be relevant for segment reporting | Posting design may need to change if Old GL is still active | SAP FI Consultant | **Unvalidated** | Target: Phase 0 T0-03 | Critical for posting architecture |
| A-03 | A parallel IFRS ledger is NOT configured — IFRS 16 entries go into the main GL | If parallel ledger exists, posting approach must support it; may require separate entry set | SAP FI Consultant | **Unvalidated** | Target: Phase 0 T0-04 | Feeds into ADR decision on posting approach |
| A-04 | ABAP version 7.4 or higher is available on the ECC system | Lower ABAP versions restrict OO syntax and newer language features | ABAP Architect | **Unvalidated** | Target: Phase 0 T0-03 | Confirm with Basis team |
| A-05 | SAP transport system (CTS) is active; Z objects can be assigned to dedicated packages | Transport strategy invalid if packaging restrictions apply | Basis Team | **Unvalidated** | Target: Phase 0 T0-03 | Confirm with Basis team |
| A-06 | SAP Application Log (SLG1 / BAL_* function modules) is available and not restricted | Logging architecture must be redesigned if SLG1 is unavailable | Basis Team | **Unvalidated** | Target: Phase 0 T0-03 | Confirm SLG1 log object creation is permitted |
| A-07 | **[OPTION B CONTEXT]** If existing RE-FX contracts are migrated, RE-FX condition types can be read during the one-time migration extract to classify payment types. This is a migration-only read; RE-FX is NOT used at runtime. | If condition types cannot be mapped during migration, manual classification is required for migrated contracts | SAP RE Functional Consultant | **Unvalidated** | Target: Phase 0 T0-02 | Migration read-only; not a runtime dependency per ADR-006 |
| A-08 | **[OPTION B CONTEXT]** If existing RE-FX contracts are migrated, RE-FX option date fields can be read during the one-time migration extract. Z contract master will store option dates explicitly. This is a migration-only read; RE-FX is NOT used at runtime. | If option dates are not in RE-FX, manual entry is required during migration intake | SAP RE Functional Consultant | **Unvalidated** | Target: Phase 0 T0-02 | Migration read-only; not a runtime dependency per ADR-006 |

### B: Accounting Policy Assumptions

| ID | Assumption | Impact If Wrong | Owner | Status | Validation Date | Notes |
|----|-----------|----------------|-------|--------|----------------|-------|
| A-09 | The client has adopted the practical expedient to not separate non-lease components for all RE leases | Calculation must separate non-lease components; payment schedule more complex | IFRS 16 Accountant | **Unvalidated** | Target: Phase 0 T0-01 | Policy election — must be formally documented |
| A-10 | The client uses IBR as the discount rate (rate implicit in lease is not readily determinable for all leases) | If implicit rate is available, IBR process is supplementary; minor design impact | IFRS 16 Accountant | **Unvalidated** | Target: Phase 0 T0-01 | High probability this assumption is correct |
| A-11 | Short-term exemption is elected for leases ≤ 12 months within specific asset classes (classes TBC) | Exemption logic must be designed per policy; rules change if no election is made | IFRS 16 Accountant | **Unvalidated** | Target: Phase 0 T0-01 | Asset class list must be provided |
| A-12 | Low-value exemption threshold is USD 5,000 (IASB reference) — or another threshold the client has formally adopted | Threshold parameter must be updated; reportable impact on which contracts are exempt | IFRS 16 Accountant | **Unvalidated** | Target: Phase 0 T0-01 | Many entities use a higher threshold; confirm |
| A-13 | IBR determination process exists — Treasury or external advisor provides rates on request | If no IBR process exists, discount rates for new measurements cannot be obtained; blocks calculation | IFRS 16 Accountant + Treasury | **Unvalidated** | Target: Phase 0 T0-01 | Critical Path dependency |

### C: Project Governance Assumptions

| ID | Assumption | Impact If Wrong | Owner | Status | Validation Date | Notes |
|----|-----------|----------------|-------|--------|----------------|-------|
| A-14 | The project has access to an IFRS 16 Accountant with sufficient availability for Phase 0 workshops and ongoing approval tasks | Timeline extends; design assumptions unchecked; governance gates cannot be satisfied | Project Governance Lead | **Unvalidated** | Target: Project kickoff | Confirm resource availability and commitment |
| A-15 | The SAP RE Functional Consultant has detailed knowledge of the client's RE-FX configuration | Blueprint quality is reduced; field mapping is inaccurate; design assumptions are wrong | Project Governance Lead | **Unvalidated** | Target: Project kickoff | Confirm consultant competency and system access |
| A-16 | Data governance / legal review for AI service integration can be completed within Phase 2 timeline | Phase 3 AI integration is delayed; Epic 7 cannot be delivered as designed | Legal/DGO + Project Governance Lead | **Unvalidated** | Target: Phase 1 start | Begin engagement in Phase 0 |
| A-17 | The client will provide anonymized / synthetic SAP RE-FX data for development and UAT | Testing with real data creates compliance and privacy risk; delays if synthetic data is not provided | Project Governance Lead + Legal | **Unvalidated** | Target: Phase 0 T0-08 | Data provisioning process must be established |
| A-18 | The existing RE-FX contracts have sufficient data quality to proceed with IFRS 16 measurements without a major data cleansing project | A data cleansing project would be an additional scope item not currently planned | SAP RE Functional Consultant + IFRS 16 Accountant | **Unvalidated** | Target: Phase 0 T0-02 | Data quality assessment is part of T0-02 |

---

## D: Option B Architecture Assumptions

| ID | Assumption | Impact If Wrong | Owner | Status | Validation Date | Notes |
|----|-----------|----------------|-------|--------|----------------|-------|
| A-19 | All Z tables required for the Option B contract master (ZRIF16_CONTRACT, ZRIF16_PAYMENT_SCHED, ZRIF16_LEASEOBJ, etc.) can be created in the client's SAP system without namespace conflicts | Z table naming must be revised; transport strategy must be updated | ABAP Architect | **Unvalidated** | Target: Phase 0 T0-03 | Linked to OQ-ABAP-01; confirm with Basis team |
| A-20 | Standard SAP FI BAPIs (e.g., BAPI_ACC_DOCUMENT_POST) are available and sufficient for all IFRS 16 FI-GL posting scenarios required by the addon | Custom FM or alternative posting approach required; significant ABAP rework | FI Architect + ABAP Architect | **Unvalidated** | Target: Phase 0 T0-04 | Linked to OQ-FI-02; critical for CD-04 design |
| A-21 | Standard SAP FI-AA BAPIs are available and sufficient for ROU asset creation and depreciation activation without RE-FX intermediary | Custom FI-AA integration required; significant ABAP rework | FI-AA Specialist + ABAP Architect | **Unvalidated** | Target: Phase 0 T0-04 | Linked to OQ-FI-05; critical for CD-05 design |
| A-22 | The client does NOT have existing RE-FX contracts that require migration, OR the migration scope is manageable within Phase 0/Phase 1 timeline | Migration program becomes a separate project; Phase 1 timeline extends significantly | Project Governance Lead + SAP RE Functional Consultant | **Unvalidated** | Target: Phase 0 T0-02 | Linked to OQ-CM-06; critical path item |
| A-23 | The Option B Z addon can be deployed as a standalone package without modifying any SAP standard objects or requiring SAP Note application | Standard object modification required; Basis team involvement; transport risk | ABAP Architect | **Unvalidated** | Target: Phase 0 T0-03 | Core Option B principle; must be validated early |
| A-24 | The client's SAP ECC system has sufficient technical capacity (dialog work processes, background work processes, database performance) to support the Z addon's period-end batch processing requirements | Performance tuning or infrastructure upgrade required; delays Phase 1 go-live | ABAP Architect + SAP Basis | **Unvalidated** | Target: Phase 0 T0-03 | Linked to R-07 (performance risk) |

---

## Validated Assumptions
*(None confirmed yet — all validations pending Phase 0)*

---

## Rejected Assumptions
*(None rejected yet)*

---

## Next Actions
1. Project Governance Lead: schedule Phase 0 T0-01 (accounting policy workshop) immediately.
2. Project Governance Lead: confirm resource availability for IFRS 16 Accountant and SAP RE Functional Consultant.
3. ABAP Architect: confirm SAP landscape details (A-04, A-05, A-06, A-19, A-23, A-24) with Basis team.
4. SAP RE Functional Consultant: initiate data quality assessment to validate A-08, A-18, A-22.
5. FI Architect + ABAP Architect: confirm BAPI availability (A-20, A-21) in T0-04 workshop.

---

*Traceability: specs/000-master-ifrs16-addon/requirements.md | docs/governance/decision-log.md — ADR-006 | Last updated: 2026-03-26 | Updated by: Project Governance Lead (reconciliation pass)*
