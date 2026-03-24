# Master User Manual — IFRS 16 Z Addon for SAP RE/RE-FX

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-24 | Bootstrap | Initial user manual baseline |

---
Traceability:
- Spec: specs/000-master-ifrs16-addon/requirements.md
- Last updated: 2026-03-24
- Updated by: Bootstrap Agent
---

## How to Use This Manual

This manual is organized by **user role**. Go to the section for your role to find step-by-step instructions for your tasks. If you perform multiple roles, read each relevant section.

| I am... | My section is... |
|---------|----------------|
| RE Contract Manager | Section 2 |
| Lease Accountant | Section 3 |
| Finance Controller | Section 4 |
| Auditor / Audit Reviewer | Section 5 |
| IT/ABAP Support | Section 6 |

If you have a question not answered here, see the FAQ (Section 7) or contact your Lease Accountant or IT Support team.

---

## Section 1: Overview — What This System Does

The IFRS 16 Z Addon in SAP helps your organization manage lease accounting under IFRS 16 without manual spreadsheets. Here is what the system does:

1. **Guides you** through capturing the right data when you create or amend a lease contract.
2. **Calculates** the right-of-use (ROU) asset, lease liability, amortization schedule, and period entries automatically.
3. **Enforces approval steps** so the right person reviews and approves before anything is posted to accounting.
4. **Stores complete evidence** so auditors can trace every number back to its source.
5. **Produces disclosure output** to support IFRS 16 notes in the financial statements.

**What the system does NOT do automatically (without your approval):**
- Post any journal entries to the general ledger.
- Make accounting judgments (like lease term or discount rate decisions).
- Override previous decisions without a new approval.

---

## Section 2: RE Contract Manager

### Your Role
You are responsible for creating and maintaining real estate contracts in SAP RE-FX. When you create a new contract or change an existing one, the system will ask you for information needed for IFRS 16 accounting.

You do not need to understand IFRS 16 accounting to do your part — the system guides you step by step. If you are unsure about a field, use the built-in help text or escalate to the Lease Accountant.

---

### 2.1 What Happens When You Create a New Contract

When you save a new RE contract that the system identifies as potentially relevant to IFRS 16:
1. The system displays a notification: "This contract may require IFRS 16 data. Please complete the IFRS 16 intake form."
2. You can complete the form immediately or return to it later via Transaction `ZRE_IFRS16_INTAKE`.

> **Note:** Until the IFRS 16 intake is complete and approved by the Lease Accountant, the contract will show status "Not Assessed" in the IFRS 16 status view.

---

### 2.2 Completing the IFRS 16 Intake Form (Transaction: ZRE_IFRS16_INTAKE)

**When to use:** When creating a new RE contract or when prompted after a contract amendment.

**What the system pre-populates for you:**
- Contract number and description
- Commencement date (from RE-FX)
- Non-cancellable period end date (from RE-FX)
- Payment amounts and frequencies (from RE-FX conditions)
- Option dates (extension, termination) from RE-FX

**What you need to complete:**
- Asset type description (what is being leased — office space, warehouse, etc.)
- Estimated value of the asset when new (for low-value exemption check)
- Any payment types that are NOT based on fixed amounts or an index (e.g., revenue-based payments) — describe them in the variable payments field
- Confirm whether a purchase option exists and its terms

**Step-by-step:**
1. Open transaction `ZRE_IFRS16_INTAKE` (or click the IFRS 16 intake link from the contract).
2. Select the contract number.
3. Review pre-populated fields — correct any that look wrong.
4. Complete the fields highlighted in orange (required fields not derivable from RE-FX).
5. Click "Validate" — the system checks your entries and shows any issues in plain language.
6. Fix any issues shown.
7. Click "Submit for Review" — the Lease Accountant is notified.

**Common validation messages and what to do:**

| Message | What it means | What to do |
|---------|--------------|-----------|
| "Commencement date is before today — please verify" | The date you entered is in the past | Confirm the date is correct; if yes, proceed |
| "No payment schedule found — please check conditions" | RE-FX conditions are empty or missing | Check the contract conditions in RE-FX; contact IT support if missing |
| "Asset value when new is required for exemption check" | You left the asset value field blank | Enter your best estimate; if unknown, enter 0 and add a note for the accountant |

---

### 2.3 Checking IFRS 16 Status of Your Contracts

**Transaction:** `ZRE_IFRS16_INTAKE` → Status Overview tab (or report `ZRIF16_STATUS_OVERVIEW` — to be confirmed)

Status meanings:

| Status | What it means | What to do |
|--------|--------------|-----------|
| Not Assessed | Intake not yet submitted | Complete the intake form |
| Pending Accountant Review | Intake submitted; awaiting Lease Accountant | No action needed — wait for notification |
| Exempt | Contract is exempt from IFRS 16 (short-term or low-value) | No further action |
| Active | Lease is in IFRS 16 scope and calculations are running | No action needed unless prompted |
| Pending Modification | A contract change may need IFRS 16 processing | Notify Lease Accountant |
| Remeasurement Required | A reassessment event has been flagged | Notify Lease Accountant |
| Error | A processing error occurred | Contact Lease Accountant or IT Support |

