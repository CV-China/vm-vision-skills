# 算法模块三层架构

VM 算法模块由 **三层** 组成，分别对应一个独立工程或目录：

```
<模块名>/                  ← 模块根目录（最终部署到 VM 工具箱）
│
├── 【界面层】XML 文件（5 个 + 3 个 png 图标）
│   ├── <模块名>.xml                  输入/输出参数定义（基本参数）
│   ├── <模块名>AlgorithmTab.xml      界面控件（含基本参数 UI、运行参数控件、结果显示）
│   ├── <模块名>Algorithm.xml         运行参数默认值
│   ├── <模块名>Display.xml           结果渲染（图像/点/线/矩形/文本/数据列表）
│   ├── ToolItemInfo.xml              工具箱位置与名称
│   ├── <模块名>ImageEnable.png       使能图标
│   ├── <模块名>_NormalLogo.png       常态图标
│   └── <模块名>_StateLogo.png        状态图标
│
├── 【算法层】C++ 工程（编译产出 <模块名>.dll）
│   └── <模块名>_CProj/<模块名>/
│       └── <模块名>/
│           ├── AlgorithmModule.h     声明 CAlgorithmModule 类与导出函数
│           ├── AlgorithmModule.cpp   ★ Process / GetParam / SetParam 实现
│           ├── AlgorithmModule.def   导出符号定义
│           ├── dllmain.cpp           DLL 入口
│           └── <模块名>.vcxproj
│
└── 【控件层】C# 工程（编译产出 <模块名>Cs.dll）
    └── <模块名>_CsProj/<模块名>Cs/
        └── <模块名>Control/
            ├── <模块名>.cs           工具类（仅二次开发时需要）
            ├── <模块名>Param.cs      参数类
            ├── <模块名>Result.cs     结果类
            └── *.csproj
```

## 数据流

```
VM 平台
  ↓ 解析 <模块名>.xml + AlgorithmTab.xml
  ↓ 加载 <模块名>Cs.dll（控件层）
  ↓ 控件层通过 SetParam/GetParam 接口
  ↓ 调用 <模块名>.dll（算法层）
  ↓ 算法层 Process() 处理图像
  ↓ Process() 写出结果到 hOutput
  ↑ VM 解析 Display.xml 渲染结果
```

## 关键接口对应

| XML 节点 | C++ 接口 | 触发时机 |
|---|---|---|
| `<模块名>.xml` 的 Input/Output Combination/Filter | `Process()` 中 `VmModule_GetInputImageEx` / `VM_M_Get*` / `VM_M_Set*` | 模块每次运行 |
| `AlgorithmTab.xml` 中 Tab_Run Params 的 Integer/Float/Enumeration 等 | `GetParam()` / `SetParam()` | 用户在 UI 修改参数时；模块运行前读取 |
| `Display.xml` 中 Object Mapping="..." | 自动从 hOutput 中读取 | 模块运行完毕后 |
| `<模块名>Algorithm.xml` | 初始化运行参数 | 模块首次创建 |
| `ToolItemInfo.xml` | 决定模块在工具箱中的位置 | VM 启动加载 |

## 部署路径

编译产出后，将 **界面层文件夹整体** 拷贝到：
```
VisionMaster4.X.0\Applications\Module(sp)\x64\<工具箱名>\<模块名>\
```

工具箱名默认 `UserTools`，可以是任意子目录（如 `LogicTools` / `MeasureTools` 等）。
