# Open Questions Register
**Version:** 2.0 | **Date:** 2026-03-26 | **Status:** Active — Maintained throughout all phases
**Updated by:** Project Governance Lead (reconciliation pass — Option B normalization)

> This is the **authoritative register of all unresolved architectural, accounting, and functional questions** for the RE-SAP IFRS 16 Addon project. Every open question must be registered here. Silent unresolved items are a governance violation (Rule OB-09).
>
> The `open-questions-register-check` hook validates that TBC items in specs and designs have a corresponding entry here with an owner and resolution path.

---

## Priority Levels
- **P0 — BLOCKER:** Cannot proceed with any design in the affected area until resolved
- **P1 — HIGH:** Must be resolved before Phase 1 implementation begins
- **P2 — MEDIUM:** Must be resolved before the affected feature is built
- **P3 — LOW:** Should be resolved; has a reasonable default assumption if unresolved

---

## Section A — Functional Questions (T0-01 / T0-02 Workshops)

These questions must be resolved in the accounting policy workshop (T0-01) and the blueprint workshop (T0-02).

### A.1 — Accounting Policy (T0-01)

| ID | Question | Priority | Blocks | Owner | Target Workshop | Status | ADR Candidate? |
|----|---------|----------|--------|-------|----------------|--------|----------------|
| OQ-ACC-01 | Is the IFRS 16 accounting policy formally signed off by the client? | P0 | All Phase 1 design | IFRS 16 Accountant | T0-01 | OPEN | ADR-004 (pending) |
| OQ-ACC-02 | Is linearization of stepped rents required (or optional) under the client's policy? | P1 | CD-03 valuation engine design | IFRS 16 Accountant | T0-01 | OPEN | No — policy election |
| OQ-ACC-03 | How is the Incremental Borrowing Rate (IBR) determined per company code / currency? | P0 | CD-03 / CD-04 / Phase 1 calculation | IFRS 16 Accountant + Treasury | T0-01 | OPEN | Yes — ADR candidate (discount rate governance) |
| OQ-ACC-04 | Is the REASONABLY CERTAIN threshold for renewal options defined in client policy? | P1 | CD-01 contract master / CD-03 lease term | IFRS 16 Accountant | T0-01 | OPEN | No — policy election |
| OQ-ACC-05 | Are initial direct costs (IDC) tracked and to be included in ROU calculation? | P1 | CD-03 ROU asset calculation | IFRS 16 Accountant | T0-01 | OPEN | No |
| OQ-ACC-06 | Is impairment of ROU assets in scope for this project? | P2 | CD-03 / CD-05 scope | IFRS 16 Accountant + Project Governance | T0-01 | OPEN | No — scope decision |
| OQ-ACC-07 | Is purchase option accounting (IFRS 16 para 20b) in scope? | P2 | CD-06 event engine scope | IFRS 16 Accountant | T0-01 | OPEN | No — scope decision |
| OQ-ACC-08 | Are multi-component leases in scope (lease + service components)? | P1 | CD-01 / CD-03 design | IFRS 16 Accountant | T0-01 | OPEN | No |

### A.2 — Contract Model and Coverage (T0-02)

