---
inclusion: always
description: Folder structure, file naming conventions, ABAP object naming, Z table and class naming standards, and knowledge base metadata requirements.
---

# Structure and Naming Conventions — RE-SAP IFRS 16 Addon

## Folder Conventions

### Project Root
```
RE_SAP/
├── .kiro/              # Kiro workspace intelligence layer
│   ├── agents/         # Agent definitions (JSON)
│   ├── steering/       # Persistent steering documents (Markdown)
│   └── skills/         # Skill playbooks (Markdown)
├── specs/              # Master specifications
│   └── NNN-[name]/     # Numbered spec folders
├── knowledge/          # RAG knowledge base
│   ├── official-ifrs/
│   ├── project-decisions/
│   ├── sap-functional/
│   ├── ux-stitch/
│   └── user-feedback/
├── docs/               # Living documentation
│   ├── functional/
│   ├── technical/
│   ├── user/
│   └── governance/
├── AGENTS.md           # Agent behavioral rules
├── BOOTSTRAP_SUMMARY.md
└── README.md
```

---

## Naming Conventions

### General Rules
- All file and folder names use **lowercase-kebab-case** (e.g., `master-functional-design.md`).
- No spaces in file or folder names.
- Date-stamped files use **ISO 8601** format: `YYYY-MM-DD` (e.g., `2026-03-24-decision-discount-rate.md`).
- Avoid abbreviations unless industry-standard (IFRS, SAP, RE, ROU, FI, AA are acceptable).

---

## Document Naming

| Document Type | Convention | Example |
|--------------|------------|---------|
| Steering file | `[topic].md` | `ifrs16-domain.md` |
| Master doc | `master-[type]-[subject].md` | `master-functional-design.md` |
| Spec file | `[type].md` within numbered folder | `specs/000-master-ifrs16-addon/requirements.md` |
| Decision entry | `[YYYY-MM-DD]-[short-title].md` | `2026-03-24-discount-rate-approach.md` |
| Knowledge chunk | `[source-code]-[YYYY-MM-DD]-[short-title].md` | `ifrs16-iasb-2026-01-01-lease-term-guidance.md` |
| Skill | `SKILL.md` inside skill folder | `.kiro/skills/ifrs16-contract-analysis/SKILL.md` |
| Agent | `[agent-name].json` | `orchestrator-ifrs16.json` |

---

## Spec Naming

Specs are numbered with zero-padded three-digit prefixes to maintain ordering:

```
specs/
  000-master-ifrs16-addon/     # Master spec (always 000)
  001-contract-intake/         # Feature spec #1
  002-calculation-engine/      # Feature spec #2
  ...
  NNN-[feature-name]/
```

Within each spec folder, the standard files are:
- `requirements.md` — epics, stories, acceptance criteria
- `design.md` — architecture, components, decisions
- `tasks.md` — phased backlog with owners and done criteria

---

## Decision Log Naming

Entries in `docs/governance/decision-log.md` use the format:

```
ADR-NNN | YYYY-MM-DD | [Status] | [Short Title]
```

Example:
```
ADR-001 | 2026-03-24 | Accepted | Use ABAP OO classes for all calculation logic
ADR-002 | 2026-03-24 | Proposed | Discount rate storage in Z table vs. hardcoded
```

Statuses: `Proposed` | `Accepted` | `Rejected` | `Superseded` | `Deprecated`

---

## ABAP Package and Object Naming Conventions (Examples — to be confirmed with ABAP Architect)

### Development Packages
```
ZRIF16          # Root package for IFRS 16 addon (top-level)
ZRIF16_CORE     # Core calculation engine
ZRIF16_DATA     # Data model and Z tables
ZRIF16_UI       # UI components and transactions
ZRIF16_POST     # FI posting framework
ZRIF16_DISC     # Disclosure engine
ZRIF16_UTILS    # Shared utilities, logging, exceptions
ZRIF16_TEST     # Test classes and test data
```

### Z Table Naming
```
ZRIF16_CNTRT    # Contract master extension for IFRS 16 data
ZRIF16_SCHED    # Amortization schedule storage
ZRIF16_CALC     # Calculation run header
ZRIF16_CALCI    # Calculation run items
ZRIF16_PARAM    # IFRS 16 parameters (rates, thresholds)
ZRIF16_AUDIT    # Audit trail entries
ZRIF16_MODF     # Contract modification log
```

### Class Naming
```
ZCL_RIF16_CALC_ENGINE     # Main calculation engine class
ZCL_RIF16_CONTRACT_DATA   # Contract data reader/mapper
ZCL_RIF16_SCHEDULE_GEN    # Schedule generation
ZCL_RIF16_POSTING         # FI posting orchestrator
ZCL_RIF16_DISCLOSURE      # Disclosure aggregator
ZCL_RIF16_LOGGER          # Application logging utility
ZCX_RIF16_ERROR           # Root exception class
ZCX_RIF16_DATA_ERROR      # Data validation exception
ZCX_RIF16_CALC_ERROR      # Calculation exception
```

### Interface Naming
```
ZIF_RIF16_CALC_STRATEGY   # Interface for calculation strategies
ZIF_RIF16_POSTING_HANDLER # Interface for posting handlers
ZIF_RIF16_DATA_PROVIDER   # Interface for data providers
```

### Transaction Naming
```
ZRE_IFRS16_INTAKE     # Contract data intake guided workflow
ZRE_IFRS16_CALC       # Calculation run execution
ZRE_IFRS16_REVIEW     # Calculation review and approval
ZRE_IFRS16_POST       # Posting execution with approval gate
ZRE_IFRS16_DISC       # Disclosure report
ZRE_IFRS16_AUDIT      # Audit trail viewer
ZRE_IFRS16_ADMIN      # Administration and parameter maintenance
```

### Job/Program Naming
```
ZRIF16_PERIOD_END_CALC    # Periodic batch calculation
ZRIF16_POSTING_RUN        # Batch posting program
ZRIF16_DISCLOSURE_GEN     # Disclosure pack generation
ZRIF16_DATA_CONSISTENCY   # Data consistency check program
```

> **Note:** All naming conventions above are examples and must be confirmed with the ABAP Architect and the client's SAP transport landscape owner before implementation begins. The namespace prefix `Z` must comply with the client's SAP system namespace policies.

---

## Knowledge Base File Conventions

Files in `knowledge/` must include a metadata header:

```markdown
---
source-type: [official-ifrs | project-decision | sap-functional | ux-stitch | user-feedback]
source-date: YYYY-MM-DD
confidence: [high | medium | low]
status: [current | superseded | under-review]
tags: [ifrs16, lease-term, discount-rate, ...]
cited-in: [list of docs that reference this]
---
```

---

## Diagram Conventions
- Diagrams embedded in Markdown must use **Mermaid** syntax where possible.
- Complex diagrams may use draw.io (`.drawio` file) with an exported PNG in the same folder.
- Every diagram must have a caption and a version date.
- Architecture diagrams must be updated within the same PR/change as the corresponding design doc update.
