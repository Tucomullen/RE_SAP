# Master Design — IFRS 16 Z Addon for SAP ECC (Option B)

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial design baseline |
| 0.2 | 2026-03-24 | Remediation | Added section 11 (Pain Point Mitigation Patterns), S/4HANA ECC flags, and open question OQ-08 |
| 0.3 | 2026-03-26 | Remediation | Option B mandate applied (ADR-006): Z addon is system of record, RE-FX removed as runtime layer, 9 capability domains added |

---

> **ARCHITECTURAL MANDATE — OPTION B (ADR-006, 2026-03-26):** The Z addon is the system of record. RE-FX is NOT used at runtime for contracts, valuation, or accounting. See `.kiro/steering/option-b-target-model.md` and `docs/architecture/option-b-architecture.md`.

---

## 1. Architecture Overview

The IFRS 16 Z addon is a **layered ABAP architecture** embedded in the SAP ECC landscape, operating as a fully self-contained system of record under Option B (ADR-006). RE-FX is not used at runtime. The addon consists of five logical layers:

```
┌─────────────────────────────────────────────────────────┐
│  USER LAYER  (SAP Transactions, Wizards, Reports)       │
├─────────────────────────────────────────────────────────┤
│  AI ASSISTANT LAYER  (Copilot/Gemini — future)          │
├─────────────────────────────────────────────────────────┤
│  ORCHESTRATION LAYER  (ABAP workflow, approval gates)   │
├─────────────────────────────────────────────────────────┤
│  BUSINESS LOGIC LAYER  (ABAP OO classes, calculation)   │
├─────────────────────────────────────────────────────────┤
│  DATA LAYER  (Z Persistence Layer — Z tables across     │
│               10 domain areas; no RE-FX dependency)     │
└─────────────────────────────────────────────────────────┘
```

The layers communicate downward only — upper layers call lower layers, not the reverse. Business logic is never duplicated across layers.

The Z Persistence Layer covers 10 data domains:
- Domain 1: Contract Truth / Contract Master (CD-01)
- Domain 2: Lease Object Master (CD-02)
- Domain 3: Valuation Results (CD-03)
- Domain 4: Posting History (CD-04)
- Domain 5: Contract Events / Lifecycle (CD-06)
- Domain 6: Integration References (CD-07)
- Domain 7: Supporting Documents
- Domain 8: Error and Process Logs
- Domain 9: Configuration / Accounting Determination (CD-04)
- Domain 10: Reclassification History (CD-08)

The 9 Capability Domains (CD-01 to CD-09) map to the specs in `specs/001-*` through `specs/009-*`. See Section 12 for the full domain table.

---

## 2. Logical Components

### 2.1 Contract Data Provider (CD-01, CD-02)
- **Purpose:** Reads Z contract master and lease object master as the source of truth for all IFRS 16 processing.
- **Key objects:** `ZCL_RIF16_CONTRACT_DATA`, `ZIF_RIF16_DATA_PROVIDER`
- **Reads:** `ZRIF16_CONTRACT` (Z contract master — Domain 1), `ZRIF16_LEASE_OBJ` (lease object — Domain 2), contract conditions, option dates, partner data
- **Produces:** Structured IFRS 16 contract data transfer object

> Option B note: `ZCL_RIF16_CONTRACT_DATA` reads `ZRIF16_CONTRACT` (Z contract master). It does NOT read RE-FX tables at runtime.

### 2.2 Z Valuation Engine (CD-03)
- **Purpose:** Stores IFRS 16-specific valuation data and implements the full calculation engine in Z.
- **Key objects:** `ZRIF16_CONTRACT` (contract master, Domain 1), `ZRIF16_PARAM` (parameters), `ZRIF16_VALUATION` (valuation results, Domain 3)
- **Maintained via:** Z intake transaction and modification workflow

> Option B note: `ZRIF16_CONTRACT` is the primary contract master table (Domain 1). It is NOT an extension table on RE-FX.

