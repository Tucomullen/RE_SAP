# Master Task Backlog — IFRS 16 Z Addon for SAP ECC (Option B)

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial phased backlog |
| 0.2 | 2026-03-24 | Remediation | Added Phase 1F (pain point mitigation tasks T1-21 to T1-31) and Phase 2 pain point continuations |
| 0.3 | 2026-03-26 | Project Governance Lead | Option B normalization: updated T0-02, T1-01, T1-12, T2-01 to reflect Z standalone architecture (ADR-006); removed RE-FX runtime references |

---

## Backlog Structure
Tasks are organized by phase. Each task has: ID, title, description, dependencies, owner role/agent, done criteria, doc update requirement, and QA gate.

**Owner codes:**
- `HUM-ACC` — IFRS 16 Accountant (Human)
- `HUM-RE` — SAP RE Functional Consultant (Human)
- `HUM-ABAP` — ABAP Architect (Human)
- `HUM-GOV` — Project Governance Lead (Human)
- `HUM-SEC` — Security/Basis Team (Human)
- `AGT-ORC` — Orchestrator Agent
- `AGT-DOM` — IFRS 16 Domain Agent
- `AGT-RE` — SAP RE Specialist Agent
- `AGT-ABAP` — ABAP Architecture Agent
- `AGT-RAG` — RAG Knowledge Curator Agent
- `AGT-DOCS` — Docs Continuity Agent
- `AGT-UX` — UX/Stitch Agent
- `AGT-QA` — QA/Audit Controls Agent

---

## PHASE 0 — Foundation (Pre-Development)
> **Goal:** Resolve all open questions and assumptions. No development begins until Phase 0 is complete.

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T0-01 | IFRS 16 accounting policy sign-off | Document client's accounting policy elections: short-term exemption by asset class, low-value threshold, IBR source, non-lease component policy | None | HUM-ACC | Policy document signed off, stored in knowledge/project-decisions/ | docs/governance/assumptions-register.md updated | HUM-GOV review |
| T0-02 | Option B blueprint and ECC coverage workshop | **[OPTION B]** Run workshop with SAP RE Functional Consultant and ECC Coverage Analyst to: (1) confirm all current ECC capabilities are covered by CD-01 to CD-09; (2) confirm migration scope if RE-FX contracts exist; (3) resolve OQ-COV-01 to OQ-COV-08 from T0-02-coverage-gaps-matrix.md; (4) obtain sign-off on T0-02-option-b-blueprint.md | None | HUM-RE + AGT-ECC | Blueprint document signed off; all OQ-COV items resolved or escalated; migration scope confirmed | knowledge/sap-functional/ updated; docs/architecture/T0-02-option-b-blueprint.md signed | HUM-GOV review |
| T0-03 | Technical landscape confirmation | Confirm ABAP version, transport landscape, package naming, authorization framework, SLG1 availability | None | HUM-ABAP + HUM-SEC | All A-0x assumptions in requirements.md marked Confirmed or Rejected | docs/governance/assumptions-register.md updated | HUM-GOV review |
| T0-04 | FI-GL/FI-AA posting approach decision | Confirm whether IFRS 16 postings go to main ledger, parallel ledger, or extension ledger; confirm FI-AA approach for ROU assets | T0-01 | HUM-ACC + FI Architect | ADR recorded in docs/governance/decision-log.md; design.md §8 updated | docs/governance/decision-log.md, design.md | HUM-GOV |
| T0-05 | Populate official IFRS knowledge base | Add IFRS 16 standard text, basis for conclusions, and key IFRIC agenda decisions to knowledge/official-ifrs/ with full metadata | None | AGT-RAG + HUM-ACC (validation) | All Priority 1-2 sources have validated-by human name; README.md updated | knowledge/official-ifrs/README.md | AGT-RAG health check |
| T0-06 | Risk and assumptions baseline review | Review and validate all risks (R-01 to R-06) and assumptions (A-01 to A-08) in the registers | T0-01, T0-02, T0-03 | HUM-GOV + AGT-ORC | All High risks have mitigation plans; all assumptions have owners and target dates | docs/governance/risk-register.md, assumptions-register.md | HUM-GOV |
| T0-07 | ADR-001 through ADR-005 approved | Record and approve foundational ADRs: ABAP OO mandate, Z object strategy, logging approach, approval workflow technology selection, disclosure approach | T0-01 to T0-04 | HUM-GOV + HUM-ABAP | ADRs in docs/governance/decision-log.md with status Accepted | docs/governance/decision-log.md | HUM-GOV |
| T0-08 | Phase 0 gate review | Formal review of all Phase 0 outputs before development begins | T0-01 to T0-07 | HUM-GOV | All Phase 0 tasks Done; no open Critical/High blocking items | BOOTSTRAP_SUMMARY.md updated with Phase 0 completion | HUM-GOV sign-off |

