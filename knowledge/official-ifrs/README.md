# Knowledge Base: Official IFRS Sources

**Priority Level:** 1 (authoritative) and 2 (interpretive authority)
**Location:** `knowledge/official-ifrs/`
**Managed by:** RAG Knowledge Curator Agent + IFRS 16 Accountant (validation)

---

## Purpose
This folder contains official IFRS 16 source materials and high-quality professional reference documents. These sources form the authoritative basis for all accounting rules applied in the RE-SAP addon. No accounting assertion may be made without grounding in a source from this folder (or an approved project decision in `knowledge/project-decisions/`).

---

## Source Categories in This Folder

| Sub-type | Priority | Examples | Notes |
|----------|---------|---------|-------|
| IFRS 16 Standard (IASB, 2016/2019 effective) | 1 | `ifrs16-standard-2019-full.md` | Authoritative text; cite paragraph number |
| IASB Amendments to IFRS 16 | 1 | `ifrs16-amendment-covid-relief.md`, `ifrs16-amendment-2023.md` | Check effective dates; supersede earlier provisions |
| IASB Basis for Conclusions (IFRS 16) | 2 | `ifrs16-basis-for-conclusions.md` | Interpretive authority; explains intent of standard |
| IFRIC Agenda Decisions relevant to IFRS 16 | 2 | `ifric-2019-cancellable-leases.md` | High interpretive value; cite decision date |
| Big 4 / professional body IFRS 16 guides | 6 (stored here, tagged as reference) | `pwc-ifrs16-guide-2024.md` | Reference quality only; cross-check with standard |

---

## How to Add a New Source

1. **Confirm priority level** — Is this an official IASB source (Priority 1-2) or a professional reference (Priority 6)?
2. **Check for overlap** — Search existing files for the same topic. Do not add a duplicate without noting the differentiation.
3. **Prepare the file** with the required YAML frontmatter:

```yaml
---
source-type: official-ifrs
source-name: [Full title, e.g., "IFRS 16 Leases — IASB January 2019"]
source-date: YYYY-MM-DD
source-version: [e.g., "Effective January 2019" or "Amendment 2023"]
priority: [1 or 2 for official; 6 for professional reference]
confidence: high
status: current
tags: [ifrs16, lease-term, discount-rate, modifications, etc.]
cited-in: []
added-by: [name]
added-date: YYYY-MM-DD
validated-by: [REQUIRED — IFRS 16 Accountant name]
validation-date: YYYY-MM-DD
---
```

4. **Human validation required** before changing `status` from `under-review` to `current` for Priority 1-2 sources.
5. **Update this README** — add an entry to the index table below.
6. **Chunking:** For long documents, apply chunking rules from `.kiro/steering/rag-policy.md`. One concept per chunk; maximum 1,500 tokens; contextual header on every chunk.

---

## Index of Current Sources

| File | Title | Priority | Status | Date | Key Topics |
|------|-------|---------|--------|------|-----------|
| *(To be populated as sources are added)* | | | | | |

---

## Key IFRS 16 Topics to Cover (Minimum Required)

The following topics must have dedicated source chunks before Phase 1 development begins:

- [ ] Lease identification — three criteria (IFRS 16 ¶9–11)
- [ ] Short-term exemption (IFRS 16 ¶5(a), ¶B34)
- [ ] Low-value exemption (IFRS 16 ¶5(b), ¶B3–B8)
- [ ] Lease term definition and options (IFRS 16 ¶19–21, ¶B37–B40)
- [ ] Discount rate — rate implicit in lease vs. IBR (IFRS 16 ¶26, ¶A1)
- [ ] Lessee initial measurement (IFRS 16 ¶26–28)
- [ ] Lessee subsequent measurement — liability (IFRS 16 ¶36–38)
- [ ] Lessee subsequent measurement — ROU asset (IFRS 16 ¶29–35)
- [ ] Variable lease payments (IFRS 16 ¶38, ¶42)
- [ ] Modification — separate new lease (IFRS 16 ¶44–46)
- [ ] Modification — not a separate lease (IFRS 16 ¶44–46)
- [ ] Remeasurement of lease liability (IFRS 16 ¶45–46)
- [ ] Disclosure requirements lessee (IFRS 16 ¶52–60)
- [ ] Non-lease components (IFRS 16 ¶12–16)

---

## Version and Obsolescence Management
- When the IASB publishes an amendment, add the new version and mark the affected prior sections as `status: superseded`.
- Add `superseded-by: [new filename]` to the superseded file.
- Notify the docs-continuity agent to review all documents citing the superseded source.
