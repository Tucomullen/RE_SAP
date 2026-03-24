# Master Functional Design — IFRS 16 Z Addon for SAP RE/RE-FX

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial functional design baseline |

---
Traceability:
- Spec: specs/000-master-ifrs16-addon/requirements.md
- Decision: docs/governance/decision-log.md
- Last updated: 2026-03-24
- Updated by: Bootstrap Agent
---

## 1. Introduction and Scope

### 1.1 Purpose
This document defines the functional design of the RE-SAP IFRS 16 Z addon — an extension to SAP ECC RE/RE-FX that automates the IFRS 16 lessee accounting lifecycle. It is the authoritative reference for business analysts, SAP consultants, and auditors who need to understand what the system does.

### 1.2 Scope
This document covers lessee IFRS 16 accounting within SAP RE/RE-FX:
- Lease identification and exemption management
- IFRS 16 data capture and governance
- Calculation and schedule generation
- Modification and remeasurement processing
- FI posting (with human approval gate)
- Disclosure data aggregation
- Audit trail and evidence management

**Out of scope:** Lessor accounting, sublease accounting, sale-and-leaseback, S/4HANA migration execution.

---

## 2. Business Context and User Roles

### 2.1 Business Problem
See `.kiro/steering/product.md` — Business Problem section. The key gap is the absence of a native IFRS 16 automation capability in SAP RE/RE-FX, forcing manual spreadsheet-based processes with inherent traceability and accuracy risks.

### 2.2 User Roles and Responsibilities

| Role | Responsibilities in the Addon |
|------|------------------------------|
| RE Contract Manager (P2) | Initiates IFRS 16 data capture when creating/amending RE contracts. Completes the guided intake wizard. |
| Lease Accountant (P1) | Reviews and approves captured data. Makes IFRS 16 accounting judgments (scope, term, exemption). Approves calculations. Processes modifications and remeasurements. |
| Finance Controller (P3) | Reviews calculation results and disclosure output before period-end approval. Approves FI posting runs. Signs off disclosure packs. |
| Internal/External Auditor (P4) | Read-only access to all IFRS 16 evidence: inputs, calculations, approvals, postings. |
| IT/ABAP Support (P5) | Administers Z transactions, monitors batch jobs, manages transport and error resolution. |

---

## 3. Functional Processes

### 3.1 Contract Intake and IFRS 16 Data Capture

**Trigger:** A new RE-FX contract is created or an existing contract is amended.

**Process Flow:**
```
1. RE Contract Manager creates/amends contract in RE-FX.
2. System detects contract as potentially IFRS 16-relevant (based on asset class and contract type — rules TBC with RE Consultant).
3. IFRS 16 Intake Wizard is triggered (automatically or via manual initiation — approach TBC).
4. Wizard pre-populates all derivable fields from the RE-FX contract:
   - Commencement date
   - Non-cancellable period
   - Payment amounts and frequencies
   - Option dates
5. RE Contract Manager completes remaining fields (fields not available in RE-FX standard).
6. System validates all entries with plain-language messages.
7. Completed intake record is submitted to Lease Accountant for review.
```

**Key Data Fields Captured:**

| Field | Source | IFRS 16 Relevance |
|-------|--------|------------------|
| Commencement date | RE-FX or manual | Start of lease term and initial measurement |
| Non-cancellable period | RE-FX (derived) | Base for lease term |
| Extension options (date + term) | RE-FX option fields | Lease term determination |
| Termination options (date + penalty) | RE-FX option fields | Lease term determination |
| Payment schedule | RE-FX conditions | Lease liability measurement |
| Variable payment components | Manual (not in RE-FX standard) | Exclusion from liability if not index-based |
| Underlying asset type | RE-FX asset class | Exemption eligibility |
| Asset value when new | Manual | Low-value exemption check |
| Discount rate (IBR) | Manual — Accountant input | Initial measurement |
| Purchase option | Contract document | Lease term assessment |

**Human Validation Required:** Lease Accountant must review and approve before calculation proceeds.

---

### 3.2 IFRS 16 Scope and Exemption Determination

**Trigger:** Data capture is approved. Lease Accountant opens the scoping workflow.

