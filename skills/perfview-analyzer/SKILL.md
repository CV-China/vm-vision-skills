---
name: perfview-analyzer
description: >
  基于 PerfView + xperf 的 Windows 混合模式应用内存自动化分析。核心能力：通过 VirtAlloc ETW 事件
  追踪 C++/原生非托管内存分配，按模块→函数逐层归因定位内存热点；兼顾 .NET 托管堆/GC 辅助分析。
  适用场景：排查 .NET+Native 混合进程内存占用、诊断非托管内存过度增长、定位 C++ 模块/函数的
  原生内存分配热点。触发词："用PerfView分析内存"、"PerfView内存分析"、"分析C++非托管内存"、
  "分析内存占用"、"定位内存增长"、"哪个模块占用内存多"、"内存热点模块"、"采集ETW trace"、
  "perfview analyze <process>"、"PerfView profile <PID>"、"analyze memory with PerfView"。
---

# PerfView Analyzer — 混合模式应用内存分析

对运行中的 .NET+原生(C++)混合进程进行 PerfView ETW 内存追踪分析。

**核心能力：定位 C++ 非托管内存分配热点，按模块→函数逐层归因到可操作的优化目标。**

## ⚠️ 语言要求

**所有用户交互对话、AskUserQuestion 提示、以及最终输出的 Markdown 分析报告，
必须使用简体中文。**

---

## 核心方法论

本技能基于海康机器人 VisionMaster 内存分析实战经验提炼：

```
┌─────────────────────────────────────────────────────────┐
│              混合模式应用内存分析流程                       │
├─────────────────────────────────────────────────────────┤
│  1. PerfView 采集（VirtAlloc 必勾）                         │
│  2. xperf CLI 自动分析（无需 GUI）                         │
│  3. 第一层：按所属 DLL/Module 拆分（-images）               │
│     ├── msvcr90.dll / ntdll.dll → 进入第二层               │
│     └── dxgmms2.sys → 进入第二层                           │
│  4. 第二层：按 CRT/CUDA/系统运行时库拆分                    │
│  5. 第三层：按 C++ 算法函数拆分（-stacks + -cullFrames）      │
│  6. 第四层：按业务模块聚合 → 生成优化优先级排名               │
│     ├── DL 轮廓匹配 → 256 MB → 重点优化                    │
│     ├── DL 表面缺陷滤波 → 256 MB → 重点优化                  │
│     └── ...                                              │
└─────────────────────────────────────────────────────────┘
```

**为什么托管 GC 分析不是重点？** — 在混合模式应用中，.NET 托管堆通常只占总内存的一小部分。真正的内存大头是 C++ 算法库通过 P/Invoke 分配的非托管内存。分析托管 GC 而忽略非托管内存，就像在泰坦尼克号上重新排列甲板椅子。

---

## 分析模式

本技能聚焦于**非托管内存分析**，通过 VirtAlloc ETW 事件定位 C++ 原生分配热点。

| 模式 | 目标 | 关键事件 | 默认时长 | 分析方式 |
|------|------|---------|---------|---------|
| **非托管内存**（默认） | C++ 原生分配热点 | VirtAlloc | 覆盖完整测试场景 | xperf CLI `-a virtualalloc` |

