---
screen: Lease Contract Overview
version: 0.1
status: placeholder
spec-ref: specs/000-master-ifrs16-addon/requirements.md
user-stories:
  - US-1.2
  - US-2.1
personas:
  - P1 — Lease Accountant
  - P2 — RE Contract Manager
pain-points:
  - PP-D — Cannot quickly see IFRS 16 status per contract
  - PP-G — No contract-level amortization schedule visible
  - PP-B — FI entries not explainable from context alone
source-prompt: design/stitch/prompts/lease-contract-overview.md
export-html: design/stitch/exports/lease-contract-overview/screen.html
export-screenshot: design/stitch/exports/lease-contract-overview/screenshot.png
export-metadata: design/stitch/exports/lease-contract-overview/metadata.json
validated-artifact: knowledge/ux-stitch/ (pending)
---

# Traceability — Lease Contract Overview

## Spec Links

| Item | Reference |
|------|-----------|
| Requirements | [specs/000-master-ifrs16-addon/requirements.md](../../../../specs/000-master-ifrs16-addon/requirements.md) |
| US-1.2 | Contract data capture — IFRS 16 parameters visible per contract |
| US-2.1 | IFRS 16 decision support — accountant can confirm recognition status |
| Pain point PP-D | Contract status not visible without navigating multiple transactions |
| Pain point PP-G | No amortization schedule at contract level |
| Pain point PP-B | FI entries lack traceable context |

## Design Contract

All design decisions for this screen must comply with [design/stitch/DESIGN.md](../../DESIGN.md).

Key applicable sections:
- Section 4: Layout and Grid (4-zone layout, 12-column grid)
- Section 6: Table Pattern (amortization schedule)
- Section 8: Status badges (Active / Draft / Pending Review / Approved / Posted / etc.)
- Section 11: Auditability (calculation run ID, approver, timestamp always visible)

## Implementation Status

| Artifact | Status | Notes |
|----------|--------|-------|
| `screen.html` | ⬜ Pending | Not yet exported from Stitch |
| `screenshot.png` | ⬜ Pending | Not yet exported from Stitch |
| `metadata.json` | ⬜ Placeholder | Must be replaced with real data after export |
| `screen.json` | ⬜ Pending | Full Stitch export JSON |
| UI5 spec (ui5-fiori-bridge output) | ⬜ Pending | Blocked until screen.html is available |
| Validated artifact (knowledge/ux-stitch/) | ⬜ Pending | Blocked until review + persona validation |

## Change Log

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-03-25 | 0.1 | Initial placeholder — folder structure created, prompt ready | Bootstrap |
