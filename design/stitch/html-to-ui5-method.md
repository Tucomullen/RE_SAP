# HTML → SAP UI5/Fiori Translation Method

**Version:** 1.0
**Date:** 2026-03-25
**Owner:** ui5-fiori-bridge agent + UX Designer
**Applies to:** All screens exported from Google Stitch for the RE-SAP IFRS 16 Add-On

---

## 1. Principio de precedencia de fuentes

Cuando existe un export real de Stitch, la fuente principal es siempre el artefacto exportado.
**Nunca rediseñar desde un prompt cuando ya existe un HTML.**

| Prioridad | Fuente | Rol |
|-----------|--------|-----|
| 1 | `screen.html` | **FUENTE PRINCIPAL** — jerarquía visual, layout, zonas, componentes, acciones, estados |
| 2 | `screenshot.png` | **VALIDACIÓN VISUAL** — confirma que el XML View es fiel a la imagen real |
| 3 | `metadata.json` / `screen.json` | **CONTEXTO ESTRUCTURAL** — design system, versión, IDs de pantalla |
| 4 | `source-prompt.md` | **SOLO TRAZABILIDAD** — usar solo cuando el HTML no define un comportamiento específico |
| 5 | `design/stitch/DESIGN.md` | **CONTRATO DE DISEÑO** — constraints SAP obligatorias para toda pantalla |

> **Regla de oro:** Si `screen.html` existe con contenido real, el HTML manda.
> `source-prompt.md` puede complementar comportamientos no expresables en HTML (lógica de negocio, condicionales de servidor),
> pero nunca sustituye la estructura visual definida en el HTML.

---

## 2. Reglas de traducción HTML → SAP UI5

### 2.1 Layout

| HTML pattern | UI5 Component | Notas |
|---|---|---|
| `<body>` con header fijo + contenido | `sap.m.Page` | Para páginas simples con barra de acciones |
| Header dinámico que colapsa al scroll | `sap.f.DynamicPage` | [Fiori-ready — ECC alternative needed] |
| Página multi-sección con ObjectHeader | `sap.uxap.ObjectPageLayout` | [Fiori-ready — ECC alternative needed] |
| Contenedor horizontal | `sap.m.HBox` | Usar `wrap: true` para responsividad |
| Contenedor vertical | `sap.m.VBox` | |
| Grid de 12 columnas | `sap.ui.layout.Grid` | `defaultSpan="L4 M6 S12"` para responsividad |
| Dos columnas (35% + 65%) | `sap.ui.layout.Grid` con `span="L4"` y `span="L8"` | |
| Panel expandible | `sap.m.Panel` con `expandable: true` | |

### 2.2 Formularios y campos

| HTML pattern | UI5 Component | Notas |
|---|---|---|
| Sección de campos con labels | `sap.ui.layout.form.SimpleForm` | Para formularios sencillos |
| Formulario complejo con grupos | `sap.ui.layout.form.Form` + `sap.ui.layout.form.FormContainer` | |
| Label + valor de solo lectura | `sap.m.Label` + `sap.m.Text` | |
| Label + valor con semántica | `sap.m.Label` + `sap.m.ObjectAttribute` | |
| Campo editable de texto | `sap.m.Input` | |
| Campo de fecha | `sap.m.DatePicker` | |
| Campo numérico / importe | `sap.m.Input` con `type: Number` | |
| Campo de selección | `sap.m.Select` o `sap.m.ComboBox` | |
| Campo de solo lectura bloqueado | `sap.m.Text` (no Input disabled) | No usar inputs deshabilitados para datos bloqueados |
| Indicador requerido (*) | `required: true` en `sap.m.Label` | |

### 2.3 Tablas

| Caso | UI5 Component | Cuándo usar |
|---|---|---|
| Tabla densa con muchas filas, columnas fijas | `sap.ui.table.Table` | **ECC-realistic para listas ALV-like** |
| Lista responsive, mobile-friendly | `sap.m.Table` + `sap.m.ColumnListItem` | Para listas simples o mobile |
| SmartTable con OData V4 | `sap.ui.comp.smarttable.SmartTable` | [Fiori-ready — ECC alternative needed] |

**Regla de selección:**
- Si la tabla tiene >10 columnas o >50 filas esperadas → `sap.ui.table.Table`
- Si la tabla es un listado responsive simple → `sap.m.Table`
- Si el proyecto es 100% Fiori/OData V4 → `SmartTable` (marcar con flag)

**Columnas de tabla (siempre incluir):**
```xml
<table:Column width="...">
  <Label text="{i18n>columnKey}" />
  <table:template>
    <Text text="{model>/fieldName}" />
  </table:template>
</table:Column>
```

