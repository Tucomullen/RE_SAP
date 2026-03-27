# Workshop T0-01 — Política Contable IFRS 16
**Fecha objetivo:** TBD — debe realizarse antes del inicio de Phase 1
**Duración estimada:** 3-4 horas
**Participantes requeridos:** IFRS 16 Accountant (lead), Finance Controller, Treasury (para IBR), Project Governance Lead
**Prerequisito para:** Todo diseño funcional de CD-03, CD-04, CD-05 y la aprobación de ADR-004

> **REGLA DE CIERRE:** Este workshop no concluye hasta que todas las decisiones P0 tengan una respuesta firmada. Las decisiones P1 deben quedar al menos con un owner y fecha de resolución confirmada. El output es el documento `T0-01-accounting-policy-template.md` completado y firmado.

---

## 1. Decisiones de Política Contable a Firmar

Las siguientes decisiones deben quedar firmadas en este workshop. Cada una incluye su impacto directo en el diseño del addon y qué queda bloqueado si no se decide.

---

### DEC-ACC-01 — Política IFRS 16 formalmente aprobada
**Prioridad:** P0 — BLOCKER
**Owner:** IFRS 16 Accountant + Finance Controller
**OQ vinculada:** OQ-ACC-01

**Pregunta:** ¿Está la política contable IFRS 16 del grupo formalmente aprobada y vigente?

**Opciones:**
- A) Sí — política aprobada, adjuntar documento firmado
- B) No — se aprueba en este workshop con los parámetros que se definen aquí
- C) Política parcial — existen gaps que deben resolverse en este workshop

**Impacto en diseño:**
- La política define los parámetros de configuración de `CD-03 Valuation Engine Z`
- Sin política firmada, ningún cálculo de valoración puede considerarse válido
- ADR-004 (human approval gate) no puede aprobarse sin saber qué aprueba el Accountant

**Bloquea si no se decide:**
- TODOS los diseños de CD-03, CD-04 y CD-05
- El inicio de Phase 1 (D-PHASE-01)
- La aprobación de ADR-004

---

### DEC-ACC-02 — Tasa IBR: proceso de determinación y gobernanza
**Prioridad:** P0 — BLOCKER
**Owner:** IFRS 16 Accountant + Treasury
**OQ vinculada:** OQ-ACC-03

**Pregunta:** ¿Cómo se determina el IBR (Incremental Borrowing Rate) por sociedad y moneda?

**Opciones a decidir (no excluyentes):**
1. **¿Quién determina el IBR?** → Treasury / Accounting / externo
2. **¿Con qué frecuencia se revisa?** → Por contrato / trimestral / anual / ad-hoc
3. **¿Es por sociedad? ¿Por moneda? ¿Por plazo?** → Confirmar granularidad
4. **¿Se aplica el mismo IBR a contratos existentes o solo a nuevos?**
5. **¿Existe una tabla de IBRs históricos aprobados?**

**Impacto en diseño:**
- `ZRIF16_IBR_CONFIG`: tabla de tasas por BUKRS + moneda + plazo; esta tabla no puede diseñarse sin conocer la granularidad
- `ZCL_RIF16_VALUATION_ENGINE`: la lógica de selección del IBR depende de esta decisión
- ADR-007 (candidate): "IBR governance and rate determination" — se crea cuando esta decisión queda firmada

**Bloquea si no se decide:**
- Cálculo del valor presente de cualquier contrato (C-01, C-02)
- Testing del engine de valoración
- Cualquier migración de contratos existentes

---

### DEC-ACC-03 — Método de reconocimiento: umbral "razonablemente seguro"
**Prioridad:** P1 — HIGH
**Owner:** IFRS 16 Accountant
**OQ vinculada:** OQ-ACC-04

**Pregunta:** ¿Tiene el cliente una definición formal del umbral "REASONABLY CERTAIN" para la evaluación de opciones de renovación?

**Opciones:**
- A) Definición cuantitativa (e.g., >70% probabilidad de ejercer)
- B) Definición cualitativa (criterios de negocio: ubicación estratégica, dependencia operacional, coste de traslado)
- C) Caso a caso — documentado por contrato
- D) Combinación de A+B con C como fallback

**Impacto en diseño:**
- Campo `ZRIF16_CONTRACT.EXTENSION_OPTION_PROBABILITY` y `EXTENSION_OPTION_ASSESSMENT`
- El wizard de creación de contratos debe guiar al usuario a través de esta evaluación
- Si es caso a caso: se requiere campo de justificación textual libre
- Si es cuantitativo: se puede implementar alerta automática cuando un contrato se acerca al umbral de renovación

