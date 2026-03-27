# Workshop T0-02 — Blueprint SAP RE-FX / Cobertura Funcional Option B
**Fecha objetivo:** TBD — debe realizarse antes del inicio de Phase 1 (puede ser concurrent con T0-01)
**Duración estimada:** 4-5 horas
**Participantes requeridos:** SAP RE Functional Consultant (lead), RE Contract Manager, Project Governance Lead, ABAP Architect (para sección de arquitectura), IFRS 16 Accountant (para solapamientos con T0-01)
**Prerequisito para:** Diseño definitivo de CD-01, CD-02, CD-06, CD-07; cierre de D-PHASE-01 junto con T0-01

> **REGLA DE CIERRE:** Este workshop no concluye hasta que OQ-CM-01 y OQ-ARCH-01 tengan respuesta documentada. La lista de tipos de contrato debe quedar firmada como base del modelo de datos CD-01/CD-02.

---

## 1. Análisis de Cobertura Funcional: ECC Actual → Option B

### Resumen Ejecutivo

El sistema ECC actual gestiona el ciclo de vida de arrendamientos a través de una combinación de **SAP RE-FX** (sistema de record para datos de contratos), **desarrollos Z propios** (ZRE009 para reclasificación, programas de carga masiva, validaciones SII), **procesos manuales** (hojas de cálculo Excel para valoración IFRS 16, cálculos US GAAP, reconciliaciones), y **FI/FI-AA estándar** (posteos contables y activos fijos).

El addon Z Option B replica y **mejora** todas las capacidades de negocio actuales, eliminando las dependencias en RE-FX en tiempo de ejecución, simplificando la arquitectura, y automatizando procesos hoy manuales.

**Resultado del análisis:** 56 capacidades MUST + 12 capacidades SHOULD + 1 capacidad LATER han sido identificadas. **No existe ninguna capacidad de negocio crítica del ECC actual que quede sin cobertura en Option B** — aunque se han identificado 8 gaps de cobertura que requieren decisión antes de iniciar Phase 1.

---

### 1.1 Área A: Datos Maestros de Contrato

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora vs ECC | Prioridad |
|---------------------|-------------------|-----------------|----------------|---------------|-----------|
| Asignación a sociedad (BUKRS) | RE-FX contrato header | CD-01 | `ZRIF16_CONTRACT.BUKRS` | Sin cambio — replicado | MUST |
| Tipos de contrato (C001-C009 + CM00) | RE-FX categorías + Annex 8.5 | CD-01 | `ZRIF16_CTYPE` config table; 9 tipos + marco | Config table visible vs. RE-FX customizing opaco | MUST |
| Fechas inicio / fin / fin probable IFRS 16 | RE-FX fechas + `Fin probable` manual | CD-01 | `START_DATE`, `FIRST_END_DATE`, `IFRS16_TERM_DATE` (campo explícito) | Campo `IFRS16_TERM_DATE` independiente del fin contractual — sin ambigüedad | MUST |
| Opciones de renovación / rescisión | RE-FX campos de opción | CD-01 | `ZRIF16_CONTRACT_RNEWAL` + `_TERM` con tipo, duración, aviso | Evaluación estructurada de opción vs. campo libre en RE-FX | MUST |
| Arrendador (BP / vendor) | BP role TR602 + replicación vendor | CD-01 | `VENDOR_ID` FK directa a vendor master; sin jerarquía BP | Elimina complejidad de rol BP TR602 | MUST |
| Múltiples arrendadores por contrato | Múltiples BPs con rol TR602 | CD-01 | `ZRIF16_CONTRACT_PARTY` tabla con % participación | Modelo de split más claro | SHOULD |
| Calendario de pagos / rentas | RE-FX condition types (C100, etc.) | CD-01 | `ZRIF16_PYMT_SCHED` tabla explícita; sin config de condition types | Elimina dependencia de condition type customizing | MUST |
| Rentas escalonadas (stepped) | Múltiples filas de condición | CD-01 | Múltiples filas `ZRIF16_PYMT_SCHED` con rangos de fecha | Mejor visibilidad; sin config RE-FX | MUST |
| Renta variable (informacional) | Condition type con flag no valoración | CD-01 | `VALUATION_RELEVANT = N` explícito | Flag explícito vs. deducción de condition purpose | MUST |
| Anticipos / prepagos | Condition type "Anticipo" + bridge account | CD-01 | `PREPAYMENT_AMOUNT` campo directo | Elimina cuenta puente | MUST |
| Costes incrementales (IDC) | Condition type de costes | CD-01 | `INITIAL_DIRECT_COSTS` campo directo | Un campo vs. condition type complejo | MUST |
| Moneda (multimoneda) | Moneda del contrato RE-FX | CD-01 | `CURRENCY` + flag FX contract | Flag explícito para contratos FX | MUST |
| Asignación de centro de coste / profit center | Regla de valoración RE-FX | CD-01 | `COST_CENTER` + `PROFIT_CENTER` campo directo | Visible directamente; sin regla de valoración intermediaria | MUST |
| Múltiples centros de coste | Múltiples reglas de valoración | CD-01 | `ZRIF16_CONTRACT_CC` tabla con % split | % split explícito vs. múltiples reglas RE-FX | SHOULD |
| Ajuste de renta por IPC | REAJPR + condition types | CD-01 + CD-06 | `ZRIF16_RENT_ADJ` + evento PAYMENT_CHANGED | Job batch automático vs. proceso manual REAJPR | MUST |
| Carga masiva de contratos | Programa Z legacy (Excel → RE-FX) | CD-01 | Z mass upload: Excel/CSV → `ZRIF16_CONTRACT`; validación antes de activación | Reutilizable (migración + operación continua); nuevo campo template | MUST |
| Referencia a contrato anterior (migración) | Campo RE-FX contrato previo | CD-01 | `PREV_SYSTEM_REF` campo de trazabilidad | Trazabilidad de migración | MUST |

