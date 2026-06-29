---
name: vm-script-protection
description: |
  为 VisionMaster .sol 方案文件中的 ShellModule 脚本自动添加代码防护。

  ## 触发条件
  当用户提到以下场景时触发：
  - 给方案加 try-catch
  - ShellModule 增加异常保护
  - 脚本模块加 try catch
  - 方案脚本增加稳健性
  - 给 sol 文件中的脚本加异常处理
  - VM 方案脚本保护
  - 分母为0防护、除零防护
  - 数组索引溢出防护、数组越界防护
  - null 空指针防护
  - 防止脚本崩溃/闪退
  - 防止内存泄漏（静态集合泄漏检测）
  - 防止脚本卡死/死循环
  - 脚本性能优化（循环拼接、重复LINQ）
  - 脚本优化

  即使没有明确说 "try-catch"，用户提到 "增加脚本代码的稳健性"、"防止脚本崩溃"、
  "脚本异常保护"、"防除零"、"防数组越界"、"防死循环"、"脚本性能分析"、
  "脚本优化"、"脚本性能优化" 等也应触发。

  ## 依赖
  - **运行时要求**：CLI 工具 `VMSolutionParser.Cli.exe` 目标框架为 **.NET Framework 4.6.1**，
    运行前需确保系统已安装 [.NET Framework 4.6.1 Runtime](https://dotnet.microsoft.com/download/dotnet-framework/net461) 或更高版本
  - CLI 工具及其所有托管 DLL 依赖已打包在 `tools/` 目录下（`VMSolutionParser.Core.dll`、
    `CommandLine.dll`、`Newtonsoft.Json.dll`、`protobuf-net.dll`、`ZipManager.dll`、`Hzip.dll`）
  - 将技能目录拷贝到任意已安装 `.NET Framework 4.6.1+` 的 Windows 机器的 `~/.claude/skills/` 下即可使用
  - **PowerShell 版本要求**：脚本中的 `ConvertTo-Json -Depth` 参数需要 **PowerShell 5.1+** 或 **PSCore 6+**（Windows 10/11 自带 PS 5.1，已满足）。验证命令建议在 Git Bash 中调用 `powershell -File` 执行
---

# VM 方案 ShellModule 代码防护

为 .sol 方案中所有 ShellModule 脚本模块自动添加代码防护，支持：
- **try-catch 异常保护**：包裹 `Init()` / `Process()` 方法
- **除零防护**：检测除法运算，在分母接近零时提前返回安全值
- **数组/集合越界防护**：在索引访问前校验长度，null 引用前做判空
- **无限循环防护**：为 `while` 循环注入迭代上限计数器，防止卡死
- **静态集合泄漏检测**：发现只增不减的 `static` 集合（警告）
- **深度递归检测**：发现自调用方法（警告）
- **循环性能分析**：检测循环内字符串拼接、重复 LINQ、大对象分配（警告）

## 工具路径

本技能自包含 CLI 工具，路径相对于技能根目录：

```

CLI = "<skill-base>/tools/VMSolutionParser.Cli.exe"
```

> 技能被调用时，系统会告知技能根目录（Base directory for this skill）。
> 根据该目录拼接 CLI 路径。例如：
> ```bash
> SKILL_BASE="<技能根目录>"
> CLI="$SKILL_BASE/tools/VMSolutionParser.Cli.exe"
> "$CLI" inspect -f "<sol路径>" --list
> ```
>
> `tools/` 目录下包含 `VMSolutionParser.Cli.exe` 及其所有运行时依赖 DLL
> （`VMSolutionParser.Core.dll`、`CommandLine.dll`、`Newtonsoft.Json.dll`、
> `protobuf-net.dll`、`ZipManager.dll`、`Hzip.dll`）。
> 拷贝技能时保持 `tools/` 目录完整即可。

## C# 语法与目标框架约束（⚠️ 必须遵守）

VM 内置的 Roslyn 脚本编译器锁定在 **C# 5.0** 语法，目标框架为 **.NET Framework 4.6.1**。
生成任何防护代码时，**禁止使用 C# 6.0 及以上版本的语法特性**：

### 禁止的语法（C# 6+）

| 语法特性 | C# 版本 | 错误示例（不可用） | 替代方案 |
|---------|---------|------------------|---------|
| 字符串插值 | 6.0 | `$"模块{name}异常: {ex.Message}"` | `"模块" + name + "异常: " + ex.Message` |
| 空条件运算符 | 6.0 | `obj?.Method()` / `arr?.Length` | `obj != null ? obj.Method() : null` |
| `nameof()` | 6.0 | `nameof(Process)` | 字符串字面量 `"Process"` |
| 表达式体成员 | 6.0 | `int Foo => 42;` | `int Foo { get { return 42; } }` |
| 自动属性初始化 | 6.0 | `int Count { get; set; } = 0;` | 在构造函数中初始化 |
| `using static` | 6.0 | `using static System.Math;` | `Math.Sqrt()` 全限定调用 |
| 异常筛选器 | 6.0 | `catch (Exception e) when (e.HResult == 5)` | `catch` 内 `if` 判断 |
| `await` in catch/finally | 6.0 | — | 不在 catch 中使用 await |
| `out var` 声明 | 7.0 | `int.TryParse(s, out var x)` | 先声明 `int x;` 再 `out x` |
| 值元组 | 7.0 | `var (x, y) = GetPoint();` | `Point p = GetPoint(); p.X, p.Y` |
| 模式匹配 | 7.0+ | `if (x is int n)` | `if (x is int) { int n = (int)x; }` |
| 局部函数 | 7.0 | 方法内定义 `void Helper() { }` | 提取为 private 方法 |
| `throw` 表达式 | 7.0 | `x ?? throw new Exception()` | `if (x == null) throw ...` |
| `??=` / switch 表达式 / 范围索引 | 8.0 | `x ??= 0;` / `^1` / `..` | `x = x ?? 0;` / 索引反向计算 |

### 允许的语法（C# 2–5）

`??` (C# 2)、`var` (C# 3)、LINQ/Lambda (C# 3)、命名实参/可选参数 (C# 4)、`async/await` (C# 5)

### 脚本代码合规检查清单

- [ ] 字符串拼接使用 `+`（不使用 `$"..."`）
- [ ] 空检查使用显式 `== null` / `!= null`（不使用 `?.` / `??=`）
- [ ] 异常日志：`"<模块名> Init异常: " + ex.Message`
- [ ] 方法体使用完整 `{ }` 块（不使用 `=>` 表达式体）
- [ ] catch/finally 块中不使用 `await`（C# 5 不允许；try 块内 `await` 是允许的）
- [ ] 变量先声明再使用（不使用 `out var`）

> **`yield return` 特殊限制**：若 ShellModule 脚本使用了 `yield return` 迭代器，
> C# 编译器错误 CS1626 禁止 `yield return` 出现在 try-catch 内。
> 此时仅添加除零/null 防护，跳过 try-catch 包裹。

## 标准工作流

### Step 0: 路径约定

- `<sol路径>`：.sol 文件绝对路径（用户提供）
- `<sol目录>`：`<sol路径>` 所在目录 = `dirname("<sol路径>")`，后续所有中间文件均存放于此

### Step 1: 确认输入

### Step 0.5: 环境预检（⚠️ 在 Step 1 之前执行）

**在开始任何操作之前，验证运行环境：**

```bash
# 检查 .NET Framework 4.6.1+ 是否安装
reg query "HKLMSOFTWAREMicrosoftNET Framework SetupNDP4Full" /v Release 2>/dev/null | grep -qE "[4-9][0-9]{5}" && echo "✅ .NET Framework 已安装" || echo "❌ 需要 .NET Framework 4.6.1+"

# 检查 CLI 工具是否存在
test -f "<skill-base>/tools/VMSolutionParser.Cli.exe" && echo "✅ CLI 工具就绪" || echo "❌ CLI 工具缺失"
```

> **任一检查失败 → 告知用户缺失项并提供下载/安装指引，不要继续后续步骤。**

向用户确认：
- `.sol` 文件路径（必须）— 记作 `<sol路径>`
- 是否密码保护（如加密，向用户询问密码；未加密则跳过）
- 需要添加哪类防护（try-catch / 除零 / 数组越界 / 无限循环 等，可多选；**默认全部**）
- 是否覆盖原方案（**默认覆盖**，自动创建 `.bak` 备份）

> 若用户只提供了 `.sol` 路径而未说明其他参数，按默认值执行：
> 全部防护类型（自动注入 + 分析警告）+ 覆盖原方案 + 生成 `.bak` 备份。

### Step 2: 扫描 ShellModule

> **⚠️ 若方案加密，在 Step 2 第一步先用带密码的 inspect 验证密码正确性。**
> 密码错误时 CLI 会报错，立即退出流程并提示用户重新输入密码，不要继续后续步骤。
> 避免在密码错误的情况下执行完漫长的 Step 3（二进制提取）才发现问题。

使用 `inspect --list` 列出所有模块，过滤出 ShellModule：

```bash
"CLI" inspect -f "<sol路径>" --list [-p <密码>]
```

解析 JSON 输出，找出所有 `"name": "ShellModule"` 的模块，记录其 `fullPath` 和 `displayName`。

如果未找到任何 ShellModule，直接告知用户："该方案中没有 ShellModule 脚本模块。"

### Step 3: 提取完整脚本内容

**重要**：CLI 的 `inspect` 和 `parse` 输出对长脚本内容存在截断（JSON 输出中脚本正文
被省略为 `...` 或标记为 truncated），不能直接用于分析。必须从 sol 二进制中提取完整脚本。

**方法：二进制搜索 + 边界检测 + 多模块循环提取**

#### 3a. 定位所有候选位置

> **编码关键**：使用 **Latin-1** (ISO-8859-1, code page 28591) 解码字节流。
> Latin-1 对 256 个字节值做 1:1 映射，保证 ASCII 子串（如 `using System;`）
> 在所有二进制段中都能可靠命中，避免 UTF-8 解码遇到无效序列时的风险。

```powershell
$bytes = [System.IO.File]::ReadAllBytes('<sol路径>')
$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$text = $latin1.GetString($bytes)

# 找到所有 "using System;" 出现位置
$search = 'using System;'
$positions = @()
$i = 0
while ($true) {
    $pos = $text.IndexOf($search, $i)
    if ($pos -lt 0) { break }
    $positions += $pos
    $i = $pos + 1
}
Write-Output "共找到 $($positions.Count) 个 'using System;' 命中"
```

#### 3b. 过滤 GlobalScript，识别 ShellModule 候选

sol 文件中可能出现三类包含 `using System;` 的区域：
1. **GlobalScript JSON 内嵌**：在文件前部，`"ScriptContent":"using System;..."`（JSON 字符串内）
2. **ShellModule 二进制段**：在文件中后部，前有 `ShellContent` + NUL 填充标记
3. 其他脚本引用

ShellModule 脚本特征：前面有 `ShellContent` 标记 + NUL 填充；NUL 填充末尾通常有 `T` 字节
（模块版本标记），紧跟 `using System;`；脚本结束后紧跟 `AssemblyGuid` 标记。

过滤策略：**从后往前**遍历 `$positions`（GlobalScript 通常在文件前部，ShellModule 在中后部）。
对每个候选位置，检查前面约 **512 字节**内是否含 `ShellContent` 标记。
（实测 `ShellContent` 距离 `using System;` 约 264 字节，远超 256 字节窗口，必须扩大至 512。）

```powershell
# ShellModule 候选：前面 512 字节内有 "ShellContent"
$shellCandidates = @()
for ($idx = $positions.Count - 1; $idx -ge 0; $idx--) {
    $pos = $positions[$idx]
    $preBytes = New-Object byte[] 512
    $copyLen = [Math]::Min(512, $pos)
    [Array]::Copy($bytes, $pos - $copyLen, $preBytes, 512 - $copyLen, $copyLen)
    $preText = $latin1.GetString($preBytes)
    if ($preText.Contains('ShellContent')) {
        $shellCandidates += $pos
    }
}
Write-Output "ShellModule 候选: $($shellCandidates.Count) 个"
```

#### 3c. 逐模块提取 C# 脚本（字节级精确提取 + 正确编码解码）

> **⚠️ 编码关键**：Latin-1 仅用于定位 **纯 ASCII 边界标记**
> （`using System;`、`AssemblyGuid`、`}`）。
> **提取脚本内容时，必须使用原始字节 + UTF-8/GB2312 正确解码**，
> 不可将 Latin-1 字符串直接持久化（会导致中文永久乱码，详见 Step 3c.5）。
>
> 每个 ShellModule 脚本通常 < 10KB，取 **14KB（14336 字节）** 安全边界足以覆盖。

```powershell
$utf8 = [System.Text.Encoding]::UTF8
$gb   = [System.Text.Encoding]::GetEncoding(936)  # GB2312/GBK

# 用于跟踪提取结果的列表
$extractedScripts = @()
$chunkSize = 14336  # 14KB，足以覆盖单个 ShellModule 脚本

for ($idx = 0; $idx -lt $shellCandidates.Count; $idx++) {
    $startPos = $shellCandidates[$idx]
    Write-Output "--- 提取模块 $($idx + 1)/$($shellCandidates.Count) (字节偏移 0x$($startPos.ToString('X')) ---"

    # 提取字节块（用于定位边界）
    $actualChunkSize = [Math]::Min($chunkSize, $bytes.Length - $startPos)
    $chunk = New-Object byte[] $actualChunkSize
    [Array]::Copy($bytes, $startPos, $chunk, 0, $actualChunkSize)
    $raw = $latin1.GetString($chunk)

    # 1) 定位 C# 代码起始（Latin-1: using System; 是纯 ASCII，1:1 映射）
    $codeStart = $raw.IndexOf('using System;')
    if ($codeStart -lt 0) {
        Write-Warning "  [跳过] 未在块中找到 'using System;'"
        continue
    }

    # 2) 定位脚本结束边界
    $codeEnd = $raw.IndexOf('AssemblyGuid')
    if ($codeEnd -lt 0) {
        $codeEnd = $raw.IndexOf('DynamicInData')
    }
    if ($codeEnd -lt 0) {
        Write-Warning "  [跳过] 未找到结束边界标记 (AssemblyGuid/DynamicInData)"
        continue
    }
    if ($codeEnd -le $codeStart) {
        Write-Warning "  [跳过] 边界异常: codeEnd($codeEnd) <= codeStart($codeStart)"
        continue
    }

    # 3) 从 codeEnd 往前找最后一个 '}'（类结束括号）
    $searchRegion = $raw.Substring($codeStart, $codeEnd - $codeStart)
    $lastBrace = $searchRegion.LastIndexOf('}')
    if ($lastBrace -lt 0) {
        Write-Warning "  [跳过] 未在边界范围内找到类结束 '}'"
        continue
    }

    # 4) 字节级精确提取（关键：不使用 Latin-1 字符串截取，而是操作原始字节）
    $scriptByteStart = $startPos + $codeStart
    $scriptByteLen   = $lastBrace + 1
    $scriptBytes = New-Object byte[] $scriptByteLen
    [Array]::Copy($bytes, $scriptByteStart, $scriptBytes, 0, $scriptByteLen)

    # 5) 编码自动检测与解码
    # 先尝试 UTF-8 解码，检查是否有常见中文字符；否则尝试 GB2312
    $script = $utf8.GetString($scriptBytes)
    # 中文验证探针（扩宽词表，覆盖 C# 注释常见用词，防止窄探针误判）
    $chineseProbe = '初始化|执行|流程|变量|函数|模块|数据|处理|排序|计算|防护|返回|异常|遍历|输入|输出|索引|图像|相机|参数|结果|检测|位置|坐标|阈值|检查|设置|获取|缓存|释放|转换|更新|创建|删除'
    $hasChineseUtf8 = ($script -match $chineseProbe)
    if (-not $hasChineseUtf8) {
        # 尝试 GB2312 解码
        $scriptGb = $gb.GetString($scriptBytes)
        $hasChineseGb = ($scriptGb -match $chineseProbe)
        if ($hasChineseGb) {
            Write-Output "  检测到 GB2312 编码，已转换为 UTF-8"
            $script = $scriptGb
        } else {
            # 字节级统计回退：检测高字节密度（GB2312 双字节范围 0xA1-0xFE）
            $highByteCount = 0
            foreach ($b in $scriptBytes) {
                if ($b -ge 0xA1 -and $b -le 0xFE) { $highByteCount++ }
            }
            $highByteDensity = $highByteCount / $scriptBytes.Length
            if ($highByteDensity -gt 0.02) {
                Write-Output "  中文探针未命中，但检测到高字节密度 ($('{0:P0}' -f $highByteDensity))，推测为 GB2312"
                $script = $scriptGb
            } else {
                Write-Output "  未检测到中文内容，按 UTF-8 处理"
            }
        }
    } else {
        Write-Output "  检测到 UTF-8 编码"
    }
    Write-Output "  提取成功，脚本长度: $($script.Length) 字符"

    # 保存到临时文件（始终以 UTF-8 编码写入）
    $safeName = "shell_$($idx + 1)_clean.txt"
    $outPath = Join-Path '<sol目录>' $safeName
    [System.IO.File]::WriteAllText($outPath, $script, $utf8)

    $extractedScripts += [PSCustomObject]@{
        Index        = $idx + 1
        FileName     = $safeName
        FilePath     = $outPath
        ScriptBody   = $script
        ByteOffset   = $startPos
    }
}

Write-Output "成功提取 $($extractedScripts.Count) 个 ShellModule 脚本"

> **⚠️ 跨步骤变量持久化**：$extractedScripts 是内存对象，Step 4-6 可能在新的 PowerShell 会话中执行。
> 必须立即将 $extractedScripts 序列化到磁盘：
> ```powershell
> $extractedScripts | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 "extracted_scripts.json"
> ```
> Step 6.5 从文件恢复：`$extractedScripts = Get-Content "extracted_scripts.json" | ConvertFrom-Json`
if ($extractedScripts.Count -eq 0) {
    Write-Error "未能提取任何 ShellModule 脚本，终止流程"
    exit 1
}
```

> **为什么不能直接 `WriteAllText(Latin-1字符串, UTF8)`**：
> Latin-1 解码时，UTF-8 中文三字节序列（如 `E8 AE A1` = `计`）被映射为三个独立的
> Latin-1 字符（`è ® ¡`）。再以 UTF-8 写回时，每个 Latin-1 字符被重新编码
> （`è` U+00E8 → `C3 A8`），原始中文字节被永久破坏，注释变为乱码。
> **正确做法**：Latin-1 仅用于 ASCII 边界定位；脚本正文通过 `[Array]::Copy` 字节级
> 提取后用正确编码解码。

#### 3d. 将提取的脚本映射到 Step 2 的模块

Step 2 的 `inspect --list` 输出按内部模块树遍历顺序列出 ShellModule；
Step 3 的 `$extractedScripts` 按二进制偏移**降序**排列（从后往前遍历）。
两者通常**同序**（模块树遍历顺序与 sol 文件物理布局一致），按此顺序建立映射表：

```

| fullPath (Step2) | displayName | 脚本文件 (Step3) |
|-----------------|-------------|-----------------|
| 流程1.脚本1      | 脚本1       | shell_1_clean.txt |
| 流程1.脚本2      | 数据预处理  | shell_2_clean.txt |
```

> **映射可靠性验证**：
> 
> 脚本中注入的 debug 消息包含 displayName（如 `"脚本1 Init异常:"`）。
> **必须用此消息验证映射关系是否正确。**
> 
> ```powershell
> foreach ($scr in $extractedScripts) {
>     if ($scr.ScriptBody -match '"([^"]+) Init异常:') {
>         Write-Output "$($scr.FileName) debug displayName: $($Matches[1])"
>     }
> }
> ```
> 
> **验证逻辑**：
> - 脚本中 debug displayName = inspect --list 中的 displayName → ✅ 映射正确
> - 脚本 debug displayName 与另一个模块匹配 → ⚠️ **映射顺序颠倒，需交换**
> - 两者无交叉匹配 → 🔴 **阻断流程**
> - 脚本内容相同（Step 3e 去重 → 1 组）则无影响
> 
> **⚠️ 实测陷阱**：二进制从后往前遍历，`$extractedScripts[0]` 对应文件物理位置最后的 ShellModule。当 displayName 不同时必须交叉校验。
> - 若所有提取脚本内容相同（Step 3e 去重 → 1 组），映射顺序无影响
> - 若脚本数 = ShellModule 数，且存在多个不同内容组，映射大概率正确
> - 若脚本数 ≠ ShellModule 数，**必须**告知用户并暂停，不可继续

> 若 `$extractedScripts.Count` 与 Step 2 的 ShellModule 数量不一致：
> 1. 打印 warning 列出差异
> 2. **不让用户决定是否继续**——改为**阻断流程**，因为映射关系不可靠
> 3. 提示用户检查 sol 文件完整性或手动指定映射关系

#### 3e. 脚本去重

对比所有提取脚本的 `ScriptBody`。若多个脚本内容相同，标记为一组：
只需分析一次的组内第一个脚本，其余副本在 Step 6 通过替换 `displayName` 生成。

> **关键边界标记参考**：
> - `ShellContent` + NUL 填充 → 脚本起始前导标记
> - `AssemblyGuid` + NUL 填充 → 脚本结束后的第一个标记
> - `DynamicInData` → 备选结束标记

### Step 4: 分析脚本，确定需要修改的位置

#### 4.0 脚本语法兼容性预检（⚠️ 必须先执行）

在分析之前，先检查脚本是否使用了与 try-catch 不兼容的 C# 特性：

**`yield return` 迭代器方法**：C# 编译器错误 CS1626 禁止 `yield return` 出现在 try-catch 块内。
若 `Init()` 或 `Process()` 方法体含 `yield return`，标记该方法 **不可添加 try-catch**，
仅能添加除零/null 防护。

> **关于 `async`**：VM ShellModule 标准签名为 `public void Init()` 和 `public bool Process()`。
> C# 5 中 `async` 方法只能返回 `void`、`Task` 或 `Task<T>`，`bool` 与 `async` 不兼容，
> 因此 `Process()` 不存在 async 场景。`Init()` 理论上可为 `async void`，但 catch 块
> 仅写 `Debug.WriteLine`，不含 `await`，不会触发 C# 5 的 catch 内 await 限制。

> 检查脚本时若发现 `yield return`，在 Step 5 报告中显式标注，避免生成无法编译的代码。
> 
> **`yield return` 与非 try-catch 防护的兼容性**：除零、null 越界、无限循环等局部防护
> 使用 `return <safeValue>` 或 `break` 而非 try-catch 包裹，这些语法在迭代器方法中
> **合法**（`return;` / `return <expr>;` / `break;` 均可出现在 `yield return` 方法中）。
> 因此仅 try-catch 受 CS1626 限制，其他防护类型不受影响。

**4a. try-catch 防护分析**

检查 `Init()` 和 `Process()` 方法体内是否已有**方法级** `catch` 关键字：
- 已有方法级 try-catch → 跳过该方法
- 仅有内部 try-catch（非包裹整个方法体）→ 仍标记为需要包裹
- 没有 → 在方法体外层包裹 try-catch（见 Step 6 模板）

**4b. 除零防护分析**

扫描脚本中所有除法表达式 `a / b`，检查分母 `b`：

**4b-1. 整数取模防护分析**（`%` 运算符同样可抛出 DivideByZeroException）
扫描脚本中所有取模表达式 `a % b`：
- 若 `b` 是常量非零 → 安全，跳过
- 若 `b` 是变量/表达式 → 需要防护（与除零防护同样方式）

整数取模防护模板：
```csharp
// __safe_guard
int __safe_mod_divisor = <原始除数表达式>;
if (__safe_mod_divisor == 0) return <安全默认值>;
int result = dividend % __safe_mod_divisor;
```
- 若分母是常量（非零）→ 安全，跳过
- 若分母是 `Math.Sqrt(1 + k*k)` 等形式（恒 ≥1）→ 安全，跳过
- 若分母是变量/表达式（可能为零）→ 需要防护

浮点数除零防护模板（变量名使用 `__safe_` 前缀避免与用户代码冲突）：
```csharp
// __safe_guard
float __safe_min_f = 0.000001f;
float __safe_denom = <原始分母表达式>;
if (Math.Abs(__safe_denom) < __safe_min_f) return <安全默认值>;
float result = numerator / __safe_denom;
```

整数除零防护模板：
```csharp
// __safe_guard
int __safe_divisor = <原始除数表达式>;
if (__safe_divisor == 0) return <安全默认值>;
int result = dividend / __safe_divisor;
```

> **变量命名约定**：防护代码中引入的局部变量统一使用 `__safe_` 前缀
> （如 `__safe_min_f`、`__safe_denom`、`__safe_divisor`），避免与用户脚本中
> 可能存在的 `min_f`、`denominator` 等变量名冲突导致编译错误。

注意：若除法已在 `if(Math.Abs(dx) > min_f)` 之类条件保护的分支内，
且该条件确保分母非零，则该除法已安全，无需重复防护。

**4c. 数组/集合越界防护分析**

扫描以下模式：
- `arr[i]`、`list[i]` — 索引访问前检查 `i >= 0 && i < arr.Length`
- `arr[0]`、`list.First()` — 假定非空的访问，检查 `arr.Length > 0`
- `collection.AddRange(x)` — `x` 为 null 会抛异常，检查 `x != null`
- `obj.Method()` — `obj` 可能为 null 的引用

防护方式：
```csharp
// __safe_guard
if (arr == null || arr.Length == 0) return <安全默认值>;
// __safe_guard
if (list == null || list.Count == 0) return <安全默认值>;
// __safe_guard
if (i < 0 || i >= arr.Length) return <安全默认值>;
// __safe_guard
if (obj == null) return <安全默认值>;
```

> **安全默认值选择**：
> - 返回 `bool` 的方法 → `false`
> - 返回数值的方法 → `0` 或 `0.0f`
> - 返回集合的方法 → `new List<T>()` 或 `new T[0]`
> - 返回 `void` 的方法 → `return;`

**4d. 无限循环/卡死防护分析** 🔴 高

扫描脚本中所有 `while` 循环和 `for(;;)` 模式，检查是否存在无法退出的风险：
- `while (true)` / `while (1 == 1)` / `for (;;)` — 恒真条件，必须有内部 `break`/`return`
- `while (condition)` 但 `condition` 在循环体内未被修改 — 死循环
- `while` / `for(;;)` 循环体内无任何 `break`/`return`/迭代器推进 — 疑似死循环

> `for`（含 `for(;;)` 三子句全空无限循环形式）和 `foreach` 循环通常由明确的范围/迭代器控制，
> 默认视为安全，不添加防护。但 **`for(;;)` 是 C# 合法无限循环**，等同于 `while(true)`，
> 必须检测并注入防护。

对于疑似死循环，注入迭代上限计数器：

```csharp
// 注入在 while 循环之前：
// __safe_guard
        int __safe_iter = 0;
int __safe_max_iter = 1000000;
// 注入在 while 循环体的第一行：
    __safe_iter++;
    if (__safe_iter > __safe_max_iter)
    {
        System.Diagnostics.Debug.WriteLine("<displayName> 循环可能无限，已强制退出");
        break;
    }
```

> **不注入的场景**：循环体已有类似迭代计数变量或 `__safe_iter` 标记时跳过。

**4e. 静态集合内存泄漏分析** 🟡 中

扫描脚本中所有 `static` 集合字段（`List<T>`、`Dictionary<K,V>`、`HashSet<T>`、
`Queue<T>`、`Stack<T>` 等），检查是否存在只增不减的内存泄漏风险：
- 字段声明为 `static List<T>` 等
- 在 `Process()` 或循环中对集合执行 `Add()` / `Enqueue()` / `Push()` 操作
- 全脚本中无对应的 `Clear()` / `Remove()` / `Dequeue()` / `Pop()` 调用

> 此类风险**仅报告为警告**，不自动注入修复代码（`Clear()` 会丢失业务数据，
> 需用户确认正确的清理策略）。报告中注明建议添加的清理方式。

**4f. 深度递归/栈溢出分析** 🟡 中

扫描脚本中所有方法，检查是否存在直接递归调用：
- `MethodA()` 内部调用 `MethodA()` — 直接递归
- `MethodA()` 调用 `MethodB()` 且 `MethodB()` 调用 `MethodA()` — 间接递归

> 仅报告为警告。VM ShellModule 默认栈空间有限，深层递归可能导致
> StackOverflowException 闪退。建议用户确认递归深度上限并添加深度守卫。

**4g. 循环内字符串拼接分析** 🟡 中

扫描循环体内的 `+=` 字符串操作：
```csharp
string result = "";
foreach (var item in items)
{
    result += item.ToString() + ",";  // O(n²) 内存分配，产生大量临时 string 对象
}
```

> 仅报告为警告，建议改用 `StringBuilder` 或 `string.Join()`。
> 不自动注入修复（涉及变量声明和作用域变更，自动化风险较高）。

**4h. 循环内重复 LINQ 枚举分析** 🟡 中

扫描循环体内对同一数据源重复调用 `.ToList()` / `.ToArray()` / `.Count()` 的模式：
```csharp
foreach (var item in items)
{
    var filtered = source.Where(x => x.Id == item.Id).ToList(); // 每次循环重新扫描
}
```

> 仅报告：提示可预先构建 `Dictionary<K,V>` 或 `Lookup<K,V>` 将 O(n²) 降为 O(n)。

**4i. 大对象循环内分配分析** 🟢 低

扫描循环体内 `new` 分配的对象，检查是否可以提到循环外复用：
```csharp
foreach (var roi in rois)
{
    Roi tempRoi = new UserScript.Roi();  // 可提到循环外复用（如果未 Add 到外部集合）
    tempRoi.X = roi.CenterX;
    ...
}
```

> 仅报告：提示注意循环内对象分配。但需人工判断复用是否安全
> （如对象被 `Add` 到外部集合时不可复用，否则会互相覆盖）。

### 防护类型决策矩阵

| 防护类型 | 触发关键词 | 严重度 | 操作 | C# 5.0 合规 |
|----------|-----------|--------|------|:--:|
| try-catch | `Init()` / `Process()` 无外层 try | 🔴 高 | **自动注入** | 禁止 `$""`, `?.`, `=>` |
| 除零 | `/` 运算符 + 变量分母 | 🟡 中 | **自动注入** | `__safe_` 前缀变量 |
| 数组/null越界 | `arr[i]`, `.AddRange()`, `.First()` | 🟡 中 | **自动注入** | `== null \|\|` 显式检查 |
| 无限循环 | `while (true)`, while 无 break | 🔴 高 | **自动注入** | `__safe_iter` 计数器 |
| 静态集合泄漏 | `static List<T>` + 只增不减 | 🟡 中 | ⚠️ 警告 | 用户手动处理 |
| 深度递归 | 方法调用自身 | 🟡 中 | ⚠️ 警告 | 用户手动处理 |
| 循环字符串拼接 | 循环内 `+=` string | 🟡 中 | ⚠️ 警告 | 建议 StringBuilder |
| 重复 LINQ 枚举 | 循环内重复 `.ToList()` | 🟡 中 | ⚠️ 警告 | 建议预计算 |
| 循环内大对象分配 | 循环内 `new` 对象 | 🟢 低 | ⚠️ 警告 | 需人工判断 |

### Step 5: 报告分析结果，等待用户确认（⚠️ 必须执行）

**在修改任何代码之前**，必须向用户清晰报告分析结果，并等待用户明确确认。

报告内容应包含以下部分：

#### 5a. 分析总览

```

## 代码安全分析报告

| 项目 | 内容 |
|------|------|
| 方案文件 | <sol文件名> |
| ShellModule 数量 | <N> |
| 脚本总行数 | <总行数> |

### 检测结果汇总

| 风险类型 | 发现数量 | 严重程度 | 操作 |
|----------|---------|---------|------|
| 未捕获异常 (try-catch) | <N> | 🔴 高 | 自动注入 |
| 除零风险 | <M> | 🟡 中 | 自动注入 |
| 数组/null 越界 | <K> | 🟡 中 | 自动注入 |
| 无限循环/卡死 | <L> | 🔴 高 | 自动注入 |
| 静态集合泄漏 | <P> | 🟡 中 | ⚠️ 警告 |
| 深度递归 | <Q> | 🟡 中 | ⚠️ 警告 |
| 循环字符串拼接 | <R> | 🟡 中 | ⚠️ 警告 |
| 重复 LINQ 枚举 | <S> | 🟡 中 | ⚠️ 警告 |
| 循环内大对象分配 | <T> | 🟢 低 | ⚠️ 警告 |

> **自动注入**：无需用户干预，直接修改代码添加防护。
> **⚠️ 警告**：仅在报告中展示风险，由用户决定是否修复。
```

#### 5b. 按模块逐项列出问题与修复方案

对每个 ShellModule，逐项列出：

```

### 模块: <fullPath> (displayName) <去重标注>

#### 问题 1: <问题类型> — <位置描述>
- **风险**: <说明如果不修复会发生什么>
- **当前代码**:
```csharp
// 有问题的原始代码
```

- **修改方案**:
```csharp
// 修改后的代码
```

- **修改说明**: <一句话说明做了什么保护>

#### 问题 2: ...
```

> **重要**：每个问题的修改方案必须用代码对比展示，让用户直观看到 before/after 差异。
>
> **`<去重标注>`**：若 Step 3e 标记该模块脚本与另一模块内容相同（如模块 A 与模块 C），
> 标注 `[与 模块C 脚本相同，修改方案同上，仅 displayName 不同]`。方便用户快速确认去重关系。

#### 5c. 安全默认值说明

若修改涉及 `return <安全默认值>`，说明选择了什么默认值及理由：

```

| 方法 | 返回类型 | 安全默认值 | 理由 |
|------|---------|-----------|------|
| Process() | bool | false | 异常时跳过本次执行 |
| PointToLine() | float | 0.0f | 异常时返回零距离 |
```

#### 5d. 确认提示

报告末尾明确询问：

```

---
### ⚠️ 请确认是否继续

以上共发现 **<X>** 处需要修改的问题，涉及 **<N>** 个 ShellModule。
是否按上述方案进行修改？

- 回复 **"确认"** / **"继续"** / **"是"** → 立即执行修改（Step 6-11），完成后生成报告（Step 12）
- 回复 **"跳过 XXX"** / **"不要 XXX"** → 排除指定修改后执行
- 回复 **"仅生成报告"** / **"暂不修改"** → 跳过修改步骤（Step 6-11），直接生成分析报告（Step 12），所有问题标注 `[未应用]`
- 回复 **"取消"** / **"否"** → 终止操作，不做任何修改，但仍必须生成分析报告（Step 12），所有问题标注 `[未应用-用户取消]`
```

#### 确认后的行为

- 用户确认 → 进入 Step 6 开始修改代码，完成后进入 Step 12 生成报告
- 用户部分确认（如跳过某项）→ 按用户指示调整后进入 Step 6，完成后进入 Step 12 生成报告
- 用户选择「仅生成报告」→ 跳过 Step 6-11，直接进入 Step 12。报告全部标注 `[未应用]`
- 用户取消 → 跳过 Step 6-11，直接进入 Step 12 生成报告。报告全部标注 `[未应用-用户取消]`。清理已提取的临时文件

> **禁止跳过此步骤**：即使用户在 Step 1 已指定了防护类型，也必须在此步骤
> 展示具体发现后再获得确认。用户可能只想做 try-catch 但不想加除零防护，
> 或者想跳过某些低风险项。

### Step 6: 生成修改后的完整脚本

> **前提**：用户已在 Step 5 确认修改方案。

在临时文本文件的基础上进行修改，生成完整的新脚本文件。
保留原始脚本的编码风格（缩进、换行、注释）。

**优先使用 Edit 工具**进行精确替换，避免手动重写整个脚本（容易引入格式差异）。

> **注入标记**：所有注入的防护代码均添加 `// __safe_guard` 注释作为标记，
> 便于在 Step 10 验证时区分**新增防护代码**与原始代码中已存在的相似模式。
> 每个注入点的首行或关键守卫行前添加此标记。

#### try-catch 包裹模板

Init()：
```csharp
public void Init()
{
    // __safe_guard
    try
    {
        // ... 原有代码 ...
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine("<displayName> Init异常: " + ex.Message);
    }
}
```

Process()：
```csharp
public bool Process()
{
    // __safe_guard
    try
    {
        // ... 原有代码 ...
        return true;
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine("<displayName> Process异常: " + ex.Message);
        return false;
    }
}
```

> `<displayName>` 替换为模块实际显示名称（如 `脚本1`）。若多个 ShellModule
> 脚本内容相同，从第一个生成后，通过字符串替换 displayName 生成其余副本。

#### 无限循环防护模板

while 循环守卫：
```csharp
// 注入在 while 循环之前：
// __safe_guard
// __safe_guard
        int __safe_iter = 0;
int __safe_max_iter = 1000000;

// 原始 while (xxx) 块体第一行注入守卫：
while (xxx)
{
    // __safe_guard
    __safe_iter++;
    if (__safe_iter > __safe_max_iter)
    {
        System.Diagnostics.Debug.WriteLine("<displayName> 循环可能无限，已强制退出");
        break;
    }
    // ... 原有循环体 ...
}
```

> **注意**：
> - `__safe_iter` / `__safe_max_iter` 使用 `__safe_` 前缀避免与用户变量冲突
> - 仅在 `while` / `for(;;)` 循环缺乏明确退出机制时注入
> - 若循环体内已有类似迭代计数器，跳过不注入

#### Step 6.5: 构建模块整合数据（`$modules`）

将 Step 2（`inspect --list` JSON）、Step 3（`$extractedScripts`）和 Step 6（修改后脚本路径）
关联为 Step 7 所需的统一数据结构：

```powershell
# 解析 Step 2 的 inspect --list JSON 输出
$listJson = '<inspect --list 的输出>' | ConvertFrom-Json
$shellModules = $listJson | Where-Object { $_.name -eq 'ShellModule' }

# Step 3d 约定：extractedScripts 与 shellModules 按顺序一一对应
if ($extractedScripts.Count -ne @($shellModules).Count) {
    # 若 Step 3e 做了去重（脚本内容相同的模块标记为一组），$extractedScripts.Count 会小于 $shellModules.Count。
    # 此时不阻断——用 $shellModules 作为映射骨架，把相同的脚本内容复制给每个副本模块。
    # 仅当 $extractedScripts.Count > $shellModules.Count（提取超量，映射不可靠）时才阻断。
    if ($extractedScripts.Count -gt @($shellModules).Count) {
        Write-Error "提取脚本数($($extractedScripts.Count))超过 ShellModule 数($(@($shellModules).Count))，映射关系不可靠"
        # 清理已生成的中间文件再退出
        Remove-Item "$solDir/shell_*_clean.txt" -ErrorAction SilentlyContinue
        Remove-Item "$solDir/shell_*_modified.txt" -ErrorAction SilentlyContinue
        exit 1
    }
    Write-Warning "提取脚本数($($extractedScripts.Count)) <  ShellModule 数($(@($shellModules).Count))，可能存在去重场景"

$modules = @()
for ($i = 0; $i -lt $extractedScripts.Count; $i++) {
    $sm = $shellModules[$i]
    $ext = $extractedScripts[$i]

    # 修改后的脚本路径（Step 6 输出）
    $modifiedPath = $ext.FilePath -replace '_clean\.txt$', '_modified.txt'

    $modules += [PSCustomObject]@{
        FullPath       = $sm.fullPath        # 如 "流程1.脚本1"
        DisplayName    = $sm.displayName     # 如 "脚本1"
        ScriptFilePath = $modifiedPath       # Step 6 生成的修改后脚本
        OriginalBody   = $ext.ScriptBody     # 用于去重检测
    }
}

Write-Output "已构建 $($modules.Count) 个模块的数据映射"
```

> **去重场景**：若 Step 3e 标记了多个脚本内容相同，副本模块的 `ScriptFilePath`
> 应为通过 `displayName` 替换后单独保存的副本文件，而非模板模块的修改后脚本。

### Step 7: 生成 changes.json

**必须用 PowerShell `ConvertTo-Json` 生成**，不要手动拼接 JSON 字符串
（手动拼接容易导致中文路径乱码，或 `\n` 转义后 CLI 写入长度异常）。

> **JSON 键名约定**：CLI 使用 PascalCase 键名。虽然 Newtonsoft.Json 默认大小写不敏感，
> 但使用规范格式可避免未来序列化器迁移时的兼容问题。

```powershell
$utf8 = [System.Text.Encoding]::UTF8

# 动态构建 changes 数组（覆盖所有 ShellModule）
$changes = @()
foreach ($m in $modules) {
    $scriptPath = $m.ScriptFilePath  # 来自 Step 6 生成的修改后脚本路径
    $script = [System.IO.File]::ReadAllText($scriptPath, $utf8)
    $changes += [PSCustomObject]@{
        Action    = 'setBinaryParam'
        Target    = $m.FullPath      # 如 "流程1.脚本1"（来自 Step 2）
        ParamName = 'ShellContent'
        Value     = $script
    }
}
$obj = [PSCustomObject]@{ Changes = $changes }
$json = $obj | ConvertTo-Json -Depth 5
# 不带 BOM 的 UTF-8
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText('<sol目录>/changes.json', $json, $utf8NoBom)
```

> **将多个 ShellModule 的修改合并到一个 changes.json 中**，一次 `modify` 调用完成所有修改。

### Step 8: 应用修改

```bash
"CLI" modify -f "<sol路径>" -c "<sol目录>/changes.json" -o "<sol目录>/output.sol" [-p <密码>]
```

确认输出中显示 `应用了 N/N 条修改`（N = ShellModule 数量）。若部分失败（如 `应用了 M/N`），
打印 warning 并告知用户哪些模块修改失败，不要继续覆盖原方案。

> CLI `modify` 命令执行后会生成 `<sol目录>/<时间戳>.modify.json` 报告文件，
> 记录每条修改的应用状态。Step 11 清理时会删除此文件。

### Step 9: 覆盖原方案

> **警告**：若 `<sol路径>.bak` 已存在（如重复执行过保护），将被静默覆盖。
> 多轮修改时建议使用带时间戳的备份名（如 `<sol路径>.bak.$(date +%s)`）。

```bash
# 先备份，再用 mv 原子替换（单条命令，避免 rm 成功但 mv 失败的数据丢失）
cp "<sol路径>" "<sol路径>.bak" && mv "<sol目录>/output.sol" "<sol路径>"
```

> 若 `mv` 失败，`.bak` 备份仍然存在，可安全恢复。恢复方法：`cp "<sol路径>.bak" "<sol路径>"`

### Step 10: 验证

由于 CLI 的 `parse`/`inspect` 对长脚本存在截断，**必须用二进制搜索验证**
关键防护代码是否写入：

#### 10a. 高效搜索函数

使用 .NET 原生 `String.Contains()` 替代逐字节暴力搜索（避免 PowerShell 嵌套循环
在大文件上的 O(n×m) 性能灾难）：

```powershell
$bytes = [System.IO.File]::ReadAllBytes('<sol路径>')
$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$content = $latin1.GetString($bytes)

function Test-Contains($content, $text) {
    return $content.Contains($text)
}
```

#### 10b. 验证项分类

**通用结构验证**（纯 ASCII 关键词，无中文风险）：

> **核心验证方式**：所有注入的防护代码均包含 `// __safe_guard` 注释标记。
> **先统计注入前后的标记增量**，再按选定的防护类型逐项验证对应关键词。
> 以下代码**必须**按 `$selectedProtections`（Step 1 确认的防护类型列表）过滤执行。

```powershell
# === 注入标记计数（最可靠的验证方式） ===
# 统计 sol 文件中 // __safe_guard 出现次数
# 每个注入点 = 1 个标记。预期数量 = 各防护类型的注入点数之和
$guardCount = ([regex]::Matches($content, '// __safe_guard')).Count
Write-Output "__safe_guard markers: $guardCount (预期 >= <Step 5 确认的注入点总数>)"

> **⚠️ 以上为全局关键词检查，不足以保证每模块注入成功。必须额外执行每模块验证：**
> ```powershell
> foreach ($m in $modules) {
>     $dn = $m.DisplayName
>     $found = $utf8Content.Contains($dn + " Init异常:") -and $utf8Content.Contains($dn + " Process异常:")
>     Write-Output "$dn : $(if($found){"✅"}else{"❌"})"
> }
> ```
> 任一模块 ❌ → 验证失败，不可进入 Step 11。

# === 以下按 Step 1 确认的 selectedProtections 条件执行 ===
if ($selectedProtections -contains 'try-catch') {
    Write-Output "try-catch: $(Test-Contains $content 'catch (Exception ex)')"
}

if ($selectedProtections -contains '除零') {
    Write-Output "__safe_min_f: $(Test-Contains $content '__safe_min_f')"
    Write-Output "__safe_divisor: $(Test-Contains $content '__safe_divisor')"
}

if ($selectedProtections -contains '数组越界') {
    # 具体判空变量名从 Step 4 实际注入的代码中提取
    Write-Output "null guard: $(Test-Contains $content '// __safe_guard')"
}

if ($selectedProtections -contains '无限循环') {
    Write-Output "loop guard: $(Test-Contains $content '__safe_iter')"
}
```

**模块级 displayName 验证**（使用 Step 2 获取的实际 displayName 动态构造）：

> **编码关键**：ASCII 关键词用 Latin-1 解码搜索。但中文 displayName 在 sol 中以 UTF-8 存储，
> Latin-1 解码会将中文字节拆为乱码，无法匹配。因此中文关键词需用 UTF-8 解码后搜索。
> 虽然 UTF-8 对二进制段会产生替换字符，但我们搜索的 `"<displayName> Init异常:"` 字符串
> 是由 Step 6 模板写入的有效 UTF-8 文本，位于脚本正文区域内，不会被替换字符干扰。

```powershell
# ASCII 通用结构用 Latin-1 内容验证（上面已完成）

# 中文 displayName 验证用 UTF-8 内容
$utf8Content = [System.Text.Encoding]::UTF8.GetString($bytes)

# $displayNames 从 Step 2 的 inspect --list 结果中提取
$displayNames = @('<模块1的displayName>', '<模块2的displayName>')
foreach ($dn in $displayNames) {
    $initKey = $dn + ' Init'   # 搜索 "<displayName> Init异常:"
    $procKey = $dn + ' Process'
    $initOk = $utf8Content.Contains($initKey)
    $procOk = $utf8Content.Contains($procKey)
    Write-Output "$dn Init: $initOk"
    Write-Output "$dn Process: $procOk"
}
```

> **VM 输入参数命名约定**：`in0`、`in1`… `inN` 是 VisionMaster ShellModule 脚本的
> 输入参数固定命名。VM 运行时将外部输入以 `HObject` / `float` / `int` / `List<T>`
> 类型传入。在 Step 4 分析中，判空检查针对的参数名取决于实际代码中使用到的
> `inN` 参数，验证时搜索关键词应**从 Step 4-6 实际注入的检查表达式中提取**，
> 而非假设所有脚本都检查了 `in0`。

#### 10c. 验证清单（全部通过才算成功）

| 验收项 | 关键词（ASCII） | 说明 |
|--------|----------------|------|
| 注入标记 | `// __safe_guard` | **首要验证**——所有注入点均有此唯一标记 |
| try-catch 结构 | `catch (Exception ex)` | 每个 ShellModule 的方法级 try-catch 存在 |
| 浮点除零防护 | `__safe_min_f` | 浮点除零阈值变量 |
| 整数除零防护 | `__safe_divisor` | 整数除零判零变量 |
| 数组/null 越界 | `// __safe_guard` + `== null` | 通过标记区分新旧判空代码 |
| 无限循环防护 | `__safe_iter` + `__safe_max_iter` | while 循环守卫 |
| 模块 displayName | `<displayName> Init` / `<displayName> Process` | 每个模块的 Debug 标识 |

> **注意**：
> - `// __safe_guard` 标记是区分**新增防护**与原始代码的最可靠方式
> - 验证关键词应与 Step 5 确认的**实际修改**对应，按 `$selectedProtections` 条件执行
> - 若用户仅选某几类防护，跳过未实施类型的关键词检查

#### 10d. 验证失败处理

若任一项验证失败：
1. 打印失败明细（哪个模块、哪个验证项失败）
2. 恢复原方案：`cp "<sol路径>.bak" "<sol路径>"`
3. 保留中间文件供调试，不执行 Step 11 清理
4. 告知用户验证未通过，可手动检查中间文件

#### 10e. PowerShell 编码注意事项

- 通过 bash 调用 PowerShell 时，中文可能因编码转换导致解析失败
- 二进制验证阶段使用 **Latin-1** 解码保证中文关键词可靠搜索
- ASCII 关键词（`catch`, `__safe_min_f`, `null`）作为首选验证关键词

### Step 11: 清理中间文件

验证通过后，删除本次操作产生的所有中间文件：

```bash
# 精确删除 Step 3-7 产生的中间文件（通配符限定在 <sol目录> 范围内，避免跨目录误删）
rm "<sol目录>/shell_"*"_clean.txt"          # Step 3 提取的干净脚本
rm "<sol目录>/shell_"*"_modified.txt"       # Step 6 修改后的脚本
rm "<sol目录>/changes.json"                 # Step 7 生成的修改指令
rm "<sol目录>/output.sol"                   # Step 8 CLI 临时输出
rm "<sol目录>/"*".modify.json"              # CLI modify 报告文件（如有）
```

不要删除：
- `<sol路径>.bak` — 原文件备份，保留供回滚
- 修改后的 `.sol` 文件本身

### Step 12: 生成分析报告（⚠️ 不可跳过——无论如何必须执行）

**此步骤不可跳过。** 无论用户选择：全部修改 / 部分修改 / 仅分析不修改 / 取消 —— **都必须生成**
一份 Markdown 报告，命名格式为 `<sol文件名>_代码防护报告.md`，存放于 sol 同目录。

**对应的修改状态标注**：
- 全部修改 → 报告标注 `[已应用]`
- 部分修改 → 报告区分 `[已应用]` / `[未应用-用户跳过]`
- 仅分析不修改 → 报告全部标注 `[未应用]`
- 用户取消 → 报告全部标注 `[未应用-用户取消]`

> **为什么必须生成？** 分析阶段（Step 4-5）已经产出了完整的诊断数据——每个模块的防护状态、
> 每个问题的 before/after 代码对比。这些数据是综合报告的输入源，不保存为独立报告就会丢失。
> 即使用户选择"跳过/不修改"，分析报告本身仍有独立价值（记录了什么问题、在哪个位置、建议怎么修）。

#### 报告内容

- **基本信息**：方案文件名、处理时间、防护类型、ShellModule 总数、备份路径
- **ShellModule 概览**：表格列出各模块的 fullPath、displayName、moduleId
- **分析结果明细**（每个模块）：
  - 每个防护点的修改前后代码对比（用 diff 代码块）
  - 位置标注（行号引用）
  - 防护状态标注：`[已应用]` / `[未应用-用户跳过]` / `[已有防护]`
- **安全分析结论**：已防护风险表（类型/位置/等级/状态）
- **修改统计**（如已应用）：修改模块数、各防护类型数量、脚本大小变化
- **回滚方法**（如已应用）：`cp` 命令示例

#### 修改状态标注

| 状态 | 含义 | 何时使用 |
|------|------|---------|
| `[已应用]` | 防护代码已写入 .sol | 用户确认修改，Step 6-9 执行成功 |
| `[未应用]` | 发现问题但未修改 | 用户选择「仅生成报告/暂不修改」或综合技能默认「只记录不修改」 |
| `[未应用-用户取消]` | 发现问题，用户取消操作 | 用户回复「取消/否」，跳过修改但 Step 12 仍强制生成报告 |
| `[已有防护]` | 此前已添加的防护 | 检测到 `__safe_guard` 标记或已有 try-catch 包裹 |

#### 向用户报告结果

```

✅ 脚本代码分析完成
- 方案: <sol文件名>
- 报告文件: <sol目录>/<sol文件名>_代码防护报告.md
- ShellModule 总数: <N>
- 发现问题: <X> 处（已修改: <Y> / 未修改: <Z> / 已有防护: <W>）
- [如已修改] 备份文件: <sol路径>.bak
```
## 常见问题处理

### Q: CLI inspect/parse 输出的脚本内容被截断？
`parsed` 字段和 `scriptText` 在 JSON 输出中对超过约 500 字符的内容会截断（显示 `...`或标记为 truncated）。必须使用 **Step 3 的二进制搜索法** 从 sol 文件中直接提取。

### Q: "using System;" 搜索命中多个位置，哪些是 ShellModule？
sol 文件中可能出现三类包含 `using System;` 的区域：
1. **GlobalScript JSON 内嵌**：在文件前部，`"ScriptContent":"using System;..."`（JSON 字符串内）
2. **ShellModule 二进制段**：在文件中后部，前有 `ShellContent` + NUL 填充标记
3. 其他脚本引用

ShellModule 脚本的特征：
- 前面有 `ShellContent` 标记 + 大量 NUL 字节填充
- 在 NUL 填充末尾通常有 `T` 字节（模块版本标记），紧跟 `using System;`
- 脚本结束后紧跟 `AssemblyGuid` 标记

### Q: modify 应用成功（N/N）但验证发现内容没变？
原因：CLI 在写入 ShellContent 时，JSON 中 `value` 的换行格式影响写入长度。
**解决**：用 `ConvertTo-Json` 生成 changes.json（Step 7），而不是手动字符串拼接。
用二进制搜索（Step 10）而非 parse 来验证，因为 parse 输出有截断。

### Q: modify 报 "未找到模块" 乱码？
changes.json 的 target 路径中文乱码，原因是文件编码不对。
**解决**：用 `New-Object System.Text.UTF8Encoding($false)` 写入（不带 BOM 的 UTF-8）。

### Q: ShellModule 脚本不包含 Init() 或 Process()？
非标准脚本模板，打印 warning，跳过该方法，仅修改存在的方法。

### Q: Process() 返回值不是 bool？
保持原始返回类型，catch 块中返回该类型的默认值（`null`/`false`/`0`）。

### Q: 方案已加密，用户不知道密码？
告知用户 CLI 工具不支持密码破解，需要提供正确密码才能修改。

### Q: PowerShell 脚本中嵌入中文导致解析失败？
通过 bash 调用 `powershell -Command "..."` 时，中文可能被错误编码。
**解决**：
- 验证关键词优先使用纯 ASCII（`catch`、`__safe_min_f`、`__safe_denom`）
- 中文 displayName 用 `[char]0xNNNN` Unicode 码点拼接
- 或将含中文的脚本写入临时 .ps1 文件（UTF-8 with BOM），再用 `powershell -File` 执行

### Q: 提取的脚本中文注释乱码？
检查是否将 Latin-1 字符串直接 `WriteAllText` 为 UTF-8。
**原理**：Latin-1 解码后 UTF-8 中文字节变为多个独立 Latin-1 字符（U+00xx），
以 UTF-8 写回时被重新编码为 2 字节（C2 xx / C3 xx），原始中文字节永久破坏。
**解决**：使用 Step 3c 的字节级提取法——Latin-1 仅定位 ASCII 边界，
脚本正文用 `[Array]::Copy` 提取原始字节后用正确编码（UTF-8/GB2312）解码。

### Q: ShellContent 标记在 256 字节窗口内没找到？
实测 `ShellContent` 距离 `using System;` 约 264 字节，已接近 256 边界。
较大脚本或复杂填充场景可能超出。已修正为 **512 字节**窗口。
若仍然漏检，可手动将窗口扩至 1024 字节或先用 `$text.IndexOf('ShellContent')`
全文搜索定位后回查距离。

### Q: 无限循环防护会误伤正常的 while 循环吗？
防护仅针对**缺乏明确退出机制**的 `while` 循环（无 `break`/`return`，条件变量不在
循环体内被修改）。若 while 循环已有退出逻辑，跳过注入。迭代上限设为
**1,000,000 次**，对正常数据处理循环影响极小；触发上限时输出 Debug 日志
并 `break` 退出，不会丢失数据（循环已执行 100 万次，之后的数据处理被跳过）。

### Q: 静态集合泄漏为什么不自动修复？
`static` 集合在多次 `Process()` 调用之间共享，是**跨请求缓存**的常见实现方式。
自动 `Clear()` 会破坏业务逻辑（如累积统计、历史记录）。因此仅报告警告，
由用户确认是否需要以及如何清理。
