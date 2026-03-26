---
name: ecc-coverage-preservation
description: Analyzes current SAP ECC / RE-FX business functionality to extract business requirements and verify their coverage in the Option B Z addon design. Use when reviewing functional coverage, migration scope, or when a new feature is proposed that might conflict with existing ECC behavior.
---

# Skill: ECC Coverage Preservation

## Purpose
Ensure that every piece of business value delivered by the current SAP ECC solution (RE-FX module + manual processes + existing Z programs) is explicitly captured in the Option B Z addon design. Prevent silent loss of critical functionality during the transition from RE-FX to standalone Z system.

## When to Use
- When a new feature or domain design is proposed — check what the current ECC equivalent does
- When reviewing the functional coverage matrix for completeness
- When preparing for Phase 0 gate review (T0-02 revised workshop)
- When a business stakeholder raises a concern about missing functionality
- When the migration-coverage-reviewer agent runs a governance gate review

## Mandatory Inputs
1. Functional area under review (e.g., "contract date management", "payment schedule", "reclassification")
2. Current ECC behavior description (from RE-FX documentation or business stakeholder input)
3. Option B design proposal for this area (domain spec, domain data model section)

## Expected Outputs
1. Coverage assessment table: business requirement → Option B coverage → status → gap/improvement
2. List of open questions for business stakeholders
3. List of items to register in functional-coverage-matrix.md
4. List of items to register in open-questions-register.md (with priority P0-P3)

## Rules

### Rule 1: Separate Business Requirement from Technical Implementation
Always distinguish:
- **Business requirement:** What the business NEEDS (e.g., "track whether a payment is in advance")
- **RE-FX implementation:** How RE-FX currently implements it (e.g., "condition purpose flag")
- **Option B proposal:** How Z will implement it (e.g., "explicit boolean field on Z payment schedule")

Never reject a business requirement because RE-FX implemented it in a specific way. The RE-FX implementation is irrelevant — the business need is what matters.

### Rule 2: Coverage Status Definitions
- **COVERED:** Option B design explicitly addresses this requirement. Reference domain spec section.
- **PARTIALLY COVERED:** Design addresses core need but known edge cases are missing. Document the gaps.
- **GAP:** No current Option B design covers this. Must be resolved or explicitly deferred via ADR.
- **DEFERRED:** Governance decision to defer to later phase. Must cite ADR or governance meeting output.
- **NEW CAPABILITY:** Option B can deliver something the current ECC solution cannot. Flag as improvement opportunity.

### Rule 3: Never Propose RE-FX as the Solution
If current ECC behavior relies on a RE-FX feature, do not propose "read from RE-FX" as the coverage solution. Always propose the Z-native equivalent.

### Rule 4: Accounting Policy Rules Must Be Validated
If the current ECC implementation reflects an accounting policy decision (not just a system configuration), flag it for IFRS 16 Accountant validation before recording as a coverage requirement.

### Rule 5: Country-Specific Rules
When analyzing current ECC behavior, check for country-specific variants (especially: Poland advance payments, specific local GAAP requirements). Register each as a separate coverage item.

## Anti-Patterns
- ❌ "RE-FX handles this so we don't need to design it" — RE-FX is not part of Option B
- ❌ "The business doesn't need this because RE-FX doesn't support it cleanly" — Z can do better
- ❌ Conflating RE-FX configuration with business requirements
- ❌ Marking items as 'Covered' without a specific domain spec reference
- ❌ Registering open questions without a priority level and owner

## Validation Checklist
Before closing a coverage review session:
- [ ] Every Must item in the reviewed area has a Coverage Status
- [ ] Every Gap has been registered in functional-coverage-matrix.md
- [ ] Every open question has been registered in open-questions-register.md with P0-P3 priority
- [ ] Every deferred item has a referenced ADR or governance decision
- [ ] No RE-FX runtime dependency has been proposed as coverage solution
- [ ] Accounting policy items have human validation flags

## References
- `docs/architecture/functional-coverage-matrix.md` — the master coverage register
- `docs/architecture/open-questions-register.md` — open questions register
- `docs/architecture/option-b-architecture.md` — 9 capability domains
- `.kiro/steering/option-b-target-model.md` — Option B mandate (OB-08)
- `docs/governance/decision-log.md` — ADR-006 and deferred decisions
