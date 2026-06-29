# CLAUDE.md — vm-script-tutor 项目说明

> **加载说明**：本文件由 Claude Code 在打开本目录时自动加载，作为项目级上下文。Trae、Kimi Code 等其他 AI 编程工具不会自动加载本文件，但**推荐手动引用**——其中的设计决策与约束对所有 AI 工具同样适用，特别是"关键设计决策"和"给未来 Claude 的提醒"两节。
>
> 无论使用哪种工具，核心规则均以 `SKILL.md` 为准（所有工具均可读取）。本文件侧重记录**设计演进历史与决策背景**，帮助 AI 理解"为什么这样设计"。

## 项目概览

- **项目类型**：Claude Code Skill（不是可运行项目，而是一组规则 + 参考资料）
- **作者**：Mr.Buer
- **版本**：1.2
- **路径**：`C:\Users\zhusong6\.claude\skills\vm-script-tutor`
- **用途**：辅助用户编写、修改、排查 VisionMaster (VM) **2D** C# 脚本模块代码
- **不支持**：3D VisionMaster、Python 脚本模块、控制器 IO、UI 自动化、通讯协议解析

## 关键设计决策

### 1. 信息源边界（最高优先级红线）

**绝对禁止**反编译 VM 安装目录下的任何 DLL/EXE 文件。所有 C# 接口签名、数据结构、转换方法**必须且仅能**来自 `references/` 与 `examples/`。

**允许（且要求）读取的例外**：VM 安装目录下的 `AlgorithmTab.xml` 文本文件，用于查询具体算法模块的可设置参数名（Key）和参数值范围（MinValue / MaxValue）。详见决策 #15 和 SKILL.md §6。

历史教训：早期版本曾尝试反编译 `Script.Methods.dll` 推断接口，结果误用了 `GetIntArrayValue` 的 3 参版本（实际 partial property 走的是 `Conceal.InternalMethods` 的 2 参重载），生成的脚本编译失败。

### 2. 直接赋值范式

`UserProperty.cs` 与 `UserScript.cs` 是同一个 `partial class UserScript` 的两半。VM 把每个 UI 上添加的变量自动生成为 C# property（输入只读 `get`，输出只写 `set`）。**在 `UserScript.cs` 中应直接读写变量名**（`out0 = in0`），编译器自动转发到 property。

- partial property 的 `get` 内部对标量调用 `ScriptMethods.GetIntValue` 等（见 `references/Script.Interface.cs`）；对数组调用 `(InternalObject as InternalMethods).GetXxxArrayValue(...)` 2 参版本（见 `references/InternalMethods.cs`）
- **唯一允许使用遗留 Get/Set 接口的场景**：按字符串动态访问变量名（如遍历全局变量列表）

### 3. VM 版本差异：RoiboxData / ImageData 的 Heigth vs Height

- **VM ≤ 4.3**：`RoiboxData` 和 `ImageData` 的高度字段拼写为 `Heigth`（历史拼写错误，在 `InternalMethods.cs` 中能看到）
- **VM ≥ 4.4**：修正为 `Height`
- **`RoiboxData` 和 `ImageData` 均受版本影响**；`RectData.Height` / `Mat.Height` / `Bitmap.Height` 在所有版本中始终为 `Height`
- **强制规则**：生成代码前必须询问用户 VM 版本；未答复时默认 VM 4.4+ 并在配置清单中标注假设

### 4. 矩形框 / ROI 默认是 RoiboxData，不是 RectData

用户口语说"矩形框/ROI/识别框"时，**默认对应 ROIBOX → `RoiboxData[]`**（带角度）。`RECT → RectData[]` 是不带角度的轴对齐矩形，使用频率远低。判断顺序：先看 `UserProperty.cs` 实际类型；若用户未明确，按 `RoiboxData[]` 处理。

### 5. 多变量场景的消歧

`UserProperty.cs` 可能有多个同类型变量。当用户请求中涉及"两个矩形框"、"某个图像"等不指名描述，且存在 ≥2 个同类型候选时，**必须先列出所有候选并让用户指认**，禁止猜测。规则细节见 `SKILL.md` 的"生成前的强制确认事项 §2"。

