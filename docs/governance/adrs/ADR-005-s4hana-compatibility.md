# ADR-005 — Compatibilidad S/4HANA por Diseño

**ID:** ADR-005
**Fecha:** 2026-03-24
**Fecha de revisión para aprobación:** 2026-03-27
**Estado:** PROPOSED → Pendiente de aprobación del Project Governance Lead
**Owner:** ABAP Architect
**Categoría:** Technical Architecture / Long-term Investment
**Prioridad de aprobación:** P0 — Principio de diseño que afecta a todos los objetos Z desde el primer día

---

## Contexto

El cliente está actualmente en SAP ECC. La hoja de ruta de SAP establece que ECC 6.0 alcanza el fin de mantenimiento estándar en 2027 (con opción de mantenimiento extendido hasta 2030). El timeline de migración S/4HANA del cliente está pendiente de confirmación (OQ-ABAP-06, OQ-TBD-S4).

Si el addon IFRS 16 se construye sin consideración de S/4HANA:
- Cada objeto Z que usa sintaxis deprecated debe reescribirse en la migración
- Los SELECT * y los accesos a tablas obsoletas en S/4HANA generan errores de compatibilidad
- Las dependencias en RE-FX (ya eliminadas por ADR-006 Option B) habrían sido el mayor riesgo — mitigado
- Las dependencias en tablas de ECC que cambian su estructura en S/4HANA (BKPF, BSEG, LFA1) deben ser abstraídas

**El objetivo no es construir para S/4HANA ahora** — el cliente está en ECC y la complejidad S/4 nativa (ABAP Cloud, RAP, Tier-1) es prematura. El objetivo es **no cerrar la puerta de migración** con decisiones de diseño hoy.

**Estimación de impacto:** Si se ignora esta ADR, el costo de migración del addon a S/4HANA se estima en 30-50% del costo de construcción original. Si se aplica, la estimación es 10-15%.

---

## Decisión

**Todo desarrollo Z sigue las reglas de compatibilidad S/4HANA desde el primer día.**

### Reglas Obligatorias

#### R1 — Sin sentencias ABAP deprecadas

Prohibido:
```abap
" Prohibido
MOVE ... TO ...           → usar =
ADD/SUBTRACT              → usar +=/- =
COMPUTE                   → usar =
SELECT-OPTIONS con CHECK  → usar WHERE clause
WRITE / FORMAT           → usar ALV OO
```

Permitido con anotación:
- `MESSAGE` statements: marcados con `[ECC-SPECIFIC: Review for S/4 migration]`
- Acceso a tablas cluster/pool: abstraídos via interface `ZIF_RIF16_DATA_PROVIDER`

#### R2 — SELECT explícito (nunca SELECT *)

```abap
" Prohibido
SELECT * FROM zrif16_contract INTO TABLE lt_contracts.

" Obligatorio
SELECT z_contract_id, bukrs, contract_type, status
  FROM zrif16_contract
  INTO TABLE @DATA(lt_contracts)
  WHERE bukrs = @lv_bukrs.
```

Justificación: En S/4HANA las tablas de ECC tienen campos adicionales; SELECT * en tablas que cambian estructura puede provocar dumps.

#### R3 — Todas las dependencias de tablas ECC detrás de interfaces

Las tablas que cambian su estructura o desaparecen en S/4HANA deben ser accedidas vía interfaz:

```abap
" No acceder directamente desde lógica de negocio
SELECT * FROM bkpf INTO ...        " PROHIBIDO en business logic

" Sí: a través de interface abstracta
DATA(lo_fi_reader) = NEW zcl_rif16_fi_doc_reader( ).
lo_fi_reader->get_document( ... ).  " la implementación aísla la tabla ECC
```

Tablas ECC que requieren abstracción:
- `BKPF`/`BSEG` — cambiarán en S/4 (Universal Journal ACDOCA)
- `LFA1`/`LFB1` — vendor master (se sustituye por Business Partner en S/4)
- `ANLA`/`ANLZ` — FI-AA (puede cambiar en S/4)
- Cualquier tabla RE-FX: ya prohibida por ADR-006

#### R4 — CDS Views para la capa de reporting

