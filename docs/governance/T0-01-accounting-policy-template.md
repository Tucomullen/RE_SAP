# IFRS 16 Accounting Policy Document — Template for T0-01 Workshop
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** DRAFT — Ready for T0-01 Workshop Completion | **Owner:** IFRS 16 Accountant

---

## Executive Summary

This document records the client's formal IFRS 16 accounting policy decisions. It is the authoritative reference for all IFRS 16 calculations performed by the Z addon. Every decision is grounded in IFRS 16 paragraphs and includes the business rationale and impact on the addon design.

**Workshop Objective:** Complete all open questions (OQ-ACC-01 through OQ-ACC-05) and obtain formal sign-off from the IFRS 16 Accountant and Finance Controller.

**Decisions to be finalized in T0-01:**
- OQ-ACC-01: Formal accounting policy sign-off
- OQ-ACC-02: Linearization requirement
- OQ-ACC-03: Incremental Borrowing Rate (IBR) determination
- OQ-ACC-04: REASONABLY CERTAIN threshold for renewal options
- OQ-ACC-05: Initial Direct Costs (IDC) tracking

---

## 1. Lease Identification and Scope

### 1.1 Lease Definition — IFRS 16 ¶9–11

**Policy Decision:** [TO BE COMPLETED IN T0-01]

A contract is a lease if it conveys the right to control the use of an identified asset for a period of time in exchange for consideration. Control exists when the lessee has:
1. The right to obtain substantially all the economic benefits from the use of the identified asset, AND
2. The right to direct the use of the identified asset.

**Proposed Application:**
- [HUMAN VALIDATION REQUIRED] Confirm which contract types in the current ECC solution meet this definition.
- [HUMAN VALIDATION REQUIRED] Confirm whether any contracts are currently classified as non-leases that should be reconsidered.

**Impact on Addon Design:**
- CD-01 (Contract Master Z): Scope field required on every contract (IN_SCOPE / EXEMPT / OUT_OF_SCOPE).
- CD-02 (Lease Object Master Z): Asset identification must be explicit and auditable.
- CD-09 (Reporting & Audit Z): Scope decision must be traceable with approver and date.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

### 1.2 Short-Term Lease Exemption — IFRS 16 ¶5(a), ¶B34

**Policy Decision:** [TO BE COMPLETED IN T0-01]

A lessee may elect not to apply IFRS 16 to short-term leases (leases with a lease term of 12 months or less at the commencement date).

**Proposed Application:**
- **Election:** Does the client elect to use the short-term exemption? [YES / NO]
- **Scope:** If YES, which asset classes are eligible for the exemption?
  - [ ] Land
  - [ ] Buildings
  - [ ] Vehicles
  - [ ] Equipment
  - [ ] Other: _______________

**Rationale:** [HUMAN VALIDATION REQUIRED — Provide business rationale for exemption election]

**Impact on Addon Design:**
- CD-01 (Contract Master Z): Lease term field required; system auto-checks against 12-month threshold.
- CD-03 (Valuation Engine Z): If exempt, no calculation run is triggered; contract marked EXEMPT.
- CD-09 (Reporting & Audit Z): Exempt leases reported separately; total short-term lease expense disclosed.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

### 1.3 Low-Value Asset Exemption — IFRS 16 ¶5(b), ¶B3–B8

**Policy Decision:** [TO BE COMPLETED IN T0-01]

A lessee may elect not to apply IFRS 16 to leases of low-value assets. An asset is considered low-value if, when new, it has a value of USD 5,000 or less (or equivalent in other currencies).

**Proposed Application:**
- **Election:** Does the client elect to use the low-value exemption? [YES / NO]
- **Threshold:** What is the low-value threshold in the client's reporting currency?
  - USD equivalent: $5,000 (IFRS 16 guidance)
  - Client currency equivalent: _____________ (to be confirmed by Finance)
- **Scope:** Which asset classes are eligible?
  - [ ] Land — typically NOT low-value
  - [ ] Buildings — typically NOT low-value
  - [ ] Vehicles — [YES / NO]
  - [ ] Equipment — [YES / NO]
  - [ ] Software — [YES / NO]
  - [ ] Other: _______________

