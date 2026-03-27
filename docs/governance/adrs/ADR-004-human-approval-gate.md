# ADR-004 — Gate de Aprobación Humana Obligatorio Antes de Posting FI

**ID:** ADR-004
**Fecha:** 2026-03-24
**Fecha de revisión para aprobación:** 2026-03-27
**Estado:** PROPOSED → Pendiente de aprobación del Project Governance Lead
**Owner:** Project Governance Lead
**Categoría:** Governance / Controls / AI Boundaries
**Prioridad de aprobación:** P0 — Principio de diseño que afecta a CD-03, CD-04 y CD-06 completos
**Prerequisito:** OQ-ACC-01 (política IFRS 16 firmada) — el gate aprueba algo concreto

---

## Contexto

Los cálculos IFRS 16 afectan directamente a los estados financieros publicados del grupo. Un error en el cálculo (tasa IBR incorrecta, lease term equivocado, modificación mal clasificada) se convierte en un error en los estados financieros si el posting se ejecuta sin revisión.

La política de gobernanza de IA del proyecto (`.kiro/steering/ai-governance.md`) establece que:
> *"Ningún agente de IA puede generar ni aprobar posteos FI directamente. Los posteos FI requieren confirmación humana explícita."*

El riesgo de posting automatizado sin gate de aprobación humana es:
- **Financiero:** Cifras incorrectas en balance y P&L
- **Compliance:** IFRS 16 requiere juicio profesional en decisiones de medición
- **Auditoría:** Los auditores requerirán evidencia de que un humano revisó el cálculo antes del posting
- **Segregación de funciones (SOD):** El cálculo y el posting deben ser ejecutados/aprobados por roles distintos

**Dependency:** OQ-UX-03 (tecnología de workflow: SAP standard vs. Z table) afecta a la implementación técnica del gate, pero no a la existencia del gate en sí. Este ADR aprueba la existencia del gate; la tecnología se decide en ADR futuro (T0-04 Workshop).

---

## Decisión

**Ningún posting FI generado por el addon IFRS 16 puede ejecutarse sin aprobación humana explícita en dos niveles.**

### Nivel 1 — Aprobación del Cálculo (Lease Accountant)

**Cuándo:** Después de que el motor de valoración (CD-03) genera el schedule de amortización
**Quién:** IFRS 16 Accountant (rol `ZRIF16_AUTH_APPROVE_CALC`)
**Qué aprueba:**
- Inputs del cálculo: IBR utilizado, lease term, payment schedule snapshot
- Outputs del cálculo: liability inicial, ROU asset inicial, tabla de amortización
- En caso de remedición: delta vs. cálculo anterior

**Lo que el sistema hace tras la aprobación:**
- `ZRIF16_CALC_RUN.STATUS` → `APPROVED`
- Registro en `ZRIF16_AUDIT` con `AUDIT_CAT = CALC_APPROVED`
- El run queda disponible para ejecución de posting por el Finance Controller

**Lo que el sistema NO permite:**
- Ejecutar el cálculo y el posting en la misma sesión de usuario
- Aprobar un cálculo cuyo run no esté en estado `SIMULATED` o `CALCULATED`
- Aprobar cálculos propios del mismo usuario que los generó (SOD enforcement)

### Nivel 2 — Aprobación del Run de Posting (Finance Controller)

**Cuándo:** Antes de ejecutar el posting FI real (BAPI_ACC_DOCUMENT_POST)
**Quién:** Finance Controller (rol `ZRIF16_AUTH_APPROVE_POST`)
**Qué aprueba:**
- Revisión del posting batch completo: todos los contratos del período
- Simulación de posting previamente ejecutada (simulación es obligatoria)
- Impacto en balance/P&L del período

**Lo que el sistema hace tras la aprobación:**
- `ZRIF16_POSTING_RUN.STATUS` → `APPROVED_FOR_POSTING`
- Registro en `ZRIF16_AUDIT` con `AUDIT_CAT = POSTING_APPROVED`
- Habilitación del botón "Ejecutar Posting" solo para el Finance Controller

**Lo que el sistema NO permite:**
- Posting sin simulación previa exitosa
- Posting sin aprobación de Nivel 2
- El mismo usuario que aprobó en Nivel 1 puede ejecutar el Nivel 2 (roles distintos)
- Posting de un período ya cerrado en FI sin autorización adicional

### Diagrama de Flujo de Aprobación