Todo reporting debe usar CDS Views en lugar de acceso directo a tablas en los programas de report:
- `ZRIF16_V_CONTRACT_OVERVIEW` — vista de contratos activos
- `ZRIF16_V_SCHEDULE` — vista de tabla de amortización
- `ZRIF16_V_POSTING_LOG` — vista de historial de postings
- En S/4HANA, las CDS Views se portan a ABAP Cloud con mínimo esfuerzo

#### R5 — ALV OO para UI (con nota de Fiori-readiness)

- Todas las transacciones Z usan ALV OO (`CL_SALV_TABLE`)
- Cada transacción incluye un comentario `[FIORI-READY: Review for Fiori conversion in S/4 migration]`
- No usar `WRITE` para UI de usuario final

#### R6 — Marcadores de dependencias ECC-específicas

Cualquier código que no sea portable a S/4 debe marcarse:
```abap
" [ECC-SPECIFIC: This BAPI_ACC_DOCUMENT_POST call needs review for S/4 Journal Entry API]
CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
  EXPORTING ...
```

Esto permite que la evaluación de compatibilidad S/4 en Phase 3 sea automatizable con un grep.

---

## Alternativas Consideradas

| Alternativa | Razón de Rechazo |
|-------------|----------------|
| Optimizar solo para ECC | Crea deuda técnica masiva; reduce el ROI del addon para el cliente; la migración S/4 se convierte en una reescritura completa del addon |
| Construir directamente para S/4HANA ABAP Cloud | Prematuro — el cliente está en ECC; ABAP Cloud tiene restricciones que complican el desarrollo actual (no todos los FMs disponibles, RAP requiere experiencia adicional) |
| Compatibilidad S/4 solo para módulos específicos | No sostenible — la frontera entre módulos "compatibles" y "no compatibles" se erosiona durante el proyecto |
| Esperar a que el cliente confirme el timeline S/4 | El costo de retroajustar código ya escrito es mucho mayor que escribirlo bien desde el inicio |

---

## Consecuencias

**Positivas:**
- Phase 3 S/4 compatibility assessment será un proceso de revisión, no una reescritura
- Los marcadores `[ECC-SPECIFIC]` generan un inventario automático de puntos de atención
- Las CDS Views son directamente portables
- El cliente recibe más valor: el addon tiene mayor longevidad

**Negativas y riesgos aceptados:**
- Overhead de desarrollo de 5-10% estimado para:
  - Escribir interfaces de abstracción para tablas ECC
  - SELECT explícitos (más verboso pero sin costo funcional)
  - Comentarios de Fiori-readiness
- Requiere que los desarrolladores conozcan las reglas — checklist en el onboarding del equipo

**Verificación continua:**
- ATC (ABAP Test Cockpit) con reglas de compatibilidad S/4 habilitadas desde el inicio
- Code Inspector ejecutado antes de cada transport a QA

---

## Criterios de Verificación

- [ ] ATC configurado con ruleset de S/4HANA compatibility checks en sistema de desarrollo
- [ ] Ningún SELECT * en clases de lógica de negocio (ATC rule)
- [ ] Interfaces `ZIF_RIF16_DATA_PROVIDER` y `ZIF_RIF16_FI_READER` diseñadas antes del primer módulo que acceda a BKPF/LFA1
- [ ] Cada transacción tiene comentario `[FIORI-READY]`
- [ ] Phase 3 S/4 assessment puede realizarse con grep de `[ECC-SPECIFIC]` tags

---

## Firmas Requeridas

| Rol | Nombre | Decisión | Fecha |
|-----|--------|----------|-------|
| Project Governance Lead | ________________________ | ☐ APROBADO  ☐ RECHAZADO  ☐ MODIFICADO | ____________ |
| ABAP Architect | ________________________ | ☐ ACEPTADO | ____________ |

**Nota al Project Governance Lead:** La aprobación de este ADR es una decisión de inversión. Implica un overhead de desarrollo de ~10% pero reduce el costo de migración S/4 en un estimado de 30-40%. Recomendamos aprobarlo sin restricciones.

**Comentarios:**
________________________________________________________________________________________

---

*Traceability: docs/governance/decision-log.md | .kiro/steering/tech.md | OQ-ABAP-06 | Risks R-05 (S/4 migration timeline)*
*Generado: 2026-03-27 | Pendiente de aprobación*
