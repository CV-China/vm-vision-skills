<#
.SYNOPSIS
    Collect ETW traces with PerfView and generate analysis reports.
    Supports CPU hotspots, .NET Memory (GC) analysis, and combined CPU+Memory profiling.
.DESCRIPTION
    Uses PerfView start/stop commands for non-interactive ETW collection.
    Then generates reports via xperf and/or PerfView's built-in analyzers:

    CPU Analysis:
    - CPU profile per core (xperf -a profile)
    - Process tree with CPU data (xperf -a process)
    - Stack analysis per module/function (xperf -a stack)
    - CPU/Disk activity (xperf -a cpudisk)

    Memory Analysis:
    - GCStats report (PerfView GCStats command) — GC pause times, heap sizes, allocation rates
    - PerfView GC event extraction for timeline analysis
    - Optionally: heap snapshot via heapdump command

    PerfView ETW tracing works on any Windows CPU (no PMU dependency) and
    requires no driver installation. Admin rights recommended but not required.
.PARAMETER TargetPid
    Process ID to focus analysis on (used to filter stack reports).
.PARAMETER TargetProcess
    Process name regex for stack filtering (e.g. "VisionMaster").
.PARAMETER AnalysisType
    "CPU" (default), "Memory" (GC + heap), or "CPUMemory" (combined).
    Memory mode uses /ClrEvents:GC+Stack and generates GCStats report.
.PARAMETER Duration
    Collection time in seconds (default: 30 for CPU, 60 for Memory).
.PARAMETER OutputDir
    Directory for results and reports (default: $env:USERPROFILE\PerfView\Traces).
.PARAMETER PerfViewPath
    Path to PerfView.exe. Auto-detected if not specified.
.PARAMETER XperfPath
    Path to xperf.exe. Auto-detected if not specified.
.PARAMETER CpuSampleMSec
    CPU sampling interval in ms (default: 1).
.PARAMETER HeapSnapshot
    If set, takes a .NET heap snapshot before stopping the trace.
    Uses PerfView HeapSnapshot command. Pauses the target process briefly.
.EXAMPLE
    # CPU hotspot analysis (30s)
    .\perfview_collect.ps1 -TargetPid 86324 -TargetProcess "VisionMaster" -AnalysisType CPU -Duration 30

    # Memory/GC analysis (60s, with allocation callstacks)
    .\perfview_collect.ps1 -TargetPid 86324 -TargetProcess "VisionMaster" -AnalysisType Memory -Duration 60

    # Combined CPU + Memory (90s, for comprehensive profiling)
    .\perfview_collect.ps1 -TargetPid 86324 -TargetProcess "VisionMaster" -AnalysisType CPUMemory -Duration 90

    # Memory analysis with heap snapshot
    .\perfview_collect.ps1 -TargetPid 86324 -TargetProcess "VisionMaster" -AnalysisType Memory -HeapSnapshot
#>

param(
    [int]$TargetPid = 0,
    [ValidatePattern('^[A-Za-z0-9_. -]+$')]
    [string]$TargetProcess = "",
    [ValidateSet("CPU","Memory","CPUMemory")]
    [string]$AnalysisType = "CPU",
    [ValidateRange(0, 3600)]
    [int]$Duration = 0,
    [string]$OutputDir = "$env:USERPROFILE\PerfView\Traces",
    [string]$PerfViewPath = "",
    [string]$XperfPath = "",
    [int]$CpuSampleMSec = 1,
    [switch]$HeapSnapshot = $false
)

$ErrorActionPreference = "Continue"

# ---- Set defaults based on analysis type ----
$suffix = switch ($AnalysisType) { "CPU" { "CPU" } "Memory" { "Mem" } "CPUMemory" { "Full" } }
if ($Duration -le 0) {
    $Duration = switch ($AnalysisType) { "CPU" { 30 } "Memory" { 60 } "CPUMemory" { 90 } }
}

