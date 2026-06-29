# 脚本 → 算法模块 参数映射规则

来源：模块敏捷封装工具 `ParamExtractor.cs` 的提取逻辑。本规则适用于"从 C# 脚本转算法模块"模式。

## 核心原则

脚本中的**输入参数** → 模块的**基本参数（Input Filter）**
脚本中的**输出**       → 模块的**基本参数（Output Filter）**
脚本**无**运行参数概念  → 必须**新增**询问用户

## 输入参数识别

读取脚本工程的 `*.csproj`（或脚本 UI 配置），提取 `InternalObjs` 标记的参数：

```csharp
// 脚本中典型声明
InternalObj("OBJ_NUM_THRESHOLD", 128, "int", "阈值")
InternalObj("OBJ_RATIO", 0.5f, "float", "比率")
InternalObj("OBJ_FILE_PATH", "", "openFile", "模型文件")
InternalObj("OBJ_ENABLE", true, "bool", "使能")
InternalObj("OBJ_TYPE", 1, "enumeration:BINARY=1,BINARY_INV=2", "类型")
InternalObj("OBJ_POINT", null, "POINT", "点")
InternalObj("OBJ_LINE", null, "LINE", "直线")
InternalObj("OBJ_IMAGE", null, "IMAGE", "输入图像")
```

## 类型映射表

| 脚本类型 | XML ValueType | 基本参数 / 运行参数？ | C++ 类型 | UI 控件 |
|---|---|---|---|---|
| `int` | `int` | 基本参数 Filter | `int` | Combination 内 Filter |
| `float` | `float` | 基本参数 Filter | `float` | Combination 内 Filter |
| `string` | `string` | 基本参数 Filter | `std::string` | Combination 内 Filter |
| `bool` | `bool` | 基本参数 Filter | `bool` | Combination 内 Filter |
| `POINT` | `point` | 基本参数 Combination Style="POINT" | `PointData` | Combination |
| `LINE` | `line` | 基本参数 Combination Style="LINE" | `LineData` | Combination |
| `IMAGE` | `image` | 基本参数 Combination Style="IMAGE" | `HKA_IMAGE` | Combination |
| `enumeration:...` | `int` | 基本参数 Filter（值为 int） | `int` | Combination 内 Filter |
| `openFile` | `string` | 基本参数 Filter | `std::string` | Combination 内 Filter |
| `byte`/`byte[]` | `byte` | 基本参数 Filter（IsArray="true"） | `unsigned char*` | Combination 内 Filter |

详见 [param-type-mapping.md](param-type-mapping.md)。

## 输出参数识别

脚本的输出通过：
- `ModuOutput("OUT_KEY", value)` 类调用
- 或脚本 `Out` 类的属性赋值

每个输出 → `<模块名>.xml` 的 Output 节点中加 Filter（或 Combination）。

## 运行参数：必须新增确认

脚本里**没有**运行参数概念。转模块时必须问用户：

> 脚本里 `OBJ_NUM_THRESHOLD` 等已经识别为基本参数（输入端 Filter）。算法模块还可以增加"运行参数"——用户在 VM 工具 UI 上调节的可视化参数。**是否需要把某些基本参数同时作为运行参数？或新增哪些运行参数？**

用户确认后，对应参数同时在 `<模块名>AlgorithmTab.xml` 中加控件（Integer/Float/Enumeration 等）。

## 算法逻辑迁移

脚本主体（在 `OnCalc()` / `Process()` 等方法内）的算法代码逐行翻译到 C++ `Process()` 内。涉及：

| C# | C++ |
|---|---|
| `InternalMethods.Read*` / `GetParameter` | `VM_M_Get*` / `VmModule_GetInputImageEx` |
| `InternalMethods.Write*` / `SetResult` | `VM_M_Set*` |
| `ConsoleWrite(...)` / `MessageBox.Show` | `MLOG_INFO(u8"...")` / `MLOG_ERROR(u8"...")` |
| `using Cv2 = OpenCvSharp.Cv2;` | `#include <opencv2/opencv.hpp>` + 配置 .vcxproj（见 [third-party-libs.md](third-party-libs.md)） |
| `HOperatorSet.*` (HalconDotNet) | `HalconCpp::*` + 配置 HALCON（详见 [third-party-libs.md](third-party-libs.md) 和 [../examples/06-halcon-zoom.md](../examples/06-halcon-zoom.md)） |
| `IUserStringData/IUserBytesData` 弹窗 | 子界面方案（VM 高级）见 sub-window.md |

## 字段重命名

脚本里常用业务名称（如客户领域专有词），转模块时按用户语境保留；但生成 examples 时**必须**改为通用名（`Output1`、`Output2`）防泄露。

## 工作流（脚本转模块场景）

1. 让用户提供 `UserScript.cs` 路径
2. 读取并 grep `InternalObj(...)` 提取所有基本参数 → 列表展示
3. grep `using` 检查第三方库 → 触发 [third-party-libs.md](third-party-libs.md) 流程
4. 询问：「以上参数都作为基本参数，是否需要追加/调整为运行参数？还需新增哪些运行参数？」
5. 列计划（基本参数表 + 运行参数表 + 算法逻辑大纲）→ 用户确认
6. 修改模板 → 翻译算法主体 → 自检日志接口/u8 prefix/中文路径

## 反模式

| ❌ 不要 | 原因 |
|---|---|
| 把脚本输入参数当运行参数 | 违反默认映射（用户预期是基本参数） |
| 自动判断"这个参数适合作运行参数"并改归类 | 必须问用户 |
| 把 `ConsoleWrite("xxx");` 翻译成 `std::cout << "xxx";` | 违反日志规范，必须 `MLOG_INFO` |
| 把脚本里所有 `cv::` 调用直接复制 | 没配 OpenCV 路径就编译失败，必须先走 [third-party-libs.md](third-party-libs.md) 流程 |
