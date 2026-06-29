<#
.SYNOPSIS
    多阶段 PerfView 内存采集脚本（非交互式批量采集，内部调用 perfview_unmanaged.ps1）

.DESCRIPTION
    按预定阶段顺序循环调用 perfview_unmanaged.ps1，每个阶段产出独立的 .etl.zip。
    适用于 CI/自动化场景或已知各阶段时长的批量采集。

    对于交互式多阶段采集（用户在每个阶段手动切换应用状态），
    推荐 LLM 编排模式：LLM 在聊天中按阶段逐个调用 perfview_unmanaged.ps1 -PhaseName。

.PARAMETER TargetPid
    目标进程 PID

.PARAMETER TargetProcess
    目标进程名称（用于输出文件命名）

.PARAMETER PhaseNames
    阶段名称列表，如 @("空方案","加载方案","运行检测")
    默认: @("空方案","加载方案","运行检测")

.PARAMETER PhaseDurations
    每个阶段的采集时长（秒），与 PhaseNames 一一对应
    默认: @(30, 30, 60)

.PARAMETER OutputDir
    输出目录，默认: $env:USERPROFILE\PerfView\Traces

.PARAMETER PerfViewPath
    PerfView.exe 路径，留空则自动检测

.PARAMETER CircularMB
    循环缓冲区大小（MB），默认 10000

.PARAMETER BufferSizeMB
    ETW 缓冲区大小（MB），默认 4096

.PARAMETER Cleanup
    自动删除原始 .etl 文件（保留 .etl.zip）

.PARAMETER StopOnError
    遇到错误时停止后续阶段（默认继续）