### 2.4 Barras de acción (Action Bar)

```xml
<!-- Patrón estándar: acciones primarias a la derecha -->
<footer>
  <Bar>
    <contentRight>
      <Button type="Reject" text="{i18n>btnReject}" press=".onReject" />
      <Button type="Default" text="{i18n>btnSaveDraft}" press=".onSaveDraft" />
      <Button type="Emphasized" text="{i18n>btnApprove}" press=".onApprove" />
    </contentRight>
  </Bar>
</footer>
```

Reglas:
- Acción primaria (Emphasized) siempre al extremo derecho.
- Acciones destructivas (Reject, Cancel) siempre con `type="Reject"` o confirmación.
- "View Audit Log" es una acción siempre visible — no ocultarla condicionalmente.

### 2.5 Badges de estado

```xml
<!-- ObjectStatus para estados de contrato -->
<ObjectStatus
  text="{i18n>statusActive}"
  state="Success"
  inverted="true" />
```

| Estado IFRS 16 | SAP UI5 `state` |
|---|---|
| Active | `Success` |
| Approved / Posted | `Success` |
| Pending Review | `Warning` |
| Draft | `None` |
| Rejected / Blocked | `Error` |
| Exempt | `Information` |
| Rescinded | `None` (con texto diferenciado) |

### 2.6 Diálogos de confirmación

Para toda acción de aprobación o acción destructiva:
```xml
<Dialog
  title="{i18n>dlgApproveTitle}"
  type="Message"
  state="Warning">
  <content>
    <Text text="{i18n>dlgApproveBody}" />
  </content>
  <buttons>
    <Button text="{i18n>btnConfirm}" type="Emphasized" press=".onConfirmApprove" />
    <Button text="{i18n>btnCancel}" press=".onCancelDialog" />
  </buttons>
</Dialog>
```

Reglas:
- Siempre mostrar qué se está aprobando (nombre del contrato, período, importe afectado).
- Siempre incluir nombre del aprobador (de sesión SAP) y timestamp.
- `type="Message"` para confirmaciones informativas.
- `state="Warning"` para acciones irreversibles.

### 2.7 Breadcrumbs

```xml
<Breadcrumbs>
  <Link text="{i18n>appTitle}" press=".onNavToHome" />
  <Link text="{i18n>contractList}" press=".onNavToList" />
  <Text text="{contractNumber}" />
</Breadcrumbs>
```

### 2.8 MessageStrip para notificaciones

```xml
<MessageStrip
  text="{i18n>warningIbrExpired}"
  type="Warning"
  showIcon="true"
  showCloseButton="false" />
```

---

## 3. Criterios de fidelidad

Al comparar el XML View generado con `screenshot.png`:

| Criterio | Obligatorio | Descripción |
|----------|-------------|-------------|
| Número de zonas/secciones | ✅ Sí | El XML debe tener las mismas zonas que el HTML/screenshot |
| Orden de zonas | ✅ Sí | Top → bottom, left → right debe coincidir |
| Tabla de amortización visible en pantalla principal | ✅ Sí | No moverla a un tab si el diseño la muestra en la pantalla principal |
| Columnas de tablas | ✅ Sí | Mismas columnas, mismo orden |
| Labels de campos | ✅ Sí | Texto idéntico al HTML (traducir a i18n key pero mantener valor) |
| Acciones en la barra de acción | ✅ Sí | Mismas acciones, mismo orden |
| Badges de estado | ✅ Sí | Mismo set de estados, misma semántica |
| Detalles decorativos de CSS | ❌ No | El UI5 puede diferir en colores exactos del tema Fiori |
| Tipografía exacta | ❌ No | SAP 72 es el estándar; no hardcodear fuentes |
| Spacing pixel-exact | ❌ No | SAP Fiori theme gestiona el spacing |

---

## 4. Cómo documentar diferencias inevitables

Toda diferencia entre el HTML de Stitch y la implementación UI5 debe documentarse en la sección
**"Fidelity Gaps"** del output del agente `ui5-fiori-bridge`.

Formato para cada gap:

```
| Gap ID | HTML define | SAP UI5/ECC restricción | Alternativa propuesta | Severidad |
|--------|-------------|------------------------|----------------------|-----------|
| GAP-01 | FilterBar con inputs inline en tabla | FilterBar requiere OData V4 en ECC | sap.m.SearchField + sap.m.MultiComboBox sobre la tabla | MINOR |
```

