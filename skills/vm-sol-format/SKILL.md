---
name: vm-sol-format
description: Use when reading, writing, or operating on VisionMaster .sol solution files — parsing ModuleFrame/UiParamData/GlobalScript_0 binary formats, extracting module parameters and scripts, comparing two sol files, modifying binary data and rebuilding .sol files. Also triggers when the user provides a .sol file directly, asks about binary layout, or needs to modify/compare/rebuild sol files.
author: Kyron.Zhang
version: 2.3.2
---

# VM 方案文件格式与操作（解析 + 对比 + 重建）

## 声明

1. **逆向工程知识沉淀**：本 skill 内容来自对 VisionMaster 方案文件的逆向分析，仅供学习和技术研究使用。
2. **版本兼容性**：格式基于 V4.4.0+ 版本，不保证跨版本兼容。不同 VM 版本的二进制格式可能有差异。
3. **内部使用**：仅供 HIK 公司内部员工使用，未经作者授权不得对外分发。

---

## 核心概念

sol 文件是 ZIP 压缩包。解压后得到 `SolutionFile/` 目录，包含三部分数据：
- **ModuleFrame**（VM 内部拼写为 MoudleFrame）：所有模块的二进制参数（算法参数、脚本、输入输出定义）
- **VmServer.xml**：模块列表、连线关系、参数订阅、流程配置
- **UiParamData/**：每个模块的画布坐标、连线槽位、就绪状态

本 skill 覆盖三大操作：
- **读（parse）**：sol → 结构化 JSON
- **比（compare）**：两个 sol → diff
- **写（rebuild）**：修改方案（changes.json）→ 回写 sol

---

## 路由表

> 模块类型、连线关系、参数订阅等概念见 vm-sol-structure skill。

| 需要了解 | 参考文件 |
|---------|----|
| sol = ZIP，加密检测，解压方法 | `references/format-sol-zip.md` |
| modify 命令 changes.json schema | `references/format-sol-modify.md` |
| **ZIP 回写 + ModuleFrame 重建 + UiParamData TLV 补丁** | `references/format-sol-rebuild.md` |
| **直接解析 .sol 获取结构化 JSON** | `tools/VMSolutionParser.Cli.exe parse -f <file> [-p pw] [-o out.json] [--include-raw]` |
| **对比两个 .sol 方案（终端摘要 + JSON diff）** | `tools/VMSolutionParser.Cli.exe compare -f1 a.sol -f2 b.sol [-p1 pw1] [-p2 pw2] [--verbose] [-o out.json]` |
| **修改方案参数并输出新 sol** | `tools/VMSolutionParser.Cli.exe modify -f <sol> -c changes.json -o output.sol [-p pw]` |
| **查看指定模块参数（AI 生成 changes.json 前用）** | `tools/VMSolutionParser.Cli.exe inspect -f <sol> [-m <fullPath> \| --list] [-p pw]` |
| **从 HTML 流程图生成新 sol 方案** | `tools/VMSolutionParser.Cli.exe generate -f input.html -o output.sol [--base base.sol] [--templates dir]` |
| **自动集成入口** | `2d-vision-guidance-expert` 的 `vm_flow_builder.py` → `generate_sol_from_html()` → 自动调用本 CLI |
| generate 命令工作原理 + 自带词表 + 选基底策略 | `references/format-sol-generate.md` |
| 模板 sol 库（按场景分类，generate/addModule 引用） | `templates/` |
| parse 命令输出 JSON schema | 见 vm-sol-structure skill |
| 方案对比 diff JSON schema | 见 vm-sol-structure skill |
| **引用完整性校验（每次修改后运行）** | `node references/scripts/validate-skill.js --all` |
| **5 分钟快速上手** | `Quickstart.md` |

---

## 内容维护规则

**增补前检查：你要添加的信息是否已在其他文件中存在？**

| 信息类型 | 唯一权威来源 | 其他文件 |
|---------|-------------|---------|
| ZIP 结构/解压/加密 | `format-sol-zip.md` | 只引用，不复述 |
| modify changes.json schema | `format-sol-modify.md` | 只引用，不复述 |
| ZIP 回写/重建/repack | `format-sol-rebuild.md` | 只引用，不复述 |
| 模块类型/ID/架构 | `vm-sol-structure → modules.md` | 只引用，不复述 |
| 连线/订阅/DynamicIO | `vm-sol-structure → connections.md` | 只引用，不复述 |
| CLI 命令用法 | `tools/VMSolutionParser.Cli.exe`（SKILL.md 路由表） | 只在路由表中写 CLI 一行 |
| JSON schema（parse/compare） | vm-sol-structure skill | 只引用，不复述 |

**SKILL.md 自身保留：** 行为准则（解析原则/写入原则的简要摘要）、路由表、声明、模块类型/ID 速查表。

修改后运行 `node references/scripts/validate-skill.js --all` 校验引用完整性。

---

## 解析原则

1. **不读取大型二进制内容**：图像数据（CurImageData）、模板 binary、BMP/JPG 附件等，只记录大小和存储位置
2. **密码直接询问用户**，不尝试从 DLL 提取或暴力破解
3. **遇到不确定的参数值**，建议用户打开 VM 软件对照验证
4. **标准模块用标准解析**，特殊模块（name slot 不以 `{ID}-` 开头）使用专用格式，由 CLI 自动处理

## 写入原则

详见 `references/format-sol-rebuild.md`。核心要点：dataLen 变更须重建 ModuleFrame、Hzip DEFLATE 压缩（非加密回退手动 Stored）、反斜杠路径、TLV val_len 同步。

---

## 标准工作流

### 读取流程

1. **解压 sol**：见 `references/format-sol-zip.md`
2. **parse 命令**：CLI 自动解析 ModuleFrame/VmServer.xml/UiParamData/GlobalScript_0
3. 输出结构化 JSON，schema 见 vm-sol-structure skill

### 写入流程

1. **modify 命令**：准备 changes.json（schema 见 `references/format-sol-modify.md`）
2. CLI 自动重建 ModuleFrame → 补丁 UiParamData → 回写 ZIP
3. 重建细节见 `references/format-sol-rebuild.md`

### 修改代码后必须回归测试

修改任何 .cs 文件后，编译 + 全量测试，确认无回退：

```bash
MSBuild.exe VMSolutionParser.sln -t:Build -p:Configuration=Debug -verbosity:minimal
vstest.console.exe Tests/bin/Debug/VMSolutionParser.Tests.dll /TestAdapterPath:<NUnitAdapter> /Platform:x64
```

标准: 编译 0 警告，全部测试通过。
