# IFRS16 Functional Coverage Matrix — ECC → Option B Addon Z

**Version:** 1.0 | **Date:** 2026-03-26 | **Status:** Draft — Pending Business Validation
**Based on:** BBP_IFRS16_Implantación SAP RE_v3.pdf | D05_Reclasificación LP a CP_v1.7.pdf | DF_Generación automática contrato_v3.pdf
**Maintained by:** ECC Coverage Analyst + Migration Coverage Reviewer

> **Option B Mandate (ADR-006):** RE-FX is NOT used at runtime. The Z addon is the system of record. All capabilities below must be delivered by Z tables, Z logic, and direct FI/AA BAPIs.

---

## How to Read This Matrix

| Column | Meaning |
|--------|---------|
| Area | Functional area (A–Q) |
| Capability ID | Unique identifier for tracking |
| Functional Capability | What the business capability does |
| Source Document | Which ECC document evidences this capability |
| ECC Type | RE-FX / Z-Custom / Hybrid / Manual |
| Current Behavior | How it works in ECC today |
| Target Domain | Which of the 9 Option B capability domains owns this |
| Option B Design Direction | How the Z addon will deliver this |
| Automation | None / Partial / High |
| Improvement | Specific improvement opportunity vs. ECC |
| Priority | MUST / SHOULD / LATER |
| Risk if Omitted | Business/accounting risk |
| Complexity | Low / Medium / High |
| Dependencies | Other capabilities that must exist first |
| Open Questions | Unresolved items → linked to open-questions-register.md |

---

## A. Contract Master Data

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| A-01 | Company code assignment to contract | BBP §3.2.3.1.1 | RE-FX | Contract created under a FI Sociedad; RE-FX inherits organizational assignment | CD-01 | ZRIF16_CONTRACT.BUKRS field; drives FI-AA asset society and FI-GL posting society | None | Multi-society contract creation from single Z screen | MUST | Cannot post FI documents without Bukrs | Low | CD-04 FI-GL posting | None |
| A-02 | Contract type (Clase de contrato) | BBP §3.2.3.1, Annex 8.5 | RE-FX | 9 contract types: C001 Construcciones, C002 Instalaciones técnicas, C003 Equipos informáticos, C004 Maquinaria, C005 Elementos transporte, C006 Terrenos, C007 Enseres/utillaje, C008 Otro inmovilizado, C009 Aplicaciones informáticas + CM00 Marco | CD-01 | ZRIF16_CONTRACT.ZCONTRACT_TYPE; config table ZRIF16_CTYPE mapping contract type → FI-AA asset class | None | Simpler classification screen vs. RE-FX RECN | MUST | FI-AA asset class cannot be determined; ROU asset cannot be created | Low | CD-02 lease object, CD-05 FI-AA | OQ-CTYPE-01: Confirm final list of contract types needed |
| A-03 | Contract start and end dates | BBP §3.2.3.1.2 | RE-FX | Start date (Inicio contrato), First end date (Primer fin contrato), End of validity (Fin periodo vigencia including renewals) | CD-01 | ZRIF16_CONTRACT: START_DATE, FIRST_END_DATE, CALC_END_DATE (IFRS 16 lease term), CONTRACTUAL_END_DATE | None | Single date model — no ambiguity between contractual end and IFRS 16 probable end | MUST | Cannot calculate lease term for IFRS 16 | Low | CD-03 valuation | None |
| A-04 | IFRS 16 lease term (probable end / fin probable) | BBP §3.2.3.4 | RE-FX | "Fin probable" — the end date used for IFRS 16 calculation (may differ from contractual end date). Manually entered. Extension options assessed manually. | CD-01 | ZRIF16_CONTRACT.IFRS16_TERM_DATE + ZRIF16_CONTRACT.EXTENSION_OPTION_FLAG; human validation required | None | Explicit field with audit trail; extension option assessment must be validated by accountant | MUST | Incorrect IFRS 16 liability calculation | Medium | CD-03, CD-06 events | OQ-ACC-03: How is extension probability assessed and documented? |
| A-05 | Renewal/extension conditions (Prórroga) | BBP §3.2.3.1.2 | RE-FX | Prórroga type (automatic / by option), quantity, duration, notice period | CD-01 | ZRIF16_CONTRACT_RNEWAL table: type, duration, quantity, notice_days | None | Structured renewal capture linked to IFRS 16 option assessment | MUST | Cannot assess extension option for IFRS 16 lease term | Medium | CD-06 events | OQ-CTYPE-02: Are there auto-renewal cases requiring system-triggered reassessment? |
| A-06 | Early termination conditions (Rescisión) | BBP §3.2.3.1.2 | RE-FX | Rescisión party (arrendador/arrendatario/ambos), rescisión date rule, notice period | CD-01 | ZRIF16_CONTRACT_TERM: who can terminate, when, notice_days | None | Termination clause directly drives IFRS 16 lease term assessment | MUST | Cannot determine correct lease term under IFRS 16.19 | Medium | CD-06 events | None |
| A-07 | Lessor/vendor (Arrendador) — Business Partner | BBP §3.2.1, §4.1.1 | RE-FX + Z | BP role TR602 Arrendador linked to vendor; auto-replication from vendor master | CD-01 | ZRIF16_CONTRACT.VENDOR_ID (FK to SAP vendor); no BP hierarchy needed in Z addon; vendor master read-only | Partial | Eliminate BP role complexity; contract directly references vendor | MUST | Cannot generate FI-AA or FI-GL postings without vendor | Low | CD-04 FI-GL | OQ-BP-01: Can the Z addon use vendor directly without BP role? Confirm with FI Architect |
| A-08 | Multiple lessors per contract | BBP §3.2.3.2 | RE-FX | Multiple BPs with TR602 role; conditions split per BP; billing split | CD-01 | ZRIF16_CONTRACT_PARTY table: multiple vendors per contract with % participation | None | Cleaner split model | SHOULD | If omitted, multi-landlord contracts cannot be managed | High | CD-04 posting | OQ-BP-02: How common are multi-lessor contracts in the current portfolio? |
| A-09 | Payment conditions / rent schedule (Condiciones) | BBP §3.2.3.3.2, Annex 8.8 | RE-FX | Conditions: C100 fixed rent, variable rent, stepped, statistical; marked as relevant/not relevant for valuation | CD-01 | ZRIF16_PYMT_SCHED: condition type, valid_from, valid_to, amount, currency, valuation_relevant flag | None | Clear separation of IFRS-relevant vs. informational conditions | MUST | Cannot calculate liability without payment schedule | Medium | CD-03 valuation | None |
| A-10 | Stepped/escalating rents | BBP §3.2.3.3.2, §2.3 (limitation) | RE-FX | Multiple condition rows with different valid_from dates; system linearizes | CD-01 | Multiple rows in ZRIF16_PYMT_SCHED with different date ranges | None | Better visibility of rent steps | MUST | Incorrect amortization schedule | Medium | CD-03 | None |
| A-11 | Variable rent (Renta variable) | BBP §3.2.3.3.2, §2.3 | RE-FX | Condition type "variable" — informational only, NOT included in IFRS 16 valuation | CD-01 | ZRIF16_PYMT_SCHED with VALUATION_RELEVANT = N; stored but excluded from calculation | None | Explicit exclusion flag is clearer than RE-FX condition purpose field | MUST | Variable rent must be tracked for reporting but not capitalized | Low | CD-03 | None |
| A-12 | Advance payments / prepayments (Anticipos) | BBP §4.2.1 | RE-FX + FI | Condition type "Anticipo"; reduces liability by advance amount; bridge account mechanic | CD-01 | ZRIF16_CONTRACT.PREPAYMENT_AMOUNT + prepayment condition row in ZRIF16_PYMT_SCHED | None | Direct prepayment field eliminates bridge account complexity | MUST | ROU asset overcalculated; no IFRS 16.24 compliance without prepayment capture | Medium | CD-03, CD-04 | OQ-ACC-04: Full advance payment vs. partial — same logic? Confirm |
| A-13 | Incremental/direct costs (Costes incrementales) | BBP §4.2.2 | RE-FX | Condition type for incremental costs; increases ROU asset; separate from lease payments | CD-01 | ZRIF16_CONTRACT.INITIAL_DIRECT_COSTS field (single amount at inception) | None | Single field is simpler than RE-FX condition type | MUST | IFRS 16.24 compliance requires IDC in ROU asset | Medium | CD-03 | None |
| A-14 | Payment frequency and form (Periodicidad / postpago) | BBP §3.2.3.3.1 | RE-FX | Periodicidad (monthly/quarterly/annual), Inicio frecuencia (start of calendar year), Form (postpago = end of month) | CD-01 | ZRIF16_CONTRACT: PAYMENT_FREQ, PAYMENT_FORM (pre/post), FREQ_START | None | Dropdown UI vs. RE-FX multi-level config | MUST | Incorrect cash flow schedule | Low | CD-03 | None |
| A-15 | Currency (multi-currency) | BBP §3.2.3.1.1 | RE-FX | Contract currency; overridable from company code currency; foreign currency contracts | CD-01 | ZRIF16_CONTRACT.CURRENCY; exchange rate handling via standard SAP FX | None | Explicit FX contract flag for reporting | MUST | Cannot post FI documents in correct currency | Low | CD-04 | OQ-FX-01: FX remeasurement logic for contracts in non-local currency — confirm accounting policy |
| A-16 | Cost center / profit center assignment | BBP §3.2.3.3.1 | RE-FX | Assigned per valuation rule (Regla de valoración); one cost object per valuation rule; multiple valuation rules → multiple cost centers | CD-01 | ZRIF16_CONTRACT.COST_CENTER + PROFIT_CENTER; for multi-CC contracts: ZRIF16_CONTRACT_CC table | None | Simpler CO assignment model | MUST | FI-GL documents have no CO object | Medium | CD-04 | None |
| A-17 | Multiple cost centers per contract | BBP §3.2.3.3.1 | RE-FX | One valuation rule per cost center; complex multi-rule model | CD-01 | ZRIF16_CONTRACT_CC table: one row per cost center with % split | None | Percentage split model instead of multiple valuation rules | SHOULD | Contracts with multiple cost centers cannot be processed | High | CD-03 per-CC schedule | OQ-CO-01: How many contracts currently have multiple cost centers? |
| A-18 | Rent index adjustment (IPC/ajuste) | BBP §3.2.3.3.3, §4.2.3/4.2.4, Annex 8.9 | RE-FX | Adjustment rules by index type (IPC, fixed %, custom); mass update via REAJPR | CD-01 + CD-06 | ZRIF16_RENT_ADJ: adj_type, index_type, base_date, update_freq; mass update program Z | Partial | Automated mass IPC update job | MUST | Rent review not reflected → incorrect IFRS 16 liability | High | CD-03 recalculation | OQ-ACC-05: IPC adjustment triggers IFRS 16 remeasurement always, or only if rate-indexed? Confirm per IFRS 16.42(b) |
| A-19 | Contract document attachment (URL) | BBP §3.2.3.1.1 | RE-FX | URL link to Interacciona document system; attached post-creation | CD-01 | ZRIF16_CONTRACT.DOC_URL field; uploadable as part of contract creation wizard | None | Integrated in creation wizard vs. RE-FX post-creation step | MUST | Audit trail without document evidence is incomplete | Low | None | None |
| A-20 | SII Spain referencia catastral | BBP §3.2.2.3 | RE-FX + Z | Manual entry in ZINDSII_ALQ → /INDSII/REFCADAC; mandatory for Energía division | CD-01 | ZRIF16_LEASE_OBJ.CATASTRAL_REF; mandatory flag per division; SII integration read from Z field | None | Integrated in object creation vs. separate manual transaction | SHOULD | Spain SII reporting incomplete | Medium | CD-02 | OQ-COUNTRY-01: Confirm SII reporting requirements per society |
| A-21 | Mass contract load (Carga masiva inicial) | BBP §6.1.3 | Z-Custom | Excel template → Z LEGACY program; blocks: general data, conditions, valuation data | CD-01 | Z mass upload program reading from Excel/CSV → ZRIF16_CONTRACT; validation before activation | High | Reusable mass upload — not just for migration but also ongoing | MUST | Initial portfolio cannot be loaded without mass upload | High | All CD-01 fields | OQ-MAST-01: Confirm final field template for mass upload |
| A-22 | Contract number (internal assignment) | BBP §3.2.3.1.1 | RE-FX | SAP internal number from RE-FX contract table | CD-01 | System-generated Z Contract ID (ZRIF16_CNT_ID); format TBD with ABAP Architect | None | Stable Z ID not dependent on RE-FX internal number | MUST | All domains need stable anchor key | Low | All domains | OQ-ABAP-01: Confirm number range and format for Z contract ID |
| A-23 | Framework contract reference (Contrato marco) | BBP §3.2.3.1.1 | RE-FX | Optional reference to parent framework contract (Contrato pral) | CD-01 | ZRIF16_CONTRACT.FRAMEWORK_CONTRACT_REF (optional FK to another contract) | None | Explicit parent/child contract model | SHOULD | Vehicle renting and framework contracts lose traceability | Low | None | None |
| A-24 | Previous contract reference (Contrato anterior) | BBP §3.2.3.1.1 | RE-FX | Reference to prior system contract number | CD-01 | ZRIF16_CONTRACT.PREV_SYSTEM_REF (migration reference field) | None | Migration traceability | MUST | Cannot trace migrated contracts to source system | Low | None | None |

