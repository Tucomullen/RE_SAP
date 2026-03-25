# Design Contract — RE-SAP IFRS 16 Add-On

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.1 | 2026-03-25 | Design layer bootstrap | Initial design contract for Stitch and AI agents |

---

## 1. Product Context

This add-on extends SAP RE/RE-FX to support IFRS 16 lease accounting. It runs on SAP ECC as a Z layer. Target users are lease accountants, finance controllers, and external auditors. The system must enforce accounting integrity, provide complete audit trails, and surface IFRS 16 obligations clearly at every interaction point.

**Non-goals for UI:** The interface does not teach IFRS 16. It assumes users understand the standard. The interface enforces process and surfaces data — it does not hide complexity behind friendliness.

---

## 2. UX Goals

| Goal | Description |
|------|-------------|
| Productivity | Users complete routine tasks (period-end run, contract review, schedule approval) with minimal clicks and no context switching |
| Traceability | Every action is traceable to a specific user, timestamp, and IFRS 16 process event |
| Auditability | Auditors can independently verify any number, any status, any decision from the UI without developer support |
| Error prevention | Pre-flight validation surfaces problems before they reach FI posting |
| Controlled disclosure | Users only see data and actions permitted by their SAP role — no accidental exposure of restricted data |

---

## 3. Visual Principles

- **Clarity over styling.** No decorative gradients, shadows, or animations. Every visual element carries information or structure.
- **Density is a feature.** Finance users work with dense data. Do not pad or space out content in ways that require excessive scrolling.
- **Status is always visible.** Every list row, contract header, and process step shows its status without requiring drill-down.
- **Actionable errors only.** Every warning and error includes the specific resolution path, not just the problem description.
- **Fiori-oriented, ECC-realistic.** Design with SAP Fiori Design System constraints in mind. Flag any pattern that requires Fiori/UI5 and cannot be implemented in ECC WebDynpro with a `[Fiori-ready — ECC alternative needed]` marker.

---

## 4. Layout and Grid Guidance

### General page structure
```
┌─────────────────────────────────────────────────────┐
│  Page Title + Context (Company Code, Fiscal Year)   │
├─────────────────────────────────────────────────────┤
│  Filter / Selection Bar (collapsible)               │
├─────────────────────────────────────────────────────┤
│  Main Content Area                                  │
│  (Table / Form / Wizard / Dashboard tiles)          │
├─────────────────────────────────────────────────────┤
│  Action Bar (primary actions right-aligned)         │
└─────────────────────────────────────────────────────┘
```

### Grid
- Use 12-column grid for form layouts.
- Form fields: 4 or 6 columns wide depending on data type (dates = 3, amounts = 4, descriptions = 6–12).
- Tables: full width, no horizontal scroll unless content genuinely requires it.
- Avoid nesting more than 2 levels of containers.

### Breakpoints
- Desktop (≥1280px): full layout as designed.
- Tablet (768–1279px): two-column forms collapse to single column; tables show fewer columns with detail on row expand.
- Mobile: out of scope for v1 — SAP ECC users are on desktop.

---

## 5. Forms Pattern

### Standard form rules
- Label position: above the field (not inline) for clarity at high density.
- Required fields: marked with `*` — no color-only indication.
- Field order: follows the business process sequence, not alphabetical.
- Read-only display: use display-only fields (not disabled inputs) when showing approved/locked data.
- Group related fields in clearly labeled sections (`<h3>` level, left-aligned).
- Do not mix editable and read-only sections without a clear visual boundary.

### IFRS 16 form specifics
- Discount rate fields: always show basis (e.g., "IBR — 3.25% p.a. as at 2024-01-01"). Source must be cited.
- Lease term fields: always show the "reasonably certain to exercise" indicator adjacent to option dates.
- Amount fields: currency code always visible. No implicit currency assumptions.
- Calculation result fields: always marked as system-calculated and show the run ID as a tooltip or adjacent label.

---

## 6. Table Pattern

### Standard table rules
- Column headers: short, unambiguous, with unit or currency in parentheses where relevant (e.g., "Liability Balance (EUR)").
- Sortable columns: all key data columns sortable by default.
- Filterable: filter row visible by default for tables with >20 expected rows.
- Row actions: placed in a consistent last column labelled "Actions" or via row-level context menu.
- Status column: always leftmost after the key identifier column.
- Empty state: always shows an explicit "No records found" message with the active filter conditions visible.

