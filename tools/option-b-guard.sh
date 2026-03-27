#!/usr/bin/env bash
# =============================================================================
# option-b-guard.sh — Option B Architecture Guard
# Migrado desde: .kiro/hooks/option-b-architecture-guard.kiro.hook
# Ejecutado por: ~/.claude/settings.json PostToolUse hook
#
# Solo escanea archivos relevantes para arquitectura.
# Los checks de razonamiento profundo los hace el Orchestrator en CLAUDE.md.
# =============================================================================

FILE="${1:-}"

# Solo actuar sobre archivos relevantes
if [[ -z "$FILE" ]]; then exit 0; fi
if [[ ! -f "$FILE" ]]; then exit 0; fi

# Limitar a tipos de archivo arquitecturalmente relevantes
case "$FILE" in
  *specs/*.md|*docs/architecture/*.md|*docs/technical/*.md|*docs/functional/*.md) ;;
  *) exit 0 ;;
esac

VIOLATIONS=0
WARNINGS=()

# -----------------------------------------------------------------------
# OB-01 / OB-02: RE-FX como fuente de datos en runtime
# -----------------------------------------------------------------------
REFX_PATTERNS=(
  "RECN[A-Z_]*.*runtime"
  "VICNCOND.*runtime"
  "VIOBJHEAD.*source"
  "RE-FX contract.*system of record"
  "FK to RE-FX"
  "reads from RE-FX"
  "RE-FX.*data source"
)

for pattern in "${REFX_PATTERNS[@]}"; do
  if grep -qiE "$pattern" "$FILE" 2>/dev/null; then
    WARNINGS+=("OB-01/OB-02 POSSIBLE VIOLATION: Pattern '${pattern}' found — verify RE-FX is not used as runtime data source")
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

# -----------------------------------------------------------------------
# OB-03: Motor contable RE-FX
# -----------------------------------------------------------------------
ACCOUNTING_PATTERNS=(
  "RE-FX accounting engine"
  "RE-FX.*posting"
  "RE-FX valuation engine.*FI"
  "RECEEP.*accounting"
)

for pattern in "${ACCOUNTING_PATTERNS[@]}"; do
  if grep -qiE "$pattern" "$FILE" 2>/dev/null; then
    WARNINGS+=("OB-03 POSSIBLE VIOLATION: Pattern '${pattern}' — FI documents must be posted via direct FI BAPI, not RE-FX engine")
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

# -----------------------------------------------------------------------
# OB-06: Cambio destructivo de contrato (UPDATE sin evento)
# -----------------------------------------------------------------------
DESTRUCTIVE_PATTERNS=(
  "UPDATE.*ZRIF16_CONTRACT.*SET"
  "MODIFY.*ZRIF16_CONTRACT"
  "overwrite.*contract.*history"
  "DELETE.*contract.*row"
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if grep -qiE "$pattern" "$FILE" 2>/dev/null; then
    WARNINGS+=("OB-06 POSSIBLE VIOLATION: Pattern '${pattern}' — contract changes must use event model, not destructive UPDATE")
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

# -----------------------------------------------------------------------
# OB-04: Spec sin referencia a Capability Domain
# -----------------------------------------------------------------------
if [[ "$FILE" == *specs/*/requirements.md ]] || [[ "$FILE" == *specs/*/design.md ]]; then
  if ! grep -qE "CD-0[1-9]" "$FILE" 2>/dev/null; then
    WARNINGS+=("OB-04 WARNING: No Capability Domain reference (CD-01 to CD-09) found in spec file — add domain tag")
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
fi

# -----------------------------------------------------------------------
# Output
# -----------------------------------------------------------------------
if [[ $VIOLATIONS -eq 0 ]]; then
  echo "[option-b-guard] PASSED: ${FILE##*/} — no violations detected."
else
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  OPTION B ARCHITECTURE GUARD — POSSIBLE VIOLATIONS FOUND    ║"
  echo "╠══════════════════════════════════════════════════════════════╣"
  echo "║  File: ${FILE##*/}"
  echo "╠══════════════════════════════════════════════════════════════╣"
  for warning in "${WARNINGS[@]}"; do
    echo "║  ⚠  ${warning}"
  done
  echo "╠══════════════════════════════════════════════════════════════╣"
  echo "║  Review against ADR-006 and .kiro/steering/option-b-target-model.md"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
fi

exit 0