```
[Lease Accountant]          [Finance Controller]        [Sistema Z Addon]
        │                           │                          │
        │── Revisa cálculo ────────>│                          │
        │<─ Simulación mostrada ────│──────────────────────────│
        │── Aprueba cálculo ───────>│                          │
        │                          │<─── CALC APPROVED ────────│
        │                          │── Revisa batch posting ──>│
        │                          │<─── Simulación batch ─────│
        │                          │── Aprueba posting ───────>│
        │                          │                          │── BAPI_ACC_DOC_POST
        │                          │                          │── ZRIF16_AUDIT write
        │                          │<─── Posting ejecutado ────│
```

### Reglas Adicionales de Control

1. **Caducidad de aprobación:** Una aprobación de cálculo caduca si los datos del contrato cambian después de la aprobación. El sistema invalida automáticamente la aprobación y requiere re-aprobación.
2. **Timeout de aprobación:** Si un cálculo aprobado no se postea en `[N días TBD]`, la aprobación caduca y debe renovarse.
3. **Límite de reaprobación:** Un mismo cálculo que ha sido rechazado 2 veces requiere escalación al Project Governance Lead.
4. **Periodo cerrado:** Posting en período FI ya cerrado requiere autorización de excepción adicional con justificación documentada.

---

## Alternativas Consideradas

| Alternativa | Razón de Rechazo |
|-------------|----------------|
| Posting completamente automatizado | Riesgo de compliance inaceptable; viola la política de gobernanza de IA del proyecto; auditores rechazarán evidencia sin revisión humana |
| Un solo aprobador (solo Accountant) | SOD insuficiente; el Finance Controller necesita visibilidad del impacto en P&L antes de que llegue a GL; estándar de control interno para procesos contables materiales |
| Aprobación por muestreo (solo algunos contratos) | Inaceptable — todos los contratos activos afectan a estados financieros |
| Posting y reversión si hay error | Genera complejidad de auditoría; cada posting adicional requiere justificación; multiplica el riesgo de error |

---

## Consecuencias

**Positivas:**
- Evidencia de auditoría clara: para cada posting existe una aprobación humana documentada
- SOD cumplida: cálculo y posting aprobados por roles distintos
- El Finance Controller tiene visibilidad del impacto antes del cierre
- Protección ante cálculos incorrectos generados por datos erróneos

**Negativas y riesgos aceptados:**
- El proceso de cierre de período requiere al menos un día adicional para el flujo de aprobación
- La tecnología de workflow (SAP WS vs. Z table) afecta a la usabilidad del gate — debe resolverse en T0-04 (OQ-UX-03)
- Los usuarios deben entender y asumir sus roles de aprobación antes del go-live — formación requerida

**Implicaciones para el diseño técnico:**
- CD-03 Valuation Engine: añadir state machine `DRAFT → SIMULATED → APPROVED → POSTED`
- CD-04 Accounting Engine: el BAPI no puede llamarse si `CALC_RUN.STATUS ≠ APPROVED`
- Objetos de autorización `ZRIF16_AUTH_APPROVE_CALC` y `ZRIF16_AUTH_APPROVE_POST` a diseñar
- La misma sesión de usuario no puede cambiar estado de `CALCULATED` a `APPROVED` y ejecutar posting

---

## Criterios de Verificación

- [ ] El motor de valoración (CD-03) implementa state machine completa
- [ ] El BAPI de posting no puede ser llamado sin `POSTING_RUN.STATUS = APPROVED_FOR_POSTING`
- [ ] Test: usuario con solo rol de Accountant no puede ejecutar posting
- [ ] Test: usuario con solo rol de Controller no puede aprobar cálculo
- [ ] Test: el mismo usuario que generó el cálculo no puede aprobarlo
- [ ] `ZRIF16_AUDIT` registra toda aprobación con usuario, timestamp e inputs aprobados

---

## Firmas Requeridas

| Rol | Nombre | Decisión | Fecha |
|-----|--------|----------|-------|
| Project Governance Lead | ________________________ | ☐ APROBADO  ☐ RECHAZADO  ☐ MODIFICADO | ____________ |
| Finance Controller (cliente) | ________________________ | ☐ ACEPTADO | ____________ |
| IFRS 16 Accountant (cliente) | ________________________ | ☐ ACEPTADO | ____________ |

**Nota importante:** La aprobación de este ADR requiere que el IFRS 16 Accountant y el Finance Controller del cliente confirmen que el flujo de aprobación aquí descrito es compatible con su proceso operativo de cierre de período. Si el plazo del período es muy ajustado, se debe discutir el SLA de aprobación.

**Comentarios:**
________________________________________________________________________________________

---

*Traceability: docs/governance/decision-log.md | .kiro/steering/ai-governance.md | OQ-ACC-01, OQ-UX-03 | D-PHASE-01*
*Generado: 2026-03-27 | Pendiente de aprobación*
