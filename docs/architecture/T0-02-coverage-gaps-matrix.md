# T0-02 Coverage Gaps Analysis Matrix
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** DRAFT — Ready for T0-02 Workshop | **Owner:** ECC Coverage Analyst

---

## Purpose

This matrix identifies any functional gaps between the current ECC solution and the Option B design. A gap exists when:
1. A capability exists in the current ECC solution but is NOT covered in Option B Phase 1, OR
2. A capability is deferred to Phase 2 or later, creating a temporary gap.

**Workshop Objective:** Identify all gaps, assess risk, and decide whether to:
- Include the capability in Phase 1 (increase scope)
- Defer to Phase 2 (accept temporary gap)
- Eliminate the capability (business decision)

---

## Gap Analysis

### Gap Category A: Capabilities Deferred to Phase 2

| Gap ID | Capability | Current State | Option B Phase 1 | Option B Phase 2 | Risk if Deferred | Mitigation | Decision |
|--------|-----------|---------------|-----------------|-----------------|-----------------|-----------|----------|
| GAP-A-01 | Vendor invoice matching (FI-AP integration) | FI-AP + RE-FX manual matching | Not included | Z posting log ↔ FI-AP read | Payment reconciliation manual; audit trail incomplete | Manual workaround in Phase 1; automate in Phase 2 | [HUMAN VALIDATION REQUIRED — T0-02] |
| GAP-A-02 | Disclosure pack export (Excel/PDF) | Manual Excel export | Z structured data only (no export) | Z export to Excel/PDF | Users must manually export data | Manual export in Phase 1; automate in Phase 2 | [HUMAN VALIDATION REQUIRED — T0-02] |
| GAP-A-03 | Procurement/PO-to-contract pattern | None (manual) | Not included | Z: PO-to-contract draft generation | New contracts require manual entry | Manual entry in Phase 1; automate in Phase 2 | [HUMAN VALIDATION REQUIRED — T0-02] |
| GAP-A-04 | Impairment of ROU assets | Not in current solution | Not included | Z: impairment flag + FI posting | ROU assets not impaired if needed | Defer to Phase 3; manual impairment in Phase 1 | [HUMAN VALIDATION REQUIRED — T0-02] |
| GAP-A-05 | Purchase option accounting | Not in current RE-FX solution | Included (CD-06 event) | N/A | N/A | Included in Phase 1 | ✓ COVERED |

**Summary:** 3 capabilities deferred to Phase 2 (GAP-A-01, A-02, A-03); 1 deferred to Phase 3 (GAP-A-04); 1 included in Phase 1 (GAP-A-05).

### Gap Category B: Capabilities NOT in Current ECC Solution (New Capabilities)

| Gap ID | Capability | Current State | Option B Phase 1 | Business Value | Priority | Decision |
|--------|-----------|---------------|-----------------|-----------------|----------|----------|
| GAP-B-01 | Mass contract creation (Excel/CSV upload) | Manual entry only | Z mass upload + guided UI | High — enables bulk onboarding | Must | ✓ INCLUDED |
| GAP-B-02 | Posting simulation (preview before posting) | Not available | Z simulation mode | High — prevents posting errors | Must | ✓ INCLUDED |
| GAP-B-03 | Contract-level amortization report | Only by asset class | Z per-contract amortization report | High — enables contract-level follow-up | Must | ✓ INCLUDED |
| GAP-B-04 | Audit evidence pack (per contract) | None | Z: events + calculations + FI docs | High — audit-ready evidence | Must | ✓ INCLUDED |
| GAP-B-05 | Period-end controls checklist | None | Z: pre-flight validation + exception list | High — prevents period-end errors | Must | ✓ INCLUDED |
| GAP-B-06 | Exception management dashboard | None | Z: errors, pending items, overdue reviews | Medium — operational visibility | Should | ✓ INCLUDED |

**Summary:** 6 new capabilities; all included in Phase 1.

### Gap Category C: Capabilities with Reduced Scope in Phase 1

| Gap ID | Capability | Current State | Option B Phase 1 | Scope Reduction | Risk | Mitigation | Decision |
|--------|-----------|---------------|-----------------|-----------------|------|-----------|----------|
| GAP-C-01 | Parallel ledger for local GAAP | RE-FX parallel ledger (if active) | Z posting engine: support multi-ledger (if configured) | Conditional — only if client has parallel ledger configured | If not configured: local GAAP not supported | Confirm parallel ledger setup in T0-04 | [HUMAN VALIDATION REQUIRED — T0-04] |
| GAP-C-02 | Country-specific rules (Poland) | Manual workaround | Z: country-specific valuation rule flag on company code | Systematic but requires configuration | If not configured: Poland contracts treated as standard | Confirm Poland rules in T0-02 | [HUMAN VALIDATION REQUIRED — T0-02] |
| GAP-C-03 | Linearization of stepped rents | RE-FX or manual | Z valuation: straight-line option (if elected) | Optional — only if accounting policy requires | If not elected: stepped rents not linearized | Confirm linearization requirement in T0-01 | [HUMAN VALIDATION REQUIRED — T0-01] |

**Summary:** 3 capabilities with conditional scope; all require policy/configuration confirmation.

### Gap Category D: Capabilities with Enhanced Scope in Phase 1

