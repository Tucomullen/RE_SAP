# Hooks Setup — RE-SAP IFRS 16 Addon

**Operating model:** Kiro IDE-first. All hooks described here are designed for the Kiro IDE
hook system. CLI-equivalent procedures are noted where relevant but are not the primary target.

**Status:** Implementation plan — hooks to be configured in Kiro IDE project settings.

---

## Overview

Hooks in this project serve governance and quality gate purposes. They are not automation
convenience tools — they are the enforcement layer for the project's documentation policy,
risk capture mandate, and spec quality standards.

**Non-negotiable rule:** No hook in this project may perform git add, git commit, or git push
automatically. All version control operations require explicit human action. See `.claude/settings.json`
for the safe hook configuration.

---

## Hook Inventory

### Hook 1: Spec Documentation Guard

**Trigger:** On save of any file in `specs/` or `docs/`

**Purpose:** Detect when a spec or documentation file is changed without a corresponding version
header update. Prevents silent spec drift that breaks traceability.

**Action:**
1. Check that the file's version table (if present) has been updated (date changed from previous commit).
2. Check that a `docs/governance/decision-log.md` release note entry exists for today's date if
   the change is substantive.
3. If either condition fails: display a warning in the IDE: `"Spec or doc changed — version header
   and release note update required before committing."`

**Kiro IDE configuration:**
```yaml
hook:
  name: spec-documentation-guard
  trigger: on-save
  glob: ["specs/**/*.md", "docs/**/*.md"]
  action: warn
  message: >
    Spec or documentation file saved. Verify:
    (1) Version table updated with today's date.
    (2) Release note in docs/governance/decision-log.md if change is substantive.
    (3) docs-continuity agent run if multiple documents are affected.
```

**CLI equivalent:** Pre-commit hook checking file modification dates and version header patterns.
Not implemented automatically — see `.git/hooks/pre-commit.sample` as starting point.

---

### Hook 2: Risk and Assumption Capture

**Trigger:** On completion of any agent session that produced a design output

**Purpose:** Remind the practitioner to check whether the session output introduced new risks
or invalidated existing assumptions.

**Action:**
1. After agent session ends, display prompt: `"Session complete — check docs/governance/risk-register.md
   and docs/governance/assumptions-register.md for new items before closing."`
2. Provide direct links to both files.
3. Log reminder to session output (not to git).

**Kiro IDE configuration:**
```yaml
hook:
  name: risk-assumption-capture
  trigger: on-session-end
  agents: ["orchestrator-ifrs16", "ifrs16-domain", "abap-architecture", "sap-re-ifrs16"]
  action: remind
  message: >
    Agent session ended. Before closing:
    (1) Check docs/governance/risk-register.md — any new risks from this session?
    (2) Check docs/governance/assumptions-register.md — any assumptions invalidated?
    (3) If yes to either, update the register before your next session.
```

---

### Hook 3: Spec Quality Gate

**Trigger:** On save of `specs/000-master-ifrs16-addon/requirements.md` or any spec file

**Purpose:** Check that new user stories follow the mandatory format (ID, Story, Acceptance Criteria)
and that acceptance criteria use Given/When/Then structure.

**Action:**
1. Scan newly added user story rows for missing ID or empty acceptance criteria.
2. Check that at least one acceptance criterion uses Given/When/Then pattern.
3. If quality issues found: display inline warning per story row.

**Kiro IDE configuration:**
```yaml
hook:
  name: spec-quality-gate
  trigger: on-save
  glob: ["specs/**/*.md"]
  action: lint
  checks:
    - pattern: "| US-"
      require: acceptance-criteria-nonempty
      message: "User story missing acceptance criteria."
    - pattern: "Given.*When.*Then"
      require: present-in-acceptance-criteria
      message: "Acceptance criteria should use Given/When/Then format."
```

---

### Hook 4: Knowledge Continuity Reminder

**Trigger:** On save of any file in `knowledge/`

**Purpose:** Remind curators to update the `README.md` index in the same knowledge folder
whenever a new file is added. Prevents index drift.

**Action:**
1. If a new `.md` file is saved in `knowledge/[folder]/` (not named `README.md`): check
   whether `README.md` in the same folder has been modified in the same session.
