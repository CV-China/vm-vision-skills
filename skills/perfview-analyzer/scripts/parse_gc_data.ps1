param(
    [Parameter(Mandatory)]
    [string]$EtlFile,

    [Parameter(Mandatory)]
    [int]$TargetPid,

    [Parameter(Mandatory)]
    [string]$TargetProcess,

    [Parameter(Mandatory)]
    [string]$OutputBase,

    [string]$XperfPath = ""
)

$ErrorActionPreference = "Continue"

# Auto-detect xperf
if (-not $XperfPath -or -not (Test-Path $XperfPath)) {
    try {
        $found = Get-Command xperf.exe -ErrorAction SilentlyContinue
        if ($found) { $XperfPath = $found.Source }
    } catch {}
    if (-not $XperfPath) {
        $pf86 = [Environment]::GetFolderPath("ProgramFilesX86")
        $pf = [Environment]::GetFolderPath("ProgramFiles")
        $searchPaths = @(
            "$pf86\Windows Kits\10\Windows Performance Toolkit\xperf.exe",
            "$pf\Windows Kits\10\Windows Performance Toolkit\xperf.exe"
        )
        foreach ($p in $searchPaths) {
            if (Test-Path $p) { $XperfPath = $p; break }
        }
    }
}
if (-not $XperfPath -or -not (Test-Path $XperfPath)) {
    Write-Host "ERROR: xperf.exe not found. Provide -XperfPath." -ForegroundColor Red
    exit 1
}

Write-Host "=== Dumping .NET GC events for $TargetProcess (PID $TargetPid) ==="

$allDump = "$OutputBase`_fulldump.txt"
$gcDump = "$OutputBase`_GCDetail.txt"

Write-Host "Dumping all events (this may take a minute)..."
& $XperfPath -i $EtlFile -a dumper 2>&1 | Out-File -FilePath $allDump -Encoding UTF8

$totalLines = (Get-Content $allDump | Measure-Object -Line).Lines
Write-Host "Total events: $totalLines"

Write-Host "Filtering for $TargetProcess GC events..."
$gcEvents = Select-String -Path $allDump -Pattern "$TargetProcess.*(GC|Garbage|Alloc|Heap|Finaliz|Suspend|Restart|Mark|Pin)" | ForEach-Object { $_.Line }

$gcEvents | Out-File -FilePath $gcDump -Encoding UTF8
$gcEventCount = ($gcEvents | Measure-Object).Count
Write-Host "GC-related events for $TargetProcess: $gcEventCount"

if ($gcEventCount -eq 0) {
    Write-Host "No GC events found for $TargetProcess. Checking for any .NET Runtime events..."
    $anyCLR = Select-String -Path $allDump -Pattern "DotNETRuntime" | Select-Object -First 5
    Write-Host "Any .NET Runtime events: $($anyCLR.Count)"
    $anyCLR | ForEach-Object { Write-Host $_ }
    $pidLines = Select-String -Path $allDump -Pattern "$TargetPid" | Select-Object -First 5
    Write-Host "Lines with PID $TargetPid: $($pidLines.Count)"
    exit 0
}

# ---- Parse GC Heap Stats ----
Write-Host ""
Write-Host "=== Parsing GCHeapStats ==="
$heapStats = $gcEvents | Select-String "GCHeapStats"
Write-Host "GCHeapStats events: $($heapStats.Count)"

$heapStatsData = @()
foreach ($line in $heapStats) {
    if ($line -match 'GenerationSize0,\s*(\d+).*?GenerationSize1,\s*(\d+).*?GenerationSize2,\s*(\d+).*?GenerationSize3,\s*(\d+).*?TotalPromotedSize0,\s*(\d+).*?TotalPromotedSize1,\s*(\d+).*?TotalPromotedSize2,\s*(\d+).*?TotalPromotedSize3,\s*(\d+).*?FinalizationPromotedSize,\s*(\d+).*?PinnedObjectCount,\s*(\d+).*?GCHandleCount,\s*(\d+)') {
        $heapStatsData += [PSCustomObject]@{
            Gen0Size = [long]$Matches[1]
            Gen1Size = [long]$Matches[2]
            Gen2Size = [long]$Matches[3]
            Gen3Size = [long]$Matches[4]
            Promoted0 = [long]$Matches[5]
            Promoted1 = [long]$Matches[6]
            Promoted2 = [long]$Matches[7]
            Promoted3 = [long]$Matches[8]
            FinalPromoted = [long]$Matches[9]
            PinnedCount = [long]$Matches[10]
            GCHandles = [long]$Matches[11]
        }
    }
}

if ($heapStatsData.Count -gt 0) {
    Write-Host "Parsed $($heapStatsData.Count) GCHeapStats events"
    Write-Host "--- Heap Size Summary ---"
    Write-Host "Gen0: Min=$([math]::Round(($heapStatsData | Measure-Object Gen0Size -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($heapStatsData | Measure-Object Gen0Size -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($heapStatsData | Measure-Object Gen0Size -Average).Average/1KB,1))KB"
    Write-Host "Gen1: Min=$([math]::Round(($heapStatsData | Measure-Object Gen1Size -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($heapStatsData | Measure-Object Gen1Size -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($heapStatsData | Measure-Object Gen1Size -Average).Average/1KB,1))KB"
    Write-Host "Gen2: Min=$([math]::Round(($heapStatsData | Measure-Object Gen2Size -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($heapStatsData | Measure-Object Gen2Size -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($heapStatsData | Measure-Object Gen2Size -Average).Average/1KB,1))KB"
    Write-Host "LOH(Gen3): Min=$([math]::Round(($heapStatsData | Measure-Object Gen3Size -Minimum).Minimum/1KB,1))KB  Max=$([math]::Round(($heapStatsData | Measure-Object Gen3Size -Maximum).Maximum/1KB,1))KB  Avg=$([math]::Round(($heapStatsData | Measure-Object Gen3Size -Average).Average/1KB,1))KB"
    Write-Host "Pinned Objects: Min=$((($heapStatsData | Measure-Object PinnedCount -Minimum).Minimum))  Max=$((($heapStatsData | Measure-Object PinnedCount -Maximum).Maximum))  Avg=$([math]::Round(($heapStatsData | Measure-Object PinnedCount -Average).Average,1))"
}

