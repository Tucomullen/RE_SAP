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

## User Pain Points in RE/IFRS16

- **Data capture friction:** Lease-relevant data (commencement date, term, options, rates) is not systematically captured in RE contracts — users must hunt across documents.
- **No decision guidance:** Users do not know when IFRS 16 applies, when exemptions apply, or how to classify a modification.
- **Calculation opacity:** No system-generated schedule — users build Excel models independently.
- **Remeasurement complexity:** Every option exercise, rate change, or modification requires a full recalculation with new discount rates — currently manual.
- **Posting disconnection:** Calculated values are manually keyed into SAP FI — reconciliation errors are common.
- **Disclosure pain:** Aggregating maturity analysis, weighted average discount rates, and lease liability movements requires cross-system data collection.
- **No audit trail:** There is no system record of why a calculation was made a certain way, by whom, and when.

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
