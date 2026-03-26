# Risk Register — RE-SAP IFRS 16 Addon

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial risk register |
| 0.2 | 2026-03-24 | Remediation | Added pain-point-derived operational risks R-13 to R-22 |
| 0.3 | 2026-03-26 | Project Governance Lead | Added Option B architecture risks R-23 to R-26; updated R-01 to reflect Option B context |

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
| R-01 | Functional | **[OPTION B CONTEXT]** RE-FX data quality for migration extract is poor — payment classification, option dates, and contract attributes require extensive manual remediation before Z table load | 4 | 4 | 16 | **HIGH** | Schedule dedicated T0-02 blueprint workshop. Data quality assessment is a Phase 0 gate. Migration scope must be confirmed before Phase 1 begins. | SAP RE Functional Consultant | Open | 2026-03-26 |
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

| R-13 | UX/Operational | Validation gaps allow contracts with configuration errors (wrong dates, currency, object type) to reach the calculation engine — downstream failures occur silently | 4 | 4 | 16 | **HIGH** | Implement pre-flight validation with plain-language messages at contract intake (US-10.1). Block calculation until all mandatory fields pass validation. | SAP RE Functional Consultant | Open | 2026-03-24 |
| R-14 | UX/Operational | Users cannot interpret retroactive change postings and special movements — reconciliation delays and audit findings | 4 | 3 | 12 | **MEDIUM** | Attach machine-generated plain-language explanation to every system-generated special posting (US-10.2). Link to IFRS 16 paragraph reference. | Lease Accountant + ABAP Architect | Open | 2026-03-24 |
| R-15 | Process | ZRE009 reclassification fails at period-end due to unmet prerequisites — period close is blocked | 4 | 4 | 16 | **HIGH** | Implement pre-reclassification checklist that validates all prerequisites before ZRE009 runs (US-10.3). Block with remediation guidance. | Lease Accountant + ABAP Architect | Open | 2026-03-24 |
| R-16 | Data Quality | Unvaluated contract changes cause period-end batch to produce incorrect results without warning — silent data quality failure | 4 | 4 | 16 | **HIGH** | Implement pre-batch valuation check — batch blocked until all changes are valuated (US-10.5). Display affected contract list. | Lease Accountant | Open | 2026-03-24 |
| R-17 | Data Quality | Date mismatches in start/end/condition dates create duplicate entries or valuation differences — cascading period-end errors | 3 | 4 | 12 | **MEDIUM** | Date consistency validation at contract intake and before every calculation run (US-10.1). Blocking alerts for date anomalies. | RE Contract Manager + ABAP Architect | Open | 2026-03-24 |
| R-18 | Technical | Old contracts affected by upgrade data quality issues (clearing vs. expense differences) cannot be processed without manual remediation — upgrade readiness risk | 3 | 3 | 9 | **MEDIUM** | Upgrade impact detection report and guided remediation workflow (US-10.7). Test coverage for upgrade scenarios in regression suite. | ABAP Architect + IT/ABAP Support | Open | 2026-03-24 |
| R-19 | Compliance | Country-specific rules for Poland advance payment contracts are not implemented — non-compliance for local portfolio | 2 | 4 | 8 | **MEDIUM** | Country-specific rule configuration for advance-payment contracts (US-10.9). Pre-flight check for useful life consistency. Confirm scope with project governance. | Project Governance Lead + Local Finance | Open | 2026-03-24 |
| R-20 | UX | Amortization is only visible at asset class level — users cannot perform contract-level follow-up, blocking IFRS 16 disclosure work | 4 | 3 | 12 | **MEDIUM** | Contract-level amortization report as standard feature (US-10.6). All schedule data stored queryable by contract ID. | Lease Accountant | Open | 2026-03-24 |
| R-21 | UX | Foreign currency contract complexity causes user errors in posting parameter configuration — incorrect balances and misinterpretation | 3 | 3 | 9 | **MEDIUM** | Currency-specific validation and configuration guide at intake (US-10.10). Plain-language balance explanation for FC contracts. | RE Contract Manager + FI Architect | Open | 2026-03-24 |
| R-22 | Documentation | User manual is outdated and in English only — users escalate common questions to specialists, increasing error rate and project support burden | 4 | 2 | 8 | **MEDIUM** | Living user manual with mandatory update process on every process change (US-10.9). Spanish-language baseline. Role-based quick reference guides. | AI/Kiro Practitioner + HUM-ACC | Open | 2026-03-24 |

