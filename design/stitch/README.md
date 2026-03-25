# Design / Stitch Integration — Operational Guide

**Last updated:** 2026-03-25
**Owner:** UX Designer + Kiro ux-stitch agent
**Related files:** `design/stitch/DESIGN.md`, `.kiro/agents/ux-stitch.json`, `knowledge/ux-stitch/README.md`

> **Connection status:** Stitch MCP is **operational** as of 2026-03-25.
> Auth: Google Cloud ADC via `tools/stitch-proxy.mjs` (forwarding proxy, `google-auth-library`).
> First screen generated: `design/stitch/exports/finance-dashboard-v0.1-2026-03-25.md`.
> GCP project: `northern-syntax-483410-v6` (re-sap-ifrs16, project ID: 8885202212425441682).

---

## 1. What this integration does

This folder (`design/stitch/`) is the working layer for UI screen design generation using Google Stitch.

**Architecture:** Kiro connects to the Google Stitch MCP server via a **local stdio ADC proxy** (`tools/stitch-proxy.mjs`). Configuration is in `.kiro/settings/mcp.json`.

```
specs/ (functional truth)
    ↓  UX designer or ux-stitch agent reads requirements
design/stitch/prompts/  (prompt layer)
    ↓  [Manual path] Prompt pasted into Stitch web UI manually
    ↓  [MCP path — OPERATIONAL] Prompt sent via MCP (Kiro → stitch-proxy.mjs → stitch.googleapis.com/mcp)
Google Stitch  (design generation)
    ↓  Generated screen exported
design/stitch/exports/  (raw output)
    ↓  ux-stitch agent reviews against pain points + SAP constraints
design/stitch/screens/  (reviewed + annotated)
    ↓  Validated by persona representative
knowledge/ux-stitch/  (validated artifacts — authoritative)
    ↓  Implementation tasks generated
specs/000-master-ifrs16-addon/tasks.md
```

The boundary between `design/stitch/` (working) and `knowledge/ux-stitch/` (validated) is intentional.
Do not move artifacts to `knowledge/ux-stitch/` without validation.

---

## 2. Authentication — what is known and what is not

> **Summary:** Google API keys (`STITCH_API_KEY`) do **not** authenticate `tools/call` on the Stitch MCP.
> The validated path is **Google Cloud Application Default Credentials (ADC)**.
> `STITCH_API_KEY` in `.env` is kept only for the local mock guard — it is not the production auth mechanism.

### What was tested
- `tools/list` on `https://stitch.googleapis.com/mcp` → returns tool list with no auth (public)
- `tools/call` with `Authorization: Bearer <google-api-key>` → rejected: `"Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential."`
- Conclusion: `tools/call` requires OAuth 2 principal credentials, not an API key

### Primary path — Google Cloud Application Default Credentials (ADC)
This is the approach to implement before the MCP path is operational.

**Pending manual steps:**

1. **Install Google Cloud CLI (`gcloud`)**
   Download: https://cloud.google.com/sdk/docs/install
   Windows: use the installer, ensure Python ≥ 3.9 is present (gcloud requires it)

2. **Authenticate with ADC**
   ```bash
   gcloud auth application-default login
   ```
   This opens a browser and writes credentials to `~/.config/gcloud/application_default_credentials.json`.

3. **Set quota project (if required by Stitch API)**
   ```bash
   gcloud auth application-default set-quota-project <your-gcp-project-id>
   ```

4. **Enable the Stitch API on your GCP project** *(if not already done)*
   ```bash
   gcloud services enable stitch.googleapis.com --project=<your-gcp-project-id>
   ```
   Or via GCP Console → APIs & Services → Enable APIs.

5. **Verify that ADC is usable**
   ```bash
   gcloud auth application-default print-access-token
   ```
   If this returns a token, ADC is working.

6. **Update `tools/stitch-proxy.mjs`** to use ADC for real calls, replacing the STITCH_API_KEY guard.
   This step requires confirming the exact auth header format Stitch expects from ADC.
   Do not mark this as done until a real `tools/call` succeeds.

