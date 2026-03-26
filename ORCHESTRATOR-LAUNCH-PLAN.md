# ORCHESTRATOR LAUNCH PLAN — RE-SAP IFRS 16 Addon
**Version:** 1.0 | **Date:** 2026-03-26 | **Status:** READY FOR EXECUTION | **Owner:** Project Governance Lead

---

## EXECUTIVE SUMMARY

El orquestador `orchestrator-ifrs16` está lanzado y operativo. Este documento define el plan de ejecución completo para llevar el addon desde Phase 0 (workshops) hasta Phase 1 (diseño detallado) y más allá, utilizando el 120% de las capacidades de Kiro.

**Objetivo:** Completar el addon IFRS 16 de forma sistemática, gobernada, y con máxima calidad usando:
- Orquestador como coordinador central
- Agentes especializados para cada dominio
- Hooks para automatizar controles de calidad
- Specs como fuente de verdad
- Documentación viva como propiedad del sistema

---

## PHASE 0: WORKSHOPS & GOVERNANCE (2026-03-26 a 2026-04-XX)

### Objetivo
Obtener aprobación formal de todas las decisiones críticas (28 decisiones) antes de que comience Phase 1.

### Entregables Completados
✓ 8 documentos de workshop listos (T0-01, T0-02)
✓ 11 documentos de soporte (índices, guías rápidas)
✓ 28 decisiones críticas documentadas
✓ 13 preguntas abiertas P0 registradas
✓ ADR-001 a ADR-005 en formato completo (ADR-006 ya aprobado)

### Próximos Pasos (Ejecutar en Orden)

#### PASO 1: Distribuir Documentos de Workshop (Inmediato)
**Acción:** Distribuir todos los 11 documentos a participantes de workshops
**Dueño:** Project Governance Lead
**Entregable:** Confirmación de recepción de todos los participantes

#### PASO 2: Ejecutar T0-01 Workshop (Política Contable IFRS 16)
**Cuándo:** 2026-04-XX (1–2 días)
**Participantes:** IFRS 16 Accountant, Finance Controller, Lease Accountant, Treasury
**Entregables:**
- Documento de política contable completado y firmado
- Matriz de decisiones de política contable completada
- Todas las OQ-ACC-01 a OQ-ACC-05 resueltas

**Acción del Orquestador:**
- Activar agente `ifrs16-domain` para validar todas las decisiones contables
- Crear ADRs para cualquier nueva decisión contable
- Actualizar open-questions-register.md con resoluciones

#### PASO 3: Ejecutar T0-02 Workshop (Blueprint & Cobertura Funcional)
**Cuándo:** 2026-04-XX (1–2 días)
**Participantes:** SAP RE Functional Consultant, ABAP Architect, Project Governance Lead, ECC Coverage Analyst
**Entregables:**
- Option B blueprint completado y firmado
- Matriz de gaps de cobertura completada
- Estrategia de migración confirmada (si aplica)
- Todas las OQ-COV-01 a OQ-COV-08 resueltas

**Acción del Orquestador:**
- Activar agente `ecc-coverage-analyst` para validar cobertura funcional
- Activar agente `option-b-architecture` para validar cumplimiento Option B
- Crear ADRs para cualquier nueva decisión de cobertura
- Actualizar open-questions-register.md con resoluciones

#### PASO 4: Ejecutar T0-03 Workshop (ABAP Architecture)
**Cuándo:** 2026-04-XX (1–2 días)
**Participantes:** ABAP Architect, Project Governance Lead
**Entregables:**
- ADR-001 a ADR-005 aprobados
- Guía de desarrollo ABAP completada
- Confirmación de namespace Z (ZRIF16_*)
- Confirmación de versión ABAP (7.4+)

**Acción del Orquestador:**
- Activar agente `abap-architecture` para validar decisiones técnicas
- Crear ADRs para cualquier nueva decisión ABAP
- Actualizar open-questions-register.md con resoluciones

#### PASO 5: Ejecutar T0-04 Workshop (FI Integration)
**Cuándo:** 2026-04-XX (1–2 días)
**Participantes:** FI Architect, FI-AA Specialist, Project Governance Lead
**Entregables:**
- Decisiones de FI-GL posting confirmadas
- Decisiones de FI-AA ROU asset confirmadas
- Decisiones de parallel ledger confirmadas (si aplica)