**Bloquea si no se decide:**
- Diseño del campo de término de arrendamiento en CD-01
- Lógica de selección del `IFRS16_TERM_DATE` en CD-03
- Diseño del evento `OPTION_EXERCISED` en CD-06

---

### DEC-ACC-04 — Costes directos iniciales (IDC): ¿en scope?
**Prioridad:** P1 — HIGH
**Owner:** IFRS 16 Accountant
**OQ vinculada:** OQ-ACC-05 / Coverage B-08

**Pregunta:** ¿Se tracean los costes directos iniciales (IDC) en el sistema actual? ¿Deben incluirse en el cálculo del ROU asset?

**Opciones:**
- A) Sí — actualmente se tracean. Incluir en Z addon como campo obligatorio
- B) No se tracean actualmente, pero deben incluirse. Nuevo campo en Z addon
- C) No son materiales para este portfolio. Campo opcional/informacional
- D) Fuera de scope — no se incluyen

**Impacto en diseño (IFRS 16.24):**
- `ZRIF16_CONTRACT.INITIAL_DIRECT_COSTS` (campo existente en diseño)
- Si en scope: el motor de valoración suma IDC al ROU inicial (`ROU = PV + prepayments + IDC`)
- Si fuera de scope: campo se mantiene pero no participa en cálculo

**Bloquea si no se decide:**
- Fórmula final del ROU asset en CD-03
- Test case de reconocimiento inicial

---

### DEC-ACC-05 — Linearización de rentas escalonadas
**Prioridad:** P1 — HIGH
**Owner:** IFRS 16 Accountant
**OQ vinculada:** OQ-ACC-02 / Coverage B-12

**Pregunta:** ¿Se requiere linealización de gastos de arrendamiento para contratos con rentas escalonadas (stepped rents)?

**Opciones:**
- A) Sí, requerida por política del grupo para todos los contratos con steps
- B) Solo para contratos PGC (local GAAP)
- C) No requerida — se usa el importe real de cada período
- D) Electiva contrato a contrato

**Impacto en diseño:**
- Campo `ZRIF16_SCHEDULE.LINEAR_EXPENSE_PGC` ya existe en el diseño
- Si requerida para IFRS: se añade columna separada para linearización IFRS
- Afecta a la presentación mensual del P&L para contratos con rentas variables

**Bloquea si no se decide:**
- Diseño de la tabla ZRIF16_SCHEDULE (número de columnas de gasto)
- Lógica de posting del batch mensual de CD-04

---

### DEC-ACC-06 — Contratos multicomponente: ¿en scope?
**Prioridad:** P1 — HIGH
**Owner:** IFRS 16 Accountant
**OQ vinculada:** OQ-ACC-08 (nuevo)

**Pregunta:** ¿Existen contratos con componentes de arrendamiento + servicios? ¿Se aplica la separación práctica (practical expedient) de IFRS 16.15?

**Opciones:**
- A) No existen contratos multicomponente en el portfolio → no en scope
- B) Existen pero se aplica el practical expedient → todo el contrato como arrendamiento
- C) Existen y se separan los componentes → requiere modelo de datos adicional

**Impacto en diseño:**
- Si C: se requiere tabla `ZRIF16_CONTRACT_COMPONENT` adicional → complejidad Alta
- Si A o B: modelo de datos actual de CD-01 es suficiente

**Bloquea si no se decide:**
- Modelo de datos definitivo de CD-01 y CD-02
- Complejidad del motor de valoración CD-03

---

### DEC-ACC-07 — Deterioro / Impairment de ROU: ¿en scope?
**Prioridad:** P2 — MEDIUM
**Owner:** IFRS 16 Accountant + Project Governance Lead
**OQ vinculada:** OQ-ACC-06

**Pregunta:** ¿Está el deterioro de activos ROU (impairment) en scope para este proyecto?

**Opciones:**
- A) En scope Phase 1
- B) En scope Phase 2
- C) Fuera de scope — se gestiona manualmente
- D) No aplicable al portfolio

**Impacto en diseño:** Si en scope: capabilidad C-10 activa en CD-03 + CD-05. Si no: flag informacional, sin lógica de cálculo automática.

---

### DEC-ACC-08 — Opción de compra: ¿en scope?
**Prioridad:** P2 — MEDIUM
**Owner:** IFRS 16 Accountant
**OQ vinculada:** OQ-ACC-07

**Pregunta:** ¿Están los contratos con opción de compra (IFRS 16 para 20b) en scope?

