# Master Design — IFRS 16 Z Addon for SAP RE/RE-FX

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial design baseline |

---

## 1. Architecture Overview

The IFRS 16 Z addon is a **layered ABAP architecture** embedded in the SAP ECC landscape, operating on top of SAP RE/RE-FX without modifying standard objects. It consists of five logical layers:

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
│  DATA LAYER  (Z tables, RE-FX reads, FI integration)    │
└─────────────────────────────────────────────────────────┘
```

The layers communicate downward only — upper layers call lower layers, not the reverse. Business logic is never duplicated across layers.

---

## 2. Logical Components

### 2.1 Contract Data Provider
- **Purpose:** Reads RE-FX contract data and maps it to the IFRS 16 data model.
- **Key objects:** `ZCL_RIF16_CONTRACT_DATA`, `ZIF_RIF16_DATA_PROVIDER`
- **Reads:** RE-FX contract header, conditions, option dates, partner data [specific tables TBC]
- **Produces:** Structured IFRS 16 contract data transfer object

### 2.2 IFRS 16 Data Extension Model
- **Purpose:** Stores IFRS 16-specific data not available in standard RE-FX.
- **Key objects:** `ZRIF16_CNTRT` (contract extension), `ZRIF16_PARAM` (parameters), `ZRIF16_MODF` (modifications)
- **Maintained via:** Z intake transaction and modification workflow

### 2.3 Calculation Engine
- **Purpose:** Computes amortization schedules, period entries, and modification impacts.
- **Key objects:** `ZCL_RIF16_CALC_ENGINE`, `ZIF_RIF16_CALC_STRATEGY`
- **Strategies:** Standard amortization, short-term/low-value (exemption — no schedule), modification adjustment, remeasurement
- **Inputs:** Approved IFRS 16 data (from Z extension model + RE-FX)
- **Outputs:** `ZRIF16_SCHED` (schedule), `ZRIF16_CALC` + `ZRIF16_CALCI` (run logs)

### 2.4 Approval Workflow
- **Purpose:** Enforces human approval gates before calculation results can be posted.
- **Key objects:** SAP workflow or Z approval table [TO BE CONFIRMED — SAP WS vs. Z approval table approach]
- **Gates:** Data capture review, calculation approval, modification approval, posting authorization

### 2.5 Posting Handler
- **Purpose:** Generates FI journal entries from approved IFRS 16 period entries.
- **Key objects:** `ZCL_RIF16_POSTING`, `ZIF_RIF16_POSTING_HANDLER`
- **Integration:** FI-GL posting (standard accounting interface [TO BE CONFIRMED]), FI-AA for ROU asset [TO BE CONFIRMED]
- **References:** Every FI document carries the IFRS 16 calculation run ID

### 2.6 Disclosure Engine
- **Purpose:** Aggregates IFRS 16 data across all contracts for disclosure note generation.
- **Key objects:** `ZCL_RIF16_DISCLOSURE`
- **Outputs:** Maturity analysis, liability/ROU rollforward, weighted average discount rate

### 2.7 Audit and Logging Framework
- **Purpose:** Provides complete, immutable audit trail for all IFRS 16 process events.
- **Key objects:** `ZCL_RIF16_LOGGER`, `ZRIF16_AUDIT`, SAP SLG1 log object `ZRIF16`
- **Captures:** All user actions, all calculation runs, all approval events, all posting events

### 2.8 Administration and Configuration
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
    ├── SAP RE Specialist (sap-re-ifrs16)
    │       → RE-FX mapping, object catalog, process design
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
├── sap-functional/    [Priority 4-5]  → SAP RE documentation, process maps
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
Spec Updated (specs/000-master-ifrs16-addon/)
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
SAP RE Specialist + ABAP Architect review implementation feasibility
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
| SAP RFC Gateway | `sap-rfc` or `mcp-sap` | Query live SAP RE-FX data for design validation | Not installed — TO BE CONFIRMED |
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
- Complete SAP RE-FX blueprint and field mapping.
- Confirm technical landscape (ABAP version, transport, authorizations).
- Populate knowledge base with official IFRS 16 sources and SAP documentation.
- Complete all [TO BE CONFIRMED] items in requirements and design.

### Phase 1 — Core Engine (MVP)
- Contract data extension model.
- Calculation engine (standard amortization, exemptions).
- Basic intake workflow.
- Period-end batch calculation.
- Posting framework (with manual approval gate).
- Audit trail foundation.

### Phase 2 — Modifications and Governance
- Modification detection and classification wizard.
- Remeasurement workflow.
- Full approval workflow.
- Disclosure engine (maturity analysis, rollforward).
- Reconciliation report.
- Internal controls enforcement.

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
| OQ-01 | Which RE-FX tables/BAPIs are available and suitable for contract data reading? | All Z development | SAP RE Functional Consultant | Phase 0 |
| OQ-02 | Is a parallel IFRS ledger required, or are IFRS 16 entries in the main ledger? | Posting architecture | FI Architect | Phase 0 |
| OQ-03 | What is the IBR determination process and who owns it? | Calculation engine inputs | IFRS 16 Accountant + Treasury | Phase 0 |
| OQ-04 | Which SAP workflow technology to use for approval gates? (SAP WS vs. Z table) | Approval workflow design | ABAP Architect | Phase 1 |
| OQ-05 | What is the data retention policy for IFRS 16 audit tables? | Z table archiving design | Legal/DGO | Phase 1 |
| OQ-06 | What AI service (Copilot/Gemini) is approved for end-user assistant layer? | Epic 7 design | IT/Security | Phase 2 |
| OQ-07 | How are multi-currency leases handled? (If applicable) | Calculation engine | IFRS 16 Accountant + FI | Phase 1 |
