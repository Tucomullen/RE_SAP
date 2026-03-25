# Hooks Plan — Design/Stitch Layer

**Status:** Proposal — not yet implemented
**Date:** 2026-03-25
**Author:** Design layer bootstrap

---

## Context

The repository already has five active Kiro hooks:

| Hook | Trigger | Purpose |
|------|---------|---------|
| `ux-traceability-check` | fileEdited on docs/functional/**, docs/user/**, knowledge/ux-stitch/**, PAIN_POINTS_TRACEABILITY.md | Verify UX traceability across functional docs |
| `spec-quality-gate` | fileEdited on specs/** | Enforce spec quality standards |
| `spec-documentation-guard` | fileEdited on specs/** | Guard documentation alignment |
| `session-governance-check` | (see yaml) | Session governance enforcement |
| `controlled-closure-check` | (see yaml) | Controlled session closure |

This plan proposes **minimal, safe additions** to support the design/stitch layer.
No existing hooks are modified. Changes are additive only.

---

## Proposed Hook 1 — Extend ux-traceability-check

**Type:** Configuration update to existing hook (minimal, safe)
**File to update:** `.kiro/hooks/ux-traceability-check.yaml` and `.kiro/hooks/ux-traceability-check.kiro.hook`

**Change:** Add `design/stitch/**/*.md` to the `patterns` array.

```yaml
# Proposed addition to existing patterns list:
patterns:
  - "docs/functional/**/*.md"
  - "docs/user/**/*.md"
  - "knowledge/ux-stitch/**/*.md"
  - "PAIN_POINTS_TRACEABILITY.md"
  - "design/stitch/**/*.md"          # NEW — covers prompts, screens, hooks-plan
```

**Rationale:** Design artifacts in `design/stitch/` are upstream of `knowledge/ux-stitch/`. Changes to prompts or traceability files should trigger the same consistency check. No new agent prompt needed — the existing check covers the right questions.

**Risk:** Low. Adding a pattern to an existing hook extends coverage without changing behavior.

**Pre-condition before implementing:** Review the existing `ux-traceability-check` prompt to confirm it handles `design/stitch/` file context correctly. The current prompt references four specific files — confirm the agent can also reason about new design artifacts without prompt changes, or update the prompt text accordingly.

---

## Proposed Hook 2 — Stitch Export Sync

**Type:** New hook — `agentStop` trigger
**File to create:** `.kiro/hooks/stitch-export-sync.kiro.hook` + `.kiro/hooks/stitch-export-sync.yaml`
**Status:** Proposed — do not implement until Stitch MCP is confirmed working

**Trigger:**
```yaml
when:
  type: agentStop
  agentName: "ux-stitch"
```

**Purpose:** When the ux-stitch agent finishes a session, prompt a review of whether:
1. Any new exports were generated and saved to `design/stitch/exports/`.
2. Any exports require a traceability file in `design/stitch/screens/`.
3. Any reviewed screens are ready to promote to `knowledge/ux-stitch/`.

**Agent prompt (draft):**
```
The ux-stitch agent just finished a session.

Check design/stitch/exports/ for any new files added in this session.
For each new export:
1. Is there a corresponding traceability file in design/stitch/screens/?
   If not, create one from design/stitch/screens/TRACEABILITY_TEMPLATE.md.
2. Has the export been reviewed against pain points and SAP constraints?
   If not, flag it as requiring review.
3. Is the export ready to promote to knowledge/ux-stitch/?
   If yes, remind the user to add the required frontmatter and move the file.

If no new exports were generated, output:
"No new Stitch exports detected - no sync needed."
```

**Risk:** Medium. `agentStop` trigger timing in Kiro may vary. Implement only after confirming the trigger fires reliably in this workspace. Test with a stub agent session first.

---

## Proposed Hook 3 — Prompt Validation on Save

**Type:** New hook — `fileEdited` trigger
**File to create:** `.kiro/hooks/stitch-prompt-guard.kiro.hook` + `.kiro/hooks/stitch-prompt-guard.yaml`
**Status:** Proposed — lower priority, implement after Hook 1

**Trigger:**
```yaml
when:
  type: fileEdited
  patterns:
    - "design/stitch/prompts/**/*.md"
```

**Purpose:** When a Stitch prompt file is saved, run a lightweight check:
1. Does the prompt reference a specific user story from `specs/`?
2. Does it reference the applicable DESIGN.md constraints?
3. Does it define all required sections (business objective, states, validations, SAP constraints)?

**Agent prompt (draft):**
```
A Stitch prompt file was just saved: {{file}}

Verify the prompt is complete and consistent:
1. Does it reference a specific user story or epic from specs/000-master-ifrs16-addon/requirements.md?
   If not, flag as incomplete.
2. Does it reference design/stitch/DESIGN.md constraints?
   If not, flag as incomplete.
3. Does it include these required sections?
   - Business objective
   - Primary user / persona
   - Layout description
   - States to design
   - SAP/Fiori constraints
   If any section is missing, list which ones.

If the prompt is complete and consistent, output:
"Stitch prompt complete - no issues found."
```

**Risk:** Low. Read-only check. Does not modify files.

---

## Implementation sequence recommendation

1. **Do now (safe):** Add `design/stitch/**/*.md` pattern to `ux-traceability-check` (Hook 1 proposal). One-line change to existing hook.
2. **Do after MCP is confirmed working:** Implement Hook 2 (stitch-export-sync). Validate `agentStop` trigger first.
3. **Do when prompt library grows:** Implement Hook 3 (stitch-prompt-guard). Low value with only one prompt; high value when there are 5+.

---

## What this plan does NOT propose

- No hooks that auto-commit or auto-push anything.
- No hooks that trigger ABAP-related checks (out of scope for design layer).
- No hooks that require external service calls before Stitch MCP is confirmed.
- No modifications to the spec-quality-gate or session-governance hooks.
