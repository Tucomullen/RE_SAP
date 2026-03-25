# Master Requirements — IFRS 16 Z Addon for SAP RE/RE-FX

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial requirements baseline |
| 0.2 | 2026-03-24 | Remediation | Added EPIC 10 (pain point mitigation), updated personas, added PP-driven ACs to existing epics, added risks R-13 to R-22 |

---

## 1. Product Problem Statement
Organizations using SAP ECC RE/RE-FX for lease management lack a native, auditable IFRS 16 automation capability. Finance teams operate with manual spreadsheets external to SAP, producing calculation errors, audit trail gaps, and significant close-process bottlenecks. The Z addon eliminates this gap by embedding an IFRS 16 calculation, governance, and disclosure engine directly into the SAP RE/RE-FX landscape.

---

## 2. Business Objectives

| # | Objective | Measurable Outcome |
|---|-----------|-------------------|
| BO-1 | Eliminate external spreadsheets for IFRS 16 management | >90% of active leases managed in system by end of Phase 2 |
| BO-2 | Reduce period-end IFRS 16 processing time | >70% reduction vs. current state |
| BO-3 | Achieve zero audit findings on IFRS 16 calculation traceability | Zero findings in first post-go-live external audit |
| BO-4 | Enable self-service for contract managers | RE contract managers can complete IFRS 16 data capture without accountant support in >80% of cases |
| BO-5 | Produce disclosure-ready output | IFRS 16 disclosure pack available within 1 business day of period-end close |
| BO-6 | Support modifications and remeasurements in-system | 100% of contract events processed in system with full audit trail |

---

## 3. Personas

| ID | Persona | Role | Key Goals | Key Pain Points (documented) |
|----|---------|------|-----------|------------------------------|
| P1 | Lease Accountant | Performs IFRS 16 measurements, approves calculations, handles modifications | Accurate calculations, fast close, audit-ready evidence | PP-B (retroactive postings), PP-C (ZRE009 failures), PP-E (missing valuation), PP-F (unexplained movements), PP-G (no contract-level amortization), PP-H (broken old contracts) |
| P2 | RE Contract Manager | Creates and maintains RE-FX contracts | Efficient data entry, clear guidance on what is needed | PP-A (configuration errors), PP-L (date mismatches), PP-J (extension/rescission sequence), PP-K (advance payment rules), PP-D (contract visibility) |
| P3 | Finance Controller | Approves postings, oversees compliance | Confidence in accuracy, visibility of status | PP-F (unexplained special movements), PP-I (foreign currency interpretation), PP-G (aggregate amortization gaps), PP-C (period-end blocking errors) |
| P4 | Internal/External Auditor | Reviews IFRS 16 compliance evidence | Complete, traceable evidence | PP-F (unexplained movements), PP-B (retroactive postings without explanation), PP-G (amortization not traceable by contract) |
| P5 | IT/ABAP Support | Maintains the addon | Clean architecture, good documentation | PP-H (upgrade impact management), PP-K (country-specific rules needing config) |
| P6 | Project Governance Lead | Owns project delivery | Risk visibility, decision traceability | Scattered decisions, no single governance view |
| P7 | Local Finance User (e.g. Poland) | Executes country-specific IFRS 16 processes | Process works for local contract types | PP-K (advance payment case), PP-I (foreign currency), PP-M (manual in wrong language) |

---

## 4. Epics and User Stories

---

### EPIC 1: Contract Intake and Guided Data Capture
**Goal:** Enable RE Contract Managers to capture all IFRS 16-required data when creating or amending a RE contract, with system guidance and validation.

**User Stories:**

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-1.1 | As a RE Contract Manager, I want the system to prompt me for IFRS 16-relevant fields when I create a new RE contract, so I don't need to know IFRS 16 rules to provide the right data. | Given a new RE-FX contract is saved, When the system detects it may be IFRS 16-relevant, Then the IFRS 16 data capture wizard is triggered. The wizard pre-populates all fields derivable from the RE-FX contract. Missing mandatory fields are highlighted. |
| US-1.2 | As a RE Contract Manager, I want the system to validate my entries with plain-language explanations, so I understand what I'm entering and why. | Given the user enters data in the IFRS 16 intake form, When a validation error occurs, Then the system displays a plain-language explanation (not a SAP message code) identifying the field and why the value is invalid. |
| US-1.3 | As a RE Contract Manager, I want to see the IFRS 16 status of every RE contract I manage, so I know which ones are complete, which are pending, and which need attention. | Given a list of RE contracts, When the user accesses the IFRS 16 status view, Then each contract shows one of: Not Assessed / Exempt / Active / Pending Modification / Remeasurement Required / Error. |
| US-1.4 | As a Lease Accountant, I want to review and approve the data capture output before IFRS 16 calculation begins, so I maintain control over the inputs. | Given data capture is complete, When the accountant opens the review screen, Then they see all captured IFRS 16 inputs with source references. Approval action locks the inputs and triggers calculation eligibility. |