| ID | Question | Priority | Blocks | Owner | Target Workshop | Status | ADR Candidate? |
|----|---------|----------|--------|-------|----------------|--------|----------------|
| OQ-CM-01 | What is the full list of contract types currently managed in the ECC solution (RE-FX + manual)? | P0 | CD-01 / CD-02 domain design | RE Contract Manager + T0-02 Workshop | T0-02 | OPEN | No |
| OQ-CM-02 | Are there contracts NOT in RE-FX today that would need to be onboarded into the new Z system? | P1 | Migration scope / CD-01 intake design | RE Contract Manager | T0-02 | OPEN | No |
| OQ-CM-03 | Is the payment-in-advance model (Poland) the only country-specific payment rule, or are there others? | P1 | CD-03 country-specific rules | Local Finance / RE Contract Manager | T0-02 | OPEN | No |
| OQ-CM-04 | What currencies are used across the lease portfolio? Are foreign currency contracts common? | P1 | CD-03 / CD-04 multi-currency design | RE Contract Manager / Finance Controller | T0-02 | OPEN | No |
| OQ-CM-05 | Are there RE-FX contract types used by the client that don't fit CD-01/CD-02 classification? | P0 | CD-01 / CD-02 domain design | T0-02 Workshop | T0-02 | OPEN | Yes — ADR candidate if new domain needed |
| OQ-CM-06 | What is the exact migration scope — how many contracts exist in RE-FX today that need to be migrated to Z tables? | P1 | Migration program design / Phase 0 gate | RE Contract Manager + SAP Functional Consultant | T0-02 | OPEN | No |
| OQ-CM-07 | What is the go-live strategy — big-bang migration or phased by company code? | P1 | Migration program design / cutover plan | Project Governance Lead | T0-02 | OPEN | Yes — ADR candidate (migration strategy) |
| OQ-CM-08 | Are there vehicle fleet leases with specific attributes not covered by current Z object model? | P2 | CD-02 lease object master design | RE Contract Manager | T0-02 | OPEN | No |
| OQ-CM-09 | Is the procurement/PO-to-contract pattern (CD-07) in scope for this project? | P1 | CD-07 scope / Phase 2 planning | Project Governance Lead | T0-02 | OPEN | No — scope decision |

### A.3 — UX and Workflow (T0-02 / UX Design Phase)

| ID | Question | Priority | Blocks | Owner | Target Workshop | Status | ADR Candidate? |
|----|---------|----------|--------|-------|----------------|--------|----------------|
| OQ-UX-01 | What data does the mass upload screen need to support? (Which contract fields are batchable?) | P1 | CD-01 mass intake design | RE Contract Manager + Lease Accountant | T0-02 / UX Design | OPEN | No |
| OQ-UX-02 | Is the Z workspace implemented as a classic SAP transaction (ALV-based) or a Fiori app for ECC? | P1 | CD-09 / all UI design | Project Governance Lead + IT | T0-03 | OPEN | Yes — ADR candidate (UI technology) |
| OQ-UX-03 | What approval workflow technology is preferred — SAP standard workflow or Z table-based? | P1 | CD-04 approval gate design | ABAP Architect + Project Governance | T0-04 | OPEN | Yes — ADR candidate (workflow technology) |

---

## Section B — Technical Questions (T0-03 / T0-04 Workshops)

These questions must be resolved in the technical landscape workshop (T0-03) and the FI/FI-AA integration workshop (T0-04).

### B.1 — FI / FI-AA Integration (T0-04)

| ID | Question | Priority | Blocks | Owner | Target Workshop | Status | ADR Candidate? |
|----|---------|----------|--------|-------|----------------|--------|----------------|
| OQ-FI-01 | What is the FI posting approach — main ledger only, or IFRS parallel ledger? | P0 | CD-04 accounting engine design | FI Architect + IFRS 16 Accountant | T0-04 | OPEN | ADR-003 (pending) |
| OQ-FI-02 | Which FI-GL BAPI / FM is confirmed available in the target ECC system for lease accounting documents? | P0 | CD-04 ABAP design | FI Architect + ABAP Architect | T0-04 | OPEN | No |
| OQ-FI-03 | Is document splitting active? What business area / segment splitting rules apply to lease accounting docs? | P1 | CD-04 posting design | FI Architect | T0-04 | OPEN | No |
| OQ-FI-04 | What is the reference field strategy for FI documents generated by the addon (XBLNR, BKTXT, ZUONR)? | P1 | CD-04 / CD-09 traceability design | FI Architect + ABAP Architect | T0-04 | OPEN | No |
| OQ-FI-05 | Which FI-AA BAPI is confirmed available for sub-asset creation linked to lease contracts? | P0 | CD-05 asset engine design | FI-AA Specialist + ABAP Architect | T0-04 | OPEN | No |
| OQ-FI-06 | What is the ROU asset class name/number in the client's FI-AA configuration? | P1 | CD-05 asset engine design | FI-AA Specialist | T0-04 | OPEN | No |
| OQ-FI-07 | How is ROU asset depreciation triggered — via standard FI-AA depreciation run or a Z-generated FI entry? | P1 | CD-05 asset engine design | FI-AA Specialist + ABAP Architect | T0-04 | OPEN | No |
| OQ-FI-08 | Are profit center ledger postings required for lease accounting entries? | P1 | CD-04 posting design | FI/CO Architect | T0-04 | OPEN | No |
| OQ-FI-09 | Is parallel ledger for local GAAP currently active? (GAP-C-01 from coverage matrix) | P1 | CD-04 multi-ledger design | FI Architect | T0-04 | OPEN | Yes — ADR candidate if parallel ledger active |
| OQ-FI-10 | Is FI-AP matching (vendor invoice reconciliation) in scope for Phase 1 or Phase 2? (GAP-A-01) | P1 | CD-04 scope / Phase 2 planning | Project Governance Lead | T0-04 | OPEN | No — scope decision |