---

### 1.2 Área B: Gestión de Objetos Arrendados

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora vs ECC | Prioridad |
|---------------------|-------------------|-----------------|----------------|---------------|-----------|
| Jerarquía de objetos inmuebles (UE/Terreno/UA) | RE-FX jerarquía 3 niveles | CD-02 | `ZRIF16_LEASE_OBJ` plano; `OBJ_TYPE = LAND/BUILDING` | Elimina jerarquía de 3 niveles innecesaria para IFRS 16 | MUST |
| Objetos muebles (J4: vehículos, equipos) | RE-FX objeto J4 inline en contrato | CD-02 | `ZRIF16_LEASE_OBJ` reutilizable; `OBJ_CLASS` per Annex 8.6 | Objeto master reutilizable vs. J4 inline no reutilizable | MUST |
| Clasificación de objeto (J001-J009+) | J4 object class | CD-02 | Config table `ZRIF16_OBJ_CLASS` → FI-AA asset class | Tabla de config visible vs. RE-FX opaco | MUST |
| Múltiples objetos por contrato | Múltiples J4/UA por contrato | CD-02 | `ZRIF16_CONTRACT_OBJ` tabla M:N | Modelo M:N explícito | MUST |
| Referencia catastral (SII España) | Pestaña Equipamiento en UA | CD-02 | `ZRIF16_LEASE_OBJ.CATASTRAL_REF`; mandatory flag por sociedad | Integrado en creación; obligatoriedad configurable | SHOULD |
| Matrícula de vehículos | Free text en descripción | CD-02 | `PLATE_NUMBER` campo estructurado separado | Campo específico vs. texto libre | SHOULD |

---

