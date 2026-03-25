# Migration Notes — Kiro IDE-First Operating Model

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0 | 2026-03-24 | Remediation | Initial IDE-first operating model documentation |

---

## Decision: Kiro IDE is the Primary Runtime

**Decision date:** 2026-03-24
**Decision owner:** Project Governance Lead / AI/Kiro Practitioner

This project operates primarily through **Kiro IDE**. This is not a convenience preference —
it is an architectural choice driven by the project's dependency on features that only exist
in the IDE runtime:

| Feature | Available in Kiro IDE | Available in Kiro CLI |
|---------|----------------------|----------------------|
| Steering document injection (always / auto) | Yes | Partial |
| Multiagent orchestration (orchestrator + specialists) | Yes | Limited |
| Skill invocation from agent sessions | Yes | Limited |
| Hook system (on-save, on-session-end, etc.) | Yes | No |
| MCP server integration (Stitch, SAP RFC, Vector store) | Yes | No |
| Spec-linked task execution | Yes | No |
| Resource URI resolution (file://, skill://) | Yes | Limited |

Any workflow that bypasses the IDE loses governance enforcement, hook-based quality gates,
and agent coordination. This creates risk for a compliance-driven project.

---

## What Changed in This Remediation (2026-03-24)

The following changes were made to normalize this project as IDE-first:

### 1. README.md Updated

Added explicit operating model table (IDE = PRIMARY, CLI = Secondary) and agent strategy
section distinguishing orchestrator from specialists. Added pain point overview table.
Removed ambiguity about whether CLI or IDE is the primary entry point.

### 2. Agent Resources Migrated to URI Format

All `.kiro/agents/*.json` files now use URI-based resource references:
- File resources: `"uri": "file://path/to/file.md"`
- Skill resources: `"uri": "skill://.kiro/skills/skill-name/SKILL.md"`

This replaces the previous `"type": "file", "path": "..."` format, which was a legacy
schema that may not be recognized by Kiro IDE's resource resolution system.

### 3. Skill YAML Frontmatter Added

All 8 `SKILL.md` files now have YAML frontmatter with `name` and `description` fields at
the top of the file. This is required for Kiro IDE to recognize and list skills in the
skill picker. Without frontmatter, skills are invisible to the IDE.

Before remediation:
```
# Skill: IFRS 16 Contract Analysis
## Title
...
```

After remediation:
```yaml
---
name: ifrs16-contract-analysis
description: >-
  Analyze a lease contract for IFRS 16 scope...
---

# Skill: IFRS 16 Contract Analysis
```

### 4. Dangerous Automation Removed

`.claude/settings.json` previously contained a Stop hook that performed:
```
git add -A && git commit -m "auto: ..." && git push origin HEAD
```

This hook was **removed**. It violated the project's no-auto-commit rule and created
risk of pushing unreviewed content to remote. The file now contains an empty hooks object.

### 5. HOOKS_SETUP.md Created

A formal hooks plan (`HOOKS_SETUP.md`) documents 6 IDE-oriented hooks with trigger/action
logic. None of these hooks perform git operations. They are governance reminders and
quality gate prompts.

---

## Kiro IDE Operating Model

### Session Entry Point

Always start sessions from the **Orchestrator agent** in Kiro IDE:
1. Open `.kiro/agents/orchestrator-ifrs16.json` in Kiro IDE.
2. Start a new agent session.
3. The orchestrator reads current spec phase, identifies highest priority open item,
   and proposes the first concrete action.

### Steering Document Behavior

Steering documents in `.kiro/steering/` are injected automatically:

| File | Inclusion | When Active |
|------|-----------|------------|
| `product.md` | `always` | Every agent session |
| `tech.md` | `always` | Every agent session |
| `structure.md` | `always` | Every agent session |
| `ai-governance.md` | `always` | Every agent session |
| `documentation-policy.md` | `always` | Every agent session |
| `ifrs16-domain.md` | `auto` | When domain topics are detected |
| `sap-re-architecture.md` | `auto` | When RE/SAP topics are detected |
| `decision-policy.md` | `auto` | When ADR or decision topics are detected |
| `rag-policy.md` | `auto` | When knowledge base topics are detected |

Do not manually inject steering content into agent prompts. The IDE handles this.

### Skill Invocation

Skills are invoked from agent sessions. The IDE presents available skills based on their
YAML frontmatter. To use a skill:
1. In an agent session, reference the skill by name.
2. The IDE resolves the skill URI and presents the skill content.
3. The agent executes the skill procedure.

Skills are not scripts — they are structured playbooks that guide agent behavior.

### MCP Integration (Future)

When MCP servers are configured, they extend agent capabilities:

| MCP Server | Purpose | Status |
|-----------|---------|--------|
| Google Stitch | Read UI designs directly into ux-stitch agent | Not installed — TBC |
| SAP RFC Gateway | Query live SAP RE-FX data for design validation | Not installed — TBC |
| Vector Knowledge Store | Semantic RAG retrieval over `knowledge/` | Not installed — TBC |

MCP servers must pass security review before activation. See `.kiro/steering/ai-governance.md`.

---

## CLI Compatibility Layer

Kiro CLI remains available for lightweight operations that do not require agent coordination.
Acceptable CLI uses in this project:

- Running a single specialist agent in isolation for a focused query.
- Generating a document draft without multi-agent coordination.
- Knowledge base health check via the `rag-knowledge` agent.

**Not acceptable via CLI:**
- Phase gate reviews (require orchestrator coordination).
- Any operation involving ADR decisions (require decision-policy enforcement).
- Any operation that should trigger a documentation update (docs-continuity agent needed).
- Any operation involving IFRS 16 accounting conclusions (human validation chain required).

If a CLI session produces output that would normally update specs or docs, those updates must
be applied manually before the session is considered complete.

---

## Agent Role Boundaries (Summary)

This project enforces strict role separation between the orchestrator and specialists:

### Orchestrator (`orchestrator-ifrs16`)

- Owns the delivery program.
- Reads and enforces spec status.
- Blocks premature task closure.
- Coordinates specialist agents.
- Verifies documentation alignment after every output.
- Does NOT perform specialist analysis itself.

### Specialists (7 agents)

- Perform expert analysis within their domain.
- Produce proposals — not final decisions.
- Cannot close tasks globally.
- Cannot approve their own outputs.
- Must hand off to the orchestrator for traceability tracking.

**The orchestrator/specialist boundary is not a convention — it is a control.**
Without it, the governance chain that connects requirements → design → accounting validation
→ documentation → audit evidence breaks down.

---

## What to Do If You Work Without Kiro IDE

If you must work without Kiro IDE access (e.g., in a terminal-only environment):

1. **Read `AGENTS.md` first.** All 10 behavioral rules still apply in any session.
2. **Use steering documents manually.** Read `.kiro/steering/product.md`, `tech.md`, and
   the relevant domain steering before starting work.
3. **Follow the documentation policy.** Every output that changes a spec or design must
   update the corresponding `docs/` file in the same work session.
4. **Do not close tasks.** All task closure requires orchestrator coordination and human gate
   confirmation. Mark items as "In Progress" or "Pending Review" — never Done unilaterally.
5. **Log all open items.** After every session, add assumptions, risks, and open questions to
   the corresponding registers in `docs/governance/`.
6. **Do not commit without review.** No git operations without explicit human decision.
   See `.claude/settings.json` — auto-push has been removed.

---

## Verification Checklist (After Any Workspace Change)

When modifying the Kiro workspace itself (agents, steering, skills), verify:

- [ ] All `SKILL.md` files have YAML frontmatter with `name` and `description`.
- [ ] All `agents/*.json` files use URI-based resources (`file://` or `skill://`).
- [ ] All `steering/*.md` files have valid frontmatter with an `inclusion` field.
- [ ] `.claude/settings.json` contains no git automation hooks.
- [ ] `HOOKS_SETUP.md` is up to date with any new hooks.
- [ ] `README.md` still accurately describes the current workspace structure.
- [ ] `BOOTSTRAP_SUMMARY.md` reflects the current state of the workspace.
