---
name: vtune-analyzer
description: >
  使用 Intel VTune Profiler 对 Windows 进程进行自动化性能分析。当用户需要分析运行中进程、
  分析 CPU 热点、分析内存使用/带宽/对象、查找性能瓶颈，或使用 VTune 了解应用程序耗时
  分布时使用此技能。触发词："profile <进程>"、"分析 <X> 的性能"、"查找 <X> 的热点"、
  "VTune 分析"、"VTune 内存"、"hotspots memory"、"为什么 <X> 慢"、"CPU 分析"、
  "内存分析"、"性能瓶颈"。此技能处理完整的自动化流程 — VTune 检测、SEP 驱动、管理员
  提权、PMU 兼容性降级、Pin 附加失败自动切换到启动模式、采集、CSV 报告，以及一份
  全面的 Markdown 分析报告 — 用户无需手动点击 UI 或调试工具问题。
---

# VTune 分析器 — 自动化性能分析

**⚠️ 语言要求：执行此技能时，Agent 必须全程使用中文与用户对话。**
所有提示、确认问题、进度报告、分析结果均须以中文呈现。

使用 Intel VTune Profiler 对 Windows 运行中进程进行性能分析。此技能自动处理所有
设置（驱动安装、管理员提权、CPU 兼容性），并生成用户可直接阅读的文本报告。

## 概览

- **目标**：任意 Windows 进程 — 可附加到运行中进程（PID）或在分析下启动（exe 路径）。当 Pin 无法附加时，启动模式为备选方案。
- **分析类型**：`hotspots`（CPU 时间/函数）或 `hotspots-memory`（CPU + 内存对象）。默认：hotspots。软件采样，默认 120 秒（可由用户自定义）。
- **输出**：CSV 文件（逗号分隔，UTF-8）+ 综合 **Markdown 报告**，包含热点函数、热点模块、关键发现和建议。输出位置在采集开始前始终与用户确认。
- **输出目录结构**：如果用户指定 `-OutputDir "E:\vtune_result"`，则：
  - `E:\vtune_result\` — 原始 VTune 采集结果（~30-50 MB，可删除）
  - `E:\vtune_result_report\` — 报告目录（CSV + HTML + MD），脚本自动在 OutputDir 后追加 `_report` 后缀
  - 步骤 7 清理时删除原始目录，保留 `_report` 目录
- **依赖**：需安装 Intel VTune 2025+（自动检测）

## 工作流

### 决策流程图

```
用户指定目标进程
       │
       ▼
  ┌─────────────────┐
  │ 步骤 0: 环境检测 │
  │ VTune 安装?      │── 否 ──→ 提供安装选项 (A/B)，停止
  │ PMU 兼容?        │
  │ ⚠ 提醒管理员bash │
  └────────┬────────┘
           │ 是
           ▼
  ┌─────────────────┐
  │ 步骤 1: 进程检查 │ ── 先于一切
  │ 进程已在运行?    │
  └───┬──────┬──────┘
      │ 是    │ 否
      ▼       ▼
  ┌──────┐  ┌──────────────────┐
  │ 用户  │  │ 步骤 2: 查 exe   │
  │ 确认  │  │ 注册表→磁盘搜索   │
  └─┬──┬─┘  └────────┬─────────┘
    │  │              │
    │  └─ 残留实例    │
    │     清理进程    │
    │      ↓         │
    │     查 exe ────┘
    │               │
    ▼               ▼
  ┌─────────────────────┐
  │ 步骤 3: 确认参数     │
  │ 输出路径/时长/类型   │
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ 步骤 4: SEP 驱动     │
  │ 检查 + 安装(如需)    │
  └────────┬────────────┘
           ▼
  ┌──────────────────────────┐
  │ 步骤 5: 运行采集          │
  │ ┌──────────────────┐     │
  │ │ 附加模式 (PID)    │     │
  │ │ 或                │     │
  │ │ 启动模式 (exe)    │     │
  │ │ ⚠ .NET → 启动优先 │     │
  │ └──────────────────┘     │
  └────────┬─────────────────┘
           ▼
  ┌─────────────────────┐
  │ 步骤 6: 生成报告     │
  │ MD + CSV + HTML     │
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ 步骤 7: 清理         │
  │ 删原始结果/临时脚本  │
  │ 保留报告目录         │
  └─────────────────────┘