### 2.3 Calculation Engine (CD-03)
- **Purpose:** Computes amortization schedules, period entries, and modification impacts.
- **Key objects:** `ZCL_RIF16_CALC_ENGINE`, `ZIF_RIF16_CALC_STRATEGY`
- **Strategies:** Standard amortization, short-term/low-value (exemption — no schedule), modification adjustment, remeasurement
- **Inputs:** Approved IFRS 16 data (from Z contract master + Z valuation model)
- **Outputs:** `ZRIF16_SCHED` (schedule), `ZRIF16_CALC` + `ZRIF16_CALCI` (run logs)

### 2.4 Approval Workflow
- **Purpose:** Enforces human approval gates before calculation results can be posted.
- **Key objects:** SAP workflow or Z approval table [TO BE CONFIRMED — SAP WS vs. Z approval table approach]
- **Gates:** Data capture review, calculation approval, modification approval, posting authorization

### 2.5 FI-GL Posting Engine (CD-04)
- **Purpose:** Generates FI journal entries from approved IFRS 16 period entries via direct FI BAPIs.
- **Key objects:** `ZCL_RIF16_POSTING`, `ZIF_RIF16_POSTING_HANDLER`
- **Integration:** FI-GL posting via standard FI BAPIs (BAPI_ACC_DOCUMENT_POST or equivalent)
- **References:** Every FI document carries the IFRS 16 calculation run ID and Z contract ID

### 2.6 FI-AA Asset Engine (CD-05)
- **Purpose:** Creates and manages ROU assets in FI-AA directly from the Z addon.
- **Key objects:** `ZCL_RIF16_AA_HANDLER`
- **Integration:** FI-AA asset creation on initial recognition; asset retirement on lease termination; useful life update on remeasurement
- **References:** Z contract ID linked to FI-AA asset number in Z reference tables (Domain 6)

### 2.7 Contract Event Engine (CD-06)
- **Purpose:** Non-destructive event model for all contract lifecycle changes.
- **Key objects:** `ZCL_RIF16_EVENT_ENGINE`, `ZRIF16_EVENTS` (Domain 5)
- **Events are immutable:** Once written they cannot be changed or deleted.
- **Triggers remeasurement:** IFRS 16 modification events automatically initiate a new valuation run.

### 2.8 Reclassification Engine (CD-08)
- **Purpose:** Reliable, transparent reclassification of lease liability from non-current to current portion.
- **Key objects:** `ZCL_RIF16_RECLASSIFY`, `ZRIF16_RECLASSIF` (Domain 10)
- **Design rule:** Reclassification fails with explicit per-contract errors — not silently (addresses PP-C pain point).

### 2.9 Disclosure Engine (CD-09)
- **Purpose:** Aggregates IFRS 16 data across all contracts for disclosure note generation.
- **Key objects:** `ZCL_RIF16_DISCLOSURE`
- **Outputs:** Maturity analysis, liability/ROU rollforward, weighted average discount rate

### 2.10 Audit and Logging Framework
- **Purpose:** Provides complete, immutable audit trail for all IFRS 16 process events.
- **Key objects:** `ZCL_RIF16_LOGGER`, `ZRIF16_AUDIT`, SAP SLG1 log object `ZRIF16`
- **Captures:** All user actions, all calculation runs, all approval events, all posting events

### 2.11 Administration and Configuration
- **Purpose:** Maintains IFRS 16 parameters, policy elections, and user settings.
- **Key objects:** `ZRIF16_PARAM`, admin transaction `ZRE_IFRS16_ADMIN`
- **Manages:** Low-value threshold, short-term policy elections by asset class, GL account assignments, rate overrides

---

## 3. Agent Interaction Model

The Kiro multiagent system governs project delivery — not runtime SAP execution. The agents interact as follows:

