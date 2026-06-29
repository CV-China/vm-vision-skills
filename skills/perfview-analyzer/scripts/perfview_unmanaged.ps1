<#
.SYNOPSIS
    Collect ETW traces for unmanaged (C++) memory analysis via VirtAlloc events.
.DESCRIPTION
    Uses PerfView start/stop commands to capture VirtAlloc + optional .NET managed heap
    allocations. Designed for LLM-orchestrated multi-phase collection via -PhaseName.
    Outputs JSON summary with file paths for downstream xperf CLI analysis.
.PARAMETER TargetPid
    Process ID to trace.
.PARAMETER TargetProcess
    Process name (used for output file naming). Sanitized for path safety.
.PARAMETER Duration
    Collection duration in seconds (default: 30).
.PARAMETER OutputDir
    Output directory for ETL files (default: $env:USERPROFILE\PerfView\Traces).
.PARAMETER PerfViewPath
    Path to PerfView.exe. Auto-detected if not specified.
.PARAMETER XperfPath
    Path to xperf.exe. Auto-detected if not specified.
.PARAMETER CircularMB
    Circular buffer size in MB (default: 10000).
.PARAMETER BufferSizeMB
    ETW buffer size in MB (default: 4096).
.PARAMETER PhaseName
    Phase label for multi-phase collection (e.g. "空方案","加载方案","运行检测").
.PARAMETER Cleanup
    Remove raw .etl files after collection (keep .etl.zip).
.EXAMPLE
    # Single-phase unmanaged memory collection
    .\perfview_unmanaged.ps1 -TargetPid 12345 -TargetProcess "MyApp"

    # Multi-phase collection (LLM calls per phase)
    .\perfview_unmanaged.ps1 -TargetPid 12345 -TargetProcess "MyApp" -PhaseName "空方案"
#>

param(
    [Parameter(Mandatory)]
    [ValidateRange(1, 2147483647)]
    [int]$TargetPid,

    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9_. -]+$')]
    [string]$TargetProcess,

    [ValidateRange(5, 3600)]
    [int]$Duration = 30,

    [string]$OutputDir = "$env:USERPROFILE\PerfView\Traces",

    [string]$PerfViewPath = "",

    [string]$XperfPath = "",

    [ValidateRange(64, 65536)]
    [int]$CircularMB = 10000,

    [ValidateRange(64, 8192)]
    [int]$BufferSizeMB = 4096,

    [string]$PhaseName = "",

    [switch]$Cleanup = $false
)

$ErrorActionPreference = "Continue"

# ---- Helper: detect tools via shared detection script ----
function Find-Tools {
    $detectScript = Join-Path $PSScriptRoot "perfview_detect.ps1"
    $detectResult = $null
    if (Test-Path $detectScript) {
        try {
            $detectJson = & $detectScript 2>$null
            if ($detectJson) {
                $detectResult = $detectJson | ConvertFrom-Json -ErrorAction SilentlyContinue
            }
        } catch {}
    }

    if (-not (Test-Path $script:PerfViewPath)) {
        if ($detectResult -and $detectResult.perfview_path) {
            $script:PerfViewPath = $detectResult.perfview_path
        }
    }
    if (-not (Test-Path $script:XperfPath)) {
        if ($detectResult -and $detectResult.xperf_available -and $detectResult.xperf_path) {
            $script:XperfPath = $detectResult.xperf_path
        }
    }

    # Fallback: search common locations
    if (-not (Test-Path $script:PerfViewPath)) {
        $searchPaths = @()
        foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Where-Object Root)) {
            $searchPaths += (Join-Path $drive.Root "PerfView\PerfView.exe")
        }
        $searchPaths += "$env:USERPROFILE\Desktop\PerfView\PerfView.exe"
        $searchPaths += "$env:USERPROFILE\Downloads\PerfView\PerfView.exe"
        foreach ($p in $searchPaths) {
            if (Test-Path $p) { $script:PerfViewPath = $p; break }
        }
    }

    if ($detectResult) { return $detectResult }
    return $null
}

