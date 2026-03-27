# Plantilla de Política Contable IFRS 16
## Documento para Completar y Firmar — Workshop T0-01

**Proyecto:** RE-SAP IFRS 16 Lease Accounting Addon
**Versión:** DRAFT — Para completar en workshop T0-01
**Responsable de completar:** IFRS 16 Accountant
**Aprobación requerida:** Finance Controller / CFO (según estructura de gobernanza del cliente)
**Estado:** ☐ DRAFT  ☐ EN REVISIÓN  ☐ FIRMADO

> **INSTRUCCIONES:** Complete cada sección. Los campos marcados con `[REQUERIDO]` son obligatorios para el inicio de Phase 1. Los campos `[OPCIONAL]` pueden completarse en una fecha posterior pero deben tener owner y fecha de resolución asignados. Al finalizar, firme en la sección de Aprobaciones.

---

## Sección 1 — Identificación del Documento

| Campo | Valor |
|-------|-------|
| Nombre del grupo empresarial | `[REQUERIDO]` ________________________ |
| Ejercicio fiscal aplicable | `[REQUERIDO]` Desde ________ Hasta ________ |
| Fecha de primera adopción IFRS 16 | `[REQUERIDO]` ________________________ |
| Marco contable principal | `[REQUERIDO]` ☐ IFRS  ☐ PGC  ☐ US GAAP ASC 842  ☐ Múltiple |
| Versión del documento | `[REQUERIDO]` ________________________ |
| Fecha de aprobación | `[REQUERIDO]` ________________________ |

---

## Sección 2 — Alcance y Reconocimiento

### 2.1 Tipos de contratos en scope IFRS 16

`[REQUERIDO]` Marcar los tipos de contrato que están en scope IFRS 16:

| Tipo | ¿En scope? | Sociedad(es) afectada(s) | Observaciones |
|------|-----------|--------------------------|---------------|
| Arrendamientos de edificios / locales | ☐ Sí  ☐ No | ________________________ | |
| Arrendamientos de terrenos | ☐ Sí  ☐ No | ________________________ | |
| Arrendamientos de vehículos (renting) | ☐ Sí  ☐ No | ________________________ | |
| Arrendamientos de equipos informáticos | ☐ Sí  ☐ No | ________________________ | |
| Arrendamientos de maquinaria industrial | ☐ Sí  ☐ No | ________________________ | |
| Arrendamientos de otros bienes muebles | ☐ Sí  ☐ No | ________________________ | |
| Contratos de servicios con componente de arrendamiento | ☐ Sí  ☐ No | ________________________ | |
| Licencias de activos intangibles | ☐ Sí  ☐ No | ________________________ | |

### 2.2 Exenciones aplicadas

`[REQUERIDO]` Exenciones de IFRS 16.5:

| Exención | ¿Se aplica? | Criterio de aplicación |
|---------|------------|----------------------|
| Arrendamientos corto plazo (< 12 meses) | ☐ Sí  ☐ No | ________________________ |
| Activos de bajo valor (< USD 5.000) | ☐ Sí  ☐ No | Umbral definido: ____________ |
| Umbral de bajo valor por tipo de activo | ☐ Único  ☐ Por tipo | Detalle: ________________________ |

### 2.3 Contratos multicomponente

`[REQUERIDO]`

¿Existen contratos con componentes de arrendamiento + servicios en el portfolio?
☐ No existen en el portfolio
☐ Sí existen — se aplica practical expedient (IFRS 16.15): todo el contrato como arrendamiento
☐ Sí existen — se separan los componentes manualmente

Impacto en sistema: ________________________

---

## Sección 3 — Medición Inicial

### 3.1 Tasa de Descuento (IBR)

`[REQUERIDO]`

**¿Quién determina el IBR?**
☐ Departamento de Treasury  ☐ Accounting  ☐ Consultor externo  ☐ Otro: ____________

**Granularidad del IBR:**
☐ Una tasa única para todo el grupo
☐ Por sociedad (BUKRS)
☐ Por sociedad y moneda
☐ Por sociedad, moneda y plazo
☐ Otra: ________________________

**Frecuencia de revisión de tasas:**
☐ Por contrato (cada nuevo contrato)  ☐ Trimestral  ☐ Semestral  ☐ Anual  ☐ Otra: ____________

