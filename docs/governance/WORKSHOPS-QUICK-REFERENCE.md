# Workshops Quick Reference Guide
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** READY FOR USE | **Owner:** Project Governance Lead

---

## Quick Navigation

### T0-01 Workshop: Accounting Policy (IFRS 16)
**When:** 2026-04-XX (1–2 days)
**Where:** [Location TBC]
**Who:** IFRS 16 Accountant, Finance Controller, Lease Accountant, Treasury (if applicable)

**Main Documents:**
1. `docs/governance/T0-01-accounting-policy-template.md` — Template to complete
2. `docs/governance/T0-01-accounting-policy-decision-matrix.md` — Decision matrix to fill

**Key Questions to Answer:**
- OQ-ACC-01: Is the IFRS 16 accounting policy formally signed off?
- OQ-ACC-02: Is linearization of stepped rents required?
- OQ-ACC-03: How is the IBR determined per company code / currency?
- OQ-ACC-04: What is the REASONABLY CERTAIN threshold for renewal options?
- OQ-ACC-05: Are initial direct costs (IDC) tracked and included in ROU?

**Deliverables:**
- ✓ Completed accounting policy document (signed)
- ✓ Completed decision matrix (all cells filled)
- ✓ Approval sign-offs

**Success Criteria:**
- All [HUMAN VALIDATION REQUIRED] sections completed
- All decisions documented with IFRS 16 paragraph references
- Signed by IFRS 16 Accountant and Finance Controller

---

### T0-02 Workshop: Blueprint & Coverage (Option B)
**When:** 2026-04-XX (1–2 days)
**Where:** [Location TBC]
**Who:** SAP RE Functional Consultant, ABAP Architect, Project Governance Lead, ECC Coverage Analyst

**Main Documents:**
1. `docs/architecture/T0-02-option-b-blueprint.md` — Blueprint to complete
2. `docs/architecture/T0-02-coverage-gaps-matrix.md` — Gaps to assess

**Key Questions to Answer:**
- OQ-COV-01: Are there RE-FX contract types that don't fit CD-01/CD-02?
- OQ-COV-02: Is linearization required by accounting policy?
- OQ-COV-03: Is FI-AP matching in Phase 1 or Phase 2?
- OQ-COV-04: Are initial direct costs tracked in current ECC?
- OQ-COV-05: Is Poland advance payment the only country-specific rule?
- OQ-COV-06: Is parallel ledger for local GAAP currently active?
- OQ-COV-07: Is procurement/PO-to-contract pattern in scope?
- OQ-COV-08: Are there vehicle fleet leases with specific attributes?

**Gap Decisions to Make:**
- GAP-A-01: Include vendor invoice matching in Phase 1? → Recommend: Defer to Phase 2
- GAP-A-02: Include disclosure export in Phase 1? → Recommend: Defer to Phase 2
- GAP-A-03: Include PO-to-contract in Phase 1? → Recommend: Defer to Phase 2
- GAP-A-04: Include impairment in Phase 1? → Recommend: Defer to Phase 3

**Deliverables:**
- ✓ Completed Option B blueprint (signed)
- ✓ Completed coverage gaps matrix (all gaps assessed)
- ✓ Migration strategy (if applicable)
- ✓ Approval sign-offs

**Success Criteria:**
- All coverage questions answered
- All gaps assessed and decisions made
- Migration strategy confirmed (if applicable)
- Signed by SAP RE Functional Consultant, ABAP Architect, Project Governance Lead

---

## The 9 Capability Domains (CD-01 to CD-09)

| Domain | ID | What It Does | Replaces | Phase 1 Coverage |
|--------|----|----|----------|-----------------|
| Contract Master Z | CD-01 | Full lease contract master data | RECN* / VICNCOND in RE-FX | 100% |
| Lease Object Master Z | CD-02 | Classification and description of leased asset | RE-FX object hierarchy | 100% |
| Valuation Engine Z | CD-03 | All IFRS 16 calculations | RE-FX valuation + manual spreadsheets | 100% |
| Accounting Engine Z (FI-GL) | CD-04 | All FI-GL document creation | RE-FX accounting + manual FI postings | 88% (GAP-A-01 deferred) |
| Asset Engine Z (FI-AA) | CD-05 | ROU asset lifecycle | RE-FX FI-AA integration | 100% |
| Contract Event Engine Z | CD-06 | Non-destructive contract lifecycle | RE-FX contract amendment history | 100% |
| Procurement / Source Integration Z | CD-07 | PO-to-contract pattern | None (new capability) | 0% (Phase 2) |
| Reclassification Engine Z | CD-08 | Current/non-current liability reclassification | ZRE009 / RE-FX reclassification | 100% |
| Reporting & Audit Z | CD-09 | All reporting, rollforward, reconciliation | RE-FX reports + manual disclosure | 90% (GAP-A-02 deferred) |

---

## Critical Decisions Summary

### Already Approved
- **ADR-006:** Option B — Z addon replaces RE-FX as system of record ✓ ACCEPTED (2026-03-26)

