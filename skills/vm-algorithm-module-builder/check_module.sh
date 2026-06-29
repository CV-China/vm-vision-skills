#!/usr/bin/env bash
# VM Algorithm Module Self-Check Script
#
# Two modes:
#  1. Pre-check template integrity (before generation):
#       bash check_module.sh --pre <skill_dir>/templates/AlgTemplate/
#     Verifies template SDK libs + headers + whitelist file exist.
#
#  2. Post-check generated module (after deployment, default mode):
#       bash check_module.sh <outputDir>/<ModuleName>/ ["param1 param2 ..."]
#       e.g. bash check_module.sh ./OtsuBinarization "thresholdValue thresholdType"
#
# Pure bash, no Python required. Works on Windows git-bash / MSYS / Linux / macOS.
# Exit 0 = all checks pass; Exit 1 = any check failed (details printed to stderr).
#
# This script is invoked by the vm-algorithm-module-builder skill.
# Each finding is prefixed with FAIL: (must fix) or WARN: (review).

set -u

# ============================================================================
# Pre-check mode: verify skill template integrity (before any generation)
# ============================================================================
if [ "${1:-}" = "--pre" ]; then
  TEMPLATE="${2:-}"
  if [ -z "$TEMPLATE" ] || [ ! -d "$TEMPLATE" ]; then
    echo "Usage: bash check_module.sh --pre <skill_dir>/templates/AlgTemplate/" >&2
    exit 2
  fi
  TEMPLATE="${TEMPLATE%/}"
  PRE_FAIL=0
  pre_fail() { echo "FAIL: $*" >&2; PRE_FAIL=$((PRE_FAIL+1)); }
  pre_pass() { echo "PASS: $*"; }

  # Solution file (inside AlgTemplate_CProj/AlgTemplate/)
  test -f "$TEMPLATE/AlgTemplate_CProj/AlgTemplate/AlgTemplate.sln" \
      && pre_pass "AlgTemplate.sln present" \
      || pre_fail "AlgTemplate.sln missing at AlgTemplate_CProj/AlgTemplate/"
  test -f "$TEMPLATE/AlgTemplate_CsProj/AlgTemplateCs/AlgTemplateCs.sln" \
      && pre_pass "AlgTemplateCs.sln present" \
      || pre_fail "AlgTemplateCs.sln missing"
  test -d "$TEMPLATE/AlgTemplate_CProj"   && pre_pass "AlgTemplate_CProj/ present"        || pre_fail "AlgTemplate_CProj/ missing"
  test -d "$TEMPLATE/AlgTemplate_CsProj"  && pre_pass "AlgTemplate_CsProj/ present"       || pre_fail "AlgTemplate_CsProj/ missing"

  # SDK_V430 libs (default SDK/ — VM4.3)
  LIB_DIR_V430="$TEMPLATE/AlgTemplate_CProj/AlgTemplate/common/SDK/Libraries/x64"
  for lib in Common/MVDImageCpp.lib Common/MVDShapeCpp.lib \
             Algorithms/MVDPositionFixCpp.lib Algorithms/MVDPreproMaskCpp.lib; do
    test -f "$LIB_DIR_V430/$lib" && pre_pass "SDK_V430 lib: $lib" || pre_fail "SDK_V430 lib missing: $LIB_DIR_V430/$lib"
  done

  # SDK_V440 libs (VM4.4)
  LIB_DIR_V440="$TEMPLATE/AlgTemplate_CProj/AlgTemplate/common/SDK_V440/Libraries/x64"
  if [ -d "$LIB_DIR_V440" ]; then
    for lib in Common/MVDImageCpp.lib Common/MVDShapeCpp.lib Common/MVDRegionCpp.lib \
               Common/MVDRenderControl.lib \
               Algorithms/MVDPositionFixCpp.lib Algorithms/MVDPreproMaskCpp.lib; do
      test -f "$LIB_DIR_V440/$lib" && pre_pass "SDK_V440 lib: $lib" || pre_fail "SDK_V440 lib missing: $LIB_DIR_V440/$lib"
    done
  else
    pre_fail "SDK_V440/ directory missing at $LIB_DIR_V440"
  fi

  # Core headers
  HDR_DIR="$TEMPLATE/AlgTemplate_CProj/AlgTemplate/common"
  for hdr in src/ErrorCodeDefine.h src/HSlog/HSlogDefine.h src/VmModule_IO.h \
             src/VmAlgModuBase.h VM400/include/VmModuleFrame/VmModuleBase.h; do
    test -f "$HDR_DIR/$hdr" && pre_pass "header: $hdr" || pre_fail "SDK header missing: $HDR_DIR/$hdr"
  done

  # Whitelist file (sibling of this script under references/)
  SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
  test -f "$SKILL_DIR/references/valid-sdk-symbols.txt" && pre_pass "valid-sdk-symbols.txt present" \
                                                        || pre_fail "valid-sdk-symbols.txt missing (run: bash references/regen-sdk-whitelist.sh)"

  echo ""
  echo "========================================"
  echo "Pre-check summary: $PRE_FAIL fail"
  echo "========================================"
  [ "$PRE_FAIL" = "0" ] && exit 0 || exit 1
