param(
    [Parameter(Mandatory)]
    [string]$BasePath,

    [Parameter(Mandatory)]
    [int]$TargetPid,

    [string]$PerfViewPath = "",
    [string]$XperfPath = ""
)

$ErrorActionPreference = "Continue"

$etlZip = "$BasePath.etl.zip"
$etlFile = "$BasePath.etl"

# Auto-detect tools
if (-not $PerfViewPath) {
    try { $found = Get-Command PerfView.exe -ErrorAction SilentlyContinue; if ($found) { $PerfViewPath = $found.Source } } catch {}
}
if (-not $XperfPath) {
    try { $found = Get-Command xperf.exe -ErrorAction SilentlyContinue; if ($found) { $XperfPath = $found.Source } } catch {}
}
$perfviewPath = $PerfViewPath
$xperfPath = $XperfPath
if (-not $perfviewPath -or -not (Test-Path $perfviewPath)) { Write-Host "ERROR: PerfView.exe not found. Use -PerfViewPath." -ForegroundColor Red; exit 1 }
if (-not $xperfPath -or -not (Test-Path $xperfPath)) { Write-Host "ERROR: xperf.exe not found. Use -XperfPath." -ForegroundColor Red; exit 1 }

# Step 1: Extract ETL from zip
if (-not (Test-Path $etlFile)) {
    Write-Host "[Extract] Unzipping ETL..."
    Expand-Archive -Path $etlZip -DestinationPath (Split-Path $BasePath -Parent) -Force
}

if (Test-Path $etlFile) {
    $sizeMB = [math]::Round((Get-Item $etlFile).Length/1MB, 1)
    Write-Host "ETL extracted: $sizeMB MB"
} else {
    Write-Host "ERROR: ETL not found"
    exit 1
}

# Step 2: Try PerfView GCStats (try different syntaxes for v3.x)
Write-Host ""
Write-Host "[PerfView] Attempting GCStats..."
$gcStatsFile = "$BasePath`_GCStats.txt"

# NOTE: GCStats blocks indefinitely in CLI mode (no GUI event loop). This call may hang.
# This script is legacy CPU profiling — the main workflow uses xperf CLI, not GCStats.
$gcArgs = @("GCStats", "/DataFile=$etlFile")
$gcOutput = & $perfviewPath $gcArgs 2>&1
$gcOutput | Out-File -FilePath $gcStatsFile -Encoding UTF8

Write-Host "GCStats output:"
Write-Host $gcOutput

# Step 3: Generate xperf reports
Write-Host ""
Write-Host "[xperf] Generating reports..."

# 3a: Process list
Write-Host "[1/3] Process List..."
$processFile = "$BasePath`_process.txt"
& $xperfPath -i $etlFile -o $processFile -a process 2>&1 | Out-Null
if (Test-Path $processFile) {
    $sizeKB = [math]::Round((Get-Item $processFile).Length/1KB, 1)
    Write-Host "  OK: process.txt ($sizeKB KB)"
}

# 3b: Stack analysis (allocation stacks + GC stacks)
Write-Host "[2/3] Stack Analysis..."
$stackFile = "$BasePath`_stacks.html"
$stackArgs = @("-i", $etlFile, "-o", $stackFile, "-a", "stack", "-butterfly", "20", "-pid", "$TargetPid")
& $xperfPath $stackArgs 2>&1 | Out-Null
if (Test-Path $stackFile) {
    $sizeKB = [math]::Round((Get-Item $stackFile).Length/1KB, 1)
    Write-Host "  OK: stacks.html ($sizeKB KB)"
}

# 3c: Extract GC events
Write-Host "[3/3] GC Events Dump..."
$gcEventsFile = "$BasePath`_GCEvents.txt"
$gcEventArgs = @(
    "-i", $etlFile, "-o", $gcEventsFile, "-a", "dumper",
    "-event", "Microsoft-Windows-DotNETRuntime:10:Start",
    "-event", "Microsoft-Windows-DotNETRuntime:10:Stop",
    "-event", "Microsoft-Windows-DotNETRuntime:1:Start",
    "-event", "Microsoft-Windows-DotNETRuntime:1:Stop",
    "-event", "Microsoft-Windows-DotNETRuntime:2:Start",
    "-event", "Microsoft-Windows-DotNETRuntime:2:Stop",
    "-event", "Microsoft-Windows-DotNETRuntime:GC/HeapStats"
)
& $xperfPath $gcEventArgs 2>&1 | Out-Null
if (Test-Path $gcEventsFile) {
    $sizeKB = [math]::Round((Get-Item $gcEventsFile).Length/1KB, 1)
    Write-Host "  OK: GCEvents.txt ($sizeKB KB)"
}

# Summary
Write-Host ""
Write-Host "=== Generated Files ==="
Get-ChildItem "$BasePath*" | ForEach-Object {
    $size = if ($_.Length -gt 1MB) { "$([math]::Round($_.Length/1MB,1)) MB" } else { "$([math]::Round($_.Length/1KB,1)) KB" }
    Write-Host "  $($_.Name) ($size)"
}
