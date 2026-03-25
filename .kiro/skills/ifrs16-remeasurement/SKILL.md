---
name: ifrs16-remeasurement
description: >-
  Analyze a remeasurement trigger or contract modification event, classify the IFRS 16 treatment, compute before/after impact, and produce workflow design and audit evidence requirements.
---

# Skill: IFRS 16 Remeasurement and Contract Modification Analysis

## Title
IFRS 16 Remeasurement and Contract Modification — Trigger Detection, Classification, and Scenario Design

## Description
This skill analyzes a remeasurement trigger event or contract modification and produces a structured assessment covering: trigger classification, IFRS 16 accounting treatment options, before/after balance impact, required calculation inputs, and audit evidence requirements. All outputs are proposals for IFRS 16 Accountant validation — no accounting conclusions are final until approved.

## When to Use
- When a contract modification is received (scope change, term change, payment change).
- When a lease option is exercised or not exercised (extension, termination, purchase).
- When an index or rate used to determine variable lease payments changes and a remeasurement date is reached.
- When a residual value guarantee amount changes.
- When the project team is designing the remeasurement workflow in the Z addon.
- When assessing the correct accounting treatment for an event already processed — for retrospective review.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| Current lease data snapshot | Existing lease term, payment schedule, discount rate, ROU balance, liability balance | Z calculation tables or current schedule |
| Trigger event description | What changed — scope, term, payments, option exercise, rate change | Contract amendment or RE-FX change notification |
| Event effective date | Date the change takes effect | Contract amendment |
| New payment terms | Updated payment amounts, new payment schedule if applicable | Contract amendment |
| New discount rate (if applicable) | IBR at remeasurement date or updated rate | Treasury/Accountant |
| Client accounting policy | Any policy elections relevant to the modification | docs/governance/decision-log.md |

---

## Steps

### Step 1: Trigger Classification
Classify the event as one of the following (IFRS 16 ¶ 44–50):

**Modifications (changes to scope or consideration):**
- A. **New separate lease:** Adds right to use additional assets AND consideration increases by standalone price amount → Treat as a new lease.
- B. **Not a separate lease — decrease in scope:** Removes part of the right → Adjust ROU and liability proportionately; recognize gain/loss.
- C. **Not a separate lease — all other:** Re-measure at new discount rate; adjust liability and ROU.

**Remeasurements (no modification — reassessment of judgments):**
- D. **Lease term change:** Option exercise/non-exercise or business circumstances change → Re-measure liability using revised term and revised discount rate.
- E. **Purchase option change:** Assessment of purchase option changes → Re-measure.
- F. **Variable payment by index/rate:** Index/rate changes and remeasurement date reached → Re-measure using updated rate.
- G. **Residual value guarantee change:** Expected amount changes → Re-measure.

Output: Event classification with supporting paragraph reference and rationale.

**CRITICAL:** Classification B, C, D, E are judgment-intensive — always require IFRS 16 Accountant validation.

### Step 2: Pre-Modification Snapshot
Record a complete snapshot of the current lease state before any change is applied:
- Lease term remaining
- Remaining payment schedule (payments × amounts × dates)
- Current discount rate
- ROU asset carrying amount
- Accumulated depreciation
- Lease liability balance
- Interest accrued
- Last posting date

This snapshot is mandatory for the audit trail — stored in ZRIF16_MODF or equivalent.

### Step 3: New Calculation Inputs
Based on the trigger classification, determine the required calculation inputs:
- For A (new lease): full new lease measurement from commencement.
- For B (decrease): proportionate reduction calculation; present value of decrease.
- For C (other modification): revised payment schedule, revised discount rate at modification date.
- For D–G (remeasurement): revised remaining payments, revised discount rate as applicable.

Identify any missing inputs and request them from the appropriate party.

### Step 4: Scenario Modeling (Design Mode)
When used for workflow design:
4a. Define the data entry screen the accountant sees when a trigger event is flagged.
4b. Define the calculation preview: delta table showing OLD vs. NEW balances.
4c. Define the approval workflow: who approves before the modification is posted.
4d. Define the posted entries: which FI documents are generated and with what reference.
4e. Define the audit evidence produced: snapshot before, approved inputs, calculation output, posted document numbers.

### Step 5: Gain/Loss Assessment
For Type B modifications:
- Calculate the proportionate reduction in ROU asset and liability.
- Calculate the gain or loss to be recognized in P&L.
- Identify the GL accounts to be used [TO BE CONFIRMED with IFRS 16 Accountant].

### Step 6: Disclosure Impact
Identify how this modification/remeasurement affects IFRS 16 disclosures:
- Does it change the total lease liability maturity analysis?
- Does it require disclosure as a significant modification?
- Does it change the weighted average discount rate?

---

## Expected Outputs

1. **Trigger Classification Memo** — Event type with IFRS 16 paragraph reference and rationale.
2. **Pre-Modification Snapshot** — Complete audit record of pre-change state.
3. **Revised Calculation Inputs** — Structured data ready for the calculation engine.
4. **Delta Impact Summary** — Before/after table for ROU asset, liability, P&L.
5. **Workflow Specification** (if in design mode) — Screens, approval flow, posted entries.
6. **Disclosure Impact Note** — Which IFRS 16 disclosures are affected and how.
7. **Validation Request List** — Items requiring IFRS 16 Accountant sign-off.

---

## Quality Checks

- [ ] Event classified with explicit IFRS 16 paragraph reference.
- [ ] Pre-modification snapshot complete.
- [ ] All inputs for revised calculation identified; missing inputs flagged.
- [ ] Gain/loss calculation included for Type B modifications.
- [ ] No final accounting treatment decided without accountant validation marker.
- [ ] Disclosure impact assessed.
- [ ] Audit evidence requirements documented.

---

## Handoff to Next Role/Agent

- **IFRS 16 Accountant (Human):** Validate trigger classification and approve calculation inputs. Confirm discount rate at remeasurement date. Sign off on P&L impact if applicable.
- **ABAP Architecture Specialist (abap-architecture):** Use the workflow specification to design the remeasurement Z transaction and data model changes.
- **QA/Audit Controls Agent (qa-audit-controls):** Use the scenario design to create UAT test cases for the modification workflow.
- **Docs Continuity Agent (docs-continuity):** Update docs/functional/master-functional-design.md with the modification/remeasurement workflow design.
