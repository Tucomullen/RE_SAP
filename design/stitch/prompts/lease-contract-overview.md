# Stitch Prompt — Lease Contract Overview

**Prompt version:** 0.1
**Date:** 2026-03-25
**Target screen:** Lease Contract Overview
**Linked spec:** `specs/000-master-ifrs16-addon/requirements.md` — Epics T1 and T2, US-1.2, US-2.1
**Design constraints:** `design/stitch/DESIGN.md`

---

## Prompt

Design a high-fidelity enterprise screen called **"Lease Contract Overview"** for a SAP IFRS 16 lease accounting add-on. This is an internal finance application used on desktop by lease accountants and finance controllers at a mid-to-large enterprise. The design must be ready for implementation review and should follow SAP Fiori Design System guidelines while remaining implementable in SAP ECC WebDynpro as a fallback.

---

### Business objective

This screen is the primary working view for a lease accountant managing IFRS 16 compliance for a portfolio of real estate contracts. The user arrives here after selecting a specific contract from the contract list. The screen must give the accountant a complete, authoritative view of the contract's IFRS 16 status, the current amortization schedule, and all pending actions, without requiring them to navigate away for supporting information.

The accountant must be able to:
1. Confirm the current IFRS 16 recognition status and all key parameters with confidence.
2. Review the current amortization schedule for the active period and upcoming periods.
3. Identify any pending actions (approval requests, remeasurement triggers, extension deadlines).
4. Access the full audit log for this contract.
5. Initiate a workflow action (e.g., trigger remeasurement, approve calculation, flag for review) directly from this screen.

---

### Primary user

**Role:** Lease Accountant (P1 persona)
**Context:** Reviews 30–80 contracts monthly. Works under audit pressure. Needs to answer auditor questions on-demand using only this screen. Must defend every number with a traceable source.
**Pain points this screen addresses:**
- PP-D: Cannot quickly see IFRS 16 status per contract without navigating multiple transactions.
- PP-G: No contract-level amortization schedule visible — forced to rely on spreadsheets.
- PP-B: FI entries are not explainable from context alone.

---

### Information architecture

The screen is divided into four zones. All four zones are visible on a single desktop viewport (1280px+) with no tabs required for primary content.

#### Zone 1 — Contract Header (top strip, read-only, persistent)
Compact, always-visible strip showing:
- Contract number (RE-FX internal key) — prominent, left-aligned
- Contract description / short text
- Lessee / Lessor names
- Asset class (e.g., Real Estate — Office, Vehicle, Equipment)
- Validity period (from / to, calendar format)
- Company code + currency
- **IFRS 16 Status badge** — large, right-aligned — using defined status set: Active / Draft / Pending Review / Approved / Exempt / Blocked / Rescinded
- "View Audit Log" persistent link — right of status badge

#### Zone 2 — IFRS 16 Parameters Panel (left column, ~35% width)
Read-only parameter summary grouped in labelled sections:

**Recognition Parameters**
- Lease commencement date
- Initial lease term (months / years)
- Reasonably certain lease term (months / years, with source note)
- Option dates: extension, rescission, purchase — each with "Reasonably certain to exercise: Yes / No / Pending"
- Lease classification: Finance / Operating (if applicable)
- Exemption elected: None / Short-term / Low-value (with reason if elected)

**Financial Parameters**
- Incremental Borrowing Rate (IBR): percentage, basis, reference date, source (e.g., "Treasury — approved 2024-01-15")
- Initial right-of-use asset value (EUR)
- Initial lease liability (EUR)
- Residual value guarantee (EUR or "None")
- Variable payments included: Yes / No

**Current Balances (as of last posted period)**
- ROU Asset — net book value
- Lease Liability — current balance
- Accumulated depreciation
- Accrued interest (current period, if not yet posted)
- Last posted period label (e.g., "Period 3 / 2025 — 01.03.2025–31.03.2025")
- Calculation run ID (linked — opens run detail)

#### Zone 3 — Amortization Schedule (right column, ~65% width)
A compact, scrollable data table showing the amortization schedule for the current fiscal year plus two future years. Columns:

| Period | Date Range | Opening Liability | Interest Expense | Lease Payment | Closing Liability | ROU Depreciation | Status |
|--------|------------|-------------------|-----------------|---------------|-------------------|------------------|--------|