---

## PHASE 1 — Core Engine (MVP)
> **Goal:** Deliver a working IFRS 16 calculation engine with basic intake, period-end run, and posting for standard leases (no modifications in this phase).

### P1-A: Data Foundation

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T1-01 | Z data model design — contract master | **[OPTION B]** Design ZRIF16_CONTRACT and all related Z tables (ZRIF16_PAYMENT_SCHED, ZRIF16_LEASEOBJ, etc.); field list, keys, indexes, change documents. No RE-FX table foreign keys. All contract data is self-owned in Z. | T0-02, T0-03, T0-07 | AGT-ABAP + HUM-ABAP | Technical design document complete and approved by ABAP Architect; OB-01 and OB-05 compliance confirmed | docs/technical/master-technical-design.md updated | HUM-ABAP review |
| T1-02 | Z data model design — calculation tables | Design ZRIF16_CALC, ZRIF16_CALCI, ZRIF16_SCHED | T1-01 | AGT-ABAP + HUM-ABAP | Technical design approved | docs/technical updated | HUM-ABAP review |
| T1-03 | Z data model design — parameters and audit | Design ZRIF16_PARAM, ZRIF16_AUDIT, SLG1 log object definition | T1-01 | AGT-ABAP + HUM-ABAP | Technical design approved | docs/technical updated | HUM-ABAP review |
| T1-04 | Z table creation in DEV | Create approved Z tables in SAP DEV with transports | T1-01, T1-02, T1-03 | HUM-ABAP | Tables active in DEV; transport released to QA; regression test passed | docs/technical: object catalog updated | AGT-QA regression check |

### P1-B: Calculation Engine

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T1-05 | Functional spec — calculation engine | Write functional spec for amortization schedule generation (standard lease, effective interest method) | T0-01, T0-02 | AGT-DOM + HUM-ACC | Spec reviewed and signed off by IFRS 16 Accountant and RE Consultant | docs/functional updated; spec file created | HUM-ACC + HUM-RE sign-off |
| T1-06 | Technical design — calculation engine | Design ZCL_RIF16_CALC_ENGINE, ZIF_RIF16_CALC_STRATEGY, strategy patterns | T1-05, T1-01 | AGT-ABAP + HUM-ABAP | Technical design reviewed and approved by ABAP Architect | docs/technical updated | HUM-ABAP |
| T1-07 | ABAP development — calculation engine | Implement calculation engine classes with unit tests | T1-06 | HUM-ABAP (developer) | All unit tests pass; manual calculation cross-check passed by IFRS 16 Accountant for 3 test scenarios | docs/technical: implementation notes | AGT-QA unit test review |
| T1-08 | Functional spec — exemption handling | Write functional spec for short-term and low-value exemption detection and storage | T0-01 | AGT-DOM + HUM-ACC | Signed off by IFRS 16 Accountant | docs/functional updated | HUM-ACC |
| T1-09 | ABAP development — exemption logic | Implement exemption check and storage | T1-08, T1-01 | HUM-ABAP (developer) | Unit tests pass; accountant validates exemption output | docs/technical updated | AGT-QA |

### P1-C: Intake Workflow

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T1-10 | Functional spec — contract intake wizard | Write functional spec for guided data capture transaction ZRE_IFRS16_INTAKE | T0-02, T1-01 | AGT-RE + HUM-RE | Signed off by RE Consultant | docs/functional updated | HUM-RE + HUM-ACC |
| T1-11 | UX design — intake wizard | Design intake wizard screens (field layout, progress steps, validation messages) | T1-10 | AGT-UX | Design reviewed by RE Contract Manager persona and Lease Accountant persona | knowledge/ux-stitch/ updated | HUM (target persona review) |
| T1-12 | ABAP development — intake transaction | **[OPTION B]** Implement ZRE_IFRS16_INTAKE as a Z standalone transaction. Contract data is entered directly into Z tables. If a migration extract exists, pre-population from the migration staging table (ZRIF16_MIGRATION_STAGING) is supported. No runtime RE-FX data reads. | T1-10, T1-11, T1-04 | HUM-ABAP | Transaction executable; Z table entries created correctly; no RE-FX runtime dependency | docs/user updated; docs/technical updated | AGT-QA UAT scenarios T1 |