---

## B. Lease Object Management

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| B-01 | Lease object types: land/buildings (UA hierarchy) | BBP §3.2.2 | RE-FX | Unidad Económica → Terreno → Unidad de Alquiler hierarchy; only for terrenos | CD-02 | ZRIF16_LEASE_OBJ with OBJ_TYPE = LAND; no hierarchy required; flat structure | None | Eliminate 3-level hierarchy complexity for simple land parcels | MUST | Land contracts have no object to reference | Medium | CD-01 | None |
| B-02 | Lease object types: movable assets (J4) | BBP §3.2.2.4 | RE-FX | J4 object — no master data hierarchy; created inline in contract; class codes J007 (vehicles), etc. | CD-02 | ZRIF16_LEASE_OBJ with OBJ_TYPE per Annex 8.6 class list; reusable across contracts | None | Explicit object master vs. RE-FX inline J4 | MUST | Object classification cannot be reported | Low | CD-01 | None |
| B-03 | Object classification (Clase de uso/objeto) | BBP §3.2.2.4, Annex 8.6 | RE-FX | J4 object class (J001-J009+) determines type | CD-02 | ZRIF16_LEASE_OBJ.OBJ_CLASS; config table ZRIF16_OBJ_CLASS mapping to FI-AA asset class | None | Direct mapping table visible to users | MUST | FI-AA asset class cannot be determined | Low | CD-05 FI-AA | OQ-OBJ-01: Provide full Annex 8.6 class list for option B mapping |
| B-04 | Multiple objects per contract | BBP §3.2.3.2.1 | RE-FX | Multiple J4 or UA objects per contract; each can have separate cost object | CD-02 | ZRIF16_CONTRACT_OBJ (M:N table); one IFRS 16 calculation per object or aggregated — confirm | None | Cleaner multi-object view | MUST | Contracts with multiple leased assets cannot be modeled | High | CD-01, CD-03 | OQ-OBJ-02: Is IFRS 16 calculated per object or per contract? |
| B-05 | Object reuse across contracts | BBP §3.2.2.4.2 | RE-FX | RE-FX objects are reused; J4 objects are inline (not reused) | CD-02 | ZRIF16_LEASE_OBJ is a reusable master; referenced by ZRIF16_CONTRACT_OBJ | None | Better asset tracking across leases | SHOULD | Cannot track same physical asset across multiple lease contracts | Medium | CD-01 | None |
| B-06 | Cost center assignment per object | BBP §3.2.2.4 | RE-FX | Cost object (imputación) on J4 object; one per J4 | CD-02 | ZRIF16_LEASE_OBJ.COST_CENTER; overridable at contract level | None | Object-level vs. contract-level cost assignment | MUST | FI-GL postings have no CO object | Low | CD-04 | None |
| B-07 | Cadastral reference for land (Referencia catastral) | BBP §3.2.2.3.2 | RE-FX | Stored in UA Equipamiento tab; mandatory for Energía division | CD-02 | ZRIF16_LEASE_OBJ.CATASTRAL_REF with mandatory flag per company code/division | None | Validation enforced at object creation | SHOULD | Spain SII reporting failures | Low | None | OQ-COUNTRY-01 |
| B-08 | Object description / denomination | BBP §3.2.2.4 | RE-FX | Free text 60 chars; contains matricula for vehicles | CD-02 | ZRIF16_LEASE_OBJ.DESCRIPTION (60 chars) + ZRIF16_LEASE_OBJ.PLATE_NUMBER for vehicles | None | Separate structured plate field vs. embedded in description text | SHOULD | Vehicle search/reporting is difficult | Low | None | None |

---

