# Hooks Setup — RE-SAP IFRS 16 Addon

**Operating model:** Kiro IDE-first. All hooks are implemented in `.kiro/hooks/` as YAML files.
Kiro IDE compiles each YAML into a `.kiro.hook` JSON file, which is the runtime representation.

**Status:** Active — 5 hooks compiled and enabled by Kiro IDE.

**Non-negotiable rule:** No hook in this project may perform `git add`, `git commit`, or `git push`
automatically. All version control operations require explicit human action.

---

## Overview

Hooks in this project serve governance and quality gate purposes. They are not convenience
automation — they are the enforcement layer for the documentation policy, risk capture mandate,
and spec quality standards defined in `AGENTS.md` and `.kiro/steering/documentation-policy.md`.

---

## Confirmed Kiro IDE Hook Schema

Kiro IDE reads the YAML source files and compiles them to `.kiro.hook` JSON. The confirmed
field mappings (validated from compiled output) are:

| YAML field | Kiro runtime field | Notes |
|---|---|---|
| `when.type: fileEdited` | `when.type: fileEdited` | File save trigger |
| `when.type: agentStop` | `when.type: agentStop` | Agent session end trigger |
| `when.type: postTaskExecution` | `when.type: postTaskExecution` | Spec task completion trigger |
| `when.patterns: [...]` | `when.patterns: [...]` | Glob pattern list |
| `then.type: askAgent` | `then.type: askAgent` | Agent prompt action |
| `then.prompt: \|` | `then.prompt` | Multiline prompt string |

Template variables confirmed available in prompts: `{{file}}`, `{{task.id}}`, `{{task.title}}`

---

## Implemented Hooks

### Hook 1 — spec-documentation-guard
**File:** `.kiro/hooks/spec-documentation-guard.yaml`
**Trigger:** `fileEdited` on `docs/technical/**/*.md` and `docs/governance/**/*.md`
**Purpose:** When a technical or governance document changes, check whether companion
master docs (functional, technical, user) need corresponding updates.
**Scope note:** Intentionally excludes `docs/functional/` and `docs/user/` — covered by
`ux-traceability-check`. Excludes `specs/` — covered by `spec-quality-gate`.
**Spec → doc continuity:** When spec files change and may require doc updates, this is
covered at agent stop by `session-governance-check`, which always checks documentation
impact from the session. No file-save hook fires on `specs/` → avoids dual-firing.

---

### Hook 2 — session-governance-check
**File:** `.kiro/hooks/session-governance-check.yaml`
**Trigger:** `agentStop`
**Purpose:** After each agent session, one pass covering two concerns:
- **Part 1:** New risks, assumptions, dependencies, or TBC items → governance registers
- **Part 2:** Reusable knowledge produced → correct `knowledge/` subfolder

---

### Hook 3 — spec-quality-gate
**File:** `.kiro/hooks/spec-quality-gate.yaml`
**Trigger:** `fileEdited` on `specs/**/requirements.md` and `specs/**/design.md`
**Purpose:** Validate spec structure, AC quality (Given/When/Then), traceability footers,
and cross-spec consistency. Silent when clean.
**Note:** `tasks.md` is excluded — task closure is governed by `controlled-closure-check`.

---

### Hook 4 — ux-traceability-check
**File:** `.kiro/hooks/ux-traceability-check.yaml`
**Trigger:** `fileEdited` on `docs/functional/**/*.md`, `docs/user/**/*.md`,
`knowledge/ux-stitch/**/*.md`, and `PAIN_POINTS_TRACEABILITY.md`
**Purpose:** Verify PP-A through PP-M traceability across the four-document chain when
UX-related or user-facing docs change. Silent when consistent.

---

### Hook 5 — controlled-closure-check
**File:** `.kiro/hooks/controlled-closure-check.yaml`
**Trigger:** `postTaskExecution` — fires after a Kiro IDE spec task completes
**Purpose:** Enforce the five-point closure gate: spec currency, docs updated, governance
checked, QA recorded, next action stated.
**Context:** Uses `{{task.id}}` and `{{task.title}}` from Kiro task execution context.

---

## Trigger Coverage Map (no dual-firing)

| File edited or event | Hook triggered |
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

## File Structure

```
.kiro/hooks/
  spec-documentation-guard.yaml       # YAML source (authoritative)
  spec-documentation-guard.kiro.hook  # JSON compiled by Kiro IDE (runtime)
  session-governance-check.yaml
  session-governance-check.kiro.hook
  spec-quality-gate.yaml
  spec-quality-gate.kiro.hook
  ux-traceability-check.yaml
  ux-traceability-check.kiro.hook
  controlled-closure-check.yaml
  controlled-closure-check.kiro.hook
```

Edit the `.yaml` files to change hook behavior. Kiro IDE recompiles the `.kiro.hook`
files automatically. Both are committed to version control.

---

## Known Limitations

1. **session-governance-check fires on all sessions:** The `agentStop` trigger fires after
   every agent session, including short ones. The prompt self-filters (one sentence when
   nothing was produced), but expect this to be the most frequently triggered hook.

2. **Spec → doc continuity at file-save:** There is no dedicated file-save hook on `specs/`
   that checks doc impact when specs change — intentional to avoid dual-firing with
   `spec-quality-gate`. If immediate spec → doc checking is needed after a significant spec
   change, invoke the `docs-continuity` agent explicitly.

3. **controlled-closure-check task context:** `{{task.id}}` and `{{task.title}}` are available
   if Kiro IDE exposes them via task execution context — confirmed schema supports this.

---

## What Hooks Must Never Do

- Perform `git add`, `git commit`, or `git push` automatically.
- Overwrite user content without explicit confirmation.
- Hard-block the IDE from saving (advisory output only).
- Send content to external services without explicit user action.

---

## Recommended Enablement Order

All hooks are enabled by default when Kiro IDE reads the compiled `.kiro.hook` files.
If you need to disable/re-enable selectively, do it via the Kiro IDE Hook UI, in this order:

1. `session-governance-check` — lowest friction; fires only at session end
2. `spec-quality-gate` — silent when clean; reports only real issues
3. `controlled-closure-check` — fires only on task execution events
4. `ux-traceability-check` — silent when consistent
5. `spec-documentation-guard` — monitor for noise on first use
