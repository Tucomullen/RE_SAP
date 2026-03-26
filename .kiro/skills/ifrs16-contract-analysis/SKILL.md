---
name: ifrs16-contract-analysis
description: >-
  Analyze a lease contract for IFRS 16 scope, extract required data, identify missing fields, and produce a structured scoping memo with human validation requests.
---

# Skill: IFRS 16 Contract Analysis

## Title
IFRS 16 Contract Analysis — Lease Identification, Data Extraction, and Risk Assessment

## Description
This skill analyzes a real estate lease contract (or a structured summary of one) to extract all IFRS 16-relevant elements, identify missing data, flag compliance risks, and produce a structured output ready for input to the IFRS 16 calculation engine. It is grounded exclusively in the IFRS 16 standard and approved project accounting decisions.

## When to Use
- When a new RE contract is entered in SAP and must be assessed for IFRS 16 scope.
- When a contract amendment arrives and the IFRS 16 impact must be assessed before processing.
- When an existing lease is reviewed for period-end reassessment.
- When the project team needs to validate that the Z data model captures all required IFRS 16 fields for a specific contract type.

**Do not use this skill to produce final accounting conclusions.** Outputs are always subject to IFRS 16 Accountant validation.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| Contract document or structured summary | Original lease or RE-FX contract data extract | RE-FX system or contract file |
| Asset description | Type and nature of the underlying asset (property, equipment, land) | Contract |
| Payment schedule | All payment amounts, frequencies, and types | Contract |
| Option terms | Extension options, termination options, purchase options with dates | Contract |
| Applicable accounting policy | Client's elected thresholds (low-value amount, short-term policy by asset class) | docs/governance/decision-log.md or IFRS 16 Accountant |
| Commencement date | Actual lease commencement date | Contract |

---

## Steps

### Step 1: Lease Identification Test
Apply the three-criteria test per IFRS 16 paragraphs 9–11:
1. **Identified asset:** Is there an explicitly or implicitly identified asset? Can the supplier substitute the asset? Document findings.
2. **Substantially all economic benefits:** Does the customer control substantially all economic benefits from use throughout the period?
3. **Right to direct use:** Who determines how and for what purpose the asset is used? Document findings.

Output: Scoping conclusion proposal — **IN SCOPE / OUT OF SCOPE / UNCERTAIN** (uncertain always escalates to human).

### Step 2: Exemption Check
2a. **Short-term exemption:** Determine if lease term (including reasonably certain extensions) is ≤ 12 months. Check client policy for asset class election.
2b. **Low-value exemption:** Identify underlying asset value when new. Compare to client's elected threshold. Document source of asset value estimate.

Output: Exemption applicability proposal — **APPLICABLE / NOT APPLICABLE / UNCERTAIN**.

### Step 3: Lease Term Assessment
3a. Extract the non-cancellable period from contract data.
3b. Identify all extension and termination options with dates.
3c. Document the facts and circumstances relevant to "reasonably certain" assessment for each option.
3d. Propose a lease term (years/months from commencement) with supporting rationale.
3e. Identify trigger events that would require reassessment (significant modifications, business strategy changes).

**Note:** Final lease term determination ALWAYS requires IFRS 16 Accountant sign-off. The output here is a structured proposal only.

### Step 4: Payment Classification
For each payment type in the contract, classify as:
- Fixed lease payment (included in liability)
- In-substance fixed (included)
- Variable by index/rate (included at initial rate; flag for remeasurement)
- Variable not based on index/rate (excluded; expensed as incurred)
- Residual value guarantee (lessee's expected amount — included)
- Purchase option reasonably certain (included) / not certain (excluded)
- Termination penalty (included if in lease term)
- Non-lease components (excluded unless policy election to not separate)

Document each classification and note any ambiguity.

### Step 5: Discount Rate
5a. Determine if rate implicit in lease is readily determinable (IFRS 16 ¶26).
5b. If not, identify as requiring IBR — flag for Treasury/Accounting team.
5c. Document any relevant characteristics that affect IBR estimation (credit profile, currency, collateral, term).

**ALWAYS FLAG: Discount rate selection requires IFRS 16 Accountant + Treasury sign-off.**

### Step 6: Data Gap Identification
Identify all IFRS 16-required data items that are missing from the contract or RE-FX record:
- Missing commencement date
- Incomplete payment schedule
- Undocumented option terms
- No asset value for low-value assessment
- Missing counterparty/lessor data

For each gap: state what is missing, why it is needed, and who is responsible for providing it.

### Step 7: Modification Risk Flag
Review the contract for indicators of an existing modification that may not yet have been processed:
- Payment amount changes effective on a specific date.
- Scope changes (area, assets added/removed).
- Term changes.
- Option exercise notifications.

Flag any such indicators for immediate escalation.

---

## Expected Outputs

1. **IFRS 16 Scoping Memo** — Structured document with findings from each step above.
2. **Data Capture Checklist** — List of all required Z-table fields with current data status (present / missing / uncertain).
3. **Risk Summary** — Compliance risks identified, with severity and recommended action.
4. **Human Validation Requests** — Itemized list of decisions requiring IFRS 16 Accountant sign-off.
5. **Proposed Calculation Inputs** — Draft inputs for the calculation engine (subject to accountant validation).

---

## Quality Checks

- [ ] All three lease identification criteria explicitly addressed.
- [ ] Both exemptions assessed with client policy reference.
- [ ] Every payment type classified with explanation.
- [ ] Discount rate flagged for human sign-off (not assumed).
- [ ] All data gaps documented with owner assignment.
- [ ] All accounting assertions cite IFRS 16 paragraph numbers.
- [ ] No final conclusions stated — all proposals labeled as "subject to IFRS 16 Accountant validation."

---

## Handoff to Next Role/Agent

- **IFRS 16 Accountant (Human):** Review and validate the scoping memo, lease term proposal, and payment classifications. Provide discount rate. Sign off on the data capture checklist.
- **SAP ECC Coverage Analyst Agent (ecc-coverage-analyst):** Use the data capture checklist to verify which capabilities exist in the current ECC solution and which require new Z design. Confirm Option B coverage for the contract type being analyzed.
- **RAG Knowledge Curator (rag-knowledge):** If new IFRS 16 interpretation insights emerge, propose them for addition to knowledge/official-ifrs/.
- **Functional Spec Writer (functional-spec-writer):** Use the validated output to update or create the contract intake functional spec.