**Process Flow:**
```
1. Lease Identification Checklist:
   a. Identified asset? (Yes/No/Uncertain)
   b. Right to substantially all economic benefits? (Yes/No/Uncertain)
   c. Right to direct use? (Yes/No/Uncertain)
   → If all Yes: IN SCOPE
   → If any Uncertain: ESCALATE to IFRS 16 specialist
   → If any No: OUT OF SCOPE

2. If IN SCOPE: Exemption check
   a. Short-term check: Is lease term ≤ 12 months? (apply asset class policy)
   b. Low-value check: Is asset value when new below policy threshold?

3. Results stored with accountant name, timestamp, and rationale.
4. Scoping memo generated as audit evidence.
```

**IFRS 16 Rules Applied:**
- Identification: IFRS 16 ¶9–11 (source: knowledge/official-ifrs/ [to be populated])
- Short-term: IFRS 16 ¶5(a), ¶B34
- Low-value: IFRS 16 ¶5(b), ¶B3–B8

**Mandatory Human Validation:** Scope conclusion and exemption determination require Lease Accountant sign-off. System proposes; accountant decides.

---

### 3.3 Lease Term and Discount Rate Assessment

**Trigger:** Contract confirmed as IFRS 16 in-scope (not exempt).

**Lease Term Wizard:**
```
1. System presents: non-cancellable period + all options with dates.
2. For each option, accountant records: Reasonably certain (Yes/No) + rationale.
3. System calculates proposed lease term from accountant's assessments.
4. Accountant reviews and confirms lease term.
5. Approved lease term stored with evidence.
```

**Discount Rate:**
```
1. System checks if rate implicit in lease is available (input field).
2. If not available: prompts for IBR from Treasury/Accountant.
3. IBR is entered with: rate value, effective date, supporting reference.
4. Rate stored — immutable after calculation approval.
```

**ALWAYS: Both lease term and discount rate require IFRS 16 Accountant sign-off. System cannot proceed without approved values.**

---

### 3.4 IFRS 16 Calculation Engine

**Trigger:** Approved inputs (term, rate, payment schedule, commencement date).

**Calculation Process:**
```
1. Initial measurement:
   - Lease liability = Present value of future payments at discount rate
   - ROU asset = Lease liability + initial direct costs - incentives received

2. Amortization schedule generation:
   - Period-by-period table: Date | Payment | Interest | Principal | Liability Balance
   - Depreciation schedule: Period | Depreciation | Accumulated Dep | ROU Net Book Value

3. Schedule stored in ZRIF16_SCHED.
4. Calculation run logged in ZRIF16_CALC / ZRIF16_CALCI.
5. Calculation result presented for Accountant review with calculation explainer.
```

**Calculation Explainer Output:**
- Lease term used: [N months] — approved by [name] on [date]
- Discount rate: [X%] — IBR entered by [name] on [date]
- Total liability at commencement: [amount]
- Total payments over lease term: [amount]
- Total interest over lease term: [amount]
- ROU asset at commencement: [amount]

**Human Approval Gate:** Calculation cannot be posted without Lease Accountant approval. Controller approval required for posting.

---

### 3.5 Period-End Calculation Batch

**Trigger:** Period-end batch job ZRIF16_PERIOD_END_CALC.

**Process:**
```
1. Selection: Company code, fiscal period, scope (all / selection).
2. System processes all active leases in parallel.
3. For each lease: generates period entry from pre-calculated schedule.
4. Period entries collected in a run result table.
5. Exception log for any lease that cannot be processed (with reason).
6. Summary report: contracts processed, entries generated, exceptions.
7. Run status: Pending approval.
```

**Controller Approval:**
- Controller reviews pre-posting summary (entries by account, contract, and amount).
- Approves the run → status changes to "Ready for Posting."
- Rejects (with reason) → status returns to "Pending Review."

**FI Posting:**
- Executed separately after Controller approval.
- Each FI document carries the run ID as reference.
- Posting log links FI document numbers back to the calculation run.

---

### 3.6 Contract Modification and Remeasurement

**Trigger Detection:**
- RE-FX contract amendment saves → system detects potential IFRS 16-relevant change.
- Option date reached → system creates reassessment alert.
- Index/rate change entered by accountant.

**Classification Wizard:**
- Accountant works through classification criteria per IFRS 16 ¶44–46.
- System proposes treatment based on accountant inputs; accountant confirms.
- Modification memo generated with pre-modification snapshot.

