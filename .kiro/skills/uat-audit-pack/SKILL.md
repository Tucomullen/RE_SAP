---
name: uat-audit-pack
description: >-
  Generate a complete UAT test package for an IFRS 16 addon feature: test scenarios, expected results, audit evidence matrix, internal controls checklist, and sign-off register.
---

# Skill: UAT and Audit Pack Generator

## Title
UAT and Audit Pack Generator — Test Scenarios, Evidence Matrix, and Sign-off Package

## Description
This skill generates a complete UAT test package for a specific feature or release of the IFRS 16 Z addon. The package includes test scenarios, expected results (to be validated by the IFRS 16 Accountant), an audit evidence matrix, a controls checklist, and a sign-off register. It is designed to produce artifacts that satisfy both UAT completion criteria and external audit evidence requirements.

## When to Use
- When a feature is development-complete and ready for UAT.
- When preparing an audit evidence pack for internal or external audit review.
- When a regression test run is needed after a change.
- When the project governance requires a phase completion quality gate.
- When preparing the first end-to-end test of the full IFRS 16 calculation cycle.

---

## Required Inputs

| Input | Description | Source |
|-------|-------------|--------|
| Feature or epic in scope | Which features are covered by this UAT pack | specs/000-master-ifrs16-addon/requirements.md |
| Acceptance criteria | Formal pass/fail criteria | Functional spec or requirements.md |
| Technical design | What the system does and how | docs/technical/master-technical-design.md |
| Test data specification | What SAP master data and contract data is needed | To be defined jointly with Functional Consultant |
| Risk register | High-risk areas requiring extra test coverage | docs/governance/risk-register.md |
| Previous UAT findings | Known issues from earlier test cycles | knowledge/user-feedback/ |

---

## Steps

### Step 1: UAT Scope Definition
- List all functional stories covered by this UAT pack.
- Define the test environment requirements (SAP system, data state, user access).
- Identify which personas are required as UAT participants and in what capacity.
- Note any features explicitly out of scope for this UAT cycle.

### Step 2: Test Data Design
- Specify the SAP master data required: company codes, business entities, rental units, contracts.
- Specify the IFRS 16 scenario data: contract types (standard lease, short-term, low-value), modification scenarios, remeasurement scenarios.
- All test data must be synthetic or anonymized — no real production data.
- Provide a data setup checklist: what an admin must create or configure before UAT begins.

### Step 3: Test Scenario Creation
For each acceptance criterion, create at least one test scenario:

**Scenario Structure:**
```
Scenario ID: UAT-[AREA]-NNN
Title: [Short descriptive title]
Persona: [Which user role performs this test]
Priority: [Critical / High / Medium / Low]
Category: [Happy Path / Error Path / Edge Case / Regression]

Preconditions:
- [List all setup requirements]

Test Steps:
1. [Action] — [Expected screen/system response]
2. [Action] — [Expected screen/system response]
...

Expected Result:
- [Specific, measurable expected outcome]
- IFRS 16 accounting impact: [ROU/liability/P&L expected effect — to be validated by IFRS 16 Accountant]
- Evidence generated: [What audit trail/log entries are expected]

Pass Criteria: [Exact condition for PASS]
Fail Criteria: [Any condition that means FAIL]
Sign-off Role: [Who can sign off this scenario as PASSED]
```

### Step 4: IFRS 16 Accounting Validation Requirements
For every scenario that involves IFRS 16 calculation results:
- Prepare an independent manual calculation (outside SAP) of the expected result.
- This manual calculation must be reviewed and signed off by the IFRS 16 Accountant before UAT begins.
- The UAT pass criterion is that the system matches the manually calculated result within an acceptable tolerance [TO BE CONFIRMED — tolerance policy].

### Step 5: Audit Evidence Matrix
For each IFRS 16 process step in scope, document:

| Process Step | Evidence Generated | Storage Location | Retrieval Method | Retention Requirement |
|-------------|-------------------|-----------------|-----------------|----------------------|
| Contract scoping decision | Scoping memo with approver | ZRIF16_AUDIT | ZRE_IFRS16_AUDIT transaction | To be confirmed |
| Initial calculation | Calculation run log + inputs snapshot | ZRIF16_CALC + SLG1 | SLG1 transaction | To be confirmed |
| Accountant approval | Approval timestamp + user ID | ZRIF16_CALC header | ZRE_IFRS16_REVIEW | To be confirmed |
| FI posting | FI document numbers linked to run | ZRIF16_POST or FI link | FBL3N / ZRE_IFRS16_AUDIT | Standard FI retention |
| Modification approval | Modification memo + snapshot | ZRIF16_MODF | ZRE_IFRS16_AUDIT | To be confirmed |

### Step 6: Internal Controls Checklist
For each key control in the IFRS 16 process:

| Control | Control Type | Test Procedure | Pass Criteria |
|---------|-------------|----------------|--------------|
| Calculation cannot be posted without accountant approval | Preventive | Attempt to post without approval — verify system blocks | System displays error and blocks posting |
| Override of calculated values requires reason and supervisor sign-off | Preventive | Attempt override without reason — verify block | System requires reason and triggers approval workflow |
| All data inputs captured in immutable audit log | Detective | Review log after calculation run — verify completeness | Log contains all input fields with values and timestamps |
| Only authorized roles can execute period-end calculation job | Preventive | Attempt to run job with non-authorized user | System denies access |

### Step 7: Regression Test Suite
Identify the minimum test cases that must pass before any release:
- Core calculation accuracy (at least 3 different contract scenarios).
- Modification workflow (at least new separate lease + not-separate-not-scope-decrease).
- Period-end batch execution with correct output.
- Posting flow with FI document creation.
- Audit trail completeness check.

### Step 8: Sign-off Register
Create a sign-off register template:

| Scenario ID | Tester | Test Date | Result | Defect Ref | Sign-off By | Sign-off Date |
|-------------|--------|-----------|--------|------------|-------------|--------------|
| UAT-INTAKE-001 | [name] | | PASS/FAIL | | [accountant] | |
| ... | | | | | | |

Phase pass criteria: 100% of Critical scenarios PASS, ≥95% of High scenarios PASS, no open Critical defects.

---

## Expected Outputs

1. **UAT Test Pack** — Complete scenario set per steps above.
2. **Test Data Setup Checklist** — Admin instructions for test environment preparation.
3. **Manual Calculation Workbook Reference** — Pointer to independently calculated expected results (to be prepared by IFRS 16 Accountant).
4. **Audit Evidence Matrix** — Complete evidence coverage table.
5. **Controls Test Procedures** — Test procedures for each internal control.
6. **Regression Test Suite** — Minimum regression cases for future releases.
7. **Sign-off Register Template** — Ready for UAT execution.

---

## Quality Checks

- [ ] Every acceptance criterion from the functional spec has at least one test scenario.
- [ ] All IFRS 16 calculation expected results marked for accountant validation.
- [ ] All test data is synthetic/anonymized.
- [ ] Audit evidence matrix covers every process step with a posted FI entry.
- [ ] Controls checklist covers all segregation of duties requirements.
- [ ] Regression suite defined and baseline established.
- [ ] Sign-off register identifies the correct approver for each scenario type.

---

## Handoff to Next Role/Agent

- **IFRS 16 Accountant (Human):** Validate all IFRS 16 expected results in the UAT scenarios. Prepare manual calculation workbook.
- **SAP RE Functional Consultant (Human):** Validate test data setup instructions.
- **UAT Participants (Human — target personas):** Execute the UAT scenarios and record results.
- **QA Lead (Human):** Review defects, manage retest, and authorize phase sign-off.
- **Docs Continuity Agent (docs-continuity):** Record UAT completion and any documentation updates triggered by defect findings.