**Rationale:** [HUMAN VALIDATION REQUIRED]

**Impact on Addon Design:**
- CD-01 (Contract Master Z): Asset value when new field required; system auto-checks against threshold.
- CD-03 (Valuation Engine Z): If low-value, no calculation run; contract marked EXEMPT.
- CD-09 (Reporting & Audit Z): Low-value lease expense disclosed separately.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

## 2. Lease Term Determination

### 2.1 Lease Term Definition — IFRS 16 ¶19–24

**Policy Decision:** [TO BE COMPLETED IN T0-01]

The lease term is the non-cancellable period of a lease, plus periods covered by an option to extend (or not to terminate) the lease if the lessee is reasonably certain to exercise that option.

**Proposed Application:**

#### 2.1.1 Non-Cancellable Period
- **Definition:** The period for which the lessee has the right to use the underlying asset, during which neither the lessee nor the lessor can terminate the lease without permission.
- **Data Source:** RE-FX contract start date and non-cancellable end date (or derived from contract term).
- **Validation:** System validates that non-cancellable period is ≥ 0 months.

#### 2.1.2 Renewal Options — REASONABLY CERTAIN Threshold

**OPEN QUESTION OQ-ACC-04:** [TO BE COMPLETED IN T0-01]

**Question:** How is the "reasonably certain" threshold defined in the client's policy?

**Proposed Guidance:**
- **Quantitative:** A renewal option is reasonably certain if the probability of exercise is > [CLIENT THRESHOLD]%. [HUMAN VALIDATION REQUIRED — Confirm threshold]
- **Qualitative:** A renewal option is reasonably certain if:
  - The lessor has a strong economic incentive to renew (e.g., renewal at below-market rates).
  - The lessee has a strong operational need to continue using the asset.
  - Historical pattern shows the lessee typically renews similar leases.

**Addon Implementation:**
- CD-01 (Contract Master Z): Renewal option flag + probability field.
- CD-03 (Valuation Engine Z): Lease term calculation includes renewal periods where probability ≥ threshold.
- CD-09 (Reporting & Audit Z): Renewal option assessment documented with approver and date.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

#### 2.1.3 Termination Options

**Policy Decision:** [TO BE COMPLETED IN T0-01]

A termination option is reasonably certain to be exercised if:
- The lessor has a strong economic incentive to terminate (e.g., termination penalty is low).
- The lessee has a strong operational need to terminate (e.g., asset becomes obsolete).

**Proposed Application:**
- Termination options are assessed using the same "reasonably certain" framework as renewal options.
- If a termination option is reasonably certain to be exercised, the lease term ends at the termination date (not the contractual end date).

**Addon Implementation:**
- CD-01 (Contract Master Z): Termination option flag + probability field.
- CD-03 (Valuation Engine Z): Lease term calculation excludes periods after reasonably certain termination date.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

## 3. Discount Rate and Initial Measurement

### 3.1 Discount Rate Selection — IFRS 16 ¶26

**Policy Decision:** [TO BE COMPLETED IN T0-01]

The discount rate used to measure the lease liability is:
1. **The rate implicit in the lease** (if determinable), OR
2. **The lessee's incremental borrowing rate (IBR)** (if the implicit rate is not determinable).

#### 3.1.1 Rate Implicit in the Lease

**Definition:** The discount rate that equates the present value of lease payments to the fair value of the underlying asset plus any initial direct costs.

**Proposed Application:**
- [HUMAN VALIDATION REQUIRED] Is the implicit rate determinable for any leases in the client's portfolio?
- If YES: Provide the method for determining the implicit rate (e.g., from lessor disclosure, reverse calculation).
- If NO: All leases will use the IBR approach.

**Addon Implementation:**
- CD-01 (Contract Master Z): Implicit rate field (optional); if populated, system uses this rate.
- CD-03 (Valuation Engine Z): If implicit rate is not provided, system defaults to IBR.

#### 3.1.2 Incremental Borrowing Rate (IBR) — OPEN QUESTION OQ-ACC-03

**OPEN QUESTION OQ-ACC-03:** [TO BE COMPLETED IN T0-01]

**Question:** How is the Incremental Borrowing Rate (IBR) determined per company code and currency?