fi

# ============================================================================
# Post-check mode (default): verify generated module
# ============================================================================
OUT="${1:-}"
USER_PARAMS="${2:-}"

if [ -z "$OUT" ] || [ ! -d "$OUT" ]; then
  echo "Usage: bash check_module.sh <outputDir>/<ModuleName>/ [\"param1 param2 ...\"]" >&2
  exit 2
fi

OUT="${OUT%/}"
FAIL_COUNT=0
WARN_COUNT=0

fail() { echo "FAIL: $*" >&2; FAIL_COUNT=$((FAIL_COUNT+1)); }
warn() { echo "WARN: $*" >&2; WARN_COUNT=$((WARN_COUNT+1)); }
pass() { echo "PASS: $*"; }

# Locate key files (tolerant to absent dirs)
shopt -s nullglob
CPP_FILES=("$OUT"/*_CProj/*/*/AlgorithmModule.cpp)
H_FILES=("$OUT"/*_CProj/*/*/AlgorithmModule.h)
VCXPROJ_FILES=("$OUT"/*_CProj/*/*/*.vcxproj)
UI_DIR=("$OUT"/[!_]*)        # interface-layer dir (5 XMLs)

MODULE_XML=()
ALG_TAB_XML=()
ALG_DEFAULT_XML=()
DISPLAY_XML=()
TOOL_INFO_XML=()

for d in "${UI_DIR[@]}"; do
  [ -d "$d" ] || continue
  for f in "$d"/*.xml; do
    case "$(basename "$f")" in
      *AlgorithmTab.xml) ALG_TAB_XML+=("$f") ;;
      *Algorithm.xml)    ALG_DEFAULT_XML+=("$f") ;;
      *Display.xml)      DISPLAY_XML+=("$f") ;;
      ToolItemInfo.xml)  TOOL_INFO_XML+=("$f") ;;
      *)                 MODULE_XML+=("$f") ;;
    esac
  done
done

CSPROJ_FILES=("$OUT"/*_CsProj/*Cs/*Cs/*.csproj "$OUT"/*_CsProj/*Cs/*Control/*.csproj)
shopt -u nullglob

# ----------------------------------------------------------------------------
# 1. AlgTemplate string residue
# ----------------------------------------------------------------------------
if grep -rIlq "AlgTemplate" "$OUT/" 2>/dev/null; then
  fail "AlgTemplate string residue (run: grep -rIn AlgTemplate '$OUT/')"
else
  pass "no AlgTemplate residue"
fi

# ----------------------------------------------------------------------------
# 2. EXAMPLEMODULE_EXPORTS residue (string does NOT contain "AlgTemplate")
# ----------------------------------------------------------------------------
if grep -rInq "EXAMPLEMODULE_EXPORTS" "$OUT/" 2>/dev/null; then
  fail "EXAMPLEMODULE_EXPORTS residue (rename to <MODULE_NAME>_EXPORTS in vcxproj + .h)"
else
  pass "no EXAMPLEMODULE_EXPORTS residue"
fi

# ----------------------------------------------------------------------------
# 3. Fabricated SDK APIs (compile-fail blacklist - known-bad names)
# ----------------------------------------------------------------------------
FAB_API='VM_M_GetImageInfo|VM_M_CreateImage|VM_M_GetImageData|VM_M_SetOutputImage|VM_M_DestroyImage|VM_M_CopyImage|VM_M_SetIntValue|VM_M_SetFloatValue|VM_M_SetStringValue|VM_M_GetIntValue|VM_M_GetFloatValue|VM_M_GetLine|VM_M_SetLine|VM_M_GetRect|VM_M_SetRect|VM_M_GetPoint|VM_M_SetPoint|VM_M_GetCircle|VM_M_SetCircle|VM_M_SetParam|VmModule_GetInputRoiBox|VmModule_OutputVector_BoxF|VmModule_OutputVector_PointF|IMVS_EC_NOMEM|AlgCommon_TimeMilliseconds'
for f in "${CPP_FILES[@]}" "${H_FILES[@]}"; do
  if grep -nE "$FAB_API" "$f" >/dev/null 2>&1; then
    fail "fabricated SDK API in $f:"
    grep -nE "$FAB_API" "$f" >&2
  fi
done

# ----------------------------------------------------------------------------
# 3.5 SDK symbol whitelist reverse-validation (catches any fabricated symbol)
# ----------------------------------------------------------------------------
# Any VM_M_*/VmModule_*/IMVS_EC_*/MLOG_*/HKA_* token in user cpp/h that is NOT
# in references/valid-sdk-symbols.txt is treated as fabricated and FAILs.
# Whitelist is regenerated from template headers by references/regen-sdk-whitelist.sh.
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
WHITELIST="$SKILL_DIR/references/valid-sdk-symbols.txt"
if [ -f "$WHITELIST" ]; then
  WL_TMP="$(mktemp 2>/dev/null || echo /tmp/vm_whitelist.$$)"
  grep -v '^#' "$WHITELIST" | grep -v '^$' | sort -u > "$WL_TMP"

  for f in "${CPP_FILES[@]}" "${H_FILES[@]}"; do
    USED_TMP="$(mktemp 2>/dev/null || echo /tmp/vm_used.$$)"
    grep -oE '\b(VM_M_[A-Za-z0-9_]+|VmModule_[A-Za-z0-9_]+|IMVS_EC_[A-Z0-9_]+|MLOG_[A-Z]+|LOG_[A-Z]+|HKA_[A-Z][A-Z0-9_]*|HKA_IMG_[A-Z0-9_]+|MVD_PIXEL_[A-Z0-9_]+|MVD_IMAGE_[A-Z0-9_]+|MVDSDK_API|MVDSDK_TRY|MVDSDK_CATCH|MVDSDK_BASE_MODU_INPUT|AllocateSharedMemory|MyMilliseconds|GenerateMaskImage|MODULE_RUNTIME_INFO)\b' "$f" 2>/dev/null | sort -u > "$USED_TMP"
    UNKNOWN=$(comm -23 "$USED_TMP" "$WL_TMP" 2>/dev/null)
    if [ -n "$UNKNOWN" ]; then
      fail "$f references SDK symbols NOT in whitelist (likely fabricated):"
      echo "$UNKNOWN" | sed 's/^/      /' >&2
      echo "      (verify against templates/AlgTemplate/common/**/*.h; if symbol IS real, run: bash references/regen-sdk-whitelist.sh)" >&2
    fi
    rm -f "$USED_TMP"
  done
  rm -f "$WL_TMP"
else
  warn "whitelist file missing: $WHITELIST (run: bash references/regen-sdk-whitelist.sh)"
fi

# ----------------------------------------------------------------------------
# 4. Required timing API present
# ----------------------------------------------------------------------------
for f in "${CPP_FILES[@]}"; do
  grep -q "MyMilliseconds"            "$f" || fail "$f missing MyMilliseconds() timing entry"
  grep -q "VM_M_SetModuleRuntimeInfo" "$f" || fail "$f missing VM_M_SetModuleRuntimeInfo()"
done

# ----------------------------------------------------------------------------
# 5. PostBuildEvent in csproj (otherwise Cs/Control dll not copied)
# ----------------------------------------------------------------------------
for csproj in "${CSPROJ_FILES[@]}"; do
  case "$csproj" in
    *Control/*)
      grep -q "CopyBuildCs2File.bat" "$csproj" || fail "$csproj missing PostBuildEvent CopyBuildCs2File.bat" ;;
    *)
      grep -q "CopyBuildCs1File.bat" "$csproj" || fail "$csproj missing PostBuildEvent CopyBuildCs1File.bat" ;;
  esac
done

# ----------------------------------------------------------------------------
# 5.5. CopyBuild*.bat existence + CRLF line endings (cmd.exe cannot parse LF bats)
# ----------------------------------------------------------------------------
BAT_FILES=($(find "$OUT" -name "CopyBuild*.bat" 2>/dev/null))
for bat in "${BAT_FILES[@]}"; do
  if ! head -c 200 "$bat" | xxd | grep -q "0d 0a"; then
    fail "$bat uses LF line endings (must be CRLF for cmd.exe; fix: sed -i 's/\$/\\r/' \"$bat\")"
  fi
done
# At least CopyBuildCs1File.bat and CopyBuildCFile.bat must exist
echo "${BAT_FILES[@]}" | grep -q "CopyBuildCs1File.bat" || fail "CopyBuildCs1File.bat not found in $OUT"
echo "${BAT_FILES[@]}" | grep -q "CopyBuildCFile.bat"  || fail "CopyBuildCFile.bat not found in $OUT"
# CopyBuildCs2File.bat is optional (only when Control sub-UI exists)

# ----------------------------------------------------------------------------
# 6. Process overload: 1 (image module) or 2 (no-image module with delegate)
# ----------------------------------------------------------------------------
for f in "${CPP_FILES[@]}"; do
  N=$(grep -cE "^int[[:space:]]+CAlgorithmModule::Process[[:space:]]*\(" "$f")
  { [ "$N" -ge 1 ] && [ "$N" -le 2 ]; } || fail "$f has $N Process() definitions (must be 1 or 2)"
done
for f in "${H_FILES[@]}"; do
  N=$(grep -cE "^[[:space:]]*int[[:space:]]+Process[[:space:]]*\(" "$f")
  { [ "$N" -ge 1 ] && [ "$N" -le 2 ]; } || fail "$f has $N Process() declarations (must be 1 or 2)"
done

# ----------------------------------------------------------------------------
# 7. Forbidden base-class virtual overrides
# ----------------------------------------------------------------------------
FORBID='ResetDefaultParam|GetAllParamList|SetAllParamList|GetProcessInput|GenerateMaskImage|ClearRoiData|ResetDefaultRoi|DynamicIOInit'
for f in "${CPP_FILES[@]}"; do
  if grep -nE "::($FORBID)[[:space:]]*\(" "$f" >/dev/null 2>&1; then
    fail "$f overrides forbidden base virtual:"
    grep -nE "::($FORBID)[[:space:]]*\(" "$f" >&2
  fi
done
for f in "${H_FILES[@]}"; do
  if grep -nE "^[[:space:]]*(virtual[[:space:]]+)?int[[:space:]]+($FORBID)[[:space:]]*\(" "$f" >/dev/null 2>&1; then
    fail "$f declares forbidden base virtual:"
    grep -nE "^[[:space:]]*(virtual[[:space:]]+)?int[[:space:]]+($FORBID)[[:space:]]*\(" "$f" >&2
  fi
done

# ----------------------------------------------------------------------------
# 8. Log API blacklist
# ----------------------------------------------------------------------------
LOG_BLACK='MessageBox|AfxMessageBox|std::cout|std::cerr|std::clog|std::cin|ConsoleWrite|LOG_ERROR|LOG_WARN|LOG_INFO|LOG_DEBUG|LOG_TRACE'
RAW_PRINTF='\bprintf[[:space:]]*('
for f in "${CPP_FILES[@]}" "${H_FILES[@]}"; do
  if grep -nE "$LOG_BLACK" "$f" >/dev/null 2>&1; then
    fail "$f uses blacklisted log API:"
    grep -nE "$LOG_BLACK" "$f" >&2
  fi
  # 裸 printf 检查：禁止在 MLOG_* 格式串外直接使用 printf（§I）
  if grep -nE '[^A-Za-z_]printf[[:space:]]*\(' "$f" >/dev/null 2>&1; then
    fail "$f uses bare printf() (use MLOG_* instead):"
    grep -nE '[^A-Za-z_]printf[[:space:]]*\(' "$f" >&2
  fi
  # OutputDebugStringA: allowed ONLY in CreateModule/DestroyModule (DLL entry, no m_nModuleId)
  if grep -n "OutputDebugString" "$f" >/dev/null 2>&1; then
    # Use awk for multi-line context detection (function-body scope)
    # Report any OutputDebugString line that is NOT inside CreateModule or DestroyModule function
    awk '
      /CreateModule[[:space:]]*\(|DestroyModule[[:space:]]*\(/ { inEntry=1 }
      /^}/ { inEntry=0 }
      /OutputDebugString/ && !inEntry { print FILENAME ":" NR ": " $0 }
    ' "$f" | while read -r line; do
      [ -n "$line" ] && fail "OutputDebugString outside CreateModule/DestroyModule: $line"
    done
  fi
done

# ----------------------------------------------------------------------------
# 9. ROI as Process output (forbidden)
# ----------------------------------------------------------------------------
for f in "${CPP_FILES[@]}"; do
  if grep -nE 'VM_M_Set[A-Za-z]+\([^)]*"(OutROI|ROI|FixROI|InROI)"' "$f" >/dev/null 2>&1; then
    fail "$f outputs ROI via VM_M_Set* (base class auto-displays ROI):"
    grep -nE 'VM_M_Set[A-Za-z]+\([^)]*"(OutROI|ROI|FixROI|InROI)"' "$f" >&2
  fi
  if grep -nE 'VmModule_OutputVector_BoxF\([^)]*"(OutROI|ROI|FixROI)"' "$f" >/dev/null 2>&1; then
    fail "$f outputs ROI via VmModule_OutputVector_BoxF"
  fi
done

# ----------------------------------------------------------------------------
# 10. ROI as Filter port in <module>.xml (forbidden)
# ----------------------------------------------------------------------------
for x in "${MODULE_XML[@]}"; do
  if grep -nE '<Filter[[:space:]]+Name="(InROI|OutROI|ROI|FixROI)"' "$x" >/dev/null 2>&1; then
    fail "$x has illegal ROI Filter port"
  fi
done

# ----------------------------------------------------------------------------
# 11. Fabricated XML tags (forbidden-xml-tags.md)
# ----------------------------------------------------------------------------
for x in "${ALG_TAB_XML[@]}"; do
  if grep -nE '<EnumEntryList>|<EnumEntries>|<Symbolic>|<Step>' "$x" >/dev/null 2>&1; then
    fail "$x uses fabricated XML tag (see references/forbidden-xml-tags.md)"
  fi
  if grep -nE '<EnumEntry[[:space:]]+[^>]*Value[[:space:]]*=[[:space:]]*"' "$x" >/dev/null 2>&1; then
    fail "$x: EnumEntry Value must be child node <Value>X</Value>, not attribute"
  fi
done

# ----------------------------------------------------------------------------
# 11.5. ToolItemInfo.xml format (must be <ToolBoxItemData>, NOT <ToolItemInfo>)
# ----------------------------------------------------------------------------
for x in "${TOOL_INFO_XML[@]}"; do
  if grep -qE '<ToolItemInfo>|<ChineseName>|<EnglishName>|<ChineseGroup>|<EnglishGroup>|<ToolType>' "$x" 2>/dev/null; then
    fail "$x uses fabricated <ToolItemInfo> format (template uses <ToolBoxItemData> with <name>/<priority>/<toolTip>)"
  fi
  if ! grep -q '<ToolBoxItemData>' "$x" 2>/dev/null; then
    fail "$x missing root element <ToolBoxItemData>"
  fi
done

# ----------------------------------------------------------------------------
# 12. Single-t typo (IntegerBetween → IntegerBettween)
# ----------------------------------------------------------------------------
for x in "${ALG_TAB_XML[@]}"; do
  if grep -nE '<(IntegerBetween|FloatBetween|Range_Int|Range_Float)\b' "$x" >/dev/null 2>&1; then
    fail "$x uses single-t spelling (must be IntegerBettween/FloatBettween, double-t)"
  fi
done

# ----------------------------------------------------------------------------
# 13. SDK libs present (minimum functional count — V430≥4, V440≥6)
# ----------------------------------------------------------------------------
LIB_BASE=$(ls -d "$OUT"/*_CProj/*/common/SDK/Libraries/x64 2>/dev/null | head -1)
if [ -n "$LIB_BASE" ] && [ -d "$LIB_BASE" ]; then
  LIB_COUNT=$(find "$LIB_BASE" -name "*.lib" 2>/dev/null | wc -l)
  if [ "$LIB_COUNT" -ge 4 ]; then
    pass "SDK libs present ($LIB_COUNT .lib files)"
  elif [ "$LIB_COUNT" -gt 0 ]; then
    warn "SDK libs potentially incomplete: only $LIB_COUNT .lib files (expected >=4)"
  else
    fail "SDK libs directory empty: $LIB_BASE"
  fi