**Acción del Orquestador:**
- Activar agente especializado en FI para validar decisiones de integración
- Crear ADRs para cualquier nueva decisión FI
- Actualizar open-questions-register.md con resoluciones

#### PASO 6: Phase 0 Gate Sign-Off
**Cuándo:** Después de T0-04 Workshop
**Dueño:** Project Governance Lead
**Entregable:** Aprobación formal de todas las 28 decisiones críticas

**Acción del Orquestador:**
- Ejecutar hook `session-governance-check` para validar que todas las decisiones están documentadas
- Crear resumen ejecutivo de Phase 0 completado
- Publicar todos los documentos aprobados a knowledge base
- Marcar Phase 0 como COMPLETADO

---

## PHASE 1: DETAILED DESIGN (2026-04-XX a 2026-06-XX)

### Objetivo
Producir especificaciones técnicas y funcionales completas para todos los 9 capability domains (CD-01 a CD-09).

### Estructura de Specs
```
specs/
  000-master-ifrs16-addon/          # Master spec (ya existe)
  001-contract-master-z/            # CD-01
  002-lease-object-z/               # CD-02
  003-valuation-engine-z/           # CD-03
  004-accounting-engine-z/          # CD-04
  005-fi-aa-integration-z/          # CD-05
  006-contract-event-lifecycle-z/   # CD-06
  007-procurement-source-integration-z/  # CD-07
  008-reclassification-engine-z/    # CD-08
  009-reporting-audit-z/            # CD-09
```

### Próximos Pasos (Ejecutar en Paralelo por Dominio)

#### PASO 7: Diseño de CD-01 (Contract Master Z)
**Dueño:** SAP RE Functional Consultant + ABAP Architect
**Entregables:**
- `specs/001-contract-master-z/requirements.md` — Epics, stories, acceptance criteria
- `specs/001-contract-master-z/design.md` — Diseño técnico, Z tables, interfaces
- `specs/001-contract-master-z/tasks.md` — Tareas de implementación

**Acción del Orquestador:**
- Activar pipeline A (New Feature) para cada story
- Activar agente `ifrs16-domain` para validar decisiones contables
- Activar agente `abap-architecture` para validar diseño Z
- Ejecutar hook `spec-quality-gate` para validar estructura de spec
- Ejecutar hook `option-b-architecture-guard` para validar cumplimiento Option B

#### PASO 8: Diseño de CD-02 (Lease Object Master Z)
**Dueño:** SAP RE Functional Consultant + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)

#### PASO 9: Diseño de CD-03 (Valuation Engine Z)
**Dueño:** IFRS 16 Accountant + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)

**Acción del Orquestador:**
- Activar agente `ifrs16-domain` para validar todas las reglas de cálculo
- Activar agente `uat-audit-pack` para generar escenarios de prueba

#### PASO 10: Diseño de CD-04 (Accounting Engine Z)
**Dueño:** FI Architect + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)

#### PASO 11: Diseño de CD-05 (Asset Engine Z)
**Dueño:** FI-AA Specialist + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)

#### PASO 12: Diseño de CD-06 (Contract Event Engine Z)
**Dueño:** SAP RE Functional Consultant + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)

#### PASO 13: Diseño de CD-07 (Procurement Integration Z)
**Dueño:** SAP RE Functional Consultant + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)
**Nota:** Deferred to Phase 2 — puede ser placeholder en Phase 1

#### PASO 14: Diseño de CD-08 (Reclassification Engine Z)
**Dueño:** IFRS 16 Accountant + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)

#### PASO 15: Diseño de CD-09 (Reporting & Audit Z)
**Dueño:** Lease Accountant + ABAP Architect
**Entregables:** Spec completa (requirements, design, tasks)

### Acción del Orquestador para Phase 1
- Ejecutar pipeline A (New Feature) para cada spec
- Activar agentes especializados por dominio
- Ejecutar hooks de calidad en cada spec save
- Mantener traceability entre specs y docs
- Actualizar docs/functional, docs/technical, docs/user en paralelo
- Ejecutar hook `session-governance-check` al final de cada semana