**Proposed Approach:**

**Option A: Treasury-Provided Rate Table**
- Treasury provides a rate table by company code, currency, and lease term band.
- System applies the rate based on contract currency and company code.
- Rate is updated quarterly or as Treasury directs.

**Option B: Formula-Based IBR**
- IBR = Risk-free rate + Credit spread + Lease-specific adjustments
- Risk-free rate: [SOURCE — e.g., government bond yield]
- Credit spread: [CLIENT CREDIT RATING EQUIVALENT]
- Lease-specific adjustments: [COLLATERAL, TERM, CURRENCY]

**Option C: Hybrid**
- Treasury provides a base rate; system applies lease-specific adjustments.

**Proposed Selection:** [HUMAN VALIDATION REQUIRED — Select Option A, B, or C]

**Addon Implementation:**
- CD-01 (Contract Master Z): IBR field; system allows manual override with approval.
- CD-03 (Valuation Engine Z): IBR lookup table (ZRIF16_PARAM) stores rates by company code, currency, and effective date.
- CD-09 (Reporting & Audit Z): IBR used in each calculation is disclosed; weighted average IBR by asset class.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant + Treasury] _________________ Date: _______

---

### 3.2 Initial Direct Costs — OPEN QUESTION OQ-ACC-05

**OPEN QUESTION OQ-ACC-05:** [TO BE COMPLETED IN T0-01]

**Question:** Are initial direct costs (IDC) tracked and to be included in ROU calculation?

**IFRS 16 Requirement:** IFRS 16 ¶24 requires that the ROU asset be measured at:
- Lease liability + Initial direct costs − Lease incentives received

**Proposed Application:**

**Option A: IDC Included**
- Initial direct costs are tracked on every lease.
- IDC is added to the ROU asset at commencement.
- Examples of IDC: legal fees, broker commissions, lease negotiation costs.
- Examples of NON-IDC: general administrative costs, training costs.

**Option B: IDC Not Tracked**
- IDC is assumed to be immaterial or is expensed as incurred.
- ROU asset = Lease liability − Lease incentives received.

**Proposed Selection:** [HUMAN VALIDATION REQUIRED — Select Option A or B]

**If Option A Selected:**
- **Data Source:** [HUMAN VALIDATION REQUIRED] Where are IDC currently tracked? (RE-FX, manual spreadsheet, vendor invoice, other?)
- **Addon Implementation:**
  - CD-01 (Contract Master Z): IDC field on contract master.
  - CD-03 (Valuation Engine Z): IDC added to ROU asset at commencement.
  - CD-09 (Reporting & Audit Z): IDC disclosed in ROU rollforward.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

## 4. Lease Payments and Measurement

### 4.1 Lease Payment Components — IFRS 16 ¶27–29

**Policy Decision:** [TO BE COMPLETED IN T0-01]

Lease payments include:
1. Fixed payments (adjusted for inflation).
2. Variable payments that depend on an index or rate (e.g., CPI-linked rent).
3. Amounts expected to be paid under residual value guarantees.
4. Exercise prices of purchase options if reasonably certain to be exercised.
5. Penalties for termination if reasonably certain to be exercised.

**Excluded from lease payments:**
- Variable payments that do NOT depend on an index or rate (e.g., usage-based payments, performance-based payments).
- Payments for services or supplies (e.g., maintenance, insurance).

**Proposed Application:**

#### 4.1.1 Fixed Payments
- **Definition:** Payments that are fixed in amount or that vary only by reference to an index or rate.
- **Examples:** Monthly rent, annual rent increases by CPI, stepped rent increases.
- **Addon Implementation:** CD-01 (Contract Master Z) stores payment schedule with fixed amounts per period.

#### 4.1.2 Variable Payments — Index-Based

**Policy Decision:** [TO BE COMPLETED IN T0-01]

- **Definition:** Payments that vary based on an index (e.g., CPI) or rate (e.g., interest rate).
- **Proposed Treatment:** Index-based variable payments are INCLUDED in the lease liability at the rate in effect at commencement.
- **Addon Implementation:**
  - CD-01 (Contract Master Z): Variable payment flag + index reference.
  - CD-03 (Valuation Engine Z): At commencement, variable payments are measured at the index rate as of commencement date. Future changes to the index are recognized as lease modifications.