else
  warn "SDK libs directory not found (expected $OUT/*_CProj/*/common/SDK/Libraries/x64)"
fi

# ----------------------------------------------------------------------------
# 14. Run-param name consistency across 3 files (Tab.xml / Algorithm.xml / cpp)
# ----------------------------------------------------------------------------
# Extract param names from AlgorithmTab.xml within Tab_Run Params section.
# Use awk range match for portability.
TAB_PARAMS=""
for x in "${ALG_TAB_XML[@]}"; do
  P=$(awk '/<Tab Name="Tab_Run Params">/,/<\/Tab>/' "$x" 2>/dev/null \
      | grep -oE '<(Integer|Float|Boolean|Enumeration|String|OpenFile|OpenFolderDialogEx|OpenFileForCNNDialog|OpenFileForCalibDialog|SaveFileDialog|IntegerBettween|FloatBettween)[[:space:]]+Name="[^"]+"' \
      | grep -oE 'Name="[^"]+"' \
      | sed 's/Name="//;s/"//')
  TAB_PARAMS="$TAB_PARAMS $P"
done
TAB_PARAMS=$(echo "$TAB_PARAMS" | tr ' ' '\n' | sort -u | grep -v '^$')

for p in $TAB_PARAMS; do
  FOUND_IN_ALG=0
  for x in "${ALG_DEFAULT_XML[@]}"; do
    grep -q "<Name>$p</Name>" "$x" && FOUND_IN_ALG=1 && break
  done
  [ "$FOUND_IN_ALG" = "1" ] || fail "Algorithm.xml missing ParamItem: $p"

  FOUND_IN_CPP=0
  for f in "${CPP_FILES[@]}"; do
    grep -q "strcmp(\"$p\"" "$f" && FOUND_IN_CPP=1 && break
  done
  [ "$FOUND_IN_CPP" = "1" ] || fail "cpp missing strcmp branch: $p"
