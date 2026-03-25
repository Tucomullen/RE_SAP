# Source Prompt — Lease Contract Overview

> **PROPÓSITO:** Este archivo existe únicamente para **trazabilidad**.
> NO es la fuente de implementación. La fuente principal es `screen.html`.
>
> Si `screen.html` existe en esta carpeta: trabaja desde el HTML.
> Solo consulta este prompt si el HTML no define algún comportamiento específico.

---

**Referencia:** Este prompt es una copia de `design/stitch/prompts/lease-contract-overview.md` (v0.1, 2026-03-25).

Para el prompt completo y actualizado, ver siempre el archivo original:
→ [design/stitch/prompts/lease-contract-overview.md](../../prompts/lease-contract-overview.md)

---

## Resumen del prompt (para referencia rápida)

- **Pantalla:** Lease Contract Overview
- **Historias de usuario:** US-1.2, US-2.1
- **Personas:** P1 (Lease Accountant), P2 (RE Contract Manager)
- **Pain points cubiertos:** PP-D, PP-G, PP-B
- **Zonas de la pantalla:**
  1. Contract Header (strip superior, read-only)
  2. IFRS 16 Parameters Panel (columna izquierda ~35%)
  3. Amortization Schedule (columna derecha ~65%)
  4. Pending Actions and Notifications (barra inferior)
- **Estados a diseñar:** 6 (Normal / Pending Approval / Remeasurement Triggered / Draft / Blocked / Exempt)
- **Target:** SAP Fiori Freestyle, ECC WebDynpro fallback

---

## Regla de precedencia

| Fuente | Rol |
|--------|-----|
| `screen.html` | FUENTE PRINCIPAL — jerarquía visual, componentes, layout |
| `screenshot.png` | VALIDACIÓN VISUAL — confirma fidelidad del HTML |
| `metadata.json` / `screen.json` | CONTEXTO ESTRUCTURAL — design system, versión, IDs |
| `source-prompt.md` (este archivo) | SOLO TRAZABILIDAD — no rediseñar desde aquí si HTML existe |