# Configure CLR and Kernel events per analysis type
switch ($AnalysisType) {
    "Memory" {
        $ClrEvents = "GC+Stack"
        # Must include VirtualAlloc for unmanaged (C++) memory analysis
        $KernelEvents = "Process,Thread,ImageLoad,VirtualAlloc,VAMap"
    }
    "CPUMemory" {
        $ClrEvents = "Default"
        $KernelEvents = "Default"
    }
    default {
        $ClrEvents = "Default"
        $KernelEvents = "Default"
    }
}

# ---- Step 0: Tool Detection ----
$detectScript = Join-Path $PSScriptRoot "perfview_detect.ps1"
$detectResult = $null

if (Test-Path $detectScript) {
    $detectJson = & $detectScript 2>$null
    if ($detectJson) {
        try { $detectResult = $detectJson | ConvertFrom-Json } catch {}
    }
}

if ($detectResult -and $detectResult.perfview_path) {
    if (-not $PerfViewPath) { $PerfViewPath = $detectResult.perfview_path }
    if (-not $XperfPath -and $detectResult.xperf_available) { $XperfPath = $detectResult.xperf_path }
}

# Fallback search for PerfView
if (-not $PerfViewPath -or -not (Test-Path $PerfViewPath)) {
    $fallbackRoots = @()
    foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Where-Object Root)) {
        $fallbackRoots += (Join-Path $drive.Root "PerfView\PerfView.exe")
    }
    $fallbackRoots += "$env:USERPROFILE\Desktop\PerfView\PerfView.exe"
    $fallbackRoots += "$env:USERPROFILE\Downloads\PerfView\PerfView.exe"
    foreach ($p in $fallbackRoots) {
        if (Test-Path $p) { $PerfViewPath = $p; break }
    }
}

if (-not $PerfViewPath -or -not (Test-Path $PerfViewPath)) {
    Write-Host "ERROR: PerfView.exe not found."
    Write-Host "Download from: https://github.com/microsoft/perfview/releases"
    exit 1
}

# Fallback search for xperf
if (-not $XperfPath -or -not (Test-Path $XperfPath)) {
    # Check PATH
    try {
        $found = Get-Command xperf.exe -ErrorAction SilentlyContinue
        if ($found) { $XperfPath = $found.Source }
    } catch {}
    # Check common install locations
    if (-not $XperfPath -or -not (Test-Path $XperfPath)) {
        $pf86 = [Environment]::GetFolderPath("ProgramFilesX86")
        $pf = [Environment]::GetFolderPath("ProgramFiles")
        $xperfSearch = @(
            "$pf86\Windows Kits\10\Windows Performance Toolkit\xperf.exe",
            "$pf\Windows Kits\10\Windows Performance Toolkit\xperf.exe"
        )
        foreach ($r in $xperfSearch) {
            if (Test-Path $r) { $XperfPath = $r; break }
        }
    }
}

$xperfAvailable = ($XperfPath -and (Test-Path $XperfPath))

Write-Host "============================================"
Write-Host " PERFVIEW 分析: $AnalysisType"
Write-Host "============================================"
Write-Host "PerfView : $PerfViewPath"
Write-Host "xperf    : $(if($xperfAvailable){$XperfPath}else{'未找到'})"
Write-Host "分析类型 : $AnalysisType"
Write-Host "采集时长 : ${Duration}s"
Write-Host "CLR 事件 : $ClrEvents"
Write-Host "内核事件 : $KernelEvents"
Write-Host "堆快照   : $(if($HeapSnapshot){'是'}else{'否'})"
Write-Host "============================================"

