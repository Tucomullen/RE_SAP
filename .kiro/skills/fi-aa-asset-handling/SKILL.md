---
name: fi-aa-asset-handling
description: Defines the FI-AA ROU asset management patterns for the Z addon. Use when designing ROU asset creation, depreciation activation, derecognition, or any FI-AA integration under CD-05.
---

# Skill: FI-AA ROU Asset Handling (Option B — Direct FI-AA BAPI)

## Purpose
Ensure all FI-AA ROU asset operations in the Z addon are correctly structured, traceable, and use standard FI-AA BAPIs directly — no RE-FX FI-AA integration path.

## When to Use
- When designing ROU asset creation logic (CD-05)
- When specifying depreciation activation patterns
- When designing termination / derecognition flows
- When reviewing the Z contract ↔ FI-AA asset number mapping

## Mandatory Inputs
1. Confirmed FI-AA BAPI names [TO BE CONFIRMED at T0-04]
2. ROU asset class number(s) [TO BE CONFIRMED — client FI-AA config]
3. Asset class ↔ Z lease object category mapping (ZRIF16_ASSET_CLS config)

## ROU Asset Lifecycle Patterns

### Pattern 1: Initial Asset Creation
- **Trigger:** Initial recognition approval (after ZRIF16_CALC_ITEM approved)
- **BAPI:** [TO BE CONFIRMED — BAPI_FIXEDASSET_CREATE1 or equivalent]
- **Asset class:** From ZRIF16_ASSET_CLS (Z lease object category → asset class)
- **Useful life:** Derived from Z contract lease term (days)
- **Depreciation key:** Straight-line (confirmed per asset class — [TO BE CONFIRMED])
- **Output:** FI-AA asset number stored in ZRIF16_INTG_REF (ref type = FI_ASSET)

### Pattern 2: Depreciation Activation
- **Trigger:** Day following initial recognition posting
- **Method:** Activate via FI-AA depreciation run or direct FI posting [TO BE CONFIRMED — OQ-FI-07]
- **Linked to:** ZRIF16_INTG_REF entry (contract ↔ asset)

### Pattern 3: Useful Life Update (Remeasurement)
- **Trigger:** CD-06 modification event + new calculation run
- **Action:** Update asset useful life in FI-AA to match new lease term
- **BAPI:** [TO BE CONFIRMED — BAPI_FIXEDASSET_CHANGE or equivalent]
- **Log:** Update ZRIF16_INTG_REF with updated asset details

### Pattern 4: Asset Retirement (Termination)
- **Trigger:** CD-06 TERMINATED_EARLY or EXPIRED event
- **Action:** Retire asset in FI-AA for net book value amount
- **BAPI:** [TO BE CONFIRMED]
- **FI impact:** DR Accumulated Depreciation + DR/CR Gain/Loss / CR ROU Asset gross

## Validation Checklist
- [ ] FI-AA BAPI names confirmed [OQ-FI-05]
- [ ] ROU asset class configured in client system [OQ-FI-06]
- [ ] ZRIF16_INTG_REF populated on every asset creation
- [ ] Depreciation method confirmed [OQ-FI-07]
- [ ] Partial retirement scenario analyzed for scope reductions

## Anti-Patterns
- ❌ Manual FI-AA transactions to create/modify ROU assets (Z addon is the only path)
- ❌ Hardcoding asset class numbers in ABAP (always use ZRIF16_ASSET_CLS)
- ❌ Creating an asset without writing to ZRIF16_INTG_REF
- ❌ Using RE-FX FI-AA integration path

## References
- `.kiro/steering/ecc-integration-boundaries.md` — FI-AA integration table
- `docs/architecture/domain-data-model.md` — Domain 5 + Domain 6
- `docs/architecture/open-questions-register.md` — OQ-FI-05, OQ-FI-06, OQ-FI-07
- Agent: `fi-aa-integration-architect`