### B.2 — ABAP / Technical Landscape (T0-03)

| ID | Question | Priority | Blocks | Owner | Target Workshop | Status | ADR Candidate? |
|----|---------|----------|--------|-------|----------------|--------|----------------|
| OQ-ABAP-01 | What is the confirmed Z namespace / package prefix for the project? | P0 | All Z object creation | ABAP Architect | T0-03 | OPEN | ADR-002 (pending confirmation) |
| OQ-ABAP-02 | Is SAP standard workflow active and licensed in the target system? | P1 | CD-04 approval gate / OQ-UX-03 | ABAP Architect + IT | T0-03 | OPEN | No |
| OQ-ABAP-03 | What parallelization approach is supported for period-end batch jobs? | P1 | CD-03 / CD-04 batch design | ABAP Architect | T0-03 | OPEN | No |
| OQ-ABAP-04 | Is SLG1 Application Log retention sufficient, or is a custom Z log table needed for long-term retention? | P2 | CD-09 audit design | ABAP Architect + IT | T0-03 | OPEN | ADR-003 (pending) |
| OQ-ABAP-05 | Are there existing Z authorization objects or custom auth framework rules that must be followed? | P1 | CD-04 / CD-09 authorization design | ABAP Architect + Security | T0-03 | OPEN | No |
| OQ-ABAP-06 | What is the ABAP version and EHP level in the target ECC system? | P0 | All Z development | ABAP Architect | T0-03 | OPEN | No |
| OQ-ABAP-07 | Are there SAP version constraints (EHP level, support pack) that could affect BAPI availability? | P1 | CD-04 / CD-05 BAPI selection | SAP Basis / ABAP Architect | T0-03 | OPEN | No |

---

## Section C — Orchestrator / Governance Questions (TBC-ORK)

These questions are governance-level and must be resolved by the Project Governance Lead before or during Phase 0.

| ID | Question | Priority | Blocks | Owner | Target Resolution | Status | ADR Candidate? |
|----|---------|----------|--------|-------|------------------|--------|----------------|
| TBC-ORK-01 | Are ADR-001 through ADR-005 formally approved by the Project Governance Lead? | P0 | All Phase 1 development | Project Governance Lead | Phase 0 gate (T0-07) | OPEN | N/A — these ARE the ADRs |
| TBC-ORK-02 | Is there any remaining RE-FX functionality that MUST be preserved as runtime integration (not migration)? | P0 | Option B compliance / OB-08 | SAP RE Functional Consultant | T0-02 | OPEN | Yes — ADR-006 amendment if any runtime RE-FX needed |
| TBC-ORK-03 | What is the formal project governance structure — who has authority to approve ADRs, scope changes, and phase gates? | P0 | All governance gates | Project Governance Lead | Project kickoff | OPEN | No — governance charter |
| TBC-ORK-04 | Is the IFRS 16 Accountant resource confirmed and available for Phase 0 workshops and ongoing approval tasks? | P0 | T0-01 / all accounting gates | Project Governance Lead | Project kickoff | OPEN | No |
| TBC-ORK-05 | Is the SAP RE Functional Consultant confirmed with detailed knowledge of the client's ECC configuration? | P0 | T0-02 / all functional design | Project Governance Lead | Project kickoff | OPEN | No |
| TBC-ORK-06 | Has data governance / legal review been initiated for AI service integration? | P1 | Phase 3 AI assistant / R-06 | Legal/DGO + Project Governance Lead | Phase 1 start | OPEN | No |
| TBC-ORK-07 | Will the client provide anonymized / synthetic SAP data for development and UAT? | P1 | All testing / A-17 | Project Governance Lead + Legal | T0-08 | OPEN | No |
| TBC-ORK-08 | What is the S/4HANA migration timeline? Does it affect the Phase 2/3 investment decision? | P2 | Phase 3 planning / R-05 | Project Governance Lead | Phase 0 gate | OPEN | No |
| TBC-ORK-09 | Is the disclosure pack export (GAP-A-02) confirmed as Phase 2 scope? | P1 | CD-09 Phase 2 planning | Project Governance Lead | T0-02 | OPEN | No — scope decision |
| TBC-ORK-10 | Are the critical path dependencies (D-PHASE-01 to D-PHASE-05) formally acknowledged and assigned? | P0 | Phase 0 gate / all phases | Project Governance Lead | Phase 0 gate | OPEN | No |