# ---- Verify target ----
if ($TargetPid -gt 0) {
    $proc = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
    if (-not $proc) {
        Write-Host "错误: 未找到 PID 为 $TargetPid 的进程。"
        exit 1
    }
    Write-Host "[目标] $($proc.ProcessName).exe (PID: $TargetPid)"
    if (-not $TargetProcess) { $TargetProcess = $proc.ProcessName }
} elseif ($TargetProcess) {
    $procs = Get-Process -Name $TargetProcess -ErrorAction SilentlyContinue
    if (-not $procs) {
        Write-Host "错误: 未找到匹配 '$TargetProcess' 的进程。"
        exit 1
    }
    $TargetPid = $procs[0].Id
    Write-Host "[目标] $TargetProcess.exe (PID: $TargetPid, $($procs.Count) 个实例)"
} else {
    Write-Host "警告: 未指定目标进程，将采集系统级追踪数据。"
}

# ---- Prepare output ----
$baseName = if ($TargetProcess) { $TargetProcess } else { "System" }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$etlBase = Join-Path $OutputDir "${baseName}_${suffix}_${timestamp}"

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "[输出] 基础路径: $etlBase"
Write-Host ""

# ---- Ensure no existing trace is running ----
Write-Host "[PerfView] 正在停止已有的追踪会话..."
$null = & $PerfViewPath stop 2>&1
Start-Sleep -Seconds 2

# ---- Step 1: Start PerfView trace ----
$maxSec = $Duration + 15
$startArgs = @(
    "/DataFile=$etlBase.etl",
    "/MaxCollectSec:$maxSec",
    "/CpuSampleMSec:$CpuSampleMSec",
    "/KernelEvents=$KernelEvents",
    "/ClrEvents=$ClrEvents",
    "/CircularMB=10000",
    "/BufferSizeMB=4096",
    "/LogFile=$etlBase.log.txt",
    "/AcceptEula",
    "start"
)

Write-Host "[PerfView] 正在启动 ETW 追踪..."
Write-Host "  命令: $($startArgs -join ' ')"

$startOutput = & $PerfViewPath $startArgs 2>&1
Write-Host $startOutput

