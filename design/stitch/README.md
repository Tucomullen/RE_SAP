# Design / Stitch Integration — Operational Guide

**Last updated:** 2026-03-25
**Owner:** UX Designer + Kiro ux-stitch agent
**Related files:** `design/stitch/DESIGN.md`, `.kiro/agents/ux-stitch.json`, `.kiro/agents/ui5-fiori-bridge.json`, `knowledge/ux-stitch/README.md`

> **Connection status:** MCP infrastructure **validated and registered** as of 2026-03-25.
> **Global MCP config:** Stitch MCP configured globally at `~/.kiro/settings/mcp.json` (2026-03-27) — available in all projects.
> Auth: Google Cloud ADC via `tools/stitch-proxy.mjs` (forwarding proxy, `google-auth-library`).
> Workflow A (manual) is fully operational.
> Workflow B (MCP via Kiro) requires completing ADC authentication setup (see section 2).
> First screen generated: `design/stitch/exports/finance-dashboard-v0.1-2026-03-25.md` (legacy flat format).

---

## 1. Flujo actual y fuente de implementación

> **Principio fundamental:** La fuente principal para implementación UI5/Fiori es el artefacto real
> exportado por Stitch. El prompt original existe solo para trazabilidad, no como fuente de trabajo.

### Flujo completo

```
specs/ (verdad funcional)
    ↓  El diseñador UX o el agente ux-stitch lee los requisitos
design/stitch/prompts/  (capa de prompt — trazabilidad)
    ↓  [Workflow A] Prompt pegado manualmente en Stitch web UI
    ↓  [Workflow B — MCP] Prompt enviado vía MCP (Kiro → stitch-proxy.mjs → stitch.googleapis.com/mcp)
Google Stitch  (generación de pantalla)
    ↓  Pantalla generada, exportada como HTML + screenshot + JSON
design/stitch/exports/<screen-name>/  ← NUEVO ESTÁNDAR (carpeta por pantalla)
    ↓  screen.html ← FUENTE PRINCIPAL para ui5-fiori-bridge
    ↓  screenshot.png ← validación visual
    ↓  metadata.json / screen.json ← contexto estructural
    ↓  source-prompt.md ← solo trazabilidad
    ↓  traceability.md ← links a specs, pain points
    ↓  El agente ux-stitch revisa contra SAP constraints + pain points
    ↓  El agente ui5-fiori-bridge traduce HTML → SAP UI5 spec
design/stitch/screens/  (revisados y anotados)
    ↓  Validado por representante de persona
knowledge/ux-stitch/  (artefactos validados — autoritativos)
    ↓  Tareas de implementación generadas
specs/000-master-ifrs16-addon/tasks.md
```

### Precedencia de fuentes (para implementación UI5)

| Prioridad | Fuente | Rol |
|-----------|--------|-----|
| 1 | `screen.html` | **FUENTE PRINCIPAL** — layout, jerarquía, componentes, acciones |
| 2 | `screenshot.png` | **VALIDACIÓN VISUAL** — confirma fidelidad del HTML |
| 3 | `metadata.json` / `screen.json` | **CONTEXTO ESTRUCTURAL** — design system, versión, IDs |
| 4 | `source-prompt.md` | **SOLO TRAZABILIDAD** — no rediseñar desde aquí si HTML existe |

El límite entre `design/stitch/` (trabajo) y `knowledge/ux-stitch/` (validado) es intencional.
No mover artefactos a `knowledge/ux-stitch/` sin validación de persona.

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

**Pending manual steps (required for Workflow B):**

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

5. **Verify that ADC is usable**
   ```bash
   gcloud auth application-default print-access-token
   ```
   If this returns a token, ADC is working.

6. **Update `tools/stitch-proxy.mjs`** to use ADC for real calls, replacing the STITCH_API_KEY guard.
   Do not mark this as done until a real `tools/call` succeeds.

### `STITCH_API_KEY` — retained only as mock guard
The `.env` variable `STITCH_API_KEY` is still required by `tools/stitch-proxy.mjs` as an env-presence check.
It is **not** a working auth mechanism for the real Stitch MCP.

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

### Known real Stitch MCP tools (confirmed from `tools/list` 2026-03-25)

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

---

## 4. How to use prompts in design/stitch/prompts/

### Workflow A — Manual (no MCP, Stitch web UI)
1. Open the prompt file (e.g., [lease-contract-overview.md](prompts/lease-contract-overview.md)).
2. Copy the prompt section starting at `## Prompt`.
3. Paste into Google Stitch's generation input.
4. Export the result following the new folder standard (see section 5).
5. Save `screen.html`, `screenshot.png`, `metadata.json`, `screen.json` in the screen's folder.
6. `source-prompt.md` in the folder is for traceability — the exported HTML is the implementation source.

### Workflow B — Via MCP (ux-stitch agent in Kiro)
> Requires ADC auth setup (section 2). Confirm Kiro shows `stitch` as Connected before attempting.

1. Complete all steps in section 2 (gcloud ADC setup).
2. Confirm Kiro shows `stitch` as Connected (Settings → MCP Servers).
3. Open the `ux-stitch` agent in Kiro.
4. Ask the agent to generate the screen:
   ```
   Generate the Lease Contract Overview screen using the prompt in
   design/stitch/prompts/lease-contract-overview.md.
   Stitch project ID: 8885202212425441682
   ```
5. The agent will call `generate_screen_from_text` via MCP.
6. After generation, retrieve the screen via `get_screen` → save to `design/stitch/exports/<screen-name>/screen.html`.
7. Save screenshot and JSON. Populate `metadata.json`.

