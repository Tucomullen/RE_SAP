# Knowledge Base: User Feedback and Evidence

**Priority Level:** 8 (evidence for requirements and usability — not authoritative for accounting)
**Location:** `knowledge/user-feedback/`
**Managed by:** Project Governance Lead / QA Lead (content) + RAG Knowledge Curator Agent (maintenance)

---

## Purpose
This folder stores real evidence of user pain points, process frustrations, UAT observations, support ticket patterns, and workshop findings. This evidence grounds the product requirements in real user experience and prevents over-engineering solutions to hypothetical problems. It also informs UX design validation.

Evidence in this folder is not authoritative for accounting rules or SAP technical behavior. It is authoritative for understanding what users actually need.

---

## What to Store Here

| Artifact Type | Description | When to Add |
|---------------|-------------|------------|
| Pain point summaries | Structured descriptions of documented user frustrations | During discovery workshops, interviews |
| UAT observation notes | Specific observations from UAT sessions (anonymized) | After each UAT cycle |
| Support ticket patterns | Aggregated patterns from helpdesk/support tickets | Periodically |
| Workshop output summaries | Key findings from requirements or design workshops | After workshops |
| Survey results | User satisfaction scores, open-ended feedback | After surveys |
| Escalation patterns | Recurring issues escalated to accounting team | Periodically |

**Important:** Never store personally identifiable information (PII) or attributable individual feedback without consent. Always anonymize or aggregate.

---

## Required Frontmatter

```yaml
---
source-type: user-feedback
source-name: [Descriptive title, e.g., "RE Contract Manager — Period-End Pain Points Workshop 2026-03"]
source-date: YYYY-MM-DD
source-version: v1.0
priority: 8
confidence: [high | medium | low]
status: [current | superseded]
tags: [intake, close-process, modification, auditability, etc.]
persona-ref: [P1 | P2 | P3 | P4 — which persona provided this feedback]
linked-requirement: [US-X.X or Epic reference if applicable]
contains-pii: false
added-by: [name]
added-date: YYYY-MM-DD
validated-by: [Project Governance Lead name — confirms source is appropriate]
validation-date: YYYY-MM-DD
---
```

---

## Key Pain Points Already Documented (Bootstrap Baseline)
The following pain points were identified during project initiation and are captured in the product steering (`.kiro/steering/product.md`). They should be formalized as evidence files:

| Pain Point | Persona | Severity | Requirements Link |
|-----------|---------|----------|-----------------|
| Manual spreadsheet burden for IFRS 16 | P1 — Lease Accountant | Critical | BO-1, US-3.1 |
| No system guidance for IFRS 16 data fields | P2 — RE Contract Manager | High | US-1.1, US-1.2 |
| No calculation explanation accessible for approval | P3 — Controller | High | US-2.4 |
| No audit trail for calculation methodology | P4 — Auditor | Critical | US-9.1 |
| Rework cost for every modification | P1 — Lease Accountant | High | US-4.1, US-4.2 |
| Close bottleneck: disclosure data aggregation | P3 — Controller | High | US-6.1, US-6.2 |

Each of these should be converted into a full evidence file with supporting detail when available.

---

## UAT Feedback Loop
After each UAT cycle, findings are stored here:
- Usability observations (user confusion, steps skipped, errors made).
- Missing functionality identified by users.
- Validation message quality feedback.
- Feature requests for future phases.

UAT findings that reveal requirements gaps must be escalated to the Orchestrator agent to trigger spec updates.

---

## Index of Current Sources

| File | Description | Persona | Date | Key Pain Points |
|------|-------------|---------|------|----------------|
| *(To be populated as evidence is collected)* | | | | |
