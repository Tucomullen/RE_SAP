# Contract Event Engine Z — Requirements
**Version:** 0.1 | **Date:** 2026-03-26 | **Status:** Draft
**Capability Domain:** CD-06 — Contract Event Engine Z

> **Option B Compliance:** CD-06 is a fully autonomous Z event engine. All contract lifecycle events are stored in `ZRIF16_EVENTS` (Domain 5) as immutable records. RE-FX modification or extension functions are NOT used at runtime. IFRS 16 modification classification is driven by Z event data.

---

## Business Objective

Implement a non-destructive, immutable event model for all contract lifecycle changes. Every change to a lease contract is recorded as a discrete event with a before-snapshot and after-snapshot. Events drive downstream processing: IFRS 16 modification events trigger remeasurement (CD-03), events that affect the ROU asset trigger FI-AA updates (CD-05), and all events are fully auditable with a complete timeline per contract.

---

## Business Rationale

Under Option B, the contract event engine is the mechanism by which the "living" lease contract evolves over time. Instead of overwriting contract master data, changes are recorded as events — preserving the full history of every contract from inception to termination. This approach directly addresses the audit traceability requirement of IFRS 16 (complete history of modifications and their accounting impact) and operational pain points related to contract change visibility (PP-D, PP-J).

---

## In-Scope (v1)

- Event types: Extension, Shortening, Scope Increase (new ROU asset), Scope Decrease, Termination, Cost Center Reassignment, IBR Revision, Index Restatement
- Event creation transaction: recording a new event with before/after data snapshot
- Event sequence validation: blocking events that are out of sequence (e.g., extend after termination)
- IFRS 16 modification classification: requires explicit classification by Lease Accountant before event is confirmed
- Event immutability: events cannot be edited or deleted after confirmation
- Event-triggered actions: IFRS 16 modification events → trigger CD-03 remeasurement; termination events → trigger CD-05 retirement
- Contract event history view: full timeline per contract
- Administrative events (e.g., cost center reassignment): no IFRS 16 impact; do not trigger recalculation

---

## Out-of-Scope (v1)

- Automated event detection from source systems (CD-07 — specs/007-procurement-source-integration-z/)
- Reclassification events (CD-08 — specs/008-reclassification-engine-z/)
- Multi-step approval workflows for events (Phase 2 — Phase 1 uses single-level Lease Accountant confirmation)

---

## Actors

| Actor | Role |
|-------|------|
| RE Contract Manager | Records contract lifecycle events (extension, termination, scope change, administrative events) |
| Lease Accountant | Classifies IFRS 16 modification events; confirms or rejects proposed events |
| System (Z addon) | Validates event sequence; triggers downstream processing (CD-03, CD-05) on event confirmation |
| Finance Controller | Escalation approver for disputed modification classifications |
| Auditor | Read-only access to full event history per contract, before/after snapshots, IFRS 16 classification rationale |

---

## User Stories

| ID | Actor | Story | Acceptance Criteria | Pain Point | Domain |
|----|-------|-------|---------------------|------------|--------|
| US-EV-01 | RE Contract Manager | I can record a contract extension event with the new end date and see the resulting IFRS 16 impact | Given an active contract, when the manager records an extension event with a new end date, then the event is stored in `ZRIF16_EVENTS` with before-snapshot (old end date) and after-snapshot (new end date), the Lease Accountant is notified for IFRS 16 classification, and the contract status shows "Extension Pending Classification" | PP-J | CD-06 |
| US-EV-02 | RE Contract Manager | I cannot create events that are out of sequence (e.g., extend after termination) | Given a contract with status "Terminated", when the manager attempts to record an extension event, then the system blocks the action with an explicit message explaining why the event is not permitted in the current contract state | — | CD-06 |
| US-EV-03 | Lease Accountant | I can view the full event history of any contract, including all before/after snapshots | Given a contract with multiple events, when the accountant opens the contract event history, then a chronological timeline shows all events with: event type, event date, recorded by, before-snapshot, after-snapshot, IFRS 16 classification, and triggered processing actions | PP-D | CD-06 |
| US-EV-04 | System | When an IFRS 16 modification event is confirmed, a new valuation run is automatically initiated in CD-03 | Given a Lease Accountant confirms an IFRS 16 modification event with classification, when the confirmation is saved, then the system automatically creates a new CD-03 calculation run with the updated contract data and notifies the Lease Accountant that a new run is pending approval | — | CD-06 |
| US-EV-05 | RE Contract Manager | I can record a cost center reassignment without triggering a valuation recalculation | Given an active contract, when the manager records a cost center reassignment event, then the event is stored in `ZRIF16_EVENTS` as an administrative event type, the cost center is updated in `ZRIF16_CONTRACT`, and NO CD-03 calculation run is triggered | — | CD-06 |
| US-EV-06 | System | Events are immutable — once written they cannot be changed or deleted | Given a confirmed event exists in `ZRIF16_EVENTS`, when any user (including administrators) attempts to modify or delete the event, then the system blocks the action with an explicit message; correction is only possible by recording a new correcting event | — | CD-06 |

---

## Process Flow

