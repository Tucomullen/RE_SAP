# ADR-002 — Convención de Nombres para Objetos Z

**ID:** ADR-002
**Fecha:** 2026-03-24
**Fecha de revisión para aprobación:** 2026-03-27
**Estado:** PROPOSED → Pendiente de aprobación del Project Governance Lead
**Owner:** ABAP Architect
**Categoría:** Development Standards
**Prioridad de aprobación:** P0 — Bloqueante para creación del primer objeto Z

---

## Contexto

El proyecto creará un volumen significativo de objetos ABAP Z (tablas, clases, programas, transacciones, vistas CDS, objetos de log). Sin una convención de nombres obligatoria desde el inicio:
- Los objetos de distintos módulos colisionan en el namespace
- Es imposible identificar qué objetos pertenecen a este proyecto vs. desarrollos Z históricos del cliente
- El mantenimiento futuro no puede localizar objetos relacionados
- El equipo de Basis no puede gestionar los transportes correctamente

El estándar propuesto usa el prefijo `ZRIF16_` que:
- Usa el namespace `Z` estándar SAP para desarrollos de cliente
- Incluye `RIF16` como identificador del proyecto (RE IFRS 16)
- Es lo suficientemente único para no colisionar con objetos Z históricos del cliente

**Dependency blocker:** OQ-ABAP-01 — el namespace definitivo debe confirmarse con el equipo de Basis del cliente en T0-03 antes de crear el primer objeto Z. Este ADR adopta `ZRIF16_` como estándar provisional que puede ajustarse según la confirmación del cliente.

---

## Decisión

Adoptar la convención de nombres definida en `.kiro/steering/structure.md` como estándar obligatorio. El prefijo base es `ZRIF16_`.

### Estándar por tipo de objeto

| Tipo de objeto | Patrón | Ejemplo |
|---------------|--------|---------|
| Tablas transparentes | `ZRIF16_<DOMINIO>` | `ZRIF16_CONTRACT`, `ZRIF16_SCHEDULE` |
| Tablas de configuración | `ZRIF16_C_<NOMBRE>` | `ZRIF16_C_GL_MAP`, `ZRIF16_C_ASSET_CLS` |
| Tablas de log/audit | `ZRIF16_LOG_<TIPO>` | `ZRIF16_LOG_POSTING`, `ZRIF16_LOG_CALC` |
| Tabla audit trail | `ZRIF16_AUDIT` | `ZRIF16_AUDIT` (tabla única append-only) |
| Clases OO | `ZCL_RIF16_<MÓDULO>` | `ZCL_RIF16_VALUATION_ENGINE` |
| Interfaces | `ZIF_RIF16_<CONTRATO>` | `ZIF_RIF16_DATA_PROVIDER` |
| Clases de test | `ZCL_RIF16_<MÓDULO>_TEST` | `ZCL_RIF16_VALUATION_ENGINE_TEST` |
| Programas batch | `ZRIF16_<PROCESO>_BATCH` | `ZRIF16_RECLASS_BATCH` |
| Programas de report | `ZRIF16_REP_<NOMBRE>` | `ZRIF16_REP_ROLLFORWARD` |
| Transacciones | `ZRI_<ABREV>` | `ZRI_CONTRACT`, `ZRI_CALC_RUN` |
| Vistas CDS | `ZRIF16_V_<DOMINIO>` | `ZRIF16_V_CONTRACT_OVERVIEW` |
| Objetos de mensaje | `ZRIF16` | Object ZRIF16, message class ZRIF16 |
| Objetos de log (SLG1) | `ZRIF16` | Log object ZRIF16, subobject per domain |
| Objetos de autorización | `ZRIF16_AUTH_<ÁREA>` | `ZRIF16_AUTH_POST`, `ZRIF16_AUTH_APPROVE` |
| Paquete principal | `ZRIF16` | Package `ZRIF16` |
| Sub-paquetes | `ZRIF16_<DOMINIO>` | `ZRIF16_CONTRACT`, `ZRIF16_VALUATION` |

### Estructura de paquetes recomendada