# ---- Parse GC Pause Events ----
Write-Host ""
Write-Host "=== Parsing GC Pause Events ==="
$suspendEvents = $gcEvents | Select-String "GCSuspendEEBegin"
$restartEvents = $gcEvents | Select-String "GCRestartEEEnd"
Write-Host "SuspendEEBegin events: $($suspendEvents.Count)"
Write-Host "RestartEEEnd events: $($restartEvents.Count)"

# ---- Parse GCGlobalHeapHistory ----
Write-Host ""
Write-Host "=== Parsing GCGlobalHeapHistory ==="
$gcHistory = $gcEvents | Select-String "GCGlobalHeapHistory"
Write-Host "GCGlobalHeapHistory events: $($gcHistory.Count)"

$gcHistoryData = @()
foreach ($line in $gcHistory) {
    if ($line -match '(\d+),\s*.*?CondemnedGeneration,\s*(\d+).*?Reason,\s*(\d+).*?PauseMode,\s*(\d+).*?MemoryPressure,\s*(\d+)') {
        $gcHistoryData += [PSCustomObject]@{
            Timestamp = [long]$Matches[1]
            CondemnedGen = [int]$Matches[2]
            Reason = [int]$Matches[3]
            PauseMode = [int]$Matches[4]
            MemPressure = [int]$Matches[5]
        }
    }
}

$gen0Count = 0; $gen1Count = 0; $gen2Count = 0
$blocking = 0; $background = 0
if ($gcHistoryData.Count -gt 0) {
    $gen0Count = ($gcHistoryData | Where-Object CondemnedGen -eq 0).Count
    $gen1Count = ($gcHistoryData | Where-Object CondemnedGen -eq 1).Count
    $gen2Count = ($gcHistoryData | Where-Object CondemnedGen -eq 2).Count
    $blocking = ($gcHistoryData | Where-Object PauseMode -eq 0).Count
    $background = ($gcHistoryData | Where-Object PauseMode -eq 1).Count
    Write-Host "GC Summary: Gen0=$gen0Count, Gen1=$gen1Count, Gen2=$gen2Count, Total=$($gcHistoryData.Count)"
    Write-Host "Pause Modes: Blocking=$blocking, Background=$background"
}

# ---- Parse Allocation Ticks ----
Write-Host ""
Write-Host "=== Parsing GCAllocationTick ==="
$allocEvents = $gcEvents | Select-String "GCAllocationTick"
Write-Host "AllocationTick events: $($allocEvents.Count)"

$allocData = @()
$typeAlloc = @{}
$totalAllocBytes = 0L
foreach ($line in $allocEvents) {
    if ($line -match 'AllocationAmount,\s*(\d+).*?AllocationKind,\s*(\d+).*?AllocationAmount64,\s*(\d+).*?TypeID.*?TypeName,\s*(.*?),\s*HeapIndex') {
        $amount = [long]$Matches[3]
        $typeName = $Matches[4]
        $allocData += [PSCustomObject]@{ Amount = $amount; TypeName = $typeName }
        if (-not $typeAlloc.ContainsKey($typeName)) { $typeAlloc[$typeName] = @{ Count = 0; TotalBytes = 0L } }
        $typeAlloc[$typeName].Count++
        $typeAlloc[$typeName].TotalBytes += $amount
    }
}

if ($allocData.Count -gt 0) {
    $totalAllocBytes = ($allocData | Measure-Object Amount -Sum).Sum
    Write-Host "Total allocations: $($allocData.Count) ticks, $([math]::Round($totalAllocBytes/1MB,2)) MB total"
    Write-Host ""
    Write-Host "=== Top 15 Allocating Types ==="
    $typeAlloc.GetEnumerator() | Sort-Object { $_.Value.TotalBytes } -Descending | Select-Object -First 15 | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value.Count) allocs, $([math]::Round($_.Value.TotalBytes/1KB,1)) KB"
    }
}

# ---- Save parsed data as JSON ----
$reportData = [PSCustomObject]@{
    ProcessName = $TargetProcess
    PID = $TargetPid
    GCGlobalHistoryCount = $gcHistoryData.Count
    Gen0Count = $gen0Count
    Gen1Count = $gen1Count
    Gen2Count = $gen2Count
    BlockingGCCount = $blocking
    BackgroundGCCount = $background
    TotalAllocations = $allocData.Count
    TotalAllocBytes = $totalAllocBytes
    HeapStatsCount = $heapStatsData.Count
    TopAllocTypes = ($typeAlloc.GetEnumerator() | Sort-Object { $_.Value.TotalBytes } -Descending | Select-Object -First 10 | ForEach-Object { "$($_.Key):$($_.Value.Count):$($_.Value.TotalBytes)" }) -join "|"
}

$reportData | ConvertTo-Json -Depth 3 | Out-File -FilePath "$OutputBase`_gcdata.json" -Encoding UTF8
Write-Host ""
Write-Host "Data saved to: $OutputBase`_gcdata.json"
