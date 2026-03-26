# T0-01 Accounting Policy Decision Matrix
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** DRAFT — Ready for T0-01 Workshop | **Owner:** IFRS 16 Accountant

---

## Purpose

This matrix maps every IFRS 16 accounting policy decision to:
1. The IFRS 16 paragraph(s) that govern it
2. The options considered
3. The proposed decision
4. The impact on the Z addon design (CD-03 Valuation Engine, CD-04 Accounting Engine)
5. Any blocker if the decision is not made

**Workshop Objective:** Complete all decisions and obtain sign-off from IFRS 16 Accountant and Finance Controller.

---

## Decision Matrix

| # | Decision | IFRS 16 Para | Options Considered | Proposed Decision | Impact on CD-03 (Valuation) | Impact on CD-04 (Accounting) | Blocker if Not Decided | Status |
|---|----------|-------------|-------------------|------------------|------------------------------|------------------------------|----------------------|--------|
| **B-01** | Lease identification criteria | ¶9–11 | (1) All three criteria required (2) Flexible interpretation | All three criteria required: identified asset + substantially all benefits + right to direct use | Scope determination logic; contract marked IN_SCOPE or OUT_OF_SCOPE | N/A — no posting if out of scope | Cannot proceed with any contract | [HUMAN VALIDATION REQUIRED] |
| **B-02** | Short-term exemption election | ¶5(a), ¶B34 | (1) Elect exemption (2) Do not elect exemption | [HUMAN VALIDATION REQUIRED — Select option] | If elected: contracts ≤12 months marked EXEMPT; no calculation run | If elected: no FI posting for exempt leases | Cannot determine which contracts are in-scope | [HUMAN VALIDATION REQUIRED] |
| **B-03** | Low-value exemption election | ¶5(b), ¶B3–B8 | (1) Elect exemption (2) Do not elect exemption | [HUMAN VALIDATION REQUIRED — Select option] | If elected: contracts with asset value ≤ threshold marked EXEMPT; no calculation run | If elected: no FI posting for low-value leases | Cannot determine which contracts are in-scope | [HUMAN VALIDATION REQUIRED] |
| **B-04** | Low-value threshold amount | ¶B3–B8 | (1) USD 5,000 (IFRS guidance) (2) Client-specific threshold | [HUMAN VALIDATION REQUIRED — Confirm threshold in client currency] | Threshold used in exemption check; system compares asset value to this amount | N/A — exemption determination only | Cannot apply low-value exemption correctly | [HUMAN VALIDATION REQUIRED] |
| **B-05** | Lease term: non-cancellable period | ¶19 | (1) Contractual end date (2) Earliest termination date | Non-cancellable period = contractual end date unless termination option is reasonably certain | Base lease term; used in all calculations | N/A — valuation only | Wrong lease term → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-06** | Lease term: renewal option assessment | ¶19–24 | (1) Quantitative threshold (e.g., >50% probability) (2) Qualitative assessment (3) Hybrid | [HUMAN VALIDATION REQUIRED — Define "reasonably certain" threshold] | Renewal periods included in lease term if probability ≥ threshold | N/A — valuation only | Wrong lease term → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-07** | Lease term: termination option assessment | ¶19–24 | (1) Quantitative threshold (2) Qualitative assessment (3) Hybrid | [HUMAN VALIDATION REQUIRED — Define "reasonably certain" threshold] | Lease term shortened if termination is reasonably certain | N/A — valuation only | Wrong lease term → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-08** | Discount rate: implicit rate determination | ¶26 | (1) Use implicit rate if determinable (2) Always use IBR | [HUMAN VALIDATION REQUIRED — Is implicit rate determinable for any leases?] | If implicit rate available: system uses it; otherwise defaults to IBR | N/A — valuation only | Wrong discount rate → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-09** | Discount rate: IBR determination method | ¶26 | (1) Treasury-provided rate table (2) Formula-based (3) Hybrid | [HUMAN VALIDATION REQUIRED — Select method] | IBR lookup table (ZRIF16_PARAM) populated per method; system applies rate per contract | N/A — valuation only | Cannot calculate liability without IBR | [HUMAN VALIDATION REQUIRED] |
| **B-10** | Discount rate: IBR update frequency | ¶26 | (1) Fixed at commencement (2) Updated quarterly (3) Updated annually | [HUMAN VALIDATION REQUIRED — Select frequency] | If fixed: rate locked at commencement; if updated: remeasurement triggered | If updated: remeasurement posting generated | Wrong rate → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-11** | Lease payments: fixed payments | ¶27 | (1) Include all fixed payments (2) Exclude certain categories | Include all fixed payments (adjusted for inflation if applicable) | Payment schedule stored in Z tables; used in liability calculation | N/A — valuation only | Wrong payment schedule → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-12** | Lease payments: index-based variable payments | ¶27–29 | (1) Include at commencement rate (2) Exclude (3) Include at expected future rate | Include at index rate in effect at commencement; future changes = remeasurement | Variable payment flag on contract; included in liability at commencement rate | Remeasurement posting generated when index changes | Wrong payment classification → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-13** | Lease payments: non-index variable payments | ¶27–29 | (1) Include (2) Exclude | Exclude from lease liability; expense as incurred | Non-index variable payment flag; excluded from liability calculation | Expensed as incurred (not posted as lease liability) | Wrong payment classification → wrong liability | [HUMAN VALIDATION REQUIRED] |
| **B-14** | Lease payments: residual value guarantees | ¶27–29 | (1) Include if present (2) Exclude | Include if present and expected to be paid | Residual value guarantee field on contract; included in liability | N/A — valuation only | Wrong liability if guarantee exists | [HUMAN VALIDATION REQUIRED] |
| **B-15** | Lease payments: purchase options | ¶27–29 | (1) Include if reasonably certain (2) Exclude | Include if lessee is reasonably certain to exercise | Purchase option flag + probability; included if probability ≥ threshold | N/A — valuation only | Wrong lease term / liability if option is certain | [HUMAN VALIDATION REQUIRED] |
| **B-16** | Initial direct costs (IDC) | ¶24 | (1) Track and include in ROU (2) Expense as incurred | [HUMAN VALIDATION REQUIRED — Select option] | If included: IDC field on contract; added to ROU asset at commencement | If included: IDC added to ROU asset in initial recognition posting | Incomplete ROU asset if IDC not tracked | [HUMAN VALIDATION REQUIRED] |
| **B-17** | Linearization of stepped rents | ¶27–29 | (1) Use actual payment schedule (2) Linearize payments | [HUMAN VALIDATION REQUIRED — Select option] | If linearized: system calculates average payment; used in liability calculation | If linearized: difference between actual and linearized posted as adjustment | Wrong liability if linearization required but not applied | [HUMAN VALIDATION REQUIRED] |
| **B-18** | Lease modifications: separate lease criteria | ¶44–46 | (1) Strict application (2) Flexible interpretation | Strict: separate lease only if additional asset at standalone price | Modification event type = SEPARATE_LEASE or ADJUSTMENT; new calc run if separate | If separate lease: new FI posting for new lease | Wrong accounting treatment if criteria misapplied | [HUMAN VALIDATION REQUIRED] |
| **B-19** | Lease modifications: adjustment treatment | ¶44–46 | (1) Remeasure liability (2) Adjust ROU asset | Remeasure lease liability; recognize gain/loss | Remeasurement calc run; delta analysis | Gain/loss posting generated | Wrong liability if modification not remeasured | [HUMAN VALIDATION REQUIRED] |
| **B-20** | Remeasurement triggers: option exercise | ¶19–24 | (1) Trigger remeasurement (2) Do not trigger | Trigger remeasurement; lease term changes | Lease term updated; new calc run | Remeasurement posting generated | Wrong liability if option exercise not remeasured | [HUMAN VALIDATION REQUIRED] |
| **B-21** | Remeasurement triggers: index adjustment | ¶27–29 | (1) Trigger remeasurement (2) Do not trigger | Trigger remeasurement; payment schedule updated | Payment schedule updated; new calc run | Remeasurement posting generated | Wrong liability if index change not remeasured | [HUMAN VALIDATION REQUIRED] |
| **B-22** | Remeasurement triggers: IBR change | ¶26 | (1) Trigger remeasurement (2) Do not trigger | [HUMAN VALIDATION REQUIRED — Select option] | If triggered: new calc run with updated IBR | If triggered: remeasurement posting generated | Wrong liability if IBR change not remeasured | [HUMAN VALIDATION REQUIRED] |
| **B-23** | Derecognition: early termination | ¶54–55 | (1) Recognize gain/loss (2) Adjust ROU asset | Recognize gain/loss on derecognition | Derecognition calc run; gain/loss computed | Derecognition posting generated | Liability not removed if termination not processed | [HUMAN VALIDATION REQUIRED] |
| **B-24** | Derecognition: purchase option exercise | ¶54–55 | (1) Derecognize lease (2) Continue lease | Derecognize lease; reclassify ROU to owned asset | Derecognition calc run | Derecognition posting + asset reclassification | Lease continues incorrectly if option not processed | [HUMAN VALIDATION REQUIRED] |
| **B-25** | Country-specific: Poland advance payments | ¶24 | (1) Reduce ROU asset (2) Reduce liability (3) Treat as prepaid | Reduce ROU asset at commencement | Advance payment flag on contract; ROU reduced by advance amount | Initial recognition posting reflects reduced ROU | Wrong ROU asset if advance payment not handled | [HUMAN VALIDATION REQUIRED] |
| **B-26** | Disclosure: maturity analysis | ¶58(b) | (1) Undiscounted payments (2) Discounted payments | Undiscounted future lease payments by maturity band | Maturity analysis report from schedule table | N/A — reporting only | Incomplete disclosure | [HUMAN VALIDATION REQUIRED] |
| **B-27** | Disclosure: rollforward | ¶52–60 | (1) Detailed rollforward (2) Summary only | Detailed rollforward: opening + additions + modifications + payments + interest + closing | Rollforward report from schedule table | N/A — reporting only | Incomplete disclosure | [HUMAN VALIDATION REQUIRED] |