### 6. 第三方库通过 VM UI 添加，不私自改 csproj

`*.csproj` 是 VM 根据脚本模块 UI"编辑程序集"配置**自动生成**的。本 skill **不应直接修改 csproj**。需要 OpenCvSharp 等库时：

- 读取 csproj 检查是否已存在
- 如缺失：在 UI 配置清单中列出需添加的 DLL 名、来源、版本要求，让用户在 VM UI 上添加后重新导出工程

### 7. 代码交付：默认直接覆盖 UserScript.cs

不让用户手动粘贴。流程：

1. 若 `UserScript.cs` 是 VM 默认模板（仅 `processCount = 0` + 空 `Process()`）→ 直接 `Write` 覆盖
2. 若已含用户业务代码 → 先备份为 `UserScript.cs.bak`，再覆盖
3. 用户明确说"不要改文件/我自己粘贴" → 改回粘贴模式

`UserProperty.cs` 与 `*.csproj` 永远不动。

### 8. PATH 环境变量检测 VM 版本（自动 + 用户确认）

不要每次都问用户 VM 版本。先用 `Bash` 读 PATH，按子串 `VisionMaster4.3.0` / `VisionMaster4.4.0` / 其他 `VisionMasterX.Y.0` 分支：

- 唯一匹配 → 告知用户检测结果，等用户回复（默认视为确认）
- 0 匹配 → 询问
- ≥2 匹配 → 列出已检测版本并请用户指定

详见 SKILL.md §1。

### 9. 强制做需求合理性分析（不能埋头写代码）

用户描述算子（如"求 IOU"、"对齐"）时，先把可能的歧义点列出来。典型场景："输入 ROI 与输入 ROI 数组求 IOU" —— `ROI` 是数组第 0 个？聚合方式是 max / 平均 / 全部返回？空数组怎么处理？

任何歧义点存在 → 列出全部歧义 + 给建议方案，让用户选；无歧义 → 重述一次让用户确认。详见 SKILL.md §3。

### 10. Process() 必须 try/catch + errorStatus 类字段

- 类内固定声明 `string errorStatus = string.Empty;`
- `Process()` 整段业务包在 `try/catch` 中；`catch` 内写 `errorStatus = "..." + ex.Message;` 并 `return false`
- **命名冲突**：若 `UserProperty.cs` 已有同名输入/输出变量，改用 `_errorStatus` / `__errorStatus` / `scriptErrorStatus`，并在 UI 清单告知
- `errorStatus` 默认只是类内字段，**不映射到 VM 输出**；若用户希望流程里看到异常，在 UI 清单提示新增 STRING 输出（如 `errorOut`）并 `errorOut = errorStatus`

### 11. 默认 OFF：不加 ShowMessageBox / ConsoleWrite / 日志

`ShowMessageBox` 会**暂停整个流程**，`ConsoleWrite` 需外部 DebugView，全局变量写入会污染流程。这三类都是对用户的副作用，**默认绝不主动添加**。

- 在 §4 实施大纲阶段显式询问"是否需要调试输出"
- 用户答不需要 → 仅写 `errorStatus`
- 用户答需要 → 按用户指定形式添加；弹窗注明"发布前删除"

所有 `examples/` 已按此规则清理（不再有默认的 `ConsoleWrite` / `ShowMessageBox`）。

### 12. 写代码前先给实施大纲（§4），等用户确认

确认完版本、变量映射、歧义后，**先给一份大纲**（VM 版本、输入/输出映射、异常字段、算法步骤、是否加调试输出、第三方库依赖），等用户回复"确认"或修订后再生成代码。不要在用户没确认前就贴完整 `UserScript.cs`。

### 13. C# 5.0 语法锁定（与 .NET 4.6.1 同等位置）