### `STITCH_API_KEY` — retained only as mock guard
The `.env` variable `STITCH_API_KEY` is still required by `tools/stitch-proxy.mjs` as an env-presence check
(it mirrors the guard that a real implementation would have for a production credential).
It is **not** a working auth mechanism for the real Stitch MCP.
**Do not advertise it as such.**

### .env.example
A safe template (no real keys) is at `.env.example` at the repository root.
The `STITCH_API_KEY` entry there is for the mock guard only.

---

## 3. How Kiro connects to the Stitch MCP server (current state)

> **Current configuration:** local stdio ADC forwarding proxy (`tools/stitch-proxy.mjs`).
> Validated on 2026-03-25. Forwards all MCP calls to `stitch.googleapis.com/mcp` using ADC.

Kiro reads `.kiro/settings/mcp.json` at workspace startup. **Current config:**

```json
{
  "mcpServers": {
    "stitch": {
      "command": "node",
      "args": ["tools/stitch-proxy.mjs"],
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

**Prerequisites:**
- Node.js ≥ 18 installed
- `npm install` run at the repository root (installs `@modelcontextprotocol/sdk` + `google-auth-library`)
- `gcloud auth application-default login` completed (ADC credentials in `~/.config/gcloud/`)
- Quota project set: `gcloud auth application-default set-quota-project northern-syntax-483410-v6`

**To verify Kiro loads the proxy:**
Open Kiro → Settings → MCP Servers → `stitch` should appear as Connected.
Real Stitch tool calls will execute against `re-sap-ifrs16` project (ID: `8885202212425441682`).

### Known real Stitch MCP tools (confirmed from `tools/list` — NOT from executed tool call)
These tool names were retrieved from `https://stitch.googleapis.com/mcp` via an unauthenticated `tools/list` call on 2026-03-25.
They are confirmed as the real names exposed by the server, but have **not** been successfully invoked.

| Real tool name | Description (from server) |
|----------------|--------------------------|
| `create_project` | Creates a new Stitch project |
| `get_project` | Retrieves details of a specific project |
| `list_projects` | Lists all accessible Stitch projects |
| `list_screens` | Lists all screens within a project |
| `get_screen` | Retrieves a specific screen within a project |
| `generate_screen_from_text` | Generates a new screen from a text prompt |
| `edit_screens` | Edits existing screens via text prompt |
| `generate_variants` | Generates variants of existing screens |
| `create_design_system` | Creates a design system for a project |
| `update_design_system` | Updates a design system |
| `list_design_systems` | Lists design systems for a project |
| `apply_design_system` | Applies a design system to screens |

> **Note:** The local mock uses different names (`stitch_generate_screen`, etc.) — these are stubs
> that predate the confirmed real tool names. The mock names do not match production.
> Update the mock if/when it is used for integration testing against the real API.

---

## 4. How to use prompts in design/stitch/prompts/

### Workflow A — Manual (no MCP, Stitch web UI)
1. Open the prompt file (e.g., [lease-contract-overview.md](prompts/lease-contract-overview.md)).
2. Copy the prompt section starting at `## Prompt`.
3. Paste into Google Stitch's generation input.
4. Export the result and save to [design/stitch/exports/](exports/).
5. Create a traceability file in [design/stitch/screens/](screens/) from the template.

### Workflow B — Via MCP (ux-stitch agent in Kiro) — NOT YET OPERATIONAL
> Requires ADC auth setup (section 2) and switch to real endpoint. Do not attempt until DQ-01 resolved.

1. Complete all steps in section 2 (gcloud ADC setup).
2. Update `.kiro/settings/mcp.json` to use the real endpoint (see section 3).
3. Confirm Kiro shows `stitch` as Connected (Settings → MCP Servers).
4. Open the `ux-stitch` agent in Kiro.
5. Ask the agent to generate the screen:
   ```
   Generate the Lease Contract Overview screen using the prompt in
   design/stitch/prompts/lease-contract-overview.md.
   Stitch project ID: <your-gcp-project-id>
   ```
