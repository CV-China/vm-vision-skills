<#
.SYNOPSIS
    采集 VTune 热点数据并生成 CSV 报告。支持附加模式（分析运行中进程）
    和启动模式（在 VTune 分析下启动进程 — Pin 附加被阻止时的备选方案）。
.DESCRIPTION
    必须以管理员身份运行。处理 SW/HW 采样、PMU 兼容性降级、SEP 驱动检查，
    并生成 CSV 报告（summary、hotspots、callstacks，当 AnalysisType 为
    "hotspots-memory" 时还包括内存报告）。
.PARAMETER TargetPid
    要分析的进程 ID（附加模式，除非使用 -LaunchMode 时为必需）。
.PARAMETER LaunchMode
    切换到启动模式分析。在 VTune 下启动目标 exe。
    当 Pin 附加失败时使用（"Failed to write probes in process"）。
.PARAMETER TargetExe
    要启动的可执行文件完整路径（-LaunchMode 时必需）。
.PARAMETER TargetDir
    启动进程的工作目录（默认为 exe 所在目录）。
.PARAMETER TargetArgs
    传递给启动的可执行文件的可选参数。
.PARAMETER AnalysisType
    "hotspots"（仅 CPU，默认）或 "hotspots-memory"（CPU + 内存对象）。
.PARAMETER Duration
    采集时长（秒），默认 120，可由用户自定义。设为 0 为手动停止模式。
.PARAMETER OutputDir
    结果和报告的输出目录（默认：~/Desktop/vtune_result）。
.PARAMETER Mode
    采样模式："sw"（软件，默认）或 "hw"（硬件 PMU）。
.PARAMETER KillTarget
    （仅启动模式）采集时长到达后，先终止目标进程再取消采集。
    用于绕过 Pin 脱钩失败导致结果目录损坏的问题。
    适用于受保护进程（反篡改、.NET AOT 等）。
.PARAMETER VtunePath
    vtune.exe 的路径。如不指定则自动检测。
.EXAMPLE
    .\vtune_collect.ps1 -TargetPid 12345
    .\vtune_collect.ps1 -TargetPid 12345 -AnalysisType hotspots-memory -Duration 120
    .\vtune_collect.ps1 -LaunchMode -TargetExe "C:\Program Files\App\App.exe" -Duration 120
    .\vtune_collect.ps1 -LaunchMode -TargetExe "C:\Path\App.exe" -Duration 120 -KillTarget
#>

param(
    [Parameter(ParameterSetName="Attach",Mandatory=$true)]
    [int]$TargetPid,

    [Parameter(ParameterSetName="Launch",Mandatory=$true)]
    [switch]$LaunchMode,

    [Parameter(ParameterSetName="Launch",Mandatory=$true)]
    [string]$TargetExe,

    [Parameter(ParameterSetName="Launch")]
    [string]$TargetDir = "",

    [Parameter(ParameterSetName="Launch")]
    [string]$TargetArgs = "",

    [ValidateSet("hotspots","hotspots-memory")]
    [string]$AnalysisType = "hotspots",

    [ValidateRange(0,3600)]
    [int]$Duration = 120,

    [string]$OutputDir = "$env:USERPROFILE\Desktop\vtune_result",

    [ValidateSet("sw","hw")]
    [string]$Mode = "sw",

    [Parameter(ParameterSetName="Launch")]
    [switch]$KillTarget,

    [string]$VtunePath = ""
)

$ErrorActionPreference = "Continue"

