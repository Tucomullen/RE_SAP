---
name: sap-re-object-mapping
description: >-
  Map an IFRS 16 functional requirement to SAP RE/RE-FX objects, identify data gaps, define required Z extensions, and produce a structured mapping document for ABAP Architect review.
---

# Skill: SAP RE Object Mapping

## Title
SAP RE/RE-FX Object Mapping — Functional Requirement to SAP Process, Data, and Z Extension

## Description
This skill maps a specific IFRS 16 functional requirement to the relevant SAP RE/RE-FX objects, standard data sources, process touchpoints, and required Z extensions. It produces a structured mapping document that the ABAP Architect and Functional Consultant can use to design and implement the corresponding Z addon components.

## When to Use
- When a new IFRS 16 functional requirement needs to be translated into SAP-specific design.
- When the team needs to understand what RE-FX data already exists and what must be captured in Z extension fields.
- When designing a new transaction or process step in the Z addon.
- When reviewing the data model for completeness against contract types or process scenarios.
- When preparing for a blueprint workshop or solution design session.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| Functional requirement | The IFRS 16 requirement or user story to be mapped | specs/000-master-ifrs16-addon/requirements.md |
| Current RE-FX data available | Description of what the RE contract contains in the current system | SAP RE Functional Consultant or knowledge/sap-functional/ |
| IFRS 16 data fields needed | The specific data elements required for IFRS 16 measurement | IFRS 16 domain analysis output or .kiro/steering/ifrs16-domain.md |
| Client SAP system configuration notes | Known configuration choices (RE-FX condition types in use, asset classes, company code settings) | knowledge/sap-functional/ or Functional Consultant |

---

## Steps

### Step 1: Identify the Functional Requirement
Clearly state the functional requirement being mapped:
- Source spec: `specs/000-master-ifrs16-addon/requirements.md` — Epic and Story reference.
- User persona affected: which persona interacts with this requirement.
- Process step: where in the IFRS 16 lifecycle this falls (intake, assessment, calculation, modification, posting, disclosure).

### Step 2: Map to RE-FX Object Hierarchy
For the requirement, identify the relevant RE-FX objects:

| RE-FX Object | Purpose | IFRS 16 Relevance |
|-------------|---------|-------------------|
| Contract (VIBELN / RECN — to be confirmed) | Lease agreement | Primary object for IFRS 16 scope determination |
| Business Entity | Property group | Asset class determination |
| Rental Unit | Specific space | Identified asset |
| Condition record | Payment terms | Lease payment schedule |
| Option record | Extension/termination dates | Lease term assessment |
| Partner record | Lessor | Counterparty for disclosure |

Identify: Does the RE-FX object already carry the required IFRS 16 data field? Or must a Z extension be created?

### Step 3: Standard Data Assessment
For each required IFRS 16 data field:
- Can it be read from an existing RE-FX standard field? (Document field name — to be confirmed)
- Is it derivable from existing data with a rule? (Document the derivation logic)
- Does it require a new Z extension field? (Document why standard field is insufficient)
- Does it require user data entry? (Document the entry screen and validation rule)

Use the notation:
- `[STANDARD — field name TBC]` for fields expected in standard RE-FX
- `[Z EXTENSION REQUIRED]` for fields that must be added
- `[DERIVABLE — rule: ...]` for fields that can be computed

### Step 4: Process Trigger Identification
Identify the SAP process event that triggers IFRS 16 processing for this requirement:
- Contract creation → Initial IFRS 16 assessment required
- Contract amendment (specific type) → Modification assessment required
- Period-end batch → Recalculation required
- Option date reached → Reassessment required
- Manual user action → User-initiated via Z transaction

For each trigger: identify the SAP event (save transaction, batch job, user action) and the BAdI or user exit that could be used to intercept it [TO BE CONFIRMED — specific BAdI names need landscape check].

### Step 5: Z Object Requirement Definition
For each Z extension or new Z object needed:
- Object type (Z table field, Z table, Z transaction, Z class, Z report)
- Purpose and business justification
- Data owner (who maintains this data)
- Proposed naming (per .kiro/steering/structure.md conventions — to be confirmed with ABAP Architect)
- Relationship to existing RE-FX and Z objects
- Authorization consideration (which role maintains/views this data)

### Step 6: UX Impact Assessment
For requirements that involve user interaction:
- Which existing SAP transaction does the user currently use?
- What is the proposed UX change or new Z transaction?
- Is this a wizard, an enhancement of an existing screen, or a new standalone transaction?
- Apply UX simplification principles from .kiro/steering/sap-re-architecture.md.

### Step 7: Integration Impact
Identify impacts on:
- FI-AA (ROU asset changes)
- FI-GL (posting changes)
- CO (cost assignment changes)
- Any other module integration

---

## Expected Outputs

1. **Object Mapping Table** — Requirement → RE-FX Objects → Standard Fields → Z Extensions.
2. **Data Gap List** — Fields not available in standard RE-FX with Z extension proposals.
3. **Trigger Event Map** — SAP events that activate IFRS 16 processing for this requirement.
4. **Z Object Requirement List** — Proposed new Z objects with justification (for ABAP Architect review).
5. **UX Change Summary** — Screen changes or new transactions required.
6. **Integration Impact Summary** — FI/CO/other impacts.
7. **Confirmation Required List** — All [TO BE CONFIRMED] items with owners.

---

## Quality Checks

- [ ] Every requirement traced to a spec Epic and Story.
- [ ] Every standard field reference marked as [TO BE CONFIRMED — field name].
- [ ] Every Z extension proposal has a business justification.
- [ ] UX simplification principles applied and documented.
- [ ] No SAP standard objects proposed for modification — only enhancements.
- [ ] Integration impacts identified for FI/AA, FI/GL, CO.
- [ ] All TBC items have an owner.

---

## Handoff to Next Role/Agent

- **SAP RE Functional Consultant (Human):** Validate the standard field mapping. Confirm which RE-FX fields exist and what they contain in the client's specific landscape.
- **ABAP Architecture Specialist (abap-architecture):** Use the Z Object Requirement List to design Z tables and classes.
- **Functional Spec Writer (functional-spec-writer):** Use the complete mapping to write or update the functional spec section for this requirement.
- **UX/Design Agent (ux-stitch):** Use the UX Change Summary to design the user interface.