---

## 5. Estándar de export por pantalla (nuevo — obligatorio)

Cada pantalla generada por Stitch tiene su propia carpeta en `design/stitch/exports/`.

### Estructura de carpeta

```
design/stitch/exports/<screen-name>/
  screen.html          ← FUENTE PRINCIPAL para implementación UI5/Fiori
  screenshot.png       ← Validación visual (confirma fidelidad del HTML)
  metadata.json        ← Metadatos estructurales (design system, versión, IDs)
  screen.json          ← Export JSON completo de Stitch (si disponible)
  source-prompt.md     ← SOLO TRAZABILIDAD — no implementar desde aquí si HTML existe
  traceability.md      ← Links a specs, user stories, pain points
  README.md            ← Estado de la carpeta e instrucciones
```

### Reglas del estándar

- **`screen.html` es la fuente principal.** Si existe con contenido real, el agente `ui5-fiori-bridge` trabaja desde él.
- **`source-prompt.md` es solo trazabilidad.** No rediseñar desde el prompt si el HTML está disponible.
- **Si un archivo no puede obtenerse automáticamente**, dejar placeholder honesto con instrucción exacta de cómo completarlo.
- **No inventar artefactos.** Si Stitch no ha generado la pantalla aún, los archivos son placeholders documentados.
- **El agente `ui5-fiori-bridge` trabaja desde esta carpeta.** Ver `.kiro/agents/ui5-fiori-bridge.json` y `design/stitch/html-to-ui5-method.md`.

### Pantallas con carpeta creada

| Pantalla | Carpeta | Estado HTML | Estado |
|----------|---------|-------------|--------|
| Lease Contract Overview | [exports/lease-contract-overview/](exports/lease-contract-overview/) | ⬜ Placeholder | Prompt listo — export pendiente |

### Exports legacy (formato anterior)

Los siguientes archivos son exports del formato anterior (archivo plano `.md`).
Se mantienen como legado transitional. **No eliminar.**

| Archivo | Estado |
|---------|--------|
| `exports/finance-dashboard-v0.1-2026-03-25.md` | Legacy — raw export, no revisado. Mantener como histórico. |

Para migrar `finance-dashboard` al nuevo estándar: crear `exports/finance-dashboard/` y mover o referenciar el contenido. No borrar el `.md` original.

---

## 6. Known limitations and open issues

| Limitation | Details |
|-----------|---------|
| **Workflow B (MCP) requiere ADC setup** | Infraestructura validada pero el usuario debe completar `gcloud auth application-default login` antes de usar el agente ux-stitch para generación via MCP. |
| **screen.html no disponible para ninguna pantalla IFRS 16 aún** | Lease Contract Overview y demás pantallas tienen placeholders. El flujo HTML→UI5 no puede ejecutarse hasta el primer export real. |
| **ADC token expiry** | ADC tokens expire in ~1h. `google-auth-library` handles refresh automatically. If the proxy fails auth, re-run `gcloud auth application-default login`. |
| **`gcloud` requires Python** | On this Windows environment: `CLOUDSDK_PYTHON="$LOCALAPPDATA/Google/Cloud SDK/google-cloud-sdk/platform/bundledpython/python.exe" gcloud <cmd>`. |
| **`autoApprove` is empty** | No stitch tools are auto-approved. Kiro will prompt for confirmation on every MCP call. Intentional. |
| **DQ-02 open** | Fiori vs. WebDynpro scope not decided — afecta qué componentes UI5 son válidos. Ver `design/stitch/DESIGN.md` sección 13. |

---

## 7. Agentes relacionados

| Agente | Archivo | Rol en este flujo |
|--------|---------|-------------------|
| `ux-stitch` | `.kiro/agents/ux-stitch.json` | Genera pantallas en Stitch, valida contra pain points y SAP constraints |
| `ui5-fiori-bridge` | `.kiro/agents/ui5-fiori-bridge.json` | Traduce `screen.html` → spec SAP UI5 (XML View, controller, i18n, bindings) |

Método de traducción HTML→UI5: [design/stitch/html-to-ui5-method.md](html-to-ui5-method.md)

---

## 8. Recommended next steps

### Step 1 — Completar ADC setup para Workflow B
```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project northern-syntax-483410-v6
```
Confirmar: Kiro → Settings → MCP Servers → `stitch` aparece como Connected.

### Step 2 — Generar primera pantalla IFRS 16 real
Usar el agente `ux-stitch` para generar Lease Contract Overview.
Prompt listo: `design/stitch/prompts/lease-contract-overview.md`
Carpeta de export lista con placeholders: `design/stitch/exports/lease-contract-overview/`
Guardar: `screen.html`, `screenshot.png`, `metadata.json`, `screen.json`.

### Step 3 — Ejecutar agente ui5-fiori-bridge
Una vez que `screen.html` tenga contenido real, abrir el agente `ui5-fiori-bridge` en Kiro y proporcionar la ruta:
```
design/stitch/exports/lease-contract-overview/
```
El agente produce: XML View, controller responsibilities, i18n keys, data bindings, fidelity gaps.

### Step 4 — Revisar y validar
El agente `ux-stitch` revisa el output del bridge contra pain points y SAP constraints.
Persona representative valida.
Artefacto validado → `knowledge/ux-stitch/lease-contract-overview/`.

### Step 5 — Ampliar la biblioteca de prompts
Para cada Epic en `specs/000-master-ifrs16-addon/requirements.md` con interacciones UI,
crear prompt en `design/stitch/prompts/`.
Prioridad: Contract Intake Wizard, Period-End Trigger, Calculation Approval screen.
