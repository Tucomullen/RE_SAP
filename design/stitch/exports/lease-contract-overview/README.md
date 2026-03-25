# Export — Lease Contract Overview

**Screen:** Lease Contract Overview
**Status:** `placeholder — awaiting real Stitch export`
**Last updated:** 2026-03-25
**Source prompt:** [source-prompt.md](source-prompt.md)
**Linked spec:** [specs/000-master-ifrs16-addon/requirements.md](../../../../specs/000-master-ifrs16-addon/requirements.md) — US-1.2, US-2.1

---

## Estado de esta carpeta

Esta carpeta sigue el estándar de export estructurado por pantalla.
Actualmente contiene **placeholders** porque la pantalla aún no ha sido exportada desde Google Stitch.

| Archivo | Estado | Instrucción |
|---------|--------|-------------|
| `screen.html` | ⬜ PENDIENTE | Ver instrucción de export abajo |
| `screenshot.png` | ⬜ PENDIENTE | Ver instrucción de export abajo |
| `metadata.json` | ⬜ PENDIENTE | Ver instrucción de export abajo |
| `screen.json` | ⬜ PENDIENTE | Ver instrucción de export abajo |
| `source-prompt.md` | ✅ Presente | Prompt original de Stitch (solo trazabilidad) |
| `traceability.md` | ✅ Presente | Links a specs y pain points |

---

## Cómo completar esta carpeta (instrucción exacta)

### Opción A — Via MCP (ux-stitch agent en Kiro)

1. Abre el agente `ux-stitch` en Kiro.
2. Asegura que `gcloud auth application-default login` está completado.
3. Solicita al agente:
   ```
   Generate the Lease Contract Overview screen using the prompt in
   design/stitch/exports/lease-contract-overview/source-prompt.md.
   Stitch project ID: 8885202212425441682
   ```
4. El agente llamará `generate_screen_from_text` via MCP.
5. Guarda el resultado así:
   - HTML del screen → `screen.html` (FUENTE PRINCIPAL para UI5)
   - Screenshot/imagen → `screenshot.png` (VALIDACIÓN VISUAL)
   - JSON completo del export → `screen.json`
   - Extrae metadata → `metadata.json` (ver formato abajo)

### Opción B — Manual (Stitch web UI)

1. Abre [https://stitch.google.com](https://stitch.google.com) y el proyecto `re-sap-ifrs16`.
2. Copia el contenido de `source-prompt.md` (sección `## Prompt`) y pégalo en la interfaz de generación.
3. Genera la pantalla.
4. Desde la pantalla generada, exporta:
   - **HTML:** botón "Export" → "HTML" → guarda como `screen.html`
   - **Screenshot:** captura de pantalla del canvas → guarda como `screenshot.png`
   - **JSON:** si Stitch ofrece export JSON → guarda como `screen.json`
5. Rellena `metadata.json` manualmente (ver formato abajo).

---

## Formato requerido para metadata.json

Cuando guardes el export real, crea `metadata.json` con esta estructura mínima:

```json
{
  "screen_name": "Lease Contract Overview",
  "screen_id": "",
  "stitch_project_id": "8885202212425441682",
  "stitch_project_name": "re-sap-ifrs16",
  "design_system": "",
  "version": "0.1",
  "generated_date": "YYYY-MM-DD",
  "generated_by": "Google Stitch MCP",
  "prompt_file": "source-prompt.md",
  "user_stories": ["US-1.2", "US-2.1"],
  "personas": ["P1", "P2"],
  "pain_points": ["PP-A", "PP-B"],
  "status": "raw-export",
  "reviewed_by": null,
  "review_date": null,
  "notes": ""
}
```

---

## Flujo de esta pantalla después del export

```
[Export completado] → screen.html + screenshot.png + metadata.json guardados aquí
    ↓
[Agente ux-stitch revisa] → valida contra SAP constraints + pain points
    ↓
[Agente ui5-fiori-bridge procesa screen.html] → genera spec XML View + controller
    ↓
[Persona representative valida] → status: validated
    ↓
[Artefacto validado movido a] → knowledge/ux-stitch/lease-contract-overview/
```

---

## Regla de precedencia de fuentes (para implementación)

1. `screen.html` — **FUENTE PRINCIPAL** — define layout, jerarquía, componentes, acciones
2. `screenshot.png` — **VALIDACIÓN VISUAL** — confirma fidelidad del HTML
3. `metadata.json` / `screen.json` — **CONTEXTO ESTRUCTURAL** — design system, IDs, version
4. `source-prompt.md` — **SOLO TRAZABILIDAD** — NO rediseñar desde el prompt si ya existe HTML

> **Regla crítica:** Si `screen.html` existe, el agente `ui5-fiori-bridge` debe trabajar desde el HTML.
> Solo recurre a `source-prompt.md` cuando el HTML no define suficiente detalle sobre comportamiento.
