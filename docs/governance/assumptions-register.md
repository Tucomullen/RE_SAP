# Assumptions Register — RE-SAP IFRS 16 Addon

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial assumptions register |

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
| A-07 | RE-FX condition types are configured to reflect payment types that can be classified as IFRS 16 lease payments | If condition types do not distinguish payment types, additional configuration or Z mapping is required | SAP RE Functional Consultant | **Unvalidated** | Target: Phase 0 T0-02 | This is a key input to the field mapping |
| A-08 | RE-FX option date fields (extension, termination, purchase) are populated for all relevant contracts | If option dates are not in RE-FX, the lease term wizard cannot auto-populate; manual entry required | SAP RE Functional Consultant | **Unvalidated** | Target: Phase 0 T0-02 | Data quality assessment required |

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

## Validated Assumptions
*(None confirmed yet — all validations pending Phase 0)*

---

## Rejected Assumptions
*(None rejected yet)*

---

## Next Actions
1. Project Governance Lead: schedule Phase 0 T0-01 (accounting policy workshop) immediately.
2. Project Governance Lead: confirm resource availability for IFRS 16 Accountant and SAP RE Functional Consultant.
3. ABAP Architect: confirm SAP landscape details (A-04, A-05, A-06) with Basis team.
4. SAP RE Functional Consultant: initiate data quality assessment to validate A-08, A-18.