---

### EPIC 2: IFRS 16 Decision Support and Explainability
**Goal:** Support the Lease Accountant in making IFRS 16 judgments (scope, exemptions, lease term, discount rate) with system-guided decision tools and full documentation of reasoning.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-2.1 | As a Lease Accountant, I want a guided lease identification checklist, so the system helps me apply the three-criteria test and documents my conclusion. | Given a contract under review, When the accountant opens the identification wizard, Then the system presents the three IFRS 16 criteria, captures the accountant's assessment for each, and generates a scoping memo with the conclusion and supporting narrative. |
| US-2.2 | As a Lease Accountant, I want the system to flag potential short-term and low-value exemptions based on the contract data, so I can make the exemption determination faster. | Given a contract is identified as potentially exempt, When the accountant opens the exemption screen, Then the system presents the relevant policy (asset class election / per-contract policy) and the contract's qualifying data, and captures the accountant's determination. |
| US-2.3 | As a Lease Accountant, I want the system to present a lease term assessment screen with all option dates and their consequences pre-populated, so I can make the "reasonably certain" judgment with full information. | Given a contract with option dates, When the accountant opens the lease term screen, Then all options are listed with contractual data, IFRS 16 guidance note, and a field to record the assessment and rationale. The approved term feeds the calculation. |
| US-2.4 | As a Finance Controller, I want to view the explanation of any IFRS 16 calculation in plain language — what was assumed and why — so I can approve it with confidence. | Given a completed calculation, When the controller opens the calculation explainer, Then the system presents: lease term used + rationale, discount rate + source, payment schedule + classification, and a plain-language summary of the accounting treatment. |

---

### EPIC 3: Calculation and Recalculation Orchestration
**Goal:** Automate the IFRS 16 amortization schedule generation, period-end calculation run, and recalculation when inputs change.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-3.1 | As a Lease Accountant, I want the system to generate a complete IFRS 16 amortization schedule from the approved inputs, so I don't need to build one manually. | Given approved IFRS 16 inputs (term, rate, payment schedule), When the calculation is triggered, Then the system generates: opening balances, period-by-period interest, liability reduction, depreciation, and closing balances for the full lease term. Schedule is stored in Z tables and viewable in SAP. |
| US-3.2 | As a Lease Accountant, I want to run a period-end calculation batch for all active leases, so I can generate all IFRS 16 journal entries for the period in one run. | Given the period-end batch job is executed with a valid period parameter, When the run completes, Then all active leases have period entries calculated, a summary report is available showing entries per lease, and an exception list shows any leases that could not be processed. |
| US-3.3 | As a Finance Controller, I want the calculation results to be visible before posting, so I can review and approve before any FI entries are created. | Given a completed calculation run, When the controller opens the approval screen, Then period entries for each lease are displayed in a pre-posting review list. The controller can approve the full run or flag individual leases for review. Posting is blocked until approval is granted. |

---

### EPIC 4: Modification and Remeasurement Support
**Goal:** Detect IFRS 16 modification and remeasurement events, guide the accountant through the correct treatment, and produce the required calculation adjustments and evidence.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-4.1 | As a Lease Accountant, I want the system to automatically detect when an RE contract change constitutes a potential IFRS 16 modification, so I don't miss events. | Given a contract amendment is saved in RE-FX, When the system detects a change that may be IFRS 16-relevant (payment change, term change, scope change, option exercise), Then a modification alert is created and the Lease Accountant is notified. |
| US-4.2 | As a Lease Accountant, I want a modification classification wizard that guides me through the IFRS 16 criteria to determine if the event is a new separate lease or an adjustment to the existing lease, so I apply the correct treatment. | Given a modification alert is opened, When the accountant works through the wizard, Then the system presents the relevant IFRS 16 criteria with the contract data, captures the accountant's assessment, produces a modification memo, and proposes the calculation approach. |
| US-4.3 | As a Lease Accountant, I want to see a before/after comparison of balances after a modification is processed, so I can verify the impact before approving. | Given a modification calculation is complete, When the accountant reviews the result, Then a delta table shows: OLD ROU, OLD liability, NEW ROU, NEW liability, any gain/loss, and the revised schedule. The accountant approves or rejects the result. |

