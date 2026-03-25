---
inclusion: always
---

# Product Steering — RE-SAP IFRS 16 Addon

## Product Vision
Deliver a fully integrated, audit-ready SAP addon that transforms the IFRS 16 lease accounting process from a manual, error-prone, spreadsheet-dependent operation into a governed, automated, AI-assisted workflow embedded in SAP RE/RE-FX — enabling finance teams to meet compliance obligations with confidence, speed, and full auditability.

---

## Business Problem
Organizations using SAP RE/RE-FX for real estate management face a structural gap: SAP ECC does not natively automate the full IFRS 16 lifecycle (lease identification, ROU asset/liability calculation, modification handling, remeasurement, disclosure). The result is:

1. **Manual spreadsheets** maintained outside SAP — creating reconciliation burden, version control risk, and audit exposure.
2. **Inconsistent accounting judgments** across leases and periods — especially for lease term decisions, discount rates, and modification classification.
3. **No explainability** — auditors cannot trace how a calculation was derived from the contract data.
4. **High rework cost** — every contract modification or remeasurement requires manual rework of all affected schedules.
5. **Disclosure bottleneck** — aggregating IFRS 16 disclosure data from scattered sources takes days before close.
6. **User expertise dependency** — only specialist users understand the current process; no guided workflow for standard RE users.

---

## Target Users

| Persona | Role | Primary Pain |
|---------|------|-------------|
| **Lease Accountant** | Performs IFRS 16 calculations, handles modifications, prepares disclosures | Manual calculation burden, traceability gaps, late close |
| **RE Contract Manager** | Manages RE contracts in SAP, captures lease data | Does not know which data is required for IFRS 16 |
| **Finance Controller** | Approves postings, oversees compliance | Lack of visibility, cannot confirm accuracy without deep review |
| **Internal/External Auditor** | Reviews IFRS 16 compliance evidence | Cannot trace calculation to source data; no audit trail |
| **IT/ABAP Support** | Maintains the addon | Needs clean architecture, transports, and documentation |
| **Project Governance Lead** | Owns project delivery and risk | Needs governance artifacts, decision traceability, risk visibility |

---

## Documented Operational Pain Points

The following pain points have been observed and documented by users operating SAP RE/IFRS 16
processes. They are first-class product requirements — every epic and design decision must
address at least one of them. See `PAIN_POINTS_TRACEABILITY.md` for the full traceability matrix.

### PP-A: Contract Configuration Errors

Users struggle to correctly configure key contract fields: start date, end date, description,
currency, object type, and periodicity. Incorrect values cause silent errors in downstream
valuation and FI posting runs. Users often do not discover the error until the process fails.

Design response: Guided intake wizard with field-level validation in plain language, smart defaults
from RE-FX contract data, and pre-flight validation before calculation is triggered.

### PP-B: Retroactive Change Problems

When users modify installments or business partners in already-closed fiscal periods, the system
generates special postings that are difficult to interpret and reconcile. Users are surprised by
these entries and cannot explain them.

Design response: Change impact preview before saving, plain-language explanation of special posting
type, and guided reconciliation report for period-end exceptions.

### PP-C: Debt Reclassification Failures (ZRE009)

Reclassification process ZRE009 fails when: the current period was not posted; contract changes
were not valuated; or asset movements are pending. Error messages are technical and do not guide
users toward resolution.

Design response: Pre-reclassification checklist validating all prerequisites are met, with
plain-language remediation instructions for each unmet condition.

### PP-D: Difficulty Deleting or Blocking Contracts

Contracts with existing postings cannot be deleted. Rescinded contracts remain visible in active
contract lists, making operational filtering difficult.

Design response: Clear contract lifecycle status in all views (Active / Rescinded / Exempt /
Blocked). Filter and sort by lifecycle status as a standard feature.

### PP-E: Missing Valuation Causing Silent Failures

When users make contract changes but do not execute valuation before monthly processes, downstream
runs produce incorrect results without warning.

Design response: Mandatory valuation check before any batch calculation. System blocks period-end
processing if unvaluated changes exist and displays a clear list of affected contracts.

### PP-F: Unexpected Special Movements

Upon contract rescission or retroactive changes, the system generates special P&L account movements
that users cannot identify or explain to controllers or auditors.

Design response: Every special system movement must carry a machine-generated plain-language
explanation: what it is, why it was generated, which contract event triggered it, and the
accounting standard basis (IFRS 16 paragraph reference).

### PP-G: Amortization Visibility Problem

Amortization amounts are only visible at asset class level, not at individual contract level.
Finance staff cannot perform contract-level follow-up.

Design response: Contract-level amortization report as a standard feature. Every amortization
schedule stored and queryable by contract. Disclosure engine aggregates from contract-level data.

### PP-H: Old Contracts Broken After Upgrades

Contracts created before system upgrades may show differences between clearing amounts and expense
amounts. These differences prevent valuation and posting and require manual fixes.