### P1-D: Period-End Batch and Posting

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T1-13 | Functional spec — period-end batch | Write functional spec for ZRIF16_PERIOD_END_CALC: selection, processing, exception handling, output | T1-05 | AGT-RE + HUM-RE | Signed off | docs/functional updated | HUM-RE + HUM-ACC |
| T1-14 | Technical design — batch and parallelization | Design batch program architecture, parallel processing, commit strategy | T1-13, T1-06 | AGT-ABAP + HUM-ABAP | Approved by ABAP Architect; performance targets defined | docs/technical updated | HUM-ABAP |
| T1-15 | Functional spec — posting framework | Write functional spec for posting handler: FI-GL entries, FI-AA entries, approval gate | T0-04 | AGT-RE + HUM-RE + HUM-ACC | Signed off; posting approach confirmed | docs/functional updated | HUM-ACC + FI Consultant |
| T1-16 | ABAP development — posting handler | Implement ZCL_RIF16_POSTING with approval gate enforcement and FI integration | T1-15, T1-02, T1-04 | HUM-ABAP | Posting creates correct FI documents; approval gate blocks unauthorized posts; run ID on every FI doc | docs/technical updated | AGT-QA + HUM-ACC |
| T1-17 | ABAP development — period-end batch | Implement ZRIF16_PERIOD_END_CALC with parallelization | T1-14, T1-07, T1-12, T1-16 | HUM-ABAP | Batch runs successfully for 50+ test contracts within performance target; exception log produced | docs/technical updated | AGT-QA performance test |

### P1-E: Audit Trail and Controls

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T1-18 | Authorization concept design | Design all Z authorization objects; SOD matrix; role assignments | T1-04 | AGT-ABAP + HUM-SEC | SOD matrix approved by Security team | docs/governance: SOD matrix added | HUM-SEC + HUM-GOV |
| T1-19 | Implement authorization checks | Add authorization checks to all IFRS 16 transactions | T1-18 | HUM-ABAP + HUM-SEC | All transactions enforce auth objects; SOD violations blocked | docs/technical updated | AGT-QA SOD test |
| T1-20 | UAT Phase 1 execution | Execute UAT pack for Phase 1 features | T1-12, T1-17, T1-19 | HUM (all personas) + AGT-QA | All Critical UAT scenarios PASS; no open Critical defects | docs/user finalized for Phase 1 | HUM-ACC + HUM-RE + HUM-GOV sign-off |

### P1-F: Pain Point Mitigation (Epic 10)