```

### 步骤 0 — 环境检测（自动）

**0a — 检查管理员权限并提醒用户：**

VTune 采集**必须**以管理员身份运行（Pin 注入 .NET 进程必需）。Agent 在启动任何
工作流之前，应提醒用户：

> ⚠️ **强烈建议：以管理员身份启动 Claude Code / 终端。**
> 右键点击终端图标 → "以管理员身份运行"，再进入 Claude Code。
> 
> 如果 bash shell 本身是管理员：
> - `vtune_collect.ps1` 检测到已有管理员权限，**零 UAC 弹窗**，全程静默执行
> 
> 如果 bash shell 不是管理员：
> - 每次运行 `vtune_collect.ps1` 都会触发一次 UAC 弹窗要求提权
> - 这是 Windows 安全模型的要求，无法从非管理员上下文静默提权
> 
> N 次独立采集 = N 次 UAC 弹窗。以管理员身份启动整个会话是最佳实践。

**0b — PMU 兼容性检测：**

捆绑的 `vtune_detect.ps1` 同时检测本机 CPU 是否支持 VTune 硬件 PMU 事件采样。
它识别 CPU 微架构并与 VTune 已知数据库进行比对。

**PMU 不兼容的情况：**
- CPU 为 Comet Lake 或更早的 Skylake 代际客户端 CPU（i7-10875H、i7-9750H 等）
  → VTune 2025+ 仅支持 Ice Lake (10nm) 及更新的客户端 CPU 进行硬件 PMU 采样
- CPU 为 AMD（Ryzen、EPYC）→ VTune 硬件 PMU 仅支持 Intel
- 在无 PMU 透传的虚拟机中运行

**自动降级：**
- `hotspots-memory` → 自动降级为 `hotspots`（仅 CPU）
- `hw` 采样模式 → 自动降级为 `sw`（软件采样）
- 控制台会打印明确的警告信息

技能仍会继续进行，软件采样可普遍正常工作。

如果 VTune CLI 不在 PATH 中，运行 `scripts/vtune_detect.ps1`。
此脚本搜索标准安装根目录（与 `vtune_detect.ps1` 中的搜索路径完全一致）：

- `C:\Program Files (x86)\Intel\oneAPI\vtune\`
- `D:\Program Files (x86)\Intel\oneAPI\vtune\`
- `C:\Program Files\Intel\oneAPI\vtune\`
- `D:\Program Files\Intel\oneAPI\vtune\`

选取找到的最新版本并返回 `vtune.exe` 的路径。

#### 当 VTune 未安装时

如果 `vtune_detect.ps1` 返回空结果或在所有标准路径下都找不到 `vtune.exe`，
**立即停止 VTune 工作流**，并向用户提供两个明确的选项：

---

**选项 A — 安装 VTune（推荐，适合重复使用）**

Intel VTune Profiler 免费（本地分析无需许可证）：

1. 下载安装包（二选一）：
   - **官方下载**（较慢）：https://www.intel.com/content/www/us/en/developer/tools/oneapi/vtune-profiler.html
   - **内部高速下载**（推荐）：https://drive.ticklink.com/disk/fileDownload?link=fUcSuk5M& 提取码：`f8V6`
2. 运行安装程序 — 选择 "VTune Profiler" 组件（基础安装约 2 GB）
3. 安装完成后重新开始此对话或重新调用此技能

预计安装时间：10–20 分钟（取决于网络速度）。

---

**选项 B — 使用 Windows Performance Recorder（需安装 Windows ADK，无额外费用）**

Windows 自带内核级分析器，无需安装、无需进程注入（基于 ETW，适用于包括反篡改保护的任何进程）：

```powershell
# 1. 开始对特定进程进行 CPU 采样录制（30 秒，环形缓冲区）
wpr -start CPU -filemode memory -start GeneralProfile -recordtempto C:\temp

# 2. 等待所需时长后停止
timeout /t 30
wpr -stop C:\Users\<user>\Desktop\profile.etl

# 3. 将 ETL 转换为 CSV 进行分析
xperf -i C:\Users\<user>\Desktop\profile.etl -o C:\Users\<user>\Desktop\profile.csv -a dumper
```

与 VTune 相比的局限：
- 免费转换器无法获取每函数 CPU 时间或调用栈
- 需要 Windows Performance Toolkit（`wpr`/`xperf`），需通过 Windows ADK 单独安装（非 Windows 基础镜像自带）
- 细节不如 VTune，但零配置、普遍可用

---

通过 `AskUserQuestion` 展示这些选项让用户选择。如果 VTune 未安装，不要继续 VTune 流程。

### 步骤 1 — 进程状态检查（优先于一切）

**Agent 接收到分析目标后，第一时间检查进程是否已在运行，再决定后续路径。**

> ⚠️ **为什么进程检查必须在查找 exe 路径之前？**
> 进程是否已在运行决定了完全不同的后续策略：
> - 已在运行 → 直接用 PID 附加采集，**不需要查找 exe 路径**
> - 未运行 → 才需要查找 exe 路径，用启动模式采集
> 先去查 exe 路径再来看进程状态是浪费时间，且附加模式下 exe 路径根本用不上。

#### 1a — 检查目标进程及子进程是否已存在

```powershell
# 同时检查目标进程和已知子进程
$targetName = "<进程名>"
$childNames = @("<子进程1>", "<子进程2>")  # 如 'AwakenGpuTool','vServerApp'
$allNames = @($targetName) + $childNames

Get-Process -Name $allNames -ErrorAction SilentlyContinue |
    Select-Object Name, Id, StartTime
```

#### 1b — 决策分支

检查结果决定后续流程：

| 场景 | 处理方式 | 后续步骤 |
|------|---------|---------|
| **进程已运行 — 用户正在使用中**（已加载方案/项目） | 确认后 → **附加模式**（步骤 5） | 直接转到步骤 5，用 `-TargetPid <PID>` 附加 |
| **进程已运行 — 上次采集残留** | **自动清理** → 查找 exe 路径 → 启动模式 | 转到步骤 1c 清理，再转到步骤 2 查 exe 路径 |
| **进程未运行** | 查找 exe 路径 → 启动模式 | 转到步骤 2 查 exe 路径 |
| **残留子进程仍在运行**（主进程已退出） | **自动清理** | 转到步骤 1c 清理 |

**Agent 必须向用户确认：** 如果进程已在运行，询问这是正在使用的会话还是残留实例。
不要自作主张杀掉用户正在使用的进程。

#### 1c — 清理残留进程（含子进程）

如果目标进程是残留实例（或用户确认可以终止），执行清理：

**关键**：很多应用会启动子进程（如 VisionMaster 的 `AwakenGpuTool.exe`、`vServerApp.exe`）。这些子进程如不清理，
主进程退出后它们可能继续运行并阻止下次启动。务必一起终止。

清理步骤：
```powershell
# 1. 终止目标进程及其已知子进程
$childProcesses = @('<子进程1>', '<子进程2>')  # 如 'AwakenGpuTool','vServerApp'
Get-Process -Name @('<进程名>') + $childProcesses -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. 等待进程完全退出
Start-Sleep -Seconds 3

# 3. 清理上次可能残留的结果目录和临时文件
Remove-Item -Recurse -Force "<OutputDir>" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "<OutputDir>_report" -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\Desktop\vtune_*.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\Desktop\vtune_*_log.txt" -Force -ErrorAction SilentlyContinue