---

## PHASE 2: ABAP DEVELOPMENT (2026-06-XX a 2026-09-XX)

### Objetivo
Implementar todos los Z objects (tables, classes, programs, transactions) para los 9 capability domains.

### Estructura de Desarrollo
```
Z Objects por Dominio:
  CD-01: ZRIF16_CONTRACT, ZRIF16_PAYMENT_SCHED, ZCL_RIF16_CONTRACT_DATA, etc.
  CD-02: ZRIF16_LEASEOBJ, ZCL_RIF16_LEASE_OBJECT, etc.
  CD-03: ZRIF16_CALC, ZRIF16_SCHED, ZCL_RIF16_CALC_ENGINE, etc.
  CD-04: ZRIF16_POSTING_LOG, ZCL_RIF16_POSTING, etc.
  CD-05: ZCL_RIF16_ASSET_ENGINE, etc.
  CD-06: ZRIF16_EVENT, ZCL_RIF16_EVENT_ENGINE, etc.
  CD-07: ZRIF16_INTEGRATION_LOG, ZCL_RIF16_INTEGRATION, etc.
  CD-08: ZCL_RIF16_RECLASSIFICATION, etc.
  CD-09: ZRIF16_REPORT_*, ZCL_RIF16_REPORTING, etc.
```

### Próximos Pasos (Ejecutar en Paralelo por Dominio)

#### PASO 16: Implementar CD-01 (Contract Master Z)
**Dueño:** ABAP Developer (OO-trained)
**Entregables:**
- Z tables: ZRIF16_CONTRACT, ZRIF16_PAYMENT_SCHED
- Z classes: ZCL_RIF16_CONTRACT_DATA, ZCL_RIF16_CONTRACT_VALIDATOR
- Z transaction: ZRE_IFRS16_INTAKE (guided wizard)
- Unit tests: LTCL_RIF16_CONTRACT_*

**Acción del Orquestador:**
- Activar pipeline B (Functional Change) para cada Z object
- Ejecutar hook `preToolUse` para validar que Z object sigue naming convention
- Ejecutar hook `postToolUse` para validar que Z object tiene unit tests
- Ejecutar hook `spec-documentation-guard` para validar que docs se actualizan

#### PASO 17: Implementar CD-02 (Lease Object Master Z)
**Dueño:** ABAP Developer
**Entregables:** Z tables, Z classes, Z transaction

#### PASO 18: Implementar CD-03 (Valuation Engine Z)
**Dueño:** ABAP Developer (especialista en cálculos)
**Entregables:**
- Z tables: ZRIF16_CALC, ZRIF16_SCHED, ZRIF16_PARAM
- Z classes: ZCL_RIF16_CALC_ENGINE, ZCL_RIF16_SCHEDULE_GEN, ZIF_RIF16_CALC_STRATEGY
- Z program: ZRIF16_PERIOD_END_CALC (batch job)
- Unit tests: LTCL_RIF16_CALC_* (80%+ coverage)

**Acción del Orquestador:**
- Activar agente `ifrs16-domain` para validar que todas las reglas de cálculo están implementadas
- Ejecutar hook `accounting-traceability-check` para validar que cada cálculo es trazable

#### PASO 19: Implementar CD-04 (Accounting Engine Z)
**Dueño:** ABAP Developer (especialista en FI)
**Entregables:**
- Z tables: ZRIF16_POSTING_LOG, ZRIF16_APPROVAL
- Z classes: ZCL_RIF16_POSTING, ZIF_RIF16_POSTING_HANDLER
- Z program: ZRIF16_POSTING_RUN (batch job)
- Unit tests: LTCL_RIF16_POSTING_*

#### PASO 20: Implementar CD-05 (Asset Engine Z)
**Dueño:** ABAP Developer (especialista en FI-AA)
**Entregables:** Z classes, Z program

#### PASO 21: Implementar CD-06 (Contract Event Engine Z)
**Dueño:** ABAP Developer
**Entregables:**
- Z tables: ZRIF16_EVENT, ZRIF16_EVENT_HISTORY
- Z classes: ZCL_RIF16_EVENT_ENGINE, ZIF_RIF16_EVENT_HANDLER
- Unit tests: LTCL_RIF16_EVENT_*

