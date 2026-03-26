---
inclusion: auto
description: RAG knowledge base policy — source priority, trust levels, and curation rules for the RE-SAP IFRS 16 addon.
---

# RAG Policy — RE-SAP IFRS 16 Addon

## Purpose
This policy governs how the knowledge base in `knowledge/` is structured, maintained, and retrieved by AI agents. Consistent application of this policy ensures that agent outputs are grounded, traceable, and reliable.

---

## Source Hierarchy

The following priority order governs which sources are used when multiple sources address the same topic. Higher priority sources supersede lower priority sources:

| Priority | Source Category | Location | Notes |
|----------|----------------|----------|-------|
| 1 | Official IFRS 16 standard and IASB amendments | `knowledge/official-ifrs/` | Authoritative. Cite paragraph number. Never overridden by internal sources. |
| 2 | IASB Basis for Conclusions and educational materials | `knowledge/official-ifrs/` | Interpretive authority. Use when standard text is ambiguous. |
| 3 | Approved project decisions and ADRs | `knowledge/project-decisions/` | Binding for this project once "Accepted." Cite ADR number. |
| 4 | Official SAP documentation (help.sap.com, SAP Notes) | `knowledge/sap-functional/` | Authoritative for SAP behavior. Cite SAP Note number or URL (non-navigable — describe content). |
| 5 | Internal SAP RE-FX process documentation | `knowledge/sap-functional/` | Reference for current-state process. Validate with Functional Consultant. |
| 6 | Big 4 / professional body IFRS 16 guidance | `knowledge/official-ifrs/` (tagged as reference) | Reference quality. Cross-check with Priority 1. Note the firm and publication date. |
| 7 | UX and design artifacts | `knowledge/ux-stitch/` | Authoritative for UI/UX decisions. Not authoritative for accounting or SAP behavior. |
| 8 | User feedback and UAT findings | `knowledge/user-feedback/` | Evidence for requirements and usability. Not authoritative for accounting rules. |
| 9 | Agent-generated inference | None (labeled in output) | Never stored as knowledge. Always labeled as inference requiring validation. |

---

## Required Metadata for Each Knowledge Chunk/Source

Every file stored in `knowledge/` must include a YAML frontmatter metadata block:

```yaml
---
source-type: [official-ifrs | project-decision | sap-official | sap-internal | professional-reference | ux-stitch | user-feedback]
source-name: [Full title of the source document]
source-date: YYYY-MM-DD
source-version: [Version or amendment identifier if applicable]
priority: [1–8 per hierarchy above]
confidence: [high | medium | low]
status: [current | superseded | under-review | archived]
tags: [comma-separated keywords: ifrs16, lease-term, discount-rate, re-fx, contract-modification, etc.]
cited-in: [list of docs/specs that reference this source]
added-by: [human or agent name]
added-date: YYYY-MM-DD
validated-by: [human name — required for priority 1–3 sources]
validation-date: YYYY-MM-DD
---
```

Priority 1–3 sources **require** a `validated-by` field with a human name. Unvalidated sources in these priorities must be marked `status: under-review` and must not be used as authoritative references until validated.

---

## Versioning
- When an official source is updated (e.g., IFRS 16 amendment), the old file is **not deleted** — it is marked `status: superseded` and a new file is created for the updated version.
- The `source-version` and `source-date` fields distinguish versions.
- All files that cited the superseded source (`cited-in`) must be reviewed and updated.
- The superseded file's frontmatter must include: `superseded-by: [filename of new version]`.

---

## Obsolescence Handling
- Agents must flag a source as potentially obsolete if:
  - A newer version of the same IFRS standard has been published.
  - An ADR has been superseded or deprecated.
  - SAP release notes indicate a change to documented SAP behavior.
  - User feedback contradicts a previously validated assumption.
- Flagging procedure: Change `status` to `under-review` and add a comment: `review-reason: [why this may be obsolete]`.
- The `rag-knowledge` agent is responsible for periodic obsolescence checks.

---

## Conflict Resolution
When two sources at the same priority level conflict:
1. Agents must **not** resolve the conflict autonomously.
2. Flag the conflict explicitly: "Sources [A] and [B] provide conflicting information on [topic]. Human resolution required."
3. Create an open question entry in the current working document.
4. The conflict remains unresolved in the knowledge base until a human decision is made and recorded as an ADR.

When a lower priority source conflicts with a higher priority source:
- The higher priority source governs.
- The lower priority source is updated to reference the higher priority source and note the conflict resolution.

---

## Confidence Labels
All agent outputs referencing knowledge sources must include an explicit confidence label:

| Label | Meaning | When to Use |
|-------|---------|-------------|
| `[CONFIRMED]` | Directly cited from a Priority 1–3 source, human-validated | Only when source is in `knowledge/` and validated |
| `[REFERENCED]` | Derived from a Priority 4–6 source | For SAP or professional guidance citations |
| `[EVIDENCE-BASED]` | Supported by Priority 7–8 sources | For UX decisions or user-validated requirements |
| `[INFERRED]` | Agent reasoning without direct source | Always flag; always require validation |
| `[CONFLICTED]` | Multiple sources disagree | Always escalate; never use as sole basis |

---

## Chunking Principles
When adding long documents to the knowledge base, chunk them following these rules:

1. **One concept per chunk:** Each chunk covers a single identifiable concept or rule. Do not split a paragraph mid-concept.
2. **Maximum chunk size:** 1,000–1,500 tokens per chunk. Shorter is better for precision retrieval.
3. **Contextual header:** Every chunk begins with a contextual header identifying the source, section, and concept: e.g., `## IFRS 16 Para 26 — Discount Rate — Incremental Borrowing Rate`.
4. **No orphaned chunks:** Chunks that reference a previous section must include a brief context sentence — assume the chunk may be retrieved in isolation.
5. **Overlapping context:** For sequential rule sets, include a 1–2 sentence overlap with the preceding chunk to avoid context loss.

---

## Retrieval Principles
Agents must follow these retrieval principles:

1. **Always search before asserting:** Before making a claim about IFRS 16 rules, SAP behavior, or project decisions, search the knowledge base first.
2. **Priority-ordered retrieval:** When multiple chunks are retrieved, present higher-priority sources first and more prominently.
3. **Negative retrieval is informative:** If no relevant knowledge is found, state: "No source found in knowledge base for [topic] — human input required."
4. **Disambiguation:** If multiple relevant chunks are found, present the most specific one (narrower topic = more relevant) over the general one.
5. **Date sensitivity:** When two sources on the same topic have different dates, prefer the more recent one — but flag the superseded source for review.

---

## Citation Expectations Inside Project Docs
All citations in project documents (`docs/`, `specs/`) must follow this format:

> `[CONFIRMED] Source: knowledge/official-ifrs/ifrs16-iasb-2019-para26.md | IFRS 16 ¶26 | Confidence: HIGH | Last validated: 2026-03-24`

Minimum citation format for inline references:
> `(IFRS 16 ¶26 — discount rate — CONFIRMED)`

Unconfirmed inferences in documents:
> `(Inferred — discount rate proxy approach — NEEDS VALIDATION from IFRS 16 Accountant)`

Documents in `docs/` that contain uncited claims will be flagged by the `rag-knowledge` agent during knowledge curation runs.
