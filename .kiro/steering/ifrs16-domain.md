---
inclusion: auto
description: IFRS 16 domain rules, accounting scope boundaries, and agent constraints for the RE-SAP addon.
---

# IFRS 16 Domain Steering — RE-SAP Addon

## Domain Boundaries
This addon operates **exclusively within the lessee accounting scope of IFRS 16** as issued by the IASB (effective January 2019, with subsequent amendments). The standard requires lessees to recognize:
- A **right-of-use (ROU) asset** representing the right to use the underlying asset.
- A **lease liability** representing the obligation to make lease payments.

This project does not implement lessor accounting (IFRS 16 paragraphs 61–97), sale-and-leaseback accounting, or sublease accounting in the first release.

All accounting rules and interpretations must be grounded in the official IFRS 16 text stored in `knowledge/official-ifrs/`. **Agents must never derive accounting rules from inference alone.**

---

## Lessee Accounting Focus

### Recognition Criteria
An arrangement contains a lease under IFRS 16 when:
1. There is an **identified asset** (explicit or implicit).
2. The customer has the right to obtain **substantially all the economic benefits** from use.
3. The customer has the right to **direct the use** of the asset throughout the period of use.

Agents working on contract analysis must apply these three criteria explicitly and flag any ambiguity for human validation.

### Initial Measurement
- **Lease liability:** Present value of unpaid lease payments, discounted at the **incremental borrowing rate (IBR)** or, if determinable, the rate implicit in the lease.
- **ROU asset:** Equal to lease liability initial value, plus initial direct costs, prepayments, and less any incentives received.

> IBR selection is a critical accounting judgment — **always requires human validation from the IFRS 16 Accountant.**

### Subsequent Measurement
- **Lease liability:** Amortized using the effective interest method. Adjusted for remeasurements and modifications.
- **ROU asset:** Depreciated on a straight-line basis over the shorter of the lease term or useful life of the underlying asset (unless another method reflects the pattern of consumption of benefits).

---

## Short-Term and Low-Value Exemptions

### Short-Term Exemption (IFRS 16 paragraph 5(a))
- Applies when the lease term (including renewal options the lessee is reasonably certain to exercise) is **12 months or less** at commencement.
- Payments recognized as expense on a straight-line or systematic basis.
- Election must be made by **class of underlying asset** — not contract by contract.
- The system must capture the exemption election at the asset class level and validate it at contract commencement.

### Low-Value Exemption (IFRS 16 paragraph 5(b))
- Applies when the **underlying asset value when new** is below a defined threshold (commonly USD 5,000 per IASB basis for conclusions — to be confirmed with IFRS 16 Accountant as some entities apply different thresholds).
- Applied on a **contract-by-contract** basis.
- The system must store the threshold parameter and the per-contract low-value determination with audit trail.

> **Human validation required:** Both exemption elections have policy implications. The system enforces the policy but cannot set it without accounting sign-off.

---

## Lease Term

Lease term is one of the most judgment-intensive areas. The addon must support:
- **Non-cancellable period** as the base.
- **Periods covered by extension options** the lessee is reasonably certain to exercise.
- **Periods covered by termination options** the lessee is reasonably certain NOT to exercise.
- Annual reassessment: Events that trigger reassessment (significant leaseholder modifications, change in business strategy, etc.) must be detectable and flagged.

> **Lease term determination always requires human validation.** The system can propose based on contractual data and configurable rules, but the final determination must be approved by the IFRS 16 Accountant.

---

## Variable Payments

| Payment Type | IFRS 16 Treatment | System Handling |
|-------------|-------------------|-----------------|
| Fixed payments (including in-substance fixed) | Included in lease liability | Captured in payment schedule |
| Variable linked to index or rate | Included at commencement using index/rate at that date; remeasured at trigger events | Stored with index/rate snapshot; remeasurement flag |
| Variable not based on index/rate (e.g., revenue-based) | Excluded from lease liability; expensed when incurred | Captured separately; flagged as excluded |
| Residual value guarantees | Included (lessee's expected payment only) | Separate field in contract data |
| Purchase options (reasonably certain) | Included | Separate field; requires human validation |
| Penalty for early termination (not certain) | Included if termination is in lease term | Conditional logic; requires human validation |

---

## Lease Modifications and Remeasurement

### Modification — Separate New Lease
Treated as a new lease if it:
- Adds right to use one or more additional underlying assets, AND
- Lease payments increase by an amount commensurate with the standalone price.

### Modification — Not a Separate New Lease
Treated as an adjustment to the existing lease:
- Decrease in scope: Proportionate reduction in ROU and liability; gain/loss recognized.
- No decrease in scope: Adjusted discount rate; remeasure liability and adjust ROU asset.

### Remeasurement Triggers (not modifications)
- Reassessment of lease term (exercise or non-exercise of option).
- Reassessment of purchase option.
- Change in amounts payable under residual value guarantee.
- Change in index/rate used to determine payments.

> **Modification classification (new lease vs. adjustment) requires human accounting validation before any calculation is performed.**

### System Requirements
- The system must detect potential trigger events from contract change data.
- Present a remeasurement/modification wizard to the accountant with pre-populated data and calculation preview.
- Store the pre-modification snapshot for audit purposes before applying any changes.

---

## Accounting Evidence Expectations
Every IFRS 16 transaction in the system must produce the following audit evidence:
1. **Contract data snapshot** at measurement date.
2. **Calculation inputs** (discount rate, payment schedule, lease term, etc.) with source references.
3. **Calculation output** (opening balances, amortization table, period entries).
4. **Decision log** for any judgment made (lease term, exemption, modification type).
5. **Approver identity and timestamp** for all human-validated decisions.
6. **Posted document references** (FI document numbers linked to calculation run).

---

## Explainability Requirements
The system must be able to answer the following questions for any lease at any point in time:
- "Why is this contract within IFRS 16 scope?"
- "How was the lease term determined and who approved it?"
- "What discount rate was used and why?"
- "What payments were included in the liability and which were excluded?"
- "What event triggered this remeasurement and when was it approved?"
- "What is the ROU asset and lease liability balance and how did they move this period?"

These questions must be answerable from system data alone — without reference to external spreadsheets.

---

## Mandatory Human Validation Points

| Decision Point | Who Validates | Evidence Required |
|---------------|---------------|------------------|
| Lease identification (in/out of scope) | IFRS 16 Accountant | Written decision with paragraph reference |
| Exemption election (short-term / low-value) | IFRS 16 Accountant + Controller | Policy document |
| Lease term determination | IFRS 16 Accountant | Assessment memo |
| Discount rate (IBR) selection | IFRS 16 Accountant + Treasury (if applicable) | Rate support documentation |
| Modification classification | IFRS 16 Accountant | Modification analysis memo |
| Remeasurement trigger confirmation | IFRS 16 Accountant | Trigger event documentation |
| Disclosure pack sign-off | Controller | Review sign-off in system |
| Any accounting entry above materiality threshold | Controller | Dual approval in workflow |