# ---- 强制管理员权限检查 ----
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[Admin] Insufficient permissions, auto-elevating..."
    $myPath = $MyInvocation.MyCommand.Path
    # 重建参数字符串（排除空参数和默认值）
    $argParts = @()
    if ($LaunchMode) { $argParts += "-LaunchMode" }
    if ($TargetPid -and $TargetPid -ne 0) { $argParts += "-TargetPid $TargetPid" }
    if ($TargetExe) { $argParts += "-TargetExe `"$TargetExe`"" }
    if ($TargetDir) { $argParts += "-TargetDir `"$TargetDir`"" }
    if ($TargetArgs) { $argParts += "-TargetArgs `"$TargetArgs`"" }
    if ($KillTarget) { $argParts += "-KillTarget" }
    $argParts += "-AnalysisType $AnalysisType"
    $argParts += "-Duration $Duration"
    $argParts += "-OutputDir `"$OutputDir`""
    $argParts += "-Mode $Mode"
    if ($VtunePath) { $argParts += "-VtunePath `"$VtunePath`"" }

    $rebuiltArgs = $argParts -join ' '
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$myPath`" $rebuiltArgs"
    $psi.UseShellExecute = $true
    $psi.Verb = "runas"
    $psi.WindowStyle = "Normal"
    try {
        $p = [System.Diagnostics.Process]::Start($psi)
        if (-not $p.WaitForExit(120000)) {
            Write-Host "[Admin] Elevation timed out (120s). Trying to continue..."
            $p.Kill()
        }
        exit $p.ExitCode
    } catch {
        Write-Host "[管理员] 提权失败：$($_.Exception.Message)"
        Write-Host "[管理员] 请右键以管理员身份运行此脚本。"
        exit 1
    }
}
Write-Host "[管理员] 权限验证通过。"

# ---- 步骤 0：PMU 兼容性 & VTune 检测 ----
$detectScript = Join-Path $PSScriptRoot "vtune_detect.ps1"
$detectResult = $null

if (Test-Path $detectScript) {
    $detectJson = & $detectScript 2>$null
    if ($detectJson) {
        try { $detectResult = $detectJson | ConvertFrom-Json } catch {}
    }
}

if ($detectResult -and $detectResult.vtune_path) {
    $VtunePath = $detectResult.vtune_path
    $pmuCompatible = $detectResult.pmu_compatible
    $pmuReason = $detectResult.pmu_reason
    $cpuName = $detectResult.cpu_name
    $cpuMicroarch = $detectResult.cpu_microarchitecture
    $vtuneVersion = $detectResult.vtune_version
} else {
    # Fallback: inline search with full root set (aligned with vtune_detect.ps1)
    if (-not $VtunePath) {
        $roots = @(
            "C:\Program Files (x86)\Intel\oneAPI\vtune",
            "D:\Program Files (x86)\Intel\oneAPI\vtune",
            "C:\Program Files\Intel\oneAPI\vtune",
            "D:\Program Files\Intel\oneAPI\vtune"
        )
        foreach ($r in $roots) {
            if (Test-Path $r) {
                $latest = Get-ChildItem $r -Directory | Where-Object { $_.Name -match '^\d{4}\.\d+' } | Sort-Object Name -Descending | Select-Object -First 1
                if ($latest) {
                    $candidate = Join-Path $latest.FullName "bin64\vtune.exe"
                    if (Test-Path $candidate) { $VtunePath = $candidate; break }
                }
            }
        }
    }
    $pmuCompatible = $true
    $pmuReason = ""
    try {
        $cpuName = (Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1).Name
    } catch {
        $cpuName = "Unknown (WMI unavailable)"
    }
    $cpuMicroarch = "未知"
    $vtuneVersion = "未知"
}

if (-not $VtunePath -or -not (Test-Path $VtunePath)) {
    Write-Host "错误：未找到 VTune。"
    exit 1
}

Write-Host "============================================"
Write-Host " 系统信息"
Write-Host "============================================"
Write-Host "VTune     : $vtuneVersion ($VtunePath)"
Write-Host "CPU       : $cpuName"
Write-Host "微架构    : $cpuMicroarch"
Write-Host "PMU 硬件  : $(if($pmuCompatible){'兼容'}else{'不兼容'})"
if (-not $pmuCompatible) { Write-Host "           : $pmuReason" }
Write-Host "============================================"

# ---- 步骤 0.5：PMU 降级 ----
if (-not $pmuCompatible) {
    if ($AnalysisType -eq "hotspots-memory") {
        Write-Host ""
        Write-Host "警告：hotspots-memory 需要硬件 PMU 事件进行"
        Write-Host "内存分析，但此 CPU（$cpuMicroarch）不支持。"
        Write-Host "降级为仅 CPU 热点分析。"
        Write-Host "内存消耗和内存访问报告将不会生成。"
        $AnalysisType = "hotspots"
    }
    if ($Mode -eq "hw") {
        Write-Host ""
        Write-Host "警告：请求了 HW 采样模式但 PMU 不兼容。"
        Write-Host "降级为 SW（软件）采样模式。"
        $Mode = "sw"
    }
}
Write-Host ""

# ---- 验证目标 ----
if ($LaunchMode) {
    if (-not (Test-Path $TargetExe)) {
        Write-Host "错误：未找到目标可执行文件：$TargetExe"
        exit 1
    }
    if (-not $TargetDir) { $TargetDir = Split-Path $TargetExe -Parent }
    Write-Host "[目标] 启动：$TargetExe"
    Write-Host "[工作目录] $TargetDir"
    if ($TargetArgs) { Write-Host "[参数] $TargetArgs" }
} else {
    $proc = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
    if (-not $proc) {
        Write-Host "错误：未找到 PID 为 $TargetPid 的进程。"
        exit 1
    }
    Write-Host "[目标] $($proc.ProcessName).exe (PID: $TargetPid)"
}

# ---- 检查/安装 SEP 驱动 ----
$sepDrv = sc.exe query sepdrv5 2>&1
if ($LASTEXITCODE -ne 0 -or $sepDrv -match "1060") {
    Write-Host "[SEP] 驱动未安装。正在安装..."
    $sepReg = Join-Path (Split-Path $VtunePath -Parent) "amplxe-sepreg.exe"
    if (Test-Path $sepReg) {
        # Already admin, no need for runas verb
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $sepReg
        $psi.Arguments = "-i"
        $psi.UseShellExecute = $false
        $psi.WindowStyle = "Normal"
        $p = [System.Diagnostics.Process]::Start($psi)
        if (-not $p.WaitForExit(30000)) {
            Write-Host "[SEP] Driver install timed out (30s). Continuing..."
            $p.Kill()
        }
        if ($p.ExitCode -eq 0) {
            Write-Host "[SEP] 驱动安装成功。"
        } else {
            Write-Host "[SEP] 驱动安装返回退出码 $($p.ExitCode)。继续执行..."
        }
    } else {
        Write-Host "[SEP] 在 $sepReg 未找到 amplxe-sepreg.exe。继续执行..."
    }
} else {
    Write-Host "[SEP] 驱动已安装。"
}

# ---- 准备输出 ----
$resultDir = $OutputDir
$reportDir = "$OutputDir`_report"

# Validate output path safety — refuse to delete root-level or system directories
$dangerousPaths = @("C:\", "C:\Windows", "C:\Program Files", "C:\Program Files (x86)", "D:\", "E:\")
$safeToDelete = $true
foreach ($dp in $dangerousPaths) {
    $resolvedResult = (Resolve-Path $resultDir -ErrorAction SilentlyContinue).Path
    $resolvedReport = (Resolve-Path $reportDir -ErrorAction SilentlyContinue).Path
    if (($resolvedResult -and $resolvedResult.TrimEnd('\') -eq $dp.TrimEnd('\')) -or
        ($resolvedReport -and $resolvedReport.TrimEnd('\') -eq $dp.TrimEnd('\'))) {
        Write-Host "[ERROR] Refusing to delete system directory: $dp"
        Write-Host "[ERROR] Please specify a different -OutputDir."
        exit 1
    }
}
# Also refuse if resultDir is a bare drive root (e.g., "C:\", "D:")
# Explicit dangerous-paths list above handles safety; this catches bare root paths only
$normalizedPath = $resultDir.TrimEnd('\')
$depth = ($normalizedPath -split '\\').Count
if ($depth -lt 2) {
    Write-Host "[ERROR] Output directory cannot be a bare drive root: $resultDir"
    Write-Host "[ERROR] Please specify a subdirectory (e.g., E:\vtune_result)"
    exit 1
}

# Clean previous run (if exists)
if (Test-Path $resultDir) { Remove-Item -Recurse -Force $resultDir }
if (Test-Path $reportDir) { Remove-Item -Recurse -Force $reportDir }

# Create output directories (including all missing parent dirs)
New-Item -ItemType Directory -Path $resultDir -Force | Out-Null
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

Write-Host "[目录] 结果：$resultDir"
Write-Host "[目录] 报告：$reportDir"

# ---- 构建 VTune 参数 ----
# 对于包含空格的路径，使用内嵌双引号的单字符串命令行更可靠。
# 基于数组的 -ArgumentList 会错误地分割类似 "C:\Program Files\..." 的路径。
$vtuneArgs = "-collect hotspots -knob sampling-mode=$Mode -knob enable-characterization-insights=false -result-dir `"$resultDir`""

# Duration=0 表示手动停止（无限采集）
if ($Duration -gt 0) {
    $vtuneArgs += " -duration $Duration"
} else {
    Write-Host "[模式] 手动停止 — 采集一直运行直到 'vtune -command stop'"
}

# hotspots-memory 模式时添加内存对象分析开关
if ($AnalysisType -eq "hotspots-memory") {
    $vtuneArgs += " -knob analyze-mem-objects=true"
}

# 附加模式：添加 target-pid
# 启动模式：使用 -- <exe> 语法（不要用 -target-process，那是按名称附加用的）
if ($LaunchMode) {
    $vtuneArgs += " -- `"$TargetExe`""
    if ($TargetArgs) { $vtuneArgs += " $TargetArgs" }
} else {
    $vtuneArgs += " -target-pid $TargetPid"
}

if ($Duration -gt 0) {
    Write-Host "[采集] 类型=$AnalysisType, 模式=$Mode, 时长=${Duration}秒"
} else {
    Write-Host "[采集] 类型=$AnalysisType, 模式=$Mode, 时长=手动"
}
Write-Host "[采集] 开始采集..."

$collectStart = Get-Date

if ($LaunchMode -and $KillTarget) {
    # ---- KillTarget mode: background collection + wait for confirmation + timed kill + cancel ----
    $targetName = (Split-Path $TargetExe -Leaf) -replace '\.exe$', ''

    # Build manual-duration args (override duration to 0 for background collection)
    # Reconstruct args cleanly instead of fragile regex replacement on collected string
    $killVtuneArgs = "-collect hotspots -knob sampling-mode=$Mode -knob enable-characterization-insights=false -result-dir `"$resultDir`""
    if ($AnalysisType -eq "hotspots-memory") {
        $killVtuneArgs += " -knob analyze-mem-objects=true"
    }
    $killVtuneArgs += " -duration 0"
    $killVtuneArgs += " -- `"$TargetExe`""
    if ($TargetArgs) { $killVtuneArgs += " $TargetArgs" }

    Write-Host "[KillTarget] Starting background collection (manual mode)..."
    $vtuneProc = Start-Process -FilePath $VtunePath -ArgumentList $killVtuneArgs -NoNewWindow -PassThru

    # Add launch log for Agent verification (step 1d)
    $launchLog = Join-Path $OutputDir "vtune_launch_log.txt"
    "Launch started: $(Get-Date)" | Out-File $launchLog -Encoding UTF8
    "Target: $TargetExe" | Out-File $launchLog -Append -Encoding UTF8
    "ResultDir: $resultDir" | Out-File $launchLog -Append -Encoding UTF8
    "ReportDir: $reportDir" | Out-File $launchLog -Append -Encoding UTF8
    "VTunePID: $($vtuneProc.Id)" | Out-File $launchLog -Append -Encoding UTF8

    # Wait for user confirmation signal before starting the timer
    $signalFile = "$OutputDir\confirm.txt"
    Write-Host "[KillTarget] $targetName launched. VTune collection running in background."
    Write-Host "[KillTarget] Waiting for confirmation signal ($signalFile)..."
    "Collection started: $(Get-Date)" | Out-File $launchLog -Append -Encoding UTF8
    Write-Host "[KillTarget] Please notify Agent once the target workload has begun."
    Write-Host "[KillTarget] Agent will create confirm.txt to trigger the timed collection window."
    $waitStart = Get-Date
    $maxWait = 300  # 5 minutes timeout for user to confirm
    $timedOut = $false
    while (-not (Test-Path $signalFile)) {
        Start-Sleep -Seconds 2
        # Check if VTune process is still alive
        if ($vtuneProc -and $vtuneProc.HasExited) {
            Write-Host "[KillTarget] VTune process exited unexpectedly (exit code: $($vtuneProc.ExitCode))."
            Write-Host "[KillTarget] Aborting wait — check VTune output above for errors."
            exit 1
        }
        if (((Get-Date) - $waitStart).TotalSeconds -gt $maxWait) {
            Write-Host "[KillTarget] Wait timed out (${maxWait}s). No confirmation received."
            $timedOut = $true
            break
        }
    }
    if ($timedOut) {
        Write-Host "[KillTarget] Cancelling collection — no user confirmation within timeout."
        & $VtunePath -r $resultDir -command cancel 2>&1 | Out-File "$OutputDir\cancel_log.txt"
        Write-Host "[KillTarget] Partial results (startup phase only) may be available at: $resultDir"
        exit 1
    }
    if (Test-Path $signalFile) {
        Write-Host "[KillTarget] Confirmation signal received. Starting ${Duration}s collection window..."
        Remove-Item $signalFile -Force
    }

    # Wait for the configured duration (from confirmation point)
    Start-Sleep -Seconds $Duration

    # Kill the target process first (before VTune tries to detach)
    Write-Host "[KillTarget] Terminating $targetName processes..."
    $procs = Get-Process -Name $targetName -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force
        Write-Host "[KillTarget] Terminated $($procs.Count) process(es)"
    } else {
        Write-Host "[KillTarget] Process already exited"
    }

    # Wait for process cleanup
    Start-Sleep -Seconds 5

    # Cancel VTune collection (no process to detach from = clean finalize)
    Write-Host "[KillTarget] Cancelling VTune collection (no detach needed)..."
    $cancelOutput = & $VtunePath -r $resultDir -command cancel 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[KillTarget] Cancel warning (may be already finalized): $($cancelOutput -join '; ')"
    }

    # Wait for VTune to finish finalizing
    if ($vtuneProc -and (-not $vtuneProc.HasExited)) {
        Write-Host "[KillTarget] Waiting for VTune to finalize..."
        if (-not $vtuneProc.WaitForExit(60000)) {
            Write-Host "[KillTarget] VTune finalize timed out (60s). Killing..."
            $vtuneProc.Kill()
        }
    } elseif (-not $vtuneProc) {
        Write-Host "[KillTarget] Warning: VTune process handle was null. Checking results directly..."
    }
    $collectElapsed = (Get-Date) - $collectStart
    Write-Host "[Collection] KillTarget completed in $([math]::Round($collectElapsed.TotalSeconds,1))s"
} else {
    # ---- Standard mode: wait for VTune with timeout ----
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $VtunePath
    $psi.Arguments = $vtuneArgs
    $psi.UseShellExecute = $false
    $psi.WindowStyle = "Normal"
    $collect = [System.Diagnostics.Process]::Start($psi)
    if (-not $collect) {
        Write-Host "[ERROR] Failed to start VTune process."
        exit 1
    }
    # Wait up to ($Duration + 120) seconds for VTune to finish (grace period for finalization).
    # For manual stop mode (Duration=0), allow up to 3600s (1 hour) since user explicitly
    # requested indefinite collection until they say "stop".
    if ($Duration -eq 0) {
        $timeoutSeconds = 3600
    } else {
        $timeoutSeconds = [Math]::Max($Duration + 120, 300)
    }
    if (-not $collect.WaitForExit($timeoutSeconds * 1000)) {
        Write-Host "[ERROR] VTune process timed out after ${timeoutSeconds}s. Killing..."
        $collect.Kill()
        $collectElapsed = (Get-Date) - $collectStart
        Write-Host "[Collection] Killed after timeout — partial data may be available"
    } else {
        $collectElapsed = (Get-Date) - $collectStart
        Write-Host "[Collection] Completed in $([math]::Round($collectElapsed.TotalSeconds,1))s (exit code: $($collect.ExitCode))"
    }
}

# ---- 检查采集结果 ----
$dataDir = Join-Path $resultDir "data.0"
if (-not (Test-Path $dataDir)) {
    Write-Host "[错误] 未采集到数据。正在检查日志..."
    $logFiles = Get-ChildItem "$resultDir\log" -Filter "perfrun*.log" -ErrorAction SilentlyContinue
    if ($logFiles) {
        Write-Host "--- $($logFiles[-1].Name) 的最后 10 行 ---"
        Get-Content $logFiles[-1].FullName | Select-Object -Last 10
    }
    exit 1
}

$dataFileCount = (Get-ChildItem $dataDir -File).Count
Write-Host "[数据] data.0 中有 $dataFileCount 个文件"

# ---- 生成报告（CSV 格式）----
Write-Host "[Report] Generating CSV reports (type=$AnalysisType)..."

# Create error log for report generation diagnostics
$reportErrorLog = "$reportDir\report_errors.log"

# Build report list based on analysis type
$reportList = @(
    @{Name="summary.csv"; Type="summary"},
    @{Name="hotspots.csv"; Type="hotspots"},
    @{Name="callstacks.csv"; Type="callstacks"}
)

if ($AnalysisType -eq "hotspots-memory") {
    $reportList += @(
        @{Name="memory-consumption.csv"; Type="memory-consumption"},
        @{Name="top-down.csv"; Type="top-down"}
    )
}

$step = 0
$total = $reportList.Count
foreach ($r in $reportList) {
    $step++
    Write-Host "  [$step/$total] $($r.Name)..."
    $errOut = & $VtunePath -report $r.Type -result-dir $resultDir -format csv -csv-delimiter comma -report-output "$reportDir\$($r.Name)" 2>&1
    if (-not (Test-Path "$reportDir\$($r.Name)")) {
        # Fallback: try without -report-output (older VTune versions)
        Write-Host "    -> -report-output failed, trying pipe fallback..."
        "  [$step/$total] $($r.Name) - report-output fallback" | Out-File $reportErrorLog -Append -Encoding UTF8
        $errOut = & $VtunePath -report $r.Type -result-dir $resultDir -format csv -csv-delimiter comma 2>&1
        $errOut | Out-File -FilePath "$reportDir\$($r.Name)" -Encoding UTF8
    }
    if ($LASTEXITCODE -ne 0 -or $errOut -match "Error|error|failed") {
        "$(Get-Date) [$($r.Name)] $($errOut -join '; ')" | Out-File $reportErrorLog -Append -Encoding UTF8
    }
}

# ---- 生成 HTML 可视化报告 ----
Write-Host "[Report] Generating HTML visualization reports..."

$htmlReports = @(
    @{Name="summary.txt";      Type="summary";       Desc="Collection summary"},
    @{Name="hotspots.html";    Type="hotspots";      Desc="Hotspot functions"},
    @{Name="callgraph.html";   Type="callstacks";    Desc="Call stacks"}
)

foreach ($hr in $htmlReports) {
    Write-Host "  $($hr.Desc) ($($hr.Name))..."
    $errOut = & $VtunePath -report $hr.Type -result-dir $resultDir -report-output "$reportDir\$($hr.Name)" 2>&1
    if ($LASTEXITCODE -ne 0 -or $errOut -match "Error|error|failed") {
        "$(Get-Date) [$($hr.Name)] $($errOut -join '; ')" | Out-File $reportErrorLog -Append -Encoding UTF8
    }
    if (Test-Path "$reportDir\$($hr.Name)") {
        $sz = (Get-Item "$reportDir\$($hr.Name)").Length
        Write-Host "     -> $([math]::Round($sz/1KB,1)) KB"
    } else {
        Write-Host "     -> Not generated (no data or error)"
    }
}

# ---- 检查报告质量 ----
$reportFiles = $reportList | ForEach-Object { $_.Name }
$allOk = $true
foreach ($rf in $reportFiles) {
    $path = Join-Path $reportDir $rf
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        Write-Host "  $rf : $([math]::Round($size/1KB,1)) KB"
        if ($size -lt 100) { $allOk = $false }
    } else {
        Write-Host "  $rf : 缺失"
        $allOk = $false
    }
}

# ---- CSV 预览（解析表头 + 前几行）----
Write-Host ""
Write-Host "==========================================="
Write-Host "  CSV 预览"
Write-Host "==========================================="

function Show-CsvPreview {
    param([string]$FilePath, [string]$Title, [int]$MaxRows = 15)
    if (-not (Test-Path $FilePath)) { return }
    Write-Host "--- $Title ---"
    $lines = Get-Content $FilePath -Encoding UTF8 -TotalCount ($MaxRows + 1)
    # 过滤 VTune 日志行（以 "vtune:" 开头的行）
    $dataLines = $lines | Where-Object { $_ -notmatch '^vtune:' -and $_.Trim() -ne '' }
    $shown = 0
    foreach ($line in $dataLines) {
        if ($shown -eq 0) {
            # 表头行 — 高亮显示
            Write-Host "  表头: $($line.Substring(0, [Math]::Min(200, $line.Length)))..."
        } elseif ($shown -le $MaxRows) {
            Write-Host "  $line"
        }
        $shown++
    }
    if ($shown -gt $MaxRows + 1) {
        Write-Host "  ... （共 $($dataLines.Count - 1) 行数据）"
    }
    Write-Host ""
}

Show-CsvPreview -FilePath "$reportDir\summary.csv" -Title "摘要" -MaxRows 8
Show-CsvPreview -FilePath "$reportDir\hotspots.csv" -Title "热点函数" -MaxRows 10

Write-Host ""
Write-Host "==========================================="
if ($allOk) {
    Write-Host "  SUCCESS — Report directory: $reportDir"
} else {
    Write-Host "  PARTIAL — Some reports are empty or missing. Check: $reportDir"
    if (Test-Path $reportErrorLog) {
        Write-Host "  Error log: $reportErrorLog"
        Write-Host "--- Report errors ---"
        Get-Content $reportErrorLog -ErrorAction SilentlyContinue | Select-Object -Last 10
        Write-Host "--- End ---"
    }
}
Write-Host "==========================================="

if (-not $allOk) { exit 2 }
exit 0