---

## Section 3: Lease Accountant

### Your Role
You are responsible for all IFRS 16 accounting decisions. The system supports you by presenting data, applying calculation rules, and enforcing governance — but every significant accounting judgment requires your approval.

---

### 3.1 Reviewing an IFRS 16 Intake (Transaction: ZRE_IFRS16_REVIEW)

**When to use:** When notified that a new contract intake is ready for your review.

1. Open `ZRE_IFRS16_REVIEW`.
2. Select the contract from the pending review list.
3. Review all captured data against the original contract document.
4. Check: Are all required fields complete? Does the payment schedule look correct?
5. If data is incomplete: click "Return for Correction" and enter specific instructions for the RE Contract Manager.
6. If data is correct: proceed to the Scope Assessment.

---

### 3.2 IFRS 16 Scope Assessment

After confirming data is complete:

1. The system opens the Scope Assessment wizard.
2. For each of the three lease identification criteria, you record: Yes / No / Uncertain.
3. If all three are Yes: system proposes "IN SCOPE."
4. If any is Uncertain: the system flags this for IFRS 16 specialist review — do not proceed unilaterally.
5. Enter your rationale in the text field.
6. If IN SCOPE: proceed to Exemption Check.

**Important:** The system's scope suggestion is only a proposal. Your decision is the authoritative one. The system records your name, timestamp, and rationale.

---

### 3.3 Exemption Assessment

1. Short-term check: The system shows the proposed lease term. Is it ≤ 12 months? The system applies the asset class policy you have configured. Confirm or override.
2. Low-value check: The system shows the asset value when new entered by the RE Contract Manager. Is it below the threshold set in the system parameters? Confirm or override.
3. If exempt: select the applicable exemption type. The system records the decision.
4. If not exempt: proceed to Lease Term assessment.

---

### 3.4 Lease Term Determination

1. The system presents all option dates with contractual data.
2. For each option, record your "reasonably certain" assessment: Yes / No.
3. Enter your rationale for each option assessment.
4. The system calculates the proposed lease term from your assessments.
5. Review the proposed term and confirm.
6. Your approved term is locked — it can only be changed via a modification workflow.

---

### 3.5 Discount Rate Entry

1. Determine the applicable discount rate:
   - Is the rate implicit in the lease available? Enter it in the "Rate Implicit" field.
   - If not: enter the Incremental Borrowing Rate (IBR) in the "IBR" field.
2. Enter the reference for the rate (e.g., treasury memo reference, date of rate determination).
3. Confirm. The rate is locked after calculation approval.

**If you do not have the IBR yet:** Save as draft and notify Treasury to provide the rate before proceeding.

---

### 3.6 Reviewing the Calculation Result

After calculation completes:

1. The system presents the calculation explainer:
   - Opening lease liability amount
   - Opening ROU asset amount
   - Amortization schedule preview (first 12 periods)
   - Total interest over lease term
   - Total depreciation over lease term

2. Review each figure. If anything looks incorrect: click "Reject Calculation" and describe the issue. The system will require recalculation.

3. If correct: click "Approve Calculation." The run is now eligible for posting.

---

### 3.7 Processing a Contract Modification

When you receive a modification alert:

1. Open the modification workflow from `ZRE_IFRS16_REVIEW` → Modifications tab.
2. The system shows you the change detected in RE-FX and the pre-modification snapshot.
3. Work through the classification wizard:
   - Does this add right to use additional assets? (Yes/No)
   - If Yes: Does the consideration increase by an amount commensurate with the standalone price? (Yes/No)
   - The system proposes a treatment based on your answers.
4. Confirm or override the proposed treatment.
5. Review the before/after balance delta.
6. Approve the modification to allow it to be processed.

**If classification is uncertain:** do not approve. Escalate to your IFRS 16 accounting advisor and record the open question in the notes field.

---

### 3.8 Period-End Workflow (Summary)

| Step | Action | Transaction |
|------|--------|------------|
| 1 | Verify all active leases are ready for period-end (no pending modifications) | ZRE_IFRS16_REVIEW |
| 2 | Check that discount rates are current (if index-based) | ZRE_IFRS16_ADMIN |
| 3 | Confirm period-end batch is scheduled (IT Support) | — |
| 4 | Review calculation run output after batch completes | ZRE_IFRS16_REVIEW |
| 5 | Approve calculation run | ZRE_IFRS16_REVIEW |
| 6 | Notify Controller that run is ready for posting approval | — |

---

## Section 4: Finance Controller

### 4.1 Approving the Period-End Run for Posting

**Transaction:** `ZRE_IFRS16_POST`

1. Open the transaction after being notified by the Lease Accountant.
2. Review the run summary: total entries by account type, total amounts, number of contracts.
3. Review flagged items (contracts that need extra attention).
4. If satisfied: click "Approve Run for Posting."
5. Confirm the confirmation dialog — this is irreversible.
6. The posting program runs; you receive a completion notification with FI document summary.