> **.NET 托管 GC 分析**不在本技能 CLI 自动化范围内。PerfView `UserCommand GCStats` 在无 GUI 环境下会无限阻塞（见 [CLI vs GUI 边界](#perfview-cli-vs-gui-分析能力边界)）。如需 GC 分析，请在 PerfView GUI 中手动操作，或使用 `scripts/` 目录下的 GC 事件解析脚本作为辅助参考。

---

## 快速入口

根据用户输入情况，选择最简路径进入：

| 用户输入 | 入口 | 说明 |
|---------|------|------|
| 已有 `.etl.zip` 文件，只需分析 | **→ 直接进入 [Step 5](#step-5--xperf-cli-自动分析核心步骤)** | 跳过采集，LLM 自动执行 xperf CLI 分析并生成报告 |
| 需要采集 + 分析 | **→ [Step 0](#step-0--工具检测)** | 完整流程：检测工具 → 确认参数 → 采集 → 分析 |

> **核心原则：所有分析通过 xperf CLI 自动完成，LLM 不得要求用户打开 PerfView GUI 或截屏分享。** 见 [CLI vs GUI 能力边界](#perfview-cli-vs-gui-分析能力边界)。

---

## Workflow

### Step 0 — 工具检测

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill_dir>/scripts/perfview_detect.ps1"
```

检测脚本会自动搜索（按优先级）：PATH → 当前工作目录 → 桌面/下载/Program Files → 所有驱动器根目录。如果 PerfView.exe 或 xperf.exe 未找到，**必须显式询问用户提供路径**，不要静默失败：

> "⚠️ 未检测到 PerfView.exe（已搜索 PATH、当前目录、桌面、各驱动器根目录）。请提供 PerfView.exe 的完整路径，或从 https://github.com/microsoft/perfview/releases 下载。"
> 
> "未检测到 xperf.exe，请提供 xperf.exe 所在路径，或安装 Windows ADK 中的 Windows Performance Toolkit。**注意：PerfView ETW 采集不受影响，可先完成采集，xperf 仅影响后续分析步骤。**"

#### 回退方案（perfview_detect.ps1 失败时）

**如果 `perfview_detect.ps1` 因中文编码问题导致 ParserError（实测已验证），必须使用回退方案：**

**方案 A — `perfview_find_fallback.ps1`（纯 ASCII，推荐）**

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill_dir>/scripts/perfview_find_fallback.ps1" -ToolName "PerfView.exe"
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill_dir>/scripts/perfview_find_fallback.ps1" -ToolName "xperf.exe"
```

此脚本为纯 ASCII 编码，无中文字符，不触发编码 ParserError。搜索策略：
PATH → 常见安装路径 → 桌面/下载 → 所有驱动器根目录（depth=3）

**方案 B — `tools/Everything.exe`（仅 GUI，无法自动化，最后手段）**

⚠️ **Everything.exe 是 GUI 程序，不支持 CLI 输出。** `-search` 参数仅预填搜索框内容，
搜索结果在 GUI 窗口中显示，**无法返回给命令行或脚本**。

**当方案 A 也未找到目标工具时，必须按以下交互流程询问用户：**

> "⚠️ 自动搜索未找到 `PerfView.exe`。是否使用 Everything（极速全盘文件搜索工具）手动查找？
>
> Everything.exe 位于：`<skill_dir>/tools/Everything.exe`
>
> 操作步骤：
> 1. 双击运行上述路径的 Everything.exe
> 2. 在搜索框中输入 `PerfView.exe`
> 3. 在结果列表中找到 `PerfView.exe`，右键 → Copy Full Path
> 4. 将完整路径粘贴回复给我
>
> 如果 Everything 中也找不到，请告诉我，我将提供下载链接。"

```bash
# Everything.exe 仅能打开 GUI 窗口并预填搜索词，不能输出文本结果
# 禁止在脚本/管道中使用——这将无限阻塞等待 GUI 进程退出
"<skill_dir>/tools/Everything.exe" -search "PerfView.exe"
# → GUI 窗口弹出，用户手动查看结果后告知 Agent 路径
```

**Agent 须知**：
- `perfview_detect.ps1` 可能因中文编码问题导致 ParserError——不要手动 `ls` 枚举盘符
- **始终优先使用方案 A**（`perfview_find_fallback.ps1`）——纯 ASCII 脚本，可自动化输出结果
- 方案 A 也未找到 → **必须主动询问用户是否使用 Everything**，同时告知 Everything.exe 的完整路径
- 用户在 Everything 中找到后提供路径 → Agent 记录该路径并继续后续流程
- 用户拒绝或 Everything 中也找不到 → 走询问用户流程（提供下载链接）

### Step 0.5 — 符号处理策略

**⚠️ 关键原则：禁止在后台默默下载符号文件。下载可能耗时数分钟，用户会以为卡死。**

**⚠️ Win11 xperf 10.0.26100+ 行为变更：`-images` 现在强制要求 `-symbols`（旧版不需要）。**
不加 `-symbols` 直接报错：`virtuallaloc: -frames or -stacks requires symbol decoding`。

函数级分析依赖 C++ 算法库的 PDB 符号。符号处理流程（**必须在启动 xperf 分析前执行**）：

1. **检索本地符号缓存 + 设置环境变量**：
   ```bash
   # 检查本地符号目录
   test -d /c/Symbols 2>/dev/null && echo "本地符号缓存存在 ($(du -sh /c/Symbols 2>/dev/null | cut -f1))" || echo "无本地符号缓存"
   # 必须设置 _NT_SYMBOL_PATH！否则 xperf -symbols 触发公网下载（耗时数分钟）
   # 本地有 Symbols → 只做本地解析（毫秒级）
   export _NT_SYMBOL_PATH="C:\Symbols"
   ```

2. **分情况处理**：

   | 场景 | 处理方式 |
   |------|---------|
   | 本地已有 `C:\Symbols` 且不为空 | 直接使用 `export _NT_SYMBOL_PATH="C:\Symbols"`，**只做本地解析**，不触网 |
   | 用户提供了 C++ PDB 路径 | 将路径追加到 `_NT_SYMBOL_PATH` |
   | 无本地符号且用户未提供 | **必须主动询问用户**，不得沉默下载。**LLM 违反此条 = 造成 3-10 分钟卡死** |

3. **询问用户模板**（当本地无符号时）：

   > "要进行函数级精确归因，需要 C++ 算法模块的 PDB 符号文件。
   > 
   > - **选项 A**：提供 PDB 文件路径，我做本地解析（毫秒级）
   > - **选项 B**：从 Microsoft 公网下载系统符号（可能需 3-10 分钟）
   > - **选项 C**：跳过函数级分析，先用模块级数据做分析（模块名仍可见，但无法定位到具体函数）
   > 
   > 建议选 A 如果你有 PDB 文件，或选 C 先看模块级结果。"

4. **分析时使用符号**：
   - **`-symbols` 标志**：Win11 新版 xperf 的 `-images`、`-frames`、`-stacks` 均需 `-symbols`
   - **必须先用 `export _NT_SYMBOL_PATH` 设置路径**，再加 `-symbols`，否则触发公网下载
   - **函数名解析依赖 PDB**：`-frames`/`-stacks` 需要 PDB 才能显示函数名，无 PDB 时显示 `?`
   - 需下载符号：**用户明确同意后**，才追加 `srv*C:\Symbols*https://msdl.microsoft.com/download/symbol`

### Step 1 — 确认分析目标与测试场景

询问用户以下信息，以便设定正确的采集策略：

**1a. 确认进程 + 管理员权限**

> "将对 **<进程名>**（PID: XXXXX）进行 C++ 非托管内存分析，定位内存分配热点。是否继续？"
> 
> **⚠️ 采集前必须先检查管理员权限**：Kernel ETW events（VirtualAlloc、VAMap）需要管理员权限。
> ```bash
> powershell -Command "(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
> ```
> 返回 `True` → 继续。返回 `False` → 告知用户"需要管理员权限才能捕获内核内存事件，请以管理员身份重新启动终端"。

**1b. 了解测试场景**

内存增长通常发生在特定操作期间。用通俗语言询问用户：

> "为了准确捕获内存分配，我需要了解：**什么操作会让这个程序的内存明显增长？** 比如：
> - 加载方案/配置文件？
> - 运行图像检测/算法运算？
> - 打开某个界面/处理特定数据？
>
> 这样我可以在正确的时刻启动采集，确保捕获到内存分配的关键时段。"

根据用户回答，确定需要对比的阶段（如 空载 → 加载方案 → 运行检测）。

### Step 2 — 查找目标进程 + 确定阶段方案

使用 `Get-Process` 或 `tasklist` 找到目标进程的 PID，同时与用户确认阶段划分：

> "根据你描述的操作场景，建议分以下阶段对比采集：
> 1. **<阶段1>**（如：进程空闲/空载基线）
> 2. **<阶段2>**（如：加载方案/打开文件）
> 3. **<阶段3>**（如：运行检测/算法计算）
>
> 阶段数量和名称可根据你的实际需要增减。是否需要调整？"

**如果是 VisionMaster 或 GeneralFramework 进程**：加载模块映射表以支持中文名称标注。

```bash
# 读取映射表（无需执行，LLM 在分析时直接读取 references 目录下的文件）
Read <skill_dir>/references/VisionMaster模块映射表.md
```

### Step 3 — 确认采集参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| **Circular MB** | 10000 | 关键！必须大于整个测试周期的事件数据量 |
| **采集时长** | **30s/阶段**（可自定义） | 覆盖完整测试场景 |
| **VirtAlloc** | 必勾 | 捕获 C++ 非托管内存分配（`xperf -a virtualalloc` 数据源） |
| **测试轮次** | 至少运行 2 轮 | 确保有足够数据覆盖 |

### Step 4 — 执行采集

#### 4a. 选择采集策略

大多数内存增长排查需要**对比不同阶段的内存差异**。

| 策略 | 机制 | 适用场景 |
|------|------|---------|
| **多阶段对比采集（推荐）** | LLM 编排，逐阶段调用 `perfview_unmanaged.ps1 -PhaseName` | 90% 的内存增长排查 |
| **多阶段自动采集** | `perfview_multiphase.ps1` 一次性跑完所有阶段 | CI/自动化场景 |
| **单阶段采集** | `perfview_unmanaged.ps1`（不加 `-PhaseName`） | 快速单次快照 |

#### 4b. 多阶段对比采集工作流（LLM 编排，推荐）

⚠️ **核心原则：先启动采集，再告知用户执行操作。** PerfView ETW 采集一旦启动就开始记录。如果在用户操作*之后*才启动采集，关键的内存分配事件已经发生完毕，无法追溯捕获。

**阶段定义（LLM 必须显式告知用户默认时长并允许自定义）：**

| 阶段 | PhaseName | 应用状态 | 默认 Duration |
|------|-----------|---------|--------------|
| 1 | `空方案` | 进程空闲基线（不做任何操作） | **30s** |
| 2 | `加载方案` | 加载方案/打开文件过程中 | **30s** |
| 3 | `运行检测` | 执行实际工作负载（图像检测/算法等） | **60s** |

> **运行检测阶段默认 60s**，因为工作负载通常持续时间较长。加载方案阶段如方案较大（如 VisionMaster 复杂方案），建议设为 60-120s。其余阶段默认 30s。**所有阶段时长均可由用户自定义。**

**LLM 编排步骤：**

**步骤 1 — 确认参数**：向用户确认阶段方案和时长，**显式告知默认值并允许自定义**。

> "多阶段采集方案如下（运行检测默认 60s，其余 30s，均可调整）：
> 1. **空方案** — 进程空闲基线，采集 30s
> 2. **加载方案** — 加载方案过程中，采集 30s（方案较大可设 60-120s）
> 3. **运行检测** — 运行工作负载时，采集 60s（可设 60-180s）
> 
> 是否需要调整时长？确认后开始采集。"

**步骤 2 — 逐阶段执行**。每个阶段按以下**固定顺序**（**关键：先启动采集，再让用户操作**）：

**⚠️ 错误做法（不可用）**：先让用户"切换状态"，再启动采集 → 内存分配事件在采集启动前已经完成，无法捕获。

**正确流程**：

1. **LLM 启动采集脚本** → ETW providers 立即开始记录
2. **同时告知用户**：在采集启动的同一时刻告诉用户执行操作
3. **等待采集完成** → 脚本内部等待 Duration 秒后自动 stop + merge

> "采集已启动（${Duration}s）！**请立即执行：[阶段N操作说明]**"

```bash
MSYS_NO_PATHCONV=1 powershell -NoProfile -ExecutionPolicy Bypass -File \
    "<skill_dir>/scripts/perfview_unmanaged.ps1" \
    -TargetPid <PID> -TargetProcess "<Name>" \
    -PhaseName "<阶段名称>" -Duration <seconds> \
    -CircularMB 10000 -Cleanup
```

采集为阻塞式操作（脚本内部等待 Duration 秒 + stop/merge 时间），完成后输出 JSON 包含 `phase_name`、`etl_zip`、`etl_size_mb` 等字段。LLM 记录每个阶段的 `.etl.zip` 路径，然后进入下一阶段。

**步骤 3 — 汇总**：所有阶段完成后，汇总输出：

> "=== 多阶段采集完成 ===
> | 阶段 | 时长 | 输出文件 | 大小 |
> |------|------|---------|------|
> | 空方案 | 30s | <进程>_空方案_xxx.etl.zip | XX MB |
> | 加载方案 | 30s | <进程>_加载方案_xxx.etl.zip | XX MB |
> | 运行检测 | 60s | <进程>_运行检测_xxx.etl.zip | XX MB |
>
> 接下来自动进入 xperf CLI 分析。"

#### 4c. 多阶段自动采集（CI/非交互场景）

> **注意**：CI 场景下运行检测建议设为 60s（与交互式工作流一致）。脚本默认值为 `@(30, 30, 30)`，请在 CI 配置中显式指定。

```bash
MSYS_NO_PATHCONV=1 powershell -NoProfile -ExecutionPolicy Bypass -File \
    "<skill_dir>/scripts/perfview_multiphase.ps1" \
    -TargetPid <PID> -TargetProcess "<Name>" \
    -PhaseNames "空方案","加载方案","运行检测" \
    -PhaseDurations 30,30,60 \
    -CircularMB 10000 -Cleanup
```

#### 4d. 单阶段采集（向后兼容）

```bash
MSYS_NO_PATHCONV=1 powershell -NoProfile -ExecutionPolicy Bypass -File \
    "<skill_dir>/scripts/perfview_unmanaged.ps1" \
    -TargetPid <PID> -TargetProcess "<Name>" \
    -Duration <seconds> -CircularMB 10000 -Cleanup
```

**采集关键时序（所有采集模式通用）：**
1. 执行 `start` → ETW providers 启动（**此时即开始记录**）
2. **用户立即执行测试场景**（加载方案、运行检测等）
3. 至少运行 2 轮完整操作
4. 执行 `stop` → 合并、压缩（**保持进程运行**）
5. `-Cleanup`：自动删除原始 `.etl`（保留 `.etl.zip`）

### Step 5 — xperf CLI 自动分析（核心步骤）

**LLM 必须自动完成，不得要求用户打开 GUI 或截屏分享。**

#### 5.0 解压 ETL 文件

⚠️ **xperf 对中文路径和中文文件名存在编码兼容性问题**。解压 ETL 时**必须**：
- 使用纯 ASCII 目录名（如 `C:\temp\etl\`）
- 解压后的 `.etl` 文件名不含中文字符

```bash
# 创建纯 ASCII 临时目录，避免中文路径导致 xperf 解析失败
mkdir -p /c/temp/etl

# 解压所有阶段的 .etl.zip 到不含中文的目录
MSYS_NO_PATHCONV=1 powershell -NoProfile -Command \
  "Add-Type -AssemblyName System.IO.Compression.FileSystem; \
   [System.IO.Compression.ZipFile]::ExtractToDirectory('<file>.etl.zip', 'C:\temp\etl\<phase_name>')"
```

> 如果 `<OutputDir>` 本身包含中文路径，应将 ETL 解压到 `C:\temp\etl\` 等纯 ASCII 路径。

#### 5.1 第一层分析：模块级定位（Win11 xperf 10.0.26100+ 需 `-symbols`）

```bash
# ⚠️ 必须先设置 _NT_SYMBOL_PATH！否则 xperf -symbols 自动下载符号（耗时数分钟）
export _NT_SYMBOL_PATH="C:\Symbols"
# Win11 新版 xperf 的 -images 强制要求 -symbols（不加会报错退出）
xperf -i <trace>.etl -symbols -a virtualalloc -images soc -pid <PID> -top 30
```

输出各 DLL/Module 的 Outstanding Commit 排名，这是最核心的模块级数据。
**本步骤仅显示模块名（如 `msvcr90.dll`），要归因到业务模块需要函数级钻取（5.3）。**

#### 5.2 三阶段对比汇总

```bash
# -totals 无需 -symbols，秒出
xperf -i <trace>.etl -a virtualalloc -totals | grep <ProcessName>
```

#### 5.3 第二/三层分析：函数级调用栈钻取（需 PDB 符号）

```bash
# 按函数帧聚合（需 PDB，否则函数名显示 ?）
export _NT_SYMBOL_PATH="C:\Symbols"
xperf -i <trace>.etl -symbols -a virtualalloc -frames soc -pid <PID> -top 20

# 钻取业务调用方：cull 掉 CRT 层，露出调用 malloc 的业务代码
# 注意：实际需 cull 的帧因 CRT 版本而异，应根据 -stacks 实际输出确定帧名
# 常见需 cull 的帧：KernelBase.dll!VirtualAlloc、CRT 内部函数（如 _heap_commit、_sbrk）
xperf -i <trace>.etl -symbols \
  -a virtualalloc -stacks soc \
  -cullFrames "KernelBase.dll!VirtualAlloc" \
  -pid <PID> -top 30
```

> **无 PDB 时**：函数名显示为 `?`，但所属模块名（DLL）仍然可见，可据此进行业务模块归因。

n> **⚠️ 为什么 5.1 不够——必须钻到 5.3**：`-images` 只显示**直接调用 VirtualAlloc 的 DLL**（如 `msvcr90.dll`、`KernelBase.dll`），这些是 CRT 运行时和系统库，不是业务代码。例如运行检测阶段 `msvcr90.dll` 占 97% 内存，但所有 C++ 算法模块都通过它分配——不钻取就无法归因。**任何时候看到 `msvcr*.dll` 或 `KernelBase.dll` 在 -images TOP 3，都必须继续 5.3。**
#### 5.4 第四层：业务模块聚合

LLM 根据调用栈中的模块名按命名规则归入业务模块。基础规则如下：

| 模块名模式 | 归属业务模块 |
|-----------|------------|
| `*ContourMatch*`、`*PatMatch*` | 轮廓匹配 |
| `*SurfaceDefect*`、`*DefectFilter*` | 表面缺陷滤波 |
| `*BlobFind*` | BLOB 分析 |
| `*ImageCpp*`、`*ImageSource*`、`*MediaProcess*` | 图像源/媒体处理 |
| `*Algorithm*` | 算法核心库（需结合上层调用判断业务归属） |
| `dxgmms2.sys`、`d3d*.dll`、`wpfgfx*` | GPU/WPF 渲染 |

**VM/GF 进程：模块中文名映射**（target 包含 `VisionMaster` 或 `GeneralFramework` 时）：

1. 读取 `<skill_dir>/references/VisionMaster模块映射表.md`
2. 对 xperf 输出中的每个 DLL 名，**始终使用模糊搜索**（PerfView 中的名称可能是底层 C++ 实现 DLL，不直接等于映射表中的模块英文名）：

   | DLL 名示例 | 提取核心名 | 映射表匹配 |
   |-----------|----------|-----------|
   | `IMVSBlobFindModu.dll` | `BlobFind` | → `IMVSBlobFindModu` → **BLOB分析** |
   | `MVDBlobFindCpp.dll` | `BlobFind` | → `IMVSBlobFindModu` → **BLOB分析** |
   | `MVDContourPatMatchCpp.dll` | `ContourPat?Match` | → `IMVSContourMatchModu` → **轮廓匹配**（模糊匹配，`ContourPat` ≈ `Contour`） |
   | `MVDSurfaceDefectFilterCpp.dll` | `SurfaceDefectFilter` | → `IMVSSurfaceDefectFilterModu` → **表面缺陷滤波** |
   | `MVDImageCpp.dll` | `Image` | → `IMVSImageFilterModu` 等多候选 → 结合工具箱上下文判断 |

   **模糊搜索步骤**：
   a. 去掉 `.dll` 后缀
   b. 去掉前缀（`MVD`、`IMVS`）和后缀（`Cpp`、`Modu`），提取核心名
   c. 在映射表的"模块英文名"列中搜索包含该核心名的记录；无精确匹配时使用子串匹配（如 `Contour` 匹配 `ContourMatch`）
   d. 单匹配直接使用；多匹配时结合调用栈上下文（上层 DLL 名）辅助判断；无匹配标注"（未在映射表中）"

**聚合与截断规则**：

1. **同名去重叠加**：同一业务模块可能出现在多个调用栈路径中（如不同线程或不同算法路径），LLM 必须将所有相同业务模块的 Outstanding Commit **累加合并**，不重复列出
2. **Top 20 截断**：最终报告只罗列内存占用**前 20 名**（含"其他"汇总行）
3. **"其他"汇总**：第 20 名之后的模块合并为一行"其他"，标注模块数量

**聚合示例**：
```
# xperf 输出中出现：
# Stack A: MVDContourPatMatchCpp → IMVSContourMatchModu → 256 MB
# Stack B: libmvb_x64 → MVDContourPatMatchCpp → IMVSContourMatchModu → 64 MB
# → 合并为: 轮廓匹配 (IMVSContourMatchModu) = 256 + 64 = 320 MB
```
3. 在报告中，业务模块排名表增加一列"**模块中文名**"

**DLL 命名约定说明**（便于模糊匹配）：

| DLL 前缀/后缀 | 含义 | 示例 |
|-------------|------|------|
| `IMVS*Modu.dll` | VM 模块层（托管的 C++/CLI 包装） | `IMVSBlobFindModu.dll` |
| `MVD*Cpp.dll` | VM 底层 C++ 算子库 | `MVDBlobFindCpp.dll` |
| `MVDCommon.dll` | VM 底层通用函数库 | — |
| `MVD_Algorithm.dll` | VM 算法核心库 | — |
| `libmvb_x64.dll` | 海康自研 AI 推理库 | — |

> 通常 `MVD*Cpp.dll` 和 `IMVS*Modu.dll` 一一对应（如 `MVDBlobFindCpp.dll` ↔ `IMVSBlobFindModu.dll`），可通过提取核心名（`BlobFind`）查找映射表。

#### 5.5 xperf CLI 分析完整参考

| 分析需求 | xperf 命令 | 需要 PDB |
|---------|-----------|:---:|
| 进程级汇总（秒出） | `xperf -i trace.etl -a virtualalloc -totals` | ❌ |
| 模块级排名 | `xperf -i trace.etl -a virtualalloc -images soc -pid PID -top 30` | ❌ 模块名来自 ImageLoad 事件 |
| 函数帧级排名 | `xperf -i trace.etl -symbols -a virtualalloc -frames soc -pid PID -top 20` | ✅ 无 PDB 函数名显 `?` |
| 完整调用栈 | `xperf -i trace.etl -symbols -a virtualalloc -stacks soc -pid PID -top 30` | ✅ 无 PDB 函数名显 `?` |
| 跳过基础设施帧 | 加 `-cullFrames "KernelBase.dll!VirtualAlloc" "msvcr*.dll!malloc"` | — |

**排序模式**：`soc` = outstanding commit（当前已提交未释放）；`sc` = total committed（累计提交）。

### Step 6 — 生成分析报告（必须）

**此步骤不可跳过。** LLM 基于 xperf CLI 输出自动生成 Markdown 报告（**无需用户参与**）：

```
# PerfView 内存分析报告 — <进程名>

## 1. 采集概览
（目标进程、Circular MB、采集时长、ETL 大小、三阶段汇总）

## 2. 非托管内存 Module 级分析
| DLL / Module | 分配量 | 占比 |
|-------------|--------|------|

## 3. 非托管内存 C++ 函数级分析
各关键 module 下的 Top 函数分解（如有符号）

## 4. 业务模块内存热点排名
（VM/GF 进程时增加"模块中文名"列）
| 业务模块 | 模块中文名 | 关键 DLL | 内存增长 | 占比 | 优化优先级 |
|---------|----------|---------|---------|------|----------|

## 5. 关键发现与优化方向
按 ROI 排序的优化建议

## 6. 数据文件
所有 .etl.zip 文件路径
```

报告写入 `<workspace>/PerfView_分析报告_<进程名>_<date>.md`。

### Step 7 — 清理

保留：`.etl.zip`、分析报告
可删除：未压缩的 `.etl`、中间解压目录（`C:\temp\etl\`）

```bash
# 清理 xperf 分析用的解压临时目录
rm -rf /c/temp/etl/
```

---

## 可选工具：VMMap

VMMap（Sysinternals）可用于采集前/后的整体内存对比，帮助验证 PerfView 分析结果。

使用方式：
1. 在进程空载/加载/运行三个阶段分别用 VMMap 截图或导出
2. 对比 Committed 指标的增长
3. 验证 PerfView 分析的数据是否与 VMMap 一致

**VMMap 不是必需的** — xperf CLI 分析已经提供了足够精确的数据。

---

## 关键注意事项

1. **先启动采集，再操作** — ETW 启动即记录，用户操作必须在采集期间进行（不是等用户操作完再采集）
2. **Circular MB 必须足够大** — 设置过小会导致旧数据被覆盖。确定方法：先试运行 1-2 轮，看 Status 栏数据量，×2 作为 Circular MB
3. **VirtAlloc 是核心数据源** — 非托管内存分析完全依赖 VirtAlloc ETW 事件。`xperf -a virtualalloc` 分析的是内核 VirtualAlloc/VirtualFree 调用，不依赖 CLR 事件
4. **测试期间保持进程运行** — stop 命令执行符号解析期间不能关进程
5. **禁止后台静默下载符号** — 必须先检查本地缓存，无本地符号时主动询问用户选择（提供路径 / 下载 / 跳过）
6. **C++ PDB 符号是函数级热点的前提** — 没有符号只能停在 Module 级别，但模块级结论完全可用
7. **PerfView 为 GUI 程序** — CLI 调用时 exit code 可能为空，不能以此判断成功/失败
8. **多阶段采集时确保进程不重启** — 所有阶段必须在同一个进程实例上完成
9. **各阶段 Circular MB 保持一致** — 不同阶段用不同的 Circular MB 会导致数据覆盖程度不同
10. **运行检测默认 60s，其余阶段默认 30s** — LLM 必须在采集前显式告知用户各阶段时长并允许自定义
11. **LLM 自动完成分析** — 不得要求用户打开 PerfView GUI 截屏。所有分析通过 xperf CLI 完成
12. **禁止使用 PerfView UserCommand GCStats** — 该命令会在无 GUI 环境下无限阻塞。如需 GC 统计，仅在 GUI 打开时手动使用
13. **xperf 对中文路径存在兼容性问题** — 解压 .etl.zip 时使用纯 ASCII 目录（如 `C:\temp\etl\`），避免中文文件名导致 xperf 解析失败
14. **⚠️ 必须用 `/LogFile=` 而非 `/NoView`** — `/NoView` 仅跳过结果查看，GUI 仍会创建，触发 Empty Symbol Path 弹窗阻塞。用 `/LogFile=collect.log` 彻底抑制 GUI（`UsersGuide.htm:7623` + `App.cs:1084` 源码验证）
15. **⚠️ Git Bash 下必须用 `MSYS_NO_PATHCONV=1`** — 否则 `/CircularMB=10000` 等参数被 MSYS 误转为文件路径。所有 PerfView 命令必须加此前缀
16. **⚠️ xperf `-symbols` 前必须先设置 `_NT_SYMBOL_PATH`** — Win11 xperf (10.0.26100+) 的 `-images` 强制要求 `-symbols`。不设置环境变量会触发公网下载（耗时数分钟）。必须先检查本地符号缓存，无符号时显式询问用户或跳过函数级分析
17. **采集后检查 `.etl.zip` 文件确认完成** — PerfView 进程退出后 Bash 后台任务追踪器可能不感知。直接 `ls *.etl.zip` 检查文件是否存在来判断完成
18. **⚠️ 采集前必须检查管理员权限** — Kernel ETW events（VirtualAlloc、VAMap）须管理员权限。非管理员运行 PerfView 会静默产生空 ETL（0 事件），所有分析白做。检查方法：`powershell -Command "(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"`

## PerfView CLI 完整参考

基于 `src/PerfView/CommandLineArgs.cs` 和 `src/PerfView/CommandProcessor.cs` 源码验证。

### 所有可用命令

| 命令 | 用途 | 示例 |
|------|------|------|
| `run` | 启动采集 + 运行程序 + 停止 | `PerfView /MaxCollectSec:60 run MyApp.exe` |
| `collect` | 启动采集 + 等待 + 停止 | `PerfView /CircularMB=10000 collect` |
| `start` | 仅启动采集（需单独 stop） | `PerfView /DataFile=out.etl start` |
| `stop` | 停止采集 + 合并 | `PerfView /DataFile=out.etl stop` |
| `abort` | 强制停止所有 PerfView 会话 | `PerfView abort` |
| `merge` | 合并 ETL + 生成 PDB/ZIP | `PerfView /DataFile=out.etl merge` |
| `unzip` | 解压 .etl.zip | `PerfView /DataFile=out.etl.zip unzip` |
| `HeapSnapshot` | **拍摄 .NET 堆快照** | `PerfView /DataFile=heap.gcdump /Process:12345 HeapSnapshot` |
| `ForceGC` | 强制触发 GC | `PerfView /Process:12345 ForceGC` |
| `listSessions` | 列出活跃 ETW 会话 | `PerfView listSessions` |
| `ListCpuCounters` | 列出可用 CPU 计数器 | `PerfView ListCpuCounters` |
| `Mark` | 在事件流中添加标记 | `PerfView Mark "start test"` |
| `UserCommand` | 运行扩展插件命令 | `PerfView UserCommand DumpEventSourceManifests` |

> **⚠️ 禁止使用 `UserCommand GCStats`**：该命令需要 GUI 事件循环，CLI 模式下会无限阻塞。
> 其他 UserCommand（如 `SaveCPUStacks`）不受影响。

### 核心采集命令

```bash
# 【推荐】非托管内存分析（仅 VirtAlloc，无需 CLR 事件）
PerfView /DataFile=output.etl /MaxCollectSec:90 /KernelEvents=Default,VirtualAlloc,VAMap /CpuSampleMSec:1 /CircularMB=10000 /BufferSizeMB=4096 /LogFile=collect.log /AcceptEula start

# 停止
PerfView /DataFile=output.etl stop

# 堆快照（CLI 方式，需 .NET 进程）
PerfView /DataFile=heap.gcdump /Process:12345 HeapSnapshot

# 仅 GC 分析（附带 VirtAlloc，用于托管内存诊断）
PerfView /GCOnly /CircularMB=5000 /MaxCollectSec:60 collect
```

### 语法要点

| 规则 | 正确 | 错误 | 来源 |
|------|------|------|------|
| 大部分用 `=` | `/KernelEvents=default+VirtualAlloc` | `~:default+VirtualAlloc` | `CommandLineArgs.cs:537` |
| `/MaxCollectSec` 可用 `:` 或 `=` | `/MaxCollectSec:90` 或 `/MaxCollectSec=90` | N/A | `CommandLineArgs.cs:298` |
| `/CpuSampleMSec` 可用 `:` 或 `=` | `/CpuSampleMSec:1` 或 `/CpuSampleMSec=1` | N/A | `CommandLineArgs.cs:398` |
| 关键词用 `,` 或 `+` | `default,VirtualAlloc,VAMap` | N/A | `CommandLineArgs.cs:537` |
| **脚本用** `/LogFile` | `/LogFile=path.log` | `/nogui` | `CommandLineArgs.cs:281` |
| **交互式** 用 `/NoGui` | `/NoGui` (启动控制台版) | N/A | `CommandLineArgs.cs:578` |
| EULA | `/AcceptEula` | `/accepteula` | `CommandLineArgs.cs:565` |
| 不查看结果 | `/NoView` | N/A | `CommandLineArgs.cs:568` |
| 进程过滤 | `/Process:name_or_pid` | N/A | `CommandLineArgs.cs:334` |
| **管理员权限** | ETW kernel session 需管理员；非管理员采集静默产生空 ETL（#18） | — | — |

### 常用 KernelEvents 关键词

源码位置: `src/TraceEvent/Parsers/KernelTraceEventParser.cs` (枚举 `Keywords`, 行 172-219)

| 关键词 | 枚举值 | 内容 |
|--------|--------|------|
| `Default` | 见下行 | DiskIO, DiskFileIO, DiskIOInit, ImageLoad, MemoryHardFaults, NetworkTCPIP, Process, ProcessCounters, Profile, Thread |
| `ThreadTime` | ~ | `Default` + ContextSwitch + Dispatcher |
| `Verbose` | ~ | `Default` + ContextSwitch + Dispatcher + FileIO + FileIOInit + **Memory** + Registry + **VirtualAlloc** + **VAMap** |
| `VirtualAlloc` | 0x004000 | 每次 VirtualAlloc/VirtualFree 调用（含栈） |
| `VAMap` | 0x8000 | 虚拟地址映射信息（Win8+，Verbose 已包含） |
| `ReferenceSet` | 0x40000000 | 内核引用集事件 |
| `ThreadPriority` | 0x20000000 | 线程优先级变更事件 |
| `IOQueue` | 0x10000000 | I/O 完成端口排队/出队 |
| `Handle` | 0x00400000 | 句柄创建/关闭（排查句柄泄漏） |
| `Memory` | 0x00001000 | 页面错误（硬/软） |
| `DeferedProcedureCalls` | 0x00040000 | DPC 事件（驱动/中断分析） |

> **注意**: 以上枚举值来源：`src/TraceEvent/Parsers/KernelTraceEventParser.cs` Keywords 枚举。`Default` 不包含 `VirtualAlloc` 和 `VAMap`，使用 `Default` 作为基础时必须显式添加。`Verbose` 已包含两者。CLI 分隔符用 `,`（源码文档："A comma separated list"），`+` 也能工作。

### 预置采集模式

| 标志 | 等价于 |
|------|--------|
| `/GCOnly` | `KernelEvents=Process,Thread,ImageLoad,VirtualAlloc` + `ClrEvents=GC,GCHeapSurvivalAndMovement,Stack,Jit,StopEnumeration,SupressNGen,Loader,Exception,Type,GCHeapAndTypeNames` + `Providers=Microsoft-Windows-Kernel-Memory:0x60` |
| `/GCCollectOnly` | `KernelEvents=Process` + `ClrEvents=GC` |
| `/ThreadTime` | `KernelEvents=ThreadTime` |
| `/DotNetAlloc` | 启用 .NET 对象分配跟踪 (自动添加 VirtualAlloc) |
| `/Wpr` | `KernelEvents=ThreadTime+DPC+Driver+Interrupt` |

### PerfView CLI vs GUI 分析能力边界

| 分析操作 | CLI | GUI |
|---------|-----|-----|
| 启动/停止 ETW 采集 | ✅ `start`/`stop`/`collect` | ✅ |
| 堆快照 | ✅ `HeapSnapshot` | ✅ |
| GCStats 报告 | ❌（CLI 会阻塞） | ✅ Memory → GCStats |
| CPU 栈数据导出 | ✅ `UserCommand SaveCPUStacks` | N/A |
| VirtualAlloc 模块级分析 | ✅ **`xperf -a virtualalloc -images`** | ✅ Memory → Net Virtual Alloc Stacks |
| VirtualAlloc 调用栈分析 | ✅ **`xperf -a virtualalloc -stacks`** | ✅ 双击展开 |
| VirtualAlloc 函数帧分析 | ✅ **`xperf -a virtualalloc -frames`** | ✅ 树形展开 |
| 多阶段 diff 对比 | ✅ 基于 CLI 输出文本对比 | ✅ 并排查看 |

**结论**: 所有核心分析均可通过 xperf CLI 完成，无需 GUI。

### 源码文档索引

| 文件 | 内容 |
|------|------|
| `src/PerfView/CommandLineArgs.cs` | **所有 CLI 参数定义**（行 275-707，`SetupCommandLine` 方法） |
| `src/PerfView/CommandProcessor.cs` | **命令执行逻辑**（`Start`、`Stop`、`Collect`、`HeapSnapshot` 等） |
| `src/PerfView/SupportFiles/UsersGuide.htm` | 用户指南（行 7605 起: Command Line Reference） |
| `documentation/TraceEvent/TraceEventProgrammersGuide.md` | TraceEvent 库编程指南（ETLX、TraceLog、调用栈解析） |
| `src/PerfView/memory/` | 内存分析模块源码 |
| `src/PerfView/StackViewer/` | 调用栈查看器源码 |

---

## Scripts

### 核心脚本

- **`scripts/perfview_detect.ps1`** — 检测 PerfView.exe + xperf.exe。优先搜索常见路径和 PATH，未找到时引导用户指定路径
- **`scripts/perfview_find_fallback.ps1`** — 纯 ASCII 回退脚本（当 `perfview_detect.ps1` 因中文编码 ParserError 时使用）。搜索 PATH → 常见安装路径 → 桌面/下载 → 所有驱动器根目录
- **`scripts/perfview_unmanaged.ps1`** — 单阶段非托管内存采集（默认 30s，支持 `-PhaseName` 用于多阶段编排）
- **`scripts/perfview_multiphase.ps1`** — 多阶段批量采集包装器（内部循环调用 `perfview_unmanaged.ps1`，适用于 CI/自动化场景）
- **`scripts/perfview_collect.ps1`** — 旧版采集脚本（保留兼容，新场景推荐用 `perfview_unmanaged.ps1`）

### 辅助/内部脚本

以下脚本为开发调试辅助工具，未集成到主工作流，使用时需显式指定目标路径和参数：

- **`scripts/check_dotnet.ps1`** — 检查指定进程是否为 .NET 进程
- **`scripts/check_trace.ps1`** — 检查 PerfView 采集状态
- **`scripts/gen_reports.ps1`** — 旧版 CPU Profiling 报告生成（xperf -a profile/process/stack，非 VirtAlloc 内存分析）。**主工作流不依赖此脚本**——内存分析报告通过 Step 5 的 xperf CLI 命令直接生成
- **`scripts/extract_gc.ps1`** — 从 ETL 提取 GC 相关事件
- **`scripts/parse_gc_data.ps1`** — 解析 GC 事件数据
- **`scripts/gc_analyze.ps1`** — GC 事件分析
- **`scripts/gc_summary.ps1`** — GC 活动摘要