# ---- Tool detection ----
$detectResult = Find-Tools

if (-not $PerfViewPath -or -not (Test-Path $PerfViewPath)) {
    Write-Host "ERROR: PerfView.exe not found." -ForegroundColor Red
    Write-Host "Action: Please provide the PerfView.exe path using -PerfViewPath, or download from:" -ForegroundColor Yellow
    Write-Host "  https://github.com/microsoft/perfview/releases" -ForegroundColor Yellow
    exit 1
}

# ---- Verify target process ----
$proc = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
if (-not $proc) {
    Write-Host "ERROR: Process PID $TargetPid not found." -ForegroundColor Red
    exit 1
}
Write-Host "Target: $($proc.ProcessName).exe (PID: $TargetPid)" -ForegroundColor Cyan

# ---- Prepare output ----
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$safeProcName = $TargetProcess -replace '[^\w.-]', '_'
if ($PhaseName) {
    $safePhase = $PhaseName -replace '[^\w一-鿿-]', '_'
    $etlBase = Join-Path $OutputDir "${safeProcName}_${safePhase}_${timestamp}"
} else {
    $etlBase = Join-Path $OutputDir "${safeProcName}_${timestamp}"
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# ---- Build command ----
# Only kernel events needed: VirtAlloc for unmanaged memory analysis (xperf -a virtualalloc)
# CLR events and .NET Alloc are NOT collected — managed GC analysis is outside this skill's scope
$kernelArgs = "Default,VirtualAlloc,VAMap"

$maxSec = $Duration + 30

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " PerfView Collection Configuration" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Unmanaged (VirtAlloc) : ENABLED"
Write-Host "Duration              : ${Duration}s (MaxCollect: ${maxSec}s)"
$phaseDisplay = if($PhaseName){$PhaseName}else{'N/A (single phase)'}
Write-Host "Phase                 : $phaseDisplay"
Write-Host "Circular MB           : ${CircularMB} MB"
Write-Host "Buffer Size           : ${BufferSizeMB} MB"
Write-Host "Output                : $etlBase"
Write-Host "============================================"
Write-Host ""

# ---- Stop existing traces ----
Write-Host "[1/4] Stopping any existing traces..." -ForegroundColor Yellow
try {
    & $PerfViewPath stop 2>&1 | Out-Null
    Start-Sleep -Seconds 3
} catch {
    Write-Host "  Note: Could not stop prior sessions (may be none running)" -ForegroundColor DarkGray
}

# ---- Start collection ----
Write-Host "[2/4] Starting ETW collection..." -ForegroundColor Yellow

$startArgs = @(
    "/DataFile=$etlBase.etl",
    "/MaxCollectSec:$maxSec",
    "/KernelEvents=$kernelArgs",
    "/CpuSampleMSec:1",
    "/CircularMB=$CircularMB",
    "/BufferSizeMB=$BufferSizeMB",
    "/LogFile=$etlBase.log.txt",
    "/AcceptEula"
)

$startArgs += "start"

# Run PerfView start (returns quickly after enabling providers)
& $PerfViewPath $startArgs 2>&1 | ForEach-Object {
    Write-Host "  $_" -ForegroundColor DarkGray
}
Start-Sleep -Seconds 3

# Check if trace started
$logFile = "$etlBase.log.txt"
if (Test-Path $logFile) {
    $logContent = Get-Content $logFile -Raw
    if ($logContent -match '(?i)success') {
        Write-Host "  [OK] ETW providers enabled" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Check log: $logFile" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WARN] No log file - trace may not have started" -ForegroundColor Yellow
}

# ---- Wait for collection ----
Write-Host "[3/4] Collecting data for ${Duration}s..." -ForegroundColor Yellow
Write-Host "  IMPORTANT: Execute your test scenario NOW (load scheme, run inspection, etc.)" -ForegroundColor Magenta

$elapsed = 0
Write-Progress -Activity "PerfView ETW Collection" -Status "Starting... $Duration seconds remaining" -PercentComplete 0
while ($elapsed -lt $Duration) {
    $chunk = [Math]::Min(10, $Duration - $elapsed)
    Start-Sleep -Seconds $chunk
    $elapsed += $chunk
    $remaining = $Duration - $elapsed
    Write-Progress -Activity "PerfView ETW Collection" -Status "Collecting... $remaining seconds remaining" -PercentComplete ([int](($elapsed / $Duration) * 100))
}
Write-Progress -Activity "PerfView ETW Collection" -Completed

# ---- Stop collection ----
Write-Host "[4/4] Stopping trace and merging data (this may take 1-3 minutes)..." -ForegroundColor Yellow
Write-Host "  IMPORTANT: Keep the application running until this completes!" -ForegroundColor Magenta

$stopOutput = & $PerfViewPath "/DataFile=$etlBase.etl" "stop" 2>&1
if ($LASTEXITCODE -ne 0 -or $stopOutput -match 'ERROR|FAIL') {
    Write-Host "  WARN: $stopOutput" -ForegroundColor Yellow
}

# ---- Check output ----
$etlZip = "$etlBase.etl.zip"
$etlFile = "$etlBase.etl"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Collection Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$files = Get-ChildItem "$etlBase*" -ErrorAction SilentlyContinue
$etlZipSize = 0
$hasData = $false

if (Test-Path $etlZip) {
    $etlZipSize = (Get-Item $etlZip).Length
    $hasData = $true
    Write-Host "ETL (zipped) : $([math]::Round($etlZipSize/1MB,1)) MB" -ForegroundColor Green
} elseif (Test-Path $etlFile) {
    $etlZipSize = (Get-Item $etlFile).Length
    $hasData = $true
    Write-Host "ETL (raw)     : $([math]::Round($etlZipSize/1MB,1)) MB" -ForegroundColor Green
} else {
    Write-Host "ERROR: No ETL output generated!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Output files:" -ForegroundColor Cyan
if ($files) {
    $files | ForEach-Object {
        $sz = if ($_.Length -gt 1MB) { "$([math]::Round($_.Length/1MB,1)) MB" } else { "$([math]::Round($_.Length/1KB,1)) KB" }
        Write-Host "  $($_.Name) ($sz)"
    }
}

# ---- Output summary JSON ----
$xperfFound = ($XperfPath -and (Test-Path $XperfPath))
$summary = [PSCustomObject]@{
    status          = if ($hasData) { "complete" } else { "failed" }
    target_pid      = $TargetPid
    target_process  = $TargetProcess
    duration        = $Duration
    phase_name      = $PhaseName
    virtalloc       = $true  # VirtAlloc always enabled — required for unmanaged memory analysis
    circular_mb     = $CircularMB
    etl_zip         = if (Test-Path $etlZip) { $etlZip } else { "" }
    etl_file        = if (Test-Path $etlFile) { $etlFile } else { "" }
    etl_size_mb     = [math]::Round($etlZipSize / 1MB, 1)
    log_file        = $logFile
    output_dir      = $OutputDir
    base_name       = Split-Path $etlBase -Leaf
    xperf_available = $xperfFound
    xperf_path      = if ($xperfFound) { $XperfPath } else { "" }
}

$summary | ConvertTo-Json -Compress

# ---- Optional: Cleanup raw ETL ----
if ($Cleanup -and $hasData -and (Test-Path $etlZip)) {
    Write-Host ""
    Write-Host "[Cleanup] Removing raw ETL files..." -ForegroundColor Yellow
    Get-ChildItem "$etlBase*" | Where-Object { $_.Name -match '\.etl$|\.kernel\.etl$' -and $_.Name -notmatch '\.zip$' } | ForEach-Object {
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        Write-Host "  Removed: $($_.Name)"
    }
}

if ($hasData) { exit 0 } else { exit 1 }