# 4. 验证清理完成（含子进程）
$remaining = Get-Process -Name @('<进程名>') + $childProcesses -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host "警告：仍有残留进程，需要手动处理"
} else {
    Write-Host "环境已清理，准备启动"
}
```

> **为什么这么重要？** 今天第二次采集时，VisionMaster PID 77948（昨天 KillTarget 后的残留）仍然存活。
> VTune 通过 `-- <exe>` 启动的新实例（PID 70472）检测到已有实例，2.5 秒后干净退出（exit code 0），
> VTune 随即 finalize，采集窗口仅 2 秒，120 秒视觉流程数据完全丢失。清理后才成功。
> 此外，VTune 输出 `Profiling of the target process finished but the following child processes are still being profiled`
> 表明子进程（AwakenGpuTool、vServerApp）在父进程退出后仍存活，必须一并清理。

#### 1d — 验证进程已成功启动（启动模式后续）

在管理员脚本启动后约 10-15 秒，Agent 检查 `$OutputDir\vtune_launch_log.txt`（由 `vtune_collect.ps1` 在 KillTarget 模式下自动创建），确认：
1. 日志中包含 `Collection started` — 采集已开始
2. 日志中**没有** `profiled application was terminated` — 无异常退出
3. `Get-Process` 确认目标进程正在运行

如果检测到异常退出（如 exit code 0），立即报告用户并读取 `perfrun*.log` 排查原因。

> **注意**：`vtune_launch_log.txt` 仅在 `-KillTarget` 模式下创建。标准模式（非 KillTarget）下，Agent 应通过检查进程列表和 VTune 输出直接验证。

### 步骤 2 — 查找目标 exe 路径（仅在进程未运行时执行）

**此步骤仅在步骤 1 确认进程未运行（或已清理残留后需要重新启动）时才执行。**
如果进程已在运行且采用附加模式，跳过此步骤。

#### 2a — 通过注册表查找（优先，最可靠）

对于已安装的 Windows 应用程序，注册表比磁盘搜索更快、更可靠。按以下顺序查找：

**方法 1：AssemblyFoldersEx（.NET 应用，含版本号）**
```powershell
# 路径：HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\AssemblyFoldersEx\<应用名>
# 对于 64-bit 应用也检查：HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\AssemblyFoldersEx\<应用名>
```

此键提供：
- `(Default)` — 安装路径（可能是子目录，需向上推导根目录）
- `CurrentVersion` — 精确版本号（如 `4.4.0`）

**方法 2：Uninstall 注册表键（最通用）**
```powershell
$uninstallPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)
foreach ($path in $uninstallPaths) {
    Get-ChildItem $path -ErrorAction SilentlyContinue | Where-Object {
        (Get-ItemProperty $_.PSPath).DisplayName -like '*<应用名>*'
    } | ForEach-Object {
        $props = Get-ItemProperty $_.PSPath
        # $props.DisplayName, $props.DisplayVersion, $props.UninstallString
    }
}
```

- `UninstallString` 提供 exe 路径（如 `C:\Program Files\App\uninstall.exe`），由此推导根目录
- `DisplayVersion` 提供版本号

**从安装根目录推导主 exe：** 常见模式为 `<Root>\Applications\<AppName>.exe` 或 `<Root>\bin\<AppName>.exe`。

**方法 3：磁盘搜索（兜底，较慢）**
```powershell
Get-ChildItem -Path 'C:\Program Files', 'C:\Program Files (x86)', 'D:\', 'E:\' `
    -Filter '<AppName>.exe' -Recurse -ErrorAction SilentlyContinue -Depth 5 |
    Select-Object -First 5 FullName