**IFRS 16 Modification Event:**
1. RE Contract Manager opens a new event in the event recording transaction.
2. Manager selects event type (e.g., "Extension") and enters event details (new end date, effective date).
3. System validates event sequence against current contract status.
4. Before-snapshot is captured from `ZRIF16_CONTRACT` at time of recording.
5. Event stored in `ZRIF16_EVENTS` with status "Pending Classification".
6. Lease Accountant is notified (workflow notification or task list item).
7. Lease Accountant reviews event and classifies as IFRS 16 modification type (new lease / scope increase / other modification / no modification).
8. Accountant confirms the event with classification rationale.
9. Event status updated to "Confirmed"; after-snapshot written; `ZRIF16_CONTRACT` updated.
10. If IFRS 16 modification: CD-03 remeasurement run automatically created.
11. If termination: CD-05 retirement automatically triggered.

**Administrative Event:**
1. Manager records event (e.g., cost center reassignment).
2. System validates event type as "Administrative" — no IFRS 16 classification required.
3. Event confirmed immediately; contract master field updated.
4. No downstream CD-03 or CD-05 processing triggered.

---

## Edge Cases

- Event recorded on an Exempt contract: system warns; Lease Accountant must confirm whether the event changes the exemption assessment.
- Backdated event (effective date before today): system warns; requires explicit override with Finance Controller approval.
- Modification event where accountant classifies as "No IFRS 16 impact": event is confirmed; no CD-03 run is triggered; rationale is stored.
- Two simultaneous events recorded for the same contract: system serialises events; second event must wait until the first is fully confirmed and processed.
- Event sequence: extension event recorded while a previous extension is still "Pending Classification": system blocks; only one pending event per contract at a time.
- Termination event recorded and then a further event is attempted: system blocks all further events after termination is confirmed.

---

## Accounting Implications

- IFRS 16 para 44-46: Modification accounting — requires explicit classification: (a) new separate lease, (b) scope increase with proportionate increase in consideration, (c) all other modifications (remeasurement of existing lease). Classification is a Lease Accountant judgment — the system must capture and store the classification rationale.
- IFRS 16 para 40-43: Remeasurement events — changes in lease term, changes in amounts payable, reassessment of purchase options. These trigger remeasurement of the liability and ROU asset.
- Administrative events (cost center, vendor data) have no IFRS 16 accounting impact and must be clearly distinguished from modification events.

---

## Integration Implications

- CD-01 (Contract Master): `ZRIF16_CONTRACT` is updated by confirmed events; status field and key data fields reflect the latest confirmed event state.
- CD-03 (Valuation Engine): IFRS 16 modification events trigger automatic creation of a new remeasurement run.
- CD-05 (FI-AA Asset Engine): Termination and scope change events trigger FI-AA retirement or update.
- CD-09 (Reporting): Event history is displayed in audit evidence packs (US-RA-04).

---

## UX Implications

- Contract event history must be a clear chronological timeline — not a flat table. Each event should be expandable to show before/after snapshot.
- IFRS 16 modification classification must be a required, guided step — with descriptive options (not just a code) and a mandatory rationale text field.
- Pending events must be visible on the contract status display (PP-D pattern).
- Administrative events must be visually distinguished from IFRS 16 modification events in the timeline.
- All Z transactions must use message class `ZRIF16_MSGS` for multilingual support (PP-M).

---

## Dependencies

- CD-01 (Contract Master): `ZRIF16_CONTRACT` schema — event before/after snapshot fields must be defined.
- CD-03 (Valuation Engine): API for triggering remeasurement runs from event engine.
- CD-05 (FI-AA Asset Engine): API for triggering asset retirement and useful life update from event engine.
- IFRS 16 Accountant: Must define the complete list of event types and their IFRS 16 classification rules before Phase 2 build.

---

## Open Questions

| ID | Question | Impact | Owner |
|----|----------|--------|-------|
| OQ-EV-01 | What is the complete taxonomy of event types required for the portfolio? (Including country-specific events) | Event type configuration table design | SAP RE Functional Consultant + IFRS 16 Accountant |
| OQ-EV-02 | Is a multi-level approval workflow required for modification events in Phase 2, or is Lease Accountant single confirmation sufficient for Phase 1? | Workflow design for events | Finance Controller + Project Governance Lead |
| OQ-EV-03 | How are backdated events (prior-period corrections) handled under IFRS 16? (Restatement vs. prospective correction) | Backdating rules and accounting impact | IFRS 16 Accountant |
| OQ-EV-04 | Is there a requirement to record events in bulk (e.g., portfolio-wide index restatement)? | Mass event processing design | IFRS 16 Accountant + RE Contract Manager |

---

## Design Risks

- **Risk:** Event type taxonomy defined too narrowly → new event types required post-Phase 1 build. Mitigation: collect full portfolio event type list in Phase 0 from RE Contract Managers.
- **Risk:** IFRS 16 modification classification not validated by Lease Accountant before CD-03 is triggered → wrong remeasurement accounting. Mitigation: classification is a mandatory step in the event confirmation flow; system blocks if classification is missing.
- **Risk:** Event immutability not enforced at database level → events modified via direct table access. Mitigation: table is write-protected at ABAP level; change document tracks any admin-level changes; audit report flags inconsistencies.