VM 内置 Roslyn 编译器锁定在 C# 5。常见禁用特性：`?.`（C# 6）、`$"..."`（C# 6）、`nameof`（C# 6）、表达式体成员 `=>`（lambda 之外）、自动属性初始化 `{ get; } = ...`、异常筛选器 `catch ... when`、`out var`（C# 7）、元组、模式匹配、`throw` 表达式、`??=`（C# 8）、`switch` 表达式等。允许：`??`（C# 2）、`var`、LINQ、Lambda、`async/await`（C# 5）。生成代码前自查；改 examples 时也按此规则。

### 14. 工作目录路径自动检测触发（条件 B）

**即使用户消息中没有任何脚本编程关键字**，只要当前工作目录路径包含 `VisionMaster` 或 `UserScript`（不区分大小写），本 skill 即视为触发。这是对传统"关键词匹配"触发机制的补充。

触发后：
- 若 skill 由条件 B 触发（无脚本关键字）→ **必须显式告知用户**检测到 VM 脚本工程路径，询问是否需要编写/修改脚本
- 若 skill 已由条件 A 触发（有关键字）→ 直接进入工作流，但仍告知检测到的路径

路径模式示例：
- `C:\Program Files\VisionMaster4.3.0\Applications\...\UserScript\UserScript_3`
- `D:\Projects\VisionMaster\...`
- `...\UserScript_0\`

此项改进的背景：用户可能打开 VM 脚本工程文件夹后直接说"帮我看看这个"、"这个怎么改"等不含脚本关键字的消息，旧版 skill 无法被触发。详见 SKILL.md "触发范围 §条件 B"。

## 文件用途速查

| 文件 | 用途 |
|------|------|
| `SKILL.md` | 技能主入口：规则、强制确认事项、工作流、文件索引 |
| `README.md` | 项目快速概览（人类阅读） |
| `CLAUDE.md` | 本文件（Claude 在本目录工作时的项目级上下文） |
| `output_report_template.md` | 生成代码后给用户的 UI 手动配置清单模板 |
| `assets/find_msbuild.ps1` | 定位本机 MSBuild.exe 路径（可选，供支持 shell 的工具执行真实编译时使用） |
| `examples/01-basic-template.cs` | 基础模板（Init/Process/Dispose） |
| `examples/02-canny-edge-detection.cs` | OpenCvSharp 图像处理示例 |
| `examples/03-roi.cs` | ROI 处理示例（标注假设 VM 4.4+） |
| `examples/04-trans-CAD-file.cs` | CAD 文件转换示例 |
| `examples/05-halcon-image-conversion.cs` | Halcon ↔ ImageData 互转示例 |
| `examples/interface-quickref.md` | 变量类型映射 + 接口速查 |
| `examples/code-patterns.md` | 14 种场景代码模式库 |
| `references/Script.Interface.cs` | ScriptMethods 标量 Get/Set 公开签名 |
| `references/Script.DataStruct.cs` | 几何与图像数据结构定义 |
| `references/Script.ExMethods.cs` | Mat / Bitmap ↔ ImageData 转换 |
| `references/InternalMethods.cs` | Conceal.InternalMethods（数组 Get/Set 2 参版本，partial property 实际调用路径） |
| `references/csharp_api.md` | 官方开放接口完整列表 |
| `references/csharp_debug.md` | VS 附加 VM 主进程断点调试步骤 |
| `references/module-param-workflow.md` | §6 模块参数设置/获取完整工作流（步骤 0–4 + 降级处理汇总） |
| `references/VisionMaster模块映射表.md` | 工具箱中文名 ↔ 英文名 ↔ 模块英文名映射（AlgorithmTab.xml 路径查询前置依赖） |

## 演进历史（要点）

按时间顺序，仅记录会影响"为什么这样写"的关键决策。

1. **从 `vm-script-skill` 派生**：本 skill 在 `vm-script-skill` 基础上整合了 VS 调试文档、官方开放接口完整列表、UI 配置清单模板
2. **真实工程验证**：用户曾让 skill 分析 VM 4.3 导出的真实 `UserScript_0` 工程，发现 5 处描述异常：
   - `using` 列表少了 `System.Text` / `System.Windows.Forms`
   - 数组 Get/Set 实际走 `InternalMethods` 2 参版本，不是 `ScriptMethods` 3 参版本
   - 缺少 `nErrorCode`、`InternalObject`、`Conceal` 命名空间的文档
   据此引入了 `references/InternalMethods.cs`（来自 `D:\InternalMethods.cs`），并改写 SKILL.md 的标准模板、工作原理、调试输出章节
3. **RoiboxData 版本差异**：用户指出 VM 4.3 拼写 `Heigth`，4.4+ 才修正为 `Height`。新增"生成前强制确认版本"环节
4. **多变量消歧**：用户提出"多输入输出参数时是否需让用户指名"，确认**必须指名**，新增"§2 多变量场景"规则
5. **直接覆盖 UserScript.cs**：把交付方式从"输出代码让用户粘贴"改为"直接 Write 覆盖（自动备份）"
6. **3D 不支持**：明确告知用户本 skill 仅覆盖 2D；在询问 VM 版本时一并确认产品形态
7. **清理首版冗余**：移除"扩展范式 / 扩展清单"等面向未来版本的内容；移除 `examples/README.md` 与 `references/README.md`（与 SKILL.md 文件索引重复）
8. **Round D 五项加固**（5 条新规则，对应"关键设计决策"第 8–12 节）：PATH 自动检测 VM 版本、需求合理性分析、`Process()` 强制 try/catch + errorStatus 字段、写代码前先给实施大纲、默认 OFF 的调试输出策略；同步清理了所有 `examples/*.cs` 与 `code-patterns.md` 中默认的 `ShowMessageBox` / `ConsoleWrite` 调用
9. **工作目录路径自动检测**（2026-06-01）：新增触发条件 B —— 当工作目录路径包含 `VisionMaster` 或 `UserScript` 时，即使用户未提脚本编程关键字，skill 也自动激活并显式询问用户。在 SKILL.md 新增"触发范围 §条件 B"章节、在代码生成工作流增加 Step 0、在自校验清单增加对应条目
10. **模块参数设置工作流**（2026-06-02）：用户要求脚本能设置/获取算法模块运行参数（如轮廓匹配角度范围）。核心问题是参数 Key 名无法凭记忆获得，必须从 VM 安装目录下各模块的 `AlgorithmTab.xml` 读取。同步放开"允许读取 XML 文件"的授权例外（原规则是绝对禁止读取安装目录任何文件），新增 SKILL.md §6 完整工作流、Step 2b、自校验条目，新增 code-patterns.md 模式 13，更新 interface-quickref.md §5 和 csharp_api.md SetValue 章节，更新 CLAUDE.md 决策 #1 和 #15

## 编辑本 skill 时的注意事项

- 改 `SKILL.md` 前先想清楚：是规则变化，还是只是描述更清晰？规则变化必须同步更新"自校验清单"
- 增加新示例 `.cs` 时，同步在 `SKILL.md` 的"文件索引"与"代码生成工作流 Step 4"表中加行
- `references/` 下的 `.cs` 是只读权威参考，**不要按你自己的理解修改**它们；只有当原始 DLL 反编译结果变化时才更新
- 改 `output_report_template.md` 时确保占位符语法（`{{xxx}}`）一致，避免用户读到模板时混乱
- **永远不要**在 skill 内引用 VM 安装目录的绝对路径作为示例（除调试章节明确说明的 `vServerApp.exe.config` 和 §6 AlgorithmTab.xml 路径构造说明外）
- AlgorithmTab.xml 中的参数节点结构可能因 VM 版本或模块不同而有细微差异，读取时注意容错

## 给未来 Claude 的提醒

- **先执行 Step 0**：检查工作目录路径是否包含 `VisionMaster` 或 `UserScript`。命中且用户没提脚本关键字时，务必先显式询问；命中且用户已提脚本关键字时，告知检测到的路径后继续
- 用户的需求往往以"补一个功能"、"加个判断"开头，但你要先按 SKILL.md §1 用 PATH 检测 VM 版本，再读 `UserProperty.cs` 决定变量映射，再读 `UserScript.cs` 决定改动位置
- 不要急着写代码。先按 SKILL.md 的 Step 1–5 走完：版本 → 文件 → 变量消歧 → 需求合理性 → 实施大纲 → **等用户确认** → 才进入代码生成
- 默认不加 `ShowMessageBox` / `ConsoleWrite`；错误统一走 `errorStatus` 字段
- 静态审查失败时优先检查：变量名拼写、`RoiboxData`/`ImageData` 的 `Heigth`/`Height` 版本拼写、`Mat` 是否 Dispose、是否误用了 4.6.1 之后的 API 或 C# 6+ 语法、`errorStatus` 是否与 `UserProperty.cs` 中变量重名；真实 MSBuild 编译仅在工具支持 shell 且用户已导出工程时才执行（可选）
- **模块参数场景**：必须先查 `references/VisionMaster模块映射表.md` 获取工具箱英文名 + 模块英文名并显式告知用户确认，再构造路径读 AlgorithmTab.xml 查参数 Key；映射表查询和 XML 查询均不得猜测；超限告知用户；全链路走 §6 工作流

### 15. 模块运行参数设置：参数名来自 AlgorithmTab.xml，禁止猜测

用户要在脚本中设置算法模块参数时（如角度范围、查找数量），参数名（Key）**必须**从对应模块的 `AlgorithmTab.xml` 文件中查询获取，严禁凭记忆或命名习惯推断。

**XML 路径规律**：
```
{VM根目录}\Applications\Module(sp)\x64\{工具箱英文名}\{模块英文名}\{模块英文名}AlgorithmTab.xml
```
例如轮廓匹配：`...\Location\IMVSContourMatchModu\IMVSContourMatchModuAlgorithmTab.xml`

**XML 节点**：`<Name>` 内容即为 Key；`<MinValue>` / `<MaxValue>` 定义参数范围。

**范围超限**：用户输入的参数值超出范围时，必须明确告知，禁止生成超限代码。

**授权调整**：为支持此功能，原"绝对禁止读取 VM 安装目录文件"规则已细化：
- 仍然禁止：读取/反编译 DLL、EXE 等二进制文件
- 现在允许：读取 AlgorithmTab.xml 文本文件（用于获取参数 Key 和范围）

**代码模板**：
```csharp
CurrentProcess.GetModule("模块名").SetValue("参数Key", "值字符串");
```

完整工作流见 SKILL.md §6。与历史教训（误用 `GetIntArrayValue` 3 参版本）同理：所有接口信息必须来自权威来源，不得推断。

### 16. 模块中文名 → 英文名映射表（AlgorithmTab.xml 路径查询的前置步骤）

用户通常只知道模块的中文名（如"单点抓取"），而 AlgorithmTab.xml 位于以模块英文名命名的子目录下（如 `Calculation\SinglePointGrabModu\`）。因此新增 `references/VisionMaster模块映射表.md`，作为从中文名到文件路径的桥梁。

> **版本约束**：映射表基于 **VM 4.3** 整理。VM 4.4 / 5.0 等后续版本会新增模块（新工具箱或现有工具箱下的新模块），因此映射表查不到时，可能为版本差异，应提示用户提供工具箱英文名和模块英文名，而非直接判定为"模块不存在"。

**查询流程**：
1. 读取 `references/VisionMaster模块映射表.md`
2. 按用户提到的模块中文名精确匹配，获取**工具箱英文名**和**模块英文名**
3. **必须显式告知用户**查询结果（工具箱 + 模块英文名）并请求确认
4. 用户确认后，用这两个英文名构造 AlgorithmTab.xml 路径
5. 若映射表中找不到、或目录校验失败，**显式告知用户**具体缺失什么，不得自行推断

**路径构造公式**：
```
{VM根目录}\Applications\Module(sp)\x64\{工具箱英文名}\{模块英文名}\{模块英文名}AlgorithmTab.xml
```

> 与决策 #15（参数名来自 AlgorithmTab.xml）一脉相承：工具箱名和模块英文名也不得猜测，必须来自映射表这一权威来源。
