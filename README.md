# RE-SAP: IFRS 16 Automation Addon for SAP ECC

## Project Name

**RE-SAP IFRS16 Addon** — Enterprise Z-addon for SAP ECC that automates the IFRS 16 lease
accounting lifecycle with AI-assisted governance, multiagent orchestration, and living
documentation. The addon is a **standalone Z system of record** (Option B — ADR-006): all
contract master data, valuation, and accounting are managed in Z tables and Z logic, with
direct FI-GL and FI-AA BAPI integration. RE-FX is not used at runtime.
Designed for ECC today and migration-aware for SAP S/4HANA Private Cloud Edition in the future.

---

## Primary Operating Model: Kiro IDE-First

This project is operated primarily through **Kiro IDE**. Kiro IDE is the preferred runtime
for all specs, hooks, steering, MCP, and subagent workflows.

| Operating Model | Status | Usage |
|----------------|--------|-------|
| **Kiro IDE** | **PRIMARY** | All spec execution, agent sessions, steering, hooks, MCP |
| Kiro CLI | Secondary | Lightweight scripting only; does not replace IDE agent workflows |

Why Kiro IDE is primary:
- This project depends on Specs, Hooks, Steering, MCP, and subagents — all native Kiro IDE features.
- The orchestrator + specialist agent model requires IDE-level agent coordination.
- Documentation continuity, knowledge curation, and governance automation are designed for the IDE workflow.

See [MIGRATION_NOTES_KIRO_IDE_FIRST.md](MIGRATION_NOTES_KIRO_IDE_FIRST.md) for full
operating model documentation and the CLI compatibility layer.

---

## Purpose

This project delivers a structured, auditable, and AI-governed solution to automate the IFRS 16
lifecycle within SAP ECC. The addon is a **standalone Z system** (Option B — ADR-006): it does
not depend on SAP RE-FX at runtime. The goal is to eliminate manual spreadsheets, reduce
calculation errors, enforce accounting explainability, and produce audit-ready evidence — all
inside SAP, with an AI assistant layer to support users.

The addon addresses real, documented operational pain points experienced by users of SAP RE/IFRS 16
processes. See [PAIN_POINTS_TRACEABILITY.md](PAIN_POINTS_TRACEABILITY.md) for the full traceability
matrix linking each pain point to requirements, design, tasks, and risk register.

---

## Scope

- **In scope:** Lessee accounting under IFRS 16, SAP ECC Z-addon development (Option B standalone),
  AI-assisted decision support, RAG knowledge management, UAT governance, disclosure output support.
- **Architecture:** Option B (ADR-006) — Z addon is the system of record. RE-FX is not used at
  runtime. If existing RE-FX contracts exist, a one-time migration extract is performed.
- **S/4HANA awareness:** All design decisions are migration-aware. ECC-specific choices are flagged
  for future SAP S/4HANA Private Cloud Edition compatibility review.
- **Out of scope (v1):** Lessor accounting, SAP S/4HANA migration execution, direct ERP posting
  automation without human approval gate, non-RE lease categories unless explicitly included.

---

## Top Operational Pain Points Addressed

This addon is driven by real user pain points documented in `knowledge/user-feedback/`.

| ID | Pain Point | Impact |
|----|-----------|--------|
| PP-A | Contract configuration errors (dates, currency, object type, periodicity) | Valuation and posting failures |
| PP-B | Retroactive changes in closed periods generate uninterpretable special postings | Reconciliation burden |
| PP-C | Debt reclassification failures (ZRE009) when period not posted or changes not valuated | Period-end blocking errors |
| PP-D | Contracts with postings cannot be deleted; rescinded contracts remain visible | Operational clutter, control risk |
| PP-E | Contract changes without valuation cause downstream process failures | Silent data quality issues |
| PP-F | Special P&L movements on rescission/retroactive changes are unexplained to users | Audit and controller confusion |
| PP-G | Amortization only visible by asset class, not by individual contract | No contract-level follow-up possible |
| PP-H | Old contracts broken after upgrades (clearing vs. expense amount differences) | Manual remediation before processing |
| PP-I | Foreign currency contracts require specific posting config; unclear to users | Balance interpretation uncertainty |
| PP-J | Extension/rescission not executed correctly causes monthly process inconsistency | Period-end failures |
| PP-K | Poland advance payment contracts need distinct rules and correct useful life | Country-specific compliance risk |
| PP-L | Date mismatches (start/end/condition dates) create duplicates or valuation errors | Data quality incidents |
| PP-M | User manual is outdated, in English, does not reflect current configuration | Users cannot self-serve; error rate high |