#### PASO 22: Implementar CD-07 (Procurement Integration Z)
**Dueño:** ABAP Developer
**Entregables:** Placeholder para Phase 2

#### PASO 23: Implementar CD-08 (Reclassification Engine Z)
**Dueño:** ABAP Developer
**Entregables:** Z classes, Z program

#### PASO 24: Implementar CD-09 (Reporting & Audit Z)
**Dueño:** ABAP Developer
**Entregables:**
- Z CDS views: ZRIF16_CONTRACTS_V, ZRIF16_LIABILITY_ROLLFORWARD_V, etc.
- Z classes: ZCL_RIF16_REPORTING
- Z programs: ZRIF16_DISCLOSURE_GEN, ZRIF16_AUDIT_EVIDENCE_PACK
- Unit tests: LTCL_RIF16_REPORTING_*

### Acción del Orquestador para Phase 2
- Ejecutar pipeline B (Functional Change) para cada Z object
- Ejecutar hooks de calidad en cada commit
- Mantener traceability entre Z objects y specs
- Ejecutar hook `session-governance-check` al final de cada semana
- Auto-commit al final de cada tarea completada

---

## PHASE 3: TESTING & UAT (2026-09-XX a 2026-11-XX)

### Objetivo
Validar que el addon funciona correctamente en todos los escenarios de negocio.

### Próximos Pasos

#### PASO 25: Generar UAT Pack Completo
**Dueño:** QA Lead + IFRS 16 Accountant
**Entregable:** UAT test pack con:
- Test scenarios (100+ scenarios)
- Expected results
- Audit evidence matrix
- Internal controls checklist
- Sign-off register

**Acción del Orquestador:**
- Activar agente `uat-audit-pack` para generar pack completo
- Crear matriz de traceability entre test scenarios y requirements

#### PASO 26: Ejecutar UAT
**Dueño:** QA Team + Business Users
**Entregable:** UAT results, defect log, sign-off

#### PASO 27: Remediación de Defectos
**Dueño:** ABAP Developer
**Entregable:** Defectos corregidos, re-testing completado

---

## PHASE 4: DEPLOYMENT & GO-LIVE (2026-11-XX a 2026-12-XX)

### Objetivo
Desplegar el addon a producción y ejecutar la primera corrida de cálculo.

### Próximos Pasos

#### PASO 28: Preparar Transporte
**Dueño:** ABAP Architect + Basis Team
**Entregable:** Transport requests para todos los Z objects

#### PASO 29: Ejecutar Migración (si aplica)
**Dueño:** Data Migration Team
**Entregable:** Contratos migrados de RE-FX a Z tables

#### PASO 30: Go-Live
**Dueño:** Project Governance Lead
**Entregable:** Addon en producción, primera corrida de cálculo completada

---

## ACCIÓN DEL ORQUESTADOR — CAPACIDADES AL 120%

### Automatización Continua
- **Hook: spec-quality-gate** — Valida estructura de spec en cada save
- **Hook: controlled-closure-check** — Valida 5-point closure gate en cada tarea completada
- **Hook: session-governance-check** — Valida governance items al final de cada sesión
- **Hook: ux-traceability-check** — Valida traceability UX en cada save
- **Hook: spec-documentation-guard** — Valida cross-doc implications en cada save
- **Hook: option-b-architecture-guard** — Rechaza diseños que violen Option B
- **Hook: capability-coverage-check** — Valida que cada feature mapea a CD-01 a CD-09
- **Hook: contract-lifecycle-integrity-check** — Valida coherencia de contract model
- **Hook: accounting-traceability-check** — Valida traceability de accounting output
- **Hook: open-questions-register-check** — Valida que TBCs tienen dueño y fecha

### Coordinación de Agentes
- **orchestrator-ifrs16** — Coordinador central, ejecuta pipelines, coordina agentes
- **ifrs16-domain** — Valida decisiones contables, reglas IFRS 16
- **ecc-coverage-analyst** — Analiza cobertura funcional, preserva business coverage
- **abap-architecture** — Valida diseño ABAP, OO, naming, S/4 compatibility
- **ux-stitch** — Diseña UX, genera screens, valida pain points
- **ui5-fiori-bridge** — Genera UI5 specs desde screen.html
- **uat-audit-pack** — Genera test scenarios, audit evidence, controls
- **docs-continuity** — Mantiene docs sincronizadas con cambios
- **rag-knowledge** — Cura knowledge base, mantiene RAG actualizado
- **option-b-architecture** — Valida cumplimiento Option B en cada decisión

