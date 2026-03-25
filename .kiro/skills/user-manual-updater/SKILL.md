---
name: user-manual-updater
description: >-
  Update the master user manual with role-based operational guidance for a new or changed IFRS 16 addon feature, including step-by-step instructions, plain-language IFRS 16 guidance, and release notes.
---

# Skill: User Manual Updater

## Title
User Manual Updater — Role-Based Operational Documentation Update

## Description
This skill updates the master user manual (docs/user/master-user-manual.md) and produces supplementary operational notes when a feature is changed, added, or released. It ensures users have accurate, role-specific, plain-language guidance for every function in the IFRS 16 Z addon.

## When to Use
- When a feature spec has been approved and the user manual must be prepared ahead of UAT.
- When UAT feedback reveals user experience issues that require clarification in the manual.
- When a feature is released to production and the release note must be added to the manual.
- When the user workflow changes due to an approved functional change or ADR.
- When a new persona is added to the project and needs its manual section.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| Feature description | What the new or changed feature does | Functional spec or approved design |
| Affected personas | Which user roles are affected | specs/000-master-ifrs16-addon/requirements.md — personas |
| Screen designs | UI screens (from Stitch or description) | knowledge/ux-stitch/ |
| Process flow | Step-by-step user workflow | Functional spec |
| IFRS 16 guidance notes | Plain-language accounting guidance for users | IFRS 16 domain agent output (validated by accountant) |
| UAT feedback | User experience issues identified in testing | knowledge/user-feedback/ |

---

## Steps

### Step 1: Identify Affected Manual Sections
- Identify which persona sections of docs/user/master-user-manual.md are affected.
- Identify if a new section must be created or an existing section updated.
- Check if the change affects the Quick Start Guide, FAQ, or Troubleshooting sections.

### Step 2: Draft Role-Based Guidance
For each affected persona, write:
- **Task name:** What the user is trying to accomplish.
- **When to perform this task:** Trigger condition (e.g., "When a new lease contract is created in RE-FX...").
- **Prerequisites:** What the user needs before starting (access, approvals, data ready).
- **Step-by-step instructions:** Numbered, specific, and action-oriented. Use present tense: "Click [button]," "Enter [field label]."
- **Field guidance:** For each significant field, a brief explanation of what to enter and why it matters.
- **System response:** What the user sees after each major action.
- **Error handling:** Common error messages in plain language with what to do.
- **Approval steps:** Where the workflow requires action from another user — who, what they see, what they must decide.

### Step 3: IFRS 16 User Guidance (Plain Language)
For steps involving IFRS 16 judgments (lease term, exemption, modification type):
- Provide plain-language guidance on what the judgment means.
- Provide decision criteria the user can apply.
- Clearly state: "If you are unsure, escalate to the Lease Accountant before proceeding."
- Never instruct users to make accounting judgments that require professional sign-off.

### Step 4: Screenshots and Diagrams
- For each major workflow, include a reference to the screen design (Stitch artifact or description).
- Add a process flow diagram (Mermaid or described) showing the overall workflow.
- Caption every diagram with a version date.

### Step 5: Release Note
At the bottom of updated manual sections, add a release note:
```
> Released: YYYY-MM-DD | Version: X.Y | Feature: [short name] | Summary: [1-2 sentences describing what changed]
```

### Step 6: FAQ Update
For each major feature, add or update FAQ entries:
- "Q: What happens if I [common scenario]?" — with a plain-language answer.
- "Q: Who do I contact if [common error/uncertainty]?" — with the correct escalation path.

### Step 7: Consistency Check
Verify:
- Terminology is consistent with the IFRS 16 domain glossary and the functional spec.
- Field names match the actual SAP UI labels.
- Persona sections do not overlap — each persona sees only what is relevant to their role.
- Process described in the manual matches the approved functional spec.

---

## Expected Outputs

1. **Updated User Manual Sections** — Updated content for docs/user/master-user-manual.md for affected personas.
2. **Release Note Entry** — Added to the updated sections and to the docs/governance/decision-log.md release notes.
3. **FAQ Additions** — New or updated FAQ entries.
4. **Documentation Change Summary** — Brief summary for the docs-continuity agent changelog.

---

## Quality Checks

- [ ] All affected personas addressed.
- [ ] Instructions are numbered, specific, and use present-tense active voice.
- [ ] IFRS 16 judgment steps are clearly flagged with escalation instructions.
- [ ] No technical ABAP or system-internal language in user-facing content.
- [ ] Release note added with date and version.
- [ ] Consistency with functional spec verified.
- [ ] Traceability footer updated with current date and spec reference.
- [ ] All screenshots or screen design references are up to date.

---

## Handoff to Next Role/Agent

- **UAT Participants (Human — target personas):** Review the draft manual as part of UAT preparation. Provide feedback.
- **IFRS 16 Accountant (Human):** Validate any plain-language IFRS 16 guidance in the manual for accuracy.
- **Docs Continuity Agent (docs-continuity):** Update the version header in the master user manual and add changelog entry.
- **QA/Audit Controls Agent (qa-audit-controls):** Use the updated manual as the basis for UAT step descriptions.