| Gap ID | Capability | Current State | Option B Phase 1 | Scope Enhancement | Benefit | Decision |
|--------|-----------|---------------|-----------------|------------------|---------|----------|
| GAP-D-01 | Contract lifecycle visibility | Scattered (RE-FX + manual) | Z: lifecycle status (Active / Rescinded / Exempt / Blocked) | Unified, filterable status | Users can filter to operationally relevant contracts | ✓ INCLUDED |
| GAP-D-02 | Modification event tracking | Manual spreadsheet | Z: non-destructive event journal with full history | Complete audit trail | All modifications traceable with before/after snapshots | ✓ INCLUDED |
| GAP-D-03 | Calculation explainability | None | Z: calculation explainer with inputs, rules, approver | Plain-language explanation | Users understand why calculation is correct | ✓ INCLUDED |
| GAP-D-04 | Error handling and recovery | Silent failures | Z: error log per contract + reprocessing queue | Proactive error management | Users can identify and fix errors without specialist support | ✓ INCLUDED |

**Summary:** 4 capabilities with enhanced scope; all included in Phase 1.

---

## Risk Assessment for Deferred Capabilities

### Risk Matrix

| Gap ID | Capability | Likelihood of Impact | Severity if Impacted | Overall Risk | Mitigation Strategy |
|--------|-----------|----------------------|----------------------|--------------|-------------------|
| GAP-A-01 | Vendor invoice matching | Medium | Medium | **MEDIUM** | Manual matching process documented; Phase 2 automation planned |
| GAP-A-02 | Disclosure pack export | Low | Low | **LOW** | Manual export via SQL/Excel; Phase 2 automation planned |
| GAP-A-03 | Procurement/PO-to-contract | Low | Low | **LOW** | Manual contract creation; Phase 2 automation planned |
| GAP-A-04 | Impairment of ROU assets | Low | Medium | **LOW-MEDIUM** | Manual impairment assessment; Phase 3 automation planned |

---

## Decisions Required in T0-02

| Decision | Options | Recommendation | Owner |
|----------|---------|-----------------|-------|
| **D-01:** Include GAP-A-01 (vendor invoice matching) in Phase 1? | (1) Include in Phase 1 (increase scope) (2) Defer to Phase 2 (accept gap) | Defer to Phase 2 — manual matching is acceptable for Phase 1 | Project Governance Lead |
| **D-02:** Include GAP-A-02 (disclosure export) in Phase 1? | (1) Include in Phase 1 (2) Defer to Phase 2 | Defer to Phase 2 — manual export is acceptable for Phase 1 | Project Governance Lead |
| **D-03:** Include GAP-A-03 (PO-to-contract) in Phase 1? | (1) Include in Phase 1 (2) Defer to Phase 2 | Defer to Phase 2 — manual entry is acceptable for Phase 1 | Project Governance Lead |
| **D-04:** Include GAP-A-04 (impairment) in Phase 1? | (1) Include in Phase 1 (2) Defer to Phase 3 | Defer to Phase 3 — impairment is not common in Phase 1 | IFRS 16 Accountant |
| **D-05:** Confirm parallel ledger scope (GAP-C-01)? | (1) Include if configured (2) Exclude from Phase 1 | Include if configured — confirm in T0-04 | FI Architect |
| **D-06:** Confirm Poland country rules (GAP-C-02)? | (1) Include in Phase 1 (2) Defer to Phase 2 | Include in Phase 1 — confirm rules in T0-02 | Local Finance User |
| **D-07:** Confirm linearization requirement (GAP-C-03)? | (1) Include in Phase 1 (2) Defer to Phase 2 | Include if required by policy — confirm in T0-01 | IFRS 16 Accountant |

---

## Coverage Summary After Gap Resolution

### Phase 1 Coverage (After T0-02 Decisions)

| Domain | Must | Should | Later | Total | Phase 1 % |
|--------|------|--------|-------|-------|-----------|
| CD-01 Contract Master | 14 | 2 | 0 | 16 | 100% |
| CD-02 Lease Object | 2 | 0 | 0 | 2 | 100% |
| CD-03 Valuation Engine | 12 | 3 | 1 | 16 | 100% |
| CD-04 Accounting Engine | 7 | 0 | 1 | 8 | 88% (GAP-A-01 deferred) |
| CD-05 Asset Engine | 2 | 0 | 0 | 2 | 100% |
| CD-06 Contract Events | 6 | 1 | 0 | 7 | 100% |
| CD-07 Procurement Integration | 0 | 4 | 0 | 4 | 0% (GAP-A-03 deferred) |
| CD-08 Reclassification | 3 | 0 | 0 | 3 | 100% |
| CD-09 Reporting & Audit | 7 | 2 | 1 | 10 | 90% (GAP-A-02 deferred) |
| **TOTAL** | **53** | **12** | **3** | **68** | **85% (Phase 1)** |

### Phase 2 Coverage (Planned)

| Deferred Capability | Domain | Planned Phase 2 Delivery |
|-------------------|--------|------------------------|
| Vendor invoice matching (GAP-A-01) | CD-04 | Q3 2026 |
| Disclosure pack export (GAP-A-02) | CD-09 | Q3 2026 |
| Procurement/PO-to-contract (GAP-A-03) | CD-07 | Q3 2026 |

### Phase 3 Coverage (Planned)

| Deferred Capability | Domain | Planned Phase 3 Delivery |
|-------------------|--------|------------------------|
| Impairment of ROU assets (GAP-A-04) | CD-03 | Q4 2026 |

---

## Approval and Sign-Off

This gap analysis is approved by:

| Role | Name | Signature | Date |
|------|------|-----------|------|
| ECC Coverage Analyst | _________________ | _________________ | _______ |
| Project Governance Lead | _________________ | _________________ | _______ |

---

**Document Status:** DRAFT — Ready for T0-02 Workshop
**Next Action:** Complete all [HUMAN VALIDATION REQUIRED] decisions and obtain sign-offs.
**Target Completion:** End of T0-02 Workshop

