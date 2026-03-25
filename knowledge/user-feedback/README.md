# Knowledge Base: User Feedback and Evidence

**Priority Level:** 8 (evidence for requirements and usability — not authoritative for accounting)
**Location:** `knowledge/user-feedback/`
**Managed by:** Project Governance Lead / QA Lead (content) + RAG Knowledge Curator Agent (maintenance)

---

## Purpose

This folder stores real evidence of user pain points, process frustrations, UAT observations,
support ticket patterns, and workshop findings. This evidence grounds the product requirements in
real user experience and prevents over-engineering solutions to hypothetical problems.

Evidence in this folder is not authoritative for accounting rules or SAP technical behavior.
It is authoritative for understanding what users actually need and where the system fails them.

---

## Documented Pain Points — Baseline (13 Priority Items)

The following 13 pain points were documented from real SAP RE/IFRS 16 operational experience.
They are first-class product drivers. Every one has been traced to requirements, design, risks,
and tasks. See `PAIN_POINTS_TRACEABILITY.md` in the repository root for the full matrix.

### PP-A: Contract Configuration Errors

**Description:** Users struggle to correctly configure key contract fields — start date, end date,
description, currency, object type, and periodicity. Incorrect values cause silent errors in
downstream valuation and FI posting runs.

**Persona:** P2 — RE Contract Manager, P1 — Lease Accountant
**Severity:** High
**Linked requirements:** US-10.1, Epic 10
**Linked risks:** R-13
**Linked tasks:** T1-21, T1-22
**Design pattern:** Pre-Flight Validation Pattern (design.md §11.1)
**Status:** Documented — evidence file to be created from workshop data
**ECC vs S/4:** Affects both; validation approach is ECC-compatible and S/4-neutral

---

### PP-B: Retroactive Change Problems

**Description:** Modifying installments or business partners in already-closed fiscal periods
generates special postings that are difficult to interpret and reconcile. Users are surprised
and cannot explain these entries to controllers or auditors.

**Persona:** P1 — Lease Accountant, P3 — Finance Controller
**Severity:** High
**Linked requirements:** US-10.2, Epic 10
**Linked risks:** R-14
**Linked tasks:** T1-27, T1-28
**Design pattern:** Special Posting Explanation Pattern (design.md §11.2)
**Status:** Documented — evidence file to be created

---

### PP-C: Debt Reclassification Failures (ZRE009)

**Description:** Reclassification process ZRE009 fails when: the current period was not posted;
contract changes were not valuated; or asset movements are pending. Error messages are technical
and do not guide users toward resolution.

**Persona:** P1 — Lease Accountant
**Severity:** High — period-end blocking
**Linked requirements:** US-10.3, Epic 10
**Linked risks:** R-15
**Linked tasks:** T1-25, T1-26
**Design pattern:** Pre-Flight Validation Pattern (design.md §11.1)
**Note:** ZRE009 is a specific SAP RE/IFRS 16 reclassification transaction. Exact object
name to be confirmed with SAP RE Functional Consultant.
**Status:** Documented — evidence file to be created

---

### PP-D: Difficulty Deleting or Blocking Contracts

**Description:** Contracts with existing postings cannot be deleted. Rescinded contracts remain
visible in active contract lists, making operational filtering and control difficult.

**Persona:** P2 — RE Contract Manager, P3 — Finance Controller
**Severity:** Medium — operational clutter, control risk
**Linked requirements:** US-10.4, Epic 10
**Linked risks:** R-20 (partial)
**Linked tasks:** T1-29
**Design pattern:** Contract Lifecycle Status Pattern (design.md §11.3)
**Status:** Documented — evidence file to be created

---

### PP-E: Missing Valuation Causing Silent Failures

**Description:** When users make contract changes but do not execute valuation before running
monthly processes, downstream runs produce incorrect results without warning. The error is
discovered only at reconciliation.

**Persona:** P1 — Lease Accountant
**Severity:** High — silent data quality failure
**Linked requirements:** US-10.5, Epic 10
**Linked risks:** R-16
**Linked tasks:** T1-23, T1-24
**Design pattern:** Pre-Flight Validation Pattern (design.md §11.1)
**Status:** Documented — evidence file to be created

---

### PP-F: Unexpected Special Movements

**Description:** Upon contract rescission or retroactive changes, the system generates special
P&L account movements that users do not recognize or understand. This creates issues during
controller review and external audit.

**Persona:** P1 — Lease Accountant, P3 — Finance Controller, P4 — Auditor
**Severity:** High — audit finding risk
**Linked requirements:** US-10.2, Epic 10
**Linked risks:** R-14
**Linked tasks:** T1-27, T1-28
**Design pattern:** Special Posting Explanation Pattern (design.md §11.2)
**Status:** Documented — evidence file to be created

---

### PP-G: Amortization Visibility Problem

**Description:** Amortization can only be checked at asset class level, not by individual
contract. Finance teams cannot perform contract-level follow-up or produce contract-level
evidence for disclosure purposes.

**Persona:** P1 — Lease Accountant, P3 — Finance Controller
**Severity:** High — blocking for disclosure and audit follow-up
**Linked requirements:** US-10.6, Epic 10
**Linked risks:** R-20
**Linked tasks:** T1-30, T2-11
**Design pattern:** Contract-Level Amortization Reporting (design.md §11.4)
**Status:** Documented — evidence file to be created

---

### PP-H: Old Contracts Broken After Upgrades

**Description:** Contracts created before system upgrades show differences between clearing
amounts and expense amounts in the amortization schedule. These differences prevent valuation
and posting and require manual remediation.

