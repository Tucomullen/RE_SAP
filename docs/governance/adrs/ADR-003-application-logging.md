# ADR-003 — Logging de Aplicación: SAP SLG1 + Tabla Z de Audit Trail

**ID:** ADR-003
**Fecha:** 2026-03-24
**Fecha de revisión para aprobación:** 2026-03-27
**Estado:** PROPOSED → Pendiente de aprobación del Project Governance Lead
**Owner:** ABAP Architect
**Categoría:** Auditability / Compliance Infrastructure
**Prioridad de aprobación:** P0 — Requerido antes del primer desarrollo de lógica de negocio

---

## Contexto

IFRS 16 es un proceso de compliance contable. Los auditores externos e internos requerirán evidencia de:
1. **Qué cálculos se ejecutaron** — con qué inputs, cuándo, por quién
2. **Qué decisiones se tomaron** — aprobaciones, scope determinations, modificaciones
3. **Qué postings FI se generaron** — y cuáles fueron rechazados o revertidos
4. **Durante cuánto tiempo** — la retención de la evidencia de auditoría es una obligación regulatoria

SAP SLG1 (Application Log) provee logging operacional estructurado pero tiene limitaciones:
- La retención está configurada globalmente y puede ser purgada
- No garantiza inmutabilidad (puede borrarse con autorización)
- No está diseñado para evidencia de auditoría de largo plazo (7-10 años)

Una tabla Z complementaria `ZRIF16_AUDIT` provee:
- Retención independiente de la configuración de SLG1
- Inmutabilidad por diseño (append-only — sin UPDATE/DELETE)
- Campo de integridad para detección de manipulación
- Alcance acotado: solo eventos críticos de compliance, no mensajes operacionales

---

## Decisión

**Estrategia de logging en dos capas:**

### Capa 1 — SAP SLG1 (Log Operacional)

**Scope:** Todos los run summaries, warnings, errores de proceso, mensajes de batch
**Objeto de log:** `ZRIF16`
**Sub-objetos por dominio:**

| Sub-objeto | Scope |
|-----------|-------|
| `ZRIF16_CALC` | Runs de cálculo (CD-03) |
| `ZRIF16_POST` | Runs de posting FI (CD-04) |
| `ZRIF16_ASSET` | Operaciones FI-AA (CD-05) |
| `ZRIF16_RCLS` | Runs de reclasificación (CD-08) |
| `ZRIF16_BATCH` | Ejecuciones de batch general |
| `ZRIF16_EVT` | Eventos de contrato (CD-06) |
| `ZRIF16_MIGR` | Proceso de migración (one-time) |

**Retención:** Configurar retención mínima de 12 meses en SM30 para objeto ZRIF16. OQ-ABAP-04 confirmará si la retención disponible en el cliente es suficiente.

### Capa 2 — `ZRIF16_AUDIT` (Tabla de Audit Trail — Append-Only)

**Scope:** Solo eventos críticos de compliance. No duplica los mensajes operacionales de SLG1.

**Estructura de tabla:**

```
ZRIF16_AUDIT
├── AUDIT_ID       NUMC 20    (number range ZRIF16_AUD — system-generated)
├── AUDIT_TS       TIMESTAMP  (UTC timestamp — inmutable)
├── AUDIT_CAT      CHAR 20    (categoría — ver tabla abajo)
├── Z_CONTRACT_ID  CHAR 20    (contrato afectado — FK a ZRIF16_CONTRACT)
├── CALC_RUN_ID    CHAR 20    (run de cálculo si aplica)
├── FI_DOC_NUMBER  CHAR 10    (número documento FI si aplica)
├── USER_ID        UNAME      (usuario que realizó la acción)
├── EVENT_TYPE     CHAR 50    (tipo específico de evento)
├── BEFORE_STATE   STRING     (snapshot JSON del estado anterior)
├── AFTER_STATE    STRING     (snapshot JSON del estado posterior)
├── CHECKSUM       CHAR 64    (SHA-256 de los campos clave — integridad)
└── REMARKS        STRING     (texto libre de justificación si requerido)
```

**Categorías de audit (AUDIT_CAT):**