> These tasks directly address the 13 documented operational pain points (PP-A through PP-M).
> They run in parallel with other Phase 1 sub-phases and must be completed before Phase 1 UAT.
> Source: `PAIN_POINTS_TRACEABILITY.md` and `knowledge/user-feedback/README.md`.

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T1-21 | Functional spec — contract intake validation (PP-A, PP-L) | Write functional spec for pre-flight validation at contract intake: mandatory field checks, date consistency validation, plain-language error messages. Reference US-10.1 | T1-10 (intake spec exists) | AGT-RE + HUM-RE + HUM-ACC | Spec lists all validated fields with their rules; plain-language messages defined; signed off | docs/functional updated | HUM-RE + HUM-ACC |
| T1-22 | ABAP development — contract intake validation | Implement intake validation logic with plain-language messages. Block progress to IFRS 16 calculation until all mandatory fields pass. | T1-21, T1-12 | HUM-ABAP | All PP-A and PP-L validation rules implemented; no IFRS 16-critical field can be blank at calculation trigger; error messages tested in non-English locale | docs/user updated | AGT-QA PP-A/L scenarios |
| T1-23 | Functional spec — pre-batch valuation check (PP-E) | Write functional spec for pre-batch check: detect unvaluated contract changes before period-end batch; display affected contract list; block batch with remediation guidance. Reference US-10.5 | T1-13 | AGT-RE + HUM-RE | Spec defines check logic and blocked-state display; signed off | docs/functional updated | HUM-RE + HUM-ACC |
| T1-24 | ABAP development — pre-batch valuation check | Implement valuation status check in period-end batch program. Block execution if unvaluated changes detected. Display affected contracts with links to valuation transaction. | T1-23, T1-17 | HUM-ABAP | Batch correctly blocked when unvaluated changes exist; affected contract list accurate; user can navigate to valuation transaction | docs/user updated | AGT-QA PP-E scenarios |
| T1-25 | Functional spec — ZRE009 pre-flight checklist (PP-C) | Write functional spec for ZRE009 reclassification pre-flight: verify current period posted, all changes valuated, no pending asset movements. Plain-language remediation for each unmet condition. Reference US-10.3 | T1-13, T1-15 | AGT-RE + AGT-DOM + HUM-ACC | Spec covers all known ZRE009 failure modes; signed off by Lease Accountant | docs/functional updated | HUM-ACC + HUM-RE |
| T1-26 | ABAP development — ZRE009 pre-flight checklist | Implement pre-reclassification checklist with blocking behavior and remediation display. [SAP transaction/object name TBC with Functional Consultant] | T1-25, T1-16 | HUM-ABAP | All ZRE009 blocking conditions covered; remediation guidance displayed per condition; accountant confirms guidance text is correct | docs/user updated | AGT-QA PP-C scenarios |
| T1-27 | Functional spec — special posting explainability (PP-B, PP-F) | Write functional spec for machine-generated explanations attached to all system-generated special postings: what the posting is, why it exists, triggering event, IFRS 16 basis. Reference US-10.2 | T1-15, T1-16 | AGT-DOM + HUM-ACC | Spec covers all known special posting types with explanation templates; signed off | docs/functional updated | HUM-ACC |
| T1-28 | ABAP development — special posting explanations | Implement explanation attachment mechanism for system-generated special postings. Explanations stored in Z audit table and linked to FI document reference. | T1-27, T1-16 | HUM-ABAP | Every special posting type has a system-generated explanation; explanation visible in FI document display and Z audit transaction | docs/user updated | AGT-QA PP-B/F scenarios |
| T1-29 | Functional spec — contract lifecycle status and filtering (PP-D) | Write functional spec for contract lifecycle status display: Active / Rescinded / Exempt / Blocked. Default filter to Active. Status visible in all Z contract list views. Reference US-10.4 | T1-10 | AGT-RE + HUM-RE | Spec defines all lifecycle statuses, transitions, and filter behavior; signed off | docs/functional updated | HUM-RE |
| T1-30 | Functional spec — contract-level amortization report (PP-G) | Write functional spec for contract-level amortization view: period, opening balance, interest, depreciation, payment, closing balance. Exportable. Reference US-10.6 | T1-05, T1-07 | AGT-DOM + AGT-RE + HUM-ACC | Spec defines all columns, calculation source references, and export format; signed off | docs/functional updated | HUM-ACC |
| T1-31 | UAT scenarios — EPIC 10 pain point coverage | Generate UAT test pack covering all EPIC 10 acceptance criteria (US-10.1 through US-10.10). Include edge cases for each pain point and regression scenarios. | T1-22, T1-24, T1-26, T1-28, T1-29, T1-30 | AGT-QA | UAT pack covers all US-10.x acceptance criteria; manual calculation cross-check prepared by IFRS 16 Accountant for all affected scenarios | docs/user updated | HUM-ACC + HUM-RE sign-off |

---