```

> **注意**：磁盘搜索含中文路径时可能产生编码乱码（bash → PowerShell 管道），注册表方式无此问题。

仅在注册表均未找到时使用磁盘搜索。找到路径后告知用户确认。

### 步骤 3 — 确认输出位置

**始终向用户询问报告文件保存位置。** 不要在没有确认的情况下假定默认位置。
使用 `AskUserQuestion` 向用户展示选项：

- 默认：`~/Desktop/vtune_<进程名>_report/`
- 自定义：用户可以输入任意路径

**自定义路径处理**：如果用户提供自定义路径，按原样接受。
采集脚本通过 `New-Item -Force` 自动创建完整目录树（包括所有缺失的父目录）。
无需手动验证或 `mkdir` 步骤。

同时确认：
- **分析类型**：`hotspots`（仅 CPU）或 `hotspots-memory`（CPU + 内存对象）
- 采集时长（默认 120 秒，可由用户自定义）
- 采集后是否保留或删除原始结果目录（可能 30+ MB）

仅在用户确认所有参数后才进入步骤 4。

### 步骤 4 — 检查/安装 SEP 驱动

VTune 的采样启用产品（SEP）驱动必须安装才能进行硬件事件采样。检查方法：

```powershell
sc.exe query sepdrv5 2>&1
# 退出码 0   → 驱动已安装且正在运行
# 退出码 1060 → 驱动未安装（ERROR_SERVICE_DOES_NOT_EXIST）
# 其他非零退出码 → 驱动已安装但未启动（需手动启动或重新安装）
```

如果驱动缺失（退出码 1060），安装它（`vtune_collect.ps1` 已内置此步骤，含 30 秒超时保护）：

```powershell
# 脚本内部直接调用 amplxe-sepreg.exe -i（无额外 runas，因已管理员运行）
```

安装后会自动用 `sc.exe query sepdrv5` 验证。

### 步骤 5 — 运行采集 + 报告脚本

使用捆绑的 `scripts/vtune_collect.ps1` 脚本。**必须以管理员身份运行**，
因为 Pin 插桩引擎在 Windows 上需要管理员权限才能附加到进程。
**脚本已内置自动提权逻辑**：以非管理员身份运行时，会自动触发 UAC 弹窗重启自身。

> ⚠️ **严禁以非管理员身份运行采集。** 非管理员模式会导致：
> - VTune 无法分析 .NET 托管代码（"Cannot profile the managed part"）
> - Pin 注入受限，采样数据质量严重下降
> - 热点数据中等待/休眠函数占比异常偏高（>80%），掩盖真实业务逻辑
>
> 脚本会自动检测并提权——Agent 无需手动编写提权包装脚本。

脚本接受的关键参数：
- `-TargetPid <PID>` — 要分析的进程（附加模式，除非使用 `-LaunchMode` 时为必需）
- `-LaunchMode` — 切换到启动模式分析（在 VTune 下启动目标 exe）
- `-TargetExe <路径>` — 要启动的可执行文件（`-LaunchMode` 时必需）
- `-TargetDir <路径>` — 启动模式的工作目录（默认为 exe 所在目录）
- `-TargetArgs <参数>` — 传递给启动的可执行文件的可选参数
- `-AnalysisType hotspots` — `hotspots`（仅 CPU，默认）或 `hotspots-memory`（CPU + 内存对象）
- `-Duration 120` — 采集时长（秒），默认 120，可由用户自定义。设为 **0** 为手动停止（一直采集直到 `vtune -command stop`）。
- `-OutputDir <路径>` — 结果和报告保存位置（默认桌面）
- `-Mode sw` — 采样模式：`sw`（软件，默认）或 `hw`（硬件 PMU）

**默认使用 SW 采样的原因：** VTune 2025.10 在某些 CPU 上存在 PMU 检测 bug
（在 Intel i7-10875H 上观察到），生成的 `--pmu-type` 值为空，
导致 `amplxe-runss.exe` 解析失败。使用 SW 采样配合
`enable-characterization-insights=false` 可绕过此问题。仅在确认 CPU
兼容时才使用 HW 模式。

#### 附加模式（默认 — 目标已在运行）

Agent 写入包装 `.ps1` 文件直接调用采集脚本（脚本会**自动提权**）：

**仅热点分析（默认）：**
```powershell
# wrapper.ps1 内容：
$skillDir = "$env:USERPROFILE\.claude\skills\vtune-analyzer\scripts"
& "$skillDir\vtune_collect.ps1" -TargetPid <PID> -AnalysisType hotspots -Duration 120 -OutputDir "<输出目录>"
```

**热点 + 内存对象：**
```powershell
# wrapper.ps1 内容：
$skillDir = "$env:USERPROFILE\.claude\skills\vtune-analyzer\scripts"
& "$skillDir\vtune_collect.ps1" -TargetPid <PID> -AnalysisType hotspots-memory -Duration 120 -OutputDir "<输出目录>"
```

#### ⚠️ .NET 托管代码采集局限性

**附加模式下，即使以管理员身份运行，VTune 也可能无法分析 .NET 托管代码。**
本次采集 VisionMaster 时就遇到了此问题——管理员附加模式下仍提示：

> `vtune: Warning: Cannot profile the managed part of the target process. Internal error.`

**这意味着：**
- 仅 **Native C/C++ 代码**被采样（如 `mvb_cnn_x64_cpu.dll`、`MVD_Algorithm.dll`）
- **.NET 托管代码**（C#/WPF 业务逻辑层）完全不可见
- `clr.dll` 自身函数可见，但 C# 方法调用链不可见
- 报告会偏向底层计算（CNN 推理占 90%+），看不到高层业务模块触发关系

**根本原因分析：**
- 附加模式：Pin 注入到**已运行**的 .NET 进程时，CLR 已初始化完毕，Pin 可能无法注册
  CLR 托管代码回调，导致仅能采样原生栈帧
- 启动模式：Pin 在 CLR 初始化**之前**注入，可以正常注册 .NET JIT 编译回调，
  理论上能完整采样托管代码

**应对策略（按优先级）：**

| 策略 | 方法 | 适用场景 |
|------|------|---------|
| **启动模式（推荐）** | 在 VTune 下启动进程，Pin 在 CLR 初始化前注入 | .NET 应用首选，可完整采样托管+原生代码 |
| **附加模式 + 接受局限** | 仅关注原生 DLL 性能（如 CNN 推理、图像处理） | 分析重点在 Native 层，不需 C# 调用链 |
| **PerfView 互补** | 使用 PerfView（ETW 内核级）对同一 .NET 进程进行托管代码分析 | 需要完整 .NET 托管代码调用栈 |

> **Agent 须知**：如果用户在附加模式下得到 "Cannot profile the managed part" 警告，
> 应在报告中明确标注此局限性（见步骤 6 报告模板的"注意事项"部分），
> 并建议下次使用启动模式重新采集以获得完整 .NET 托管代码数据。

#### 启动模式（备选 — Pin 附加失败时，或进程尚未运行时的默认模式）

当 Pin 插桩引擎无法附加到运行中进程（错误：
`Failed to write probes in process, can't complete attach!`），使用启动模式。
VTune 在分析下启动目标进程，在任何保护初始化之前注入 Pin。

**启动模式现在是需要加载方案/项目的应用的默认模式。** Agent 在步骤 1 中自动
检查进程状态并清理残留进程后，在步骤 5 中使用 LaunchMode 自动启动目标进程 —
用户无需手动启动应用。

**⚠️ 关键 — 方案/项目就绪：** 许多应用程序（VisionMaster、IDA Pro、Visual Studio 等）
需要用户在应用程序启动后加载项目、打开 .sol 方案文件并运行视觉流程。
如果方案尚未加载，采集只能捕获启动开销（DLL 加载、UI 初始化），而非实际业务逻辑。

**在启动之前，始终向用户询问：**

> "我将先启动 <应用名>。如果需要加载方案/项目文件，请在启动后完成加载并开始工作流程。
>  工作流程开始执行后告诉我，我再开始计时采集数据。"

**交互确认流程（重要）：**

1. Agent 在步骤 1 中检查进程状态：确认是否已运行、是否为残留
2. 如为残留 → Agent 自动清理（含子进程），确认环境干净
3. 如进程未运行 → Agent 在步骤 2 中查找 exe 路径
4. Agent 自动以 LaunchMode + KillTarget 启动管理员脚本（启动进程 + VTune 后台采集）
5. Agent 等待 10-15 秒后验证日志：确认 `Collection started` 且无异常退出
6. Agent 确认方案加载需求，确定采集时长（默认 120 秒，用户可自定义）
7. 用户加载 .sol 方案文件，运行视觉流程
8. **用户确认"视觉流程已开始执行"** ← 交互确认点，此时 Agent 开始计时
9. Agent 从确认点起等待用户指定的采集时长（如 120 秒）
10. 计时到达后停止采集（`-KillTarget` 模式杀进程+cancel，或正常 cancel）
11. Agent 生成报告

> **为什么要用 `-KillTarget` 模式？**
> 因为无法预知用户何时加载完方案并确认。KillTarget 模式以 `-duration 0`（手动模式）在后台启动采集，
> 等待 Agent 创建 `confirm.txt` 信号文件后才开始计时，确保采集时长精确覆盖工作流程运行阶段。
> 
> **重要**：虽然 Agent 传递 `-Duration 120`，但脚本内部会将其覆盖为 `-duration 0`（手动模式），
> 实际的 120 秒计时从信号文件检测到后才开始（`Start-Sleep -Seconds $Duration`）。
> 启动阶段 + 方案加载 + 工作流程运行 + $Duration 秒的业务逻辑 — 全部被覆盖。

