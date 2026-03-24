# Knowledge Base: UX Design Artifacts (Stitch)

**Priority Level:** 7 (authoritative for UI/UX decisions)
**Location:** `knowledge/ux-stitch/`
**Managed by:** UX/Stitch Agent + UX Designer (content)

---

## Purpose
This folder stores UI/UX design artifacts for the IFRS 16 Z addon. When the Google Stitch MCP server is activated, the `ux-stitch` agent will feed artifacts directly into this folder. Until then, designs are added manually as exports, screenshots, or structured descriptions.

Designs in this folder are authoritative for UI implementation decisions but are not authoritative for accounting or SAP technical behavior.

---

## What to Store Here

| Artifact Type | Description | Format |
|---------------|-------------|--------|
| Screen designs | Full screen layouts from Stitch | PNG export or Markdown description |
| Component specifications | Reusable UI components (form fields, wizards, status displays) | Markdown with field tables |
| User flow diagrams | Navigation flows between screens | Mermaid flowchart or PNG |
| Interaction specifications | Button behaviors, validation messages, conditional displays | Markdown |
| MCP-exported artifacts | Raw Stitch design exports when MCP is active | To be determined on activation |

---

## MCP Integration (Future)
When the Google Stitch MCP server is configured:
- The `ux-stitch` agent will read designs directly from Stitch projects.
- Designs will be extracted as structured component specifications and stored here.
- Every MCP-fed artifact will be treated as untrusted input until validated by the UX designer and a target persona user.
- MCP activation procedure: see `.kiro/agents/ux-stitch.json` for configuration notes.

**Current status:** MCP server not installed. [TO BE CONFIRMED — when activated, update this README.]

---

## Required Frontmatter

```yaml
---
source-type: ux-stitch
source-name: [Screen or component name, e.g., "Contract Intake Wizard — Step 2: Options"]
source-date: YYYY-MM-DD
source-version: [Design version, e.g., "v0.2"]
priority: 7
confidence: [high | medium | draft]
status: [current | draft | under-review | superseded]
tags: [intake, wizard, options, status-display, etc.]
user-story-ref: [US-X.X from requirements.md]
persona: [P1 | P2 | P3 — which persona this design serves]
pain-point-ref: [Which pain point from knowledge/user-feedback/ this addresses]
cited-in: []
added-by: [UX designer name or agent]
added-date: YYYY-MM-DD
validated-by: [Persona representative name — required for status: current]
validation-date: YYYY-MM-DD
---
```

---

## Design-to-Implementation Lifecycle

```
1. Design created in Stitch (or described manually)
2. Stored here with status: draft
3. ux-stitch agent reviews against pain points and SAP constraints
4. Issues flagged for UX designer
5. Persona representative validates design
6. Status → current when validated
7. Implementation tasks generated from design
8. Tasks added to specs/000-master-ifrs16-addon/tasks.md
9. After implementation: design cited in docs/user/master-user-manual.md
```

---

## Index of Current Designs

| File | Screen/Component | User Story | Persona | Status | Date |
|------|-----------------|-----------|---------|--------|------|
| *(To be populated as designs are created)* | | | | | |

---

## UX Simplification Principles (Reference)
All designs must comply with the principles from `.kiro/steering/sap-re-architecture.md`:
- Progressive disclosure: only IFRS 16-relevant fields at each step.
- Smart defaults from RE-FX data.
- Plain-language validation messages.
- Decision wizards for complex IFRS 16 judgments.
- Calculation preview before posting.
- IFRS 16 status visible per contract.