6. The agent will call `generate_screen_from_text` via MCP — Kiro will prompt for approval (autoApprove is empty).
7. After generation, retrieve the screen via `get_screen` → save to `design/stitch/exports/`.
8. Review the output and annotate in `design/stitch/screens/`.

### Creating a new prompt
1. Identify the target screen and its linked user story in `specs/`.
2. Read `design/stitch/DESIGN.md` — all prompts must be consistent with it.
3. Copy an existing prompt file as a starting point.
4. Fill in all sections (see `lease-contract-overview.md` for structure).
5. Name the file: `<kebab-case-screen-name>.md`.

---

## 5. Where to save exports, screens, and traceability

| Artifact | Location | When |
|----------|----------|------|
| Raw Stitch output (JSON/PNG/Markdown) | `design/stitch/exports/` | Immediately after generation |
| Reviewed and annotated screen | `design/stitch/screens/` | After ux-stitch agent review |
| Traceability record | `design/stitch/screens/<screen-name>-traceability.md` | One per screen, instantiated from `TRACEABILITY_TEMPLATE.md` |
| Validated artifact | `knowledge/ux-stitch/` | After persona representative validation — with full frontmatter |

File naming convention for exports:
```
design/stitch/exports/<screen-name>-v<version>-<date>.<ext>
Example: lease-contract-overview-v0.1-2026-03-25.md
```

---

## 6. Known limitations and open issues

| Limitation | Details |
|-----------|---------|
| **ADC token expiry** | ADC tokens expire in ~1h. `google-auth-library` handles refresh automatically via the stored credentials file. If the proxy fails auth, re-run `gcloud auth application-default login`. |
| **`gcloud` requires Python** | On this Windows environment, `gcloud` works with its bundled Python. Use: `CLOUDSDK_PYTHON="$LOCALAPPDATA/Google/Cloud SDK/google-cloud-sdk/platform/bundledpython/python.exe" gcloud <cmd>`. |
| **`autoApprove` is empty** | No stitch tools are auto-approved. Kiro will prompt for confirmation on every MCP call. Intentional — update only after confirming tool safety. |
| **design/stitch vs knowledge/ux-stitch** | Do not confuse working artifacts (here) with validated artifacts (`knowledge/ux-stitch/`). Only artifacts with persona validation belong in `knowledge/ux-stitch/`. |
| **Stitch generates generic designs** | Stitch output must be reviewed against SAP constraints and IFRS 16 pain points before use. See `ux-stitch` agent and `DESIGN.md`. |

---

## 7. Recommended next steps

### Step 1 — Verify Kiro loads the proxy ✅ Unblocked
1. `npm install` at repo root ✅
2. `gcloud auth application-default login` ✅
3. `gcloud auth application-default set-quota-project northern-syntax-483410-v6` ✅
4. Open Kiro → Settings → MCP Servers → confirm `stitch` appears as Connected

### Step 2 — Run first design generation ✅ Done
First screen generated: `design/stitch/exports/finance-dashboard-v0.1-2026-03-25.md`
Stitch project: `re-sap-ifrs16` (ID: `8885202212425441682`)

### Step 3 — Generate IFRS 16 screens
Use Workflow B (via MCP) with the real endpoint to generate the Lease Contract Overview screen.
Prompt file is ready: `design/stitch/prompts/lease-contract-overview.md`.
Tool to call: `generate_screen_from_text` (confirmed real name — see section 3).

### Step 4 — Connect specs to design
For each Epic in `specs/000-master-ifrs16-addon/requirements.md` with UI interactions,
create a corresponding prompt in `design/stitch/prompts/`.
Priority order: Contract Intake Wizard, Period-End Trigger, Calculation Approval screen.

### Step 5 — Extend ux-traceability-check hook
See `design/stitch/hooks-plan.md` — add `design/stitch/**/*.md` to the existing hook.

### Step 6 — Update knowledge/ux-stitch/README.md index
Once the first validated screen exists in `knowledge/ux-stitch/`, update the index table.
