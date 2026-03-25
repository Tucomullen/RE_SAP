# Placeholder — screenshot.png

**Este archivo es un marcador de posición.**

El archivo real `screenshot.png` debe ser una imagen PNG del canvas de Stitch
que muestre la pantalla **Lease Contract Overview** generada.

## Cómo obtener screenshot.png

**Desde Stitch web UI:**
1. Genera la pantalla con el prompt en `source-prompt.md`.
2. En el canvas de Stitch, usa "Export" → "PNG" o captura de pantalla del canvas completo.
3. Guarda la imagen como `screenshot.png` en esta misma carpeta.
4. Elimina este archivo placeholder una vez que `screenshot.png` exista.

**Desde MCP:**
- El agente `ux-stitch` puede obtener una representación visual vía `get_screen`.
- Si Stitch devuelve una URL de imagen, descárgala y guárdala como `screenshot.png`.

## Uso de screenshot.png

- Usado por el agente `ui5-fiori-bridge` como **validación visual**.
- El agente contrasta la fidelidad del XML View generado contra esta imagen.
- NO es la fuente principal — `screen.html` tiene precedencia.
- Es esencial para detectar diferencias entre el HTML y la representación visual real de Stitch.
