# Hooks Setup — RE-SAP IFRS 16 Addon

**Operating model:** Kiro IDE-first. All hooks are implemented in `.kiro/hooks/` as YAML files
and designed for the Kiro IDE hook system.

**Status:** Implemented — 5 hooks active in `.kiro/hooks/`. See Known Limitations below.

**Non-negotiable rule:** No hook in this project may perform `git add`, `git commit`, or `git push`
automatically. All version control operations require explicit human action.

---

## Overview

Hooks in this project serve governance and quality gate purposes. They are not convenience
automation — they are the enforcement layer for the documentation policy, risk capture mandate,
and spec quality standards defined in `AGENTS.md` and `.kiro/steering/documentation-policy.md`.

---

## Implemented Hooks

### Hook 1 — spec-documentation-guard
**File:** `.kiro/hooks/spec-documentation-guard.yaml`
**Trigger:** `fileSave` on `docs/technical/**/*.md` and `docs/governance/**/*.md`
**Purpose:** When a technical or governance document changes, check whether companion
master docs (functional, technical, user) need corresponding updates.
**Scope note:** Intentionally scoped to `docs/technical/` and `docs/governance/` only.
Coverage of `docs/functional/` and `docs/user/` is handled by `ux-traceability-check`.
**Spec → doc continuity:** When a spec file (requirements.md, design.md) changes and may
require doc updates, this is covered by `session-governance-check` at agent stop — which
always asks about documentation impact from the session. No separate file-save hook on
`specs/**` is used, to avoid dual-firing with `spec-quality-gate`.

---

### Hook 2 — session-governance-check
**File:** `.kiro/hooks/session-governance-check.yaml`
**Trigger:** `agentStop`
**Purpose:** After each agent session, perform two checks in one pass:
- **Part 1:** Identify new risks, assumptions, dependencies, or TBC items for the governance registers.
- **Part 2:** Identify reusable knowledge produced and recommend where it belongs in `knowledge/`.
**Design note:** This hook merges what were originally planned as two separate agent-stop hooks
(risk capture + knowledge continuity). One trigger, two concerns, no redundancy.

---

### Hook 3 — spec-quality-gate
**File:** `.kiro/hooks/spec-quality-gate.yaml`
**Trigger:** `fileSave` on `specs/**/requirements.md` and `specs/**/design.md`
**Purpose:** Validate spec files for structural completeness, AC quality (Given/When/Then),
traceability footers, and cross-spec consistency.
**Note:** `tasks.md` is deliberately excluded — task quality is governed by `controlled-closure-check`.

---

### Hook 4 — ux-traceability-check
**File:** `.kiro/hooks/ux-traceability-check.yaml`
**Trigger:** `fileSave` on `docs/functional/**/*.md`, `docs/user/**/*.md`,
`knowledge/ux-stitch/**/*.md`, and `PAIN_POINTS_TRACEABILITY.md`
**Purpose:** When UX-related or user-facing docs change, verify that PP-A through PP-M
traceability remains coherent across the four-document traceability chain.
**Silent behavior:** If everything is consistent, outputs one line and stops.

---

### Hook 5 — controlled-closure-check
**File:** `.kiro/hooks/controlled-closure-check.yaml`
**Trigger (primary):** `postTaskExecution` — fires after a Kiro IDE spec task completes
**Purpose:** Enforce the five-point closure gate after each spec task execution:
spec currency, docs updated, governance checked, QA recorded, next action stated.
**Trigger context:** Uses `{{task.id}}` and `{{task.title}}` from Kiro task execution context.

---

## Trigger Coverage Map (no dual-firing)

| File saved or event | Hook triggered |
|---|---|
| `docs/technical/**` | spec-documentation-guard |
| `docs/governance/**` | spec-documentation-guard |
| `docs/functional/**` | ux-traceability-check |
| `docs/user/**` | ux-traceability-check |
| `knowledge/ux-stitch/**` | ux-traceability-check |
| `PAIN_POINTS_TRACEABILITY.md` | ux-traceability-check |
| `specs/**/requirements.md` | spec-quality-gate |
| `specs/**/design.md` | spec-quality-gate |
| Agent session ends | session-governance-check |
| Spec task execution completes | controlled-closure-check |

---

## Schema Uncertainty and Provisional Status

**Important:** The YAML hook schema used in `.kiro/hooks/` is based on the best available
documentation for Kiro IDE as of project setup. The following field names may vary by
installed Kiro IDE version:

