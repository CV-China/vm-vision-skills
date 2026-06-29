param(
    [Parameter(Mandatory)]
    [string]$EtlFile,

    [Parameter(Mandatory)]
    [int]$TargetPid,

    [string]$TargetProcess = "",

    [string]$LogFile = ""
)

$ErrorActionPreference = "Continue"
$xperf = (Get-Command xperf.exe -ErrorAction SilentlyContinue).Source
if (-not $xperf) {
    $pf86 = [Environment]::GetFolderPath("ProgramFilesX86")
    $pf = [Environment]::GetFolderPath("ProgramFiles")
    foreach ($p in @("$pf86\Windows Kits\10\Windows Performance Toolkit\xperf.exe", "$pf\Windows Kits\10\Windows Performance Toolkit\xperf.exe")) {
        if (Test-Path $p) { $xperf = $p; break }
    }
}
if (-not $xperf) { Write-Host "ERROR: xperf.exe not found." -ForegroundColor Red; exit 1 }

Write-Host "=== Checking all GC events in the trace ==="
$output = & $xperf -i $EtlFile -a dumper 2>&1

# Count all GC-related events (any process)
$allGCHeapStats = ($output | Where-Object { $_ -match 'GCHeapStats' }).Count
$allGCHistory = ($output | Where-Object { $_ -match 'GCGlobalHeapHistory' }).Count
$allAlloc = ($output | Where-Object { $_ -match 'GCAllocationTick' }).Count
$allSuspend = ($output | Where-Object { $_ -match 'GCSuspendEEBegin' }).Count
$finalizeBegin = ($output | Where-Object { $_ -match 'GCFinalizersBegin' }).Count

Write-Host "ALL Processes:"
Write-Host "  GCHeapStats: $allGCHeapStats"
Write-Host "  GCGlobalHeapHistory: $allGCHistory"
Write-Host "  GCAllocationTick: $allAlloc"
Write-Host "  GCSuspendEEBegin: $allSuspend"
Write-Host "  GCFinalizersBegin: $finalizeBegin"

# Which .NET processes have GC events?
Write-Host ""
Write-Host "=== .NET processes in trace ==="
$dotnetProcs = $output | Where-Object { $_ -match 'DotNETRuntime.*exe.*\(\d+\)' }
if ($dotnetProcs.Count -gt 0) {
    # Extract unique process names from GC events
    $procs = @{}
    foreach ($line in ($output | Where-Object { $_ -match 'GCAllocationTick|GCHeapStats|GCGlobalHeapHistory' })) {
        if ($line -match '([A-Za-z_]+\.exe)\s*\((\d+)\)') {
            $key = "$($Matches[1]) ($($Matches[2]))"
            if (-not $procs.ContainsKey($key)) { $procs[$key] = 0 }
            $procs[$key]++
        }
    }
    Write-Host "Processes with GC events:"
    $procs.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value) events"
    }
}

# Check for CLR-related processes (not just GC events)
Write-Host ""
$procFilter = if ($TargetProcess) { $TargetProcess } else { "." }
Write-Host ("=== CLR modules loaded by {0} during trace ===" -f $TargetProcess)
$vmImages = $output | Where-Object { $_ -match "${procFilter}.*ImageId.*\.(dll|exe)" }
$clrImages = $vmImages | Where-Object { $_ -match 'clr|mscorlib|System\.' }
Write-Host "CLR-related images loaded: $($clrImages.Count)"

# Check target process timeline
Write-Host ""
Write-Host "=== Target process timeline ==="
$pidPattern = [regex]::Escape("($TargetPid)")
$pidLines = $output | Where-Object { $_ -match $pidPattern }
Write-Host ("Total events matching PID {0}: {1}" -f $TargetPid, $pidLines.Count)

$vmStart = $pidLines | Where-Object { $_ -match 'P-Start|T-Start' }
$vmEnd = $pidLines | Where-Object { $_ -match 'P-End|T-End' }
Write-Host "  Process/Thread Start: $($vmStart.Count)"
Write-Host "  Process/Thread End: $($vmEnd.Count)"

# Check when GC events occurred relative to trace
Write-Host ""
Write-Host "=== Trace timing ==="
$firstTs = 0; $lastTs = 0
if ($output -match 'FirstReliableEventTimeStamp,\s*(\d+)') {
    Write-Host "FirstReliableEventTimeStamp: $($Matches[1])"
}
$firstGCEvent = $output | Where-Object { $_ -match 'DotNETRuntime.*\d+,\s*(\d+)' } | Select-Object -First 1
if ($firstGCEvent -match '(\d+),') {
    Write-Host "First GC event timestamp: $($Matches[1])"
}

Write-Host ""
Write-Host "=== Log file summary ==="
if (Test-Path $LogFile) {
    $log = Get-Content $LogFile -Raw
    if ($log -match 'CLR Rundown took ([\d.]+) sec') { Write-Host "CLR Rundown: $($Matches[1])s" }
    if ($log -match 'Merge and NGEN PDB Generation took ([\d.]+) sec') { Write-Host "Merge+NGEN: $($Matches[1])s" }
    if ($log -match 'ZIP generation took ([\d.]+) sec') { Write-Host "ZIP: $($Matches[1])s" }
}