```
Orchestrator (orchestrator-ifrs16)
    ├── IFRS 16 Domain Specialist (ifrs16-domain)
    │       → Accounting rules, scope analysis, explainability
    ├── ECC Coverage Analyst (ecc-coverage-analyst)
    │       → ECC business coverage, Z replacement analysis
    ├── Contract Model Architect (contract-model-architect)
    │       → CD-01, CD-02: contract master and lease object model
    ├── Valuation Engine Architect (valuation-engine-architect)
    │       → CD-03: calculation engine, schedules, IBR
    ├── FI-GL Integration Architect (fi-gl-integration-architect)
    │       → CD-04: posting patterns, account determination
    ├── FI-AA Integration Architect (fi-aa-integration-architect)
    │       → CD-05: ROU asset creation, depreciation, derecognition
    ├── Contract Event Architect (contract-event-architect)
    │       → CD-06: lifecycle events, modification classification
    ├── Reporting & Audit Architect (reporting-audit-architect)
    │       → CD-09: reporting, rollforward, disclosure, audit evidence
    ├── Migration Coverage Reviewer (migration-coverage-reviewer)
    │       → Phase 0/1/2 coverage certification gates
    ├── ABAP Architect (abap-architecture)
    │       → Technical design, Z objects, integration patterns
    ├── RAG Curator (rag-knowledge)
    │       → Knowledge base health, source validation
    ├── Docs Continuity (docs-continuity)
    │       → Documentation alignment and changelog
    ├── UX/Stitch Agent (ux-stitch)
    │       → Design-to-implementation translation
    └── QA/Audit (qa-audit-controls)
            → Test scenarios, evidence matrix, controls
```

**Interaction Rules:**
- Orchestrator initiates each iteration with a structured plan.
- Specialist agents produce proposals — never final decisions.
- All human approval gates are identified by the orchestrator and blocked until fulfilled.
- Docs continuity agent runs after every substantive change to update documentation.
- RAG curator runs at phase start and after significant knowledge additions.

---

## 4. RAG Architecture

The RAG knowledge base serves both the project agents and (in future) the end-user AI assistant:

```
knowledge/
├── official-ifrs/     [Priority 1-2]  → IFRS 16 standard, IASB materials
├── project-decisions/ [Priority 3]    → Approved ADRs, policy decisions
├── sap-functional/    [Priority 4-5]  → SAP ECC documentation, process maps
├── ux-stitch/         [Priority 7]    → Design artifacts
└── user-feedback/     [Priority 8]    → UAT findings, pain points
```

**Retrieval flow:**
1. Agent receives a question or task.
2. Agent searches the knowledge base by topic, starting at Priority 1.
3. Retrieved chunks are ranked by priority, recency, and specificity.
4. Agent cites sources in output using the format defined in .kiro/steering/rag-policy.md.
5. Missing sources are flagged as knowledge gaps.

**Future enhancement (Phase 3+):** Vector store MCP server for semantic retrieval. [TO BE CONFIRMED — technology selection]

---

## 5. Documentation Lifecycle

```
Requirement Change
       ↓
Spec Updated (specs/000-master-ifrs16-addon/ AND relevant specs/00x-*/)
       ↓
Functional Design Updated (docs/functional/)
       ↓
Technical Design Updated (docs/technical/)
       ↓
User Manual Updated (docs/user/)
       ↓
Decision Log / Risk Register Updated (docs/governance/)
       ↓
Knowledge Base Updated (knowledge/) if new sources needed
       ↓
Docs Continuity Agent verifies alignment across all layers
       ↓
Release note added to decision-log.md
```

No step may be skipped. The docs-continuity agent enforces this by running an alignment check at the end of every iteration.

---

## 6. UX / Design-to-Delivery Flow from Stitch

When Google Stitch MCP server is activated [TO BE CONFIRMED — not yet installed]:

```
Stitch Design Created (by UX Designer)
       ↓
MCP Server delivers design artifact to ux-stitch agent
       ↓
Agent validates: (a) Pain point coverage, (b) SAP constraints, (c) IFRS 16 terminology
       ↓
Agent generates: Field specifications, interaction rules, implementation tasks
       ↓
Tasks added to specs/000-master-ifrs16-addon/tasks.md
       ↓
ECC Coverage Analyst + ABAP Architect review implementation feasibility
       ↓
Functional Spec updated with UI specifications
       ↓
ABAP development begins
```

Until Stitch MCP is available: designs are delivered as screenshots, exported files, or structured descriptions stored in knowledge/ux-stitch/.