| Categoría | Descripción | Obligatorio |
|-----------|------------|-------------|
| `SCOPE_DETERMINED` | Decisión de scope IFRS 16 para un contrato | Sí |
| `SCOPE_OVERRIDDEN` | Override manual de scope determination | Sí |
| `CALC_APPROVED` | Aprobación de resultado de cálculo | Sí |
| `CALC_REJECTED` | Rechazo de resultado de cálculo | Sí |
| `POSTING_APPROVED` | Aprobación de run de posting | Sí |
| `POSTING_EXECUTED` | Posting FI ejecutado (con doc number) | Sí |
| `POSTING_REVERSED` | Reversión de posting FI | Sí |
| `CONTRACT_MODIFIED` | Modificación de contrato con antes/después | Sí |
| `EVENT_RECORDED` | Evento de ciclo de vida registrado | Sí |
| `IBR_APPLIED` | IBR aplicado en cálculo (qué tasa, quién aprobó) | Sí |
| `EXEMPTION_APPLIED` | Exención short-term o low-value aplicada | Sí |
| `MIGRATION_LOADED` | Contrato cargado en migración | Sí (migración) |

**Reglas de inmutabilidad:**
- La tabla `ZRIF16_AUDIT` no tiene ningún programa Z que permita UPDATE o DELETE
- Las autorizaciones de escritura se limitan al objeto de autorización `ZRIF16_AUTH_AUDIT_WRITE` (solo procesos batch Z)
- Los usuarios de negocio no tienen autorización de escritura directa
- La integridad de cada registro se verifica con checksum SHA-256

**Retención:**
- Política de retención: `[TO BE CONFIRMED — ver OQ-ABAP-04]` — objetivo mínimo 7 años
- Archiving: se diseñará estrategia de archive en Phase 2 si el volumen lo requiere
- La política de retención definitiva debe ser aprobada por Legal/DGO del cliente

---

## Alternativas Consideradas

| Alternativa | Razón de Rechazo |
|-------------|----------------|
| Solo SLG1 | Los límites de retención pueden no cumplir con requisitos de auditoría (7-10 años); no garantiza inmutabilidad; configurable y purgable por Basis |
| Solo tabla Z | Duplica la funcionalidad de monitorización operacional de SLG1; overhead de desarrollo para mensajes de operación que SLG1 gestiona eficientemente |
| Log en tabla estándar de SAP | No existe una tabla estándar adecuada para este propósito en ECC |
| Log externo (file/SIEM) | Infraestructura adicional fuera del alcance del proyecto; introduce dependencias externas |

---

## Consecuencias

**Positivas:**
- Evidencia de auditoría inmutable y de largo plazo
- Separación clara: SLG1 para operaciones, `ZRIF16_AUDIT` para compliance
- Los auditores pueden verificar cualquier cálculo, aprobación o posting
- Detección de manipulación via checksum

**Negativas y riesgos aceptados:**
- Overhead de escritura en `ZRIF16_AUDIT` en cada evento crítico: aceptable dado el volumen esperado de contratos IFRS 16
- La política de retención definitiva requiere confirmación de Legal/DGO (OQ-ABAP-04)
- Archiving de `ZRIF16_AUDIT` debe planificarse en Phase 2

**Precondiciones:**
- OQ-ABAP-04: confirmar retención SLG1 disponible en sistema cliente
- Legal/DGO deben definir política de retención para `ZRIF16_AUDIT` antes de go-live

---

## Criterios de Verificación

- [ ] Objeto de log ZRIF16 creado en SLG1 con sub-objetos
- [ ] Tabla `ZRIF16_AUDIT` creada sin UPDATE/DELETE en ningún programa Z
- [ ] Clase `ZCL_RIF16_AUDIT_WRITER` implementada con método `LOG_EVENT`
- [ ] Test unitario verifica que SCOPE_DETERMINED genera registro de audit
- [ ] Test unitario verifica que CALC_APPROVED genera registro de audit
- [ ] Política de retención confirmada por Legal/DGO antes de go-live

---

## Firmas Requeridas

| Rol | Nombre | Decisión | Fecha |
|-----|--------|----------|-------|
| Project Governance Lead | ________________________ | ☐ APROBADO  ☐ RECHAZADO  ☐ MODIFICADO | ____________ |
| ABAP Architect | ________________________ | ☐ ACEPTADO | ____________ |

**Nota al Project Governance Lead:** La aprobación de este ADR implica el compromiso de iniciar la revisión de política de retención con Legal/DGO antes del fin de Phase 0.

**Comentarios:**
________________________________________________________________________________________

---

*Traceability: docs/governance/decision-log.md | .kiro/steering/ifrs16-domain.md | OQ-ABAP-04 | D-PHASE-02*
*Generado: 2026-03-27 | Pendiente de aprobación*