---

## Option B Architecture Risks (R-23 to R-26)

> These risks are specific to the Option B standalone Z addon architecture (ADR-006). They must be reviewed at every phase gate.

| ID | Category | Risk Description | Likelihood | Impact | Score | Rating | Mitigation | Owner | Status | Last Reviewed |
|----|----------|-----------------|-----------|--------|-------|--------|-----------|-------|--------|--------------|
| R-23 | Architecture | FI BAPI coverage gap — standard SAP FI BAPIs (BAPI_ACC_DOCUMENT_POST or equivalent) do not support all IFRS 16 posting scenarios required by the addon (e.g., multi-ledger, document splitting edge cases) | 3 | 5 | 15 | **HIGH** | Confirm BAPI coverage in T0-04 workshop (OQ-FI-02). Design FI posting interface (ZIF_RIF16_POSTING_HANDLER) to allow alternative posting FM if BAPI is insufficient. Do not start CD-04 ABAP development until confirmed. | FI Architect + ABAP Architect | Open | 2026-03-26 |
| R-24 | Architecture | FI-AA BAPI coverage gap — standard FI-AA BAPIs do not support ROU sub-asset creation or depreciation activation in the required manner, forcing a custom posting approach | 3 | 4 | 12 | **MEDIUM** | Confirm FI-AA BAPI availability in T0-04 workshop (OQ-FI-05). Design FI-AA interface (ZIF_RIF16_ASSET_HANDLER) to allow alternative approach. Prototype in Phase 0 sandbox. | FI-AA Specialist + ABAP Architect | Open | 2026-03-26 |
| R-25 | Architecture | Option B scope creep — stakeholders request RE-FX runtime integration after ADR-006 is accepted, creating pressure to reintroduce RE-FX dependencies and violate Option B governance rules | 3 | 4 | 12 | **MEDIUM** | ADR-006 is non-negotiable. Any RE-FX runtime integration request must be escalated to Project Governance Lead and assessed against OB-01 to OB-10 rules. The `option-b-architecture-guard` hook enforces this automatically. | Project Governance Lead | Open | 2026-03-26 |
| R-26 | Migration | Migration program underestimated — if the client has a large RE-FX contract portfolio, the one-time migration extract, validation, and Z table load may require a separate project track that delays Phase 1 go-live | 3 | 4 | 12 | **MEDIUM** | Confirm migration scope in T0-02 (OQ-CM-06). If migration scope is large, create a dedicated migration workstream with its own timeline. Do not allow migration complexity to delay Phase 1 core engine delivery. | Project Governance Lead + SAP RE Functional Consultant | Open | 2026-03-26 |

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
| R-01 | RE-FX data quality for migration extract | **Phase 0 Priority:** Schedule T0-02 blueprint workshop. Data quality assessment is a Phase 0 gate. |
| R-23 | FI BAPI coverage gap | **Phase 0 Priority:** Confirm BAPI coverage in T0-04. Do not start CD-04 ABAP development until confirmed. |
| R-13 | Contract configuration errors reach calculation engine | **Phase 1 Priority:** Implement pre-flight validation at contract intake (Epic 10, US-10.1). |
| R-15 | ZRE009 reclassification blocked at period-end | **Phase 1 Priority:** Implement ZRE009 pre-flight checklist (Epic 10, US-10.3). |
| R-16 | Unvaluated changes cause silent batch failures | **Phase 1 Priority:** Implement pre-batch valuation check (Epic 10, US-10.5). |

---

## Risk Review Schedule
- **Phase Gates:** Full risk register review at every phase completion.
- **Weekly:** Project Governance Lead reviews Critical and High risks.
- **Monthly:** All risks reviewed; likelihood and impact re-assessed.
- **On new information:** Any new risk discovered is added within 1 business day.