## C. IFRS16 Valuation Logic

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| C-01 | Initial lease liability (PV of payments at IBR) | BBP §4.1.6, §3.2.3.5 | RE-FX | Automatic calculation in RE-FX valuation engine; uses IBR (Tipo de interés) from valuation rule; discounts all IFRS-relevant conditions | CD-03 | ZCL_RIF16_VALUATION_ENGINE: PV calculation using IBR, payment schedule, payment frequency, payment form (pre/post) | High | Full Z calculation — transparent, auditable inputs | MUST | Cannot recognize initial lease liability | High | CD-01 (payment schedule, IBR) | OQ-ACC-03: IBR determination process |
| C-02 | IBR (Incremental Borrowing Rate) input and storage | BBP §3.2.3.4 | RE-FX | Tipo de interés — free-form entry on valuation rule; no validation | CD-03 | ZRIF16_CALC_RUN input; stored as snapshot in ZRIF16_CALC_ITEM.IBR_USED | None | IBR stored as immutable input per calculation run | MUST | Rate not auditable → audit risk | Low | None | OQ-ACC-03 |
| C-03 | Initial ROU asset (liability + prepayments + IDC) | BBP §4.1.5, §4.1.8, IFRS 16.24 | RE-FX | ROU = PV lease payments + advance payments + incremental costs | CD-03 | ZCL_RIF16_VALUATION_ENGINE: ROU = liability + PREPAYMENT_AMOUNT + INITIAL_DIRECT_COSTS | High | Explicit ROU formula vs. RE-FX automated derivation | MUST | IFRS 16.24 non-compliance | Medium | CD-01 | None |
| C-04 | Full amortization + interest schedule generation | BBP §4.1.6, §3.2.3.5 | RE-FX | Generated automatically after valuation rule saved; shows per period: opening balance, interest, payment, closing balance | CD-03 | ZRIF16_SCHEDULE table: one row per period per contract; columns: period, opening_liability, interest, payment, closing_liability, opening_rou, amortization, closing_rou | High | Schedule stored and queryable at any time | MUST | Cannot generate periodic accounting entries without schedule | High | C-01, C-02, C-03 | None |
| C-05 | Linearization of expenses (Linealización del gasto) | BBP §4.2.6, §2.3 | RE-FX | PGC: monthly expense accrual even when payment is non-monthly; RE-FX linearizes; eliminates lumpy P&L | CD-03 | ZRIF16_SCHEDULE.LINEAR_EXPENSE_PGC: monthly linear amount; driven by PGC valuation flag | Partial | Explicit linearization flag per contract | MUST | PGC expense recognition incorrect for non-monthly payment contracts | Medium | CD-01 (PGC flag) | OQ-ACC-06: Which contracts require linearization? Confirm PGC scope |
| C-06 | Advance payment (anticipo) valuation | BBP §4.2.1 | RE-FX | Total advance: ROU recognized, liability created then immediately reversed; partial advance: ROU includes full value, liability reflects net | CD-03 | ZRIF16_VALUATION_ENGINE: PREPAYMENT_TYPE (TOTAL/PARTIAL); schedule adjusted; PGC periodification via ZRIF16_SCHEDULE.LINEARIZATION_PGC | Medium | No bridge account complexity in Z | MUST | Advance payment contracts have incorrect opening balance | High | A-12 | OQ-ACC-04 |
| C-07 | Incremental/direct costs in ROU | BBP §4.2.2 | RE-FX | IDC condition adds to ROU; immediately reversed from liability | CD-03 | ZCL_RIF16_VALUATION_ENGINE adds IDC to initial ROU; IDC not included in liability schedule | None | Explicit IDC field — no condition type complexity | MUST | IFRS 16.24 non-compliance | Low | A-13 | None |
| C-08 | Rent update recalculation (remeasurement on IPC) | BBP §4.2.3, §4.2.4 | RE-FX | After IPC adjustment: valuation recalculated; new schedule from adjustment date; if ROU < 0 → P&L impact | CD-03 | New ZRIF16_CALC_RUN triggered by CD-06 PAYMENT_CHANGED event; new ZRIF16_SCHEDULE from effective date | Partial | Event-driven recalculation vs. RE-FX manual RECEEP | MUST | Incorrect post-remeasurement balance | High | CD-06 events | OQ-ACC-05 |
| C-09 | Remeasurement on modification/extension | BBP §4.3 | RE-FX | Manual recalculation after modification; new valuation overrides prior | CD-03 | New ZRIF16_CALC_RUN from modification event; prior run preserved (immutable) | Partial | Non-destructive recalculation | MUST | Modification accounting incorrect | High | CD-06 | OQ-ACC-07: Define which modifications always trigger remeasurement |
| C-10 | Impairment / deterioro | BBP §3.3.3, §4.3.5 | RE-FX + FI-AA | Via non-planned depreciation in FI-AA areas 01/11/12; movement types ZDR/ZCR | CD-03 + CD-05 | Z impairment indicator on contract; triggers non-planned FI-AA depreciation posting via CD-05 | None | Impairment flag with audit trail | SHOULD | Impaired ROU assets not reflected | High | CD-05 FI-AA | OQ-AA-01: How many contracts have impairment history? Confirm scope |
| C-11 | Calculation simulation (without saving) | BBP §4.1.6 (implied), D05 §3.4 | RE-FX | Implicit in RE-FX (simulation mode via BAPI_ACC_DOCUMENT_CHECK) | CD-03 | ZRIF16_CALC_RUN.SIM_FLAG = X; results stored temporarily; user approves → saves permanently | High | Explicit simulation workflow | MUST | Finance team cannot review before committing | Medium | None | None |
| C-12 | Calculation input snapshot (audit) | BBP §3.2.3.5 | RE-FX | Implicit in RE-FX valuation log | CD-03 | ZRIF16_CALC_ITEM stores snapshot: IBR_USED, TERM_USED, PAYMENT_SCHEDULE_SNAPSHOT, EFFECTIVE_DATE | High | Explicit immutable input record per run | MUST | Audit cannot verify what inputs were used | Medium | None | None |
| C-13 | Short-term exemption (< 12 months) | BBP §2.3 (limitation: excluded) | RE-FX | "no serán inferiores al año" — renting vehicles excluded by premise; not explicitly managed | CD-01 + CD-03 | ZRIF16_CONTRACT.EXEMPTION_TYPE = SHORT_TERM; no valuation run created; expense recognized directly | None | Explicit exemption flag with justification field | MUST | IFRS 16.B34 compliance | Medium | CD-01 | OQ-ACC-08: Scope of short-term exemption in current portfolio |
| C-14 | Low-value exemption (< USD 5000) | BBP §2.3 (limitation: excluded in vehicles) | RE-FX | Excluded by premise in vehicle renting; not explicitly managed for other asset types | CD-01 + CD-03 | ZRIF16_CONTRACT.EXEMPTION_TYPE = LOW_VALUE with documented threshold | None | Configurable threshold by asset type | MUST | IFRS 16.B3-B8 compliance | Low | CD-01 | OQ-ACC-08 |
| C-15 | Multi-GAAP parallel valuation (IFRS + PGC) | BBP §4.1.9 | RE-FX | Two valuation rules per contract (IFRS16 + AJUSTE_PGC); PGC reverses all IFRS entries with LL document class | CD-03 | ZRIF16_CALC_RUN.GAAP_TYPE (IFRS/PGC/US_GAAP); PGC valuation produces reversal entries | High | Automated parallel posting vs. semi-manual in RE-FX | MUST | Local GAAP compliance failure | High | CD-04 FI-GL | OQ-ACC-01: Confirm which societies use PGC vs. IFRS only vs. USGAAP |
| C-16 | US GAAP ASC 842 valuation (estimated IPC) | BBP §6.1.5 | Z-Custom (GAP) | Custom Z development required; SAP RE-FX standard does not support; estimated IPC for full contract term; linear fixed payments; differences adjusted each year | CD-03 | ZCL_RIF16_VALUATION_US_GAAP: estimated IPC schedule; linear payment calculation; annual delta calculation | Partial | Option B Z engine can natively implement this | MUST | US GAAP compliance failure for USD societies | High | C-01, C-15, CD-04 | OQ-ACC-09: Confirm scope of US GAAP societies and IPC estimation policy |
| C-17 | Retrospective method at transition (01.01.2019) | BBP §4.1.10 | RE-FX | Method: asset = liability at transition date; reserve account entry | CD-03 | Migration-only calculation; ZRIF16_CALC_RUN.IS_TRANSITION_RUN flag; reserve entry via CD-04 | High | Automated migration calculation | SHOULD (migration only) | Migration balance incorrect | High | None | OQ-MAST-02: Is retrospective method still needed for new contracts or migration only? |

---

## D. Multi-GAAP / Local GAAP

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| D-01 | PGC local GAAP reversal (cuentas L*) | BBP §4.1.9, §4.2 | RE-FX | LL document class; L-prefix accounts reverse all IFRS entries | CD-04 | ZRIF16_GL_MAP.GAAP_TYPE = PGC; reversal posting generated per period alongside IFRS posting | High | Automated parallel posting | MUST | PGC compliance failure | Medium | C-15, CD-04 | None |
| D-02 | US GAAP parallel valuation and posting | BBP §4.1.9, §6.1.5 | RE-FX + Z-Custom (partial) | Partially standard, partially Z development needed; estimated IPC; linear payments | CD-03 + CD-04 | Full Z implementation: estimated IPC at inception; linear payment schedule; annual delta posting | High | Option B can natively implement fully | MUST | US GAAP compliance for USD entities | High | C-16 | OQ-ACC-09 |
| D-03 | Multi-ledger posting (0L + LL) | BBP §2.4 | RE-FX + FI config | Costa Rica and India have two fiscal year ledgers; RE-FX uses Z0LL presentation rule | CD-04 | ZRIF16_GL_MAP.LEDGER_SCENARIO; BAPI_ACC_DOCUMENT_POST with ledger specification | None | Config-driven ledger selection | MUST | Costa Rica/India postings incomplete | High | CD-04 | OQ-FI-01: Confirm ledger approach — extension ledger vs. parallel ledger |
| D-04 | Impairment in local GAAP (deterioro PGC) | BBP §3.3.3 | FI-AA + RE-FX | Non-planned depreciation in areas 01/11/12 via movement types ZDR/ZCR | CD-05 + CD-04 | Z impairment event → non-planned FI-AA depreciation; LL adjustment posting generated | None | Event-driven impairment | SHOULD | Impairment not reflected in PGC balance | High | CD-05, C-10 | OQ-AA-01 |
| D-05 | Country-specific: Poland advance payments | BBP §3.1.1 (inferred from PLN societies) | RE-FX | Poland specific advance payment handling (inferred — specific design TBC) | CD-03 | ZRIF16_CONTRACT.COUNTRY_VARIANT = PL; Z engine applies Poland-specific prepayment logic | None | Explicit country variant | MUST | Poland contracts calculated incorrectly | Medium | C-06 | OQ-COUNTRY-02: Document Poland advance payment accounting specifics |
| D-06 | Chile UF/CLF currency | BBP §6.2.1 (validation) | FI validation | CLF currency allowed in RE-FX transactions via validation ZRE_TCODES set | CD-04 | ZRIF16_GL_MAP currency handling; CLF posting supported; Z_TCODES equivalent not needed (Z addon handles directly) | None | Native currency support in Z | MUST | Chile UF contracts cannot be posted | Medium | CD-04 | OQ-COUNTRY-03: Confirm UF indexation handling in Z |

---

