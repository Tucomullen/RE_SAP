# RE-SAP: IFRS 16 Automation Addon for SAP RE/RE-FX

## Project Name
**RE-SAP IFRS16 Addon** — Enterprise Z-addon for SAP ECC (RE/RE-FX module) that automates IFRS 16 lease accounting processes with AI-assisted governance, multiagent orchestration, and living documentation.

---

## Purpose
This project delivers a structured, auditable, and AI-governed solution to automate the IFRS 16 lifecycle within SAP Real Estate (RE/RE-FX). The goal is to eliminate manual spreadsheets, reduce calculation errors, enforce accounting explainability, and produce audit-ready evidence — all inside SAP, with an AI assistant layer to support users.

---

## Scope
- **In scope:** Lessee accounting under IFRS 16, SAP ECC RE/RE-FX processes, Z-addon development, AI-assisted decision support, RAG knowledge management, UAT governance, disclosure output support.
- **Out of scope (v1):** Lessor accounting, SAP S/4HANA migration execution, direct ERP posting automation without human approval gate (phased in later), non-RE lease categories unless explicitly included.

---

## Repository Structure

### `.kiro/`
Kiro workspace configuration — the intelligence layer of the project.

| Subfolder | Purpose |
|-----------|---------|
| `.kiro/agents/` | Agent definitions (orchestrator + specialists). Each JSON file defines a Kiro agent with its role, prompt, resources, and tools. |
| `.kiro/steering/` | Steering documents that inject persistent context into every agent interaction. Cover product vision, tech strategy, domain rules, governance, and policies. |
| `.kiro/skills/` | Reusable skill playbooks. Each `SKILL.md` defines a repeatable task procedure for agents and human practitioners. |

### `specs/`
Master specification documents for the addon. The primary artifact driving all development.

| File | Purpose |
|------|---------|
| `specs/000-master-ifrs16-addon/requirements.md` | Epics, user stories, acceptance criteria, scope, assumptions, risks. |
| `specs/000-master-ifrs16-addon/design.md` | Architecture, component model, agent interaction, RAG, UX flow, MCP integration. |
| `specs/000-master-ifrs16-addon/tasks.md` | Phased backlog with owners, dependencies, done criteria, and QA gates. |

### `knowledge/`
RAG-ready knowledge base. Organized by source type. Each folder has a `README.md` explaining ingestion rules.

| Folder | Content |
|--------|---------|
| `knowledge/official-ifrs/` | IFRS 16 standard text, IASB amendments, interpretations. |
| `knowledge/project-decisions/` | ADRs and design decisions with rationale. |
| `knowledge/sap-functional/` | SAP RE/RE-FX process references, object catalogs, screenshots. |
| `knowledge/ux-stitch/` | Google Stitch designs, UI exports, MCP-fed design artifacts. |
| `knowledge/user-feedback/` | Real user pain points, UAT observations, support tickets. |

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

---

## First Recommended Actions

1. **Read `BOOTSTRAP_SUMMARY.md`** — Understand what has been created and the recommended activation sequence.
2. **Review `.kiro/steering/product.md` and `.kiro/steering/ifrs16-domain.md`** — Align on product vision and IFRS 16 domain constraints before any work begins.
3. **Open `specs/000-master-ifrs16-addon/requirements.md`** — Review epics, stories, and acceptance criteria. Mark which requirements need human validation.
4. **Activate the Orchestrator agent** — Open `.kiro/agents/orchestrator-ifrs16.json` and start a session to plan the first iteration.
5. **Populate `knowledge/`** — Add official IFRS 16 documents, internal SAP RE screenshots, and user pain point evidence to enable RAG retrieval.
6. **Complete `docs/governance/assumptions-register.md`** — Validate or challenge initial assumptions before design work proceeds.
7. **Review `AGENTS.md`** — Ensure all team members and AI practitioners understand agent behavioral rules.

---

## Key Contacts and Roles
*(To be completed by project lead — see `docs/governance/assumptions-register.md` for current placeholder.)*

| Role | Responsibility |
|------|---------------|
| IFRS 16 Accountant | Validates accounting conclusions, approves calculation rules |
| SAP RE Functional Consultant | Validates RE/RE-FX process mapping |
| ABAP Architect | Reviews technical design, transports, and Z-object strategy |
| Project Governance Lead | Approves ADRs, manages risk register |
| AI/Kiro Practitioner | Manages agent configuration and RAG curation |

---

## Standards and Governance
- All significant decisions must be recorded in `docs/governance/decision-log.md`.
- No ABAP code is created without a corresponding technical spec in `specs/` and a completed design section in `docs/technical/master-technical-design.md`.
- AI agents must never produce accounting conclusions without human validation. See `AGENTS.md` and `.kiro/steering/ai-governance.md`.
- All documentation is treated as living — updates are mandatory when specs change.
