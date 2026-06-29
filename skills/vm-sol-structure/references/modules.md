# 模块层级与类型

## 层级架构

```
Solution (Type=100)
├── 全局模块（CommManager/GlobalVariable/GlobalCamera/LightControl/GlobalTrigger）
│   └── GlobalVariableModule（Type=5）：全局变量，可绑定给所有流程和模块
├── GlobalScript（独立，不在 ModuleFrame 模块列表里，在 VmServer.xml GlobalScriptInfo 节点）
├── Procedure（流程，Solution 层级的容器，Index 10000+）
│   ├── LocalVariableModule（Type=25，ContainerType=1）：流程局部变量，只能绑定给流程内第一层模块
│   ├── ProcedureComm（Type=26，ContainerType=1）：流程 IO 接口，归属某个 Procedure
│   ├── 普通模块（Index 0-2047）
│   └── IMVSGroup（流程层级的容器，Type=20，Index 21000+）
│       ├── LocalVariableModule（Type=25，ContainerType=20）：Group局部变量，只能绑定给Group内模块
│       ├── 普通模块
│       └── IMVSGroup（可多层嵌套）
└── IMVSProcessControl（Type=1，流程控制模块）
```

## Type 枚举

| Type 值 | 模块类型 | 说明 |
|---------|----------|------|
| 0 | 普通模块 | IfModule、ShellModule、IMVSEdgeWidthFindModu 等算法模块 |
| 1 | 流程控制 | IMVSProcessControl，对应一个流程（Procedure） |
| 3 | 通信管理 | CommManagerModule |
| 4 | 数据队列 | DataQueueModule |
| 5 | 全局变量 | GlobalVariableModule |
| 6 | 全局相机 | GlobalCameraModule（多相机方案可有多个实例，ID 不限于 64~65） |
| 7 | 全局光源 | LightControl |
| 8 | 全局触发 | GlobalTriggerModule |
| 20 | Group | IMVSGroup，流程层级的容器，可多层嵌套 |
| 25 | 局部变量 | LocalVariableModule，归属某个流程或 Group |
| 26 | 流程通信 | ProcedureComm，定义流程的 IO 接口 |
| 100 | 方案 | Solution 根节点 |

## ModuleID 分段规律

| ID 范围 | 用途 |
|---------|------|
| 0 ~ 2047 | 普通算法模块（流程内） |
| 10000 ~ 19999 | 流程（Procedure），对应 IMVSProcessControl，Index 从 10000 起 |
| 20000+ | Group（IMVSGroup） |
| 任意小 ID | GlobalCameraModule（与普通模块共用 0~几千的 ID 范围） |
| 11000 | CommManagerModule |
| 13000 | GlobalVariableModule |
| 14000 | LightControl |
| 14200 | GlobalTriggerModule |
| ProcedureID + 14000 | LocalVariableModule（流程局部变量，ContainerType=1） |
| GroupID + 10000 | LocalVariableModule（Group 局部变量，ContainerType=20） |
| ProcedureID + 16000 | ProcedureComm（流程通信，ContainerType=1） |
| 70000 | 方案级元数据（\_70000+100+solution） |

## 三类 GUID 说明

每个模块存在三类不同用途的 GUID，通过 moduleId 关联，不直接交叉引用：

| 类型 | 存储位置 | 用途 |
|------|----------|------|
| VmServer GUID | VmServer.xml `Guid` 属性 | 逻辑层标识，方案拓扑管理 |
| UiParamData GUID | UiParamData 文件 `GUID` 字段 | 画布层标识，画布渲染和连线 |
| AssemblyGuid | ModuleFrame ShellModule 二进制参数 | 脚本程序集标识，仅 ShellModule 有 |

## ProcedureBase 属性

| 属性 | 说明 |
|------|------|
| Index | 流程ID（10000起） |
| DisplayName | 流程显示名称 |
| ContinueExecuteTimGap | 连续执行间隔（ms） |
| StopWhenNG | NG时是否停止 |
| RunTimeout | 运行超时（0=不限） |
| ShieldGlobalCtrl | 是否屏蔽全局控制 |