---

## Resolution Log (Closed Questions)

| ID | Question | Resolution | Date | ADR |
|----|---------|-----------|------|-----|
| OQ-ARCH-OPT-B | Should the Z addon replace RE-FX entirely or use RE-FX as backend? | **RESOLVED — Option B approved.** Z addon is the system of record. RE-FX not used at runtime. | 2026-03-26 | ADR-006 |

---

## ADR Candidates Summary

The following open questions have been identified as requiring a formal ADR when resolved:

| OQ ID | Topic | ADR Status |
|-------|-------|-----------|
| OQ-ACC-03 | Discount rate governance (IBR determination) | Candidate — create ADR-007 when resolved |
| OQ-CM-05 | New domain needed for unclassified contract types | Candidate — create ADR-008 if applicable |
| OQ-CM-07 | Migration strategy (big-bang vs. phased) | Candidate — create ADR-009 when resolved |
| OQ-UX-02 | UI technology (ALV vs. Fiori for ECC) | Candidate — create ADR-010 when resolved |
| OQ-UX-03 | Approval workflow technology | Candidate — create ADR-011 when resolved |
| OQ-FI-09 | Parallel ledger for local GAAP | Candidate — create ADR-012 if parallel ledger active |
| TBC-ORK-02 | RE-FX runtime integration exception (if any) | Candidate — ADR-006 amendment if applicable |

---

## Governance Rules for This Register

1. **Every TBC item in any spec or design document must have a corresponding entry here.**
2. **P0 questions must be resolved before Phase 1 design begins.** No exceptions.
3. **P1 questions must be resolved before the affected domain spec is approved.**
4. **Agents must not make assumptions to resolve P0 or P1 questions — escalate to human.**
5. **When a question is resolved, move it to the Resolution Log and cite the ADR or workshop output.**
6. **This file is checked by the `open-questions-register-check` hook at session end.**
7. **ADR candidates must be tracked and created when the question is resolved.**

---

## Cross-Reference Index

| OQ ID | Related ADR | Related Domain | Related Dependency |
|-------|------------|---------------|-------------------|
| OQ-ACC-01 | ADR-004 | CD-03, CD-04 | D-PHASE-01 (accounting policy) |
| OQ-ACC-03 | ADR-007 (candidate) | CD-03 | D-PHASE-03 (IBR process) |
| OQ-FI-01 | ADR-003 | CD-04 | D-PHASE-04 (FI integration) |
| OQ-ABAP-01 | ADR-002 | All | D-PHASE-02 (ABAP landscape) |
| OQ-ABAP-06 | ADR-001, ADR-005 | All | D-PHASE-02 |
| TBC-ORK-01 | ADR-001 to ADR-005 | All | D-PHASE-01 |
| TBC-ORK-02 | ADR-006 | All | D-PHASE-01 |
| TBC-ORK-10 | All ADRs | All | D-PHASE-01 to D-PHASE-05 |

---

*Traceability: specs/000-master-ifrs16-addon/requirements.md | docs/governance/decision-log.md — ADR-006 | Last updated: 2026-03-26 | Updated by: Project Governance Lead (reconciliation pass)*