## E. FI-GL Integration (Direct)

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| E-01 | Initial recognition posting (ROU + Liability) | BBP §4.1.8 | RE-FX → FI-GL | RECEEP generates two FI docs linked by bridge account: DR ROU / CR Bridge + DR Bridge / CR Liability; document type AN | CD-04 | Direct BAPI: single conceptual entry DR ROU / CR Lease Liability (no bridge account required); document type AN; Z contract ID in XBLNR | High | Eliminate bridge account complexity | MUST | Cannot activate IFRS 16 contract without initial entry | High | CD-03 | OQ-FI-02 |
| E-02 | Bridge account elimination | BBP §4.1.8, §4.2.8, §4.2.9 | RE-FX (technical artifact) | Bridge accounts 5999999090/5999999190 required to link RE-FX and FI documents | CD-04 | Not needed in Option B — Z addon posts directly; payment matching via AP clearing | High | Major simplification | MUST | If bridge accounts kept, entire reconciliation complexity remains | High | CD-04 posting | OQ-FI-03: How will AP payment clearing work without bridge account? |
| E-03 | Monthly interest accrual posting (Intereses) | BBP §4.2.5 | RE-FX → FI-GL | SA document: DR Interest Expense / CR Lease Liability; automatically per contract frequency | CD-04 | Batch Z job: ZRIF16_SCHEDULE row → BAPI post; document type SA; Z Contract ID + Period in reference | High | Fully automated batch | MUST | Interest expense not recognized | Medium | C-04 (schedule) | None |
| E-04 | Lease liability reduction (Cuota arrendamiento) | BBP §4.2.8 | RE-FX → FI-GL | SF document: DR Liability / CR Bridge account; compensation when invoice arrives | CD-04 | Not needed as separate step in Option B — payment posting directly reduces liability via AP clearing | High | Eliminate SF devengo document complexity | MUST | Liability not reduced at payment | High | E-02 bridge elimination | OQ-FI-03 |
| E-05 | PGC parallel posting (Linealización + ajuste) | BBP §4.2.6, §4.2.8 | RE-FX → FI-GL | LL document: DR Rent Expense / CR AP Accrual (PGC monthly); reverses IFRS entries | CD-04 | ZRIF16_GL_MAP PGC mapping; LL document generated in parallel per period | High | Automated LL posting | MUST | PGC expense recognition incorrect | High | C-15 | None |
| E-06 | Rent revision posting (Actualizaciones) | BBP §4.2.3, §4.2.4 | RE-FX → FI-GL | AN document: DR/CR ROU / CR/DR Liability for delta amount; negative deltas: if ROU < 0 → P&L 7710000090 | CD-04 | Post-remeasurement delta entry: DR/CR ROU / CR/DR Liability; gain/loss account when ROU insufficient | Partial | Automated from recalculation event | MUST | Remeasurement not posted | High | C-08, C-09 | None |
| E-07 | Account determination (Determinación cuentas) | BBP §3.2.3.3.1, Annex 8.13 | RE-FX | Account determination: IFRS16/IFRS16-SII per contract type and valuation rule; embedded in RE-FX customizing | CD-04 | ZRIF16_GL_MAP config table: BUKRS + CONTRACT_TYPE + GAAP_TYPE + POSTING_TYPE → GL account | None | Transparent config table vs. RE-FX deep customizing | MUST | Wrong GL accounts | Medium | None | OQ-FI-04: Provide full Annex 8.13 GL account list for Z mapping |
| E-08 | Alternative reconciliation accounts (proveedores) | BBP §4.1.1 | RE-FX + FI config | Standard vendor account 4000000000 vs. IFRS16-specific 5230000090; configured via alternative reconciliation accounts | CD-04 | ZRIF16_GL_MAP.VENDOR_RECON_ACCOUNT; Z posting uses IFRS16 vendor recon account | None | Explicit config vs. FI OB57 configuration | MUST | Vendor postings to wrong account | Medium | CD-04 | OQ-FI-05: Confirm list of alternative recon accounts needed |
| E-09 | Document type mapping | BBP §3.3.5, Annex 8.12 | RE-FX | AN (ROU acquisition), SF (cash flow), SA (interest), KR (vendor invoice), LT (reclassification), AJ (asset retirement), LL (GAAP adjustment) | CD-04 | ZRIF16_GL_MAP.DOC_TYPE per posting type; document types configured in FI customizing | None | Same document type approach | MUST | FI audit trail broken without correct document types | Low | None | OQ-FI-06: Confirm document type availability in client system |
| E-10 | Posting simulation (BAPI_ACC_DOCUMENT_CHECK) | BBP D05 §3.4 | RE-FX + Z | Used in reclassification program before posting | CD-04 | All Z posting programs call BAPI in simulation mode first; results displayed to user before confirmation | High | Simulation mandatory for all posting types | MUST | Finance cannot review before committing | Medium | None | OQ-FI-02: Confirm BAPI name available in ECC version |
| E-11 | CO object in FI postings (CeCo/PEP/Orden) | BBP §3.2.3.3.1 | RE-FX | Cost center from valuation rule object; P&L items require CO object | CD-04 | Z posting includes COST_CENTER/PEP/ORDER from ZRIF16_CONTRACT; derived per posting line | None | Explicit CO derivation | MUST | FI-CO reconciliation breaks | Low | A-16 | None |
| E-12 | Posting reversal (Anulación) | BBP D05 §3.5 | Z-Custom | ZRE009 reversal for reclassification; standard FI reversal for others | CD-04 | Z addon reversal: standard BAPI_ACC_DOCUMENT_REVERSE; logged in ZRIF16_POST_LOG.REVERSAL_OF | High | Universal reversal capability | MUST | Errors cannot be corrected | Medium | None | None |

---

## F. FI-AA Integration (Direct)

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| F-01 | ROU asset automatic creation | BBP §4.1.5 | RE-FX → FI-AA | Upon contract activation + valuation rule save → FI-AA asset created automatically; class per contract type | CD-05 | Z initial recognition event → FI-AA BAPI creates sub-asset; class from ZRIF16_ASSET_CLS config | High | Automated asset creation | MUST | No ROU asset in FI-AA | High | CD-03 (initial values), A-02 (contract type) | OQ-FI-AA-01: Confirm FI-AA BAPI for asset creation |
| F-02 | Asset class mapping by contract type | BBP §3.3.4, Annex 8.10 | RE-FX | 9 ROU asset classes: D21009 (land) to D21909 (other) + D20609 (software) | CD-05 | ZRIF16_ASSET_CLS config table: CONTRACT_TYPE → ASSET_CLASS; same 9 classes | None | Same mapping, transparent config | MUST | Wrong asset class → wrong depreciation | Low | A-02 | OQ-FI-AA-02: Confirm Annex 8.10 asset classes are still valid |
| F-03 | Depreciation key ZLEA | BBP §3.3.2 | FI-AA config | ZLEA key transfers amortization values from RE-FX contract; handles IFRS/PGC/USGAAP differences | CD-05 | In Option B: standard straight-line FI-AA depreciation key applied to Z lease term; ZLEA may not apply (no RE-FX feed) | High | Z drives useful life directly; no relay through RE-FX | MUST | ROU asset not amortized | High | F-01 | OQ-FI-AA-03: Does ZLEA key work without RE-FX feed? Replacement key needed? |
| F-04 | Useful life from lease term | BBP §4.1.5 | RE-FX → FI-AA | "Activo se da de alta con la misma vida útil que tiene el contrato"; modifiable | CD-05 | Z sends IFRS16_TERM_DATE to FI-AA BAPI as useful life end date | High | Automated useful life | MUST | Incorrect depreciation | Low | A-04 | None |
| F-05 | Depreciation areas: IFRS (01), PGC (11/12), USGAAP (13) | BBP §3.3.3 | FI-AA config | Multiple areas per asset: 01 (IFRS real), 11 (local non-posting), 12 (derived difference), 13 (US GAAP) | CD-05 | Z addon activates same area configuration per depreciation plan; no change to FI-AA config | None | FI-AA config is a prerequisite, not a Z development | MUST | Parallel GAAP depreciation incorrect | High | D-01, D-02 | OQ-FI-AA-04: Confirm all client depreciation plans have correct area setup |
| F-06 | Asset movement types for leases | BBP §3.3.5 | FI-AA config | Custom movement types: ZD1/D1Z (acquisition), ZD4/D4Z (post-cap), 250/200 (retirement), ZDR/ZCR (impairment) | CD-05 | Z addon uses same movement types in BAPI calls; no change | None | No change needed | MUST | Wrong FI-AA movements | Low | F-01 | OQ-FI-AA-05: Confirm movement types available in current client system |
| F-07 | Asset retirement on contract termination | BBP §4.4.1, §4.4.2 | RE-FX → FI-AA | AJ document: DR Acc.Depreciation + DR Liability / CR ROU + DR/CR Gain-Loss; movement 250 or 200 | CD-05 | Z termination event (CD-06) → FI-AA retirement BAPI; gain/loss calculated from Z schedule | High | Event-driven retirement | MUST | ROU asset stays on balance after contract ends | Medium | CD-06 termination event | OQ-FI-AA-01 (retirement BAPI) |
| F-08 | Partial asset retirement (scope reduction) | BBP §4.4 (inferred) | RE-FX | Partial cancellation: partial scope reduction | CD-05 | Z scope reduction event → partial FI-AA retirement; pro-rated NBV | None | Explicit scope reduction model | SHOULD | Over-stated ROU asset on partial terminations | High | CD-06 | OQ-OBJ-03: Scope of partial cancellations in current portfolio |
| F-09 | Useful life update on remeasurement | BBP §4.3.1 (renewal) | RE-FX → FI-AA | Upon contract extension: RE-FX updates asset and useful life automatically | CD-05 | Z extension event → FI-AA BAPI to update useful life; new depreciation calculation | High | Automated update | MUST | ROU asset depreciated over wrong period | Medium | CD-06 extension event | OQ-FI-AA-01 (change BAPI) |
| F-10 | Z contract ↔ FI-AA asset mapping | BBP §3.2.3.4 | RE-FX (automatic) | Asset number stored on valuation rule in RE-FX contract | CD-05 | ZRIF16_INTG_REF table: Z_CONTRACT_ID + ANLN1 (asset number) + ANLN2 (sub-number) | High | Explicit traceability table | MUST | Cannot navigate from contract to asset or vice versa | Low | F-01 | None |
| F-11 | Post-capitalization (postcapitalización) | BBP §3.3.5 | RE-FX | Movement types ZD4/D4Z for subsequent capitalization | CD-05 | Z post-cap event → FI-AA postcapitalization BAPI (ZD4 movement) | None | Event-driven post-cap | SHOULD | Incremental additions to ROU not captured | Medium | CD-06 | OQ-OBJ-04: Frequency of post-capitalization scenarios |