## PHASE 2 — Modifications, Governance and Disclosure
> **Goal:** Add modification and remeasurement handling, full disclosure output, and enhanced governance controls.

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T2-01 | Functional spec — modification detection | **[OPTION B]** Spec for detecting Z contract events (from ZRIF16_EVENT table) that constitute IFRS 16 modifications. Events are generated by the Z contract event engine (CD-06), not by RE-FX change events. | T1-12, Phase 1 complete | AGT-DOM + AGT-ECC + HUM-RE | Signed off; event types defined in Z event model | docs/functional updated | HUM-ACC + HUM-RE |
| T2-02 | Functional spec — modification wizard | Spec for classification wizard: new separate lease vs. adjustment | T2-01 | AGT-DOM + HUM-ACC | Signed off with all IFRS 16 paragraph references | docs/functional updated | HUM-ACC |
| T2-03 | ABAP development — modification module | Implement ZRIF16_MODF, detection logic, classification wizard, delta display | T2-01, T2-02 | HUM-ABAP | Wizard operational; pre-modification snapshot saved; delta table correct | docs/technical + docs/user updated | AGT-QA UAT-MOD scenarios |
| T2-04 | Functional spec — remeasurement | Spec for all remeasurement triggers (D-G per IFRS 16 classification) | T2-01 | AGT-DOM + HUM-ACC | Signed off | docs/functional updated | HUM-ACC |
| T2-05 | ABAP development — remeasurement module | Implement remeasurement calculation and workflow | T2-04, T2-03 | HUM-ABAP | All remeasurement trigger types handled; approved before posting | docs/technical + docs/user updated | AGT-QA |
| T2-06 | Disclosure engine — maturity analysis | Implement IFRS 16 ¶52 maturity analysis output | Phase 1 complete | AGT-DOM + HUM-ABAP | Report matches manually calculated maturity table for test portfolio | docs/functional + docs/user updated | HUM-ACC |
| T2-07 | Disclosure engine — rollforward | Implement ROU asset and liability rollforward disclosure | T2-06 | HUM-ABAP | Report matches period GL movements | docs/user updated | HUM-ACC + HUM-GOV |
| T2-08 | Reconciliation report | Implement schedule-vs-GL reconciliation report | Phase 1 complete | HUM-ABAP | Report correctly identifies all reconciled and unreconciled items | docs/user updated | HUM-ACC |
| T2-09 | UAT Phase 2 execution | Execute UAT pack for Phase 2 features | T2-05, T2-08 | HUM (all personas) + AGT-QA | All Critical UAT scenarios PASS | docs/user finalized for Phase 2 | HUM-ACC + HUM-RE + HUM-GOV sign-off |

| T2-10 | ABAP development — extension/rescission guided workflow (PP-J) | Implement guided workflow for contract extension and rescission: enforce mandatory sequence, status checks per step. Reference US-10.8 | T2-03, T1-29 | HUM-ABAP | Workflow enforces sequence; out-of-order steps blocked; pending extension/rescission visible per contract | docs/user updated | AGT-QA PP-J scenarios |
| T2-11 | ABAP development — contract-level amortization report (PP-G) | Implement the contract-level amortization report per spec T1-30. Queryable by contract. Exportable. | T1-30, T2-03 | HUM-ABAP | Report shows full schedule per contract; export works; reconciles to GL movements | docs/user updated | HUM-ACC |
| T2-12 | Upgrade impact detection report (PP-H) | Design and implement report identifying contracts with clearing vs. expense amount differences from upgrades. Guided remediation workflow per affected contract. Reference US-10.7 | Phase 1 complete | AGT-ABAP + HUM-ABAP | Report correctly identifies all affected contracts; remediation steps documented and tested | docs/technical + docs/user updated | AGT-QA + HUM-ABAP |
| T2-13 | Foreign currency contract support (PP-I) | Implement multi-currency calculation support with currency-specific validation at intake and plain-language balance explanation. Reference US-10.10. [Exchange rate strategy TBC with FI team] | T1-21, T2-03 | AGT-DOM + HUM-ABAP + HUM-ACC | FC contracts calculate correctly; balance display shows exchange rate and plain-language explanation; FI team validates posting approach | docs/functional + docs/user updated | HUM-ACC + FI Consultant |
| T2-14 | Country-specific rules — Poland advance payment (PP-K) | Implement country-specific rule configuration for Poland advance-payment contracts. Pre-flight check for useful life consistency across asset areas. Reference US-10.9. [Poland scope must be confirmed by Governance Lead] | T2-03, T1-18 | HUM-ABAP + Local Finance | Poland advance payment contracts processed correctly; useful life check validates all areas; user manual section for Poland complete | docs/user Poland section | Local Finance + HUM-ACC |
| T2-15 | Multilingual user manual — Spanish baseline (PP-M) | Produce Spanish-language baseline of the master user manual, aligned with the current functional spec. Reference US-10.9. | T2-09 (Phase 2 UAT done) | AGT-DOCS + HUM (Language review) | Spanish manual covers all Phase 1+2 features; reviewed by Spanish-speaking target persona; released as docs/user/master-user-manual-es.md | docs/user: new ES file | HUM (target persona) |
| T2-16 | UAT Phase 2 continuation — pain point scenarios | Extend Phase 2 UAT to cover T2-10 through T2-15 scenarios. All EPIC 10 continuation acceptance criteria tested. | T2-10 to T2-15 | HUM (all personas) + AGT-QA | All continuation scenarios PASS; no open Critical defects in pain point coverage | docs/user finalized for Phase 2 | HUM-ACC + HUM-RE + HUM-GOV |