**⚠️ KillTarget 模式路径限制**：`-OutputDir` 必须是**纯 ASCII 路径**。

实战验证：PowerShell 脚本（`vtune_collect.ps1`）在 bash → PowerShell 调用链中，含中文的
`-OutputDir` 参数会被损坏为乱码（如 `CPU分析` → `CPU鍒嗘瀽`），导致：
- 脚本创建的实际目录名乱码，与 Agent 后续操作的目录不一致
- `confirm.txt` 信号文件路径不匹配——Agent 创建在正确路径，脚本监听在乱码路径
- 采集等待超时（300s），120s 检测窗口完全浪费

采集前 Agent 必须检查 `-OutputDir` 为纯 ASCII。若含非 ASCII 字符，自动替换为
ASCII 安全路径（如 `CPU_Analysis/raw`）并警告用户。

**采集时长的计时起点：**
- 默认 120 秒**从用户确认"视觉流程已开始执行"时开始计算**，而非从进程启动时计算。

根据方案加载需求设置采集时长：
- **不需要加载方案 / 仅分析启动**：采集 120 秒（默认），从进程启动时计时
- **需要加载 .sol 方案并运行视觉流程**：采集 120 秒（默认），**从用户确认视觉流程已开始时计时**
- **手动停止模式**：VTune 一直采集，直到视觉流程完成后用户通知停止
- 采集时长始终可由用户自定义，默认为 120 秒

**基于方案的应用的典型工作流（含进程检查+清理+启动验证）：**

```
0. Agent 运行 vtune_detect.ps1 → VTune 已安装，PMU 不兼容 → SW 降级
1. Agent 检查进程：Get-Process VisionMaster（含子进程 AwakenGpuTool/vServerApp）
   → 发现残留 PID xxx → 向用户确认后 Stop-Process -Force → 验证无残留 ✓
2. Agent 查找 exe 路径：注册表/磁盘搜索 → 找到路径（首次分析时执行，后续可从已知路径推断）
3. Agent 确认参数：输出路径、时长 120s、hotspots
4. Agent："我将先启动 VisionMaster。请加载 .sol 方案并运行视觉流程，
   视觉流程开始执行后告诉我，我再开始计时采集 120 秒。"
5. Agent 以 -LaunchMode -TargetExe <路径> -Duration 120 -KillTarget 启动管理员脚本
6. 等待 10-15s → 检查日志：Collection started ✓，无异常终止 ✓
7. VisionMaster 启动（PID 新），用户加载 .sol 文件，运行视觉流程
8. 用户确认："视觉流程已开始执行"
9. Agent 创建 confirm.txt → 脚本开始 120s 计时
10. 120 秒后脚本自动 Kill 进程 + cancel，生成报告
11. Agent 读取报告 — 涵盖了启动 + 方案加载 + 视觉流程运行阶段
```

> **关键决策点**：步骤 1 决定了后续全部流程。
> - 进程已在运行且是用户正在使用的 → 跳过步骤 2，直接用 PID 附加模式采集
> - 进程未运行 / 是残留实例 → 步骤 2 查找 exe，然后用启动模式采集

#### Pin 脱钩失败应对（受保护进程）

某些受保护进程（带反篡改、.NET AOT、杀毒软件注入等）即使使用启动模式，
在采集结束时 Pin 也无法正常脱钩。错误表现为：

```
vtune: Error: [Instrumentation Engine]: NotifyDetachComplete: 483:
Failed to remove probes from process, detach can't be completed
vtune: Collection failed.
```

此错误会**损坏结果目录**，导致后续报告生成失败（`0x4000002c Invalid result directory`）。

**应对策略：先杀目标进程，再 cancel 采集。**

这可以绕过 Pin 的探针移除失败——进程已死，Pin 无需脱钩，结果目录正常终结。

**修改后的工作流（使用确认信号文件）：**

```
0. Agent 运行 vtune_detect.ps1 → VTune 安装状态和 PMU 兼容性
1. Agent 检查进程状态（步骤 1）→ 清理残留（如有）→ 查找 exe 路径（如需要）
2. Agent 确认需求后，以 -Duration 120 -KillTarget 启动管理员脚本
3. VisionMaster 启动，VTune 开始后台采集
4. 脚本进入等待状态：轮询检查 OutputDir 下的 confirm.txt 信号文件
5. 用户加载 .sol 文件，运行视觉流程
6. 用户确认："视觉流程已开始执行"
7. Agent 创建信号文件（New-Item confirm.txt），脚本检测到后开始计时 120 秒
8. 计时到达后脚本自动 Kill VisionMaster → cancel → 生成报告
```

**实现方式**：使用 `vtune_collect.ps1` 的 `-KillTarget` 参数。

`-KillTarget` 开关的工作机制：
1. 以 `-duration 0`（手动模式）启动 VTune 后台采集
2. 等待 `$OutputDir\confirm.txt` 信号文件出现（最长等待 5 分钟）
3. 检测到信号文件后，开始计时用户指定的 `-Duration` 秒
4. 计时到达后 `Stop-Process -Force` 终止目标进程
5. `vtune -command cancel` 终结结果目录（此时进程已死，Pin 无需脱钩）
6. 正常生成 CSV 和 HTML 报告

**Agent 需要执行的操作：**

```powershell
# 步骤 1：写入包装 .ps1 文件，直接调用采集脚本（脚本自动提权）
# wrapper.ps1 内容：
$skillDir = "$env:USERPROFILE\.claude\skills\vtune-analyzer\scripts"
& "$skillDir\vtune_collect.ps1" -LaunchMode -TargetExe "C:\路径\到\App.exe" -TargetDir "C:\路径\到" -AnalysisType hotspots -Duration 120 -KillTarget -OutputDir "E:\vtune_result"

# bash 调用：
powershell.exe -ExecutionPolicy Bypass -File wrapper.ps1

# 步骤 2：等待用户确认"视觉流程已开始执行"

# 步骤 3：用户确认后，创建信号文件触发采集计时
# NOTE: The signal file must be created in $OutputDir (same as -OutputDir value), NOT a hardcoded path
New-Item -Path "<OutputDir>\confirm.txt" -Force
```