---

### EPIC 5: Posting and Reconciliation Support
**Goal:** Generate FI journal entries from approved IFRS 16 calculations and provide reconciliation tools to verify posting accuracy.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-5.1 | As a Lease Accountant, I want approved IFRS 16 calculations to generate FI journal entries automatically, so I don't need to key entries manually. | Given a calculation run is approved, When the posting function is executed, Then FI documents are created for all period entries (interest accrual, depreciation, liability reduction), each carrying the calculation run ID as a reference. Posting is blocked without approval. |
| US-5.2 | As a Finance Controller, I want a reconciliation report that compares IFRS 16 ledger balances to the Z calculation schedule, so I can confirm no posting discrepancies exist. | Given the period-end posting run is complete, When the reconciliation report is generated, Then the report shows for each lease: schedule balance vs. GL balance, difference, and status (Reconciled / Difference). Differences must be explainable and documented. |

---

### EPIC 6: Disclosure Support
**Goal:** Aggregate IFRS 16 disclosure data from the calculation tables and produce disclosure-ready output aligned with IFRS 16 paragraphs 52–60.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-6.1 | As a Finance Controller, I want the system to generate a maturity analysis of lease liabilities, so I can populate the IFRS 16 note in the financial statements. | Given the disclosure pack function is executed for a reporting period, When the output is generated, Then the system produces a maturity analysis table (within 1 year / 1-5 years / over 5 years) with undiscounted future payments for all active leases. |
| US-6.2 | As a Finance Controller, I want a summary of lease liability and ROU asset movements for the period, so I can populate the rollforward disclosure note. | Given the disclosure function is executed, When the output is generated, Then the system produces: opening balance, additions, modifications, depreciation, interest, payments, closing balance for both ROU assets and lease liabilities. |
| US-6.3 | As a Finance Controller, I want the weighted average discount rate disclosed per asset class, so I can include it in the IFRS 16 note. | Given the disclosure function is executed, When the output is generated, Then the system calculates and displays the weighted average discount rate by asset class based on outstanding lease liabilities. |

---

### EPIC 7: AI Operational Assistant
**Goal:** Provide an AI assistant layer that guides users through the IFRS 16 process, explains outputs, and answers accounting questions in plain language.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-7.1 | As a RE Contract Manager, I want to ask the system "What information do I need to enter for this lease?" and get a clear, role-appropriate answer. | AI assistant provides a plain-language checklist of required data for the specific contract type, with explanations. No accounting jargon without a plain-language equivalent. [Implementation: Copilot/Gemini layer — TO BE CONFIRMED] |
| US-7.2 | As a Lease Accountant, I want to ask the system "Why was this lease liability calculated as X?" and get a traceable explanation. | AI assistant retrieves and presents the approved calculation inputs, IFRS 16 rules applied (with paragraph references), and the accountant who approved each judgment. [TO BE CONFIRMED — integration architecture] |

---

### EPIC 8: Knowledge and Documentation Continuity
**Goal:** Maintain a living, AI-retrievable knowledge base that keeps project documentation, accounting rules, and user guidance consistently up to date.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-8.1 | As a Project Governance Lead, I want all significant project decisions recorded in an ADR log with rationale and alternatives, so the team can make coherent decisions as the project evolves. | Every decision that changes the approach must produce an ADR entry in docs/governance/decision-log.md within 1 business day of approval. ADR must include: context, decision, alternatives rejected, consequences. |
| US-8.2 | As a Kiro AI Practitioner, I want the knowledge base to be curated and current, so AI agents produce reliable outputs grounded in verified sources. | RAG curation is performed at the start of each project phase. No Priority 1-3 source is used by agents without human validation. Knowledge health reports are produced and reviewed. |

---

### EPIC 9: Governance, Audit and Controls
**Goal:** Embed governance controls, audit trail, and compliance evidence into every step of the IFRS 16 process.

| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| US-9.1 | As an External Auditor, I want to retrieve complete evidence for any IFRS 16 calculation by contract and period, so I can verify compliance without external spreadsheets. | Given any active lease and period, When the audit evidence function is accessed, Then the system displays: scoping decision + approver, inputs used + source, calculation output + run ID, approval record, posted FI documents. No external reference needed. |
| US-9.2 | As a Finance Controller, I want segregation of duties enforced by the system, so data capture, calculation, approval, and posting cannot be performed by the same user. | System authorization prevents a user with the data capture role from executing the posting function. Role combinations violating SOD rules are blocked at authorization level. |
| US-9.3 | As a Project Governance Lead, I want a risk register and assumptions register maintained throughout the project, so risks are visible and assumptions are tracked to resolution. | docs/governance/risk-register.md and docs/governance/assumptions-register.md are reviewed at every phase gate and updated before phase sign-off. No unresolved HIGH risks proceed without documented acceptance. |

---

### EPIC 10: Operational Error Prevention and User Explainability
**Goal:** Directly address the 13 documented operational pain points through validation,
guided workflows, explainability features, and upgraded documentation. This epic cuts
across all other epics — it defines the quality bar for every user-facing feature.

**Background:** Pain points PP-A through PP-M were documented from real SAP RE/IFRS 16
operational experience. They reveal that the primary failure mode for users is not a lack
of features but a lack of guidance, explainability, and proactive validation. See
`PAIN_POINTS_TRACEABILITY.md` and `knowledge/user-feedback/` for full detail.

| ID | Story | Acceptance Criteria | Pain Point |
|----|-------|-------------------|------------|
| US-10.1 | As a RE Contract Manager, I want the system to validate all IFRS 16-critical contract fields before saving, with plain-language error messages, so I can correct mistakes before they reach downstream processes. | Given a contract is being saved with incomplete or inconsistent IFRS 16 fields (dates, currency, object type, periodicity), When validation runs, Then the system displays field-specific plain-language error messages — not SAP message codes. No contract may be sent to IFRS 16 calculation with validation errors outstanding. | PP-A, PP-L |
| US-10.2 | As a Lease Accountant, I want the system to show me a plain-language explanation whenever a retroactive change generates a special posting, so I can reconcile it without specialist support. | Given a retroactive change triggers a special posting, When the posting is created, Then the system attaches a machine-generated explanation: what the posting is, why it exists, which contract event triggered it, and the IFRS 16 basis. Explanation visible from the FI document and from the Z audit transaction. | PP-B, PP-F |
| US-10.3 | As a Lease Accountant, I want the system to check all ZRE009 prerequisites before I attempt reclassification, so I am never blocked by a preventable error. | Given the user initiates ZRE009 reclassification, When the pre-flight check runs, Then the system verifies: current period is posted, all changes are valuated, no pending asset movements. Each unmet condition is listed with a plain-language remediation instruction. ZRE009 is blocked until all prerequisites are met. | PP-C |
| US-10.4 | As a RE Contract Manager, I want to see the lifecycle status of every contract in the contract list (Active / Rescinded / Exempt / Blocked), so I can filter to only operationally relevant contracts. | Given any contract list view in the Z addon, When the user applies a lifecycle status filter, Then contracts are filtered correctly. Rescinded contracts are visible but clearly labeled — not hidden. A filter preset for Active contracts is the default view. | PP-D |
| US-10.5 | As a Lease Accountant, I want the system to block the period-end batch if any contract has unvaluated changes, and show me which contracts are affected, so I do not run the period with incorrect data. | Given the period-end batch is triggered, When the pre-flight check detects contracts with unvaluated changes, Then the batch is blocked. A list of affected contracts is displayed with a link to the valuation transaction for each. | PP-E |
| US-10.6 | As a Lease Accountant, I want a contract-level amortization report that shows the full schedule for a single contract, so I can verify and follow up at the contract level. | Given any active lease contract, When the user opens the contract-level amortization view, Then the full amortization schedule is displayed: period, opening balance, interest, depreciation, payment, closing balance. Exportable to spreadsheet. | PP-G |
| US-10.7 | As a Lease Accountant, I want the system to identify contracts affected by an upgrade data quality issue (clearing vs. expense differences) and guide me through the remediation steps, so I can fix them without specialist intervention. | Given an upgrade impact detection report is executed, When the report identifies contracts with clearing/expense differences, Then each affected contract is listed with the nature of the discrepancy and step-by-step remediation instructions. | PP-H |
| US-10.8 | As a RE Contract Manager, I want the system to guide me through the correct sequence for executing a contract extension or rescission, with a status check before each step, so I cannot accidentally perform steps out of order. | Given a user initiates an extension or rescission workflow, When the guided workflow runs, Then the system enforces the mandatory sequence: execute extension/rescission → confirm → valuate → period-end. Each step checks that the previous step is complete before allowing the next. | PP-J |
| US-10.9 | As a Local Finance User, I want the user manual to be available in my working language with guidance specific to my contract types (including advance payment contracts for Poland), so I can resolve operational questions without escalation. | Given a user accesses the user manual, When they select their language and country/region, Then the manual displays in the selected language with country-specific sections flagged. Poland advance payment guidance is present and current. | PP-K, PP-M |
| US-10.10 | As a Finance Controller, I want to see a plain-language summary of any foreign currency contract balance including the exchange rate used and the calculation basis, so I can interpret the balance without accounting specialist support. | Given a foreign currency contract has been calculated, When the controller opens the contract balance view, Then the display includes: balance in contract currency, balance in company code currency, exchange rate used, rate source, and a plain-language note on multi-currency accounting treatment. | PP-I |