---

## G. Monthly / Periodic Operations

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| G-01 | Period-end interest accrual batch | BBP §4.2.5 | RE-FX batch | RECEEP executed monthly; generates SA documents for all active contracts | CD-04 | Z batch job per period: reads ZRIF16_SCHEDULE → posts per contract; error per contract; per-run log | High | Fully automated with per-contract error log | MUST | Interest expense not recognized | Medium | C-04 (schedule) | None |
| G-02 | Period-end liability reduction batch (payment) | BBP §4.2.8 | RE-FX batch | RECEEP generates SF devengo documents | CD-04 | Eliminated in Option B — payment reduces liability via AP clearing directly (see E-04) | High | Simplification | MUST | Liability not reduced | High | E-02 | OQ-FI-03 |
| G-03 | PGC expense linearization batch | BBP §4.2.6 | RE-FX batch | Monthly LL accrual for PGC expense; reversed when payment arrives | CD-04 | Z PGC batch: ZRIF16_SCHEDULE.LINEAR_EXPENSE → LL document per contract | High | Automated with simulation first | MUST | PGC monthly expense incorrect | Medium | C-05 | None |
| G-04 | FI-AA depreciation run (ROU amortization) | BBP §4.2.10 | FI-AA standard | Standard FI-AA period depreciation run (AFAB); includes ROU assets via ZLEA key | CD-05 | Standard AFAB run; ROU assets included via asset class; no Z change needed | High | No change — standard process | MUST | ROU asset not depreciated | Low | F-03, F-04 | None |
| G-05 | Reclassification LP→CP batch (ZRE009) | BBP §4.2.7, D05 full doc | Z-Custom | Custom program ZRE009; reads RECEISRECLASSIFY data; posts LT document (execution + reversal); monthly; multi-GAAP | CD-08 | Z reclassification engine: reads ZRIF16_SCHEDULE directly (next 12 months); posts LT document + reversal; no RE-FX dependency | High | Direct Z schedule read — no RE-FX method dependency | MUST | Balance sheet liability misstated (LP/CP split) | High | C-04 (schedule) | OQ-RECLS-01 (see section H) |
| G-06 | Period-end close status dashboard | BBP (implied from process descriptions) | Manual | No standard period-end close dashboard; users track manually | CD-09 | ZRIF16_PERIOD_STATUS table: per society × period: INTEREST_DONE / AMORT_DONE / RECLS_DONE / ERRORS | High | Automated period-end control | MUST | No visibility of period close completeness | Medium | G-01 to G-05 | None |
| G-07 | Mass rent index update (REAJPR equivalent) | BBP §4.2.3 | RE-FX | REAJPR mass update of index values; all contracts updated | CD-06 + CD-03 | Z mass update: input index values → create PAYMENT_CHANGED events per affected contract → trigger recalculations | High | Automated event creation | MUST | Rent revisions not reflected | High | CD-06 | OQ-ACC-05 |

---

## H. Reclassification LP → CP

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| H-01 | Reclassification calculation (next 12 months) | D05 §3.6, §4 | Z-Custom | Reads RECEISRECLASSIFY (CL_RECE_CASHFLOW_SERVICES.GET_RECLASSIFY_BY_SORT_METHOD); calculates sum of next 12 period payments minus interest | CD-08 | Z reclassification engine reads ZRIF16_SCHEDULE directly: sum(PAYMENT - INTEREST) for next 12 periods | High | No RE-FX dependency; direct Z read | MUST | Balance sheet LP/CP split incorrect | Medium | C-04 | OQ-RECLS-01: Confirm calculation method (payment-interest vs. closing-balance) |
| H-02 | Reclassification posting execution | D05 §3.2, §3.4 | Z-Custom | ZRE009 posts LT document; DR LP account / CR CP account; text: "RECLASIFICACIÓN PASIVO L/P a C/P"; assignment: contract number; CeBe from valuation rule | CD-08 | Z posts LT document via BAPI; account from ZRIF16_RECLS_MAP (COA + contract_type → DEBE/HABER accounts); assignment = Z contract ID | High | Config table vs. hardcoded accounts | MUST | Balance sheet misstated | Medium | H-01, E-07 | OQ-RECLS-02: Confirm LT document type availability |
| H-03 | Reclassification reversal (next period) | D05 §3.3, §3.4 | Z-Custom | Two documents per run: execution (current period date) + reversal (date = first day next period or period 0); special period supported | CD-08 | Z creates both documents in single run; reversal date calculated automatically; special period supported | High | Automated paired execution+reversal | MUST | Reclassification balance carries forward incorrectly | Medium | H-02 | None |
| H-04 | Multi-GAAP reclassification | D05 §3.1, §3.2 | Z-Custom | Multi-GAAP: IFRS16 (LT documents) + PGC reverse (LL documents) + US GAAP (LL documents) | CD-08 | ZRIF16_RECLS_MAP includes PGC and USGAAP rows; parallel postings generated | High | One Z run for all GAAPs | MUST | Local GAAP balance sheet incorrect | High | D-01, D-02 | OQ-ACC-01 |
| H-05 | Account determination for reclassification | D05 §3.1 | Z-Custom | ZTT_RE_RECLCONF: key=COA+Valuation rule; fields: DR account, CR account, doc type, reversal doc type, consolidation movement class | CD-08 | ZRIF16_RECLS_MAP replaces ZTT_RE_RECLCONF; key: COA + contract_type + GAAP_type | None | Option B key is contract type (not valuation rule) | MUST | Wrong accounts posted | Medium | H-02 | OQ-RECLS-03: Confirm ZRIF16_RECLS_MAP replaces ZTT_RE_RECLCONF 1:1 |
| H-06 | Reclassification reversal program (error correction) | D05 §3.5 | Z-Custom | ZRE009 reversal program: input = reclasificación ID + periods; reversal mode | CD-08 | Z reversal function: input = reclassification run ID; reverses all documents in that run | High | Run-level reversal instead of document-level | MUST | Reclassification errors cannot be corrected | Medium | H-02 | None |
| H-07 | Special period reclassification | D05 §3.4 | Z-Custom | Period special 16 supported; reversal posting date = last day of year | CD-08 | Z parameter: SPECIAL_PERIOD; date calculation handles year-end special period | None | Standard handling | SHOULD | Year-end close process fails | Low | H-03 | None |
| H-08 | Reclassification simulation | D05 §3.4 | Z-Custom | Simulation mode (BAPI_ACC_DOCUMENT_CHECK) before real posting | CD-08 | Always simulate first; show user LT documents before executing | High | Mandatory simulation | MUST | Finance cannot review before committing | Low | E-10 | None |

---

## I. Contract Events / Modifications

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| I-01 | Contract renewal (Renovación) | BBP §4.3.1 | RE-FX | Full contract re-execution; new valuation; generates reservas posting | CD-06 | MODIFIED or EXTENDED event in ZRIF16_EVENT; new ZRIF16_CALC_RUN from event date; reserve posting via CD-04 | Partial | Event-driven recalculation | MUST | Renewal not reflected in IFRS 16 balance | High | CD-06, CD-03, CD-04 | OQ-ACC-07 |
| I-02 | Extension / prórroga (not same as renewal) | BBP §4.3.2, DF §6 | RE-FX + Z | For vehicles: new PO creates new RE-FX contract linked to existing; for others: RE-FX date extension | CD-06 | EXTENDED event: new end date, IFRS 16 reassessment, new calc run; prior run preserved | Partial | Non-destructive extension | MUST | Extension not captured → wrong lease term | Medium | CD-06, CD-03 | OQ-ACC-07 |
| I-03 | Rent revaluation / IPC update (Revalorización) | BBP §4.3.3 | RE-FX | Manual index update; REAJPR mass update; triggers new valuation | CD-06 | PAYMENT_CHANGED event; triggers new ZRIF16_CALC_RUN from effective date | Partial | Event-driven | MUST | IFRS 16 liability not updated for rate changes | High | CD-06, CD-03 | OQ-ACC-05 |
| I-04 | Creditor / lessor change (Modificación acreedor) | BBP §4.3.4 | RE-FX | Manual change; no automatic accounting impact | CD-06 | NOVATED event in ZRIF16_EVENT; updates ZRIF16_CONTRACT.VENDOR_ID; history preserved | None | Audit trail vs. RE-FX silent update | MUST | AP postings go to wrong vendor | Low | CD-01 | OQ-ACC-10: Does creditor change trigger IFRS 16 remeasurement in any scenario? |
| I-05 | Cost center / CO object change | BBP DF §6 (modificación 2) | RE-FX + Z | CEBE change on PO → updates RE-FX contract CEBE; manual for others | CD-06 | CC_CHANGED event; no recalculation; updates ZRIF16_CONTRACT.COST_CENTER from effective date | None | Event preserved | MUST | Future postings to wrong CO | Low | CD-06 | None |
| I-06 | Scope reduction (cancelación parcial) | BBP §4.4 (inferred) | RE-FX | Partial scope reduction | CD-06 | SCOPE_REDUCED event; partial FI-AA retirement; prorated recalculation | None | Explicit scope reduction event | SHOULD | Over-stated liability and ROU | High | CD-06, CD-05 | OQ-OBJ-03 |
| I-07 | Event history (immutable audit trail) | BBP (implied) | RE-FX (no explicit event log) | No dedicated event log in RE-FX; contract modified in-place; before/after not tracked | CD-06 | ZRIF16_EVENT table: immutable; before_snapshot / after_snapshot; event_type; effective_date; user; timestamp | High | Complete event history — major improvement vs ECC | MUST | Cannot audit how contract reached current state | Medium | None | None |
| I-08 | Event sequencing validation | BBP (implied) | RE-FX | RE-FX has partial state machine; allows some illogical sequences | CD-06 | Z engine validates: TERMINATED contract cannot be extended; events must be in chronological order | High | Prevented invalid state transitions | MUST | Data integrity | Medium | CD-06 | None |
| I-09 | Novation (vehicle: new PO = new sub-contract) | DF §6 (modificación 3) | Z-Custom | New PO with new price; Z program links to existing RE-FX contract; price change generates novation | CD-06 | NOVATED event + PAYMENT_CHANGED event; new amounts in ZRIF16_PYMT_SCHED from effective date | Partial | Event model vs. new PO approach | SHOULD | Novation not reflected in IFRS 16 | High | CD-07 procurement | OQ-PROC-02: Novation via procurement still needed in Option B? |