Severidades:
- **CRITICAL:** El gap cambia el comportamiento funcional (no solo la apariencia). Requiere decisión del equipo.
- **MINOR:** Diferencia visual que no afecta la funcionalidad. Proponer alternativa ECC.
- **COSMETIC:** Diferencia de estilo puro (colores, spacing, tipografía). Aceptar y documentar.

---

## 5. Cuándo usar sap.m vs sap.ui.table

### Usa `sap.m.Table` cuando:
- Lista de <50 filas esperadas
- Responsive design es prioritario (tablet / mobile)
- Columnas simples (< 6-8 columnas)
- Tipo: listado de contratos en vista móvil, listas de selección

### Usa `sap.ui.table.Table` cuando:
- Tabla densa al estilo ALV con muchas columnas y filas
- Sorting y filtering nativo de columnas necesario
- Frozen columns o column resizing necesario
- Tipo: amortization schedule, audit log, contract list principal

### Marca como `[Fiori-ready — ECC alternative needed]` cuando:
- SmartTable con OData V4 y annotations
- FilterBar de Fiori Elements
- ObjectPage con automatic binding
- AnalyticalTable

---

## 6. Tratamiento de componentes específicos

### Tablas de amortización (Amortization Schedule)
- Usar `sap.ui.table.Table` (ECC-realistic).
- Columnas: Period / Date Range / Opening Balance / Interest / Payment / Closing Balance / ROU Depreciation / Status.
- Fila actual: resaltar con `highlight: Indication01` en `sap.ui.table.Row`.
- Filas posteadas: `sap.m.ObjectStatus state="Success"` en columna Status.
- Footer con totales: `sap.ui.table.RowAction` o row dedicada con estilo de total.
- Toolbar: `sap.m.OverflowToolbar` con `sap.m.Button` "Export to Excel" (usa `sap.ui.export.Spreadsheet`).

### Formularios de parámetros IFRS 16
- Usar `sap.ui.layout.form.SimpleForm` con `editable: false` para vista read-only.
- Secciones separadas por `sap.ui.layout.form.FormContainer` con title.
- Para campos con nota de fuente (ej. IBR con "Treasury — approved"): usar `sap.m.ObjectAttribute` con `title` y `text`.
- Cálculos con run ID: `sap.m.Link` para el run ID (navega al detalle del run).

### Barras de notificación / Pending Actions
- Si hay ≤3 notificaciones fijas: `sap.m.MessageStrip` apilados en un `sap.m.VBox`.
- Si hay lista dinámica de notificaciones: `sap.m.NotificationListItem` dentro de `sap.m.NotificationList`.
- Empty state: `sap.m.Text` con texto "No pending actions for this contract."

### Breadcrumbs
- Siempre usar `sap.m.Breadcrumbs` en el `subHeader` o `customData` del `sap.m.Page`.
- Formato: `App Title > Contract List > [Contract Number]`.

### Badges / ObjectStatus en headers
- Para el badge de estado principal del contrato (prominente): `sap.m.ObjectStatus` con `inverted: true`.
- Para estados de fila en tablas: `sap.m.ObjectStatus` sin invertir.

---

## 7. Cómo marcar componentes `[Fiori-ready — ECC alternative needed]`

Cuando un componente requiere Fiori Elements o OData V4 y no es implementable directamente en ECC WebDynpro, usar este marcador en comentarios del XML View y en la sección "SAP/ECC Restrictions" del output:

```xml
<!-- [Fiori-ready — ECC alternative needed]
     Stitch uses: FilterBar (sap.ui.comp.filterbar.FilterBar)
     ECC alternative: sap.m.SearchField + sap.m.MultiComboBox inline toolbar
     Decision required: confirm scope before implementing
-->
```

Y en la sección de restricciones del spec:
```
| Component | Fiori version | ECC alternative | Decision needed |
|---|---|---|---|
| Filter Bar | sap.ui.comp.filterbar.FilterBar | Inline toolbar with SearchField + dropdowns | Yes — Phase 0 decision DQ-02 |
```

---

## 8. Limitaciones conocidas y pendientes

| Limitación | Estado | Nota |
|-----------|--------|------|
| DQ-02: Fiori vs. WebDynpro scope | Open | Determina si se usa `sap.ui.comp` o solo `sap.m` + `sap.ui.table` |
| DQ-03: ALV column config | Open | Afecta configuración exacta de columnas en contract list |
| screenshot.png no disponible aún | Pending | No hay validación visual hasta que se exporte la primera pantalla real |
| screen.html no disponible aún | Pending | Este método no puede ejecutarse hasta que existan exports reales de Stitch |
