# Skill: RAG Knowledge Curation

## Title
RAG Knowledge Curation — Source Classification, Deduplication, and Knowledge Base Maintenance

## Description
This skill manages the quality and integrity of the RAG knowledge base in knowledge/. It classifies new knowledge sources, removes or resolves duplicates and conflicts, maintains the source hierarchy, and ensures all files meet metadata standards. This is a recurring maintenance skill that should be run at the start of every new project phase and whenever significant new knowledge is added.

## When to Use
- When adding new IFRS 16 guidance documents, SAP notes, or design artifacts to the knowledge base.
- At the start of each project phase to verify knowledge base health.
- When an IFRS standard amendment is published and existing sources may be superseded.
- When the IFRS 16 Accountant flags a source as inaccurate or outdated.
- When agents report conflicting information from multiple knowledge sources.
- When UAT findings reveal knowledge gaps.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| New sources to add (if applicable) | Files or content to be classified and added | Project team or external documents |
| Current knowledge index | List of existing knowledge files | knowledge/[folder]/README.md files |
| RAG policy | Metadata standards, source hierarchy, chunking rules | .kiro/steering/rag-policy.md |
| Agent reports | Any flags raised by agents about missing or conflicting knowledge | Agent session outputs |

---

## Steps

### Step 1: Knowledge Health Audit
Scan all files in knowledge/ and produce a health report:
- **Missing metadata:** Files without required YAML frontmatter fields.
- **Unvalidated priority 1-3 sources:** Sources at high priority without a 'validated-by' human name.
- **Stale sources:** Sources with 'status: under-review' with no review-reason or no action taken.
- **Orphaned citations:** Documents in docs/ or specs/ that reference knowledge files that no longer exist.
- **Index gaps:** Files in knowledge/ folders not listed in the corresponding README.md.

Format as a table: Issue Type / File / Details / Recommended Action.

### Step 2: New Source Classification
For each new source proposed for addition:

2a. **Determine priority level** using the hierarchy in .kiro/steering/rag-policy.md:
- Is this an official IFRS source (Priority 1-2)?
- An approved project decision (Priority 3)?
- SAP official doc (Priority 4)?
- SAP internal/process doc (Priority 5)?
- Professional reference (Priority 6)?
- UX design (Priority 7)?
- User feedback (Priority 8)?

2b. **Assign to the correct folder** based on priority and source type.

2c. **Prepare metadata frontmatter:**
```yaml
---
source-type: [type]
source-name: [full title]
source-date: YYYY-MM-DD
source-version: [version/amendment if applicable]
priority: [1-8]
confidence: [high | medium | low]
status: [current | under-review]
tags: [keyword list]
cited-in: []
added-by: [agent or human name]
added-date: YYYY-MM-DD
validated-by: [REQUIRED for priority 1-3 — human name]
validation-date: YYYY-MM-DD
---
```
For Priority 1-3: set status to 'under-review' until a human validates and provides their name.

2d. **Apply chunking strategy** for long documents:
- Split at logical concept boundaries (one concept per chunk).
- Maximum 1,000-1,500 tokens per chunk.
- Add contextual header to each chunk.
- Ensure no orphaned chunks (each chunk readable in isolation).

2e. **Check for duplicate coverage:** Search existing files for the same topic. If duplicates exist, note overlap and propose consolidation or differentiation.

### Step 3: Duplicate Detection and Resolution
For topics with multiple files:
- Compare metadata and content.
- If one supersedes the other: mark the older as 'status: superseded', add 'superseded-by' field.
- If they are complementary (different aspects of same topic): verify metadata differentiates them clearly.
- If they genuinely conflict: flag as conflict — do not resolve autonomously.

### Step 4: Conflict Escalation
For each detected conflict between two sources:
- Create an explicit conflict record: Source A / Source B / Nature of conflict / IFRS 16 or project impact.
- Add as an open question in the current work session.
- Assign to IFRS 16 Accountant or Project Governance Lead for resolution.
- Do not use either conflicting source in agent outputs until the conflict is resolved.

### Step 5: Index Update
For each folder in knowledge/:
- Update the README.md index to accurately list all current files.
- Include: file name, source name, priority, status, last validated date, key tags.
- Remove entries for files that have been archived.

### Step 6: Citation Tracking
After adding new sources:
- Search docs/ and specs/ for references to the topic covered by the new source.
- Add the referring documents to the 'cited-in' field of the new source file.
- In the referring documents, verify the citation format meets .kiro/steering/rag-policy.md standards.

---

## Expected Outputs

1. **Knowledge Health Report** — Current state of the knowledge base with issues and recommended actions.
2. **New Files Added** — List of classified and added files with their metadata.
3. **Conflict Log** — Any conflicts detected with escalation status.
4. **Updated README.md indexes** — All knowledge/[folder]/README.md files updated.
5. **Citation Updates** — Docs and specs updated with citations to new sources.

---

## Quality Checks

- [ ] Every new file has complete YAML frontmatter.
- [ ] No Priority 1-3 file marked 'current' without validated-by human name.
- [ ] All detected conflicts explicitly logged and escalated.
- [ ] No duplicate content without clear differentiation.
- [ ] All README.md indexes accurate and complete.
- [ ] Chunking applied correctly for long documents.
- [ ] Stale 'under-review' files have resolution actions assigned.

---

## Handoff to Next Role/Agent

- **IFRS 16 Accountant (Human):** Validate any Priority 1-3 sources added. Resolve any accounting-related conflicts.
- **Project Governance Lead (Human):** Resolve any Priority 3 (ADR) conflicts.
- **Orchestrator Agent (orchestrator-ifrs16):** Report knowledge gaps identified — propose them as backlog items.
- **Docs Continuity Agent (docs-continuity):** Notify of any obsolete sources that may affect current documentation.