### IFRS 16 table specifics
- Contract list: default filter = Active + Extension/Rescission Pending (never show all without explicit user action).
- Calculation schedule table: period column first, then opening balance, interest, depreciation, payment, closing balance. Totals row at bottom.
- Audit log table: timestamp, user, action, affected object, result — no truncation of action descriptions.

---

## 7. Wizard Pattern

Used for: Contract intake, modification classification, remeasurement workflow.

### Wizard structure
```
Step 1 [completed] → Step 2 [active] → Step 3 [pending] → Step 4 [pending]
─────────────────────────────────────────────────────────────────────────
  Step content area
  (form fields, validation feedback, calculation previews)
─────────────────────────────────────────────────────────────────────────
[ Back ]                                    [ Save Draft ]  [ Next → ]
```

### Wizard rules
- Each step has a single clearly stated objective shown at the top.
- Users cannot proceed to the next step until all required fields on the current step are valid.
- Pre-flight validation runs at step transition, not only at final submission.
- Step completion is persisted as draft — users can close and resume.
- Step 1 always shows the RE-FX contract context (contract number, description, validity period, lessee/lessor) as read-only reference.
- Wizards never post to FI — they produce a pending request that requires separate approval.

---

## 8. Status and Validation Patterns

### Status badges
All status values use consistent badge styling:

| Status | Meaning | Visual weight |
|--------|---------|---------------|
| `Active` | IFRS 16 data captured and approved | Neutral (no highlight) |
| `Draft` | In progress, not yet submitted | Low emphasis |
| `Pending Review` | Submitted, awaiting approval | Medium emphasis |
| `Approved` | Approved, calculation authorized | Positive |
| `Posted` | FI document created | Positive strong |
| `Rejected` | Returned for correction | Negative |
| `Blocked` | Administrative block applied | Warning |
| `Exempt` | Short-term or low-value exemption elected | Informational |
| `Rescinded` | Lease terminated and valuated | Neutral distinct |

Status must never be inferred from other fields — it must always be an explicit, stored, displayed value.

### Inline validation
- Validate on blur for individual fields.
- Validate on step advance for the full step.
- Validate on submit for the full form.
- All validation messages are plain language. No raw SAP message codes shown to users.
- Every blocking message includes: what is wrong + why it matters + how to fix it.

### Calculation previews
- Before any approval action, show a summary of what will change: affected period, amount delta, ROU asset impact, liability impact.
- Previews are clearly labelled "Preview — not posted" in a distinct visual container.

---

## 9. Accessibility Expectations

- All interactive elements are keyboard-navigable.
- Focus order follows the logical reading order of the form or table.
- Color is never the only differentiator for status — always paired with text label or icon.
- Contrast ratio: minimum 4.5:1 for body text, 3:1 for large text and UI components (WCAG AA).
- All form fields have programmatically associated labels.
- Error messages are announced to screen readers.
- Tables use proper `<thead>` / `<tbody>` structure with scope attributes on headers.

---

## 10. SAP / Fiori Enterprise Constraints

| Constraint | Rule |
|-----------|------|
| SAP ECC WebDynpro | Default implementation target. ABAP-side UI5 not available in all landscapes. Mark Fiori-only patterns explicitly. |
| ALV Grid | Use SAP ALV OO for all list/table views in ECC. Design tables with ALV constraints (fixed columns, standard toolbar). |
| SAP message framework | All user-visible messages use Z message class `ZRIF16_MSGS`. No hardcoded strings in ABAP. |
| Field length | All Z field definitions observed in design (e.g., contract number = RE-FX standard length, not arbitrary). |
| Role-based access | UI elements are not hidden by JavaScript — they are suppressed by SAP authorization check at render time. |
| Session / navigation | SAP GUI-style navigation assumed for ECC. No browser-history navigation. |
| Export | All tables support ALV standard export (Excel, PDF). No custom export framework needed. |
| Multilingual | All UI labels and messages support German, English, Spanish as minimum (message class ZRIF16_MSGS). |

---

## 11. Auditability and Finance-Oriented Usability Constraints

