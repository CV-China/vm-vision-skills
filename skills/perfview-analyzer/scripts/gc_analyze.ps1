param(
    [Parameter(Mandatory)]
    [string]$EtlFile,

    [Parameter(Mandatory)]
    [string]$OutputBase,

    [Parameter(Mandatory)]
    [int]$TargetPid,

    [string]$TargetProcess = ""
)

$ErrorActionPreference = "Continue"

# Auto-detect xperf
$xperf = $null
try { $found = Get-Command xperf.exe -ErrorAction SilentlyContinue; if ($found) { $xperf = $found.Source } } catch {}
if (-not $xperf) {
    $pf86 = [Environment]::GetFolderPath("ProgramFilesX86")
    $pf = [Environment]::GetFolderPath("ProgramFiles")
    $searchPaths = @(
        "$pf86\Windows Kits\10\Windows Performance Toolkit\xperf.exe",
        "$pf\Windows Kits\10\Windows Performance Toolkit\xperf.exe"
    )
    foreach ($p in $searchPaths) { if (Test-Path $p) { $xperf = $p; break } }
}
if (-not $xperf) { Write-Host "ERROR: xperf.exe not found." -ForegroundColor Red; exit 1 }

Write-Host "=== PerfView Memory Analysis: GC Event Extraction ==="

# Dump events, filter for .NET GC events by $TargetProcess (if provided) or PID
Write-Host "[1/3] Dumping ETW events and filtering for GC..."
$gcFile = "$OutputBase`_GCDetail.txt"
$allGC = @()

# Use a more targeted approach: dump all events but filter in-stream
$dumperOutput = & $xperf -i $EtlFile -a dumper 2>&1
Write-Host "Total dumper output lines: $($dumperOutput.Count)"

# Filter for lines containing GC-related event names (optionally filtered by process name)
$processFilter = if ($TargetProcess) { $TargetProcess } else { "." }
$gcEvents = $dumperOutput | Where-Object {
    $_ -match $processFilter -and ($_ -match 'GCHeapStats|GCSuspendEE|GCRestartEE|GCGlobalHeapHistory|GCAllocationTick|GCPerHeapHistory|GCMarkWithType|GCFinalizers|PinObjectAtGCTime|GCCreateSegment|GCCreateConcurrentThread|GCTriggered|IncreaseMemoryPressure')
}

Write-Host "Filtered GC events: $($gcEvents.Count)"

if ($gcEvents.Count -eq 0) {
    # Try without process name filter — GC events might not embed process name
    Write-Host "Trying without process filter..."
    $gcEvents = $dumperOutput | Where-Object {
        $_ -match 'GCHeapStats|GCSuspendEEBegin|GCRestartEEEnd|GCGlobalHeapHistory|GCAllocationTick'
    }
    Write-Host "GC events (all processes): $($gcEvents.Count)"

    # Now filter by PID
    $gcEvents = $gcEvents | Where-Object { $_ -match [regex]::Escape("$TargetPid") }
    Write-Host ("GC events for PID {0}: {1}" -f $TargetPid, $gcEvents.Count)
}

$gcEvents | Out-File -FilePath $gcFile -Encoding UTF8
Write-Host "GC events saved to: $gcFile"

# ---- Parse the events ----
Write-Host ""
Write-Host "[2/3] Parsing GC events..."

# Count event types
$heapStats = ($gcEvents | Where-Object { $_ -match 'GCHeapStats' }).Count
$suspendBegin = ($gcEvents | Where-Object { $_ -match 'GCSuspendEEBegin' }).Count
$restartEnd = ($gcEvents | Where-Object { $_ -match 'GCRestartEEEnd' }).Count
$globalHistory = ($gcEvents | Where-Object { $_ -match 'GCGlobalHeapHistory' }).Count
$allocTicks = ($gcEvents | Where-Object { $_ -match 'GCAllocationTick' }).Count
$finalizeBegin = ($gcEvents | Where-Object { $_ -match 'GCFinalizersBegin' }).Count

Write-Host "GCHeapStats: $heapStats"
Write-Host "GCSuspendEEBegin: $suspendBegin"
Write-Host "GCRestartEEEnd: $restartEnd"
Write-Host "GCGlobalHeapHistory: $globalHistory"
Write-Host "GCAllocationTick: $allocTicks"
Write-Host "GCFinalizersBegin: $finalizeBegin"

