# parse JSON 输出结构说明

## 概述

`VMSolutionParser.Cli parse` 命令将 .sol 文件解析为结构化 JSON。输出供 Claude Code 和人类阅读，涵盖三层数据：逻辑层（模块定义/连线/订阅）、参数层（算法参数/脚本/IO 定义）、画布层（坐标/GUID/就绪状态）。

## CLI 用法

```bash
parse -f file.sol                     # 基础解析
parse -f file.sol -p pwd              # 加密文件
parse -f file.sol --include-raw       # 包含 rawB64（调试/重建用）
parse -f file.sol -o output.json      # 输出到文件
```

## 顶层结构

```json
{
  "formatVersion": 7,
  "sourceFile": "SampleSol.sol",
  "parseTime": "2026-06-01T14:30:00",
  "solution": {
    "globalModules": [...],
    "procedures": [...],
    "globalScript": {...},
    "moduleParamBindings": [...],
    "warnings": null
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| formatVersion | int | ModuleFrame 格式版本号（首 4 字节 BE），非 VM 产品版本。v4.4+ 通常为 7 |
| sourceFile | string | 源文件路径（传入 -f 参数值） |
| parseTime | string | 解析时间（`yyyy-MM-ddTHH:mm:ss`，本地时间） |
| solution | object | 方案数据根节点（含 warnings，见下文） |

---

## solution 对象

```json
{
  "globalModules": [ ... ],
  "procedures": [ ... ],
  "globalScript": { ... },
  "moduleParamBindings": [ ... ],
  "warnings": [ ... ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| globalModules | Module[] | 全局模块列表（CommManager、GlobalVariable、GlobalCamera 等） |
| procedures | Procedure[] | 流程列表，每个流程含模块拓扑 |
| globalScript | GlobalScript | 全局脚本数据，无脚本时为 `null` |
| moduleParamBindings | Binding[] | ModuleParamBinding protobuf 解析结果 |
| warnings | string[] | 解析警告/异常信息，无警告时为 `null` |

---

## Module 对象

```json
{
  "moduleId": 1,
  "name": "IMVSBlobFindModu",
  "displayName": "BLOB分析1",
  "type": "Module",
  "typeId": 0,
  "isEnabled": true,
  "fullPath": "流程1.检测组.BLOB分析1",
  "frameNameSlot": "1-IMVSBlobFindModu.mdata",
  "isSlave": false,
  "enableCallBack": false,
  "guid": "a1b2c3d4-...",
  "algoriParams": [ ... ],
  "binaryParams": [ ... ],
  "connections": { ... },
  "subscriptions": [ ... ],
  "uiParams": [ ... ],
  "commSubModules": [ ... ]
}
```

### 基础字段

| 字段 | 类型 | 说明 |
|------|------|------|
| moduleId | int | 模块 ID，VmServer.xml 中 ModuleBase/Index |
| name | string | 模块类名，如 `"IMVSBlobFindModu"`、`"ShellModule"` |
| displayName | string | 显示名称，如 `"BLOB分析1"`。未设置时回退为 name |
| type | string | 模块类型枚举名，见 [模块类型枚举](#模块类型枚举) |
| typeId | int | 模块类型原始整数值 |
| isEnabled | bool | 是否启用 |
| fullPath | string | 完整路径，由 Parent 链拼接，如 `"流程1.检测组.BLOB分析1"` |
| frameNameSlot | string | ModuleFrame 中的 512-byte name slot，如 `"1-IMVSBlobFindModu.mdata"` |

### 可选标识字段

只有值为 `true` 或非空时才出现：

| 字段 | 类型 | 出现条件 | 说明 |
|------|------|---------|------|
| isSlave | bool | `true` 时 | 从模块，模块被其他模块引用为子流程 |
| enableCallBack | bool | `true` 时 | 启用回调 |
| guid | string | 非空时 | 模块 GUID，VmServer.xml Guid 属性 |

### algoriParams

算法参数列表，每个参数为固定 1024 字节槽位。标准 `--include-raw` 模式下不输出 raw 字段：

```json
{ "name": "EdgeThreshold", "value": "25.5", "index": 0 }
```

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 参数名 |
| value | string | 参数值字符串（已 trim） |
| index | int | 参数序号（0-based） |
| rawLen | int | 仅 `--include-raw`：原始字节数 |
| rawB64 | string | 仅 `--include-raw`：最多前 1024 字节的 Base64 |
| rawTruncated | bool | 仅 `--include-raw`：raw 是否被截断 |

### binaryParams

二进制参数列表，可变长度（260 字节 name + 4 字节 length + data）：

```json
{ "name": "RoiType", "valueLen": 22, "parsed": "shapeType=0, x=100.0, y=200.0, w=300.0, h=400.0, flag=0" }
```

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 参数名，决定内容格式 |
| valueLen | int | 二进制数据字节数 |
| parsed | string | 解析后的可读内容，最多截断到 500 字符。无法解析时显示 `(binary, N bytes)` |
| rawDataLen | int | 仅 `--include-raw`：原始数据字节数 |
| rawDataB64 | string | 仅 `--include-raw`：最多前 2048 字节的 Base64 |
| rawTruncated | bool | 仅 `--include-raw`：raw 是否被截断 |

二进制参数按 name 有不同的解析格式，详见 [已知二进制参数类型](#已知二进制参数类型)。

### connections

执行连线关系：

```json
{
  "frontModules": [0, 2],
  "followModules": [5]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| frontModules | int[] | 前序（上游）模块 ID 列表。VM 连线是双向冗余的 |
| followModules | int[] | 后序（下游）模块 ID 列表 |

### subscriptions

参数订阅列表，对应 VmServer.xml ModuleSubscribe/Subscribe Relation。每个订阅是一个 8 元组：

```json
{
  "paramName": "%int1%",
  "isBound": true,
  "targetModuleId": 2,
  "targetParamName": "IntValue",
  "indexMode": "All",
  "isIndexBind": false,
  "indexTargetModuleId": 0,
  "relationString": "1.%int1%.2.IntValue.0.0.All.0"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| paramName | string | 当前模块的输入参数名 |
| isBound | bool | 是否绑定输入。`true`=订阅其他模块输出，`false`=手动输入常量 |
| targetModuleId | int | 目标模块 ID（数据来源模块）。isBound=false 时固定为 0 |
| targetParamName | string | 目标参数名。isBound=false 时该值即为常量值 |
| indexMode | string | 索引模式，通常为 `"All"` |
| isIndexBind | bool | 索引是否绑定输入 |
| indexTargetModuleId | int | 索引目标模块 ID，无索引时为 0 |
| relationString | string | 原始 8 元组字符串 `curModuId.curParam.tarModuId.tarParam.isBind.indexModuId.indexParam.isIndexBind` |

**典型场景：**
- **模块订阅模块**：`isBound=true`，`targetModuleId` 指向数据来源模块
- **手动输入常量**：`isBound=false`，`targetParamName` 即为常量值（如 `"128"`）
- **索引绑定（图像输入）**：`isIndexBind=true`，`indexTargetModuleId` 指向索引来源

### uiParams

画布层 TLV 字段，来自 `UiParamData/{ModuleId}`：

```json
{ "name": "GUID", "inferredType": "guid", "value": "a1b2c3d4-..." }
```

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 字段名 |
| inferredType | string | 推断类型：`null`/`bool`/`int32`/`guid`/`position`/`string` |
| value | string | 显示值，最多截断到 200 字符 |

每个模块至少有 `GUID` 和 `Position` 两个 UiParam 字段。常见字段还包括 `Ready`（就绪状态）、`line`（画布连线）等。

### commSubModules

CommManager 模块的通信子模块列表（仅通信管理模块有值）：

```json
{
  "className": "OmronFinsTcpModule",
  "displayName": "欧姆龙Fins TCP",
  "properties": {
    "IP": "192.168.1.100",
    "Port": "9600"
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| className | string | 通信协议类名 |
| displayName | string | 通信子模块显示名称 |
| properties | object | 配置键值对 |

### ShellModule 额外字段

当模块类型为 `ShellModule` 或 `AsShellModule` 时，额外包含：

```json
{
  "scriptText": "using System;\n...",
  "assemblyGuid": "a1b2c3d4-...",
  "references": [
    { "dll": "MathTool.dll", "type": 4 }
  ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| scriptText | string | C# 脚本源码，最多截断到 2000 字符 |
| assemblyGuid | string | 编译后的 AssemblyGuid（仅 ShellModule 有，AsShellModule 无） |
| references | object[] | 引用的程序集 |
| references[].dll | string | 程序集名称/路径 |
| references[].type | int | 引用类型：0=系统内置，4=用户自定义 |

---

## Group 对象

Group 是模块容器（Type=20, IMVSGroup），包含子模块和 DynamicIO 映射：

```json
{
  "groupId": 20001,
  "displayName": "检测组",
  "fullPath": "流程1.检测组",
  "dynamicParamInfos": [
    { "paramName": "%根部圆弧ROI1%", "innerModuleId": 5, "innerParamName": "MatchROI" }
  ],
  "modules": [ ... ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| groupId | int | Group ID（范围 20000+） |
| displayName | string | Group 显示名称 |
| fullPath | string | Group 完整路径 |
| dynamicParamInfos | object[] | DynamicIO 映射：将内部模块参数暴露为 Group 输出端口 |
| dynamicParamInfos[].paramName | string | 暴露的参数名 |
| dynamicParamInfos[].innerModuleId | int | 内部模块 ID |
| dynamicParamInfos[].innerParamName | string | 内部模块参数名 |
| modules | Module[] | Group 内的子模块列表（可嵌套 Group） |

Group 内的子模块格式同 [Module 对象](#module-对象)。

---

## Procedure 对象

Procedure 是流程容器（Type=1, IMVSProcessControl）：

```json
{
  "procedureId": 10000,
  "displayName": "流程1",
  "properties": {
    "continueExecuteTimGap": 0,
    "stopWhenNG": false,
    "runTimeout": 0,
    "shieldGlobalCtrl": false
  },
  "modules": [ ... ],
  "procedureIO": {
    "params": [
      { "type": 8, "name": "%输入图像%" },
      { "type": 2, "name": "%阈值%" }
    ],
    "dynamicInData": "<ParamRoot>...",
    "dynamicOutData": "<ParamRoot>..."
  }
}
```

### properties

| 字段 | 类型 | 说明 |
|------|------|------|
| continueExecuteTimGap | int | 连续执行间隔（ms） |
| stopWhenNG | bool | NG 时是否停止流程 |
| runTimeout | int | 运行超时（ms），0=不限 |
| shieldGlobalCtrl | bool | 是否屏蔽全局流程控制 |

### procedureIO

仅当流程包含 ProcedureComm 时存在：

| 字段 | 类型 | 说明 |
|------|------|------|
| params | object[] | 输入/输出参数定义 |
| params[].type | int | 参数类型：2=float/int，8=image |
| params[].name | string | 参数名（`%xxx%` 格式） |
| dynamicInData | string | DynamicInData XML，最多截断 500 字符 |
| dynamicOutData | string | DynamicOutData XML，最多截断 500 字符 |

---

## GlobalScript 对象

全局脚本，对应 `SolutionFile/GlobalScript_0`：

```json
{
  "version": "V4.4.0",
  "scriptLength": 2048,
  "hasPassword": false,
  "references": [
    { "name": "System.dll", "type": 0 }
  ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| version | string | 脚本版本号 |
| scriptLength | int | 脚本源码字节数 |
| hasPassword | bool | 脚本是否加密 |
| references | object[] | 脚本引用的程序集 |
| references[].name | string | 程序集名称 |
| references[].type | int | 引用类型 |

---

## moduleParamBindings

ModuleParamBinding protobuf 解析结果，将模块的 algori 参数绑定到另一模块的输出：

```json
{
  "targetModuleId": 5,
  "paramName": "EdgeThreshold",
  "unknown": 4
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| targetModuleId | int | 数据来源模块 ID |
| paramName | string | 被绑定的参数名 |
| unknown | int | 恒定值 4，含义未知 |
| unknownDataLen | int | 未知数据字节数（有数据时始终输出） |
| unknownDataB64 | string | 仅 `--include-raw`：未知数据 Base64 |

---

## 模块类型枚举

| type 字符串 | typeId | 说明 | ID 范围 |
|------------|--------|------|---------|
| Module | 0 | 普通算法模块 | 0~2047 |
| Procedure | 1 | 流程控制 | 10000~19999 |
| CommManager | 3 | 通信管理 | 按分配 |
| DataQueue | 4 | 数据队列 | 按分配 |
| GlobalVariable | 5 | 全局变量 | 按分配 |
| GlobalCamera | 6 | 全局相机 | 按分配 |
| LightConfig | 7 | 光源控制 | 按分配 |
| GlobalTrigger | 8 | 全局触发 | 按分配 |
| Group | 20 | 模块容器 | 20000+ |
| LocalVariable | 25 | 局部变量 | ProcedureID+14000 |
| ProcedureComm | 26 | 流程通信 | ProcedureID+16000 |
| Solution | 100 | 方案根节点 | — |

---

## 已知二进制参数类型

| name | 格式 | parsed 示例 |
|------|------|-------------|
| DynamicInData, DynamicOutData | XML 文本 | `<ParamRoot>...` |
| Input, Output | XML 文本 | `<ParamRoot>...` |
| VarData | XML 文本 | `<VarData>...` |
| Version | UTF-8 文本 | `V4.4.0` |
| IFText | UTF-8 文本 | 通信协议描述文本 |
| ShellContent | C# 源码 | `using System;\n...` |
| RoiType (矩形) | LE struct (22B) | `shapeType=0, x=100.00, y=200.00, w=300.00, h=400.00, flag=0` |
| RoiType (圆形) | LE struct (34B) | `shapeType=6, cx(n)=0.427388, cy(n)=0.622424, r(n)=0.162247,...` — 归一化 float32，需×图像尺寸恢复绝对值 |
| RoiType (精简) | LE struct (2B) | `flag=0` |
| DrawImageSize | LE struct (8B) | `w=640.0, h=480.0` |
| ExternRoiType | LE int16 | `1` |
| gateway | LE int32 | `0` |
| modules | 二进制块 | `(binary, N bytes)` — 交由 CommManagerParser 处理 |
| LightDeviceList | protobuf | `(protobuf, N bytes)` |
| ShellRefrences | 二进制块 | `(binary, N bytes)` — 交由 ShellParser 处理 |
| *.bmp, *.jpg 等 | 图片文件 | `(.jpg, N bytes)` — 仅标记，不读取内容 |
| 其他 ≤4KB 可读文本 | UTF-8 试探 | 如果可打印字符 >90% 则直接解码 |
| 其他 | 未知二进制 | `(binary, N bytes)` |

---

## warnings

解析过程中的非致命问题，位于 `solution.warnings`。无警告时为 `null`。

```json
"warnings": [
  "文件不存在: C:\\path\\to\\file.sol",
  "VmServer.xml 未找到",
  "ModuleFrame 未找到",
  "未知的 ModuleFrame 版本 440，可能无法正确解析名称槽位",
  "ModuleFrame 条目 \"procedure-10999-data\" (ID=10999) 在 VmServer.xml 中无对应模块，数据已跳过",
  "重复的 ModuleId=100 (IMVSBlobFindModu)，后续解析可能丢失数据",
  "GlobalScript_0 解析失败，JSON 格式可能已损坏",
  "文件已加密，需要密码",
  "密码错误",
  "解压失败: ReadBytes expected 512 bytes, got 7"
]
```

常见警告类型：
- **文件/路径**：文件不存在、VmServer.xml 或 MoudleFrame 未找到
- **格式版本**：ModuleFrame 版本不是 7 或 440（可能无法正确解析名称槽）
- **ID 不匹配**：ModuleFrame 条目在 VmServer.xml 中无对应模块
- **ID 重复**：VmServer.xml 中发现重复的模块 ID（后续解析可能丢数据）
- **解析异常**：二进制读取截断（如 `ReadBytes expected 512, got 7`）、protobuf 解码失败、GlobalScript JSON 损坏
- **加密/密码**：文件已加密需密码、密码错误