#### 4.1.3 Variable Payments — Non-Index-Based

**Policy Decision:** [TO BE COMPLETED IN T0-01]

- **Definition:** Payments that vary based on usage, performance, or other non-index factors (e.g., mileage-based vehicle lease, usage-based equipment lease).
- **Proposed Treatment:** Non-index-based variable payments are EXCLUDED from the lease liability. They are expensed as incurred.
- **Addon Implementation:**
  - CD-01 (Contract Master Z): Non-index variable payment flag.
  - CD-03 (Valuation Engine Z): These payments are not included in the liability calculation.
  - CD-09 (Reporting & Audit Z): Non-index variable payments are disclosed separately.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

#### 4.1.4 Residual Value Guarantees

**Policy Decision:** [TO BE COMPLETED IN T0-01]

- **Definition:** A guarantee by the lessee that the residual value of the underlying asset at the end of the lease term will be at least a specified amount.
- **Proposed Treatment:** [HUMAN VALIDATION REQUIRED] Are residual value guarantees present in the client's lease portfolio?
  - If YES: Residual value guarantees are included in the lease liability at the amount expected to be paid.
  - If NO: No action required.

**Addon Implementation:**
- CD-01 (Contract Master Z): Residual value guarantee field (optional).
- CD-03 (Valuation Engine Z): If populated, included in lease liability calculation.

#### 4.1.5 Purchase Options

**Policy Decision:** [TO BE COMPLETED IN T0-01]

- **Definition:** An option for the lessee to purchase the underlying asset at the end of the lease term.
- **Proposed Treatment:** If the lessee is reasonably certain to exercise the purchase option, the exercise price is included in the lease liability.
- **Addon Implementation:**
  - CD-01 (Contract Master Z): Purchase option flag + exercise price + probability.
  - CD-03 (Valuation Engine Z): If probability ≥ threshold, exercise price is included in lease liability.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

### 4.2 Linearization of Stepped Rents — OPEN QUESTION OQ-ACC-02

**OPEN QUESTION OQ-ACC-02:** [TO BE COMPLETED IN T0-01]

**Question:** Is linearization of stepped rents required (or optional) under the client's policy?

**Background:** Some leases have stepped rent schedules (e.g., Year 1: $100k, Year 2: $110k, Year 3: $120k). IFRS 16 does not require linearization — the actual payment schedule is used. However, some clients prefer to linearize for operational simplicity.

**Proposed Application:**

**Option A: No Linearization**
- Actual payment schedule is used in the lease liability calculation.
- Stepped payments are recognized as incurred.

**Option B: Linearization**
- Stepped payments are averaged over the lease term.
- Difference between actual and linearized payment is recognized as a lease modification adjustment.

**Proposed Selection:** [HUMAN VALIDATION REQUIRED — Select Option A or B]

**If Option B Selected:**
- **Addon Implementation:**
  - CD-03 (Valuation Engine Z): Linearization flag on contract; if set, system calculates average payment and uses that in liability calculation.
  - CD-04 (Accounting Engine Z): Difference between actual and linearized payment is posted as a lease modification adjustment.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

## 5. Lease Modifications and Remeasurement

### 5.1 Modification Classification — IFRS 16 ¶44–46

**Policy Decision:** [TO BE COMPLETED IN T0-01]

A lease modification is a change in the scope of a lease or the consideration for a lease that was not part of the original terms and conditions. Modifications are classified as:

1. **Separate Lease:** If the modification adds the right to use one or more additional assets at a standalone price.
2. **Adjustment to Existing Lease:** If the modification does not meet the separate lease criteria.

**Proposed Application:**

#### 5.1.1 Separate Lease Criteria
- **Criterion 1:** The modification adds the right to use one or more additional identified assets.
- **Criterion 2:** The price for the additional asset(s) is the standalone price (or adjusted for contract-specific factors).
- **If both criteria met:** Treat as a separate lease.

**Addon Implementation:**
- CD-06 (Contract Event Engine Z): Modification event type = SEPARATE_LEASE or ADJUSTMENT.
- CD-03 (Valuation Engine Z): If separate lease, a new calculation run is created for the new lease.