- Current period row highlighted.
- Posted periods: status = "Posted" (green badge), amounts locked.
- Approved but not posted: status = "Approved" (blue badge).
- Draft periods: status = "Draft" (grey badge).
- Table footer: full-term totals row.
- "Export to Excel" action in table toolbar.
- "View full schedule" link that expands to all remaining periods.

#### Zone 4 — Pending Actions and Notifications (bottom bar, full width)
A structured notification area — not a generic alert banner. Shows:

- Any open approval requests for this contract (with approver name, requested date, and "View Request" link).
- Any triggered remeasurement events (with trigger description, e.g., "Extension option deadline — 2025-09-30 — 90 days remaining").
- Any blocked pre-flight conditions preventing period-end processing.
- Any open modification workflows.
- Empty state: "No pending actions for this contract."

---

### Primary actions

Action bar at the bottom right of the screen. Shown only if the user's role permits each action:

| Action | Condition |
|--------|-----------|
| **Approve Calculation** | Status = Pending Review, user has approval role |
| **Trigger Remeasurement** | Status = Active, no open modification workflow |
| **Edit IFRS 16 Parameters** | Status = Draft or Rejected |
| **Run Calculation** | Status = Approved, no open posting in current period |
| **Flag for Review** | Any status — adds a flag visible to controller |
| **View Audit Log** | Always visible (also in Zone 1 header) |

---

### States to design

Design all of the following states explicitly:

1. **Normal — Active contract, current period approved and posted.** No pending actions. Schedule visible.
2. **Pending approval — calculation submitted, awaiting controller approval.** Pending Actions zone shows the approval request. "Approve Calculation" action button active.
3. **Remeasurement triggered — extension option deadline approaching.** Pending Actions zone shows the trigger with countdown. "Trigger Remeasurement" button highlighted.
4. **Draft — IFRS 16 parameters entered but not yet approved.** Parameters in Zone 2 show edit affordance. Status badge = Draft.
5. **Blocked — pre-flight validation failure.** Pending Actions zone shows the blocking condition with plain-language explanation and resolution link.
6. **Exempt contract — short-term or low-value election.** Zone 2 shows exemption reason. Schedule zone shows "No schedule — exemption elected" with exemption basis. No calculation actions.

---

### Visible validations

- If IBR reference date > 18 months ago: show a soft warning inline in Zone 2 ("IBR may require review — last confirmed 2023-07-01").
- If reasonably certain lease term has not been confirmed for contracts with options expiring within 12 months: show warning in Zone 4.
- If a modification workflow is open: disable "Trigger Remeasurement" and explain why ("Modification workflow in progress — remeasurement locked until complete").

---

### Traceability and auditability requirements (must be visible in design)

- Every calculated amount in Zone 2 (Current Balances) must show: calculation run ID as a clickable reference.
- Every parameter in Zone 2 must show: approved date and approving user (as a small secondary text or tooltip — consistently placed).
- "View Audit Log" must be accessible from Zone 1 without scrolling.
- The last posted period label must be unambiguous — show both fiscal period notation and calendar dates.

---

### Visual tone

- Enterprise, functional, no decorative elements.
- SAP Fiori Horizon theme as the reference visual language.
- Primary color: SAP Fiori standard blue (`#0a6ed1`) for interactive elements.
- Status badges: follow SAP Fiori semantic colors — positive (green), negative (red), critical (orange), informational (blue), neutral (grey).
- Typography: SAP 72 font family or equivalent system sans-serif. Body text: 14px. Headers: 16–20px. Secondary labels: 12px.
- Dense but breathable — use 8px internal padding for cells, 16px between sections.
- No rounded hero cards, no gradient backgrounds, no illustration elements.

---

### SAP / Fiori enterprise constraints

- Assume standard SAP Fiori shell header (with user avatar, notification bell, search) is present but is NOT part of this screen design.
- Navigation breadcrumb: `RE-SAP IFRS 16 > Contract List > [Contract Number]` — show in design.
- All data is read from SAP backend — no client-side calculations in UI.
- Approval confirmation must use a SAP Fiori Dialog component pattern (modal with confirm / cancel and explicit warning).
- The screen must work as a Fiori Freestyle app (not Worklist/Object Page template) given ECC constraints.
- Flag any component that requires Fiori Elements or OData V4 with: `[Fiori Elements — ECC alternative needed]`.
