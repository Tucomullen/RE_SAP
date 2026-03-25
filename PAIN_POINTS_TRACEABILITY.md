# Pain Points Traceability Matrix — RE-SAP IFRS 16 Addon

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0 | 2026-03-24 | Remediation | Initial traceability matrix for 13 documented pain points |

---

## Purpose

This document is the single cross-reference view linking each of the 13 documented operational
pain points (PP-A through PP-M) to their corresponding requirements, design patterns, tasks,
risks, and knowledge sources. It is the entry point for any team member who wants to understand
how a specific user problem is being addressed by the addon.

Every future spec iteration, UAT cycle, or design change must be checked against this matrix
to ensure pain point coverage is maintained.

---

## How to Read This Matrix

- **PP-ID:** Pain point identifier.
- **Persona:** Which user personas experience this pain point.
- **Epic/Story:** Requirements traceability — which Epic and user story address this.
- **Design:** Which design section or pattern implements the mitigation.
- **Tasks:** Which backlog tasks deliver the mitigation.
- **Risk:** Which risk register entries track the likelihood and impact.
- **Knowledge:** Where evidence is or should be stored.
- **ECC / S/4:** Whether the pain point exists in ECC only, both, or differently in S/4HANA PCE.

---

## Traceability Matrix

| PP-ID | Pain Point Summary | Persona | Epic/Story | Design Mitigation | Tasks | Risk | Knowledge | ECC/S/4 |
|-------|-------------------|---------|-----------|------------------|-------|------|-----------|---------|
| PP-A | Contract configuration errors (dates, currency, object type, periodicity) | P2, P1 | Epic 10 / US-10.1 | §11.1 Pre-Flight Validation | T1-21, T1-22 | R-13 | knowledge/user-feedback/ PP-A | Both |
| PP-B | Retroactive changes in closed periods create uninterpretable special postings | P1, P3 | Epic 10 / US-10.2 | §11.2 Special Posting Explanation | T1-27, T1-28 | R-14 | knowledge/user-feedback/ PP-B | Both |
| PP-C | Debt reclassification failures ZRE009 (period not posted, changes not valuated) | P1 | Epic 10 / US-10.3 | §11.1 Pre-Flight Validation | T1-25, T1-26 | R-15 | knowledge/user-feedback/ PP-C | ECC — ZRE009 is ECC-specific; S/4 equivalent TBC |
| PP-D | Contracts with postings cannot be deleted; rescinded contracts remain visible | P2, P3 | Epic 10 / US-10.4 | §11.3 Contract Lifecycle Status | T1-29 | R-20 (partial) | knowledge/user-feedback/ PP-D | Both |
| PP-E | Contract changes without valuation cause downstream silent failures | P1 | Epic 10 / US-10.5 | §11.1 Pre-Flight Validation | T1-23, T1-24 | R-16 | knowledge/user-feedback/ PP-E | Both |
| PP-F | Unexpected special P&L movements on rescission/retroactive changes | P1, P3, P4 | Epic 10 / US-10.2 | §11.2 Special Posting Explanation | T1-27, T1-28 | R-14 | knowledge/user-feedback/ PP-F | Both |
| PP-G | Amortization only visible by asset class, not by contract | P1, P3 | Epic 10 / US-10.6 | §11.4 Contract-Level Amortization | T1-30, T2-11 | R-20 | knowledge/user-feedback/ PP-G | Both |
| PP-H | Old contracts broken after upgrades (clearing vs. expense differences) | P1, P5 | Epic 10 / US-10.7 | §11.5 Upgrade Impact Detection | T2-12 | R-18 | knowledge/user-feedback/ PP-H | ECC — specific to ECC upgrade cycles |
| PP-I | Foreign currency contract complexity and unclear balance interpretation | P2, P3, P7 | Epic 10 / US-10.10 | §11.1 Validation, §11.6 Multilingual | T2-13 | R-21 | knowledge/user-feedback/ PP-I | Both |
| PP-J | Extension/rescission not executed in correct sequence causes monthly failures | P2, P1 | Epic 10 / US-10.8 | §11.3 Contract Lifecycle Status | T2-10 | R-15 (partial) | knowledge/user-feedback/ PP-J | Both |
| PP-K | Poland advance payment contracts need distinct rules and correct useful life | P7, P1 | Epic 10 / US-10.9 | Country-specific rule config | T2-14 | R-19 | knowledge/user-feedback/ PP-K | Both — country specific |
| PP-L | Date mismatches (start/end/condition dates) create duplicates or valuation errors | P2, P1 | Epic 10 / US-10.1 | §11.1 Pre-Flight Validation | T1-21, T1-22 | R-17 | knowledge/user-feedback/ PP-L | Both |
| PP-M | User manual is outdated, in English, does not reflect current configuration | All, esp. P7 | Epic 10 / US-10.9 | §11.6 Multilingual User Guidance | T2-15, ongoing | R-22 | knowledge/user-feedback/ PP-M | Both |