#### 5.1.2 Adjustment to Existing Lease
- **Treatment:** Remeasure the lease liability using the revised lease payments and discount rate.
- **Gain/Loss:** Any difference between the remeasured liability and the carrying amount is recognized as a gain or loss.

**Addon Implementation:**
- CD-06 (Contract Event Engine Z): Modification event type = ADJUSTMENT.
- CD-03 (Valuation Engine Z): Remeasurement calculation run created; delta analysis performed.
- CD-04 (Accounting Engine Z): Gain/loss posting generated.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

### 5.2 Remeasurement Triggers

**Policy Decision:** [TO BE COMPLETED IN T0-01]

The lease liability is remeasured when:
1. A lease modification occurs (see 5.1 above).
2. A change in the lease term occurs (e.g., option exercise, termination).
3. A change in the lease payments occurs (e.g., index adjustment, variable payment change).
4. A change in the discount rate occurs (e.g., change in IBR).

**Proposed Application:**

| Trigger | Remeasurement Required? | Addon Implementation |
|---------|------------------------|----------------------|
| Lease modification (separate lease) | YES | CD-06 event type = SEPARATE_LEASE; new calc run |
| Lease modification (adjustment) | YES | CD-06 event type = ADJUSTMENT; remeasurement calc run |
| Option exercise (renewal) | YES | CD-06 event type = OPTION_EXERCISED; lease term extended; remeasurement calc run |
| Option exercise (termination) | YES | CD-06 event type = OPTION_EXERCISED; lease term shortened; remeasurement calc run |
| Index adjustment (CPI-linked rent) | YES | CD-06 event type = INDEX_ADJUSTED; payment schedule updated; remeasurement calc run |
| IBR change | [HUMAN VALIDATION REQUIRED] | If YES: CD-06 event type = IBR_CHANGED; remeasurement calc run |

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

## 6. Derecognition and Early Termination

### 6.1 Derecognition — IFRS 16 ¶54–55

**Policy Decision:** [TO BE COMPLETED IN T0-01]

A lease is derecognized when:
1. The lease is terminated early.
2. The lessee exercises a purchase option and the asset is no longer a lease.
3. The lease term expires.

**Proposed Application:**

#### 6.1.1 Early Termination
- **Trigger:** Lease is terminated before the contractual end date.
- **Treatment:** Lease liability is derecognized; any difference between the carrying amount and the termination payment is recognized as a gain or loss.
- **Addon Implementation:**
  - CD-06 (Contract Event Engine Z): Event type = TERMINATED_EARLY.
  - CD-03 (Valuation Engine Z): Derecognition calculation run; gain/loss computed.
  - CD-04 (Accounting Engine Z): Derecognition posting generated.

#### 6.1.2 Purchase Option Exercise
- **Trigger:** Lessee exercises a purchase option and acquires the asset.
- **Treatment:** Lease liability is derecognized; ROU asset is reclassified to owned asset (or disposed of).
- **Addon Implementation:**
  - CD-06 (Contract Event Engine Z): Event type = PURCHASE_OPTION_EXERCISED.
  - CD-05 (Asset Engine Z): ROU asset is derecognized; owned asset is created (if applicable).

#### 6.1.3 Lease Term Expiration
- **Trigger:** Lease term expires on the contractual end date.
- **Treatment:** Lease liability is derecognized; ROU asset is fully depreciated.
- **Addon Implementation:**
  - CD-06 (Contract Event Engine Z): Event type = LEASE_EXPIRED (automatic at period-end).
  - CD-04 (Accounting Engine Z): Final derecognition posting generated.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

## 7. Country-Specific Rules

### 7.1 Poland — Advance Payment Leases

**Policy Decision:** [TO BE COMPLETED IN T0-01]

**Background:** In Poland, some lease contracts require advance payments (payment at the beginning of the lease term, not at the end). This affects the timing of the interest accrual and the ROU asset depreciation.

**Proposed Application:**

**Question:** [HUMAN VALIDATION REQUIRED] Are advance payment leases present in the client's portfolio?