---

## 7. Future MCP Integration Points

| Integration | MCP Server Name (Logical) | Purpose | Status |
|------------|--------------------------|---------|--------|
| Google Stitch | `stitch` or `mcp-stitch` | Read UI designs directly | Not installed — TO BE CONFIRMED |
| SAP RFC Gateway | `sap-rfc` or `mcp-sap` | Query live SAP ECC data for design validation | Not installed — TO BE CONFIRMED |
| Vector Knowledge Store | `rag-store` or `mcp-vectordb` | Semantic RAG retrieval over knowledge/ | Not installed — TO BE CONFIRMED |
| AI Document Reader | `mcp-docs` | Parse PDF/Word source documents | Not installed — TO BE CONFIRMED |

All MCP integrations must pass security review before activation. See .kiro/steering/ai-governance.md for MCP trust rules.

---

## 8. Security and Governance Notes

### Authentication and Authorization
- All Z transactions require SAP user authentication (standard).
- Z authorization objects enforce role-based access at field level.
- Segregation of duties: data capture / calculation / approval / posting roles are separate. [Full SOD matrix: TO BE DEFINED in Phase 1]

### Data Protection
- All IFRS 16 data processed by AI agents (during project delivery) must be synthetic or anonymized.
- Production lease financial data must not be used in AI agent prompts or knowledge base.
- Retention policy for Z audit tables: [TO BE CONFIRMED — Legal/DGO]

### Change Control
- All Z objects transported via SAP CTS.
- Transport sequences documented in technical design.
- No emergency changes to production without documented approval.

### AI Governance
- AI agents are project delivery tools — not runtime SAP processing engines.
- No agent may trigger SAP posting or data modification autonomously.
- All AI outputs involving accounting conclusions require human validation before use.

---

## 9. Phased Delivery Strategy

### Phase 0 — Foundation (Pre-Development)
- Finalize accounting policy decisions.
- Complete ECC business coverage analysis and Z replacement mapping (ecc-coverage-analyst).
- Confirm technical landscape (ABAP version, transport, authorizations).
- Populate knowledge base with official IFRS 16 sources and SAP documentation.
- Complete all [TO BE CONFIRMED] items in requirements and design.
- Certify Phase 0 coverage gate (migration-coverage-reviewer).

### Phase 1 — Core Engine (MVP) — CD-01, CD-02, CD-03, CD-04
- Z contract master data model (CD-01) and lease object master (CD-02).
- Z valuation engine — standard amortization, exemptions (CD-03).
- Basic intake workflow.
- Period-end batch calculation.
- FI-GL posting framework via direct BAPIs (CD-04), with manual approval gate.
- Audit trail foundation.
- Certify Phase 1 coverage gate (migration-coverage-reviewer).

### Phase 2 — Events, Assets, and Governance — CD-05, CD-06, CD-08, CD-09
- Contract event engine — modification, extension, termination (CD-06).
- FI-AA ROU asset engine (CD-05).
- Reclassification engine (CD-08).
- Full approval workflow.
- Disclosure engine — maturity analysis, rollforward (CD-09).
- Reconciliation report.
- Internal controls enforcement.
- Certify Phase 2 coverage gate (migration-coverage-reviewer).

### Phase 3 — AI and Automation Enhancement
- AI assistant integration (Copilot/Gemini layer).
- Stitch MCP integration (when available).
- Vector store RAG for knowledge base.
- Advanced disclosure output.
- S/4HANA migration assessment and gap analysis.

---

## 10. Open Questions