.EXAMPLE
    # 默认三阶段采集（每阶段 30s）
    .\perfview_multiphase.ps1 -TargetPid 86324 -TargetProcess "VisionMaster"

    # 自定义阶段和时长
    .\perfview_multiphase.ps1 -TargetPid 86324 -TargetProcess "VisionMaster" `
        -PhaseNames "空方案","加载方案","运行检测" `
        -PhaseDurations 60,120,180

    # 单阶段 CI 场景
    .\perfview_multiphase.ps1 -TargetPid 86324 -TargetProcess "VisionMaster" `
        -PhaseNames "压力测试" -PhaseDurations 300 -Cleanup
#>

param(
    [Parameter(Mandatory)]
    [int]$TargetPid,

    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9_. -]+$')]
    [string]$TargetProcess,

    [string[]]$PhaseNames = @("空方案", "加载方案", "运行检测"),

    [ValidateRange(5, 3600)]
    [int[]]$PhaseDurations = @(30, 30, 60),

    [string]$OutputDir = "$env:USERPROFILE\PerfView\Traces",

    [string]$PerfViewPath = "",

    [ValidateRange(64, 65536)]
    [int]$CircularMB = 10000,

    [ValidateRange(64, 8192)]
    [int]$BufferSizeMB = 4096,

    [switch]$Cleanup = $false,

    [switch]$StopOnError = $false
)

$ErrorActionPreference = "Continue"

# ---- Validate parameters ----
if ($PhaseNames.Count -ne $PhaseDurations.Count) {
    Write-Host "ERROR: PhaseNames count ($($PhaseNames.Count)) must match PhaseDurations count ($($PhaseDurations.Count))" -ForegroundColor Red
    exit 1
}

$totalPhases = $PhaseNames.Count
$totalDuration = ($PhaseDurations | Measure-Object -Sum).Sum
$totalWait = $totalDuration + ($totalPhases * 45)

# ---- Resolve unmanaged script path ----
$unmanagedScript = Join-Path $PSScriptRoot "perfview_unmanaged.ps1"
if (-not (Test-Path $unmanagedScript)) {
    Write-Host "ERROR: perfview_unmanaged.ps1 not found at $unmanagedScript" -ForegroundColor Red
    exit 1
}

# ---- Verify target process ----
$proc = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
if (-not $proc) {
    Write-Host "ERROR: Process PID $TargetPid not found." -ForegroundColor Red
    exit 1
}
Write-Host "Target: $($proc.ProcessName).exe (PID: $TargetPid)" -ForegroundColor Cyan

# ---- Prepare output directory ----
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# ---- Banner ----
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " PerfView Multi-Phase Collection" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Phases     : $totalPhases ($($PhaseNames -join ' → '))"
Write-Host "Durations  : $($PhaseDurations -join 's, ')s"
Write-Host "Total wait : ~${totalWait}s (collect: ${totalDuration}s + overhead: $($totalPhases * 45)s)"
Write-Host "Circular MB: ${CircularMB} MB"
Write-Host "Output Dir : $OutputDir"
Write-Host "============================================"
Write-Host ""

# ---- Phase execution ----
$phaseResults = @()
$overallStatus = "complete"
$startTime = Get-Date

for ($i = 0; $i -lt $totalPhases; $i++) {
    $phaseName = $PhaseNames[$i]
    $phaseDuration = $PhaseDurations[$i]
    $phaseNum = $i + 1

    # ---- Check process still alive ----
    $proc = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
    if (-not $proc) {
        Write-Host "ERROR: Process PID $TargetPid no longer exists (Phase $phaseNum/$totalPhases : $phaseName)" -ForegroundColor Red
        $phaseResults += @{
            phase_name   = $phaseName
            phase_index  = $phaseNum
            duration     = $phaseDuration
            status       = "failed"
            error        = "Process PID $TargetPid not found"
            etl_zip      = ""
            etl_size_mb  = 0
        }
        if ($StopOnError) { $overallStatus = "failed"; break } else { continue }
    }

    # ---- Banner for this phase ----
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host " Phase $phaseNum/$totalPhases : $phaseName" -ForegroundColor Yellow
    Write-Host " Duration : ${phaseDuration}s" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""

    # ---- Build args for perfview_unmanaged.ps1 ----
    $unmanagedArgs = @(
        "-TargetPid", $TargetPid,
        "-TargetProcess", $TargetProcess,
        "-Duration", $phaseDuration,
        "-PhaseName", $phaseName,
        "-CircularMB", $CircularMB,
        "-BufferSizeMB", $BufferSizeMB,
        "-OutputDir", $OutputDir,
        "-ErrorAction", "Continue"
    )

    if ($PerfViewPath) { $unmanagedArgs += @("-PerfViewPath", $PerfViewPath) }
    if ($Cleanup) { $unmanagedArgs += "-Cleanup" }

    # ---- Execute perfview_unmanaged.ps1 for this phase ----
    Write-Host "[$phaseNum/$totalPhases] Launching perfview_unmanaged.ps1 -PhaseName '$phaseName'..." -ForegroundColor Yellow

    $phaseJson = $null
    $phaseOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $unmanagedScript $unmanagedArgs 2>&1

    # Extract JSON from output (last line that parses as JSON)
    foreach ($line in $phaseOutput) {
        try {
            $candidate = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($candidate -and $candidate.status) {
                $phaseJson = $candidate
                break
            }
        } catch {}
    }

    # Determine phase result
    if ($phaseJson) {
        $phaseStatus = $phaseJson.status
        $etlZip = $phaseJson.etl_zip
        $etlSizeMb = $phaseJson.etl_size_mb
        $phaseError = ""

        Write-Host "  [$phaseStatus] $etlZip ($etlSizeMb MB)" -ForegroundColor $(if ($phaseStatus -eq 'complete') { 'Green' } else { 'Red' })
    } else {
        $phaseStatus = "failed"
        $etlZip = ""
        $etlSizeMb = 0
        $phaseError = "Failed to parse output from perfview_unmanaged.ps1"
        Write-Host "  [FAIL] $phaseError" -ForegroundColor Red
        if ($StopOnError) { $overallStatus = "failed"; break }
    }

    # ---- Record phase result ----
    $phaseResults += @{
        phase_name   = $phaseName
        phase_index  = $phaseNum
        duration     = $phaseDuration
        status       = $phaseStatus
        error        = $phaseError
        etl_zip      = $etlZip
        etl_size_mb  = $etlSizeMb
    }
}

# ---- Cleanup ----
if ($Cleanup) {
    Write-Host ""
    Write-Host "[Cleanup] Removing raw .etl files generated during this run..." -ForegroundColor Yellow
    Get-ChildItem $OutputDir -Filter "*.etl" | Where-Object {
        $_.Name -notmatch '\.zip$' -and $_.LastWriteTime -gt $startTime
    } | ForEach-Object {
        # Only clean files matching our target process
        if ($_.Name -match [regex]::Escape($TargetProcess)) {
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            Write-Host "  Removed: $($_.Name)"
        }
    }
}

# ---- Final summary ----
$endTime = Get-Date
$elapsedTime = [math]::Round(($endTime - $startTime).TotalMinutes, 1)
$completed = ($phaseResults | Where-Object { $_.status -eq 'complete' }).Count
$failed = ($phaseResults | Where-Object { $_.status -eq 'failed' }).Count

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Multi-Phase Collection Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Elapsed    : ${elapsedTime} min"
Write-Host "Phases     : $totalPhases ($completed completed, $failed failed)"
Write-Host ""

foreach ($r in $phaseResults) {
    $icon = if ($r.status -eq 'complete') { '[OK]' } else { '[FAIL]' }
    Write-Host "  $icon Phase $($r.phase_index): $($r.phase_name) ($($r.duration)s) → $($r.etl_size_mb) MB"
    if ($r.error) {
        Write-Host "      Error: $($r.error)" -ForegroundColor Red
    }
}

# ---- Output summary JSON ----
$summary = [PSCustomObject]@{
    status           = $overallStatus
    target_pid       = $TargetPid
    target_process   = $TargetProcess
    total_phases     = $totalPhases
    phases_completed = $completed
    phases_failed    = $failed
    elapsed_min      = $elapsedTime
    output_dir       = $OutputDir
    phases           = $phaseResults
}

$summary | ConvertTo-Json -Compress -Depth 3

if ($failed -eq $totalPhases) { exit 1 }
elseif ($failed -gt 0) { exit 2 }
else { exit 0 }
