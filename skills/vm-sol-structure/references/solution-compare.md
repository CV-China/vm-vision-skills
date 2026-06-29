# 方案对比（.sol diff）

## 概述

`VMSolutionParser.Cli compare` 命令对比两个 .sol 方案文件，输出结构化 diff。机械化的对比由 CLI 完成，Claude Code 拿到 diff 结果后做语义化解读。

## CLI 用法

```bash
compare -f1 old.sol -f2 new.sol              # 终端摘要
compare -f1 old -f2 new --verbose             # 展开详情
compare -f1 old -f2 new -o diff.json          # 输出 JSON 给 AI 分析
compare -f1 old -f2 new -p1 pwd1 -p2 pwd2    # 加密文件
```

## 跨版本模块匹配策略

VM 的模块 ID 是递增分配的，增删模块会导致 ID 整体偏移，不能直接用 ID 对比。

### 匹配流程

```
sol1 模块列表 ──┬── 按 FullPath 精确匹配 ──→ 匹配对 (oldId↔newId)
               ├── 未匹配 → 按 Name（类名）+ 父路径模糊匹配
               └── 仍未匹配 → 记为 Unmatched
ID 映射表建立后 → 翻译连线/订阅中的 ID → 再比较
```

**匹配键优先级：**

| 级别 | 匹配键 | 说明 |
|------|--------|------|
| 主键 | FullPath | 如"相机标定.边缘检测1"。用户不改全路径，最可靠 |
| 后备 | Name + ParentFullPath | FullPath 变化时仍可通过类名+父路径找到对应 |

FullPath 由 `DisplayName ?? Name` 沿 Parent 链拼接而成，如 `"流程0.检测组.BLOB分析"`。

### ID 映射

匹配完成后建立 `Dictionary<oldId, newId>` 映射。连线 (`FrontModuleIds`) 和订阅 (`TargetModuleId`) 中的 ID 通过映射翻译后再比较。

## 对比维度

| 维度 | 对比方式 |
|------|---------|
| 模块增删 | FullPath 匹配后，sol1 未匹配=删除，sol2 未匹配=新增 |
| 属性变更 | DisplayName / IsEnabled / TypeId |
| 算法参数 | 同名参数值变化（Truncate 到 100 字符） |
| 二进制参数 | ParsedContent 文本变化，或 RawData 字节级对比 |
| 执行连线 | FrontModuleIds 翻译后差集比较（边级别：added/removed） |
| 参数订阅 | SourceParamName 为键，值/目标/绑定方式变化 |
| 流程属性 | ContinueExecuteTimGap / StopWhenNG / RunTimeout / ShieldGlobalCtrl |
| 流程 IO | ProcedureIO Params 增删 + DynamicInData/OutData 变化 |
| 模块绑定 | ModuleParamBinding 按 ParamName 对比 |
| 全局脚本 | Version / ScriptContent 变化 |

## 终端摘要格式

```
=== 方案对比摘要 ===
模块: +2 (新增) / -1 (删除) / 5 (修改) / 共 48
流程: 1 个有变化
参数变更: 12 项
连线变更: 3 处
订阅变更: 1 处
绑定变更: +1 / -0 / 1 (修改)
全局脚本: 有变更 (0B → 3KB)
```

`--verbose` 模式下展开模块/连线/订阅详情。

## JSON Diff 输出结构

```json
{
  "summary": {
    "oldModuleCount": 45,
    "newModuleCount": 48,
    "oldProcedureCount": 1,
    "newProcedureCount": 1,
    "modulesAdded": 2,
    "modulesRemoved": 1,
    "modulesChanged": 5,
    "modulesUnmatched": 0,
    "proceduresChanged": 1,
    "paramsChanged": 12,
    "connectionsChanged": 3,
    "subscriptionsChanged": 1,
    "bindingsChanged": 1,
    "globalScriptChanged": 0
  },
  "modulesAdded": [
    {"fullPath": "相机标定.边缘检测1", "name": "CaliperEdge", "newModuleId": 6}
  ],
  "modulesRemoved": [
    {"fullPath": "相机标定.找圆1", "name": "CircleFindModu", "oldModuleId": 3}
  ],
  "modulesModified": [
    {
      "fullPath": "相机标定.条件检测1",
      "name": "IfModule",
      "oldModuleId": 0,
      "newModuleId": 0,
      "propertyChanges": [],
      "algoriParamChanges": [
        {"name": "LogicalMode", "oldValue": "1", "newValue": "0"}
      ],
      "binaryParamChanges": [
        {"name": "DynamicInData", "oldLength": 2048, "newLength": 2048, "contentChanged": true}
      ],
      "connectionChanges": [
        {"changeType": "added", "source": "相机标定.边缘检测1", "target": "相机标定.条件检测1"}
      ],
      "subscriptionChanges": [
        {"changeType": "modified", "sourceParam": "%int1%",
         "targetPath": "旧路径 → 新路径", "targetParam": "旧值 → 新值",
         "oldValue": "绑定(旧目标.旧参数)", "newValue": "绑定(新目标.新参数)",
         "oldIndexMode": "All", "newIndexMode": "All"}
      ]
    }
  ],
  "procedures": [
    {
      "procedureId": 10000,
      "changeType": "modified",
      "displayName": "相机标定",
      "propertyChanges": [
        {"name": "runTimeout", "oldValue": "0", "newValue": "5000"}
      ],
      "procedureIO": {
        "hasChanges": true,
        "paramChanges": [
          {"name": "%输入图像%", "oldValue": "null", "newValue": "null"}
        ]
      }
    }
  ],
  "bindings": {
    "hasChanges": true,
    "oldCount": 2,
    "newCount": 3,
    "itemsAdded": [
      {"paramName": "EdgeThreshold", "targetModuleId": 15, "targetPath": "流程0.边缘检测1"}
    ]
  },
  "globalScript": {
    "hasChanges": true,
    "oldVersion": "V3.4.0",
    "newVersion": "V3.5.0",
    "oldLength": 0,
    "newLength": 3072
  }
}
```

## Claude 的分析要点

拿到 diff JSON 后，结合 module-index 做后处理：

1. **moduleIndex** → 新增/删除模块的**中文名**和**分类**
2. **参数变化** → 关联 module-params.md 判断参数含义（如 LogicalMode=1→0 表示与运算→或运算）
3. **连线变化** → 判断拓扑结构变化对执行逻辑的影响
4. **连线槽位**（如果有） → 从 UiParamData 提取画布连线信息，验证逻辑连线与画布连线是否一致