---

## 5. Explicit Out-of-Scope List (Version 1)

- Lessor accounting (IFRS 16 §61–97)
- Sublease accounting
- Sale-and-leaseback accounting
- SAP S/4HANA migration execution
- Automated FI posting without human approval gate
- Integration with external contract management systems
- Direct local GAAP compliance (IFRS only)
- Non-RE lease categories (equipment, vehicles) unless explicitly included in a future spec
- Fiori UI implementation for ECC (noted for S/4 readiness — not built in v1)

---

## 6. Assumptions

| ID | Assumption | Owner | Status |
|----|------------|-------|--------|
| A-01 | SAP RE-FX is the primary lease management system — no parallel legacy system | Project Governance Lead | To be confirmed |
| A-02 | New GL is active; parallel ledger for IFRS may exist — architecture TBC | SAP FI Consultant | To be confirmed |
| A-03 | ABAP 7.4+ is available in the ECC system | ABAP Architect | To be confirmed |
| A-04 | Client has approved accounting policy for short-term and low-value thresholds | IFRS 16 Accountant | To be confirmed |
| A-05 | IBR determination process exists (Treasury or external advisor) | IFRS 16 Accountant | To be confirmed |
| A-06 | Transport landscape allows Z objects in dedicated packages | Basis Team | To be confirmed |
| A-07 | SAP SLG1 is available and can be used for application logging | Basis Team | To be confirmed |
| A-08 | Data governance approval obtained for AI service usage | Legal/DGO | To be confirmed |

See full assumptions register: [docs/governance/assumptions-register.md](../../docs/governance/assumptions-register.md)

---

## 7. Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|-----------|
| R-01 | RE-FX condition type mapping is more complex than expected — payment classification requires extensive configuration analysis | High | High | Early blueprint workshop with SAP RE Functional Consultant |
| R-02 | IBR determination process not established — blocks discount rate input | Medium | High | Flag as dependency; escalate to Finance immediately |
| R-03 | ABAP landscape constraints limit parallelization — batch performance risk | Medium | Medium | Performance PoC in Phase 1 |
| R-04 | IFRS 16 accounting policy elections not yet formally decided | Medium | High | Align with IFRS 16 Accountant in Phase 0; block design without policy confirmation |
| R-05 | S/4HANA migration timeline conflicts with addon investment | Low | High | Design for S/4 compatibility from the start; document all ECC-specific choices |
| R-06 | Data governance blocks AI service integration | Medium | Medium | Engage Legal/DGO early; design AI layer to be optional |

See full risk register including pain-point-derived risks R-13 to R-22: [docs/governance/risk-register.md](../../docs/governance/risk-register.md)

---

## 8. Dependencies

| ID | Dependency | Type | Blocks |
|----|-----------|------|--------|
| D-01 | IFRS 16 accounting policy document approved by IFRS 16 Accountant | External | Epic 2, Epic 3, Epic 4 |
| D-02 | SAP RE-FX blueprint — field mapping confirmed | External | Epic 1, Epic 3 |
| D-03 | IBR/discount rate process established | External | Epic 3, Epic 4 |
| D-04 | Transport landscape and package naming confirmed | Internal | All technical development |
| D-05 | Data governance/AI service approval | External | Epic 7 |
| D-06 | FI-AA and FI-GL posting approach confirmed | External | Epic 5 |


---