```
ZRIF16                        (paquete raíz)
├── ZRIF16_CONTRACT           (CD-01: Contract Master Z)
├── ZRIF16_LEASE_OBJ          (CD-02: Lease Object Master Z)
├── ZRIF16_VALUATION          (CD-03: Valuation Engine Z)
├── ZRIF16_ACCOUNTING         (CD-04: Accounting Engine Z)
├── ZRIF16_ASSET              (CD-05: Asset Engine Z / FI-AA)
├── ZRIF16_EVENTS             (CD-06: Contract Event Engine Z)
├── ZRIF16_PROCUREMENT        (CD-07: Procurement Integration Z)
├── ZRIF16_RECLASS            (CD-08: Reclassification Engine Z)
├── ZRIF16_REPORTING          (CD-09: Reporting & Audit Z)
├── ZRIF16_CONFIG             (Configuration tables shared)
├── ZRIF16_INFRA              (Infrastructure: auth, log, utils)
└── ZRIF16_TEST               (All test classes)
```

### Abreviaturas de dominio aprobadas

| Abreviatura | Significado |
|------------|------------|
| `CNT` | Contract |
| `OBJ` | Lease Object |
| `VAL` | Valuation / Calculation |
| `SCH` | Schedule (amortization) |
| `POST` | Posting / Accounting |
| `ASSET` | FI-AA Asset |
| `EVT` | Event |
| `RCLS` | Reclassification |
| `REP` | Report |
| `CFG` | Configuration |
| `AUD` | Audit |
| `LOG` | Log |

---

## Alternativas Consideradas

| Alternativa | Razón de Rechazo |
|-------------|----------------|
| Convención del cliente | No está confirmada — adoptar estándar propio; actualizar si el cliente tiene conflicto (OQ-ABAP-01) |
| Prefijo `ZRE_` (más corto) | Demasiado genérico; puede colisionar con desarrollos Z históricos de RE-FX del cliente |
| Sin prefijo de proyecto (solo `Z_`) | Imposible identificar objetos del proyecto; riesgo de colisión con cualquier Z histórico |
| Prefijo por dominio (`ZCD01_`, `ZCD02_`) | Demasiado granular; dificulta búsqueda global por proyecto en SE80 |

---

## Consecuencias

**Positivas:**
- Todos los objetos del proyecto son identificables con `SE80` / wildcard `ZRIF16*`
- Los transportes pueden organizarse por paquete de manera predecible
- Onboarding de nuevos desarrolladores: saben dónde buscar
- Basis puede crear request de transport con scope claro

**Negativas y riesgos aceptados:**
- Si el cliente tiene un prefijo diferente requerido por su governance interna, este ADR debe enmendarse. **Confirmar con Basis en T0-03 (OQ-ABAP-01).**
- Prefijo `ZRIF16_` tiene 8 caracteres; los nombres de tabla y función quedan con menos caracteres disponibles hasta el límite de 30 de SAP. Esto es aceptable para los objetos previstos.

---

## Criterios de Verificación

- [ ] OQ-ABAP-01 resuelto: namespace confirmado con Basis del cliente
- [ ] Paquete raíz `ZRIF16` creado en sistema de desarrollo
- [ ] Primera tabla Z creada sigue la convención
- [ ] Code Inspector / Naming Convention check habilitado en ATC

---

## Firmas Requeridas

| Rol | Nombre | Decisión | Fecha |
|-----|--------|----------|-------|
| Project Governance Lead | ________________________ | ☐ APROBADO  ☐ RECHAZADO  ☐ MODIFICADO | ____________ |
| ABAP Architect | ________________________ | ☐ ACEPTADO | ____________ |

**Condición:** La aprobación de este ADR está condicionada a la confirmación del namespace por Basis del cliente (OQ-ABAP-01). Si el cliente requiere un prefijo diferente, el Project Governance Lead debe aprobar la modificación del prefijo sin necesidad de un nuevo ADR.

**Comentarios:**
________________________________________________________________________________________

---

*Traceability: docs/governance/decision-log.md | .kiro/steering/structure.md | OQ-ABAP-01 | D-PHASE-02*
*Generado: 2026-03-27 | Pendiente de aprobación*
