# VM Sol Skills — 5 分钟快速上手

## 这是什么

一套帮助你看懂和修改 VisionMaster .sol 方案文件的工具。两个 skill 配合使用：

- **vm-sol-format**：操作 sol 文件（解析/对比/修改）
- **vm-sol-structure**：理解方案结构（模块是什么/怎么连的）

## 前提

- 已配置 Claude Code
- 两个 skill 已部署到 `~/.claude/skills/`
- CLI 工具在 `~/.claude/skills/vm-sol-format/tools/`（含 VMSolutionParser.Cli.exe + Hzip.dll + ZipManager.dll）

## 场景一：看一下方案里有什么

```bash
# 解析 sol 文件，输出到 JSON 文件
Cli.exe parse -f 方案.sol -o result.json

# 加密方案需要密码
Cli.exe parse -f 方案.sol -o result.json -p 密码
```

输出 JSON 包含：模块列表、参数、订阅关系、连线、流程结构等完整信息。

## 场景二：快速查看有哪些模块

```bash
# 列出所有模块
Cli.exe inspect -f 方案.sol --list

# 查看某个模块的全部参数
Cli.exe inspect -f 方案.sol -m "流程0.BLOB分析"
```

## 场景三：对比两个方案改了哪里

```bash
Cli.exe compare -f1 方案V1.sol -f2 方案V2.sol

# 加密方案分别指定密码
Cli.exe compare -f1 方案V1.sol -f2 方案V2.sol -p1 123 -p2 456
```

输出：终端摘要 + 可选 JSON diff 文件（`-o diff.json`）。

## 场景四：修改方案参数

### 4.1 改参数值

创建 `changes.json`：

```json
{
  "changes": [
    {
      "action": "setParam",
      "target": "流程0.BLOB分析",
      "paramName": "EdgeThreshold",
      "value": "30"
    }
  ]
}
```

```bash
Cli.exe modify -f 方案.sol -c changes.json -o 方案_new.sol
```

### 4.2 改订阅（重新连线）

```json
{ "action": "setBasicSub", "target": "流程0.分支选择", "paramName": "条件", "newTargetPath": "流程0.类型判断", "newTargetParamName": "结果（INT）" }
```

### 4.3 更多操作

支持操作：`setParam` / `setBinaryParam` / `setBasicSub` / `addBasicSub` / `removeBasicSub` / `setParamSub` / `addParamSub` / `removeParamSub` / `addConnection` / `removeConnection` / `addModule` / `setDisplayName` / `setEnabled` / `deleteModule`。详见 `vm-sol-format/references/format-sol-modify.md`。

## 场景五：直接和 AI 对话操作

配置好 Claude Code 后，直接对话即可：

> "帮我把流程0.BLOB分析的 EdgeThreshold 改成 50"
>
> "对比这两个方案，看看 Flow1 里哪些模块参数变了"
>
> "在流程0里新增一个二值化模块"

AI 会自动生成 changes.json 并调用 CLI 完成操作。

## 了解更多

| 想了解 | 看这个 |
|--------|--------|
| CLI 命令完整参数 | `SKILL.md` 路由表 |
| modify 全部 8 种操作 | `references/format-sol-modify.md` |
| 模块有哪些类型、怎么连线 | `vm-sol-structure/references/modules.md` |
| ModuleFrame 二进制格式 | `references/format-moduleframe.md` |
| 方案对比 diff 格式 | `vm-sol-structure/references/solution-compare.md` |
| 模块索引（类名-中文名-分类对照） | `vm-sol-structure/references/module-index.md` |

## 常见问题

**Q: 修改后方案打不开？**
用 VM 软件打开验证。大部分参数修改不影响方案结构，但如果改了模块 ID 或删了有连线的模块需要同步清理连线。

**Q: 加密方案忘记密码？**
无法处理。CLI 不支持暴力破解。

**Q: 为什么不直接在 VM 里改？**
批量操作（改 50 个模块的同一个参数）、自动化流水线、方案对比等场景，CLI 比手动操作快很多。