**¿Existe tabla de IBRs vigentes aprobada?**
☐ Sí — adjuntar como Anexo A
☐ No — se elaborará antes de: ________________________

**IBRs actualmente en uso (si disponibles):**

| Sociedad | Moneda | Plazo (años) | IBR (%) | Fecha de vigencia | Aprobado por |
|---------|--------|-------------|---------|------------------|-------------|
| ________ | _______ | ________ | _______ % | _____________ | ____________ |
| ________ | _______ | ________ | _______ % | _____________ | ____________ |
| ________ | _______ | ________ | _______ % | _____________ | ____________ |

**¿Se aplica el mismo IBR a contratos existentes migrados?**
☐ Sí — se usa el IBR vigente en la fecha de comienzo original del contrato
☐ No — se usa el IBR a la fecha de migración
☐ Otro criterio: ________________________

### 3.2 Costes Directos Iniciales (IDC)

`[REQUERIDO]`

¿Los costes directos iniciales (comisiones, honorarios de negociación) se incluyen en el cálculo del ROU asset?
☐ Sí — campo obligatorio en sistema
☐ Sí — campo opcional, solo cuando materiales
☐ No — fuera de scope

¿Se tracean actualmente en ECC?
☐ Sí  ☐ No

### 3.3 Anticipos / Pagos por Adelantado

`[REQUERIDO]`

¿Existen contratos con pagos de renta por adelantado (anticipo) que deban incluirse en el ROU asset?
☐ Sí — frecuentes  ☐ Sí — ocasionales  ☐ No

Tratamiento contable:
☐ Total anticipo: ROU reconocido, liability creada y revertida inmediatamente
☐ Anticipo parcial: ROU = valor completo; liability = valor neto
☐ Otro: ________________________

Países / sociedades con reglas específicas de anticipo: ________________________

---

## Sección 4 — Medición Posterior

### 4.1 Opciones de Renovación y Terminación

`[REQUERIDO]`

**Definición del umbral "REASONABLY CERTAIN":**

☐ Definición cuantitativa: Probabilidad > ________ %
☐ Definición cualitativa: Criterios:
  - ☐ Ubicación estratégica / no sustituible
  - ☐ Coste de traslado significativo
  - ☐ Dependencia operacional del activo
  - ☐ Cláusula de renovación automática salvo aviso contrario
  - ☐ Otro: ________________________

☐ Evaluación caso a caso con documentación obligatoria por contrato

**Proceso de revisión periódica de opciones:**
Frecuencia: ________________________
Responsable: ________________________

### 4.2 Rentas Variables e Indexadas

`[REQUERIDO]`

¿Existen contratos con ajustes de renta por IPC u otro índice?
☐ Sí  ☐ No

Tratamiento según IFRS 16.42(b): ¿el ajuste IPC siempre desencadena una remedición?
☐ Sí — siempre que se actualiza la renta por índice
☐ No — solo cuando el cambio es material (umbral: ________)
☐ Según criterio del accountant caso a caso

### 4.3 Linearización de Gastos (Rentas Escalonadas)

`[REQUERIDO]`

¿Se requiere linearización de gastos para contratos con rentas escalonadas?
☐ Sí — requerida para todos los contratos
☐ Sí — solo para contratos bajo PGC local
☐ No — se usa el importe real de cada período

### 4.4 Modificaciones y Remediciones

`[REQUERIDO]`

Tipos de modificación que siempre desencadenan remedición:
☐ Extensión del plazo del contrato
☐ Reducción del alcance (scope reduction)
☐ Cambio de renta no vinculado a índice
☐ Cambio de moneda del contrato
☐ Ejercicio de opción de renovación
☐ Ejercicio de opción de compra
☐ Otro: ________________________

---

## Sección 5 — Marco Multi-GAAP

### 5.1 Mapa de Sociedades y GAAP Aplicable

`[REQUERIDO — bloqueante para arquitectura de CD-04]`