**注意**：此方式获取的是**启动 + 方案加载 + 视觉流程运行**数据。因进程在结束时被强制终止，
最后时刻的少量采样数据可能丢失。对于稳态分析，这是可接受的代价。

**命令（含方案就绪时长）：**
```powershell
# wrapper.ps1 内容 — 直接调用，脚本自动提权：
$skillDir = "$env:USERPROFILE\.claude\skills\vtune-analyzer\scripts"
& "$skillDir\vtune_collect.ps1" -LaunchMode -TargetExe "C:\路径\到\App.exe" -TargetDir "C:\路径\到" -AnalysisType hotspots -Duration 120 -OutputDir "<输出目录>"
```

**命令（手动停止 — 一直采集直到被告知停止）：**
```powershell
# wrapper.ps1 内容 — 步骤 1：以 -Duration 0 启动（无限运行）：
$skillDir = "$env:USERPROFILE\.claude\skills\vtune-analyzer\scripts"
& "$skillDir\vtune_collect.ps1" -LaunchMode -TargetExe "C:\路径\到\App.exe" -TargetDir "C:\路径\到" -AnalysisType hotspots -Duration 0 -OutputDir "<输出目录>"

# 步骤 2：当用户说"停止"时，发送停止命令
vtune -r <结果目录> -command stop
```

脚本使用 `--` 分隔 VTune 参数和目标可执行文件 —
对于包含空格的路径至关重要。如果目标需要参数，通过 `-TargetArgs` 传递。

#### Shell 最佳实践（Bash → PowerShell）

从此环境的 bash shell 调用 PowerShell 时：

1. **⚠️ 任何含 `$` 的 PowerShell 代码都必须写入 `.ps1` 文件** — 不仅仅是大段脚本。
   bash 会将 `$_`、`$var`、`$props` 等所有 `$` 前缀词当作 bash 变量吞掉，
   即使使用单引号包裹也会出现不可预期的行为。**即使是看似简单的单行命令，只要包含
   `Where-Object`、`ForEach-Object`、`Select-Object` 等用到 `$_` 的 cmdlet，
   也必须通过 `.ps1` 文件 + `-File` 调用。**
   
   **典型失败案例（今天遇到）：**
   ```powershell
   # ❌ 以下命令在 bash 调用时 $_ 被吞，产生 "extglob.PSChildName: command not found" 错误
   powershell.exe -Command "Get-ChildItem HKLM:\... | Where-Object { $_.PSChildName -like '*Vision*' }"
   
   # ✅ 正确做法：写入 .ps1 文件，通过 -File 调用
   # powershell.exe -File search.ps1
   ```
   
   总结：**切勿使用 `-Command` 嵌入任何含 `$` 字符的 PowerShell 代码。**
   始终将脚本写入 `.ps1` 文件并通过 `-File` 调用。

2. **管理员提权 — 推荐做法：bash shell 本身以管理员身份启动**

   **最佳实践（零 UAC 弹窗）：** 在启动 bash shell 时直接以管理员身份运行。
   这样 `vtune_collect.ps1` 检测到已有管理员权限，跳过 UAC 弹窗，全程静默执行。
   
   具体操作：右键点击终端/shell → "以管理员身份运行"，再启动 Claude Code。
   
   **备选方案（会出现 UAC 弹窗）：** 如果 bash shell 不是管理员，
   `vtune_collect.ps1` 启动时会自动检测权限不足，通过
   `System.Diagnostics.Process` + `Verb = "runas"` 触发 UAC 弹窗。
   Agent 只需直接调用脚本即可：
   ```powershell
   # Agent 写入包装 .ps1 文件，bash 一句调用：
   powershell.exe -ExecutionPolicy Bypass -File wrapper.ps1
   ```
   **无需再用 `Start-Process -Verb RunAs` 包装。** 之前的嵌套 `-Command` +
   `Start-Process` 方式容易因参数转义问题导致 UAC 弹窗不出现（已验证失败）。
   
   > ⚠️ **每次采集需要一次 UAC 交互**：如果 bash shell 不是管理员且进行 N 次独立
   > 采集，每次 `vtune_collect.ps1` 调用都会触发一次 UAC 弹窗。
   > 推荐以管理员身份启动整个 Claude Code 会话来避免此问题。

