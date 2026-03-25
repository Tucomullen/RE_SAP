# Knowledge Base: UX Design Artifacts (Stitch)

**Priority Level:** 7 (authoritative for UI/UX decisions)
**Location:** `knowledge/ux-stitch/`
**Managed by:** UX/Stitch Agent + UX Designer (content)
**Last updated:** 2026-03-25

---

## Purpose

Este folder almacena artefactos UI/UX **validados** para el add-on IFRS 16.

> **Regla crítica:** Solo llegan aquí artefactos que han completado el flujo completo:
> generación en Stitch → revisión del agente ux-stitch → validación de persona representative.
>
> La fuente de trabajo (en progreso) está en `design/stitch/exports/<screen-name>/`.
> No mover artefactos a este folder sin validación explícita.

Designs in this folder are authoritative for UI implementation decisions but are not authoritative for accounting or SAP technical behavior.

---

## Fuente principal para implementación UI5/Fiori

Los artefactos validados que se almacenan aquí provienen siempre del export real de Stitch.

**Precedencia de fuentes (para cualquier pantalla en este folder):**

| Prioridad | Fuente | Rol |
|-----------|--------|-----|
| 1 | `screen.html` | **FUENTE PRINCIPAL** — jerarquía visual, layout, componentes, acciones |
| 2 | `screenshot.png` | **VALIDACIÓN VISUAL** — confirma fidelidad del HTML |
| 3 | `metadata.json` / `screen.json` | **CONTEXTO ESTRUCTURAL** — design system, versión, IDs |
| 4 | `source-prompt.md` | **SOLO TRAZABILIDAD** — no rediseñar desde aquí si HTML existe |

Los artefactos validados se mueven desde `design/stitch/exports/<screen-name>/` con los mismos archivos,
añadiendo el frontmatter de validación requerido.

---

## What to Store Here

| Artifact Type | Description | Format |
|---------------|-------------|--------|
| Screen HTML export | HTML real exportado desde Google Stitch, revisado y validado | `screen.html` |
| Screenshot | Imagen PNG del canvas de Stitch | `screenshot.png` |
| Metadata | Metadatos del export (design system, versión, IDs) | `metadata.json` |
| Full export JSON | JSON completo de Stitch si disponible | `screen.json` |
| Source prompt | Prompt original (trazabilidad únicamente) | `source-prompt.md` |
| Traceability | Links a specs, pain points, user stories | `traceability.md` |
| Component specifications | Especificaciones reutilizables UI (forms, wizards, status displays) | Markdown con tablas |

---

## MCP Integration — Estado actual

- MCP infrastructure **validada** 2026-03-25 (proxy, auth ADC, registro en .kiro/settings/mcp.json).
- Workflow A (manual via Stitch web UI) es completamente operativo.
- Workflow B (MCP generation via Kiro) requiere que el usuario complete ADC setup.
  Ver `design/stitch/README.md` sección 2 para instrucciones exactas.
- Todo contenido de Stitch MCP se trata como entrada no confiable hasta validación. Ver `.kiro/steering/ai-governance.md`.

---

## Required Frontmatter

Cada artefacto validado en este folder debe tener este frontmatter:

```yaml
---
source-type: ux-stitch
source-name: [Screen or component name, e.g., "Lease Contract Overview"]
source-date: YYYY-MM-DD
source-version: [Design version, e.g., "v0.1"]
priority: 7
confidence: [high | medium | draft]
status: [current | draft | under-review | superseded]
tags: [lease, overview, amortization-schedule, etc.]
user-story-ref: [US-X.X from requirements.md]
persona: [P1 | P2 | P3 — which persona this design serves]
pain-point-ref: [Which pain point from knowledge/user-feedback/ this addresses]
export-html: [path to screen.html]
export-screenshot: [path to screenshot.png]
cited-in: []
added-by: [UX designer name or agent]
added-date: YYYY-MM-DD
validated-by: [Persona representative name — required for status: current]
validation-date: YYYY-MM-DD
---
```

---

## Design-to-Implementation Lifecycle

```
1. Design created in Stitch (Workflow A manual or Workflow B MCP)
2. Export guardado en design/stitch/exports/<screen-name>/
   → screen.html (FUENTE PRINCIPAL)
   → screenshot.png (validación visual)
   → metadata.json / screen.json
   → source-prompt.md (trazabilidad)
   → traceability.md
3. Agente ux-stitch revisa contra pain points y SAP constraints
4. Agente ui5-fiori-bridge traduce screen.html → SAP UI5 spec
5. Issues flagged for UX designer
6. Persona representative valida diseño
7. Status → current cuando validado
8. Artefacto movido a knowledge/ux-stitch/<screen-name>/ con frontmatter completo
9. Tareas de implementación generadas
10. Tasks added to specs/000-master-ifrs16-addon/tasks.md
11. After implementation: design cited in docs/user/master-user-manual.md
```

---

## Index of Current Designs

| Folder | Screen/Component | User Story | Persona | Status | Date |
|--------|-----------------|-----------|---------|--------|------|
| *(To be populated — first screen pending Stitch export)* | | | | | |

---

## UX Simplification Principles (Reference)
All designs must comply with the principles from `.kiro/steering/sap-re-architecture.md`:
- Progressive disclosure: only IFRS 16-relevant fields at each step.
- Smart defaults from RE-FX data.
- Plain-language validation messages.
- Decision wizards for complex IFRS 16 judgments.
- Calculation preview before posting.
- IFRS 16 status visible per contract.