2. If not: display warning: `"New knowledge file added — update knowledge/[folder]/README.md
   index before committing."`

**Kiro IDE configuration:**
```yaml
hook:
  name: knowledge-continuity-reminder
  trigger: on-save
  glob: ["knowledge/**/*.md"]
  exclude: ["knowledge/**/README.md"]
  action: warn
  message: >
    Knowledge file saved. Check that the README.md index in the same folder has been
    updated to include this file with its metadata summary.
```

---

### Hook 5: UX Traceability Check

**Trigger:** On save of any file in `knowledge/ux-stitch/` or when the UX agent session ends

**Purpose:** Ensure every UX design artifact is linked to a specific user story or acceptance
criterion in `requirements.md`.

**Action:**
1. Check that the saved design artifact's frontmatter includes a `linked-requirement` field.
2. Verify the referenced user story ID exists in `specs/000-master-ifrs16-addon/requirements.md`.
3. If missing or broken: display warning: `"UX artifact must reference a linked-requirement story ID."`

**Kiro IDE configuration:**
```yaml
hook:
  name: ux-traceability-check
  trigger: on-save
  glob: ["knowledge/ux-stitch/**/*.md"]
  action: validate
  frontmatter-field: linked-requirement
  message: >
    UX design artifact saved. Verify it includes a valid linked-requirement field
    pointing to a US-X.X story in requirements.md.
```

---

### Hook 6: Controlled Closure Check

**Trigger:** On any attempt to mark a task as Done in `specs/000-master-ifrs16-addon/tasks.md`

**Purpose:** Enforce the "done" criteria gate — no task is closed without:
- Spec updated
- Docs updated
- QA gate satisfied
- Risk/assumptions reviewed

**Action:**
1. When a task row is modified to include a Done marker: display checklist reminder.
2. Checklist items (from task structure): spec updated, doc updated, QA gate confirmed,
   no new High/Critical risks introduced.
3. User must confirm checklist before saving with Done status.

**Kiro IDE configuration:**
```yaml
hook:
  name: controlled-closure-check
  trigger: on-save
  glob: ["specs/000-master-ifrs16-addon/tasks.md"]
  action: checklist-prompt
  detect: row-marked-done
  checklist:
    - "Spec/requirements.md updated if needed"
    - "docs/ files updated (functional, technical, or user as applicable)"
    - "QA gate criteria met — confirmed by gate owner"
    - "docs/governance/risk-register.md checked for new items"
    - "docs/governance/assumptions-register.md checked for new items"
  message: >
    Task marked as Done. Confirm all closure criteria before saving.
```

---

## Implementation Status

| Hook | Kiro IDE | Notes |
|------|----------|-------|
| Hook 1: Spec Documentation Guard | To be configured | Requires Kiro IDE hook system activation |
| Hook 2: Risk and Assumption Capture | To be configured | Session-end trigger — verify Kiro IDE supports this trigger type |
| Hook 3: Spec Quality Gate | To be configured | Lint-style check — may require Kiro IDE extension |
| Hook 4: Knowledge Continuity Reminder | To be configured | On-save trigger — straightforward to implement |
| Hook 5: UX Traceability Check | To be configured | Requires frontmatter parsing |
| Hook 6: Controlled Closure Check | To be configured | Checklist prompt — verify Kiro IDE UI capability |

---

## Important: What Hooks Must Never Do

- Perform `git add`, `git commit`, or `git push` automatically.
- Overwrite user content without explicit confirmation.
- Block the IDE from saving (warnings only — not hard blocks, unless the user opts in to strict mode).
- Send content to external services without explicit user action.

The `.claude/settings.json` hook has been cleaned. It no longer contains any git automation.
Any future hook proposals must be reviewed by the Project Governance Lead before activation.

---

## Activation Checklist

Before activating hooks in Kiro IDE:

1. Review each hook definition above with the AI/Kiro Practitioner.
2. Confirm the Kiro IDE version supports the trigger types required (on-save, on-session-end, checklist-prompt).
3. Test each hook in isolation on a branch before enabling project-wide.
4. Document any deviations from the specifications above in this file.
5. Add a release note to `docs/governance/decision-log.md` when hooks are activated.
