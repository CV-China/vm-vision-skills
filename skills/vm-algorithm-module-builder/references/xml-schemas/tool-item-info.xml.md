# `ToolItemInfo.xml` —— 工具箱位置与命名

VM 启动时扫描所有模块的 `ToolItemInfo.xml`，按内容把模块挂到工具箱树的指定位置。

> **来源**：本文档结构直接抄自 `templates/AlgTemplate/AlgTemplate/ToolItemInfo.xml`。模板实际使用 `<ToolBoxItemData>` 根节点，**不要**编造 `<ToolItemInfo>` / `<ToolInfo>` / `<ToolItem>`。

## 完整结构（来自模板）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ToolBoxItemData>
    <name>ImageModifyTool</name>
    <priority>100</priority>
    <toolTip>ImageModifyTool</toolTip>
</ToolBoxItemData>
```

## 字段含义

| 字段 | 用途 |
|---|---|
| `<name>` | 模块内部名，与目录名一致即可 |
| `<priority>` | 工具箱排序优先级（100 为默认值） |
| `<toolTip>` | 鼠标悬停提示文本 |

## 部署位置

ToolItemInfo.xml 所在的**目录名**决定子分组：

```
VisionMaster4.X.0\Applications\Module(sp)\x64\<工具箱>\<模块目录>\ToolItemInfo.xml
                                              ↑           ↑
                                         一级（工具箱名）  二级（模块名）
```

工具箱名（如 `UserTools` / `MeasureTools` / `LogicTools`）由用户在调用 skill 时指定，默认 `UserTools`。

## 注意

- 修改后需**重启** VM 才生效（启动时扫描）
- 模块的中文名称在**语言资源文件**中定义，不在本文件也不在 C++/C#/XML 中
- 同一 Group 下不要有同 Name 的模块，否则后加载的覆盖
- **绝对不要**改成 `<ToolItemInfo>` 带 `<ChineseName>/<EnglishName>` 格式 —— 那是编造的，模板真实格式就是 `<ToolBoxItemData>`

## 落盘后自检

```bash
# 根节点必须是 ToolBoxItemData
grep -n "<ToolBoxItemData>" <output>/ToolItemInfo.xml || echo "FAIL: wrong root node"
# 禁止编造的 ToolItemInfo 格式
grep -nE "<ToolItemInfo>|<ChineseName>|<EnglishName>|<ChineseGroup>|<EnglishGroup>|<ToolType>" <output>/ToolItemInfo.xml && echo "FAIL: fabricated ToolItemInfo format"
```