**Remeasurement Calculation:**
- Revised inputs applied to calculation engine.
- Delta display: before/after balances with difference analysis.
- If gain/loss: proposed P&L entry shown before approval.

**Required Evidence:**
- Event description and trigger date.
- Pre-modification snapshot (stored in ZRIF16_MODF).
- Accountant's classification decision with rationale.
- Revised calculation inputs and output.
- Approval record.

---

### 3.7 Disclosure Data Aggregation

**Trigger:** Finance Controller initiates disclosure pack for a reporting period.

**Outputs:**
1. **Maturity analysis:** Undiscounted future lease payments by maturity band (within 1 year / 1-5 years / over 5 years) per IFRS 16 ¶58(b).
2. **Lease liability rollforward:** Opening balance / additions / modifications / payments / interest accrual / closing balance.
3. **ROU asset rollforward:** Opening balance / additions / depreciation / modifications / impairment / closing balance.
4. **Weighted average discount rate:** By asset class.
5. **Short-term and low-value expense:** Total period expense for exempt leases.

**Process:**
- All data sourced from Z calculation tables (not from FI GL directly).
- Reconciliation to GL performed separately.
- Controller reviews and signs off disclosure pack.
- Sign-off recorded with timestamp and user ID.

---

### 3.8 Audit Trail and Evidence

**For every IFRS 16 process action, the system must store:**

| Event | Evidence Stored | Location |
|-------|----------------|---------|
| Data capture | All field values with source flags | ZRIF16_CNTRT |
| Scope decision | Decision text, accountant, timestamp, IFRS 16 criteria | ZRIF16_AUDIT |
| Lease term approval | Term, rationale, approver, timestamp | ZRIF16_AUDIT |
| Discount rate entry | Rate, source reference, approver, timestamp | ZRIF16_AUDIT |
| Calculation run | Inputs snapshot, output snapshot, run ID | ZRIF16_CALC |
| Posting approval | Approver name, timestamp, run ID | ZRIF16_CALC |
| FI document creation | FI doc numbers, run ID reference | Link table |
| Modification event | Trigger, classification, snapshot, approver | ZRIF16_MODF |
| Disclosure sign-off | Period, approver, timestamp | ZRIF16_AUDIT |

---

## 4. Business Rules Summary

| Rule ID | Rule | Source | Validation |
|---------|------|--------|-----------|
| BR-01 | Lease identification requires all three criteria (identified asset, substantially all benefits, right to direct use) | IFRS 16 ¶9–11 | Human — IFRS 16 Accountant |
| BR-02 | Short-term exemption applies per asset class election for leases ≤ 12 months | IFRS 16 ¶5(a) | Human policy election |
| BR-03 | Low-value exemption applies per contract if underlying asset value when new is below threshold | IFRS 16 ¶5(b) | Human policy election |
| BR-04 | Lease term includes periods covered by options the lessee is reasonably certain to exercise | IFRS 16 ¶19 | Human — Lease Accountant |
| BR-05 | Discount rate: use rate implicit in lease if determinable; otherwise use IBR | IFRS 16 ¶26 | Human — Lease Accountant + Treasury |
| BR-06 | Variable payments not based on index or rate are excluded from the lease liability | IFRS 16 ¶38 | Human — Lease Accountant |
| BR-07 | Modification that adds right to use additional assets at standalone price = new separate lease | IFRS 16 ¶44 | Human — Lease Accountant |
| BR-08 | No posting without approval gate — applies to initial recognition, period entries, and modifications | Project policy | System enforced |

---

## 5. Open Questions and TBC Items

See `docs/governance/assumptions-register.md` for all items requiring human confirmation.

Key open items in this functional design:
- OQ-01: RE-FX field mapping for payment schedule and option dates [TO BE CONFIRMED — SAP RE Functional Consultant]
- OQ-02: Automatic vs. manual trigger for IFRS 16 intake wizard
- OQ-04: Approval workflow technology (SAP WS vs. Z approval table)
- OQ-07: Multi-currency lease handling scope

---

*This document will be updated as Phase 0 items are resolved and feature specifications are approved. All updates must comply with the documentation policy in `.kiro/steering/documentation-policy.md`.*