| ID | Question | Impact | Owner | Target Date |
|----|---------|--------|-------|------------|
| OQ-01 | Which Z tables replace the RE-FX contract data source? Full Domain 1 schema to be validated. | All Z development | Contract Model Architect | Phase 0 |
| OQ-02 | Is a parallel IFRS ledger required, or are IFRS 16 entries in the main ledger? | Posting architecture | FI Architect | Phase 0 |
| OQ-03 | What is the IBR determination process and who owns it? | Calculation engine inputs | IFRS 16 Accountant + Treasury | Phase 0 |
| OQ-04 | Which SAP workflow technology to use for approval gates? (SAP WS vs. Z table) | Approval workflow design | ABAP Architect | Phase 1 |
| OQ-05 | What is the data retention policy for IFRS 16 audit tables? | Z table archiving design | Legal/DGO | Phase 1 |
| OQ-06 | What AI service (Copilot/Gemini) is approved for end-user assistant layer? | Epic 7 design | IT/Security | Phase 2 |
| OQ-07 | How are multi-currency leases handled? (If applicable) | Calculation engine | IFRS 16 Accountant + FI | Phase 1 |
| OQ-08 | Is Poland advance-payment contract support in scope for v1? Confirm with Governance Lead. | T2-14, PP-K design | Project Governance Lead | Phase 2 |

---

## 11. Pain Point Mitigation Design Patterns

The following design patterns address the 13 documented operational pain points
(PP-A through PP-M). These patterns must be embedded in the corresponding components.
See `PAIN_POINTS_TRACEABILITY.md` for the full traceability matrix.

### 11.1 Pre-Flight Validation Pattern (PP-A, PP-C, PP-E, PP-L)

Applied to: Contract Intake Wizard, ZRE009 Reclassification, Period-End Batch trigger.

```
User Action (save/trigger)
       ↓
Pre-flight Validator runs synchronously
       ↓
All conditions met? → YES → Continue to main processing
                   → NO  → Display validation results panel:
                            - List of unmet conditions
                            - Plain-language explanation per condition
                            - Remediation instruction per condition
                            - Link to resolution transaction where applicable
                          → Main processing BLOCKED until all conditions met
```

Design rules:
- Every blocking condition must have a plain-language message (no SAP message codes shown raw to users).
- Every blocking condition must have a resolution path the user can act on independently.
- Pre-flight results are logged in `ZRIF16_AUDIT` with user ID, timestamp, and condition list.
- ECC implementation: ABAP method in Z validator class. [ECC-SPECIFIC: in S/4HANA, consider ABAP
  RAP validation framework if applicable to the RE-FX context].

### 11.2 Special Posting Explanation Pattern (PP-B, PP-F)

Applied to: FI-GL Posting Engine (CD-04), any Z program generating non-standard FI entries.

```
System-generated special posting
       ↓
Explanation Generator called with: posting type + triggering event + contract ID + IFRS 16 basis
       ↓
Plain-language explanation text generated from template
       ↓
Explanation stored in ZRIF16_AUDIT with FI document reference
       ↓
Explanation accessible via:
  (a) Z audit transaction (ZRE_IFRS16_AUDIT) — for accountant and auditor
  (b) FI document text field — for controller viewing FI directly
```

Design rules:
- Explanation templates are defined per posting type in Z configuration table `ZRIF16_EXPLN_TMPL`.
- Templates include placeholders for contract ID, period, amounts, and IFRS 16 paragraph reference.
- Templates are configurable — allowing updates without code changes when explanations need refinement.
- Language-specific templates can be maintained for multilingual support.
- [ECC-SPECIFIC: FI document text field population approach to be confirmed with FI Architect].

### 11.3 Contract Lifecycle Status Pattern (PP-D, PP-J)

Applied to: All Z contract list views, Extension/Rescission Workflow.

Lifecycle statuses and transitions:

```
Not Assessed → (IFRS 16 intake triggered) → Active
Active → (exemption elected) → Exempt
Active → (rescission executed and valuated) → Rescinded
Active → (administrative block applied) → Blocked
Active → (extension pending) → Extension Pending
Active → (rescission pending) → Rescission Pending
```

Design rules:
- Status stored in `ZRIF16_CONTRACT` header field (Domain 1).
- All contract list views default to filter: Active + Extension/Rescission Pending.
- Rescinded contracts are VISIBLE with clear status label — never hidden.
- Extension/Rescission workflow enforces sequence gate checks before status transitions.
- [ECC-SPECIFIC: Status change events logged in change document for Z table].

### 11.4 Contract-Level Amortization Reporting (PP-G)