---

## Pain Points by Delivery Phase

### Phase 1 (MVP — must be delivered before go-live)

| PP-ID | Delivered By | User Story |
|-------|-------------|-----------|
| PP-A | T1-21, T1-22 | US-10.1 |
| PP-B | T1-27, T1-28 | US-10.2 |
| PP-C | T1-25, T1-26 | US-10.3 |
| PP-D | T1-29 | US-10.4 |
| PP-E | T1-23, T1-24 | US-10.5 |
| PP-F | T1-27, T1-28 | US-10.2 |
| PP-G (partial) | T1-30 (spec) | US-10.6 |
| PP-L | T1-21, T1-22 | US-10.1 |

### Phase 2 (full implementation and country-specific coverage)

| PP-ID | Delivered By | User Story |
|-------|-------------|-----------|
| PP-G (full) | T2-11 | US-10.6 |
| PP-H | T2-12 | US-10.7 |
| PP-I | T2-13 | US-10.10 |
| PP-J | T2-10 | US-10.8 |
| PP-K | T2-14 (scope TBC) | US-10.9 |
| PP-M | T2-15 | US-10.9 |

---

## Pain Points by Design Theme

### Explainability (users cannot interpret system output)
PP-B, PP-F, PP-I → Special Posting Explanation Pattern + multilingual balance display

### Pre-flight Validation (users discover errors too late)
PP-A, PP-C, PP-E, PP-L → Pre-Flight Validation Pattern

### Contract-Level Visibility (users cannot see per-contract detail)
PP-D, PP-G → Contract Lifecycle Status + Contract-Level Amortization

### Guided Process Enforcement (users perform steps out of sequence)
PP-C, PP-J → Pre-Flight Validation + Contract Lifecycle Status Pattern

### Data Quality and Upgrade Resilience
PP-H, PP-L → Upgrade Impact Detection + Date Consistency Validation

### Localization and Documentation
PP-K, PP-M → Country-specific rules + Multilingual User Guidance

---

## UX Simplification Principles Driven by Pain Points

The following UX principles in `.kiro/steering/sap-re-architecture.md` are directly motivated
by these pain points:

| UX Principle | Motivated By |
|-------------|-------------|
| Progressive disclosure — show only relevant fields per step | PP-A (configuration overwhelm) |
| Smart defaults — pre-populate from RE-FX data | PP-A, PP-L (reduce manual entry errors) |
| Validation with plain-language explanation | PP-A, PP-C, PP-E, PP-L |
| Decision wizards for complex judgments | PP-C, PP-J (sequence enforcement) |
| Calculation preview before posting | PP-B, PP-F (surprise posting prevention) |
| Status visibility per contract | PP-D, PP-J (operational clarity) |

---

## Items Requiring Human Confirmation (TBC)

| Item | Who Confirms | Blocks |
|------|-------------|--------|
| ZRE009 exact object name and trigger mechanism | SAP RE Functional Consultant | T1-25, T1-26 |
| Poland advance payment contract scope in v1 | Project Governance Lead (OQ-08) | T2-14 |
| Exchange rate handling approach for FC contracts | IFRS 16 Accountant + FI Architect | T2-13 |
| Spanish language priority vs. other locales | Project Governance Lead | T2-15 |

---

## Maintenance Instructions

This matrix must be updated whenever:

1. A new pain point is documented in `knowledge/user-feedback/`.
2. A user story is added or modified in `requirements.md`.
3. A design section changes that affects a mitigation pattern.
4. A task is added, split, or re-sequenced in `tasks.md`.
5. A risk is added or updated in `risk-register.md`.

**Owner:** AI/Kiro Practitioner + Project Governance Lead
**Review cadence:** At every phase gate and after each UAT cycle.
