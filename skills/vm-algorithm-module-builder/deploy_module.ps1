<#
.SYNOPSIS
    Deploy a compiled VM algorithm module to both runtime and development paths.
.DESCRIPTION
    Tries direct xcopy first (VM normally grants Users write to Module(sp)).
    Falls back to elevation only if Access Denied.  Also verifies timestamps post-copy.
.PARAMETER SourceDir
    Path to the module build output directory (contains XMLs + DLLs + PNGs).
.PARAMETER VmRoot
    VisionMaster installation root (e.g. "C:\Program Files\VisionMaster4.3.0").
.PARAMETER Toolbox
    Toolbox name (default: "UserTools").
.PARAMETER ModuleName
    Module name (e.g. "ImageModifyTool").
.EXAMPLE
    powershell -NoProfile -File deploy_module.ps1 -SourceDir "f:\Test\ImageModifyTool\ImageModifyTool" -VmRoot "C:\Program Files\VisionMaster4.3.0" -Toolbox "UserTools" -ModuleName "ImageModifyTool"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDir,
    [Parameter(Mandatory=$true)]
    [string]$VmRoot,
    [string]$Toolbox = "UserTools",
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

$ErrorActionPreference = "Continue"

# ---- helpers ----------------------------------------------------------------
function Deploy-To($DestPath, $Label) {
    Write-Output ""
    Write-Output "--- Deploy to $Label ---"
    Write-Output "  $DestPath"

    # 1) Ensure destination exists (try without admin first)
    if (-not (Test-Path $DestPath)) {
        try {
            New-Item -ItemType Directory -Path $DestPath -Force -ErrorAction Stop | Out-Null
            Write-Output "  Created (non-elevated): $DestPath"
        } catch {
            Write-Warning "  Cannot create directory (permission denied).  Will retry with elevation."
            return Deploy-To-Elevated $DestPath $Label
        }
    }

    # 2) Copy
    $xcopyOutput = & xcopy "$SourceDir" "$DestPath\" /y /i /s 2>&1
    $xcopyExit = $LASTEXITCODE
    foreach ($line in $xcopyOutput) { Write-Output "  $line" }

    # 3) If access denied → retry with elevation
    if ($xcopyExit -ne 0) {
        $accessDenied = ($xcopyOutput -match 'Access is denied|Access denied|0 File\(s\) copied' -join '')
        if ($accessDenied) {
            Write-Warning "  Access denied on non-elevated attempt — retrying with elevation..."
            return Deploy-To-Elevated $DestPath $Label
        }
        Write-Error "  xcopy failed (exit: $xcopyExit)"
        return $false
    }

    # 4) Verify
    Verify-Files $DestPath $Label
}

function Deploy-To-Elevated($DestPath, $Label) {
    # Write a tiny helper script that does the xcopy + returns results via temp file.
    $tmpResult = [IO.Path]::GetTempFileName()
    $helperScript = [IO.Path]::GetTempFileName() + ".ps1"
    @"
`$ErrorActionPreference = 'Continue'
New-Item -ItemType Directory -Path '$DestPath' -Force -ErrorAction SilentlyContinue | Out-Null
`$out = & xcopy '$SourceDir' '$DestPath\' /y /i /s 2>&1
`$exit = `$LASTEXITCODE
`$out | Out-File -FilePath '$tmpResult' -Encoding UTF8
exit `$exit
"@ | Out-File -FilePath $helperScript -Encoding UTF8

    $proc = Start-Process -FilePath "powershell.exe" -ArgumentList @(
        "-NoProfile", "-ExecutionPolicy", "Bypass",
        "-File", $helperScript
    ) -Verb RunAs -Wait -PassThru -WindowStyle Hidden

    Remove-Item $helperScript -Force -ErrorAction SilentlyContinue

    if (Test-Path $tmpResult) {
        Get-Content $tmpResult | ForEach-Object { Write-Output "  $_" }
        Remove-Item $tmpResult -Force -ErrorAction SilentlyContinue
    }

    if ($proc.ExitCode -ne 0) {
        Write-Error "  xcopy (elevated) failed (exit: $($proc.ExitCode))"
        return $false
    }

    Verify-Files $DestPath $Label
}

function Verify-Files($DestPath, $Label) {
    $allOk = $true
    foreach ($f in $script:RequiredFiles) {
        $dstFile = Join-Path $DestPath $f
        if (-not (Test-Path $dstFile)) {
            Write-Error "  MISSING: $f in $Label"
            $allOk = $false
            continue
        }
        $dstTime = (Get-Item $dstFile).LastWriteTimeUtc
        $srcTime = $script:SourceTimestamps[$f]
        if ($dstTime -lt $srcTime) {
            Write-Error "  STALE (overwrite failed): $f — dst=$($dstTime.ToString('HH:mm:ss')) < src=$($srcTime.ToString('HH:mm:ss'))"
            $allOk = $false
        } else {
            Write-Output "  OK: $f ($($dstTime.ToString('HH:mm:ss')))"
        }
    }
    if ($allOk) {
        Write-Output "  [$Label] All $($script:RequiredFiles.Count) files verified — PASS"
    }
    return $allOk
}

# ---- main -------------------------------------------------------------------
$SourceDir = (Resolve-Path $SourceDir).Path   # resolve to absolute

Write-Output "========================================="
Write-Output "VM Module Deploy"
Write-Output "  Source : $SourceDir"
$RuntimeDest = Join-Path $VmRoot "Applications\Module(sp)\x64\$Toolbox\$ModuleName"
$DevDest     = Join-Path $VmRoot "Development\V4.x\ComControls\Assembly\Module(sp)\x64\$Toolbox\$ModuleName"
Write-Output "  Runtime: $RuntimeDest"
Write-Output "  Dev    : $DevDest"
Write-Output "========================================="

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
    exit 1
}

# Required files
$script:RequiredFiles = @(
    "$ModuleName.xml",
    "$($ModuleName)AlgorithmTab.xml",
    "$($ModuleName)Algorithm.xml",
    "$($ModuleName)Display.xml",
    "ToolItemInfo.xml",
    "$($ModuleName)Cs.dll",
    "$($ModuleName).dll"
)

$missingSrc = @()
foreach ($f in $script:RequiredFiles) {
    $fp = Join-Path $SourceDir $f
    if (-not (Test-Path $fp)) { $missingSrc += $f }
}
if ($missingSrc.Count -gt 0) {
    Write-Warning "Missing source files: $($missingSrc -join ', ')"
}

# Record source timestamps
$script:SourceTimestamps = @{}
Get-ChildItem $SourceDir -File | ForEach-Object {
    $script:SourceTimestamps[$_.Name] = $_.LastWriteTimeUtc
}

# Deploy — auto-elevate on access-denied
$runtimeOk = Deploy-To $RuntimeDest "runtime"
$devOk     = Deploy-To $DevDest "development"

Write-Output ""
Write-Output "========================================="
if ($runtimeOk -and $devOk) {
    Write-Output "DEPLOY SUCCESS — both paths verified"
} else {
    Write-Output "DEPLOY FAILED — see errors above"
    if (-not $runtimeOk) { Write-Output "  Runtime path FAILED" }
    if (-not $devOk)     { Write-Output "  Dev path FAILED" }
}
Write-Output "========================================="

if ($runtimeOk -and $devOk) { exit 0 } else { exit 1 }