**If YES:**
- **Treatment:** Advance payments are recognized as a reduction to the ROU asset at commencement (not as a prepaid expense).
- **Interest Accrual:** Interest is accrued on the remaining liability (after advance payment).
- **Addon Implementation:**
  - CD-01 (Contract Master Z): Advance payment flag on contract.
  - CD-03 (Valuation Engine Z): If advance payment flag is set, ROU asset is reduced by the advance payment amount.
  - CD-04 (Accounting Engine Z): Initial recognition posting reflects the reduced ROU asset.

**Approval:** [SIGNATURE REQUIRED — IFRS 16 Accountant] _________________ Date: _______

---

## 8. Disclosure Requirements

### 8.1 IFRS 16 Disclosure — Paragraphs 52–60

**Policy Decision:** [TO BE COMPLETED IN T0-01]

IFRS 16 requires disclosure of:
1. **Maturity analysis:** Undiscounted future lease payments by maturity band.
2. **Lease liability rollforward:** Opening balance, additions, modifications, payments, interest, closing balance.
3. **ROU asset rollforward:** Opening balance, additions, depreciation, modifications, impairment, closing balance.
4. **Weighted average discount rate:** By asset class.
5. **Short-term and low-value lease expense:** Total period expense.

**Proposed Application:**
- All disclosure data is sourced from Z calculation tables (CD-09 Reporting & Audit Z).
- Disclosure pack is generated automatically at period-end.
- Finance Controller reviews and approves disclosure pack before financial statement publication.

**Addon Implementation:**
- CD-09 (Reporting & Audit Z): CDS views and reports for all disclosure requirements.
- Disclosure pack export to Excel or PDF (Phase 2).

**Approval:** [SIGNATURE REQUIRED — Finance Controller] _________________ Date: _______

---

## 9. Approval and Sign-Off

### 9.1 Policy Approval

This accounting policy document is approved by:

| Role | Name | Signature | Date |
|------|------|-----------|------|
| IFRS 16 Accountant | _________________ | _________________ | _______ |
| Finance Controller | _________________ | _________________ | _______ |
| Project Governance Lead | _________________ | _________________ | _______ |

### 9.2 Effective Date

This policy is effective as of: **[DATE TO BE CONFIRMED IN T0-01]**

### 9.3 Review and Update

This policy will be reviewed and updated:
- Annually (or as required by changes in IFRS 16 or client circumstances).
- Whenever a significant accounting judgment is made that affects the policy.
- Before each major project phase gate.

---

## 10. Appendices

### Appendix A: IFRS 16 Paragraph References

| Topic | IFRS 16 Paragraph |
|-------|------------------|
| Lease definition | ¶9–11 |
| Short-term exemption | ¶5(a), ¶B34 |
| Low-value exemption | ¶5(b), ¶B3–B8 |
| Lease term | ¶19–24 |
| Discount rate | ¶26 |
| Lease payments | ¶27–29 |
| Initial direct costs | ¶24 |
| Modifications | ¶44–46 |
| Derecognition | ¶54–55 |
| Disclosure | ¶52–60 |

### Appendix B: Open Questions Requiring T0-01 Resolution

| OQ ID | Question | Owner | Status |
|-------|----------|-------|--------|
| OQ-ACC-01 | Is the IFRS 16 accounting policy formally signed off by the client? | IFRS 16 Accountant | OPEN |
| OQ-ACC-02 | Is linearization of stepped rents required (or optional) under the client's policy? | IFRS 16 Accountant | OPEN |
| OQ-ACC-03 | How is the Incremental Borrowing Rate (IBR) determined per company code / currency? | IFRS 16 Accountant + Treasury | OPEN |
| OQ-ACC-04 | Is the REASONABLY CERTAIN threshold for renewal options defined in client policy? | IFRS 16 Accountant | OPEN |
| OQ-ACC-05 | Are initial direct costs (IDC) tracked and to be included in ROU calculation? | IFRS 16 Accountant | OPEN |

---

**Document Status:** DRAFT — Ready for T0-01 Workshop
**Next Action:** IFRS 16 Accountant to complete all [HUMAN VALIDATION REQUIRED] sections and obtain sign-offs.
**Target Completion:** End of T0-01 Workshop (2026-04-XX)