3. **引用含空格的路径** — 当以编程方式构建 VTune 参数列表时，
   使用内嵌双引号的单字符串参数行比 `-ArgumentList` 数组更可靠：
   ```powershell
   # 好：内嵌引号的单字符串
   $args = "-collect hotspots -result-dir `"$resultDir`" -- `"$TargetExe`""
   Start-Process -FilePath $vtuneExe -ArgumentList $args -Wait -NoNewWindow

   # 有风险：带空格的数组元素可能被错误分割
   $args = @("-result-dir", $resultDir, "--", $TargetExe)  # 含空格的路径：失败
   ```

4. **在顶层 .ps1 包装脚本中定义所有变量** — 不要在 bash 中通过 `-Command` 传递变量。
   将所有路径、参数等都在 `.ps1` 文件中硬编码或计算得出，bash 仅负责一句
   `powershell.exe -File wrapper.ps1` 的调用。

5. **⚠️ .ps1 文件内容必须使用纯 ASCII/英文** — 从 bash 写入 `.ps1` 文件时，
   **严禁在脚本内容中使用中文字符**。bash → PowerShell 的字符编码路径会导致
   中文在 `.ps1` 文件中变成乱码（如 `发现子进�?$name`），引发 ParserError 解析失败。
   
   **典型失败案例（今天遇到）：**
   ```powershell
   # ❌ .ps1 文件中包含中文 — bash 写入后编码损坏
   Write-Host "发现子进程 $name: PID=$($p.Id)"   # 乱码 → ParserError
   Write-Host "需要清理: YES"                      # 乱码 → 字符串未终止错误
   
   # ✅ .ps1 文件全部使用英文
   Write-Host "Found child $name : PID=$($p.Id)"
   Write-Host "Cleanup needed: YES"
   ```
   
   总结：**.ps1 文件内容 = 纯英文**（注释、Write-Host 文本、变量名全部英文）。
   面向用户的最终输出（Markdown 报告、聊天消息）可以用中文，
   但传给 PowerShell 的脚本文件本身不能包含任何非 ASCII 字符。

6. **临时脚本使用唯一文件名** — 桌面上的临时 `.ps1` 文件可能在多次会话间残留。
   Agent 写入新脚本时应使用带用途的明确文件名（如 `vtune_check_vm.ps1`），
   并在步骤 7 清理时统一删除，避免不同会话的脚本互相覆盖导致 "file not read" 错误。
   
   推荐命名模式：`vtune_<操作>_<进程名>.ps1`（如 `vtune_check_VisionMaster.ps1`,
   `vtune_wrapper_VisionMaster.ps1`）。

**重要：** 采集和报告生成必须在**同一个**管理员会话中完成。
如果在不同会话中运行，非管理员会话无法读取管理员拥有的结果文件
（"权限不足" / "无法重新终结只读结果"）。

### 报告产出

| 分析类型 | 报告文件 |
|---------|---------|
| `hotspots` | `summary.csv`、`hotspots.csv`、`callstacks.csv` |
| `hotspots-memory` | 以上全部 + `memory-consumption.csv`、`top-down.csv` |
| **全部** | 以下 HTML 可视化报告 + 综合 Markdown 报告 |

**HTML/文本可视化报告（所有类型均生成）：**

| 报告 | 命令 | 说明 |
|------|------|------|
| `summary.txt` | `vtune -report summary -r <结果> -report-output summary.txt` | 采集摘要文本，含 CPU 时间、线程、PMU 等统计 |
| `hotspots.html` | `vtune -report hotspots -r <结果> -report-output hotspots.html` | 热点函数可视化，含火焰图、函数排序、模块分布 |
| `callgraph.html` | `vtune -report callstacks -r <结果> -report-output callgraph.html` | 函数调用栈 HTML 报告，含自底向上/自顶向下调用树 |

> **注意**：VTune 2025.10 中 `caller-callee` 和 `memory-access` 报告类型不存在。
> 调用关系通过 `callstacks` 报告类型获取，内存访问仅在使用硬件 PMU 采样时可用。

**主要交付物：`VTune_Analysis_Report.md`** — 综合 Markdown 报告（在步骤 6 中由 Agent 生成）。
Agent 读取 `summary.txt`、`hotspots.csv`、`callstacks.csv` 等原始数据后，
进行分析总结，生成包含以下内容的综合报告。

### 步骤 6 — 生成报告并进行综合分析

采集脚本（`vtune_collect.ps1`）会自动生成 CSV 和 HTML 报告。脚本完成后，
Agent 按以下流程生成最终的综合 Markdown 报告。

#### 6a — 读取原始数据

从报告目录读取以下文件：
- `summary.txt` — 采集摘要（文本格式，含经过时间、CPU 时间、线程数、PMU 事件等）
- `hotspots.csv` — 函数级 CPU 时间数据（CSV 格式）
- `callstacks.csv` — 调用栈采样数据
- `hotspots.html` — 热点函数可视化（VTune 生成的 HTML 报告）

**CSV 报告生成注意事项**：使用 `-report-output` 标志代替管道捕获 stdout，
避免 VTune 日志输出混入 CSV 数据，同时避免 sqlite-db 只读权限错误。

```powershell
# 正确方式：使用 -report-output 直接输出到文件
vtune -report summary -r <结果> -format csv -csv-delimiter comma -report-output summary.csv
vtune -report hotspots -r <结果> -format csv -csv-delimiter comma -report-output hotspots.csv

# 错误方式：管道捕获会混入 VTune stderr 日志，且可能触发权限错误
# vtune -report hotspots -r <结果> -format csv 2>&1 | Out-File hotspots.csv
```

在解析 CSV 行之前过滤掉 VTune 日志行（以 `vtune:` 或 `vtune.exe` 开头的行）和 PowerShell 错误段落。

#### 6b — 按模块聚合

解析 `hotspots.csv` 并按模块汇总 CPU 时间。这揭示了哪些 DLL 占主导地位，
比单个函数更具可操作性。

> ⚠️ **注意**：以下代码中的列索引（`$parts[1]` = CPU 时间，`$parts[5]` = 模块名）
> 依赖于 VTune CSV 输出格式。不同 VTune 版本可能改变列顺序或数量。
> 解析前应先检查 CSV 表头列名以确认索引正确。

```powershell
# 解析 hotspots.csv — 过滤表头 + VTune 噪声，按 Module 列聚合
# 注意：列索引用 ($parts[1]=CPU时间, $parts[5]=模块) 依赖于 VTune 版本
$csv = Get-Content "$reportDir\hotspots.csv" -Encoding UTF8 |
    Where-Object { $_ -match ',0x' }   # 仅数据行（包含起始地址）
$modules = @{}
foreach ($line in $csv) {
    $parts = $line -split ','
    $cpuTime = [double]$parts[1]
    $module = $parts[5].Trim()
    if (-not $modules[$module]) { $modules[$module] = 0 }
    $modules[$module] += $cpuTime
}
$sorted = $modules.GetEnumerator() | Sort-Object Value -Descending
```

#### 6c — 调用关系分析

从 `callstacks.csv` 和 `callgraph.html` 中提取关键调用路径。
关注：
- 自底向上（Bottom-Up）：热点函数的调用者是谁？
- 自顶向下（Top-Down）：哪些顶层函数消耗 CPU 最多？
- 是否存在意外的跨模块调用（如 DLL A 频繁调用 DLL B 的小函数）？

#### 6d — 生成 Markdown 综合报告

综合分析以上所有数据源，生成 `VTune_Analysis_Report.md` 写入报告目录。
使用以下模板结构：

```
# VTune 热点分析报告 — <进程名>（<阶段> 阶段）

> 采集时间 | 工具版本 | 模式 | 时长

## 1. 采集概览
（表格：目标、模式、经过时间、CPU 时间、有效/自旋/开销时间、线程数、结果大小）
（表格：CPU 型号、微架构、逻辑核心、PMU 状态、操作系统）