# Parse GCGlobalHeapHistory for generation/reason data
Write-Host ""
Write-Host "[3/3] Summarizing GC activity..."

$gen0 = 0; $gen1 = 0; $gen2 = 0
$reasons = @{}
$pauseModes = @{}

foreach ($evt in ($gcEvents | Where-Object { $_ -match 'GCGlobalHeapHistory' })) {
    if ($evt -match 'CondemnedGeneration,\s*(\d+)') {
        $gen = [int]$Matches[1]
        if ($gen -eq 0) { $gen0++ } elseif ($gen -eq 1) { $gen1++ } else { $gen2++ }
    }
    if ($evt -match 'Reason,\s*(\d+)') {
        $r = $Matches[1]
        if (-not $reasons.ContainsKey($r)) { $reasons[$r] = 0 }
        $reasons[$r]++
    }
    if ($evt -match 'PauseMode,\s*(\d+)') {
        $pm = $Matches[1]
        if (-not $pauseModes.ContainsKey($pm)) { $pauseModes[$pm] = 0 }
        $pauseModes[$pm]++
    }
}

Write-Host "=== GC Summary ==="
Write-Host "Total GCs: $($gen0 + $gen1 + $gen2)"
Write-Host "  Gen0: $gen0"
Write-Host "  Gen1: $gen1"
Write-Host "  Gen2: $gen2"
Write-Host "  Reasons: $($reasons | ConvertTo-Json -Compress)"
Write-Host "  PauseModes: $($pauseModes | ConvertTo-Json -Compress)"

# Parse heap sizes from GCHeapStats
$gen0Sizes = @(); $gen1Sizes = @(); $gen2Sizes = @(); $gen3Sizes = @()
foreach ($evt in ($gcEvents | Where-Object { $_ -match 'GCHeapStats' })) {
    if ($evt -match 'GenerationSize0,\s*(\d+).*?GenerationSize1,\s*(\d+).*?GenerationSize2,\s*(\d+).*?GenerationSize3,\s*(\d+)') {
        $gen0Sizes += [long]$Matches[1]
        $gen1Sizes += [long]$Matches[2]
        $gen2Sizes += [long]$Matches[3]
        $gen3Sizes += [long]$Matches[4]
    }
}

Write-Host ""
Write-Host "=== Heap Sizes ==="
if ($gen0Sizes.Count -gt 0) {
    Write-Host "Gen0: Min=$([math]::Round(($gen0Sizes | Measure-Object -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($gen0Sizes | Measure-Object -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($gen0Sizes | Measure-Object -Average).Average/1KB,1))KB"
}
if ($gen1Sizes.Count -gt 0) {
    Write-Host "Gen1: Min=$([math]::Round(($gen1Sizes | Measure-Object -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($gen1Sizes | Measure-Object -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($gen1Sizes | Measure-Object -Average).Average/1KB,1))KB"
}
if ($gen2Sizes.Count -gt 0) {
    Write-Host "Gen2: Min=$([math]::Round(($gen2Sizes | Measure-Object -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($gen2Sizes | Measure-Object -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($gen2Sizes | Measure-Object -Average).Average/1KB,1))KB"
}
if ($gen3Sizes.Count -gt 0) {
    Write-Host "LOH:  Min=$([math]::Round(($gen3Sizes | Measure-Object -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($gen3Sizes | Measure-Object -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($gen3Sizes | Measure-Object -Average).Average/1KB,1))KB"
}

# Parse Allocation Ticks
$totalAllocBytes = 0L
$allocCount = 0
$typeAlloc = @{}
foreach ($evt in ($gcEvents | Where-Object { $_ -match 'GCAllocationTick' })) {
    if ($evt -match 'AllocationAmount64,\s*(\d+).*?TypeName,\s*([^,]+)') {
        $totalAllocBytes += [long]$Matches[1]
        $allocCount++
        $t = $Matches[2].Trim()
        if (-not $typeAlloc.ContainsKey($t)) { $typeAlloc[$t] = 0L }
        $typeAlloc[$t] += [long]$Matches[1]
    }
}

Write-Host ""
Write-Host "=== Allocations ==="
Write-Host "Total AllocationTicks: $allocCount"
Write-Host "Total Bytes Allocated: $([math]::Round($totalAllocBytes/1MB, 2)) MB"
Write-Host "Top allocating types:"
$typeAlloc.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
    Write-Host "  $($_.Key): $([math]::Round($_.Value/1KB, 1)) KB"
}