### Pending Approval (ADR-001 to ADR-005)
| ADR | Title | Owner | Target Approval |
|-----|-------|-------|-----------------|
| ADR-001 | ABAP OO Mandate | ABAP Architect | T0-03 |
| ADR-002 | Z Naming Convention | ABAP Architect | T0-03 |
| ADR-003 | Application Logging (SLG1 + ZRIF16_AUDIT) | ABAP Architect | T0-03 |
| ADR-004 | Human Approval Gate Before FI Posting | Project Governance Lead | T0-02 |
| ADR-005 | S/4HANA Compatibility by Design | ABAP Architect | T0-03 |

### Accounting Policy Decisions (T0-01)
| Decision | IFRS 16 Para | Owner | Status |
|----------|-------------|-------|--------|
| Lease identification criteria | ¶9–11 | IFRS 16 Accountant | OPEN |
| Short-term exemption | ¶5(a) | IFRS 16 Accountant | OPEN |
| Low-value exemption | ¶5(b) | IFRS 16 Accountant | OPEN |
| Lease term (renewal options) | ¶19–24 | IFRS 16 Accountant | OPEN |
| Lease term (termination options) | ¶19–24 | IFRS 16 Accountant | OPEN |
| Discount rate (implicit vs. IBR) | ¶26 | IFRS 16 Accountant | OPEN |
| IBR determination method | ¶26 | IFRS 16 Accountant + Treasury | OPEN |
| Lease payments (fixed) | ¶27 | IFRS 16 Accountant | OPEN |
| Lease payments (index-based variable) | ¶27–29 | IFRS 16 Accountant | OPEN |
| Lease payments (non-index variable) | ¶27–29 | IFRS 16 Accountant | OPEN |
| Initial direct costs (IDC) | ¶24 | IFRS 16 Accountant | OPEN |
| Linearization of stepped rents | ¶27–29 | IFRS 16 Accountant | OPEN |
| Modifications (separate lease criteria) | ¶44–46 | IFRS 16 Accountant | OPEN |
| Remeasurement triggers | ¶19–24, ¶27–29 | IFRS 16 Accountant | OPEN |
| Derecognition | ¶54–55 | IFRS 16 Accountant | OPEN |
| Country-specific rules (Poland) | ¶24 | IFRS 16 Accountant | OPEN |

---

## Open Questions by Workshop

### T0-01 Workshop (Accounting Policy)
**OQ-ACC-01 to OQ-ACC-05** — All accounting policy questions
- Formal policy sign-off
- Linearization requirement
- IBR determination
- REASONABLY CERTAIN threshold
- Initial direct costs tracking

### T0-02 Workshop (Blueprint & Coverage)
**OQ-COV-01 to OQ-COV-08** — All coverage questions
- RE-FX contract types
- Linearization requirement (from T0-01)
- FI-AP matching scope
- Initial direct costs tracking (from T0-01)
- Poland country-specific rules
- Parallel ledger for local GAAP
- Procurement/PO-to-contract scope
- Vehicle fleet lease attributes

### T0-03 Workshop (ABAP Architecture)
**Technical decisions** — ABAP, naming, logging, S/4 compatibility
- ABAP OO mandate (ADR-001)
- Z naming convention (ADR-002)
- Application logging (ADR-003)
- S/4HANA compatibility (ADR-005)
- Approval workflow technology
- Z namespace confirmation
- ABAP version confirmation

### T0-04 Workshop (FI Integration)
**FI decisions** — Posting approach, FI-AA integration, parallel ledger
- FI-GL posting approach (main ledger vs. parallel)
- FI-AA ROU asset creation method
- Parallel ledger for local GAAP (if applicable)

---

## Pre-Workshop Checklist

### Before T0-01 Workshop
- [ ] IFRS 16 Accountant reviews accounting policy template
- [ ] Finance Controller reviews accounting policy template
- [ ] Treasury prepares IBR determination method proposal
- [ ] Lease Accountant prepares list of current contract types
- [ ] All participants review OQ-ACC-01 to OQ-ACC-05
- [ ] Meeting room booked (1–2 days)
- [ ] Laptops/projector available for document editing

### Before T0-02 Workshop
- [ ] SAP RE Functional Consultant reviews Option B blueprint
- [ ] ABAP Architect reviews Option B blueprint
- [ ] ECC Coverage Analyst prepares coverage analysis
- [ ] RE Contract Manager prepares list of current contract types
- [ ] All participants review OQ-COV-01 to OQ-COV-08
- [ ] Meeting room booked (1–2 days)
- [ ] Laptops/projector available for document editing

---

## Document Editing During Workshops

### How to Complete Documents

**Accounting Policy Template (T0-01):**
1. Open `docs/governance/T0-01-accounting-policy-template.md`
2. Find all `[HUMAN VALIDATION REQUIRED]` sections
3. Replace with actual decisions and rationale
4. Obtain signatures at end of workshop

**Accounting Policy Decision Matrix (T0-01):**
1. Open `docs/governance/T0-01-accounting-policy-decision-matrix.md`
2. Fill in "Proposed Decision" column for each decision
3. Verify "Impact on CD-03" and "Impact on CD-04" are correct
4. Obtain signatures at end of workshop

