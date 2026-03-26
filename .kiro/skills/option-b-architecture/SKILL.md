---
name: option-b-architecture
description: Validates that any design, spec, or technical proposal complies with Option B architectural constraints. Use whenever a design decision involves data storage, FI integration, contract processing, or lifecycle management to ensure RE-FX is not reintroduced as a dependency.
---

# Skill: Option B Architecture Validation

## Purpose
Prevent architectural drift back toward RE-FX dependency. Every design proposal touching contract data, FI integration, or lease lifecycle must be screened against Option B rules before being accepted.

## When to Use
- When reviewing a new Z table design
- When proposing an FI integration pattern
- When designing contract creation or modification flows
- When evaluating a data migration approach
- When the option-b-architecture-guard hook fires
- At every pipeline governance check (A10, B8, E3)

## Mandatory Inputs
1. The design proposal (table structure, flow diagram, or written description)
2. The capability domain(s) it targets (CD-01 to CD-09)

## Expected Outputs
1. PASS / FAIL assessment with specific rule references
2. For FAIL: specific violation identified + compliant alternative proposed
3. For PASS: confirmation with capability domain mapping

## Rules (from option-b-target-model.md)

| Rule | Check |
|------|-------|
| OB-01 | No Z table uses RECN*/VICNCOND* as FK at runtime |
| OB-02 | No design proposes RE-FX as source of contract truth |
| OB-03 | No FI document created via RE-FX accounting engine |
| OB-04 | Every feature maps to at least one of CD-01 to CD-09 |
| OB-05 | Contract data / valuation / posting / events are in separate domain tables |
| OB-06 | Contract changes use non-destructive event model |
| OB-07 | Every accounting output traceable to: source event + valuation run + inputs |
| OB-08 | All current ECC business functionality is preserved or explicitly deferred |
| OB-09 | No open question is silently ignored |

## Prohibited Design Patterns
Any of these phrases in a design proposal = automatic FAIL:
- "Read from RECN* at runtime"
- "Extension table on RE-FX contract"
- "RE-FX cash flow consumed by addon"
- "RE-FX modification triggers IFRS 16 recalculation"
- "RE-FX accounting engine generates the FI document"
- "RE-FX condition type determines payment classification"
- "FK to RE-FX object at runtime"

## Validation Checklist
- [ ] No runtime dependency on RE-FX tables identified
- [ ] FI-GL integration uses standard SAP FI BAPIs directly
- [ ] FI-AA integration uses standard SAP FI-AA BAPIs directly
- [ ] Contract data is stored exclusively in Z tables
- [ ] Event model is non-destructive (no overwrite of history)
- [ ] Every FI document carries Z contract ID and Z run ID
- [ ] Capability domain tag assigned (CD-01 to CD-09)
- [ ] Any open architecture questions registered in open-questions-register.md

## References
- `.kiro/steering/option-b-target-model.md` — rules OB-01 to OB-09
- `docs/architecture/option-b-architecture.md` — architecture overview
- `docs/governance/decision-log.md` — ADR-006
- Hook: `option-b-architecture-guard`