done

# ----------------------------------------------------------------------------
# 15. User-listed param matching (no extras)
# ----------------------------------------------------------------------------
if [ -n "$USER_PARAMS" ]; then
  for p in $TAB_PARAMS; do
    echo " $USER_PARAMS " | grep -q " $p " || \
      fail "extra run-param not in user list: $p (user-listed: $USER_PARAMS)"
  done
fi

# ----------------------------------------------------------------------------
# 16. Run-param controls in wrong Tab (Tab_Basic Params should not host runtime knobs)
# ----------------------------------------------------------------------------
RUN_TAGS='Integer|Float|Boolean|Enumeration|String|OpenFile|OpenFolderDialogEx|OpenFileForCNNDialog|OpenFileForCalibDialog|SaveFileDialog|IntegerBettween|FloatBettween'
for x in "${ALG_TAB_XML[@]}"; do
  MISPLACED=$(awk '/<Tab Name="Tab_Basic Params">/,/<\/Tab>/' "$x" 2>/dev/null \
              | grep -nE "<($RUN_TAGS)[[:space:]]+Name=\"")
  if [ -n "$MISPLACED" ]; then
    fail "$x has run-param controls in Tab_Basic Params (move to Tab_Run Params):"
    echo "$MISPLACED" >&2
  fi