**Do NOT approve if:** Any significant variance from the prior period is unexplained. Request the Lease Accountant to provide an explanation before you approve.

---

### 4.2 Generating the Disclosure Pack

**Transaction:** `ZRE_IFRS16_DISC`

1. Select the reporting period.
2. Select output type: Maturity Analysis / Rollforward / Weighted Average Rate / Full Pack.
3. Review the output. The system shows all amounts sourced from the Z calculation tables.
4. If any figure requires explanation: click the contract reference to drill down.
5. Sign off the disclosure pack by clicking "Controller Sign-Off."
6. Your sign-off is recorded with timestamp.

---

### 4.3 Reconciliation Review

**Transaction/Report:** `ZRIF16_RECONCILIATION` (to be developed in Phase 2)

The reconciliation report compares:
- IFRS 16 schedule balance (from Z tables)
- GL balance (from FI-GL)

Any difference is flagged. You should expect zero differences after a successful posting run. Investigate and document any difference before period-end close.

---

## Section 5: Auditor / Audit Reviewer

### 5.1 What Evidence the System Provides

For any active lease in any period, you can retrieve:

| Evidence | Location |
|----------|---------|
| Scope determination (in/out of scope, with rationale) | ZRE_IFRS16_AUDIT → Scope tab |
| Exemption decision (if applicable) | ZRE_IFRS16_AUDIT → Scope tab |
| Lease term approved and rationale | ZRE_IFRS16_AUDIT → Term tab |
| Discount rate used and source | ZRE_IFRS16_AUDIT → Rate tab |
| Payment schedule at commencement | ZRE_IFRS16_AUDIT → Inputs tab |
| Amortization schedule | ZRE_IFRS16_AUDIT → Schedule tab |
| Approval records (who approved and when) | ZRE_IFRS16_AUDIT → Approvals tab |
| FI documents linked to this lease | ZRE_IFRS16_AUDIT → Postings tab |
| All modification events | ZRE_IFRS16_AUDIT → Modifications tab |

---

### 5.2 Accessing the Audit Trail

**Transaction:** `ZRE_IFRS16_AUDIT`

1. Enter company code and contract number (or run in list mode for multiple contracts).
2. Select the period or date range.
3. The system displays all IFRS 16 evidence for the selection.
4. Export functionality available for sharing with external auditors. [Format TBC]

---

## Section 6: IT/ABAP Support

### 6.1 Monitoring Batch Jobs

Key batch jobs to monitor:

| Job | Schedule | Alert Condition |
|-----|---------|----------------|
| ZRIF16_PERIOD_END_CALC | Period-end (triggered manually) | Non-zero exceptions in the run log |
| ZRIF16_DATA_CONSISTENCY | Weekly (recommended) | Any inconsistencies detected |

Monitor via SLG1 (transaction) using log object `ZRIF16`.

### 6.2 Parameter Maintenance

**Transaction:** `ZRE_IFRS16_ADMIN`

- Low-value threshold: maintain by company code.
- Short-term policy elections: maintain by company code and asset class.
- GL account assignments for IFRS 16 postings: maintain by entry type and company code.
- Changes to parameters are logged and require admin authorization.

### 6.3 Common Error Resolution

| Error | Likely Cause | Resolution |
|-------|-------------|-----------|
| "Calculation run failed — data error on contract X" | Missing required IFRS 16 field in ZRIF16_CNTRT | Check the field in ZRIF16_CNTRT; notify Lease Accountant to complete data |
| "Posting failed — no GL account for entry type X" | Missing GL account assignment | Maintain in ZRE_IFRS16_ADMIN → GL Assignments tab |
| "Authorization error — user cannot approve" | Missing auth object assignment | Check user's role assignments against SOD matrix |

---

## Section 7: FAQ

**Q: What happens if I forget to submit the intake form?**
A: The contract will remain in "Not Assessed" status. The period-end batch will skip it with a warning. You will receive a notification. Complete the intake as soon as possible to avoid period-end exceptions.

**Q: Can I change the lease term after it has been approved?**
A: Not directly. A change to the approved lease term is processed as a remeasurement event through the modification workflow. Contact the Lease Accountant.

**Q: What if the system and my spreadsheet show different numbers?**
A: The system's calculation is authoritative once approved. If you believe there is an error, contact the Lease Accountant — do NOT override the system manually. The Lease Accountant can reject the calculation and request a review.

**Q: Who do I call if the system is down during period-end?**
A: Contact IT Support immediately. Period-end calculations can be rerun after the system is restored — the system is designed to be idempotent (running the batch twice produces the same result).

**Q: Can I see my lease calculations before the Controller approves them?**
A: Yes. The calculation review screen in `ZRE_IFRS16_REVIEW` is available after the Lease Accountant approves the calculation. You can review without approving.

---

*This manual is updated with every feature release. Version history is maintained in the version table at the top of this document. For questions about the manual, contact your project governance team.*