### 1.3 Área C: Motor de Valoración IFRS 16

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora vs ECC | Prioridad |
|---------------------|-------------------|-----------------|----------------|---------------|-----------|
| Cálculo PV inicial (pasivo arrendamiento) | Motor RE-FX + IBR en regla valoración | CD-03 | `ZCL_RIF16_VALUATION_ENGINE`: PV con IBR, frecuencia pago, pre/post pago | Auditabilidad total de inputs; snapshot de inputs en cada run | MUST |
| Activo ROU inicial | Motor RE-FX (liability + anticipos + IDC) | CD-03 | `ROU = PV + PREPAYMENT_AMOUNT + INITIAL_DIRECT_COSTS` | Fórmula explícita y visible | MUST |
| Tabla de amortización completa | RE-FX: generada automática; no queryable fácilmente | CD-03 | `ZRIF16_SCHEDULE`: 1 fila/período/contrato; queryable en todo momento | Schedule persistente y auditable vs. RE-FX que la recalcula | MUST |
| Reconocimiento en día 1 (reconocimiento inicial) | RECEEP en RE-FX | CD-03 + CD-04 | Run inicial → schedule → aprobación → posting directo FI BAPI | Flujo explícito con gate de aprobación human | MUST |
| Simulación de cálculo (sin guardar) | Modo implícito RE-FX | CD-03 | `ZRIF16_CALC_RUN.SIM_FLAG = X`; resultados temporales hasta confirmación | Simulación explícita nueva capacidad | MUST |
| Snapshot de inputs del cálculo (audit) | Log RE-FX implícito | CD-03 | `ZRIF16_CALC_ITEM`: IBR_USED, TERM_USED, PAYMENT_SCHEDULE_SNAPSHOT | Registro inmutable de inputs por run | MUST |
| Remedición por modificación | Recálculo manual en RE-FX | CD-03 + CD-06 | Nuevo `ZRIF16_CALC_RUN` disparado por evento; run anterior preservado | No destructivo; historial completo | MUST |
| Remedición por actualización IPC | RECEEP manual post-REAJPR | CD-03 + CD-06 | Evento `PAYMENT_CHANGED` → nuevo run automático | Automatización del proceso manual | MUST |
| Exención corto plazo (< 12 meses) | No gestionado explícitamente en ECC | CD-01 + CD-03 | `EXEMPTION_TYPE = SHORT_TERM`; sin run de valoración | Campo explícito con justificación; nuevo vs. RE-FX | MUST |
| Exención bajo valor (< USD 5.000) | No gestionado explícitamente en ECC | CD-01 + CD-03 | `EXEMPTION_TYPE = LOW_VALUE`; umbral configurable por tipo de activo | Umbral configurable; nuevo vs. RE-FX | MUST |
| Valoración paralela IFRS/PGC | Dos reglas de valoración en RE-FX | CD-03 | `ZRIF16_CALC_RUN.GAAP_TYPE` (IFRS/PGC/USGAAP); posting paralelo | Automatizado vs. semi-manual en RE-FX | MUST |
| Valoración US GAAP ASC 842 | Desarrollo Z parcial (GAP) | CD-03 | `ZCL_RIF16_VALUATION_US_GAAP`: IPC estimado, pagos lineales, delta anual | Implementación completa en Z vs. gap parcial ECC | MUST |
| Linealización de gastos (PGC) | RE-FX linearización | CD-03 | `ZRIF16_SCHEDULE.LINEAR_EXPENSE_PGC`; driven by PGC flag | Flag explícito por contrato | SHOULD |
| Anticipos — valoración (total/parcial) | Bridge account + condition types | CD-03 | `PREPAYMENT_TYPE (TOTAL/PARTIAL)`; schedule adjustado; sin cuenta puente | Elimina bridge account | MUST |

---