done

# ----------------------------------------------------------------------------
# 17. CurValue + DefaultValue completeness for run-param controls
# ----------------------------------------------------------------------------
for x in "${ALG_TAB_XML[@]}"; do
  awk '
    /<Tab Name="Tab_Run Params">/ { inTab=1 }
    /<\/Tab>/ { inTab=0 }
    inTab && /<(Integer|Float|Enumeration|Boolean)[[:space:]]+Name=/ {
      inNode=1; hasCur=0; hasDef=0; lineNo=NR; name=$0
    }
    inNode && /<CurValue>/     { hasCur=1 }
    inNode && /<DefaultValue>/ { hasDef=1 }
    inNode && /<\/(Integer|Float|Enumeration|Boolean)>/ {
      if (!hasCur || !hasDef) print "L" lineNo ": missing CurValue or DefaultValue: " name
      inNode=0
    }
  ' "$x" | while read -r line; do
    [ -n "$line" ] && fail "$x $line"
  done
done

# ----------------------------------------------------------------------------
# 18. DisplayName != Name for run-param controls (catch missing Chinese names)
# ----------------------------------------------------------------------------
for x in "${ALG_TAB_XML[@]}"; do
  # Collect all run param DisplayName/Name pairs from Tab_Run Params
  awk '/<Tab Name="Tab_Run Params">/ { inTab=1 }
       /<\/Tab>/ { inTab=0 }
       inTab && /<(Integer|Float|Boolean|Enumeration|String|IntegerBettween|FloatBettween|OpenFile)[[:space:]]+Name=/ {
         tag=$0
         # Extract Name attribute
         gsub(/.*Name="/, "", tag)
         gsub(/".*/, "", tag)
         paramName=tag
         inParam=1
         next
       }
       inTab && inParam && /<DisplayName>/ {
         gsub(/.*<DisplayName>/, "")
         gsub(/<\/DisplayName>.*/, "")
         displayName=$0
         if (paramName == displayName) {
           print "'"$x"' " paramName ": DisplayName equals Name (\"" displayName "\") — likely missing Chinese translation"
         }
         inParam=0
       }' "$x" | while read -r line; do
    [ -n "$line" ] && fail "$line"
  done
done

# ----------------------------------------------------------------------------
# 19. Display.xml root node (must be <ParamRoot>, not <Display ...>)
# ----------------------------------------------------------------------------
for x in "${DISPLAY_XML[@]}"; do
  if ! grep -q '<ParamRoot>' "$x" 2>/dev/null; then
    fail "$x missing <ParamRoot> root element (template uses <ParamRoot><Categorys><Category Name=\"Display\">, not <Display ...>)"
  fi
done

# ----------------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------------
echo ""
echo "========================================"
echo "Self-check summary: $FAIL_COUNT fail, $WARN_COUNT warn"
echo "========================================"
[ "$FAIL_COUNT" = "0" ] && exit 0 || exit 1