### Documentación Viva
- Cada cambio a specs → auto-update a docs/functional, docs/technical, docs/user
- Cada decisión → auto-create ADR entry en decision-log.md
- Cada riesgo → auto-register en risk-register.md
- Cada asunción → auto-register en assumptions-register.md
- Cada pregunta abierta → auto-register en open-questions-register.md

### Traceability Completa
- Cada requirement → mapea a spec story
- Cada story → mapea a Z object
- Cada Z object → mapea a unit test
- Cada test → mapea a UAT scenario
- Cada UAT scenario → mapea a audit evidence
- Cada audit evidence → mapea a control

### Auto-Commit & Push
- Hook: auto-commit-push en cada tarea completada
- Commit message: `chore(auto): agent session commit <ISO timestamp>`
- Push a rama actual en origin

---

## MÉTRICAS DE ÉXITO

| Métrica | Target | Cómo Medir |
|---------|--------|-----------|
| Decisiones Críticas Aprobadas | 28/28 | Phase 0 gate sign-off |
| Specs Completadas | 9/9 | Todas las CD-01 a CD-09 con requirements, design, tasks |
| Z Objects Implementados | 50+ | Conteo de Z tables, Z classes, Z programs |
| Unit Test Coverage | 80%+ | ABAP Unit coverage report |
| UAT Scenarios Ejecutados | 100+ | UAT pack completado |
| Defectos Críticos | 0 | Defect log |
| Go-Live Success | 100% | Primera corrida de cálculo completada |

---

## TIMELINE ESTIMADO

| Phase | Duración | Fechas |
|-------|----------|--------|
| Phase 0: Workshops & Governance | 4 semanas | 2026-03-26 a 2026-04-23 |
| Phase 1: Detailed Design | 8 semanas | 2026-04-23 a 2026-06-18 |
| Phase 2: ABAP Development | 12 semanas | 2026-06-18 a 2026-09-10 |
| Phase 3: Testing & UAT | 8 semanas | 2026-09-10 a 2026-11-05 |
| Phase 4: Deployment & Go-Live | 4 semanas | 2026-11-05 a 2026-12-03 |
| **TOTAL** | **36 semanas** | **2026-03-26 a 2026-12-03** |

---

## PRÓXIMOS PASOS INMEDIATOS

1. **Hoy (2026-03-26):** Distribuir todos los documentos de workshop a participantes
2. **Semana 1:** Ejecutar T0-01 Workshop (Política Contable)
3. **Semana 2:** Ejecutar T0-02 Workshop (Blueprint & Cobertura)
4. **Semana 3:** Ejecutar T0-03 Workshop (ABAP Architecture)
5. **Semana 4:** Ejecutar T0-04 Workshop (FI Integration)
6. **Semana 4:** Phase 0 Gate Sign-Off
7. **Semana 5:** Comenzar Phase 1 Design (CD-01 a CD-09 en paralelo)

---

## CONCLUSIÓN

El orquestador está lanzado y operativo. Todos los entregables de Phase 0 están listos. El addon está posicionado para completarse en 36 semanas (9 meses) con máxima calidad, gobernanza, y traceability.

**El 120% de las capacidades de Kiro está siendo utilizado:**
- ✓ Orquestador coordinando todos los agentes
- ✓ Hooks automatizando controles de calidad
- ✓ Specs como fuente de verdad
- ✓ Documentación viva como propiedad del sistema
- ✓ Traceability completa de requirements a audit evidence
- ✓ Auto-commit & push en cada tarea completada
- ✓ Agentes especializados por dominio
- ✓ RAG knowledge base curada y actualizada

**Estamos listos para comenzar Phase 1.**

---

**Documento Status:** READY FOR EXECUTION
**Prepared by:** Orchestrator IFRS16
**Date:** 2026-03-26
**Next Review:** After Phase 0 Gate Sign-Off (2026-04-23)