| Sociedad (BUKRS) | País | GAAP Principal | PGC paralelo | US GAAP paralelo | Parallel Ledger activo |
|-----------------|------|---------------|-------------|-----------------|----------------------|
| ____________ | ____ | IFRS / PGC / USGAAP | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |
| ____________ | ____ | IFRS / PGC / USGAAP | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |
| ____________ | ____ | IFRS / PGC / USGAAP | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |
| ____________ | ____ | IFRS / PGC / USGAAP | ☐ Sí ☐ No | ☐ Sí ☐ No | ☐ Sí ☐ No |

### 5.2 US GAAP ASC 842 — Estimación IPC

`[REQUERIDO solo si existen sociedades US GAAP]`

Metodología de estimación de IPC para valoración inicial de contratos US GAAP:
☐ IPC histórico promedio N años: ________ años, fuente: ________________________
☐ IPC objetivo del banco central: ________ %
☐ IPC proyectado por Treasury: adjuntar tabla
☐ Otro: ________________________

Responsable de aprobar la tasa IPC estimada: ________________________

---

## Sección 6 — Presentación y Divulgación

### 6.1 Clasificación en Balance

`[REQUERIDO]`

Cuentas contables principales para IFRS 16:

| Concepto | Cuenta GL | Observaciones |
|---------|-----------|---------------|
| Activo por derecho de uso (ROU) — corriente | ____________ | |
| Activo por derecho de uso (ROU) — no corriente | ____________ | |
| Pasivo por arrendamiento — corriente (< 12m) | ____________ | |
| Pasivo por arrendamiento — no corriente (> 12m) | ____________ | |
| Gasto por interés | ____________ | |
| Gasto de amortización ROU | ____________ | |
| Ajuste PGC / local GAAP | ____________ | |

### 6.2 Períodos de Presentación

Frecuencia de reclasificación corriente/no corriente:
☐ Mensual  ☐ Trimestral  ☐ Semestral  ☐ Anual

Proceso de revisión de lease term para disclosure anual:
Responsable: ________________________  Fecha en año fiscal: ________________________

---

## Sección 7 — Ámbito de Aplicación del Proyecto

### 7.1 Contratos Fuera de Scope Explícito

`[OPCIONAL en T0-01 — requerido antes de spec CD-01]`

Listar categorías de contratos que quedan explícitamente fuera del scope del addon Z:

| Tipo de contrato | Razón de exclusión | Sistema de gestión actual |
|-----------------|-------------------|--------------------------|
| ________________________ | ________________________ | ________________________ |
| ________________________ | ________________________ | ________________________ |

### 7.2 Scope Futuro (Phase 2 / Phase 3)

| Capacidad | Fase objetivo | Responsable |
|---------|--------------|-------------|
| Deterioro / Impairment de ROU | ________________________ | ________________________ |
| Opción de compra | ________________________ | ________________________ |
| Disclosure pack automático | ________________________ | ________________________ |
| AI assistant para scope determination | Phase 3 | IFRS 16 Accountant + Legal |

---

## Sección 8 — Firma y Aprobación

> Al firmar este documento, el IFRS 16 Accountant confirma que la política contable descrita en este documento es la política vigente y autorizada del grupo para el tratamiento de arrendamientos bajo IFRS 16, y que el sistema Z addon debe implementar dicha política tal como aquí se define.

| Rol | Nombre | Firma | Fecha |
|-----|--------|-------|-------|
| IFRS 16 Accountant (autor) | ________________________ | ____________ | ____________ |
| Finance Controller (aprobación) | ________________________ | ____________ | ____________ |
| Project Governance Lead (notificado) | ________________________ | ____________ | ____________ |

**Versión aprobada:** ____________
**Próxima revisión:** ____________

---

## Annexos Requeridos

- [ ] **Anexo A:** Tabla de IBRs vigentes por sociedad/moneda/plazo
- [ ] **Anexo B:** Lista definitiva de sociedades y GAAP aplicable
- [ ] **Anexo C:** Política de estimación IPC para US GAAP (si aplica)
- [ ] **Anexo D:** Cuentas GL por tipo de posting (Annex 8.13 del BBP actualizado)

---

*Traceability: docs/workshops/T0-01-accounting-policy-workshop.md | docs/architecture/open-questions-register.md — OQ-ACC-01, OQ-ACC-03*
*Template versión: 1.0 | Fecha: 2026-03-27*