**Opciones:**
- A) En scope — el evento `PURCHASE_OPTION_EXERCISED` en CD-06 debe diseñarse
- B) Fuera de scope Phase 1 — diferir a Phase 2
- C) No existe en el portfolio actual

**Impacto en diseño:** Afecta al catálogo de eventos de CD-06 y al tratamiento del ROU asset en CD-05 al momento del ejercicio.

---

### DEC-ACC-09 — Multi-GAAP: alcance de sociedades PGC / USGAAP
**Prioridad:** P0 — BLOCKER (para arquitectura de posting)
**Owner:** IFRS 16 Accountant + FI Architect
**OQ vinculada:** OQ-ACC-01 (extensión) / Coverage C-15, C-16

**Pregunta:** ¿Qué sociedades requieren valoración paralela bajo PGC y/o US GAAP ASC 842?

**Información requerida:**
- Lista de sociedades (BUKRS) con su GAAP requerido: IFRS / PGC / USGAAP / combinación
- ¿Está activo el parallel ledger (LL) en estas sociedades?
- Para USGAAP: ¿cómo se estima el IPC futuro? ¿Existe un rate table aprobado?

**Impacto en diseño:**
- `ZRIF16_GL_MAP.GAAP_TYPE` y la lógica de posting paralelo en CD-04
- El engine US GAAP (`ZCL_RIF16_VALUATION_US_GAAP`) requiere política de estimación IPC
- Afecta directamente al ADR-003 (pending: ledger approach)

**Bloquea si no se decide:**
- Arquitectura de posting de CD-04 (número de entradas FI por período)
- Diseño del tabla de configuración de cuentas GL `ZRIF16_GL_MAP`

---

## 2. Preguntas P0 del Open-Questions Register que Deben Cerrarse

Las siguientes preguntas del registro oficial deben quedar con estado RESOLVED al terminar este workshop:

| ID | Pregunta | Output esperado |
|----|---------|----------------|
| OQ-ACC-01 | ¿Está la política IFRS 16 formalmente firmada? | Política adjunta O decisión firmada en este workshop |
| OQ-ACC-03 | ¿Cómo se determina el IBR por sociedad/moneda? | Documento de proceso IBR + tabla de tasas vigentes |
| OQ-ACC-04 | ¿Está definido el umbral REASONABLY CERTAIN? | Definición formal escrita y firmada |

Adicionalmente, las siguientes P1 deben quedar al menos con owner y fecha confirmada:

| ID | Pregunta | Owner confirmado | Fecha máxima |
|----|---------|-----------------|-------------|
| OQ-ACC-02 | Linearización de rentas escalonadas | IFRS 16 Accountant | Antes de spec de CD-03 |
| OQ-ACC-05 | Initial direct costs en scope | IFRS 16 Accountant | Antes de spec de CD-03 |
| OQ-ACC-08 | Multi-component leases | IFRS 16 Accountant | Antes de spec de CD-01 |

---

## 3. Criterios de Cierre del Workshop

Este workshop se considera CERRADO y exitoso cuando:

- [ ] DEC-ACC-01: Política IFRS 16 firmada o aprobada en workshop
- [ ] DEC-ACC-02: IBR — proceso, granularidad y responsable documentados y firmados
- [ ] DEC-ACC-09: Mapa de sociedades y GAAP confirmado
- [ ] OQ-ACC-01 → estado RESOLVED en el registro
- [ ] OQ-ACC-03 → estado RESOLVED en el registro
- [ ] Documento `T0-01-accounting-policy-template.md` completado y firmado por IFRS 16 Accountant
- [ ] Todas las decisiones P1 tienen owner y fecha de resolución confirmados

---

## 4. Output de Gobierno Requerido

Al terminar el workshop, el Project Governance Lead debe:

1. **Actualizar** `docs/architecture/open-questions-register.md`: mover OQ-ACC-01, OQ-ACC-03, OQ-ACC-04 a Resolution Log
2. **Actualizar** `docs/governance/decision-log.md`: confirmar D-PHASE-01 y D-PHASE-03 como RESOLVED
3. **Crear ADR-007** (IBR governance) en `docs/governance/`
4. **Marcar** `TBC-ORK-04` como resuelto (IFRS 16 Accountant confirmado y disponible)
5. **Desbloquear** el diseño de CD-03, CD-04, CD-05 para Phase 1

---

*Traceability: docs/architecture/open-questions-register.md | docs/governance/decision-log.md — D-PHASE-01 | .kiro/steering/ifrs16-domain.md*
*Última actualización: 2026-03-27 | Preparado para: T0-01 Workshop*
