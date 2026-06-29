<#
.SYNOPSIS
    Detect PerfView and Windows Performance Toolkit (xperf) installations.
.DESCRIPTION
    Searches common paths, PATH, and registry for PerfView.exe and xperf.exe.
    PerfView uses ETW and works on any Windows CPU — no PMU dependency.
    If tools are not found, outputs guidance for the user to provide paths.
.OUTPUTS
    JSON object on stdout with detection results and guidance.
#>

# ---- 1. Find PerfView ----
$perfviewPath = $null
$perfviewVersion = ""

# Search PATH first
try {
    $found = Get-Command PerfView.exe -ErrorAction SilentlyContinue
    if ($found) { $perfviewPath = $found.Source }
} catch {}

# ---- Everything.exe es.exe 快速全盘搜索（优先，秒级） ----
$everythingDir = Join-Path $PSScriptRoot "..\tools"
$esExe = Join-Path $everythingDir "es.exe"
if (-not $perfviewPath -and (Test-Path $esExe)) {
    try {
        $esResult = & $esExe "PerfView.exe" 2>$null | Select-Object -First 5
        foreach ($line in $esResult) {
            $candidate = $line.Trim()
            if ($candidate -match 'PerfView\.exe$' -and (Test-Path $candidate)) {
                $perfviewPath = $candidate
                break
            }
        }
    } catch {}
}

# Search common install locations (drive-letter agnostic)
if (-not $perfviewPath) {
    $commonDirs = @(
        # Current working directory (where Claude was launched)
        (Get-Location).Path,
        # User directories
        "$env:USERPROFILE\Desktop\PerfView",
        "$env:USERPROFILE\Downloads\PerfView",
        "$env:USERPROFILE\PerfView",
        # Skill tools directory
        (Join-Path $PSScriptRoot "..\tools"),
        # Program Files variants
        "${env:ProgramFiles}\PerfView",
        "${env:ProgramFiles(x86)}\PerfView"
    )
    # Also check root of each available drive
    foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Where-Object Root)) {
        $commonDirs += (Join-Path $drive.Root "PerfView")
    }
    foreach ($dir in $commonDirs) {
        $candidate = Join-Path $dir "PerfView.exe"
        if (Test-Path $candidate) { $perfviewPath = $candidate; break }
    }
}

if ($perfviewPath) {
    try {
        $verInfo = (Get-Item $perfviewPath).VersionInfo
        $perfviewVersion = "$($verInfo.ProductVersion)"
    } catch {
        $perfviewVersion = "Unknown"
    }
}

# ---- 2. Find xperf (Windows Performance Toolkit) ----
$xperfPath = $null
$xperfAvailable = $false

# Check PATH
try {
    $found = Get-Command xperf.exe -ErrorAction SilentlyContinue
    if ($found) { $xperfPath = $found.Source; $xperfAvailable = $true }
} catch {}

# Check Windows Kits via registry
if (-not $xperfAvailable) {
    $kitsRoots = @()
    try {
        $kitsReg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots" -ErrorAction SilentlyContinue
        if ($kitsReg) {
            $kitsRoot = $kitsReg.KitsRoot10
            if ($kitsRoot) {
                $kitsRoots += (Join-Path $kitsRoot "Windows Performance Toolkit\xperf.exe")
            }
        }
    } catch {}

    # Fallback: check common install paths
    $kitsRoots += @(
        "${env:ProgramFiles(x86)}\Windows Kits\10\Windows Performance Toolkit\xperf.exe",
        "${env:ProgramFiles}\Windows Kits\10\Windows Performance Toolkit\xperf.exe"
    )
    # Also check available drives
    foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Where-Object Root)) {
        $kitsRoots += (Join-Path $drive.Root "Windows Kits\10\Windows Performance Toolkit\xperf.exe")
    }

    foreach ($p in $kitsRoots) {
        if (Test-Path $p) { $xperfPath = $p; $xperfAvailable = $true; break }
    }
}

# ---- 3. Output result ----
$perfviewFound = ($null -ne $perfviewPath)
$ready = $perfviewFound
$status = if ($perfviewFound -and $xperfAvailable) {
    "All tools ready"
} elseif ($perfviewFound) {
    "PerfView found, xperf missing (install Windows ADK or provide xperf path)"
} else {
    "PerfView not found, please provide PerfView.exe path"
}

$guidance = if (-not $perfviewFound) {
    "Please download PerfView from https://github.com/microsoft/perfview/releases and provide the path to PerfView.exe"
} elseif (-not $xperfAvailable) {
    "Please install Windows Performance Toolkit from Windows ADK, or provide the path to xperf.exe"
} else {
    ""
}

$result = [PSCustomObject]@{
    perfview_path    = if ($perfviewPath) { $perfviewPath } else { "" }
    perfview_version = $perfviewVersion
    xperf_path       = if ($xperfPath) { $xperfPath } else { "" }
    xperf_available  = $xperfAvailable
    perfview_found   = $perfviewFound
    ready            = $ready
    status           = $status
    guidance         = $guidance
}

$result | ConvertTo-Json -Compress

if (-not $perfviewFound) { exit 1 }
exit 0