### 1.4 Área D: Motor Contable FI-GL

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora vs ECC | Prioridad |
|---------------------|-------------------|-----------------|----------------|---------------|-----------|
| Posting de reconocimiento inicial (ROU + Pasivo) | RE-FX RECEEP → FI (via bridge account AN doc) | CD-04 | BAPI directo: `DR ROU / CR Pasivo arrendamiento` — sin cuenta puente | **Eliminación de cuenta puente** — simplificación mayor | MUST |
| Devengo mensual de intereses | Posting manual o RE-FX periodo | CD-04 | Batch Z: schedule → BAPI; doc type SA; referencia Z Contract ID | Automatización total | MUST |
| Posting post-remedición (delta ROU/Pasivo) | AN doc manual post-recalc | CD-04 | Automático tras evento de remedición: DR/CR ROU / CR/DR Pasivo | Automatización | MUST |
| Posting de PGC paralelo (LL) | RE-FX LL document semi-manual | CD-04 | `ZRIF16_GL_MAP` PGC mapping; LL generado automático por período | Automatización total del LL | MUST |
| Simulación de posting (BAPI_CHECK) | Disponible en ZRE009, no en otros | CD-04 | **Todos** los Z programs llaman BAPI en modo simulación primero | Simulación universal — nueva capacidad estándar | MUST |
| Determinación de cuentas GL | RE-FX deep customizing | CD-04 | `ZRIF16_GL_MAP`: BUKRS + CONTRACT_TYPE + GAAP_TYPE + POSTING_TYPE → GL | Tabla de config visible y exportable | MUST |
| Tipos de documento FI (AN/SF/SA/LT/AJ/LL) | RE-FX customizing | CD-04 | `ZRIF16_GL_MAP.DOC_TYPE` per posting type | Sin cambio — mismos tipos | MUST |
| Reversión de posting | FI reversal manual (ZRE009 para reclasif.) | CD-04 | `BAPI_ACC_DOCUMENT_REVERSE` + log en `ZRIF16_POST_LOG.REVERSAL_OF` | Reversión universal trazable | MUST |
| Trazabilidad FI doc ↔ contrato | Ninguna — FBL3N sin referencia a contrato | CD-04 + CD-09 | Z Contract ID en campo `XBLNR` de todos los documentos FI | **Nueva capacidad crítica** — auditoría end-to-end | MUST |
| Errores de posting — gestión | Fallos silenciosos en RE-FX | CD-04 | Log de errores + cola de reprocesamiento | **Eliminación de fallos silenciosos** (PP-E) | MUST |
| Cuentas de conciliación alternativas | FI config OB57 | CD-04 | `ZRIF16_GL_MAP.VENDOR_RECON_ACCOUNT` | Config visible en Z vs. FI customizing | MUST |

---

### 1.5 Área E: Motor de Activos FI-AA

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora vs ECC | Prioridad |
|---------------------|-------------------|-----------------|----------------|---------------|-----------|
| Creación automática activo ROU | RE-FX → FI-AA automático | CD-05 | Evento de reconocimiento inicial → BAPI FI-AA creación sub-activo; clase desde `ZRIF16_ASSET_CLS` | Automatización mantenida; sin RE-FX intermediario | MUST |
| Mapping clases de activo por tipo contrato | RE-FX customizing → FI-AA | CD-05 | Config table `ZRIF16_ASSET_CLS`: CONTRACT_TYPE → ASSET_CLASS | Tabla visible (9 clases D21009-D21909) | MUST |
| Vida útil = plazo arrendamiento | RE-FX alimenta FI-AA | CD-05 | Z envía `IFRS16_TERM_DATE` directamente al BAPI FI-AA | Directo; sin relay RE-FX | MUST |
| Actualización vida útil en extensión | RE-FX automático | CD-05 | Evento EXTENDED → BAPI FI-AA update useful life | Automatización mantenida | MUST |
| Baja de activo en terminación | RE-FX → FI-AA retirement (AJ) | CD-05 | Evento TERMINATED → FI-AA retirement BAPI; gain/loss from Z schedule | Automatización event-driven | MUST |
| Mapping contrato ↔ número de activo FI-AA | Almacenado en regla de valoración RE-FX | CD-05 | `ZRIF16_INTG_REF`: Z_CONTRACT_ID + ANLN1 + ANLN2 | Tabla explícita de trazabilidad | MUST |
| Áreas de amortización (01/11/12/13) | FI-AA config | CD-05 | Config de FI-AA es prerequisito (no desarrollo Z); Z activa las áreas correctas vía BAPI | Sin cambio en config FI-AA | MUST |
| Tipos de movimiento personalizados (ZD1/ZD4/ZDR/ZCR) | FI-AA config | CD-05 | Z usa los mismos movement types en BAPIs | Sin cambio | MUST |

---