---

## J. Early Termination / Purchase Options

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| J-01 | Early termination accounting | BBP §4.4.2 | RE-FX → FI-GL + FI-AA | Manual baja process; AJ document: DR Liability + DR Acc.Dep / CR ROU + DR/CR Gain-Loss 7710000090; PGC/USGAAP reversal | CD-06 + CD-04 + CD-05 | TERMINATED_EARLY event → Z calculates remaining values → FI-AA retirement + FI-GL gain/loss entry | Partial | Semi-automated with preview | MUST | ROU and liability remain on balance after termination | High | CD-06, CD-04, CD-05 | OQ-ACC-11: Gain/loss account confirmation |
| J-02 | Normal expiry (Baja al finalizar contrato) | BBP §4.4.1 | RE-FX → FI-AA | Asset retirement at contract end (standard FI-AA process) | CD-05 + CD-06 | EXPIRED event triggered automatically when CALC_END_DATE reached; FI-AA retirement | High | Automated at expiry | MUST | ROU not derecognized | Medium | CD-06 | None |
| J-03 | Purchase option exercise | BBP §4.4.3 | RE-FX | Process for opción de compra exercise (BBP section 4.4.3) | CD-06 + CD-05 | OPTION_EXERCISED event; ROU asset reclassified to owned asset; lease liability derecognized | None | Explicit event vs. RE-FX manual process | SHOULD | Purchase option contracts not properly transitioned to owned asset | High | CD-06, CD-05 | OQ-ACC-12: Purchase option accounting policy |
| J-04 | Termination gain/loss calculation | BBP §4.4.2 | RE-FX | Difference between remaining liability and ROU NBV → P&L 7710000090 | CD-04 | Z calculates: (remaining_liability - rou_nbv) → gain if positive, loss if negative; posted to gain/loss account | Partial | Automated P&L calculation | MUST | Incorrect P&L on termination | Medium | J-01 | OQ-ACC-11 |
| J-05 | Rescission penalty handling | BBP §3.2.3.1.2 | RE-FX | Rescision penalty conditions can be included | CD-01 + CD-03 | ZRIF16_CONTRACT.TERMINATION_PENALTY field; included in IFRS 16 liability if reasonably certain to pay | None | Explicit penalty field | SHOULD | IFRS 16.26(d) non-compliance for penalty-bearing contracts | Medium | C-01 | OQ-ACC-13: Termination penalty accounting policy |

---

## K. Procurement / Source Integration

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| K-01 | Auto-generation of lease contract from PO (vehicle renting) | DF full doc | Z-Custom | Daily job ZMMRE_PRG_PO_CONTRACT_FRM01; triggers on PO type ZCM + vehicle article group + fixed rent + >12m + >5000€; maps PO fields to RE-FX contract | CD-07 | Z procurement integration: same trigger logic; maps PO → ZRIF16_CONTRACT (not RE-FX RECN); Z contract ID written back to PO | High | Write to Z table instead of RE-FX | MUST | Vehicle renting contracts not created | High | CD-01 | OQ-PROC-01: Confirm trigger criteria still valid |
| K-02 | PO ↔ contract traceability | DF §5 | Z-Custom | Log table: PO + SdP + RE-FX contract + status + material + error message | CD-07 | ZRIF16_INTG_REF: ref_type = MM_PO; ref_doc = PO number; Z_CONTRACT_ID | High | Traceability preserved in integration reference table | MUST | Cannot trace lease contract origin | Medium | K-01 | None |
| K-03 | Status tracking (semáforo) | DF §5 | Z-Custom | Green (OK) / Yellow (open MM receipts) / Red (error) with email notification | CD-07 | ZRIF16_PROC_LOG: status + message + email notification; email via standard SAP | High | Same UX pattern in Z | MUST | Errors not visible to procurement team | Low | K-01 | None |
| K-04 | Manual reprocess (Reproceso) | DF §5 | Z-Custom | Manual re-execution of program for failed records | CD-07 | Z reprocess function: input = PO list; attempt contract creation again; update log | High | Self-service reprocess | MUST | Failed contracts require ABAP intervention | Low | K-01 | None |
| K-05 | Contract extension via new PO (prórroga) | DF §6, SCTASK1418091 §7 | Z-Custom | New PO links to existing RE-FX contract (not creates new); 7-digit license plate matching logic | CD-07 | New PO with extension flag → EXTENDED event on existing Z contract; plate/identifier matching logic | High | Event model vs. new PO creates new RE contract | MUST | Extension via PO creates duplicate contract | High | K-01, I-02 | OQ-PROC-02 |
| K-06 | Framework for non-vehicle procurement-source contracts | DF §2 | Z-Custom | "ESCENARIO 1" only covers vehicles; other scenarios exist but not implemented | CD-07 | Reusable procurement integration framework: source document type + trigger criteria + field mapping; not hardcoded for vehicles only | High | Extensible framework vs. hardcoded vehicle logic | SHOULD | Other asset types cannot be auto-created from procurement | High | K-01 | OQ-PROC-03: Which other procurement scenarios need integration? |
| K-07 | Enrichment by Finance (datos valoración) | DF §3 | Manual | After auto-creation, Finance enriches contract: CeCo, IBR, valuation dates, etc. | CD-07 + CD-01 | Z intake wizard: Finance completes IFRS 16 fields after draft creation; validation before activation | Partial | Guided wizard vs. manual RE-FX screen | MUST | Contracts activated without IFRS 16 data | Medium | CD-01 | None |

---

## L. Document Management

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| L-01 | Contract document URL attachment | BBP §3.2.3.1.1 | RE-FX | URL link to Interacciona repository; added post-creation via Servicios para objeto | CD-01 | ZRIF16_CONTRACT.DOC_URL field; attachable during contract creation wizard | None | Integrated in creation vs. post-creation step | MUST | Audit without document evidence | Low | None | None |
| L-02 | Completeness indicator for document | BBP §3.2.3.1.1 (implied) | Manual | No system indicator; manual tracking | CD-09 | ZRIF16_CONTRACT.DOC_COMPLETE flag; visible in contract list and audit dashboard | None | Explicit completeness flag | SHOULD | Documents not uploaded not flagged | Low | None | None |
| L-03 | SII referencia catastral | BBP §3.2.2.3.2 | Z (ZINDSII_ALQ) | Manual entry in separate Z transaction after contract creation | CD-02 + CD-09 | Field in ZRIF16_LEASE_OBJ; validation during object creation for Spanish societies | None | Integrated vs. separate transaction | SHOULD | SII Spain reporting incomplete | Low | B-07 | OQ-COUNTRY-01 |

---

