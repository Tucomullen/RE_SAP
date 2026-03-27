# ADR-001 — Mandato ABAP OO para Todo el Desarrollo Z

**ID:** ADR-001
**Fecha:** 2026-03-24
**Fecha de revisión para aprobación:** 2026-03-27
**Estado:** PROPOSED → Pendiente de aprobación del Project Governance Lead
**Owner:** ABAP Architect
**Categoría:** Technical Architecture
**Prioridad de aprobación:** P0 — Bloqueante para inicio de cualquier desarrollo Z

---

## Contexto

El proyecto requiere una base de código ABAP mantenible, testeable y de larga vida. El cliente está actualmente en SAP ECC y tiene S/4HANA como destino futuro (timeline TBC — OQ-ABAP-06).

El ABAP procedural tiene las siguientes limitaciones demostradas:
- No es testeable mediante ABAP Unit sin wrappers significativos
- Crea acoplamiento estrecho entre lógica de negocio y acceso a datos
- No está alineado con la dirección estratégica de SAP (ABAP Clean Core, S/4HANA ABAP Cloud)
- Genera deuda técnica que se amplifica en cada proyecto posterior

El ABAP OO permite:
- Unit testing nativo con ABAP Unit
- Inyección de dependencias (interfaces `ZIF_*`)
- Separación clara de capas (UI / Business Logic / Data Access)
- Compatibilidad con S/4HANA ABAP Cloud en el horizonte de Phase 3

**Dependency blocker:** Esta decisión debe estar aprobada antes de que el ABAP Architect diseñe cualquier clase Z del proyecto. Sin ella, no hay estándar de desarrollo.

---

## Decisión

**Todo nuevo desarrollo ABAP Z para el addon IFRS 16 usará ABAP OO exclusivamente.**

Reglas concretas:
1. **Capa de lógica de negocio:** Clases `ZCL_RIF16_*` — sin código procedural
2. **Interfaces:** `ZIF_RIF16_*` para abstracción de dependencias (BAPIs, datos, config)
3. **Excepción aceptada:** Clases wrapper sobre FMs estándar de SAP donde el FM no puede ser reemplazado (e.g., `BAPI_ACC_DOCUMENT_POST`). El wrapper es OO; el FM es legacy SAP.
4. **Programas batch (reports):** Punto de entrada procedural aceptado — la lógica real en clases OO llamadas desde el report
5. **Ningún módulo de función Z nuevo** para lógica de negocio. Los FMs existentes heredados del ECC actual pueden mantenerse como wrappers temporales.

**Estándar de calidad:**
- Cada clase de lógica de negocio debe tener test unitarios (`ZCL_RIF16_*_TEST`)
- Code coverage objetivo: ≥ 80% en business logic classes
- Code Inspector / ATC sin errores Priority 1 antes de transport a QA

---

## Alternativas Consideradas

| Alternativa | Razón de Rechazo |
|-------------|----------------|
| ABAP procedural para entrega rápida | Genera deuda técnica no testeable; no alineado con S/4; crea dependencias implícitas entre módulos |
| Enfoque mixto (OO para complejo, procedural para simple) | La frontera "complejo/simple" es subjetiva y no sostenible; genera inconsistencia en la base de código; el mantenimiento futuro no sabe qué estándar aplicar |
| Solo OO para nuevos módulos, procedural para modificaciones de objetos existentes | No hay objetos Z existentes — proyecto nuevo; esta alternativa no aplica |

---

## Consecuencias

**Positivas:**
- Unit testing desde el primer día — detección temprana de errores de cálculo IFRS 16
- Refactoring seguro: las interfaces `ZIF_*` permiten sustituir implementaciones sin afectar al caller
- S/4HANA Phase 3: la base de código existente es compatible por diseño
- Onboarding de nuevos desarrolladores: código autodocumentado via clases/métodos bien nombrados

**Negativas y riesgos aceptados:**
- Requiere desarrolladores con competencia ABAP OO: confirmar disponibilidad con el cliente (OQ-ABAP-06)
- Overhead inicial de diseño de interfaces y clases abstractas: aceptado como inversión
- Los FMs de SAP estándar (`BAPI_*`) siguen siendo procedurales — el wrapper OO añade una capa pero es necesario

**Precondiciones para aplicar esta decisión:**
- OQ-ABAP-01 (namespace Z confirmado) debe estar resuelto antes de crear la primera clase
- OQ-ABAP-06 (versión ABAP del sistema cliente) debe confirmarse en T0-03

---

## Criterios de Verificación

Este ADR se considera cumplido si:
- [ ] El ABAP Architect ha creado la estructura de paquetes `ZRIF16_*` con interfaces base
- [ ] El primer sprint de desarrollo no tiene ninguna función Z procedural de lógica de negocio
- [ ] El framework de ABAP Unit está habilitado en el sistema de desarrollo del cliente
- [ ] ATC se ejecuta en el pipeline de CI antes de cada transport

---

## Firmas Requeridas

| Rol | Nombre | Decisión | Fecha |
|-----|--------|----------|-------|
| Project Governance Lead | ________________________ | ☐ APROBADO  ☐ RECHAZADO  ☐ MODIFICADO | ____________ |
| ABAP Architect | ________________________ | ☐ ACEPTADO | ____________ |

**Comentarios del Project Governance Lead:**
________________________________________________________________________________________

---

*Traceability: docs/governance/decision-log.md | .kiro/steering/tech.md | OQ-ABAP-01, OQ-ABAP-06 | D-PHASE-02*
*Generado: 2026-03-27 | Pendiente de aprobación*
