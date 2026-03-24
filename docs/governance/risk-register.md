# Risk Register — RE-SAP IFRS 16 Addon

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial risk register |

---

## Risk Scoring Guide
- **Likelihood:** 1=Rare, 2=Unlikely, 3=Possible, 4=Likely, 5=Almost Certain
- **Impact:** 1=Negligible, 2=Minor, 3=Moderate, 4=Significant, 5=Critical
- **Score:** Likelihood × Impact
- **Rating:** 1–5=Low, 6–12=Medium, 13–19=High, 20–25=Critical

---

## Risk Register

| ID | Category | Risk Description | Likelihood | Impact | Score | Rating | Mitigation | Owner | Status | Last Reviewed |
|----|----------|-----------------|-----------|--------|-------|--------|-----------|-------|--------|--------------|
| R-01 | Functional | RE-FX condition type mapping is more complex than anticipated — payment classification requires extensive analysis and configuration study | 4 | 4 | 16 | **HIGH** | Schedule dedicated blueprint workshop with SAP RE Functional Consultant in Phase 0. Do not start calculation engine design until mapping is confirmed. | SAP RE Functional Consultant | Open | 2026-03-24 |
| R-02 | Dependency | IBR/discount rate determination process not established — blocks calculation engine testing and initial measurements | 3 | 4 | 12 | **MEDIUM** | Flag as Critical Dependency D-03. Escalate to Finance team immediately. Phase 1 cannot complete without this. | IFRS 16 Accountant | Open | 2026-03-24 |
| R-03 | Technical | ABAP landscape constraints (ABAP version < 7.4, restrictive transport policies) limit design choices | 2 | 4 | 8 | **MEDIUM** | Confirm ABAP version and transport landscape in Phase 0 (T0-03). Design after confirmation. | ABAP Architect | Open | 2026-03-24 |
| R-04 | Accounting | IFRS 16 accounting policy elections not formally decided — blocks scope determination rules and calculation parameters | 4 | 5 | 20 | **CRITICAL** | Block Phase 1 design until T0-01 is complete. Engage IFRS 16 Accountant immediately to schedule policy sign-off. | IFRS 16 Accountant | Open | 2026-03-24 |
| R-05 | Strategic | S/4HANA migration timeline is accelerated — addon investment may be wasted if ECC goes out of service before Phase 2 | 2 | 4 | 8 | **MEDIUM** | Apply S/4-compatible design from day one (ADR-005). Document migration path for every Z object. | Project Governance Lead | Open | 2026-03-24 |
| R-06 | AI/Technology | Data governance review blocks AI service integration — Phase 3 AI assistant cannot proceed | 3 | 3 | 9 | **MEDIUM** | Initiate data governance review early (D-05). Design AI layer as optional — addon delivers value without AI assistant. | HUM-GOV + Legal | Open | 2026-03-24 |
| R-07 | Performance | Period-end batch cannot complete for large contract portfolios within the close window | 3 | 4 | 12 | **MEDIUM** | Performance test in Phase 1 with representative data volume. Design parallelization from day one (T1-14). Define performance targets before development (SLA TBC). | ABAP Architect | Open | 2026-03-24 |
| R-08 | Compliance | IFRS 16 standard amended during project — design decisions become obsolete mid-project | 2 | 3 | 6 | **MEDIUM** | Monitor IASB publications. Knowledge base flagging process for amendments (RAG curation). Design for flexibility (configurable parameters, not hardcoded rules). | IFRS 16 Accountant | Open | 2026-03-24 |
| R-09 | Data Quality | Existing RE-FX contracts have poor data quality — mass intake exercise required before IFRS 16 runs can execute | 4 | 3 | 12 | **MEDIUM** | Data quality assessment as part of Phase 0. Define data remediation plan before Phase 1 completion. | SAP RE Functional Consultant | Open | 2026-03-24 |
| R-10 | Security | AI service processes confidential financial data — data residency or DPA compliance issue | 3 | 4 | 12 | **MEDIUM** | AI assistant uses only anonymized/aggregated data in prompts. Full data governance review before AI integration (T3-01). | Legal/DGO | Open | 2026-03-24 |
| R-11 | Scope | Lessor accounting requirements emerge during project — scope creep risk | 3 | 3 | 9 | **MEDIUM** | Explicit out-of-scope statement in requirements.md. Change control process for scope additions. Estimate cost before accepting scope changes. | Project Governance Lead | Open | 2026-03-24 |
| R-12 | Integration | FI-AA BAPI/FM for ROU asset creation does not support required scenarios — custom posting approach needed | 3 | 3 | 9 | **MEDIUM** | Confirm FI-AA integration approach in Phase 0 (OQ-03). Identify gap early to allow solution design time. | ABAP Architect + FI Consultant | Open | 2026-03-24 |

---

## Risk Escalation Thresholds
- **CRITICAL (20–25):** Immediate escalation to Project Governance Lead. Work on dependent tasks is blocked until risk is mitigated or formally accepted.
- **HIGH (13–19):** Mitigation plan required before end of current phase. Owner reviews weekly.
- **MEDIUM (6–12):** Mitigation plan required. Owner reviews monthly.
- **LOW (1–5):** Monitor. Review at phase gates.

---

## Current Critical and High Risks (Attention Required)

| ID | Risk | Immediate Action Required |
|----|------|--------------------------|
| R-04 | Accounting policy elections not decided | **IMMEDIATE:** Schedule accounting policy workshop with IFRS 16 Accountant. Block Phase 1 design start. |
| R-01 | RE-FX mapping complexity | **Phase 0 Priority:** Schedule blueprint workshop (T0-02). |

---

## Risk Review Schedule
- **Phase Gates:** Full risk register review at every phase completion.
- **Weekly:** Project Governance Lead reviews Critical and High risks.
- **Monthly:** All risks reviewed; likelihood and impact re-assessed.
- **On new information:** Any new risk discovered is added within 1 business day.
