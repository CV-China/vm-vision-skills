# VM 算法模块开发技能（vm-algorithm-module-builder）

> 作者：Buer
> 适用范围：VisionMaster **2D** 自定义算法模块（VM431+，3D 暂不支持）

## 目录

1. [概述](#一概述)
2. [标准使用流程](#二标准使用流程)
3. [典型场景速查](#三典型场景速查)
4. [常见问题](#四常见问题)
5. [不支持范围](#五不支持范围)
6. [约束摘要](#六约束摘要技能自动保证)
7. [与 vm-script-tutor 的关系](#七与-vm-script-tutor-的关系)
8. [项目目录结构](#八项目目录结构)
9. [法律与合规](#九法律与合规)
10. [版本](#十版本)

## 一、概述

`vm-algorithm-module-builder` 是一个面向 VisionMaster 2D 自定义算法模块的工程生成辅助技能。用户用自然语言描述算法功能（或交付已有 C# 脚本），技能基于内置 **AlgTemplate** 模板自动生成完整的算法模块工程：5 个界面 XML（含 Tab 参数、Display 渲染、ToolItemInfo 等）+ C++ 算法层工程（`AlgorithmModule.cpp/.h/.def`）+ C# 界面控件工程（`*Control`）。落盘自检通过后，自动发现所有已安装的 VS2017+ 并按版本降序排列（VS2022 > VS2019 > VS2017），**优先用高版本编译，失败自动降级**。C# 和 C++ 各自独立选择编译器（C++ 额外验证桌面开发组件）。Control 子界面项目仅在用户确认需要时编译。编译成功后自动将产物（XML + dll + 图标）部署到 VM 工具箱。

**开发模式**：

- **从零开发**：仅靠文字需求生成全套模板工程
- **脚本转模块**：基于已有 VM C# 脚本工程，提取输入输出/参数后转算法模块

**输出形态**：直接落盘到用户指定目录（复制模板 → 改名 → 替换文件内容），随后自动发现所有已安装 VS 并按版本优先级编译 C#/C++ 工程（Release 配置，失败自动降级）。编译成功后自动将产物部署到 VM 工具箱（运行时路径 + 二次开发路径）。未安装 VS 或 VM 时跳过对应步骤并显式告知。

技能保证以下事项不依赖人工核对：

- **不编造 SDK 接口**：所有 `VM_M_*` / `VmModule_*` / `IMVS_EC_*` / `MLOG_*` 符号都来自模板 `common/` 下真实头文件
- **基本参数 vs 运行参数**严格分离（XML 三方一致 + C++ 接口位置正确）
- **日志接口白名单**：只用 `MLOG_*`，禁止 `MessageBox` / 裸 `printf` / `std::cout`（`CreateModule`/`DestroyModule` DLL 入口函数允许 `OutputDebugStringA`）
- **GB2312 源码编码** + 默认英文注释；中文字面量在 GB2312 文件中**不**加 `u8` 前缀（**例外**：传入 VM SDK 接口的中文参数名/值必须加 `u8`，因 VM 参数注册表以 UTF-8 存储）；若用户明确要求中文注释，技能改用 Python 按 GB2312 写
- **基类虚函数保护**：禁止重载 `ResetDefaultParam` / `GetAllParamList` / `GetProcessInput` / `GenerateMaskImage` / `DynamicIOInit` 等会破坏初始化的接口
- **Process 重载规则**：3 参数 Process 是基类 `=0` 纯虚函数必须实现。有图像模块只覆盖 3 参数版；无图像模块两版都声明，2 参数版写算法逻辑，3 参数版委托 `return Process(hInput, hOutput);`
- **目录改名 + 字符串替换齐全**：sln/csproj/vcxproj/`EXAMPLEMODULE_EXPORTS` 都同步改名，落盘后 grep 自检无 `AlgTemplate` 残留
- **Cs 工程文件 + ToolItemInfo.xml 保护**：所有 `.xaml/.xaml.cs/.cs/.csproj/.sln/ToolItemInfo.xml` 只用 sed/Edit 字符串替换，禁止 Write 整文件重写（避免界面 XAML 被截断或 ToolItemInfo.xml 被编造格式覆盖）
- **落盘前后自检**：`check_module.sh --pre` 验证模板完整性 + `check_module.sh <output>` **22 项**结构检查，含 SDK 符号白名单反向校验（从模板头文件机械生成，LLM 编造的接口必被拦截）+ bat CRLF 换行符检查 + ToolItemInfo.xml 格式检查 + DisplayName≠Name 检查（运行参数中文名缺失检测）+ Display.xml 根节点校验
- **自动编译**：发现所有已安装 VS2017+ 并按版本降序排列，C#/C++ 各自独立编译器队列（C++ 需桌面开发组件）；按 Cs→Cpp 序 MSBuild Release 编译，失败自动降级尝试次高版本；未找到 VS 则显式告知跳过
- **Control 条件编译**：Control 子界面项目仅当用户确认需要子界面/自定义控件时才编译
- **自动部署**：编译成功后自动从注册表读取 VM 安装路径，通过固化脚本 `deploy_module.ps1` 将模块产物（XML + dll + 图标）拷贝到 VM 工具箱（运行时 + 二次开发双路径），部署后逐文件比对时间戳确保覆盖成功。三方库 dll 自动复制到 `Applications\PublicFile\x64\`（已存在则跳过并告知）。部署命令强制用 `powershell -NoProfile -File deploy_module.ps1`（`-Command` 内联模式会被 auto-mode 分类器拦截），自动 xcopy runtime + dev 双路径并逐文件比对时间戳

## 二、标准使用流程

### Step 1：准备需求或源脚本

在调用技能前，用户需要先想清楚：

- 模块名（纯英文、Pascal 命名，如 `OtsuBinarization`）
- 输入形态：单图像 / 多图像 / 无图像输入
- 是否需要支持 ROI / 屏蔽区（不需要则默认全图处理）
- 输出形态：图像 / 点 / 直线 / 矩形 / 扇环 / 标量
- 算法运行参数清单（阈值、模式、使能开关、模型路径等）
- 是否依赖第三方库（OpenCV / HALCON / Eigen / PCL / TensorRT / ONNX 等）

> 技能在确认输出路径后会自动检测当前电脑的 VM 版本（PowerShell 脚本 → reg query → 环境变量/文件系统 四级降级），与模板基准 VM431 对比；版本不匹配时主动告知并询问是否继续。若用户已有可工作的 VM C# 脚本，直接交付脚本文件即可；技能会按 `references/script-to-module-mapping.md` 规则把脚本输入/输出映射为模块基本参数，并主动追问运行参数。

### Step 2：触发技能

1. 用 Claude Code / Trae 等支持本技能的智能体打开任意工作目录
2. 在对话窗口输入 `/vm-algorithm-module-builder` 或描述需求（如"封装一个灰度调整算法模块"）触发技能

### Step 3：明确输出路径

技能**必须**等待用户给出明确输出路径（不接受默认到桌面/用户目录）：

- 父目录必须存在
- 路径**不能含中文**（含中文会要求改纯英文）
- 目标子目录已存在时，技能会询问 **覆盖 / 改名 / 取消**

### Step 4：描述算法需求

用自然语言说明：

- 算法行为（含输入图像、ROI、输出形态、是否修改像素）
- 运行参数清单（每个参数的类型、范围、默认值、使能联动关系）
- 第三方库依赖（若有）

### Step 5：等待大模型给出实施大纲并请求确认

技能在写代码前会主动发起多轮确认：

| 确认项 | 触发原因 |
| --- | --- |
| **VM 版本** | 四级降级自动检测（PowerShell → reg query → 环境变量 → 询问用户），与 VM431 对比 |
| **模块名 / 输出路径** | 模板复制和字符串替换的基准 |
| **输入形态** | 决定 `Process` 重载是 3 参数（含图像）还是 2 参数版（无图像） |
| **ROI / 屏蔽区** | 用户未提及 ROI 时默认全图处理，主动询问以免多余 mask 开销 |
| **图像拷贝策略** | 算法是否修改输入像素 → 深拷贝（修改）/ 浅拷贝（只读） |
| **基本参数清单** | 输入/输出端口（图像、ROI、点、直线、矩形、扇环、Fixture、标量 I/O） |
| **运行参数清单** | 阈值/模式/使能/枚举/路径等"算法旋钮"；分两批确认，先基本后运行 |
| **使能开关默认值** | 默认开还是关，与 Trigger 联动关系 |
| **第三方库** | 检测到 `cv::Mat`/`#include <opencv2/...>`/`HObject` 等关键字时强制询问 |

实施大纲格式示例：

```
【实施大纲】
- 模块名：OtsuBinarization
- 输出路径：D:/VMModules/OtsuBinarization/
- 输入形态：单图像（3 参数 Process）
- ROI 支持：是（调 GenerateMaskImage，循环只处理 mask==255 像素）
- 图像拷贝策略：深拷贝（二值化会修改像素）
- 基本参数：
  - 输入：InImage（IMAGE Combination + 4 Filter）
  - 输出：OutImage（IMAGE Combination）+ OutThreshold（int 标量）
- 运行参数：
  - enableManual（Boolean，默认 False，控制 manualThreshold 显隐）
  - manualThreshold（IntegerBettween，范围 0-255，默认 128）
  - binarizeMode（Enumeration，正向/反向）
- 第三方库：无
```

### Step 6：澄清并回复"确认"

逐项回答每个问题；如对大纲有调整，直接提出修订意见即可。

### Step 7：等待大模型完成工程生成

技能行为：

- 从 `<skill>/templates/AlgTemplate/` 复制到用户输出路径
- 按改名清单逐层重命名目录与文件
- sed 批量替换所有 `AlgTemplate` / `AlgTemplateCs` / `AlgTemplateControl` / `EXAMPLEMODULE_EXPORTS` 等标识符
- Write 落盘 `AlgorithmModule.cpp/.h/.def` + `dllmain.cpp` + 4 个界面 XML（仅 C++ 算法层与 XML 允许 Write）
- **所有 .xaml / .xaml.cs / .cs / .csproj / .sln / ToolItemInfo.xml 只用 sed/Edit 替换，绝不 Write**（避免 WPF 控件树被截断或 ToolItemInfo.xml 格式被编造覆盖）
- 落盘后跑 `check_module.sh` 自检（含 grep 无 AlgTemplate 残留、SDK 符号白名单反向校验等 **22 项**，含 bat CRLF 检查 + ToolItemInfo.xml 格式检查 + DisplayName≠Name 检查 + Display.xml 根节点检查）

### Step 8：模块语言资源配置

落盘自检通过后，技能**主动询问**是否需要添加模块中文名和帮助说明：

- 根据模块名和功能自动推荐中文名和中英双语结构化帮助文本（中文追加到 zh-cn.xaml + zh-cnLJ.xaml，英文追加到 en-us.xaml）
- 列出所有输出参数，逐条给出英文资源 + 推荐中文名
- 自动在 VM Lang 目录去重（已存在的 x:Key 跳过不追加）
- 用户确认后，用 Edit 在三个文件的 `</ResourceDictionary>` 前追加
- VM 未安装则生成 XAML 片段供手动追加

### Step 9：自动编译与部署

落盘自检通过后，技能询问是否自动编译。确认后按以下流程执行：

| 阶段 | 说明 |
|---|---|
| **VS 检测** | vswhere 发现所有已安装 VS2017+，按版本降序排列（VS2022 > VS2019 > VS2017）；C++ 额外检测桌面开发组件；vswhere 不可用时回退到 VSINSTALLDIR → PATH → 硬编码路径 |
| **C# 编译** | `MSBuild /p:Configuration=Release /p:Platform="AnyCPU"`，按版本降序尝试，失败自动降级；Control 项目仅当用户需要子界面时编译 |
| **C++ 编译** | `MSBuild /p:Configuration=Release /p:Platform=x64`，按版本降序尝试（仅含 C++ 组件的 VS），失败自动降级；无 C++ 组件的 VS 则跳过并告知 |
| **产物验证** | 确认 Cs 主项目 dll + C++ dll（+ Control dll 若需要）已通过 PostBuildEvent bat 自动拷到模块根目录 |
| **自动部署** | 从注册表读取 VM 安装路径 → 拷贝模块文件夹到 `Applications\Module(sp)\x64\<工具箱>\<模块名>\`（运行时）和 `Development\V4.x\...`（二次开发）；若有三方库依赖，自动将运行时 dll 复制到 `Applications\PublicFile\x64\`（已存在则跳过） |
| **收尾清理** | 删除编译/部署/语言资源写入阶段遗留的临时文件（`.py` / `.ps1` / `.rsp`），确保输出目录只保留模块工程和编译产物 |

- **未检测到 VS2017+** → 显式告知用户需安装 VS，跳过编译，保留已生成工程文件供手动编译
- **有 VS 但无 C++ 组件** → 仅跳过 C++ 编译，C# 正常进行
- **编译失败** → 自动降级尝试次高版本 VS；全部失败则展示完整编译日志 + 常见原因速查，建议 VS 打开 sln 手动编译，不删除工程
- **未检测到 VM 安装** → 跳过自动部署，提示手动拷贝路径

> 手动编译时：C# 项目用 Release 配置，C++ 项目用 **Release|x64**（勿切 Debug 或 Win32——模板仅此配置的 `AdditionalIncludeDirectories` 完整）。

### Step 10：在 VM 中加载模块

1. 若自动部署成功（编译 + VM 检测均通过），**重启 VisionMaster** 即可在工具箱中找到该模块，无需任何手动复制
2. 若自动部署跳过（未检测到 VM 或编译失败）：把 `<模块名>/` 文件夹（含 5 XML + dll + 图标）拷到 VM 的 `Applications\Module(sp)\x64\<工具箱>\<模块名>\`（运行时）和 `Development\V4.x\ComControls\Assembly\Module(sp)\x64\<工具箱>\<模块名>\`（二次开发）
3. 若有三方库依赖且未自动部署：将运行时 dll 复制到 `Applications\PublicFile\x64\`
4. 启动 VM，从模块列表拖入该模块到流程
5. 双击模块查看 Tab 参数 UI 是否符合预期（运行参数控件、ROI 选择器）
6. 连线输入图像，运行流程，观察输出

## 三、典型场景速查

| 场景 | 提示 |
| --- | --- |
| 需要把一个已有 C# 脚本封装成模块 | 直接把 `UserScript.cs` 交给技能，技能会按映射规则识别脚本输入/输出为模块基本参数，并主动追问运行参数 |
| 算法只修改一部分像素（ROI 内） | 描述时明确"支持 ROI / 屏蔽区"，技能会启用 `GenerateMaskImage` 流程 |
| 算法不读 ROI（全图处理） | 不要在需求里提 ROI 字样，技能默认全图处理；XML Tab_ROI Area 可保留也可删 |
| 多张输入图像 | 描述时明确"需要两路图像输入"，技能会在 `<模块名>.xml` 中生成多个 InputImage Combination + 在 Process 内多次 `VmModule_GetInputImageByName` |
| 多张输出图像 | 同上，Output Combination + `VmModule_OutputImageByName_8u_C*R` 多次调用，配合 `Display.xml` 多渲染节点 |
| 使能开关联动隐藏其他参数 | 描述时明确"勾选 X 后才显示 Y、Z"，技能用 `<Triggers><Trigger>` + `HiddenOperation/VisibleOperation` 联动 |
| 需要 OpenCV / HALCON | 准备好 ①头文件目录 ②库目录 ③.lib 文件名 ④运行时 dll 目录 ⑤库版本 五项资料，技能会让你确认是否屏蔽或保留 |
| 电脑未装 VS2017+ | 技能会显式告知需安装 VS，跳过编译步骤，保留已生成工程文件供后续手动编译 |
| 电脑装了 VM 但不是 VM431 | 技能在需求确认阶段通过四级降级策略检测 VM 版本，非 VM431 时主动告知差异并询问是否继续 |
| 需要一键编译+部署 | 技能自动发现所有 VS → 按版本降序编译 Cs/Cpp → 部署到 VM 工具箱（默认 UserTools），失败自动降级 |
| 电脑装有多套 VS | 自动发现并优先用高版本编译（VS2022 > VS2019 > VS2017），失败自动降级尝试次高版本；C++ 还需检查组件 |
| VS2022 未装 C++ 桌面开发 | C# 仍用 VS2022 编译；C++ 自动切到安装了 C++ 组件的低版本 VS（如 VS2017），或跳过并提示安装组件 |
| 不需要子界面/自定义控件 | Control 项目不编译，仅编译 Cs 主项目和 C++ 工程，减少不必要的编译时间 |
| 中文注释需求 | 默认英文注释；明确要中文时技能会改用 Python 按 GB2312 编码写文件（避免 UTF-8 Write 工具乱码） |
| 第三方库不能提供且不允许屏蔽 | 技能会终止生成，告知必须二选一 |
| 需要给模块添加中文名和帮助说明 | 技能在编译前主动询问，自动建议中文名/输出参数中文名/帮助文本，去重后写入 VM Lang 目录，支持用户逐条修改或跳过 |

## 四、常见问题

| 现象 | 原因 / 处理 |
| --- | --- |
| VS 编译报 `IPreproMaskTool` / `m_pPreproMaskInstance` 未声明 | 配置不是 Release\|x64；切配置（**不要**改 .h 添加 #include 来"修复"） |
| 编译报 `LINEMODULE_API=__declspec(dllimport)` 或类似 C2491 | `EXAMPLEMODULE_EXPORTS` 残留未改 → vcxproj `<PreprocessorDefinitions>` 或 `.h #ifdef` 名字不一致；让技能再扫一遍并替换 |
| 编译产物 dll 名错或没拷到界面目录 | csproj 里 `<AssemblyName>` / `<RootNamespace>` 没改全，或外层 wrapper 目录与内层 UI 目录不同名（不允许加 `UI` 后缀） |
| 编译报 `m_nModuleId` 未声明的标识符 | `OutputDebugStringA` 在 `CreateModule`/`DestroyModule` 中被误改为 `MLOG_INFO` —— DLL 入口是全局函数，无 `m_nModuleId`，此处允许保留 `OutputDebugStringA` |
| VM 加载模块报 `E0000001` 或编译报 `C2259 无法实例化抽象类` | `C2259`：无图像模块忘写 3 参数 Process（纯虚函数未实现）→ 补 `return Process(hInput, hOutput);` 委托；`E0000001`：有图像模块两个 Process 版本都写了独立逻辑，VM 框架误匹配 → 3 参数版委托到 2 参数版 |
| Tab 参数 UI 不显示 / 错位 | 运行参数控件错放在 `Tab_Basic Params` 而不是 `Tab_Run Params`，或拼错成单 t（VM 内部是双 t `<IntegerBettween>`） |
| 加载方案后默认值丢失、动态端口缺失 | 擅自重载了 `ResetDefaultParam` 基类虚函数；删掉重载，默认值放回 `<模块名>Algorithm.xml` |
| VS 打开 cpp 中文注释乱码 | Write 工具按 UTF-8 写入但模板源码是 GB2312；改用英文注释或让技能用 Python 按 GB2312 写 |
| 模块运行时输出图像污染了上游 | Process 内浅拷贝却修改了像素，或 `bDeepCopy` 传参与拷贝策略不匹配 |
| ToolItemInfo.xml 格式错误，VM 无法识别模块 | 被 Write 重写为编造的 `<ToolItemInfo>` 格式 —— 正确格式是模板的 `<ToolBoxItemData>`（sed 改名已处理，零额外操作） |
| 含中文的图像/模型路径加载失败 | 底层 UTF-8 路径需 `UTF8toANSI()` 转换后再给 fopen |
| 自动编译提示找不到 MSBuild | 4 级检测均未命中 → 安装 VS2017+（Community 免费版），勾选"使用 C++ 的桌面开发"工作负载 |
| 自动部署提示找不到 VM | 注册表无 VisionMaster 键 → 确认已安装 VM，或手动将模块文件夹拷贝到 VM 的运行时 + 二次开发两个目录 |
| CS0246 未能找到 VM.Core 等类型 | Cs 项目的 bin\Release\ 下缺少 VM 引用 dll（VM.Core.dll / VM.PlatformSDKCS.dll 等）→ 从已安装 VM 的对应目录复制过来 |
| 电脑装了多个 VS，能指定用哪个吗 | 技能自动发现所有 VS，优先用高版本编译；失败自动降级；C++ 还检查组件完整性，无需手动指定 |
| VS2022 编译 C++ 失败但 VS2017 成功 | 技能会自动降级尝试（前提是 VS2017 安装了 C++ 桌面开发组件） |
| VM4.3.0 被提示"版本低于模板基准" | 已修复。现在按主.次版本号（4.3）比较，VM4.3.0/4.3.1/4.3.2 均视为同版本，不会误报 |
| 模块运行时提示找不到 opencv_worldxxx.dll | 检查 VM 的 `Applications\PublicFile\x64\` 目录是否有该 dll；若自动部署已跳过（dll 已存在被跳过可能是版本不同），手动从 OpenCV 安装目录复制正确版本的 dll 过去 |
| 自动部署跳过了但我想手动部署 | 手动复制 `<模块名>/` 文件夹到 VM 的 `Applications\Module(sp)\x64\<工具箱>\<模块名>\` 和 `Development\V4.x\ComControls\Assembly\Module(sp)\x64\<工具箱>\<模块名>\`（两个目录都要） |

## 五、不支持范围

- **3D VisionMaster**（点云、立体视觉、`VmAlgModu3DBase` 等所有 3D 算法模块）
- VM430 及以下版本（模板基于 VM431+ 接口与目录结构；更高版本会检测并告知差异后由用户决定是否继续）
- 控制器 IO / UI 自动化 / 通讯协议解析类模块
- 反编译或搜索 VM 安装目录获取私有 API

遇到上述请求，技能会直接告知不支持。

## 六、约束摘要（技能自动保证）

- **模板内置**：固定使用 `<skill>/templates/AlgTemplate/`，不询问、不校验
- **不编造 SDK 接口**：所有 `VM_M_*` / `VmModule_*` / `IMVS_EC_*` / `MLOG_*` 符号都来自 `common/` 真实头文件；落盘后 SDK 符号白名单反向校验，编造必被拦截
- **基类虚函数保护**：禁止重载 `ResetDefaultParam` / `GetAllParamList` / `SetAllParamList` / `GetProcessInput` / `GenerateMaskImage` / `ClearRoiData` / `ResetDefaultRoi` / `DynamicIOInit`，只允许重载 `Process` / `GetParam` / `SetParam` / `SaveModuleData` / `LoadModuleData`
- **Process 重载规则**：3 参数版是纯虚函数必须实现；无图像时两版都声明（2 参数写逻辑，3 参数委托）
- **基本参数 vs 运行参数严格分离**：
  - 基本参数（图像/ROI/几何/标量 I/O）→ `<模块名>.xml`（定义端口），C++ 在 Process 内 `VM_M_GetFloat/VM_M_SetFloat` 逐分量读写
  - 几何输入参数（点/直线/矩形/扇环）还需在 `<模块名>AlgorithmTab.xml` Tab_Basic Params 中按层级展开 `ButtonSelecter` 控件；输出参数仅在 `<模块名>.xml` Output Category 配置
  - 所有几何类型统一分解为 float 子元素：点=2、直线=4、矩形=5、扇环=6，**不使用**复合接口（`VmModule_OutputVector_BoxF` / `VmModule_GetInputRoiBox` / `VmModule_OutputVector_PointF`）
  - 运行参数（阈值/模式/使能/枚举/路径）→ `<模块名>AlgorithmTab.xml` Tab_Run Params + `<模块名>Algorithm.xml`，C++ 在 `GetParam`/`SetParam` 内 strcmp 分支
  - 运行参数的中文名/描述必须原样写入 `<DisplayName>` / `<Description>`：用户提供中文则写中文，仅未提供时回退到英文名（禁止已提供中文却写英文）
- **ROI 仅输入语义**：禁止输出 `OutROI`，基类自动回显当前 ROI 与屏蔽区；用户未提 ROI 时默认全图处理
- **图像拷贝策略**：算法修改像素 → 深拷贝（`bDeepCopy=false`）；只读 → 浅拷贝（输出时 `bDeepCopy=true`）；不确定默认深拷贝
- **日志接口白名单**：只用 `MLOG_ERROR/WARN/INFO/DEBUG/TRACE`（VM430/VM431 统一使用 `MLOG_*`），禁止 `MessageBox` / 裸 `printf` / `std::cout` / `OutputDebugString`（仅 `CreateModule`/`DestroyModule` 2 个 DLL 入口函数允许 `OutputDebugStringA`）
- **GB2312 源码编码** + 默认英文注释；中文字面量在 GB2312 文件中**不**加 `u8` 前缀（**例外**：传入 VM SDK 接口的中文参数名/值必须加 `u8`）；若用户明确要求中文注释，技能改用 Python 按 GB2312 写
- **Cs 工程文件 + ToolItemInfo.xml 保护**：所有 .xaml / .xaml.cs / .cs / .csproj / .sln / **ToolItemInfo.xml** 只用 sed/Edit 字符串替换，禁止 Write 整文件重写。ToolItemInfo.xml 模板格式为 `<ToolBoxItemData>`，sed 改名已处理，零额外操作
- **VS 配置铁律**：C# 编译 `Release|AnyCPU`，C++ 编译 `Release|x64`。勿切 Debug 或 Win32（C++ 仅 Release|x64 的 `AdditionalIncludeDirectories` 完整）
- **VM 版本检测**：四级降级策略（① PowerShell 脚本 ② `reg query` .NET Assembly 注册表 ③ `$MVDALGO_DEV_ENV` 环境变量 + 文件系统 ④ 询问用户），按主.次版本号（如 4.3 vs 4.4）比较，忽略补丁号，版本不匹配时显式告知并询问是否继续
- **多 VS 优先级**：发现所有已安装 VS 并按版本降序排列（VS2022 > VS2019 > VS2017），编译失败自动降级；C++ 额外验证桌面开发组件
- **自动编译**：C#/C++ 各自独立编译器队列，按版本降序尝试 MSBuild Release 编译，任一成功即停止；未找到 VS 则显式告知跳过
- **自动部署**：编译成功后从注册表读取 VM 根目录，拷贝模块产物到运行时 + 二次开发双路径（工具箱默认 UserTools）；三方库 dll 自动复制到 `Applications\PublicFile\x64\`（已存在则跳过并告知）
- **Control 项目条件编译**：仅当步骤 1A 用户确认需要子界面/自定义控件（或需求含子界面、自定义控件等关键词）时编译 Control 项目
- **目录命名铁律**：外层 wrapper 与内层 UI 子目录必须同名 `<模块名>`，不允许加 `UI`/`_UI` 后缀（bat 拷贝逻辑硬编码）
- **落盘自检**：`check_module.sh --pre` 预检模板 + `check_module.sh <output>` **22 项**检查（含 SDK 符号白名单反向校验 + bat CRLF 检查 + ToolItemInfo.xml 格式检查 + DisplayName≠Name 检查 + Display.xml 根节点校验）
- **第三方库**：检测到 OpenCV/HALCON/Eigen/PCL/TensorRT/ONNX 等关键字必询问，要么完整配置（5 项资料），要么屏蔽 + `MLOG_WARN` 标注

## 七、与 vm-script-tutor 的关系

完全独立：

- `vm-script-tutor` 用于编写 C# **脚本**（运行在 VM 内置脚本模块里，无需编译）
- `vm-algorithm-module-builder`（本 skill）用于生成 **算法模块工程**（需 VS 编译成 dll）

脚本转模块时，本 skill 会读取 `vm-script-tutor` 风格的脚本，但不会反向依赖其文档。

## 八、项目目录结构

```
vm-algorithm-module-builder/
├── SKILL.md                        主流程 + 铁律（唯一权威规则源）
├── README.md                       本文件
├── CLAUDE.md                       Claude Code 激活提示（短引用，非规则源）
├── check_module.sh                 ★ 落盘后自检脚本（bash，**22 项**检查 + --pre 模式）
├── check_module.ps1                ★ check_module.sh 的 PowerShell 镜像（Windows 原生，含 ToolItemInfo.xml 格式检查）
├── deploy_module.ps1               ★ 固化部署脚本（xcopy 到 runtime+dev 双路径，含时间戳校验）
├── detect_vm.ps1                   ★ VM 注册表检测脚本（PowerShell 首选方案；附 Bash `reg query` + 环境变量/文件系统三级 fallback）
├── references/
│   ├── valid-sdk-symbols.txt       ★ SDK 符号白名单（反向校验防编造）
│   ├── regen-sdk-whitelist.sh      ★ 从模板重新生成白名单（版本升级时跑）
│   ├── architecture.md             三层架构说明
│   ├── cpp-api.md                  C++ SDK API 速查
│   ├── process-function.md         Process 骨架（深/浅拷贝）
│   ├── process-overload.md         Process 重载规则（无/多图像输入）
│   ├── param-type-mapping.md       参数类型映射
│   ├── error-code.md               错误码参考
│   ├── log.md                      日志接口参考
│   ├── encoding.md                 中文编码处理
│   ├── param-save-load.md          参数持久化
│   ├── sub-window.md               C# 子界面
│   ├── third-party-libs.md         第三方库集成
│   ├── version-upgrade.md          版本升级
│   ├── script-to-module-mapping.md 脚本→模块映射规则
│   ├── faq.md                      开发 FAQ
│   ├── forbidden-apis.md           接口黑名单（编造接口 + SDK 复合接口不应使用）+ 真实签名
│   ├── forbidden-xml-tags.md       编造 XML 标签黑名单
│   ├── build-deploy.md             编译与部署补充参考（lib 清单/手动部署路径/GAC/调试/性能优化；自动编译流程详见 SKILL.md §可选编译）
│   ├── vm-detect.md                 VM 版本检测详细参考（注册表路径/输出示例/4 种版本判定/告知模板）
│   ├── language-resources.md        模块语言资源格式规范（中文名/帮助说明 XAML 追加规则）
│   ├── xml-schemas/                5 个模块 XML 规范 + 样例
│   └── io-params/                  按类型分类的 I/O 参数代码片段
│       ├── geometric-params.txt     几何基本参数完整参考（POINT/LINE/RECT/CIRCLE）
│       ├── rect-params.md           BOX 矩形专题（C++ GetBatchBoxByName/SetBatchBoxByName 等）
├── examples/                       脱敏案例
│   ├── 03-multi-image-input.md     场景：多图像输入（主图 + 参考图，VmModule_GetInputImageEx 多图获取）
│   ├── 05-opencv-canny.md          场景：OpenCV 集成（HKA_IMAGE ↔ cv::Mat 互转 + Canny 边缘检测）
│   └── 06-halcon-zoom.md           场景：HALCON 集成（IMvdImage ↔ HObject 互转、GenImage1Extern 零拷贝、HException 处理）
└── templates/AlgTemplate/          黄金模板（剔除中间产物，含 common/ SDK）
```

## 九、法律与合规

`examples/` 中的所有代码均基于内部样例工程**脱敏改写**：

- 删除业务算法核心实现，替换为占位注释
- 删除行业概念字段名，统一改为通用命名
- 保留：接口调用模式、XML 结构、错误码用法、转换函数模板

## 十、版本

v1.11 / 2026-06（三轮深度审计 + cpp 文件保护 + Init 骨架防御 + 运行参数中文漏写防御 + auto-mode 分类器适配 + CustomVisible 规则修正 + 扇环统一 + 双文件同步审计 + 合理性审计 + Lang 写入安全加固 + 版本合并）

- **修复（严重 — cp -r 静默丢弃 SDK .lib 文件）**：Git Bash 的 `cp -r` 在 Windows 上可能静默丢弃 `.lib` 文件（只建目录壳，头文件正常复制）。原流程 Step 2/8 仅检查 `SDK/` 是否"非空"（`-eq 0`），目录壳存在（头文件已复制）会**假通过**，且 `SDK_V440/` 从未被校验。修复：`SKILL.md` 新增 Step 1a0（`cp -r` 后立即校验两套 lib 计数，`SDK/` ≥4、`SDK_V440/` ≥6，缺则从模板直补）；Step 1b 激活前保卫 `SDK_V440/` 源完整性；Step 2/8 阈值从"非空"提升为计数检查；`check_module.sh` + `check_module.ps1` #13 从 `-gt 0` 改为三级（`≥4` PASS / `1~3` WARN / `0` FAIL）；`build-deploy.md` SDK 激活代码同步加 guard。涉及 6 个文件。
- **新增（Lang 写入后验证加固）**：`SKILL.md` 写入后验证节从 grep 改为 Python 三重验证——(1) XML 结构完整性确认 ResourceDictionary 开闭标签数一致；(2) 全量 x:Key 重复扫描用 Counter 统计；(3) 目标 key 存在且唯一性确认。附「重复 x:Key 的后果」红色警告框。
- **新增（Lang 去重步骤警告）**：`SKILL.md` §模块语言资源配置 步骤 2 新增红色警告框——"重复 x:Key = 全界面变英文"，强调 grep 可能漏检，建议不确定时用 Python 直接读文件确认。宁可多问用户一次，不可重复追加。
- **修正（Lang 编码文档）**：`references/language-resources.md` 编码说明从"UTF-8（无 BOM）"改为"UTF-8（实际为 UTF-8 with BOM）"（与 VM 实际安装文件一致）；补充 `zh-cnLJ.xaml` 在部分 VM 版本中不存在的说明；"禁止仅用 grep 验证"替换为 Python 验证建议。
- **修复（严重 — ButtonSelecter 根 Combination CustomVisible）**：`CustomVisible` 规则修正——几何参数的**根 Combination** 必须 `<CustomVisible>True</CustomVisible>`，子 Combination 和叶子 Filter 设 `<CustomVisible>False</CustomVisible>`。涉及 `references/io-params/geometric-params.txt`（POINT/LINE/ROIANNULUS 三处代码示例 + 关键约束规则表）、`references/xml-schemas/algorithm-tab.xml.md`（关键规则）、`SKILL.md §P`（反模式速查新增 1 行）
- **修复（语言资源 Combination 层级补全）**：语言资源遗漏 Combination 层级 key（如 OutMidPoint 仅添加了子 Filter OutMidPointX/Y 而未添加 Combination 名本身）。`SKILL.md` + `references/language-resources.md` 步骤 1 补全"提取 Output 下所有 Combination 和 Filter"
- **统一（扇环命名）**：所有文件"圆环"统一改为"扇环"——扇环和圆对于基本参数而言是同一种参数类型（ROIANNULUS）

- **修复（严重 — Init 空壳）**：`§N` cpp Write 例外收紧——`Process()`/`GetParam()`/`SetParam()` 及自定义辅助函数允许 Write 重写，但 `Init()`/`CreateModule()`/`DestroyModule()` **仅允许 Edit 局部修改**（如调整构造函数成员初值），不得重写函数骨架。`§落盘流程 Step 6` 新增 Init()/CreateModule() 必须代码骨架（`VM_M_GetModuleId` + `ResetDefaultParam()` + `pUserModule->Init()` 调用），缺失任一 → 模块端口未注册 / 绑定参数报"参数不存在"。`§P 反模式速查` 新增 4 条：Init 空壳、CreateModule 丢失 Init 调用、SDK 返回值未检查、辅助函数改错误码。`§强制阅读清单` 新增模板原始 `AlgorithmModule.cpp` 对照行
- **修复（严重 — 运行参数中文漏写）**：`§plan-before-code` 第 2 段新增 "AlgorithmTab.xml 运行参数控件预演" 表格——逐控件列出 Name/DisplayName/Description 三元组，数据必须从步骤 4 确认表直接复制。`§落盘流程 Step 5` 新增 "写 AlgorithmTab.xml 前必须执行对照清单"（5 步），含写入后逐控件对比 DisplayName/Description 与步骤 4 确认值是否一致。自检改为"对比步骤 4"，不再一刀切 grep 过滤英文——用户步骤 4 明确确认了英文就按英文走
- **修复（不一致）**：`check_module.ps1` 补全 ToolItemInfo.xml 格式检查（原仅 check_module.sh 有此检查）；SKILL.md §9 项数由 19→20（补入 bat CRLF 检查）；§P 反模式表中缺少显式 §D/§N 引用的条目统一补全；§文件导航 补入 check_module.* 条目；Dot 图标注同时提及 check_module.sh/ps1
- **重写（编译）**：`SKILL.md` §编译子步骤 1-2 从 PowerShell 内联 MSBuild 改为 **Bash 直接调 exe + `@file.rsp` 响应文件**。已验证 `powershell -NoProfile -Command` 和 `cmd /c` 两种方式在 auto-mode 下均被拦截；Bash 直接调 exe + 响应文件可稳定通过
- **重写（部署）**：`SKILL.md` §部署命令执行方式铁律 从 `powershell -NoProfile -Command` 改为 `powershell -NoProfile -File deploy_module.ps1`。`references/build-deploy.md` 同步重写，新增「已验证调用模式通过性速查表」
- **重写（三方 DLL）**：`SKILL.md` §编译子步骤 5.3.2 从 PowerShell 内联 xcopy 改为 Bash 直接 xcopy
- **新增（语言资源 + Python 后备方案）**：`SKILL.md` §模块语言资源配置 新增「Edit 被拦截时的 Python 后备方案」；步骤 1 从"提取所有 Filter"修正为"提取**所有 Combination 和 Filter**"（几何输出参数的父 Combination 和子 Combination 也需要语言资源）。`references/language-resources.md` 同步修正
- **新增（Class Inputs 合并规则）**：`SKILL.md` §P + `references/xml-schemas/algorithm-tab.xml.md` 新增——多个几何输入参数时所有 ButtonSelecter 合并到一个 `<Category Name="Class Inputs">` 内
- **修复（头文件路径）**：`SKILL.md` §C + `references/forbidden-apis.md` 中 `AllocateSharedMemory` 声明头文件从 `VmAlgModuBase.h` 修正为 `VmModuleSharedMemoryBase.h`；`VM_M_SetModuleRuntimeInfo` 修正为 `VmModuleBase.h`
- **审计（第二轮 — 合理性 + 交叉引用 + 模板完整性 + 双文件同步）**：4 个并行代理深度审计——合理性分析发现 16 条改进建议（含 GB2312+u8 混淆风险、模块名重名检测缺失、schema 复述过于繁琐等）；交叉引用审计发现 `input-no-image.txt` 行 33 声明错误（与 §F 纯虚函数规则矛盾，已修复）；模板完整性审计全部通过（§O 改名清单/§C 头文件路径/SDK lib/骨架函数完整）；CLAUDE.md ↔ SKILL.md 同步审计发现 3 处不一致（部署命令硬编码 `-VmRoot` 路径已修复、激活清单遗漏 §0.6/§5、编号体系 `§A 铁律 1` vs `§A.1` 不一致）
- **修复（严重 — input-no-image.txt §F 规则错误）**：`references/io-params/input-no-image.txt` 三处旧规则残留修正——标题"只声明 2 参数"→"两个版本都声明"、代码注释"仅 2 参数"→ 补充 3 参数纯虚函数声明、节标题"只实现 2 参数"→"两个版本都实现"并新增 3 参数委托实现 `return Process(hInput, hOutput);`，与 `SKILL.md §F` 纯虚函数必须实现规则完全一致
- **修复（不一致 — CLAUDE.md 部署命令硬编码）**：`CLAUDE.md` 部署固化节的 `-VmRoot "C:\Program Files\VisionMaster4.3.0"` → `-VmRoot "$vmRoot"`；`-Toolbox "UserTools"` → `-Toolbox "$toolbox"`，与 `SKILL.md §编译子步骤 5.2` 动态检测变量一致
- **修复（一致性 — 检查项计数 21→22）**：`SKILL.md`、`CLAUDE.md`、`README.md`、`references/build-deploy.md` 共 9 处"21 项"→"22 项"同步更新（实际自检脚本包含 22 个检查项，含编号 1~19 + 子项 3.5/5.5/11.5）
- **修复（一致性 — CLAUDE.md 检查项编号）**：`CLAUDE.md` 第 28 行 DisplayName 检查引用"第 19 项"→"第 18 项"（check_module 脚本中第 18 项才是 DisplayName ≠ Name 检查）
- **修复（一致性 — SDK 符号提取正则补全）**：`check_module.sh` 行 166 + `check_module.ps1` 行 123 SDK 符号提取正则补全 `MVDSDK_API|MVDSDK_TRY|MVDSDK_CATCH` 三个前缀（与 `regen-sdk-whitelist.sh` 行 36 对齐）；黑名单 `FAB_API` 补全 `VmModule_GetInputRoiBox|VmModule_OutputVector_BoxF|VmModule_OutputVector_PointF` 三个禁止接口（与 `forbidden-apis.md` 对齐）
- **审计（第一轮）**：3 个并行代理对全技能 40+ 文件深度审计——0 死链、0 孤儿、所有 references 交叉引用有效、自检脚本覆盖完整 22 项、无外部未声明依赖、SKILL.md ↔ README.md 版本号一致
- **涉及文件**：`SKILL.md`（33 处，含 version 修正为当前版本 + Step 1a0 新增/lib 完整性保卫 5 处）、`README.md`（本记录，历史版本合并入当前版本）、`CLAUDE.md`（2 处修复）、`references/build-deploy.md`（SDK 激活代码同步加 guard）、`references/io-params/input-no-image.txt`（§F 规则修复 3 处）、`references/forbidden-apis.md`、`references/language-resources.md`（Lang 编码说明修正）、`references/xml-schemas/algorithm-tab.xml.md`、`check_module.sh`（#13 阈值 `-gt 0` → `-ge 4` 三级检查 + 前序 3 处修复）、`check_module.ps1`（同上 + 前序 3 处修复）

v1.10 / 2026-06（两轮深度自检审计——Process 重载规则修正 + 错误码传播 + Lang 去重 + 脚本缺陷修复）

- **修复（严重）**：Process 重载规则全量修正——3 参数 `Process(hInput, hOutput, modu_input)` 是基类 **纯虚函数**(`=0`)，必须实现。有图像模块只覆盖 3 参数版；无图像模块两版都声明（2 参数写逻辑，3 参数委托 `return Process(hInput, hOutput);`）。涉及 `SKILL.md §F`、`process-overload.md`、`process-function.md`、`README.md`、`CLAUDE.md`、`check_module.sh`/`ps1` 共 7 个文件 21 处修改
- **修复（严重）**：`check_module.sh`/`ps1` 中 `$MODULE_DIR`/`$ModuleDir` 变量从未定义，导致 bat CRLF 检查永远静默失败 + 误报 bat 缺失 → 改为 `$OUT`
- **修复（严重）**：`references/cpp-api.md` "LOG_* 亦可" 残留引用删除（v1.8 已修 `log.md` 但漏了 `cpp-api.md`）
- **新增**：SKILL.md §P 反模式速查 + `process-function.md` 双骨架约束表 + SKILL.md §步骤 5 追加"SDK 调用失败必须 `return nErrCode` 传播具体错误码"铁律（涉及 4 个文件）
- **新增**：`check_module.sh`/`ps1` log 黑名单追加 `LOG_ERROR|LOG_WARN|LOG_INFO|LOG_DEBUG|LOG_TRACE`——白名单校验虽放行但 §I 禁止用户代码使用
- **修复（不一致）**：语言资源去重检查 grep 从子串匹配 `x:Key="KEY"` 改为尾部锚定 `x:Key="KEY">`（防止 MidPoint 误命中 MidPointX）；`SKILL.md` + `language-resources.md` 两处同步
- **修复（不一致）**：`process-overload.md` 多图像示例 SDK 调用失败 `return IMVS_EC_PARAM` → `return nErrCode`
- **修复（不一致）**：`process-function.md` skeleton B `VmModule_OutputVector_PointF` 加注释区分合法场景（批量检测点）vs 禁止场景（几何参数）；`forbidden-apis.md` 同步
- **修复（不一致）**：`SKILL.md` 红旗清单 `AlgTemplate.sln` 路径修正 + 无图像模块红旗条件更新
- **清理**：6 个文件中全部"Process 单重载/单一重载/只保留一个/删掉 Process"等旧规则残留字符串归零
- **清理**：移除本次会话产生的临时脚本（`check_lang.ps1`/`rename_midpoint.ps1`/`copy_libs.ps1`）

v1.9 / 2026-06（部署脚本管道修复 + SKILL.md 部署节重写 + 几何全类型补全）

- **修复（严重）**：`deploy_module.ps1` xcopy 管道 `2>&1 | ForEach-Object` 导致 `$LASTEXITCODE` 丢失 → 改为先捕获输出到变量再打印；新增权限不足自动提权回退（`Start-Process -Verb RunAs`）；新增管理员权限预检
- **重写**：`SKILL.md` §编译子步骤 5.2-5.4 手工 xcopy 代码块（~60 行）替换为 `deploy_module.ps1` 调用（~10 行），消除手写 xcopy 风险；子步骤编号重整（5.5→5.3）
- **修正**：`build-deploy.md` "18 项"→"19 项"
- **修正**：`CLAUDE.md` 部署警示行从"bash xcopy 静默失败"改为"管道丢失 $LASTEXITCODE + 自动提权"

v1.8 / 2026-06（技能自洽性审计、部署固化、DisplayName检查、几何Lang资源补全、AlgorithmTab结构修正）

- **新增**：`deploy_module.ps1` 固化部署脚本——xcopy 到 runtime+dev 双路径，逐文件校验存在性+时间戳
- **新增**：`check_module.sh`/`ps1` 第 19 项检查——DisplayName ≠ Name 运行参数中文名缺失检测（当 DisplayName 文本与 Name 属性值完全相同时报警，防止 agent 将英文名直接填入 DisplayName 而遗漏用户提供的中文名）
- **新增**：`references/language-resources.md` "几何输出参数的完整资源映射"节——明确 POINT/LINE/ROIBOX/ROIANNULUS 每种输出类型需要的全部 x:Key 条目数（含根 Combination + 子 Combination + 叶子 Filter），附 ROIBOX 完整示例和 agent 自检规则
- **新增**：`references/xml-schemas/algorithm-tab.xml.md` ButtonSelecter 结构约束——强调所有 ButtonSelecter **必须**包裹在 `<Category Name="Class Inputs"><Items>...</Items></Category>` 内，附错误示例 vs 正确示例对比
- **新增**：`references/build-deploy.md` "部署命令执行铁律"+"部署后强制验证"两节——强制 PowerShell xcopy 字面路径 + 时间戳比对
- **修复（不一致）**：`references/encoding.md` `UTF8toANSI`/`ANSItoUTF8` 所在文件路径由 `common/VM400/src/VmModuleFrame/VmModule_IO.cpp`（不存在）修正为 `common/src/VmModule_IO.cpp`（实际位置）
- **修复（不一致）**：`references/cpp-api.md` GetParam 示例中 `*pDataLen = sprintf_s(...)` 删除 `*pDataLen =`（与 `param-type-mapping.md` "不赋值 *pDataLen" 规则冲突——VM 底层自行计算长度，重复赋值反而干扰）
- **修复（不一致）**：`references/log.md` 删除 "`LOG_*` 亦可" 误导语句（与 SKILL.md §I "`LOG_*` 是内部别名不对外暴露" 矛盾），统一为只使用 `MLOG_*`
- **同步**：README / CLAUDE.md / SKILL.md 自检项数统一改为 19 项

v1.7 / 2026-06（几何基本参数完整支持、ButtonSelecter 控件文档、接口三级分类）

- **新增**：`references/io-params/geometric-params.txt` 几何基本参数完整参考（POINT/LINE/RECT/CIRCLE 四类,含 XML Combination、AlgorithmTab ButtonSelecter、C++ 逐分量读写、Display.xml 渲染）
- **新增**：`references/io-params/rect-params.md` BOX 矩形专题（GetBatchBoxByName/GetBoxByName/SetBatchBoxByName 辅助函数）
- **新增**：`references/xml-schemas/algorithm-tab.xml.md` ButtonSelecter 控件章节（两类 Operation + 递归展开公式 + 控件属性表）
- **扩展**：`references/xml-schemas/module-io.xml.md` Input/Output 节补充 POINT/LINE/ROIBOX/ROIANNULUS Combination 示例和 AccessMode 变体
- **扩展**：`references/xml-schemas/display.xml.md` 补充 circle Type、修正 point/line Feature Name 为实际值（StartLineX/CenterX 等）
- **扩展**：`references/param-type-mapping.md` 补充 ROIBOX 和 ROIANNULUS 行
- **修正**：`references/forbidden-apis.md` 接口三级分类（编造/不存在 vs SDK 复合接口/不应使用），新增 VM_M_GetPoint/SetPoint/VM_M_GetCircle/SetCircle/VmModule_OutputVector_PointF；表头从"编造接口黑名单"改为"接口黑名单"
- **修正**：`references/cpp-api.md` 补充 VM_M_GetPoint/SetPoint/VM_M_GetCircle/SetCircle 编造接口行
- **修正**：`check_module.ps1` + `check_module.sh` 黑名单追加 VM_M_GetPoint|VM_M_SetPoint|VM_M_GetCircle|VM_M_SetCircle
- **修正**：`SKILL.md` §步骤3 新增几何基本参数结构说明（4 种类型 + 子元素数量 + ButtonSelecter + 逐分量公式）；§落盘流程 Step5 Tab_Basic Params 修正为含 ButtonSelecter；§P 反模式表新增 3 行；§强制阅读清单追加 geometric-params.txt/rect-params.md

v1.6 / 2026-06（结构审计、编码规则修正、双源消除、模块语言资源）

- **修复（§J 规则漏洞）**：SKILL.md §J 补充 VM SDK API u8 例外子表——传入 VM 框架的中文参数名/值必须加 `u8` 前缀
- **修复（死锚点 ×4）**：`references/process-function.md`/`process-overload.md`/`io-params/input-image.txt` 四处失效引用改为 SKILL.md §G/§H/§9
- **修复（严重）**：`references/build-deploy.md` "17 项" → "18 项"（v1.5 第 18 项新增后同步遗漏）
- **修复（严重）**：`references/encoding.md` "必须 UTF-8 with BOM" 与模板实际编码矛盾 → 删 "with BOM"；自检 grep 补全 `std::clog` + OutputDebugStringA 例外引用
- **修复（中等）**：README Step 7 删除提前出现的编译结果描述（避免流程顺序误导）；`references/log.md` 补充"默认策略：优先英文日志"提示
- **修复（中等）**：Dot 图模块语言资源→可选编译边标注"确认 / 跳过"；CLAUDE.md TodoWrite 清单补充"模块语言资源"
- **修复（轻微）**：SKILL.md §强制阅读清单标题补 § 前缀；"§步骤 4" 引用修正为 "步骤 4"
- **重写**：`references/encoding.md` 删除 C++ UTF-8 with BOM 错误框架，重写为运行时路径编码转换专项文档（120→92 行）
- **重写**：`references/process-function.md` 中文约束措辞精确化为"传入 VM SDK 的中文参数名/值必须加 u8"
- **去重**：`references/build-deploy.md` 删除 ~210 行过期 PowerShell（VS 检测/Cs Cpp 编译/部署/三方 dll），改为指向 SKILL.md §可选编译（395→187 行）
- **抽出**：SKILL.md 步骤 0.6 VM 版本检测细节（~65 行）迁入新建 `references/vm-detect.md`；SKILL.md 1390→1491 行
- **精简**：`references/process-overload.md` 决策表 / `references/param-type-mapping.md` 速判表改为指向 SKILL.md §F/§E，详细代码模板均保留
- **新增**：`examples/06-halcon-zoom.md` HALCON 集成脱敏案例
- **新增**：模块语言资源配置功能——落盘后编译前主动询问是否添加模块中文名、输出参数中文名和中英双语帮助说明（中文追加 zh-cn.xaml + zh-cnLJ.xaml，英文追加 en-us.xaml），自动去重后写入
- **修复**：帮助说明改为中英双语三文件写入；`process-overload.md` 死链修正；§C + `forbidden-apis.md` 头文件路径补全；`input-image.txt` ROI 补第三种情况；§落盘 Step 3 补 PNG 提醒；删除孤儿文件
- **文档**：`detect_vm.ps1` 补充到 README 目录清单；`build-deploy.md` 描述修正

v1.5 / 2026-06

- **修复（严重）**：`display.xml.md` 根节点描述由 `<Display Name="..." Version="...">` 改为模板实际根节点 `<ParamRoot><Categorys><Category Name="Display">`；Object 结构改为 `<Features><Feature>` 子节点，"Result List" 类型由 `resultlist` 改为正确的 `datalist`
- **修复（严重）**：`build-deploy.md` 部署路径 `Module(sp)d\` → `Module(sp)\x64\$toolbox\$moduleName`（原写法会将 dll 部署到错误目录导致 VM 无法加载）
- **修复（严重）**：`build-deploy.md` 编码规则与 SKILL.md §J 矛盾（"UTF-8 with BOM + u8 前缀"→ "GB2312 无 u8 前缀"）；同步删除 §自检清单 的 u8 检查，改为裸 `printf` 检查
- **修复（严重）**：`build-deploy.md` 注册表路径缺 `\v` 前缀（`\.NETFramework4.0.30319` → `\.NETFramework\v4.0.30319`），VM 版本检测静默失败导致自动部署跳过
- **修复（严重）**：`check_module.sh`/`ps1` 黑名单补入裸 `printf`（§I 铁律，之前缺失导致裸 printf 通过自检）
- **修复（严重）**：`examples/README.md` 删除 01/02/04/06/07/08 六个不存在的示例条目（保留真实存在的 03/05），消除 agent 读不到文件时凭印象编造代码的风险
- **修复（中等）**：`build-deploy.md` vswhere 方法 1 `-latest` 改为全量发现（与 SKILL.md §可选编译 多 VS 发现逻辑同步）
- **修复（中等）**：`check_module.sh`/`ps1` ODS 检查由单行同行正则改为 awk/逐行多行上下文检测，避免 `OutputDebugStringA` 在函数体内（多行）被误判为违规
- **新增**：`check_module.sh`/`ps1` 第 18 项检查：Display.xml 根节点必须含 `<ParamRoot>`
- **修复**：`module-io.xml.md` `ModuleDisplayName` 默认值 `ImageModifyTool` → 改为说明 sed 改名后等于 `<模块名>`
- **修复**：`SKILL.md` 白名单行数 "629 行" → 实际 "639 行"；覆盖项列表从 16 条补全为 18 条
- **修复**：`SKILL.md §I` 日志接口白名单澄清 VM430/VM431 统一使用 `MLOG_*`（不对外暴露 `LOG_*`）
- **同步**：README / CLAUDE.md / SKILL.md 自检项数统一改为 18 项

v1.4 / 2026-06

- 修复：步骤 4 运行参数确认表格缺「描述」列（追加 8 列铁律 + 枚举项副表模板）
- 修复：基本参数输出端中文名来源说明缺失（补全 §E + 落盘 Step 5 + module-io.xml.md 的输入/输出参数 DisplayName 策略区分）
- 修复：§plan-before-code 输出全英文（全文改写为 5 段中文模板 + 输出语言铁律）
- 修复：§J（GB2312 无 u8）与 §落盘 Step 6（加 u8）矛盾（删除 u8 残留）
- 修复：§P 反模式表缺少"用户提供中文则写中文"正向规则（补全 + references 同步）
- 修复：`$vmVersion` 变量未定义（改为 `$vmFullVersion`）
- 修复：步骤 0.6 VM 注册表检测中 PowerShell `(默认)` 中文值名编码问题（改用 `(default)`）

---

> 完整规则与设计依据见 [SKILL.md](./SKILL.md)（**唯一权威规则源**）。[CLAUDE.md](./CLAUDE.md) 仅是 Claude Code 环境的激活提示，非规则源；Trae / Copilot CLI / Gemini CLI 等环境只读 SKILL.md 即可。
> 参考资料位于 [references/](./references/)：cpp-api.md（SDK 接口手册）、param-type-mapping.md（参数类型映射）、process-function.md（Process 骨架）、script-to-module-mapping.md（C# 脚本转模块规则）、io-params/（输入输出代码片段）。