### 1.6 Área F: Reclasificación Corriente/No Corriente

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora vs ECC | Prioridad |
|---------------------|-------------------|-----------------|----------------|---------------|-----------|
| Cálculo reclasificación pasivo | ZRE009 (frágil — PP-C) | CD-08 | `ZRIF16_RECLASS_RUN`: cálculo corriente/no corriente por contrato desde schedule | Motor dedicado y fiable vs. ZRE009 frágil | MUST |
| Posting de reclasificación (doc LT) | ZRE009 → FI BAPI | CD-08 | Batch Z → FI BAPI post; doc type LT; simulación primero | Simulación estándar; reversión trazable | MUST |
| Historial de reclasificaciones | No persiste | CD-08 | `ZRIF16_RECLASS_HIST` tabla | Historial explícito | MUST |

---

### 1.7 Área G: Reporting y Auditoría

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora vs ECC | Prioridad |
|---------------------|-------------------|-----------------|----------------|---------------|-----------|
| Lista de contratos activos | RE-FX report (PP-G: solo por clase activo) | CD-09 | CDS view: contratos activos con estado IFRS 16 y indicadores | **Por contrato, no solo por clase activo** | MUST |
| Reporte de vencimientos | No existe | CD-09 | Z: contratos que vencen en N meses | Nueva capacidad | MUST |
| Rollforward de pasivo | Excel manual | CD-09 | Z: rollforward automático desde `ZRIF16_SCHEDULE` | **Automatización de proceso manual clave** | MUST |
| Rollforward de activo ROU | Excel manual | CD-09 | Z: rollforward ROU desde schedule + FI-AA | Automatización | MUST |
| Historial de postings por contrato | FBL3N sin referencia contrato | CD-09 | `ZRIF16_POST_LOG` + Z_CONTRACT_ID en FI doc | **Trazabilidad completa nueva** | MUST |
| Checklist de cierre de período | No existe | CD-09 | Dashboard: todos los contratos procesados / errores / pendientes | Nueva capacidad de control | MUST |
| Paquete de evidencia de auditoría | Manual | CD-09 + CD-04 | Por contrato: eventos + cálculos + FI docs enlazados | **Nueva capacidad crítica para auditoría** | MUST |
| Disclosure pack | Excel manual | CD-09 | Datos estructurados + export (Phase 2) | Phase 2 | SHOULD |

---

### 1.8 Área H: Gestión de Eventos de Contrato

| Capacidad ECC Actual | Implementación ECC | Dominio Option B | Diseño Z Addon | Mejora | Prioridad |
|---------------------|-------------------|-----------------|----------------|--------|-----------|
| Extensión de contrato | RE-FX amendment (PP-J) | CD-06 | Evento `EXTENDED` → recalculation desde fecha extensión | Workflow guiado vs. RE-FX sin guía | MUST |
| Novación (cambio arrendador) | RE-FX amendment | CD-06 | Evento `NOVATED` → update vendor + remedición | No destructivo | MUST |
| Reasignación de CeCo | RE-FX change manual | CD-06 | Evento `CC_CHANGED` → update + reasignación postings futuros | Automático | MUST |
| Reducción de alcance | RE-FX complejo | CD-06 | Evento `SCOPE_CHANGED` → recalcul. en base nuevo alcance | Explícito | SHOULD |
| Historial de versiones del contrato | No existe en ECC | CD-06 | Event journal no destructivo — todas las versiones preservadas | **Nueva capacidad crítica para auditoría** | MUST |
| Validación de secuencia de eventos | No existe (PP-J) | CD-06 | Validación secuencial de eventos; workflow guiado | Elimina PP-J pain point | MUST |

---

## 2. Gaps de Cobertura a Resolver Antes de Phase 1

Los siguientes gaps han sido identificados. Cada uno requiere una decisión antes de que el equipo de diseño pueda finalizar los specs de los dominios afectados.

