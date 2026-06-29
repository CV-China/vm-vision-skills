# VM Algorithm Module Self-Check (PowerShell)
# Mirror of check_module.sh. Use this on Windows when bash/git-bash is unavailable.
#
# Two modes:
#  1. Pre-check template integrity:
#       pwsh -File check_module.ps1 -Pre <skill_dir>\templates\AlgTemplate\
#
#  2. Post-check generated module (default):
#       pwsh -File check_module.ps1 <outputDir>\<ModuleName>\ [-UserParams "p1 p2 ..."]
#
# Exit 0 = pass, 1 = any FAIL.

param(
    [Parameter(Position=0)] [string]$Path,
    [string]$UserParams = "",
    [switch]$Pre,
    [string]$PreTemplate = ""
)

$FailCount = 0
$WarnCount = 0
function Fail([string]$msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; $script:FailCount++ }
function Warn([string]$msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow; $script:WarnCount++ }
function Pass([string]$msg) { Write-Host "PASS: $msg" -ForegroundColor Green }

# ============================================================================
# Pre-check mode
# ============================================================================
if ($Pre -or $Path -eq "--pre") {
    if (-not $PreTemplate -and $Path -eq "--pre" -and $args.Count -ge 1) { $PreTemplate = $args[0] }
    if (-not $PreTemplate) { $PreTemplate = $Path }
    if (-not (Test-Path $PreTemplate -PathType Container)) {
        Write-Host "Usage: pwsh -File check_module.ps1 -Pre <skill_dir>\templates\AlgTemplate\" -ForegroundColor Yellow
        exit 2
    }
    $T = (Resolve-Path $PreTemplate).Path.TrimEnd('\','/')

    if (Test-Path "$T\AlgTemplate_CProj\AlgTemplate\AlgTemplate.sln") { Pass "AlgTemplate.sln present" }
    else { Fail "AlgTemplate.sln missing at AlgTemplate_CProj\AlgTemplate\" }
    if (Test-Path "$T\AlgTemplate_CsProj\AlgTemplateCs\AlgTemplateCs.sln") { Pass "AlgTemplateCs.sln present" }
    else { Fail "AlgTemplateCs.sln missing" }
    foreach ($d in @("AlgTemplate_CProj","AlgTemplate_CsProj")) {
        if (Test-Path "$T\$d" -PathType Container) { Pass "$d/ present" } else { Fail "$d/ missing" }
    }

    # SDK_V430 libs (default SDK/ — VM4.3)
    $LibDirV430 = "$T\AlgTemplate_CProj\AlgTemplate\common\SDK\Libraries\x64"
    foreach ($lib in @("Common\MVDImageCpp.lib","Common\MVDShapeCpp.lib",
                        "Algorithms\MVDPositionFixCpp.lib","Algorithms\MVDPreproMaskCpp.lib")) {
        if (Test-Path "$LibDirV430\$lib") { Pass "SDK_V430 lib: $lib" } else { Fail "SDK_V430 lib missing: $LibDirV430\$lib" }
    }

    # SDK_V440 libs (VM4.4)
    $LibDirV440 = "$T\AlgTemplate_CProj\AlgTemplate\common\SDK_V440\Libraries\x64"
    if (Test-Path $LibDirV440 -PathType Container) {
        foreach ($lib in @("Common\MVDImageCpp.lib","Common\MVDShapeCpp.lib","Common\MVDRegionCpp.lib",
                            "Common\MVDRenderControl.lib",
                            "Algorithms\MVDPositionFixCpp.lib","Algorithms\MVDPreproMaskCpp.lib")) {
            if (Test-Path "$LibDirV440\$lib") { Pass "SDK_V440 lib: $lib" } else { Fail "SDK_V440 lib missing: $LibDirV440\$lib" }
        }
    } else { Fail "SDK_V440/ directory missing at $LibDirV440" }

    $HdrDir = "$T\AlgTemplate_CProj\AlgTemplate\common"
    foreach ($hdr in @("src\ErrorCodeDefine.h","src\HSlog\HSlogDefine.h","src\VmModule_IO.h",
                       "src\VmAlgModuBase.h","VM400\include\VmModuleFrame\VmModuleBase.h")) {
        if (Test-Path "$HdrDir\$hdr") { Pass "header: $hdr" } else { Fail "SDK header missing: $HdrDir\$hdr" }
    }

    $SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (Test-Path "$SkillDir\references\valid-sdk-symbols.txt") { Pass "valid-sdk-symbols.txt present" }
    else { Fail "valid-sdk-symbols.txt missing (run: bash references/regen-sdk-whitelist.sh)" }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Pre-check summary: $FailCount fail" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    if ($FailCount -eq 0) { exit 0 } else { exit 1 }
}

# ============================================================================
# Post-check mode
# ============================================================================
if (-not $Path -or -not (Test-Path $Path -PathType Container)) {
    Write-Host "Usage: pwsh -File check_module.ps1 <outputDir>\<ModuleName>\ [-UserParams `"p1 p2 ...`"]" -ForegroundColor Yellow
    exit 2
}
$OUT = (Resolve-Path $Path).Path.TrimEnd('\','/')

# Locate key files
$CppFiles  = @(Get-ChildItem -Path "$OUT" -Recurse -Filter "AlgorithmModule.cpp" -ErrorAction SilentlyContinue | ForEach-Object FullName)
$HFiles    = @(Get-ChildItem -Path "$OUT" -Recurse -Filter "AlgorithmModule.h"   -ErrorAction SilentlyContinue | ForEach-Object FullName)
$CsProjs   = @(Get-ChildItem -Path "$OUT" -Recurse -Filter "*.csproj"           -ErrorAction SilentlyContinue | ForEach-Object FullName)

$UiXmls    = @(Get-ChildItem -Path "$OUT" -Directory -ErrorAction SilentlyContinue |
               Where-Object { $_.Name -notlike "*_*" } |
               ForEach-Object { Get-ChildItem -Path $_.FullName -Filter "*.xml" -ErrorAction SilentlyContinue })

$ModuleXml = @($UiXmls | Where-Object { $_.Name -notlike "*AlgorithmTab.xml" -and $_.Name -notlike "*Algorithm.xml" -and $_.Name -notlike "*Display.xml" -and $_.Name -ne "ToolItemInfo.xml" } | ForEach-Object FullName)
$AlgTabXml = @($UiXmls | Where-Object { $_.Name -like "*AlgorithmTab.xml" } | ForEach-Object FullName)
$ToolItemXml = @($UiXmls | Where-Object { $_.Name -eq "ToolItemInfo.xml" } | ForEach-Object FullName)
$AlgDefXml = @($UiXmls | Where-Object { $_.Name -like "*Algorithm.xml" -and $_.Name -notlike "*AlgorithmTab.xml" } | ForEach-Object FullName)

# Helper
function GrepCount([string]$file, [string]$pattern) {
    if (-not (Test-Path $file)) { return 0 }
    return @(Select-String -Path $file -Pattern $pattern -AllMatches -ErrorAction SilentlyContinue).Count
}
function GrepFound([string]$file, [string]$pattern) { return (GrepCount $file $pattern) -gt 0 }

# 1. AlgTemplate residue
$res = Select-String -Path "$OUT\*" -Pattern "AlgTemplate" -CaseSensitive -Recurse -ErrorAction SilentlyContinue -List
if ($res) { Fail "AlgTemplate string residue (Select-String -Path '$OUT' -Pattern AlgTemplate -Recurse)" } else { Pass "no AlgTemplate residue" }

# 2. EXAMPLEMODULE_EXPORTS residue
$res = Select-String -Path "$OUT\*" -Pattern "EXAMPLEMODULE_EXPORTS" -Recurse -ErrorAction SilentlyContinue -List
if ($res) { Fail "EXAMPLEMODULE_EXPORTS residue (rename to <MODULE>_EXPORTS in vcxproj + .h)" } else { Pass "no EXAMPLEMODULE_EXPORTS residue" }

# 3. Fabricated SDK API blacklist
$FabApi = 'VM_M_GetImageInfo|VM_M_CreateImage|VM_M_GetImageData|VM_M_SetOutputImage|VM_M_DestroyImage|VM_M_CopyImage|VM_M_SetIntValue|VM_M_SetFloatValue|VM_M_SetStringValue|VM_M_GetIntValue|VM_M_GetFloatValue|VM_M_GetLine|VM_M_SetLine|VM_M_GetRect|VM_M_SetRect|VM_M_GetPoint|VM_M_SetPoint|VM_M_GetCircle|VM_M_SetCircle|VM_M_SetParam|VmModule_GetInputRoiBox|VmModule_OutputVector_BoxF|VmModule_OutputVector_PointF|IMVS_EC_NOMEM|AlgCommon_TimeMilliseconds'
foreach ($f in ($CppFiles + $HFiles)) {
    $hits = Select-String -Path $f -Pattern $FabApi -ErrorAction SilentlyContinue
    if ($hits) { Fail "fabricated SDK API in $f"; $hits | ForEach-Object { Write-Host "      $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor DarkGray } }
}

# 3.5 Whitelist reverse-validation
$SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Whitelist = "$SkillDir\references\valid-sdk-symbols.txt"
if (Test-Path $Whitelist) {
    $WL = @{}
    Get-Content $Whitelist | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object { $WL[$_.Trim()] = $true }
    $TokenRegex = '\b(VM_M_[A-Za-z0-9_]+|VmModule_[A-Za-z0-9_]+|IMVS_EC_[A-Z0-9_]+|MLOG_[A-Z]+|LOG_[A-Z]+|HKA_[A-Z][A-Z0-9_]*|HKA_IMG_[A-Z0-9_]+|MVD_PIXEL_[A-Z0-9_]+|MVD_IMAGE_[A-Z0-9_]+|MVDSDK_API|MVDSDK_TRY|MVDSDK_CATCH|MVDSDK_BASE_MODU_INPUT|AllocateSharedMemory|MyMilliseconds|GenerateMaskImage|MODULE_RUNTIME_INFO)\b'
    foreach ($f in ($CppFiles + $HFiles)) {
        $used = @()
        Get-Content $f -ErrorAction SilentlyContinue | ForEach-Object {
            [regex]::Matches($_, $TokenRegex) | ForEach-Object { $used += $_.Value }
        }
        $unknown = $used | Sort-Object -Unique | Where-Object { -not $WL.ContainsKey($_) }
        if ($unknown) {
            Fail "$f references SDK symbols NOT in whitelist (likely fabricated):"
            $unknown | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
            Write-Host "      (verify against templates/AlgTemplate/common/**/*.h; if real, run: bash references/regen-sdk-whitelist.sh)" -ForegroundColor DarkGray
        }
    }
} else {
    Warn "whitelist file missing: $Whitelist"
}

# 4. Required timing API
foreach ($f in $CppFiles) {
    if (-not (GrepFound $f "MyMilliseconds"))            { Fail "$f missing MyMilliseconds() timing entry" }
    if (-not (GrepFound $f "VM_M_SetModuleRuntimeInfo")) { Fail "$f missing VM_M_SetModuleRuntimeInfo()" }
}

# 5. PostBuildEvent
foreach ($csproj in $CsProjs) {
    if ($csproj -match "Control") {
        if (-not (GrepFound $csproj "CopyBuildCs2File.bat")) { Fail "$csproj missing PostBuildEvent CopyBuildCs2File.bat" }
    } else {
        if (-not (GrepFound $csproj "CopyBuildCs1File.bat")) { Fail "$csproj missing PostBuildEvent CopyBuildCs1File.bat" }
    }
}

# 5.5. CopyBuild*.bat existence + CRLF line endings (cmd.exe cannot parse LF bats)
$batFiles = @(Get-ChildItem -Path $OUT -Recurse -Name "CopyBuild*.bat" -ErrorAction SilentlyContinue)
foreach ($bat in $batFiles) {
    $fullPath = Join-Path $OUT $bat
    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    $hasCRLF = $false
    for ($i = 0; $i -lt $bytes.Count - 1; $i++) {
        if ($bytes[$i] -eq 0x0D -and $bytes[$i+1] -eq 0x0A) { $hasCRLF = $true; break }
    }
    if (-not $hasCRLF) { Fail "$fullPath uses LF line endings (must be CRLF for cmd.exe)" }
}
if (-not ($batFiles -match "CopyBuildCs1File.bat")) { Fail "CopyBuildCs1File.bat not found in $OUT" }
if (-not ($batFiles -match "CopyBuildCFile.bat"))  { Fail "CopyBuildCFile.bat not found in $OUT" }

# 6. Process overload: 1 (image module, 3-param only) or 2 (no-image with delegate)
foreach ($f in $CppFiles) {
    $n = GrepCount $f '^int\s+CAlgorithmModule::Process\s*\('
    if ($n -lt 1 -or $n -gt 2) { Fail "$f has $n Process() definitions (must be 1 or 2)" }
}
foreach ($f in $HFiles) {
    $n = GrepCount $f '^\s*int\s+Process\s*\('
    if ($n -lt 1 -or $n -gt 2) { Fail "$f has $n Process() declarations (must be 1 or 2)" }
}

# 7. Forbidden base virtuals
$Forbid = 'ResetDefaultParam|GetAllParamList|SetAllParamList|GetProcessInput|GenerateMaskImage|ClearRoiData|ResetDefaultRoi|DynamicIOInit'
foreach ($f in $CppFiles) {
    $hits = Select-String -Path $f -Pattern "::($Forbid)\s*\(" -ErrorAction SilentlyContinue
    if ($hits) { Fail "$f overrides forbidden base virtual"; $hits | ForEach-Object { Write-Host "      $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor DarkGray } }
}
foreach ($f in $HFiles) {
    $hits = Select-String -Path $f -Pattern "^\s*(virtual\s+)?int\s+($Forbid)\s*\(" -ErrorAction SilentlyContinue
    if ($hits) { Fail "$f declares forbidden base virtual"; $hits | ForEach-Object { Write-Host "      $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor DarkGray } }
}

# 8. Log blacklist
$LogBlack = 'MessageBox|AfxMessageBox|std::cout|std::cerr|std::clog|std::cin|ConsoleWrite|LOG_ERROR|LOG_WARN|LOG_INFO|LOG_DEBUG|LOG_TRACE'
foreach ($f in ($CppFiles + $HFiles)) {
    $hits = Select-String -Path $f -Pattern $LogBlack -ErrorAction SilentlyContinue
    if ($hits) { Fail "$f uses blacklisted log API"; $hits | ForEach-Object { Write-Host "      $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor DarkGray } }
    # 裸 printf 检查：禁止在 MLOG_* 格式串外直接使用 printf（§I）
    $printfHits = Select-String -Path $f -Pattern '[^A-Za-z_]printf\s*\(' -ErrorAction SilentlyContinue
    if ($printfHits) {
        Fail "$f uses bare printf() (use MLOG_* instead)"
        $printfHits | ForEach-Object { Write-Host "      $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor DarkGray }
    }
    # OutputDebugStringA: allowed ONLY in CreateModule/DestroyModule (DLL entry, no m_nModuleId)
    $odsHits = Select-String -Path $f -Pattern "OutputDebugString" -ErrorAction SilentlyContinue
    if ($odsHits) {
        # Use multi-line context: track whether we're inside CreateModule/DestroyModule
        $lines = Get-Content $f -ErrorAction SilentlyContinue
        $inEntry = $false
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            if ($line -match 'CreateModule\s*\(|DestroyModule\s*\(') { $inEntry = $true }
            if ($line -match '^}') { $inEntry = $false }
            if ($line -match 'OutputDebugString' -and -not $inEntry) {
                Fail "$f OutputDebugString outside CreateModule/DestroyModule (line $($i+1)): $($line.Trim())"
            }
        }
    }
}

# 9. ROI as Process output
foreach ($f in $CppFiles) {
    if (Select-String -Path $f -Pattern 'VM_M_Set[A-Za-z]+\([^)]*"(OutROI|ROI|FixROI|InROI)"' -ErrorAction SilentlyContinue) {
        Fail "$f outputs ROI via VM_M_Set* (base class auto-displays ROI)"
    }
    if (Select-String -Path $f -Pattern 'VmModule_OutputVector_BoxF\([^)]*"(OutROI|ROI|FixROI)"' -ErrorAction SilentlyContinue) {
        Fail "$f outputs ROI via VmModule_OutputVector_BoxF"
    }
}

# 10. ROI as Filter port
foreach ($x in $ModuleXml) {
    if (Select-String -Path $x -Pattern '<Filter\s+Name="(InROI|OutROI|ROI|FixROI)"' -ErrorAction SilentlyContinue) {
        Fail "$x has illegal ROI Filter port"
    }
}

# 11. Fabricated XML tags
foreach ($x in $AlgTabXml) {
    if (Select-String -Path $x -Pattern '<EnumEntryList>|<EnumEntries>|<Symbolic>|<Step>' -ErrorAction SilentlyContinue) {
        Fail "$x uses fabricated XML tag (see references/forbidden-xml-tags.md)"
    }
    if (Select-String -Path $x -Pattern '<EnumEntry\s+[^>]*Value\s*=\s*"' -ErrorAction SilentlyContinue) {
        Fail "$x EnumEntry Value must be child node <Value>X</Value>, not attribute"
    }
}

# 11.5 ToolItemInfo.xml format
foreach ($x in $ToolItemXml) {
    if (-not (Select-String -Path $x -Pattern '<ToolBoxItemData>' -ErrorAction SilentlyContinue)) {
        Fail "$x missing <ToolBoxItemData> root node (not <ToolItemInfo>!)"
    }
    if (Select-String -Path $x -Pattern '<ToolItemInfo>|<ChineseName>|<EnglishName>|<ChineseGroup>|<EnglishGroup>|<ToolType>' -ErrorAction SilentlyContinue) {
        Fail "$x uses fabricated ToolItemInfo format - correct format is <ToolBoxItemData>"
    }
}

# 12. Single-t typo
foreach ($x in $AlgTabXml) {
    if (Select-String -Path $x -Pattern '<(IntegerBetween|FloatBetween|Range_Int|Range_Float)\b' -ErrorAction SilentlyContinue) {
        Fail "$x uses single-t spelling (must be IntegerBettween/FloatBettween, double-t)"
    }
}

# 13. SDK libs present (minimum functional count — V430≥4, V440≥6)
$LibBase = @(Get-ChildItem -Path "$OUT" -Recurse -Directory -Filter "x64" -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -match "common.SDK.Libraries.x64$" } | Select-Object -First 1).FullName
if ($LibBase) {
    $LibCount = @(Get-ChildItem -Path "$LibBase" -Filter "*.lib" -ErrorAction SilentlyContinue).Count
    if ($LibCount -ge 4) {
        Pass "SDK libs present ($LibCount .lib files)"
    } elseif ($LibCount -gt 0) {
        Warn "SDK libs potentially incomplete: only $LibCount .lib files (expected >=4)"
    } else {
        Fail "SDK libs directory empty: $LibBase"
    }
} else { Warn "SDK libs directory not found under $OUT" }

# 14. Run-param name consistency
$TabParams = @()
foreach ($x in $AlgTabXml) {
    $content = Get-Content $x -Raw -ErrorAction SilentlyContinue
    if ($content -match '(?s)<Tab Name="Tab_Run Params">(.*?)</Tab>') {
        $section = $Matches[1]
        $TabParams += [regex]::Matches($section, '<(?:Integer|Float|Boolean|Enumeration|String|OpenFile|OpenFolderDialogEx|OpenFileForCNNDialog|OpenFileForCalibDialog|SaveFileDialog|IntegerBettween|FloatBettween)\s+Name="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
    }
}
$TabParams = $TabParams | Sort-Object -Unique

foreach ($p in $TabParams) {
    $foundAlg = $false
    foreach ($x in $AlgDefXml) { if (GrepFound $x "<Name>$p</Name>") { $foundAlg = $true; break } }
    if (-not $foundAlg) { Fail "Algorithm.xml missing ParamItem: $p" }

    $foundCpp = $false
    foreach ($f in $CppFiles) { if (GrepFound $f "strcmp\(`"$p`"") { $foundCpp = $true; break } }
    if (-not $foundCpp) { Fail "cpp missing strcmp branch: $p" }
}

# 15. User-listed param matching
if ($UserParams) {
    $userList = $UserParams -split '\s+' | Where-Object { $_ }
    foreach ($p in $TabParams) {
        if ($userList -notcontains $p) { Fail "extra run-param not in user list: $p (user-listed: $UserParams)" }
    }
}

# 16. Run-param controls in wrong Tab
foreach ($x in $AlgTabXml) {
    $content = Get-Content $x -Raw -ErrorAction SilentlyContinue
    if ($content -match '(?s)<Tab Name="Tab_Basic Params">(.*?)</Tab>') {
        $section = $Matches[1]
        if ($section -match '<(Integer|Float|Boolean|Enumeration|String|OpenFile|OpenFolderDialogEx|OpenFileForCNNDialog|OpenFileForCalibDialog|SaveFileDialog|IntegerBettween|FloatBettween)\s+Name="') {
            Fail "$x has run-param controls in Tab_Basic Params (move to Tab_Run Params)"
        }
    }
}

# 17. CurValue + DefaultValue completeness (simplified - per-node check)
foreach ($x in $AlgTabXml) {
    $content = Get-Content $x -Raw -ErrorAction SilentlyContinue
    if ($content -match '(?s)<Tab Name="Tab_Run Params">(.*?)</Tab>') {
        $section = $Matches[1]
        $nodeMatches = [regex]::Matches($section, '(?s)<(Integer|Float|Enumeration|Boolean)\s+Name="([^"]+)"[^>]*>(.*?)</\1>')
        foreach ($m in $nodeMatches) {
            $name = $m.Groups[2].Value
            $body = $m.Groups[3].Value
            if ($body -notmatch '<CurValue>'     -or $body -notmatch '<DefaultValue>') {
                Fail "$x missing CurValue or DefaultValue: $name"
            }
        }
    }
}

# 18. DisplayName != Name for run-param controls (catch missing Chinese names)
foreach ($x in $AlgTabXml) {
    $content = Get-Content $x -Raw -ErrorAction SilentlyContinue
    if ($content -match '(?s)<Tab Name="Tab_Run Params">(.*?)</Tab>') {
        $section = $Matches[1]
        # Match each run-param node and extract Name + DisplayName
        $nodeMatches = [regex]::Matches($section, '(?s)<(Integer|Float|Boolean|Enumeration|String|IntegerBettween|FloatBettween|OpenFile)\s+Name="([^"]+)"[^>]*>(.*?)</\1>')
        foreach ($m in $nodeMatches) {
            $paramName = $m.Groups[2].Value
            $body = $m.Groups[3].Value
            if ($body -match '<DisplayName>([^<]+)</DisplayName>') {
                $displayName = $Matches[1]
                if ($paramName -eq $displayName) {
                    Fail "$x $($paramName): DisplayName equals Name (`"$displayName`") — likely missing Chinese translation"
                }
            }
        }
    }
}

# 19. Display.xml root node (must be <ParamRoot>)
$DisplayXmls = @($UiXmls | Where-Object { $_.Name -like "*Display.xml" } | ForEach-Object FullName)
foreach ($x in $DisplayXmls) {
    if (-not (Select-String -Path $x -Pattern '<ParamRoot>' -Quiet -ErrorAction SilentlyContinue)) {
        Fail "$x missing <ParamRoot> root element (template uses <ParamRoot><Categorys><Category Name=""Display"">, not <Display ...>)"
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Self-check summary: $FailCount fail, $WarnCount warn" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
if ($FailCount -eq 0) { exit 0 } else { exit 1 }