Design response: Upgrade impact detection report identifying affected contracts. Guided remediation
workflow with step-by-step instructions for each contract with clearing/expense differences.

### PP-I: Foreign Currency Contract Complexity

Foreign currency lease contracts require specific posting parameter configuration. Users do not
know what configuration is needed or how to interpret the resulting balances.

Design response: Currency-specific configuration guide and validation at contract intake.
Multi-currency calculation support with explicit exchange rate handling and plain-language
balance explanation.

### PP-J: Extension and Rescission Problems

If a contract extension or rescission is not executed and valuated in the correct sequence,
monthly processes become inconsistent.

Design response: Guided extension/rescission workflow enforcing the correct execution and valuation
sequence. Status checks prevent out-of-sequence steps. Pending extension/rescission shown per contract.

### PP-K: Poland Advance Payment Case

Advance-payment lease contracts in Poland require distinct rules: separate Z assets and correct
useful life in all asset areas. Generic process does not handle this.

Design response: Country-specific rule configuration for advance-payment contracts. Pre-flight
check validating useful life consistency across asset areas. Poland-specific documentation in the
user manual.

### PP-L: Date Mismatch Incidents

Small date differences in start dates, end dates, or condition dates cause duplicate calculation
entries or valuation differences that cascade through period-end processing.

Design response: Date consistency validation at intake and before every calculation run. Detection
of date anomalies with blocking alerts and guided correction.

### PP-M: Outdated or Unclear User Manual

The user manual is outdated, in English, and does not reflect the current configuration.
Users cannot resolve common operational questions without specialist support.

Design response: Multilingual user manual (Spanish-language version as baseline). Manual is a
living document — every process change triggers a manual update. Role-based quick reference guides
embedded in each Z transaction.

---

## General Pain Point Design Themes

Across all 13 documented pain points, six design themes emerge that must be embedded in every
feature:

1. **Explainability:** Every system action explained in plain language (PP-B, PP-F, PP-I).
2. **Guided workflows:** Multi-step processes use step-by-step wizards (PP-A, PP-C, PP-J, PP-K).
3. **Pre-flight validation:** Prerequisites checked before processes run, not after failure (PP-C, PP-E, PP-L).
4. **Contract-level visibility:** All reporting available at individual contract level (PP-G, PP-D).
5. **Living documentation:** User guidance current, role-based, in the user's language (PP-M).
6. **Upgrade resilience:** Design detects and remediates data quality issues from upgrades (PP-H).

---

## Product Goals

1. **Automate the IFRS 16 calculation engine** inside SAP — amortization schedules, ROU/liability opening entries, remeasurement, and period-end entries — with full traceability to contract data.
2. **Provide guided data capture** — a workflow that prompts RE Contract Managers to enter IFRS 16-relevant fields when creating or modifying a contract.
3. **Enforce accounting rules with explainability** — every decision rule (exemption check, modification type, discount rate logic) must be documented and auditable.
4. **Support modifications and remeasurement** — detect triggering events, present remeasurement options to the accountant, calculate with delta visualization.
5. **Produce disclosure-ready output** — aggregated IFRS 16 disclosure packs aligned with IAS 1 and IFRS 16 paragraph 52–60 requirements.
6. **Embed an AI assistant layer** — guide users through the process, flag anomalies, explain outputs in plain language.
7. **Maintain a living knowledge base** — RAG-enabled, always current, governing both AI agents and human practitioners.

---

## Non-Goals (Version 1)

- Lessor accounting under IFRS 16 (finance and operating lease — lessor side).
- SAP S/4HANA migration execution (design must be S/4-compatible, but migration is out of scope for v1).
- Real-time integration with external contract management systems (future phase).
- Automated FI posting without human approval gate (approval gate is mandatory in v1).
- Direct integration with ERP disclosure output formats for specific local GAAP jurisdictions beyond IFRS.

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Reduction in manual spreadsheet usage for IFRS 16 | > 90% of contracts managed in system by end of Phase 2 |
| Time to complete period-end IFRS 16 run | Reduced by > 70% vs. current state |
| Audit finding rate related to IFRS 16 traceability | Zero findings attributable to calculation traceability gaps |
| User satisfaction (guided data capture flow) | > 80% positive rating in UAT |
| Disclosure pack generation time | < 1 business day after period-end run |
| Mean time to process a contract modification | Reduced by > 60% vs. current state |

---

## Competitive Advantage Hypothesis
Most IFRS 16 SAP solutions on the market are either standalone lease management tools (not embedded in RE/RE-FX) or generic FI extensions without RE process awareness. This addon's advantage is:

1. **Native RE/RE-FX integration** — data flows from RE contract objects without double-entry.
2. **AI-governed process** — not just calculation automation but decision support, explainability, and anomaly detection built in from day one.
3. **Living documentation architecture** — the addon is self-documenting; every decision, assumption, and change is traceable.
4. **S/4-compatible design** — built with migration awareness so the investment survives the ECC-to-S/4 transition.