## M. Reporting / Audit / Reconciliation

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| M-01 | Posting log per contract (RERAPL equivalent) | BBP §5.2.1 | RE-FX | RERAPL: all FI documents per RE contract; filter by RE doc or FI doc | CD-09 | ZRIF16_POST_LOG queryable by Z_CONTRACT_ID; shows all FI document numbers with dates and amounts | High | Direct Z table query | MUST | Cannot audit posting history | Low | CD-04 | None |
| M-02 | Active contracts list (REISCN equivalent) | BBP §5.2.2 | RE-FX | REISCN: filter by type/society/dates | CD-09 | CDS view over ZRIF16_CONTRACT; filters by status, society, type, date | High | ALV-style Z report | MUST | No contract overview | Low | CD-01 | None |
| M-03 | Contract valuation schedule (RECESH equivalent) | BBP §5.2.11 | RE-FX | RECESH: per valuation rule, period: asset/liability opening, interest, payment, closing | CD-09 | CDS view over ZRIF16_SCHEDULE; replaces RECESH; all contracts, not just asset-class level | High | Contract-level schedule | MUST | Cannot verify amortization schedule | Low | CD-03 | Pain point PP-G addressed |
| M-04 | Cash flow forecast (REISCDCF equivalent) | BBP §5.2.9 | RE-FX | REISCDCF: future payments by period per contract | CD-09 | CDS view over ZRIF16_PYMT_SCHED projected; future obligations per contract | High | Forward-looking payment schedule | MUST | Cannot plan cash payments | Low | CD-01 | None |
| M-05 | Lease liability rollforward | BBP (implied by reclassification) | Manual (no standard report) | No dedicated rollforward; users reconstruct from RERAPL | CD-09 | ZRIF16_ROLLFORWARD CDS view: opening / additions / interest / payments / remeasurements / FX / closing per period | High | Dedicated rollforward vs. reconstruction | MUST | IFRS 16 disclosure cannot be prepared | High | CD-03, CD-04 | None |
| M-06 | ROU asset rollforward | BBP (implied) | FI-AA standard (RABEWG_LFA01) | Standard FI-AA asset history sheet; covers additions/amortization/retirements | CD-09 | CDS view combining ZRIF16_POST_LOG + FI-AA asset values; linked by ZRIF16_INTG_REF | Medium | Z+FI-AA combined view | MUST | IFRS 16 disclosure incomplete | Medium | CD-05 | None |
| M-07 | Reconciliation program (bridge account) | BBP §6.1.1 | Z-Custom | Z program reconciles RE-FX cashflow doc vs. FI invoice via bridge account; criteria: assignment (contract/PO), vendor, amount, CeBe | CD-09 | In Option B: bridge account ELIMINATED (E-02); reconciliation needed is RE-FX → FI — replaced by AP clearing | High | Entire bridge account complexity eliminated | LATER (migration only) | During transition only | High | E-02 | OQ-RECON-01: Is bridge account reconciliation needed during transition period? |
| M-08 | FI-AA assets by contract (RECEISASSETCN equivalent) | BBP §5.2.12 | RE-FX | RECEISASSETCN: asset number per contract per valuation rule | CD-09 | CDS view over ZRIF16_INTG_REF + FI-AA asset master | High | Z-native view | MUST | Cannot navigate from contract to ROU asset | Low | CD-05 | None |
| M-09 | Liability maturity analysis | BBP §1.1 (D05, implied) | RE-FX (RECEISRECLASSIFY) | RECEISRECLASSIFY shows maturity-bucketed liability | CD-09 | CDS view over ZRIF16_SCHEDULE: remaining payments bucketed by <1yr, 1-5yr, >5yr | High | Direct Z schedule query | MUST | IFRS 16.58 disclosure requirement | Medium | CD-03 | None |
| M-10 | Conditions per contract (REISCDCN equivalent) | BBP §5.2.6 | RE-FX | REISCDCN: all conditions per contract with amounts and purposes | CD-09 | CDS view over ZRIF16_PYMT_SCHED | High | Simpler Z view | SHOULD | Cannot verify payment schedule | Low | CD-01 | None |
| M-11 | Valuation rules status (RECEISRULECN equivalent) | BBP §5.2.13 | RE-FX | RECEISRULECN: valuation rule + dates + IBR + status per contract | CD-09 | CDS view over ZRIF16_CALC_RUN latest run per contract | High | Current calculation run = valuation rule equivalent | MUST | Cannot verify current IFRS 16 parameters | Low | CD-03 | None |
| M-12 | Exception and error report | BBP §6.1.1 (implied) | Manual | No dedicated exception report | CD-09 | ZRIF16_ERROR_LOG CDS: contracts with errors, type, date, message | High | Proactive error visibility | MUST | Errors not found until period close | Low | All domains | None |
| M-13 | Audit evidence per contract | BBP (implied) | Manual | No single audit pack; assembled manually from multiple transactions | CD-09 | Z audit evidence: one view per contract: creation → events → calculations → postings → FI documents | High | Complete audit trail in one place | MUST | External audit requires manual assembly | High | All domains | None |

---

## N. Error Handling / Reprocessing

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| N-01 | Per-contract error in batch | BBP (implied by RECEEP) | RE-FX | Batch errors not well isolated | CD-04 + CD-08 | All Z batch programs: one error per contract does not stop batch; error logged in ZRIF16_ERROR_LOG | High | Resilient batch processing | MUST | One bad contract blocks entire period close | Low | All CD-04/CD-08 | None |
| N-02 | Procurement error log + reprocess | DF §5 | Z-Custom | Traffic light status; manual reprocess capability | CD-07 | ZRIF16_PROC_LOG with reprocess function | High | Self-service reprocess | MUST | Procurement errors require ABAP fix | Low | K-01 | None |
| N-03 | Reclassification reversal (error correction) | D05 §3.5 | Z-Custom | ZRE009 reversal program | CD-08 | Z reversal: input = run ID; reverses all LT documents in that run | High | Run-level reversal | MUST | Reclassification errors cannot be corrected | Low | H-06 | None |
| N-04 | FI document reversal (any posting type) | BBP (implied) | FI standard | FBRA standard reversal | CD-04 | Z addon supports reversal of all posting types; logged in ZRIF16_POST_LOG.REVERSAL_OF | High | Tracked reversal | MUST | Accounting errors cannot be corrected | Low | None | None |
| N-05 | Mass upload validation errors | BBP §6.1.3 | Z-Custom | Z load program validates per row; errors in report | CD-01 | Z upload: per-row validation; error report before posting; staging table for review | High | Pre-load validation | MUST | Bad data loaded without feedback | Medium | A-21 | None |

---

## O. Configuration / Accounting Determination

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| O-01 | GL account determination (ZRIF16_GL_MAP) | BBP Annex 8.13 | RE-FX customizing | Account determination in RE-FX customizing: determination type IFRS16/IFRS16-SII | CD-04 | ZRIF16_GL_MAP: key = COA + contract_type + GAAP_type + posting_type; fields: debit account, credit account, doc type | None | Transparent config table accessible to Finance | MUST | Wrong accounts posted | Medium | None | OQ-FI-04 |
| O-02 | Reclassification account determination (ZTT_RE_RECLCONF replacement) | D05 §3.1 | Z-Custom | ZTT_RE_RECLCONF: COA + valuation rule → accounts | CD-08 | ZRIF16_RECLS_MAP: COA + contract_type + GAAP → accounts; replaces ZTT_RE_RECLCONF | None | Contract type instead of valuation rule | MUST | Wrong reclassification accounts | Low | None | OQ-RECLS-03 |
| O-03 | Asset class determination (ZRIF16_ASSET_CLS) | BBP §3.3.4, Annex 8.10 | RE-FX | Contract type determines asset class; configured in RE-FX | CD-05 | ZRIF16_ASSET_CLS: contract_type → FI-AA asset class | None | Transparent config | MUST | Wrong asset class | Low | None | OQ-FI-AA-02 |
| O-04 | IFRS 16 IBR configuration by company code | BBP §3.2.3.4 | RE-FX (manual per contract) | IBR entered manually per contract on valuation rule | CD-03 | ZRIF16_IBR_CONFIG: optional default IBR by BUKRS + currency + valid_from; overridable per contract | None | Config table for default rates | SHOULD | Inconsistent IBR application across portfolio | Low | None | OQ-ACC-03 |
| O-05 | Substitutions (Sustituciones): movement class 120/140 | BBP §6.2.2 | FI substitutions | Z substitutions set movement class 120 (increase) on RE-FX devengo positions and 140 (decrease) on invoice positions | CD-04 | In Option B: substitutions eliminated — Z posting program sets movement class directly in BAPI call | High | Eliminate substitution complexity | MUST | If substitutions not replaced, account clearing fails | Low | E-02 | None |
| O-06 | Validations: LL doc + IFRS accounts | BBP §6.2.1 | FI validations | 4 custom validations: LL doc type + IFRS accounts; RE transaction codes for Chile CLF | CD-04 | In Option B: Z posting engine handles all document type + account rules internally; FI validations may be simplified | None | Simplification | SHOULD | If retained without change, may conflict with Z postings | Low | E-07 | OQ-FI-07: Which FI validations remain relevant in Option B? |

---

## P. Country-Specific Behavior

| ID | Functional Capability | Source | ECC Type | Current Behavior | Target Domain | Option B Design Direction | Automation | Improvement | Priority | Risk if Omitted | Complexity | Dependencies | Open Questions |
|----|----------------------|--------|----------|-----------------|---------------|--------------------------|------------|-------------|----------|----------------|------------|-------------|----------------|
| P-01 | Poland: advance payment / prepayment | BBP §3.1.1 (inferred, PLN societies) | RE-FX + Z | Poland-specific advance payment handling (inferred from country list) | CD-03 | ZRIF16_CONTRACT.COUNTRY_VARIANT = PL; Z valuation engine applies Polish prepayment rules | None | Explicit country variant | MUST | Poland contracts incorrectly calculated | Medium | C-06 | OQ-COUNTRY-02 |
| P-02 | Spain: SII referencia catastral | BBP §3.2.2.3 | Z (ZINDSII_ALQ) | Manual; mandatory for Energía; data in /INDSII/REFCADAC | CD-02 + CD-09 | ZRIF16_LEASE_OBJ.CATASTRAL_REF; SII integration reads from Z; mandatory validation for Energía | Partial | Integrated vs. separate transaction | SHOULD | SII reporting failures | Low | B-07 | OQ-COUNTRY-01 |
| P-03 | Spain: IFRS16-SII determination (SII locales negocio) | BBP §3.2.3.3.1 | RE-FX | Determination type IFRS16-SII for Spanish C001 contracts with J025 object | CD-04 | ZRIF16_GL_MAP: society = ES + contract_type = C001 + OBJ_CLASS = LOCAL_NEGOCIO → determination type IFRS16_SII | None | Config-driven | MUST | Wrong VAT/SII handling for Spanish premises | Low | O-01 | OQ-COUNTRY-01 |
| P-04 | Chile: CLF/UF currency | BBP §6.2.1 | FI validation | CLF currency allowed via ZRE_TCODES validation modification | CD-04 | Z posting engine handles CLF natively; no validation modification needed | None | Simplification | MUST | Chile UF contracts cannot post | Low | None | OQ-COUNTRY-03 |
| P-05 | Costa Rica + India: dual fiscal year (0L + LL) | BBP §2.4 | RE-FX + FI | Z0LL presentation rule; postings in both 0L and LL ledgers | CD-04 | ZRIF16_GL_MAP.LEDGER_SCENARIO = DUAL for relevant societies | None | Config-driven | MUST | Fiscal year companies have incomplete posting | High | E-07, D-03 | OQ-FI-01 |
| P-06 | Multi-country Dummy societies (non-SAP systems) | BBP §3.1.2 | RE-FX + FI Dummy | Dummy FI societies for non-SAP entities; CeBe structure by division/country | CD-01 + CD-04 | Z addon supports same Dummy society structure; CeBe derivation same as current | None | No change needed | MUST | Non-SAP entity contracts cannot be managed | Low | None | OQ-DUMMY-01: Confirm active dummy societies in scope |

