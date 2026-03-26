---
name: contract-event-modeling
description: Defines the non-destructive event model for all lease contract lifecycle changes. Use when designing any contract modification, extension, termination, or reassessment logic under CD-06.
---

# Skill: Contract Event Modeling (Non-Destructive Lifecycle)

## Purpose
Ensure every change to a lease contract is captured as an immutable event — never overwriting history. This skill enforces Option B Rule OB-06 and enables full lifecycle traceability.

## When to Use
- When designing any contract change flow (modification, extension, termination, novation)
- When classifying an IFRS 16 modification vs. non-modification event
- When designing the event sequencing validation
- When the contract-lifecycle-integrity-check hook fires

## Mandatory Inputs
1. Change description (what is changing on the contract)
2. Effective date of the change
3. Current contract status
4. IFRS 16 modification classification (requires human accounting validation)

## Expected Outputs
1. Event type classification (from standard event type list)
2. Before/after snapshot structure
3. IFRS 16 modification assessment (modification = new calc run required / non-modification = no recalc)
4. Downstream trigger: does this event trigger a CD-03 recalculation? Which type?
5. ZRIF16_EVENT row structure
6. ZRIF16_EVENT_SNAP rows (before and after)

## Event Classification Decision Tree

```
Is the lease term changing?
  → YES: Is it an extension that is reasonably certain? → IFRS 16 remeasurement → MODIFIED event
  → NO: Is the payment amount changing?
    → YES: Is it indexed to a rate/index? → IFRS 16 remeasurement → MODIFIED event
    → YES: Is it a contractual rent step? → UPDATE payment schedule → PAYMENT_CHANGED event (may or may not remeasure — confirm with accountant)
    → NO: Is the cost center changing?
      → YES: CC_CHANGED event (no remeasurement, no new calc run)
      → NO: Is the lessor changing?
        → YES: NOVATED event (confirm with accountant if remeasurement required)
        → Other: classify by event type list
```

## Event Sequencing Rules
- A TERMINATED contract cannot be EXTENDED
- A TERMINATED_EARLY contract cannot receive PAYMENT_CHANGED
- An EXPIRED contract cannot be MODIFIED
- Extensions must be processed before the original end date (PP-J guard)
- Multiple events on the same contract on the same day: sequence by event ID (auto-incremented)

## Immutability Rules (OB-06)
- Events written to ZRIF16_EVENT are NEVER updated or deleted
- If an event was entered incorrectly, a CORRECTION event is created that references the original
- The system always shows the effective state as of a given date by replaying events in sequence

## IFRS 16 Modification Classification
ALWAYS flag modification type as requiring human accounting validation (IFRS 16 Accountant). Never auto-classify without confirmation gate.

Key rules (IFRS 16.44-46):
- Lease modification = change in scope or consideration NOT contemplated in original terms
- Modification that increases scope AND increases consideration = separate lease (new contract in Z, original continues)
- All other modifications = remeasure existing lease (new calculation run from modification date)

## Validation Checklist
- [ ] Event type assigned from standard list
- [ ] Before/after snapshot fields populated
- [ ] IFRS 16 modification classification flagged for human validation (if applicable)
- [ ] Downstream recalculation trigger confirmed (yes/no + type)
- [ ] Event sequencing validation passes (contract state allows this event)
- [ ] ZRIF16_EVENT row structure complies with domain 5 design
- [ ] If modification: new ZRIF16_CALC_RUN linked to this event

## Anti-Patterns
- ❌ Updating the contract master record directly without creating an event
- ❌ Auto-classifying IFRS 16 modifications without human validation
- ❌ Allowing event sequence violations
- ❌ Creating a new calculation run without linking it to the triggering event

## References
- `docs/architecture/domain-data-model.md` — Domain 5 (Contract Events)
- `.kiro/steering/ifrs16-domain.md` — IFRS 16 modification rules
- `.kiro/steering/option-b-target-model.md` — OB-06
- Agent: `contract-event-architect`
- Skill: `ifrs16-remeasurement` — for the calculation side of modifications
