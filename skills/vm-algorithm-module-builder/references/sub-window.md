# 子界面开发（高级，可选）

VM 算法模块默认属性页只有标准控件（Integer/Float/...）。如需**自定义子界面**（例如标注界面、模型训练向导），需要在 Cs 控件层用 WPF/WinForms 实现，并通过 `IUserStringData` / `IUserBytesData` 接口与算法层 C++ 通信。

**此功能复杂且非必需**。除非用户明确要求，否则**默认不生成**。

## 何时需要

- 算法需要交互式输入（如手动框选模板、用户标注特征点）
- 参数太多/太复杂，标准 Integer/Enumeration 无法表达
- 需要离线训练流程嵌入到属性页

## 涉及的工程文件

| 层 | 文件 |
|---|---|
| Cs | `<模块名>Control/AdvancedConfigWindow.xaml` / `.cs`（WPF 子界面） |
| Cs | `<模块名>Control/<模块名>UserControl.xaml` 中加按钮触发子界面 |
| C++ | `AlgorithmModule.h/.cpp` 增加 `IUserStringData` / `IUserBytesData` 接口实现 |
| GAC | 控件 dll 注册到 GAC（用 gacutil） |

## 通信接口

Cs 端通过 **索引器(indexer)** 方式访问(教程示例):

```csharp
// Cs → C++(向算法层推送)
(paramsConfig as IUserStringData)["SetImageWidth"] = model.ImageWidth.ToString();  // int
(paramsConfig as IUserStringData)["TextBoxMsg"] = textMsg;                          // string
(paramsConfig as IUserBytesData)["SetImageData"] = model.ImageBuffer;               // byte[]

// C++ → Cs(从算法层读取)
int ImageWidth = int.Parse((paramsConfig as IUserStringData)["GetImageWidth"]);     // int
byte[] ImageBuffer = (paramsConfig as IUserBytesData)["GetImageData"];              // byte[]
byte[] roiBuffer  = (paramsConfig as IUserBytesData)["GetRoiData"];                 // byte[]
```

- `IUserStringData["SetXxx"] = "value"` → C++ 端在 `SetParam("SetXxx", pData, nLen)` 收到
- `IUserStringData["GetXxx"]` → C++ 端在 `GetParam("GetXxx", pBuff, nBuffSize, &dataLen)` 中 sprintf_s 写回
- 字节流走 `IUserBytesData`,与 `SetParam/GetParam` 的字节版本对应

## 推荐实现路径

1. 与用户确认是否需要 → 多数情况下用标准 Integer / IntegerBettween / Enumeration / OpenFile 已足够
2. 如必须，让用户提供子界面 UI 草图（哪些字段、按钮、流程）
3. 在 Cs 工程中新增 `AdvancedConfigWindow.xaml`
4. 在 `<模块名>UserControl.xaml` 中加 `<Button Click="OpenAdvancedConfig_Click" Content="高级配置"/>`
5. 用 `IUserStringData` 接口同步数据

## 当前版本不支持子界面自动生成

> ⚠️ 本 skill 当前版本（V1.11）**不自动生成子界面（Control 项目 WPF 控件树）的业务代码**。Skill 会在步骤 1A 明确询问用户是否需要子界面：
> - 用户答「否」→ 跳过 Control 项目编译，仅保留 Cs 主项目基本改名
> - 用户答「是」→ Skill 保留 `<模块名>Control/` 工程结构并正常编译 Control 项目，但 **WPF 控件树（xaml 事件绑定、自定义控件的业务逻辑代码）由用户自行在编译后的工程中二次开发**
>
> 子界面自动生成功能计划在**后续版本**中支持。

若用户提出此需求，应：
- 简化为：能用标准控件实现吗？
- 如果不能：先输出标准模块，子界面作为**后续二次开发**