## 2. 🔥 前 10 热点函数
（表格：排名、函数、模块、CPU 时间、占总比 %）

## 3. 📦 CPU 耗时最多的前 10 模块
（表格：排名、模块、CPU 时间、占总比 %、角色/描述）

## 4. 📞 调用关系分析
（基于 callstacks.csv 和 callgraph.html 的调用关系总结）
（关键调用路径、跨模块调用热点、自底向上/自顶向下视角）

## 5. 🔍 关键发现
（基于数据揭示的内容分段 — 综合 summary.txt、hotspots.csv、callstacks.csv）

### 5.X <发现标题>
（用数据支撑的段落解释发现 — 例如"DLL 加载主导启动"、
".NET + 原生互操作混合"、"CUDA GPU 初始化"等）

## 6. ⚠️ 注意事项
（项目符号列表：这是启动阶段还是稳态？符号是否缺失？PMU 是否可用？
是否启用了调用栈采集？等）

## 7. 建议
（表格：优先级、建议、理由 — 可操作的后续步骤）

---

*报告由 Intel VTune Profiler <版本> 生成，<日期>*
```

**向用户展示**：保存 MD 文件后，在聊天中呈现简明摘要
（前 10 模块表格 + 2-3 个关键发现），并引导用户查看完整的 MD 报告和 HTML 可视化报告。

**失败处理**：如果采集失败，从结果目录的 `log/` 子目录中读取最新的
`perfrun*.log` 并解释错误。

### 步骤 7 — 清理

Markdown 报告保存后，提供清理选项：

1. **原始结果目录** — 可能 30–50 MB。确认报告有效（CSV 文件 > 200 字节，MD 报告存在）后删除。
2. **临时脚本和日志文件** — 会话期间写入桌面的 `.ps1` 包装脚本（`vtune_*.ps1`）和日志文件（`vtune_launch_log.txt`、`report_errors.log` 等）。
3. **保留** — `*_report/` 目录及其中的 CSV 文件和 MD 报告。仅在用户明确要求时删除这些。

## 兼容性矩阵

| 场景 | 检测方式 | 处理方式 |
|------|---------|---------|
| **VTune 未安装** | 步骤 0 | **停止流程** → 提供 (A) 安装 VTune 或 (B) Windows ETW/WPR 内置分析器 |
| Intel Ice Lake+ 客户端 CPU | 自动检测 | 完全硬件 PMU 支持，所有分析类型 |
| Intel Comet Lake / 更早客户端 | 自动检测 | 仅 SW 采样；内存分析被阻止并给出解释 |
| AMD CPU | 自动检测 | 仅 SW 采样；PMU 被阻止并给出解释 |
| 虚拟机 / 无 PMU 透传 | 非自动检测 | 将以 "cannot recognize the processor" 失败 → 手动 SW 降级 |
| Pin 附加被阻止 | 运行时 | "Failed to write probes" → 自动降级到启动模式分析 |
| .NET 进程 — 附加模式 | 运行时 | 可能出现 "Cannot profile the managed part" → 仅原生代码可见，C# 调用链缺失；改用启动模式可解决 |
| .NET 进程 — 启动模式 | 设计时 | Pin 在 CLR 初始化前注入 → 可完整采集托管+原生代码（推荐） |
| 无管理员权限 | 运行时 | Pin 附加将失败；**bash shell 应以管理员身份启动** |

## 常见失败模式

| 错误信息 | 可能原因 | 解决方案 |
|---------|---------|---------|
| `Cannot recognize the processor` | CPU 不在 PMU 数据库中 | 使用 SW 采样 |
| `Option 'pmu-type' received value from next argument` | VTune 配置生成 bug | `enable-characterization-insights=false` |
| `Failed to write probes in process` | Pin 附加被阻止（反篡改、.NET、杀毒软件） | 使用 `-LaunchMode` 在 VTune 下启动进程 |
| `Cannot find application file "C:\Program"` | 含空格路径被错误分割 | 引用路径：`` "-result-dir `"$dir`" -- `"$exe`"" `` |
| `Cannot re-finalize a read-only result` | 跨会话权限问题 | 在一个管理员会话中运行所有操作 |
| sqlite-db 上 `Insufficient permissions` | 管理员拥有的文件 | 使用管理员会话生成报告 |
| `Cannot find raw collector data` | 采集提前中止 | 检查日志，尝试禁用特征分析 |
| 退出代码 1 且无数据文件 | 通用采集失败 | 读取 `log/perfrun*.log` |
| `Cannot find a running process with the specified name` | 启动时使用了错误的 VTune 语法 | 在 VTune 参数后使用 `-- <exe>`，不要用 `-target-process` |
| LaunchMode 下采集仅持续 2-3 秒（perfrun log: `profiled application was terminated with exit code = 0`） | 已有同名进程在运行，新实例检测到后退出 | **步骤 1 自动处理**：先检查进程状态，确认残留后 `Stop-Process -Force` 清理（含子进程），验证无残留后再启动 |
| 热点中 >80% 为 Sleep/Wait 函数，业务模块 CPU 占比 <0.1% | 采集未以管理员身份运行，VTune 无法注入 Pin 分析托管代码 | **vtune_collect.ps1 已内置自动提权**，Agent 直接调用即可；不要绕过管理员提权 |
| `Cannot profile the managed part of the target process` | **附加模式下** Pin 无法注册 .NET CLR 托管代码回调（即使在管理员下也可能发生）。CLR 已在 Pin 注入前初始化完毕，导致仅能采样原生栈帧 | **(1)** 改用启动模式（`-LaunchMode`），Pin 在 CLR 初始化前注入，可完整采集托管代码。**(2)** 如果必须用附加模式，在报告中明确标注此局限性，C# 调用链不可见。**(3)** 使用 PerfView 互补分析 .NET 托管层 |

## 脚本

两个脚本都在 `scripts/` 目录中：

- **`vtune_detect.ps1`** — 查找 VTune 安装，输出 vtune.exe 路径和 PMU 兼容性信息
- **`vtune_collect.ps1`** — 完整的采集+报告流程，支持**附加模式**（`-TargetPid`）和**启动模式**（`-LaunchMode -TargetExe`）。需以管理员身份运行。
