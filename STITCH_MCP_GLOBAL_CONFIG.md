# Stitch MCP — Global Configuration Complete

**Date:** 2026-03-27
**Status:** ✅ CONFIGURED AND READY
**Scope:** All Kiro projects (global user-level configuration)

---

## What Was Done

Stitch MCP is now configured globally at the user level (`~/.kiro/settings/mcp.json`). This means:

- **Every new project** you create will automatically have Stitch MCP available.
- **No per-workspace configuration needed** — the global config is inherited by all workspaces.
- **Read-only operations are auto-approved** — list projects, get project, list screens, get screen.
- **Write operations still require approval** — generate screen, edit screen, apply design system (safety feature).

---

## Configuration Details

**Location:** `~/.kiro/settings/mcp.json`

```json
{
  "mcpServers": {
    "stitch": {
      "command": "node",
      "args": ["tools/stitch-proxy.mjs"],
      "disabled": false,
      "autoApprove": [
        "mcp_stitch_list_projects",
        "mcp_stitch_get_project",
        "mcp_stitch_list_screens",
        "mcp_stitch_get_screen"
      ]
    }
  }
}
```

**What this means:**
- `command: "node"` — Uses Node.js to run the proxy
- `args: ["tools/stitch-proxy.mjs"]` — Runs the Stitch forwarding proxy (must exist in each workspace)
- `disabled: false` — Stitch MCP is enabled
- `autoApprove` — These 4 read-only tools don't require confirmation

---

## Prerequisites for Each Project

For Stitch MCP to work in a new project, you need:

1. **`tools/stitch-proxy.mjs` file** in the project root
   - This is the forwarding proxy that connects to Google Stitch API
   - You can symlink it from the RE_SAP project or copy it

2. **Google Cloud ADC authentication** (one-time setup)
   ```bash
   gcloud auth application-default login
   gcloud auth application-default set-quota-project northern-syntax-483410-v6
   ```
   - This creates credentials at `~/.config/gcloud/application_default_credentials.json`
   - Valid for all projects — you only do this once

3. **Node.js ≥ 18** installed on your machine

4. **npm dependencies** installed in the project
   ```bash
   npm install
   ```
   - Installs `@modelcontextprotocol/sdk` and `google-auth-library`

---

## How to Use in a New Project

1. **Create your new project folder**
   ```bash
   mkdir my-new-project
   cd my-new-project
   ```

2. **Copy or symlink the Stitch proxy**
   ```bash
   # Option A: Copy from RE_SAP
   cp ../RE_SAP/tools/stitch-proxy.mjs tools/
   
   # Option B: Symlink (recommended)
   ln -s ../RE_SAP/tools/stitch-proxy.mjs tools/stitch-proxy.mjs
   ```

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Open in Kiro**
   - Kiro automatically reads the global MCP config
   - Stitch MCP is immediately available
   - Check: Settings → MCP Servers → `stitch` should show as Connected

5. **Start using Stitch MCP**
   - Use the `ux-stitch` agent to generate screens
   - Use the `ui5-fiori-bridge` agent to convert HTML to UI5 specs
   - All read operations are auto-approved; write operations require confirmation

---

## Verification

To verify the global config is working:

1. **Check the file exists:**
   ```bash
   cat ~/.kiro/settings/mcp.json
   ```

2. **In Kiro:**
   - Open Settings → MCP Servers
   - Look for `stitch` in the list
   - Status should show as Connected (after ADC auth is complete)

3. **Test a read operation:**
   - Open any agent that uses Stitch MCP
   - Call `mcp_stitch_list_projects`
   - Should return your Stitch projects without prompting for approval

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `stitch` shows as Disconnected | Run `gcloud auth application-default login` and restart Kiro |
| `tools/stitch-proxy.mjs not found` | Copy or symlink the file from RE_SAP to your project's `tools/` folder |
| `npm install` fails | Ensure Node.js ≥ 18 is installed: `node --version` |
| ADC token expired | Run `gcloud auth application-default login` again |
| Permission denied on `gcloud` | On Windows, use: `$env:CLOUDSDK_PYTHON="...bundledpython/python.exe"` (see design/stitch/README.md section 6) |

---

## Next Steps

1. ✅ Global config is ready
2. ⏳ Complete ADC setup: `gcloud auth application-default login`
3. ⏳ Create your first new project and test Stitch MCP
4. ⏳ Use `ux-stitch` agent to generate your first screen

---

**Questions?** See `design/stitch/README.md` for detailed documentation on Stitch workflows and integration.