| Field | Value used | May also be |
|---|---|---|
| `trigger.type` | `fileSave`, `agentStop`, `postTaskExecution` | `file_save`, `agent_stop`, `post_task_execution` |
| `action.type` | `agentPrompt` | `agent`, `ai_prompt` |
| Task context variable | `{{task.id}}`, `{{task.title}}` | `{{taskId}}`, `{{taskTitle}}` |
| File context variable | `{{file}}` | `{{filePath}}`, `{{path}}` |

**Before enabling hooks:** Open each file in Kiro IDE and verify the schema is accepted.
If Kiro IDE reports a schema error, use the Fallback UI Setup section below.

---

## Fallback UI Setup

If Kiro IDE does not accept the file-based hook format, configure the hooks manually via
the Kiro IDE Hook UI. Use the following definitions:

### spec-documentation-guard (UI)
- **Trigger:** File Save
- **File pattern:** `docs/technical/**/*.md`, `docs/governance/**/*.md`
- **Action:** Agent Prompt
- **Prompt:** *Copy from `.kiro/hooks/spec-documentation-guard.yaml` → `action.prompt` field*

### session-governance-check (UI)
- **Trigger:** Agent Stop
- **Action:** Agent Prompt
- **Prompt:** *Copy from `.kiro/hooks/session-governance-check.yaml` → `action.prompt` field*

### spec-quality-gate (UI)
- **Trigger:** File Save
- **File pattern:** `specs/**/requirements.md`, `specs/**/design.md`
- **Action:** Agent Prompt
- **Prompt:** *Copy from `.kiro/hooks/spec-quality-gate.yaml` → `action.prompt` field*

### ux-traceability-check (UI)
- **Trigger:** File Save
- **File pattern:** `docs/functional/**/*.md`, `docs/user/**/*.md`, `knowledge/ux-stitch/**/*.md`, `PAIN_POINTS_TRACEABILITY.md`
- **Action:** Agent Prompt
- **Prompt:** *Copy from `.kiro/hooks/ux-traceability-check.yaml` → `action.prompt` field*

### controlled-closure-check (UI)
- **Trigger:** Post Task Execution (preferred) — or File Save on `specs/000-master-ifrs16-addon/tasks.md` as fallback
- **Action:** Agent Prompt
- **Prompt (post-task-execution version):** *Copy from `.kiro/hooks/controlled-closure-check.yaml` → `action.prompt` field*
- **Prompt (file-save fallback):** Detect whether any task row was marked Done. If yes, enforce the five-point closure gate (spec, docs, governance, QA, next action). If no task marked Done, output: "No closure action detected - no check needed."

---

## Known Limitations

1. **Schema version uncertainty:** The hook YAML files are provisional. Field names must be
   validated against the installed Kiro IDE version before relying on file-based activation.

2. **controlled-closure-check task context:** The `{{task.id}}` and `{{task.title}}` variables
   depend on Kiro IDE exposing task execution context in the hook prompt. If these variables
   are not populated, the agent will still perform the closure check with whatever context is
   available from the session.

3. **Spec → doc continuity gap:** There is no dedicated file-save hook on `specs/` that checks
   documentation impact when specs change. This is intentional (to avoid dual-firing with
   `spec-quality-gate`). Coverage is provided by `session-governance-check` at agent stop.
   If more immediate spec → doc checking is needed, invoke the `docs-continuity` agent
   explicitly after significant spec changes.

4. **agentStop reliability:** The `agentStop` trigger fires at the end of every agent session,
   including minor ones. The `session-governance-check` prompt is designed to self-filter
   (short output when nothing was produced), but expect it to fire often.

---

## What Hooks Must Never Do

- Perform `git add`, `git commit`, or `git push` automatically.
- Overwrite user content without explicit confirmation.
- Hard-block the IDE from saving (advisory output only — not hard blocks).
- Send content to external services without explicit user action.

---

## Recommended Enablement Order

1. `session-governance-check` — lowest friction; fires only at session end
2. `spec-quality-gate` — silent when clean; only reports real spec issues
3. `controlled-closure-check` — fires only on task execution events
4. `ux-traceability-check` — silent when consistent; fires on UX/functional doc saves
5. `spec-documentation-guard` — enable last; monitor for noise on first use

---

## Activation Checklist

Before activating hooks in Kiro IDE:

1. Open each `.kiro/hooks/*.yaml` file in Kiro IDE and confirm the schema is accepted.
2. If schema errors appear, use the Fallback UI Setup section above.
3. Verify `postTaskExecution` trigger is supported in the installed Kiro IDE version.
4. Test `controlled-closure-check` on a test task before relying on it in production.
5. Record hook activation in `docs/governance/decision-log.md` with date and version.