---

## PHASE 3 — AI and Automation Enhancement
> **Goal:** Integrate AI assistant for end users; enhance RAG; prepare for S/4HANA.

| Task ID | Title | Description | Dependencies | Owner | Done Criteria | Doc Update | QA Gate |
|---------|-------|-------------|--------------|-------|--------------|------------|---------|
| T3-01 | AI service selection and approval | Select, security-review, and formally approve end-user AI service (Copilot/Gemini) | Phase 2 complete; D-05 resolved | HUM-GOV + HUM-SEC | Written approval with data governance sign-off | docs/governance/decision-log.md | HUM-GOV |
| T3-02 | Stitch MCP server setup | Install and configure Google Stitch MCP server; validate security | T3-01 | HUM-SEC + AI Practitioner | MCP server active; prompt injection test passed | .kiro/agents/ux-stitch.json updated | AGT-QA + HUM-SEC |
| T3-03 | AI assistant integration | Build AI assistant connection to IFRS 16 knowledge base and calculation explanations | T3-01 | HUM-ABAP + AI Practitioner | AI answers IFRS 16 questions with cited sources; calculation explainer works | docs/user updated | HUM-ACC validation of AI outputs |
| T3-04 | S/4HANA compatibility assessment | Review all [ECC-SPECIFIC] flags; document migration path for each | Phase 2 complete | AGT-ABAP + HUM-ABAP | Migration assessment document complete in docs/technical | docs/technical S/4 migration section | HUM-ABAP + HUM-GOV |
| T3-05 | Vector store RAG deployment | Deploy vector knowledge base for semantic retrieval | T3-01, T3-02 | AI Practitioner | Semantic search returns relevant results; source citations maintained | .kiro/steering/rag-policy.md updated if needed | AGT-RAG validation |

---

## Minimum First Release Slice (Phase 1 MVP)
The following tasks constitute the minimum viable release that delivers measurable value:

| Priority | Tasks | Value Delivered |
|----------|-------|----------------|
| Must Have | T0-01 to T0-08 (all Phase 0) | Foundation for all development |
| Must Have | T1-01 to T1-04 (data model) | Z table foundation |
| Must Have | T1-05 to T1-09 (calculation engine) | Core IFRS 16 calculation |
| Must Have | T1-10 to T1-12 (intake) | User can capture IFRS 16 data |
| Must Have | T1-13 to T1-17 (batch + posting) | Period-end run produces FI entries |
| Must Have | T1-18 to T1-20 (controls + UAT) | Auditable, controlled process |
| Must Have | T1-21 to T1-26 (intake validation, pre-batch check, ZRE009 preflight) | Core pain point prevention (PP-A, PP-C, PP-E, PP-L) |
| Must Have | T1-27, T1-28 (special posting explainability) | User cannot interpret system actions without this (PP-B, PP-F) |
| Must Have | T1-29 (lifecycle status) | Operational visibility (PP-D) |
| Must Have | T1-30, T1-31 (contract amortization + Epic 10 UAT) | Contract-level visibility and pain point UAT gate (PP-G) |
| Should Have | T2-06 (maturity analysis) | Basic disclosure output |
| Should Have | T2-10, T2-11 (extension workflow, contract amortization impl.) | Phase 2 pain point continuations (PP-G, PP-J) |
| Can defer | T2-01 to T2-05 (modifications) | Phase 2 |
| Can defer | T2-07, T2-08, T2-12 to T2-15 (rollforward, reconciliation, upgrades, FC, Poland, multilingual manual) | Phase 2 |
| Defer | All Phase 3 | Phase 3 |