---

## Summary of Open Questions (OQ-ACC-01 to OQ-ACC-05)

| OQ ID | Decision | Owner | Target Resolution | Status |
|-------|----------|-------|-------------------|--------|
| OQ-ACC-01 | Is the IFRS 16 accounting policy formally signed off by the client? | IFRS 16 Accountant | T0-01 Workshop | OPEN |
| OQ-ACC-02 | Is linearization of stepped rents required (or optional) under the client's policy? | IFRS 16 Accountant | T0-01 Workshop | OPEN |
| OQ-ACC-03 | How is the Incremental Borrowing Rate (IBR) determined per company code / currency? | IFRS 16 Accountant + Treasury | T0-01 Workshop | OPEN |
| OQ-ACC-04 | Is the REASONABLY CERTAIN threshold for renewal options defined in client policy? | IFRS 16 Accountant | T0-01 Workshop | OPEN |
| OQ-ACC-05 | Are initial direct costs (IDC) tracked and to be included in ROU calculation? | IFRS 16 Accountant | T0-01 Workshop | OPEN |

---

## Approval Sign-Off

This decision matrix is approved by:

| Role | Name | Signature | Date |
|------|------|-----------|------|
| IFRS 16 Accountant | _________________ | _________________ | _______ |
| Finance Controller | _________________ | _________________ | _______ |

---

**Document Status:** DRAFT — Ready for T0-01 Workshop
**Next Action:** Complete all [HUMAN VALIDATION REQUIRED] cells and obtain sign-offs.
**Target Completion:** End of T0-01 Workshop