# PerfView is a GUI app — exit code is unreliable per SKILL.md guidance.
# Check log file for actual success/failure instead.
$logFile = "$etlBase.log.txt"
if (Test-Path $logFile) {
    $logContent = Get-Content $logFile -Raw
    if ($logContent -notmatch '(?i)success') {
        Write-Host "WARN: PerfView start may have failed — check $logFile" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARN: No log file generated — trace may not have started" -ForegroundColor Yellow
}

# ---- Step 2: Wait for collection ----
Write-Host "[采集] 等待 ${Duration} 秒数据采集..."
for ($i = 5; $i -le $Duration; $i += 5) {
    $remaining = $Duration - $i
    Write-Progress -Activity "PerfView ETW 采集 ($AnalysisType)" -Status "剩余 $remaining 秒" -PercentComplete (($i / $Duration) * 100)
    Start-Sleep -Seconds 5
}
Write-Progress -Activity "PerfView ETW 采集 ($AnalysisType)" -Completed

# ---- Optional: Heap Snapshot (memory mode only) ----
if ($HeapSnapshot -and $TargetPid -gt 0) {
    Write-Host ""
    Write-Host "[堆快照] 正在从 PID $TargetPid 拍摄 .NET 堆转储..."
    Write-Host "  注意: 这可能会暂停目标进程数秒。"

    $heapFile = "$etlBase`_heap.gcdump"
    # Correct CLI command is HeapSnapshot (per CommandLineArgs.cs:653), not heapdump
    $hsArgs = "/Process:$TargetPid /DataFile:$heapFile HeapSnapshot"
    $hsOutput = & $PerfViewPath $hsArgs 2>&1
    Write-Host $hsOutput
    if (Test-Path $heapFile) {
        Write-Host "  完成: 堆转储已保存至 $heapFile"
    } else {
        Write-Host "  警告: 堆转储可能未成功创建（请检查进程是否为 .NET）"
    }
}

# ---- Step 3: Stop trace ----
Write-Host ""
Write-Host "[PerfView] 正在停止追踪并合并数据..."
$stopArgs = @("/DataFile=$etlBase.etl", "stop")
$stopOutput = & $PerfViewPath $stopArgs 2>&1
if ($LASTEXITCODE -ne 0 -or $stopOutput -match 'ERROR|FAIL') {
    Write-Host "  WARN: $stopOutput" -ForegroundColor Yellow
} else {
    Write-Host $stopOutput
}

# ---- Check output ----
$etlZip = "$etlBase.etl.zip"
$etlFile = "$etlBase.etl"

if (-not (Test-Path $etlZip) -and -not (Test-Path $etlFile)) {
    Write-Host "错误: 未生成 ETL 文件。"
    Write-Host "请查看 $etlBase.log.txt 获取详情。"
    exit 1
}

$etlSize = if (Test-Path $etlZip) { (Get-Item $etlZip).Length } else { (Get-Item $etlFile).Length }
Write-Host "[数据] ETL 大小: $([math]::Round($etlSize/1MB,1)) MB"

# ---- Step 4: Generate Reports ----
Write-Host ""
Write-Host "============================================"
Write-Host " 报告生成"
Write-Host "============================================"

# ---- 4a: PerfView GCStats (for Memory and CPUMemory modes) ----
# Initialize all report path variables (prevent strict-mode errors)
$gcStatsFile = ""
$profileFile = ""
$cpudiskFile = ""
$gcEventsFile = ""
$heapFile = ""

if ($AnalysisType -eq "Memory" -or $AnalysisType -eq "CPUMemory") {
    Write-Host "[GCStats] 正在生成 GC 统计报告..."
    # Per UserCommands.cs:1139, GCStats generates etlFile.Replace('.etl', '.GCStats.html')
    $gcStatsHtml = "$etlBase.gcStats.html"
    $etlToUse = if (Test-Path "$etlBase.etl") { "$etlBase.etl" } else { $etlZip }
    try {
        # ⚠️ CLI模式禁用GCStats(需GUI事件循环,会无限阻塞):         & $PerfViewPath "UserCommand" "GCStats" $etlToUse 2>&1 | Out-Null
    } catch { }

    if (Test-Path $gcStatsHtml) {
            $gcStatsFile = $gcStatsHtml
        Write-Host "  完成: GCStats.html ($([math]::Round((Get-Item $gcStatsHtml).Length/1KB,1)) KB)"
    } else {
        Write-Host "  注意: GCStats HTML 未生成（可能需要 PerfView GUI Memory > GCStats）"
    }
}

# ---- 4b: xperf reports ----
if ($xperfAvailable) {
    # Extract ETL from zip if needed
    if ((Test-Path $etlZip) -and -not (Test-Path $etlFile)) {
        Write-Host "[解压] 正在解压 ETL 文件..."
        Expand-Archive -Path $etlZip -DestinationPath $OutputDir -Force
    }

    if (Test-Path $etlFile) {
        $step = 0
        $totalSteps = if ($AnalysisType -eq "Memory") { 3 } else { 4 }

        # CPU Profile per core (skip in pure memory mode if not needed)
        if ($AnalysisType -ne "Memory") {
            $step++
            Write-Host "[$step/$totalSteps] CPU 使用率分析..."
            $profileFile = "$etlBase`_profile.txt"
            & $XperfPath -i $etlFile -o $profileFile -a profile 2>&1 | Out-Null
            if (Test-Path $profileFile) {
                Write-Host "  OK ($([math]::Round((Get-Item $profileFile).Length/1KB,1)) KB)"
            }
        }

        # Process list
        $step++
        Write-Host "[$step/$totalSteps] 进程列表..."
        $processFile = "$etlBase`_process.txt"
        & $XperfPath -i $etlFile -o $processFile -a process 2>&1 | Out-Null
        if (Test-Path $processFile) {
            Write-Host "  OK ($([math]::Round((Get-Item $processFile).Length/1KB,1)) KB)"
        }

        # Stack analysis
        $step++
        Write-Host "[$step/$totalSteps] 堆栈分析..."
        $stackFile = "$etlBase`_stacks.html"
        $stackArgs = @("-i", $etlFile, "-o", $stackFile, "-a", "stack", "-butterfly", "20")
        if ($TargetPid -gt 0) {
            $stackArgs += @("-pid", "$TargetPid")
        } elseif ($TargetProcess) {
            $stackArgs += @("-process", $TargetProcess)
        }
        & $XperfPath $stackArgs 2>&1 | Out-Null
        if (Test-Path $stackFile) {
            Write-Host "  OK ($([math]::Round((Get-Item $stackFile).Length/1KB,1)) KB)"
        }

        # CPU/Disk activity (skip in memory mode)
        if ($AnalysisType -ne "Memory") {
            $step++
            Write-Host "[$step/$totalSteps] CPU/磁盘活动..."
            $cpudiskFile = "$etlBase`_cpudisk.txt"
            $cdOutput = & $XperfPath -i $etlFile -o $cpudiskFile -a cpudisk 2>&1
            if (Test-Path $cpudiskFile) {
                Write-Host "  OK ($([math]::Round((Get-Item $cpudiskFile).Length/1KB,1)) KB)"
            } else {
                Write-Host "  跳过: 未采集到 CSwitch 事件（请添加 /KernelEvents:Default+CSwitch）"
            }
        }

        # Dump GC events for Memory mode
        if ($AnalysisType -eq "Memory" -or $AnalysisType -eq "CPUMemory") {
            Write-Host "[扩展] 正在提取 GC 事件..."
            $gcEventsFile = "$etlBase`_GCEvents.txt"
            & $XperfPath -i $etlFile -o $gcEventsFile -a dumper -event "Microsoft-Windows-DotNETRuntime:10:Start" -event "Microsoft-Windows-DotNETRuntime:10:Stop" -event "Microsoft-Windows-DotNETRuntime:1:Start" -event "Microsoft-Windows-DotNETRuntime:1:Stop" 2>&1 | Out-Null
            if (Test-Path $gcEventsFile) {
                Write-Host "  完成: GCEvents.txt ($([math]::Round((Get-Item $gcEventsFile).Length/1KB,1)) KB)"
            }
        }
    }
}

# ---- Step 5: Summary ----
Write-Host ""
Write-Host "============================================"
Write-Host " 采集完成"
Write-Host "============================================"
Write-Host "输出路径: $etlBase"
Write-Host ""
Write-Host "=== 生成的文件 ==="
Get-ChildItem "$etlBase*" | ForEach-Object {
    $size = if ($_.Length -gt 1MB) { "$([math]::Round($_.Length/1MB,1)) MB" } else { "$([math]::Round($_.Length/1KB,1)) KB" }
    Write-Host "  $($_.Name) ($size)"
}

# Output summary JSON
$summary = [PSCustomObject]@{
    status            = "complete"
    analysis_type     = $AnalysisType
    duration_seconds  = $Duration
    target_pid        = $TargetPid
    target_process    = $TargetProcess
    etl_zip           = if (Test-Path $etlZip) { $etlZip } else { "" }
    etl_file          = if (Test-Path $etlFile) { $etlFile } else { "" }
    gcstats_report    = if ($gcStatsFile -and (Test-Path $gcStatsFile)) { $gcStatsFile } else { "" }
    profile_report    = if (Test-Path $profileFile) { $profileFile } else { "" }
    process_report    = if (Test-Path $processFile) { $processFile } else { "" }
    stack_report      = if (Test-Path $stackFile) { $stackFile } else { "" }
    cpudisk_report    = if (Test-Path $cpudiskFile) { $cpudiskFile } else { "" }
    gcevents_report   = if (Test-Path $gcEventsFile) { $gcEventsFile } else { "" }
    heap_dump         = if ($heapFile -and (Test-Path $heapFile)) { $heapFile } else { "" }
    log_file          = "$etlBase.log.txt"
}

Write-Host ""
$summary | ConvertTo-Json -Compress
exit 0