---

## Repository Structure

### `.kiro/`

Kiro workspace configuration — the intelligence layer of the project.

| Subfolder | Purpose |
|-----------|---------|
| `.kiro/agents/` | Agent definitions (orchestrator + 7 specialists). JSON files with URI-based resources (file:// and skill://) for Kiro IDE. |
| `.kiro/steering/` | Steering documents injecting context into every agent interaction. Frontmatter controls inclusion (always / auto). |
| `.kiro/skills/` | Reusable skill playbooks. Each SKILL.md has YAML frontmatter (name + description) plus a detailed procedure. |

### `specs/`

Master specification documents — the primary axis driving all development.

| File | Purpose |
|------|---------|
| `specs/000-master-ifrs16-addon/requirements.md` | Epics, user stories, acceptance criteria, pain-point stories, assumptions, risks. |
| `specs/000-master-ifrs16-addon/design.md` | Architecture, component model, pain point mitigation patterns, agent interaction, RAG, MCP. |
| `specs/000-master-ifrs16-addon/tasks.md` | Phased backlog with owners, dependencies, done criteria, QA gates, pain-point work packages. |

### `knowledge/`

RAG-ready knowledge base. Organized by source type.

| Folder | Content |
|--------|---------|
| `knowledge/official-ifrs/` | IFRS 16 standard text, IASB amendments, interpretations. |
| `knowledge/project-decisions/` | ADRs and design decisions with rationale. |
| `knowledge/sap-functional/` | SAP ECC process references, BAPI documentation, FI/FI-AA integration references. RE-FX documentation is retained as legacy source for migration analysis only — not as runtime design reference. |
| `knowledge/ux-stitch/` | Google Stitch designs, UI exports, MCP-fed design artifacts. |
| `knowledge/user-feedback/` | Real user pain points, UAT observations, support tickets. All 13 pain points documented here. |

### `docs/`

Living documentation. Always updated when specs or implementation change.

| File | Purpose |
|------|---------|
| `docs/functional/master-functional-design.md` | Business process design, functional flows, decision rules. |
| `docs/technical/master-technical-design.md` | Technical architecture, object catalog, integration patterns. |
| `docs/user/master-user-manual.md` | Role-based user manual with step-by-step guidance. |
| `docs/governance/decision-log.md` | ADR-style log of all significant decisions. |
| `docs/governance/risk-register.md` | Project and compliance risks with mitigation. |
| `docs/governance/assumptions-register.md` | Tracked assumptions with validation status. |

### Root Files

| File | Purpose |
|------|---------|
| `AGENTS.md` | 10 mandatory behavioral rules for all AI agents. |
| `BOOTSTRAP_SUMMARY.md` | Workspace initialization and activation guide. |
| `PAIN_POINTS_TRACEABILITY.md` | Cross-reference matrix: pain points to requirements, risks, tasks, design. |
| `HOOKS_SETUP.md` | Kiro IDE hooks plan with trigger/action logic and setup instructions. |
| `MIGRATION_NOTES_KIRO_IDE_FIRST.md` | Operating model: IDE-first rationale and CLI compatibility layer. |

---

## First Recommended Actions

1. **Read `AGENTS.md`** — Non-negotiable behavioral rules before any agent session.
2. **Review `.kiro/steering/product.md` and `.kiro/steering/ifrs16-domain.md`** — Align on product vision and domain constraints.
3. **Read `PAIN_POINTS_TRACEABILITY.md`** — Understand which real user problems this addon must solve.
4. **Resolve CRITICAL Risk R-04** — IFRS 16 accounting policy elections must be signed off before Phase 1 design. See `docs/governance/risk-register.md`.
5. **Activate the Orchestrator in Kiro IDE** — Open `.kiro/agents/orchestrator-ifrs16.json` and start a session.
6. **Populate `knowledge/`** — Add official IFRS 16 documents, SAP RE screenshots, and user evidence.
7. **Complete Phase 0 tasks** — All T0-01 through T0-08 must be done before Phase 1 development begins.

---

## Agent Strategy

### Orchestrator (Primary IDE Entry Point)

`orchestrator-ifrs16` is the primary entry point for all project sessions in Kiro IDE.
It owns delivery program, traceability, governance enforcement, and coordinates all specialists.
It blocks premature task closure and must be activated in Kiro IDE for full multiagent coordination.

### Specialists (engage via orchestrator or directly)

| Agent | Domain | Engage Directly When |
|-------|--------|---------------------|
| `ifrs16-domain` | IFRS 16 accounting rules | Accounting analysis, scope questions, modification classification |
| `ecc-coverage-analyst` | ECC business functionality preservation | Confirming Option B covers all current ECC capabilities; migration scope analysis |
| `abap-architecture` | ABAP technical design | Z object design, integration patterns, performance |
| `rag-knowledge` | Knowledge base health | Phase start health check, new source curation |
| `docs-continuity` | Documentation alignment | After any spec or design change |
| `ux-stitch` | UX design analysis | When UI designs are ready (Stitch MCP or file-based) |
| `qa-audit-controls` | UAT and audit readiness | UAT planning, evidence matrix, controls review |

**Note:** The `sap-re-ifrs16` agent has been repurposed as `ecc-coverage-analyst` under Option B (ADR-006). Its mission is now preserving business coverage from the current ECC solution, not mapping to RE-FX objects.

---

## Architecture: Option B (ADR-006)

> **Non-negotiable architectural constraint.** The Z addon is the system of record. RE-FX is NOT used at runtime.

The addon stores all contract master data in Z tables, calculates all IFRS 16 valuations in Z logic, and posts all FI-GL and FI-AA documents directly via standard SAP BAPIs. End users interact exclusively with Z workspace transactions.

If the client has existing RE-FX contracts, a one-time migration extract is performed. After migration, RE-FX is not updated by the addon.

See `docs/architecture/option-b-architecture.md` and `.kiro/steering/option-b-target-model.md` for the full architectural specification.

---

## Key Contacts and Roles

*(To be completed by project lead — see `docs/governance/assumptions-register.md`)*

| Role | Responsibility |
|------|---------------|
| IFRS 16 Accountant | Validates accounting conclusions, approves calculation rules |
| SAP RE Functional Consultant | Validates RE/RE-FX process mapping |
| ABAP Architect | Reviews technical design, transports, Z-object strategy |
| Project Governance Lead | Approves ADRs, manages risk register, gates phases |
| AI/Kiro Practitioner | Manages Kiro IDE workspace, agent configuration, RAG curation |

---

## Standards and Governance

- All significant decisions must be recorded in `docs/governance/decision-log.md`.
- No ABAP code is created without a corresponding technical spec and completed design section.
- AI agents must never produce accounting conclusions without human validation. See `AGENTS.md`.
- All documentation is living — updates are mandatory when specs change.
- The `auto-commit-push` hook fires on every `postTaskExecution` event — see `.kiro/steering/git-repository.md`.
- ECC-specific design choices are flagged `[ECC-SPECIFIC]` for S/4HANA migration review.
- **Option B compliance is mandatory.** Any design proposing RE-FX as a runtime dependency is rejected. See ADR-006 and `.kiro/steering/option-b-target-model.md`.