Applied to: Calculation Engine output, Disclosure Engine (CD-09).

Design rule: Every calculation run stores schedule data at line level in `ZRIF16_SCHED` with
contract ID as a key field. No aggregation-only storage.

Report structure:
- Selection by contract ID (mandatory), period range (optional), company code.
- Output: period-by-period table with opening balance, interest, depreciation, payment, closing balance.
- Totals per year.
- Export to spreadsheet (ALV OO standard download).
- Disclosure engine reads from this same table — no separate aggregation layer needed.

### 11.5 Upgrade Impact Detection (PP-H)

Applied to: Administration and Configuration component (section 2.11).

Trigger: Executed manually after any system upgrade or patch cycle.

Logic:
- Query all active contracts in ZRIF16_SCHED.
- For each contract, compare: clearing amount in Z schedule vs. depreciation expense in FI-AA.
- Report contracts where the difference exceeds a configurable tolerance.
- Guided remediation: for each affected contract, present step-by-step correction instructions.

Design rule: Remediation instructions are stored as configurable text in Z table — not hardcoded
in ABAP. This allows updating guidance without a transport.

### 11.6 Multilingual User Guidance (PP-M)

Applied to: User Manual, Z transaction contextual help, error messages.

Design rule: All user-visible text in Z transactions uses message class `ZRIF16_MSGS` with
language-dependent maintenance. Spanish (`S`) is the primary non-English target language.

User manual structure:
- `docs/user/master-user-manual.md` — English (primary, always current).
- `docs/user/master-user-manual-es.md` — Spanish (maintained in sync with English version).
- Every process change triggers an update to both language versions before task closure.
- Contextual help texts in Z transactions are maintained in the same message class.

### 11.7 ECC vs. S/4HANA Design Flags for Pain Point Features

| Feature | ECC Approach | S/4HANA PCE Consideration |
|---------|-------------|--------------------------|
| Pre-flight validation | ABAP class methods | Review ABAP RAP validation hooks if RE-FX migrated to RAP model |
| Explanation templates | Z config table | Same approach; FIORI UI may require Odata adaptation |
| Contract lifecycle status | Z field in ZRIF16_CONTRACT | If standard S/4 RE offers lifecycle fields, use standard first |
| Special posting text | FI document text field | Standard approach should remain valid; confirm with FI team |
| Upgrade impact report | Custom report | Equivalent functionality may exist in S/4 RE migration tools |
| Multilingual messages | Message class ZRIF16_MSGS | Standard SAP translation workbench; compatible with S/4 |

---

## 12. Option B Architecture Reference

The full Option B architecture is documented in `docs/architecture/option-b-architecture.md`.

### 9 Capability Domains
| Domain | ID | Spec |
|--------|----|------|
| Contract Master Z | CD-01 | specs/001-contract-master-z/ |
| Lease Object Master Z | CD-02 | specs/002-lease-object-z/ |
| Valuation Engine Z | CD-03 | specs/003-valuation-engine-z/ |
| Accounting Engine Z (FI-GL) | CD-04 | specs/004-accounting-engine-z/ |
| Asset Engine Z (FI-AA) | CD-05 | specs/005-fi-aa-integration-z/ |
| Contract Event Engine Z | CD-06 | specs/006-contract-event-lifecycle-z/ |
| Procurement / Source Integration Z | CD-07 | specs/007-procurement-source-integration-z/ |
| Reclassification Engine Z | CD-08 | specs/008-reclassification-engine-z/ |
| Reporting & Audit Z | CD-09 | specs/009-reporting-audit-z/ |

### Data Domain Model
See `docs/architecture/domain-data-model.md` for the conceptual separation of:
- Domain 1: Contract Truth / Contract Master
- Domain 2: Lease Object Master
- Domain 3: Valuation Results
- Domain 4: Posting History
- Domain 5: Contract Events / Lifecycle
- Domain 6: Integration References
- Domain 7: Supporting Documents
- Domain 8: Error and Process Logs
- Domain 9: Configuration / Accounting Determination
- Domain 10: Reclassification History