**Option B Blueprint (T0-02):**
1. Open `docs/architecture/T0-02-option-b-blueprint.md`
2. Find all `[HUMAN VALIDATION REQUIRED]` sections
3. Replace with actual answers to coverage questions
4. Confirm migration strategy (if applicable)
5. Obtain signatures at end of workshop

**Coverage Gaps Matrix (T0-02):**
1. Open `docs/architecture/T0-02-coverage-gaps-matrix.md`
2. For each gap (GAP-A-01 to GAP-C-03), decide: Include / Defer / Eliminate
3. Document decision and rationale
4. Obtain signatures at end of workshop

---

## Approval Sign-Off Process

### Step 1: Document Completion
- All [HUMAN VALIDATION REQUIRED] sections completed
- All decisions documented with rationale
- All open questions answered

### Step 2: Review
- Participants review completed document
- Clarifications made as needed
- Final version agreed

### Step 3: Sign-Off
- Authorized signatories sign the document
- Signatures recorded with date
- Document marked as APPROVED

### Step 4: Publication
- Approved document published to knowledge base
- Open questions register updated
- Next workshop scheduled (if applicable)

---

## Key Contacts

| Role | Name | Email | Phone |
|------|------|-------|-------|
| Project Governance Lead | [TBC] | [TBC] | [TBC] |
| IFRS 16 Accountant | [TBC] | [TBC] | [TBC] |
| Finance Controller | [TBC] | [TBC] | [TBC] |
| SAP RE Functional Consultant | [TBC] | [TBC] | [TBC] |
| ABAP Architect | [TBC] | [TBC] | [TBC] |
| FI Architect | [TBC] | [TBC] | [TBC] |
| ECC Coverage Analyst | [TBC] | [TBC] | [TBC] |

---

## Escalation Path

**If a decision cannot be made in the workshop:**
1. Document the issue and why it cannot be decided
2. Identify the missing information or stakeholder
3. Assign an owner to resolve the issue
4. Set a target resolution date
5. Add to open-questions-register.md
6. Schedule follow-up meeting to finalize decision

**If a blocker is identified:**
1. Immediately escalate to Project Governance Lead
2. Document the blocker and its impact
3. Identify mitigation options
4. Decide: Resolve now / Defer / Accept risk
5. Document decision in risk register

---

## Success Metrics

### T0-01 Workshop Success
- ✓ All 22 accounting policy decisions documented
- ✓ All OQ-ACC-01 to OQ-ACC-05 questions resolved
- ✓ Accounting policy document signed
- ✓ No [HUMAN VALIDATION REQUIRED] items remaining
- ✓ No [TO BE CONFIRMED] items without owner and date

### T0-02 Workshop Success
- ✓ All 8 coverage questions answered
- ✓ All 7 gaps assessed and decisions made
- ✓ Migration strategy confirmed (if applicable)
- ✓ Option B blueprint signed
- ✓ No open questions remaining

### Phase 0 Gate Success
- ✓ All 28 critical decisions approved
- ✓ All ADRs (ADR-001 to ADR-005) approved
- ✓ All accounting policy decisions approved
- ✓ All coverage decisions approved
- ✓ Phase 0 gate sign-off obtained

---

## Useful Links

| Document | Location |
|----------|----------|
| Accounting Policy Template | `docs/governance/T0-01-accounting-policy-template.md` |
| Accounting Policy Decision Matrix | `docs/governance/T0-01-accounting-policy-decision-matrix.md` |
| Option B Blueprint | `docs/architecture/T0-02-option-b-blueprint.md` |
| Coverage Gaps Matrix | `docs/architecture/T0-02-coverage-gaps-matrix.md` |
| Complete ADRs | `docs/governance/ADR-001-to-ADR-005-complete.md` |
| Critical Decisions Matrix | `docs/governance/critical-decisions-matrix.md` |
| Executive Summary | `docs/governance/WORKSHOPS-T0-01-T0-02-EXECUTIVE-SUMMARY.md` |
| Open Questions Register | `docs/architecture/open-questions-register.md` |
| Decision Log | `docs/governance/decision-log.md` |
| Option B Architecture | `docs/architecture/option-b-architecture.md` |
| Functional Coverage Matrix | `docs/architecture/functional-coverage-matrix.md` |

---

## Tips for Workshop Facilitators

1. **Start with context:** Begin each workshop by reviewing the Option B architecture and why these decisions matter.
2. **Use the matrices:** Matrices are designed to be filled collaboratively; use them as the primary working document.
3. **Document rationale:** Every decision should include the "why" — not just the "what."
4. **Escalate early:** If a decision cannot be made, escalate immediately rather than guessing.
5. **Get sign-offs:** Don't leave the workshop without signatures on completed documents.
6. **Publish immediately:** Approved documents should be published to the knowledge base within 24 hours.
7. **Update registers:** Update open-questions-register.md and decision-log.md immediately after workshop.

---

**Document Status:** READY FOR USE
**Last Updated:** 2026-03-26
**Next Update:** After each workshop completion