---

## Q. Custom Z Developments Identified in ECC

| ID | ECC Development | Source | Description | Option B Disposition | Target Domain | Priority | Notes |
|----|----------------|--------|-------------|---------------------|---------------|----------|-------|
| Q-01 | ZRE009 + ZRE012 | D05 full | Reclassification LP→CP program + transaction | REPLACE with Z reclassification engine in CD-08; reads ZRIF16_SCHEDULE not RE-FX | CD-08 | MUST | Core functional redesign |
| Q-02 | ZTT_RE_RECLCONF | D05 §3.1 | Account determination table for reclassification | REPLACE with ZRIF16_RECLS_MAP | CD-08 | MUST | Same business logic, new key structure |
| Q-03 | ZTT_FI_SUST | D05 §3.1 | Substitution config table | RETIRE — substitutions eliminated in Option B | CD-04 | LATER | Bridge account eliminated |
| Q-04 | Informe conciliación Z | BBP §6.1.1 | Bridge account reconciliation program | RETIRE after transition — bridge account eliminated in Option B | CD-09 | LATER (migration only) | Needed during transition only |
| Q-05 | Programa carga maestros Z | BBP §6.1.2 | LSMW for UE/Terreno/UA mass load | REPLACE with Z mass upload for ZRIF16_LEASE_OBJ | CD-02 | MUST | New object, same business purpose |
| Q-06 | Programa carga contratos Z | BBP §6.1.3 | Mass contract load from Excel | REPLACE with Z mass upload for ZRIF16_CONTRACT | CD-01 | MUST | Extended field template |
| Q-07 | Activación proveedores BP | BBP §6.1.4 | Mass vendor → BP conversion with date fix | RETIRE — Option B uses vendor directly; no BP needed for Z | CD-01 | LATER | Eliminates BP dependency |
| Q-08 | Z US GAAP development | BBP §6.1.5 | Custom IPC estimation + linear payment calculation for ASC 842 | BUILD in Option B Z valuation engine natively | CD-03 | MUST | Full implementation in Z |
| Q-09 | Validaciones FI (Steps 053-055) | BBP §6.2.1 | LL doc + IFRS accounts + contract in invoice validation | REVIEW — most eliminated in Option B; retain only if FI process unchanged | CD-04 | SHOULD | OQ-FI-07 |
| Q-10 | Sustituciones FI (mov. class 120/140) | BBP §6.2.2 | Movement class on bridge account positions | RETIRE — bridge account eliminated | CD-04 | LATER | E-02 |
| Q-11 | ZMMRE_PRG_PO_CONTRACT_FRM01 | DF full | Auto-generation RE contract from PO (vehicles) | REPLACE — writes to ZRIF16_CONTRACT instead of RE-FX | CD-07 | MUST | Core procurement integration |
| Q-12 | ZFM_WS_ENVIAR_SOLICITUD | DF §7.3.2.1 | Plate validation function (7-digit license plate match) | KEEP business logic — plate matching reused in Z procurement integration | CD-07 | MUST | Business validation logic preserved |
| Q-13 | ZINDSII_ALQ / /INDSII/REFCADAC | BBP §3.2.2.3 | SII catastral reference entry | REPLACE — field moved to ZRIF16_LEASE_OBJ | CD-02 | SHOULD | Integration to SII confirmed separately |

---

## Summary Statistics

| Priority | Count | % |
|----------|-------|---|
| MUST | 82 | 73% |
| SHOULD | 21 | 19% |
| LATER | 9 | 8% |
| **TOTAL** | **112** | **100%** |

| Coverage Status (initial assessment) | Count |
|--------------------------------------|-------|
| Covered by Option B design direction | 78 |
| Partially covered (design needed) | 24 |
| Gap (no design yet) | 10 |
| **TOTAL** | **112** |

---

## Key Insights

### 1. The Bridge Account Mechanic is Eliminated (Major Simplification)
The entire RE-FX ↔ FI bridge account system (accounts 5999999090, 5999999190, 5999339190) is a RE-FX technical artifact. In Option B, the Z addon posts directly to the final accounts via FI BAPIs — no bridge account required. This eliminates: the reconciliation program (Q-04), the substitutions (Q-10), and the validation for contract number in invoice (Step 055). **Impact: ~15 capabilities simplified or eliminated.**

### 2. US GAAP (ASC 842) Is a First-Class Citizen in Option B
The BBP explicitly identifies that RE-FX standard does NOT support the US GAAP IPC estimation logic (BBP §6.1.5 — marked as GAP). The Z addon can implement this natively in ZCL_RIF16_VALUATION_US_GAAP. This is one of the **biggest Option B improvements over the current ECC solution.**

### 3. Reclassification is Already Z-Custom — Transition is Straightforward
ZRE009 already uses CL_RECE_CASHFLOW_SERVICES to read RE-FX data and BAPI_ACC_DOCUMENT_POST to write FI documents. In Option B, the read source changes from RE-FX to ZRIF16_SCHEDULE. The FI posting logic and account determination (ZTT_RE_RECLCONF → ZRIF16_RECLS_MAP) carries over with minimal change.

### 4. Event History is a Major Gap in Current ECC
The current RE-FX solution has no explicit contract event log. Modifications are applied in-place with no before/after snapshot. The ZRIF16_EVENT model in Option B is a **substantial improvement** that resolves audit risk.

### 5. Poland Advance Payment Logic Needs Explicit Confirmation
Multiple references to Polish advance payment behavior are inferred but not fully documented in the available ECC documents. This must be extracted in T0-02 workshop.

---

## Critical Gaps (Must Resolve Before Design Phase)

| Gap ID | Description | Blocking Domain | Blocking Capability | Resolution Path |
|--------|-------------|----------------|--------------------|----|
| GAP-01 | Poland advance payment specific accounting rules not fully documented | CD-03 | C-06, P-01 | OQ-COUNTRY-02 — T0-01 workshop with Polish accountant |
| GAP-02 | FI BAPI name confirmed for ECC version (BAPI_ACC_DOCUMENT_POST vs. alternative) | CD-04 | E-01 to E-12 | OQ-FI-02 — T0-04 blueprint |
| GAP-03 | FI-AA BAPI for sub-asset creation, useful life update, retirement | CD-05 | F-01, F-07, F-09 | OQ-FI-AA-01 — T0-04 blueprint |
| GAP-04 | Depreciation key ZLEA: does it work without RE-FX feed? | CD-05 | F-03 | OQ-FI-AA-03 — FI-AA specialist |
| GAP-05 | Extension option probability assessment: who assesses and how documented? | CD-01, CD-03 | A-04, C-01 | OQ-ACC-03 — T0-01 accounting policy |
| GAP-06 | Ledger approach for parallel GAAP (extension ledger vs. parallel) | CD-04 | D-03, P-05 | OQ-FI-01 — T0-04 |
| GAP-07 | Full Annex 8.13 GL account list for ZRIF16_GL_MAP design | CD-04 | O-01 | OQ-FI-04 — extract from client system |
| GAP-08 | Scope of impairment (deterioro) in current portfolio | CD-05 | F-07, D-04 | OQ-AA-01 — portfolio analysis |
| GAP-09 | Multi-object contracts: IFRS 16 calculated per object or aggregated? | CD-03 | B-04, C-01 | OQ-OBJ-02 — accounting policy |
| GAP-10 | Short-term and low-value exemption scope in current portfolio | CD-01, CD-03 | C-13, C-14 | OQ-ACC-08 — portfolio analysis |

---

## Automation Opportunities (HIGH Priority)

| ID | Manual Process Today | Option B Automation | Benefit |
|----|---------------------|--------------------|----|
| AUT-01 | RECEEP run manually per contract/batch | Z batch job per period | Eliminate manual execution error |
| AUT-02 | Reclassification: manual check + ZRE009 run | Automated monthly Z job with simulation | One-click month-end |
| AUT-03 | ROU asset creation: manual after contract activation | Automatic on initial recognition approval | Zero manual FI-AA action |
| AUT-04 | IPC mass update: manual REAJPR + RECEEP | Z mass update creates events + triggers recalculations | Rent review automated |
| AUT-05 | Period close tracking: manual checklist | ZRIF16_PERIOD_STATUS dashboard | Real-time close visibility |
| AUT-06 | Procurement contract creation: daily job (Z) | Same — already automated; repoint to Z table | No change in automation level |
| AUT-07 | US GAAP IPC delta: manual (GAP in current ECC) | Z engine calculates natively | Eliminate current manual workaround |
| AUT-08 | FI-AA useful life update on extension: manual | Z extension event triggers FI-AA update | Eliminate manual FI-AA transaction |
| AUT-09 | Contract expiry derecognition: manual | Z system detects CALC_END_DATE reached → EXPIRED event | Proactive lifecycle management |
| AUT-10 | Audit evidence pack: manual assembly from 8+ transactions | Single Z audit view per contract | Hours → seconds for audit prep |

---

## References

- `docs/architecture/functional-coverage-matrix.md` — summary matrix (this file is the detailed version)
- `docs/architecture/open-questions-register.md` — all OQ-* items referenced above
- `.kiro/steering/option-b-target-model.md` — Option B rules (OB-01 to OB-09)
- `docs/architecture/domain-data-model.md` — 10 Z domain separation rules
- `knowledge/currently-design/BBP_IFRS16_Implantación SAP RE_v3.pdf` — primary ECC source
- `knowledge/currently-design/D05_Acciona_DF_Reclasificación de LP a CP_v1.7.pdf` — reclassification source
- `knowledge/currently-design/DF_IFRS16_Generación automática del contrato+SCTASK1418091_modif_lógica_exp_RE_v3.pdf` — procurement source