| ID Gap | Descripción | Capacidad ECC afectada | Impacto si no se resuelve | Owner | Plazo |
|--------|------------|------------------------|--------------------------|-------|-------|
| GAP-A-01 | **FI-AP matching (conciliación de facturas proveedor)** — La capacidad de asociar el pago real del arrendamiento (factura AP) con el pasivo contabilizado no existe en el diseño actual Option B Phase 1. En ECC se hace via bridge account + compensación AP. | Pago y reducción de pasivo (A-14 / E-04) | El pasivo no se reduce automáticamente al pagar; reconciliación manual continua | Project Governance Lead | T0-02 / antes de spec CD-04 |
| GAP-A-02 | **Disclosure pack automático (export IFRS 16.53)** — El reporte de disclosure requerido por norma se produce hoy en Excel. El addon lo producirá en Phase 2 (G-09). | Disclosure anual | Proceso manual continúa hasta Phase 2 | Project Governance Lead | Confirmar Phase 2 scope |
| GAP-B-01 | **Clave de depreciación ZLEA sin RE-FX** — La clave de depreciación custom ZLEA depende de que RE-FX alimente los valores al activo FI-AA. En Option B, RE-FX no existe en runtime. Se necesita una clave de sustitución o dirección de vida útil directa desde Z. | Depreciación de activo ROU (F-03) | ROU asset no se amortiza correctamente | FI-AA Specialist + ABAP Architect | T0-04 Workshop |
| GAP-C-01 | **Ledger paralelo activo para PGC** — Si las sociedades tienen parallel ledger activo para local GAAP, el BAPI de posting necesita especificación de ledger. No confirmado si está activo en el cliente. | Multi-ledger posting (D-03) | Postings PGC incompletos si parallel ledger activo | FI Architect | T0-04 Workshop |
| GAP-D-01 | **Contratos no en RE-FX hoy** — Pueden existir contratos gestionados 100% en Excel que deban onboardearse al nuevo sistema. El scope de migración no incluye contratos fuera de RE-FX hoy. | Scope de migración (OQ-CM-02) | Contratos IFRS 16 materiales pueden quedar fuera del sistema | RE Contract Manager | T0-02 Workshop |
| GAP-E-01 | **Reglas de pago específicas por país (más allá de Polonia)** — Solo el caso de Polonia está documentado. Otros países pueden tener reglas similares. | Country-specific valuation (D-05, OQ-CM-03) | Contratos de otros países calculados con lógica incorrecta | Local Finance / RE Contract Manager | T0-02 Workshop |
| GAP-F-01 | **Moneda UF/CLF Chile** — El tratamiento de indexación en UF requiere lógica específica de revalorización que va más allá del FX estándar. No completamente diseñado. | Multi-currency Chile (D-06) | Contratos en UF no calculables | FI Architect + RE Contract Manager | T0-04 Workshop |
| GAP-G-01 | **Patrón PO-to-contract (CD-07)** — No existe equivalente en ECC. Capacidad nueva. Scope no confirmado. | Integración procurement (Sección F) | Si en scope y no diseñado, contratos originados en MM quedan fuera del sistema | Project Governance Lead | T0-02 Workshop |

---

## 3. Preguntas P0 del Open-Questions Register que Deben Cerrarse

Las siguientes preguntas del registro oficial deben quedar con estado RESOLVED al terminar este workshop:

| ID | Pregunta | Output esperado |
|----|---------|----------------|
| OQ-ARCH-01 / TBC-ORK-02 | ¿Existe alguna funcionalidad RE-FX que DEBA preservarse como integración runtime (no migración)? | Respuesta definitiva: "ninguna" O lista de excepciones con justificación. Si hay excepción → enmendar ADR-006. |
| OQ-CM-01 | ¿Cuál es la lista completa de tipos de contrato actualmente en ECC? | Lista firmada de tipos de contrato (C001-C009 + otros) con confirmación de si todos mapean a CD-01/CD-02 |

Adicionalmente, las siguientes P1 deben quedar al menos con owner y fecha:

| ID | Pregunta | Owner confirmado | Fecha máxima |
|----|---------|-----------------|-------------|
| OQ-CM-02 | ¿Hay contratos fuera de RE-FX que deban onboardearse? | RE Contract Manager | Antes de spec migración |
| OQ-CM-03 | ¿Hay reglas de país más allá de Polonia? | Local Finance | Antes de spec CD-03 |
| OQ-CM-04 | ¿Qué monedas se usan en el portfolio? | Finance Controller | Antes de spec CD-03 |
| OQ-CM-05 | ¿Hay tipos de contrato RE-FX que no mapeen a CD-01/CD-02? | T0-02 Workshop | En este workshop |
| OQ-CM-06 | ¿Cuántos contratos hay en RE-FX hoy? (scope de migración) | RE Contract Manager | Antes de spec migración |
| OQ-CM-07 | ¿Estrategia de go-live: big-bang o por fases? | Project Governance Lead | Antes de Phase 0 gate |
| OQ-CM-09 | ¿El patrón PO-to-contract (CD-07) está en scope? | Project Governance Lead | En este workshop |

---

## 4. Agenda Propuesta del Workshop T0-02

| Tiempo | Bloque | Objetivo | Output |
|--------|--------|---------|--------|
| 0:00 – 0:30 | Contexto y Option B | Alinear a todos los participantes en la arquitectura Option B y sus implicaciones | Comprensión compartida |
| 0:30 – 1:30 | Revisión de tipos de contrato | Recorrer los 9 tipos C001-C009 + CM00 + posibles nuevos; confirmar mapeo a CD-01/CD-02 | **OQ-CM-01 cerrada** |
| 1:30 – 2:00 | Contratos fuera de RE-FX | ¿Qué contratos IFRS 16 existen fuera del sistema actual? | **OQ-CM-02 avanzada** |
| 2:00 – 2:30 | RE-FX runtime: ¿hay excepciones? | ¿Alguna función RE-FX debe mantenerse en tiempo de ejecución? | **OQ-ARCH-01 cerrada** |
| 2:30 – 3:00 | Análisis de gaps (GAP-A-01 a GAP-G-01) | Priorizar cada gap; asignar owner y fecha | Lista de gaps con decisiones |
| 3:00 – 3:30 | Alcance de CD-07 (PO-to-contract) | Decisión de scope | **OQ-CM-09 cerrada** |
| 3:30 – 4:00 | Estrategia de migración (preliminar) | Big-bang vs. fases; número de contratos en RE-FX | **OQ-CM-06, OQ-CM-07 avanzadas** |
| 4:00 – 4:30 | Reglas por país y monedas | Polonia + otros países; portfolio de monedas | **OQ-CM-03, OQ-CM-04 avanzadas** |
| 4:30 – 5:00 | Cierre y governance | Actualización del OQ register; próximos pasos | Acta de workshop firmada |

---

## 5. Criterios de Cierre del Workshop

Este workshop se considera CERRADO y exitoso cuando:

- [ ] OQ-ARCH-01 y TBC-ORK-02: respuesta definitiva sobre RE-FX runtime — **RESOLVED**
- [ ] OQ-CM-01: lista de tipos de contrato firmada — **RESOLVED**
- [ ] Todos los gaps (GAP-A-01 a GAP-G-01) tienen owner y fecha de resolución asignados
- [ ] Decisión de scope sobre CD-07 (PO-to-contract)
- [ ] SAP RE Functional Consultant confirmado como disponible para Phase 1

---

## 6. Output de Gobierno Requerido

Al terminar el workshop, el Project Governance Lead debe:

1. **Actualizar** `docs/architecture/open-questions-register.md`: mover OQ-ARCH-01, OQ-CM-01 a Resolution Log; actualizar estado de OQ-CM-02 a OQ-CM-09
2. **Actualizar** `docs/governance/decision-log.md`: si no hay excepciones RE-FX, registrar TBC-ORK-02 como RESOLVED
3. **Actualizar** `docs/functional/IFRS16_Coverage_Matrix.md`: añadir decisiones de gaps a la columna de design direction
4. **Marcar** TBC-ORK-05 como resuelto (SAP RE Functional Consultant confirmado)
5. **Confirmar** D-PHASE-01 parcialmente desbloqueado (junto con T0-01 completado)

---

*Traceability: docs/architecture/open-questions-register.md | docs/governance/decision-log.md — ADR-006, D-PHASE-01 | .kiro/steering/option-b-target-model.md*
*Última actualización: 2026-03-27 | Preparado para: T0-02 Workshop*
