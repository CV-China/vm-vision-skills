#!/usr/bin/env bash
# Regenerate references/valid-sdk-symbols.txt from template SDK headers.
#
# When to run:
#  - After updating templates/AlgTemplate/ to a newer VM SDK version
#  - When a legitimate SDK symbol is rejected by check_module.sh
#
# Usage:  bash references/regen-sdk-whitelist.sh
#
# Idempotent. Overwrites references/valid-sdk-symbols.txt.

set -eu

HERE="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_COMMON="$HERE/templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common"
OUT="$HERE/references/valid-sdk-symbols.txt"

if [ ! -d "$TEMPLATE_COMMON" ]; then
  echo "ERROR: template common/ not found at $TEMPLATE_COMMON" >&2
  exit 1
fi

{
  cat <<'HDR'
# valid-sdk-symbols.txt
# Auto-generated SDK symbol whitelist for vm-algorithm-module-builder.
# Source: templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common/**/*.h
#
# Regenerate: bash references/regen-sdk-whitelist.sh
# Used by:    check_module.sh (reverse-validation against fabricated SDK calls)
#
# Format: one symbol per line; lines starting with "#" are section markers.
HDR
  echo ""
  find "$TEMPLATE_COMMON" -name "*.h" -exec cat {} + 2>/dev/null \
    | grep -oE "(VM_M_[A-Za-z0-9_]+|VmModule_[A-Za-z0-9_]+|MVDSDK_API|MVDSDK_TRY|MVDSDK_CATCH|HKA_IMAGE|HKA_POINT_F|HKA_BOX_F|HKA_LINE_F|HKA_S32|HKA_U8|HKA_U32|HKA_RGB[A-Z0-9_]*|HKA_IMG_[A-Z0-9_]+|HKA_PIXEL[A-Z0-9_]*|HKA_NULL|HKA_PROC_[A-Z0-9_]+|AllocateSharedMemory|MyMilliseconds|GenerateMaskImage|MODULE_RUNTIME_INFO|MVDSDK_BASE_MODU_INPUT|MVD_PIXEL_[A-Z0-9_]+|MVD_IMAGE_[A-Z0-9_]+)" \
    | sort -u
  echo "#---error-codes---"
  find "$TEMPLATE_COMMON" -name "*.h" -exec cat {} + 2>/dev/null \
    | grep -oE "IMVS_EC_[A-Z0-9_]+" | sort -u
  echo "#---log-macros---"
  find "$TEMPLATE_COMMON" -name "*.h" -exec cat {} + 2>/dev/null \
    | grep -oE "(MLOG_[A-Z]+|LOG_[A-Z]+)" | sort -u
} > "$OUT"

LINES=$(wc -l < "$OUT")
echo "Regenerated $OUT ($LINES lines)"