**Persona:** P1 — Lease Accountant, P5 — IT/ABAP Support
**Severity:** Medium — requires manual fix before processing can resume
**Linked requirements:** US-10.7, Epic 10
**Linked risks:** R-18
**Linked tasks:** T2-12
**Design pattern:** Upgrade Impact Detection (design.md §11.5)
**Status:** Documented — evidence file to be created

---

### PP-I: Foreign Currency Contract Complexity

**Description:** Foreign currency lease contracts require specific posting parameter configuration
that is unclear to users. Users cannot interpret resulting balances or confirm which exchange rate
was applied.

**Persona:** P2 — RE Contract Manager, P3 — Finance Controller, P7 — Local Finance User
**Severity:** Medium — balance interpretation uncertainty
**Linked requirements:** US-10.10, Epic 10
**Linked risks:** R-21
**Linked tasks:** T2-13
**Design pattern:** Multilingual User Guidance (design.md §11.6), Pre-Flight Validation
**Status:** Documented — evidence file to be created

---

### PP-J: Extension and Rescission Problems

**Description:** If a contract extension or rescission is not executed and valuated in the
correct sequence, the contract does not reflect the changes and monthly processes produce
inconsistent results.

**Persona:** P2 — RE Contract Manager, P1 — Lease Accountant
**Severity:** High — monthly process inconsistency
**Linked requirements:** US-10.8, Epic 10
**Linked risks:** R-15 (partial)
**Linked tasks:** T2-10
**Design pattern:** Contract Lifecycle Status Pattern (design.md §11.3)
**Status:** Documented — evidence file to be created

---

### PP-K: Poland Advance Payment Case

**Description:** Advance-payment lease contracts in Poland require distinct rules: they must be
assigned separate Z assets and may fail if the useful life is not maintained correctly in all
asset areas. The generic process does not accommodate this.

**Persona:** P7 — Local Finance User (Poland), P1 — Lease Accountant
**Severity:** Medium — country-specific compliance risk
**Linked requirements:** US-10.9, Epic 10
**Linked risks:** R-19
**Linked tasks:** T2-14
**Note:** Poland scope must be formally confirmed in scope by Project Governance Lead (OQ-08).
**Status:** Documented — scope confirmation required before implementation

---

### PP-L: Date Mismatch Incidents

**Description:** Small date differences in start dates, end dates, or condition dates — from data
entry errors or system migration — create duplicate calculation entries or valuation differences
that cascade through the period-end process.

**Persona:** P2 — RE Contract Manager, P1 — Lease Accountant
**Severity:** High — cascading period-end errors
**Linked requirements:** US-10.1, Epic 10
**Linked risks:** R-17
**Linked tasks:** T1-21, T1-22
**Design pattern:** Pre-Flight Validation Pattern (design.md §11.1)
**Status:** Documented — evidence file to be created

---

### PP-M: Outdated or Unclear User Manual

**Description:** The general user manual is outdated, written in English, and does not reflect
the current system configuration. Users cannot resolve common operational questions without
escalating to specialists, which increases error rate and support burden.

**Persona:** All personas, especially P7 — Local Finance User
**Severity:** Medium — increases all other pain points' frequency
**Linked requirements:** US-10.9, Epic 10
**Linked risks:** R-22
**Linked tasks:** T2-15 (Spanish baseline), ongoing via user-manual-updater skill
**Design pattern:** Multilingual User Guidance (design.md §11.6)
**Status:** Documented — work begins in Phase 2

---

## What to Store Here

| Artifact Type | Description | When to Add |
|---------------|-------------|------------|
| Pain point summaries | Structured descriptions of documented user frustrations | During discovery workshops, interviews |
| UAT observation notes | Specific observations from UAT sessions (anonymized) | After each UAT cycle |
| Support ticket patterns | Aggregated patterns from helpdesk/support tickets | Periodically |
| Workshop output summaries | Key findings from requirements or design workshops | After workshops |
| Survey results | User satisfaction scores and open-ended feedback | After surveys |
| Escalation patterns | Recurring issues escalated to the accounting team | Periodically |

**Important:** Never store personally identifiable information (PII) or attributable individual
feedback without consent. Always anonymize or aggregate.

---

## Required Frontmatter for Evidence Files

```yaml
---
source-type: user-feedback
source-name: "[Descriptive title, e.g., RE Contract Manager — Period-End Pain Points Workshop 2026-03]"
source-date: YYYY-MM-DD
source-version: v1.0
priority: 8
confidence: [high | medium | low]
status: [current | superseded]
tags: [intake, close-process, modification, auditability, etc.]
persona-ref: [P1 | P2 | P3 | P4 | P5 | P6 | P7]
linked-requirement: [US-X.X or Epic reference]
pain-point-ref: [PP-A | PP-B | ... | PP-M]
contains-pii: false
added-by: [name]
added-date: YYYY-MM-DD
validated-by: [Project Governance Lead name]
validation-date: YYYY-MM-DD
---
```

---

## UAT Feedback Loop

After each UAT cycle, findings are stored here:
- Usability observations (user confusion, steps skipped, errors made).
- Missing functionality identified by users.
- Validation message quality feedback.
- Feature requests for future phases.

UAT findings that reveal requirements gaps must be escalated to the Orchestrator agent to
trigger spec updates. The user-manual-updater skill is triggered for any finding that reveals
a documentation gap.

---

## Index of Current Sources

| File | Description | Persona | Date | Pain Points |
|------|-------------|---------|------|------------|
| *(PP-A through PP-M above are baseline documented pain points — evidence files to be created from workshop data collected during Phase 0)* | | | | |
