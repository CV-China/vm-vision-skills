---
name: vm-sol-structure
description: Use when understanding VisionMaster solution topology — module hierarchy, execution connections, parameter subscriptions, data flow, procedure configuration, Group nesting, or VmServer.xml structure. Also triggers on questions about module types (Type enum), module ID ranges, GUID types, or how modules connect and exchange data in a VM solution.
author: Kyron.Zhang
version: 2.3.2
---

# VM 方案结构理解

## 声明

1. **逆向工程知识沉淀**：本 skill 内容来自对 VisionMaster 方案文件的逆向分析，仅供学习和技术研究使用。
2. **版本兼容性**：结构基于 V4.4.0+ 版本，不保证跨版本兼容。
3. **内部使用**：仅供 HIK 公司内部员工使用，未经授权不得对外分发。

---

## 核心概念

VM 方案有三层结构：**逻辑层**（VmServer.xml：模块定义、连线、订阅）、**参数层**（ModuleFrame：算法参数、脚本、输入输出定义）、**画布层**（UiParamData/：坐标、槽位、就绪状态）。三层通过 moduleId（整数）关联。

---

## 三层结构

```
逻辑层（VmServer.xml）
    模块定义、连线关系、参数订阅、流程配置

参数层（ModuleFrame）
    每个模块的算法参数、脚本内容、输入输出定义

画布层（UiParamData/）
    每个模块的画布坐标、连线槽位、就绪状态
```

---

## 路由表

| 需要了解 | 参考文件 |
|---------|----|
| 模块层级架构、Type 枚举、ID 分段规律、三类 GUID | `references/modules.md` |
| 执行连线 vs 参数订阅 vs 连线槽位、两种绑定机制、图像订阅 4 元组、DynamicIO、典型数据流模式 | `references/connections.md` |
| VmServer.xml 全部节点清单及 XML 示例 | `references/vmserver-xml.md` |
| 模块类名-中文名-分类对照表（含 Help GUID）、索引生成方法 | `references/module-index.md` |
| 全模块运行参数速查 | `references/module-params.md` |
| BlobFind 参数-帮助对照示例 | `references/blobfind-params-help.md` |
| 方案对比：跨版本模块匹配策略、对比维度、JSON diff 格式 | `references/solution-compare.md` |
| **parse 命令输出的 JSON 字段含义（完整 schema）** | `references/solution-parse-schema.md` |
| **修改方案参数并输出新 sol** | 见 vm-sol-format skill → `tools/VMSolutionParser.Cli.exe` (modify 命令) |
| **查看指定模块参数（AI 生成 changes.json 前用）** | 见 vm-sol-format skill → `tools/VMSolutionParser.Cli.exe` (inspect 命令) |
| **AI 改参指南（联动关系/枚举值查找）** | `references/param-modify-guide.md` |
| **直接解析 .sol 文件获取结构化 JSON** | 见 vm-sol-format skill → `tools/VMSolutionParser.Cli.exe` (parse 命令) |
| **对比两个 .sol 方案（终端摘要 + JSON diff）** | 见 vm-sol-format skill → `tools/VMSolutionParser.Cli.exe` (compare 命令) |

---

## 模块类型速查

| Type | 名称 |
|------|------|
| 0 | 普通算法模块 |
| 1 | IMVSProcessControl（流程控制） |
| 3 | CommManagerModule |
| 4 | DataQueueModule |
| 5 | GlobalVariableModule |
| 6 | GlobalCameraModule |
| 7 | LightControl（光控模块，代码枚举名 LightConfig） |
| 8 | GlobalTriggerModule |
| 20 | IMVSGroup |
| 25 | LocalVariableModule |
| 26 | ProcedureComm |
| 100 | Solution 根节点 |

## 模块 ID 速查

| ID 范围 | 用途 |
|---------|------|
| 0 ~ 2047 | 普通算法模块 |
| 10000 ~ 19999 | 流程（Procedure） |
| 20000+ | Group |
| ProcedureID + 14000 | 流程局部变量 |
| GroupID + 10000 | Group 局部变量 |
| ProcedureID + 16000 | ProcedureComm |