- **Every screen that displays a calculated amount must show:** the calculation run ID, the run date, and the user who triggered the run. This must be a permanent fixture, not a tooltip.
- **Every approval action must require:** explicit confirmation dialog showing what is being approved, the approver's name (from SAP session), and the timestamp.
- **Posted data is immutable in the UI.** Users cannot edit a posted record — they can only create a new correction workflow.
- **Disclosure aggregation views** must show the source population (number of contracts included) and a drill-down link to the contract list used to compute any aggregate.
- **Audit trail access** must be available from every screen that shows IFRS 16 data — a persistent "View Audit Log" action, not buried in menus.
- **Finance-period labels** always show both the fiscal period and the calendar date range (e.g., "Period 3 / 2025 — 01.03.2025–31.03.2025").

---

## 12. Design Artifact Storage and Versioning

### Fuente principal para implementación UI5/Fiori

> **La fuente principal para implementar cualquier pantalla es el artefacto real exportado por Stitch.**
> El prompt original (`source-prompt.md`) existe únicamente para trazabilidad.
> El agente `ui5-fiori-bridge` trabaja desde `screen.html`, no desde el prompt.

### Precedencia de fuentes

| Prioridad | Fuente | Rol |
|-----------|--------|-----|
| 1 | `screen.html` | **FUENTE PRINCIPAL** — jerarquía visual, layout, componentes, acciones |
| 2 | `screenshot.png` | **VALIDACIÓN VISUAL** — confirma fidelidad del HTML |
| 3 | `metadata.json` / `screen.json` | **CONTEXTO ESTRUCTURAL** — design system, versión, IDs |
| 4 | `source-prompt.md` | **SOLO TRAZABILIDAD** — no rediseñar desde aquí si HTML existe |

### Estructura de storage

| Capa | Ubicación | Contenido |
|------|-----------|-----------|
| Prompts (inputs a Stitch) | `design/stitch/prompts/` | Prompts por pantalla — fuente de trazabilidad |
| Exports estructurados por pantalla | `design/stitch/exports/<screen-name>/` | `screen.html`, `screenshot.png`, `metadata.json`, `screen.json`, `source-prompt.md`, `traceability.md`, `README.md` |
| Exports legacy (formato anterior) | `design/stitch/exports/*.md` | Archivos planos del formato anterior — mantener como histórico |
| Revisados y anotados | `design/stitch/screens/` | Traceability files anotados tras revisión del agente ux-stitch |
| Artefactos validados | `knowledge/ux-stitch/` | Solo tras validación de persona representative |

Cada pantalla tiene su carpeta en `design/stitch/exports/<screen-name>/` con todos sus artefactos.
El estándar completo de la carpeta está en `design/stitch/README.md` sección 5.

Every file in `design/stitch/screens/` and `knowledge/ux-stitch/` must carry the frontmatter defined in `knowledge/ux-stitch/README.md`.

### Agentes del flujo

- `ux-stitch` — Genera pantallas, revisa contra pain points y SAP constraints.
- `ui5-fiori-bridge` — Traduce `screen.html` → spec SAP UI5 (XML View, controller, i18n, bindings).
- Método de traducción: `design/stitch/html-to-ui5-method.md`.

---

## 13. Open Design Questions

| ID | Question | Impact | Status |
|----|---------|--------|--------|
| DQ-01 | Confirmed Google Stitch API authentication scheme? | `tools/stitch-proxy.mjs` and `.kiro/settings/mcp.json` | **Resolved** 2026-03-25 — Auth: Google Cloud Application Default Credentials (ADC) via `google-auth-library` + `x-goog-user-project: northern-syntax-483410-v6`. API keys rejected. `tools/call` validated: `list_projects`, `create_project`, `generate_screen_from_text` all succeed. First screen generated: `design/stitch/exports/finance-dashboard-v0.1-2026-03-25.md`. |
| DQ-02 | Fiori vs. WebDynpro scope for v1 UI? | Layout and component choices | Deferred to Phase 0 decision |
| DQ-03 | Confirm exact ALV column configuration for contract list view | `knowledge/ux-stitch/` screen spec | Open |
| DQ-04 | Polish advance-payment contract (PP-K) — in scope for design? | Modification wizard step count | Pending governance decision (OQ-08) |
