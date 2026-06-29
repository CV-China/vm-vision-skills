# 模块语言资源配置（中文名 + 输出参数中文名 + 帮助说明）

> 写入流程与交互规范见 **SKILL.md §模块语言资源配置**。本文档为格式参考与示例。

## 文件位置

VM 安装目录下 `Applications\Lang\`，三个文件：

| 文件 | 编码 | 用途 |
|---|---|---|
| `zh-cn.xaml` | UTF-8（实际为 UTF-8 with BOM） | 模块名 + 输出参数名 → 中文显示名 + 中文帮助说明 |
| `en-us.xaml` | UTF-8（实际为 UTF-8 with BOM） | 模块名 + 输出参数名 → 英文显示名 + 英文帮助说明 |
| `zh-cnLJ.xaml` | UTF-8（实际为 UTF-8 with BOM，部分 VM 版本无此文件） | 中文帮助说明（与 zh-cn.xaml 中的帮助说明内容一致） |

三个文件均以 `<ResourceDictionary xmlns=...>` 开头、`</ResourceDictionary>` 结尾。新条目追加在 `</ResourceDictionary>` 之前。

**编码说明**：VM 实际安装目录下的 Lang 文件为 UTF-8 with BOM（`EF BB BF`）。用 `codecs.open(f, 'r', 'utf-8-sig')` 读写可正确处理 BOM。写入后用 Python 读取验证（**禁止仅用 grep**——grep 可能因权限拦截或编码问题漏检）。

## 模块中文名格式

**zh-cn.xaml**（`</ResourceDictionary>` 前追加）：
```xml
  <sys:String x:Key="ImageModifyTool">图像调整模块</sys:String>
```

**en-us.xaml**（`</ResourceDictionary>` 前追加）：
```xml
  <sys:String x:Key="ImageModifyTool">ImageModifyTool</sys:String>
```

英文资源中 x:Key 与值相同（均为英文名），因为 VM 默认显示英文名。

## 输出参数中文名格式

agent 从 `<模块名>.xml` 的 Output Category 提取**所有 Combination 和 Filter 的 Name**（含 `ModuStatus`），为每个条目建议中文名。**不得只提取叶子 Filter**——几何类型（POINT/ROIBOX/LINE/ROIANNULUS）的父 Combination 和子 Combination 同样需要语言资源（详见下文 §几何输出参数的完整资源映射）。

**zh-cn.xaml**（`</ResourceDictionary>` 前追加）：
```xml
  <sys:String x:Key="thresholdOut">自适应阈值结果</sys:String>
  <sys:String x:Key="binarizeInfo">二值化统计信息</sys:String>
```

**en-us.xaml**（`</ResourceDictionary>` 前追加）：
```xml
  <sys:String x:Key="thresholdOut">thresholdOut</sys:String>
  <sys:String x:Key="binarizeInfo">binarizeInfo</sys:String>
```

英文资源 x:Key 与值相同。

## 模块帮助说明格式

帮助说明**同时追加中英双语**：中文追加到 `zh-cn.xaml` + `zh-cnLJ.xaml`（两文件内容一致），英文追加到 `en-us.xaml`。

**zh-cn.xaml** + **zh-cnLJ.xaml**（中文，`</ResourceDictionary>` 前追加）：
```xml
  <sys:String x:Key="ImageModifyTool_HELP" xml:space="preserve">
                        
        功能:对输入图像进行灰度调整，支持伽马校正和亮度校正两种模式。
        操作:
        1.连接并配置好输入图像；
        2.选择补偿模式（伽马校正 / 亮度校正）；
        3.设置对应的算法参数；
        4.运行。
  </sys:String>
```

**en-us.xaml**（英文，`</ResourceDictionary>` 前追加）：
```xml
  <sys:String x:Key="ImageModifyTool_HELP" xml:space="preserve">
                        
        Function: Adjust the grayscale of the input image, supporting Gamma correction and Brightness correction.
        Operation:
        1. Connect and configure the input image.
        2. Select the compensation mode (Gamma / Brightness).
        3. Set the corresponding parameters.
        4. Run.
  </sys:String>
```

x:Key = `模块英文名_HELP`。`xml:space="preserve"` 为必加属性。

**帮助说明模板**（agent 生成建议时套用）：
```
【中文】
功能:<一句话描述模块做什么>
操作:
1.连接并配置好输入图像；<—— 有图像输入时保留，无图像输入时不写此行>
2.<根据实际算法步骤>;
3.运行。

【English】
Function: <one-line description>
Operation:
1. Connect and configure the input image.
2. <actual steps>.
3. Run.
```

## 去重规则

1. 写入前对每个 x:Key 在 `zh-cn.xaml` 中搜索（仅需一个文件，中/英文资源一一对应）。**必须用 `">` 做键名尾部锚定，禁止子串 / 前缀匹配**：
   ```bash
   grep 'x:Key="KEY">' "$vmRoot/Applications/Lang/zh-cn.xaml"
   # 错误示例（禁止）：grep 'x:Key="MidPoint"'  → 会误命中 x:Key="MidPointX"
   ```
2. 帮助说明 key（`模块名_HELP`）在 `zh-cn.xaml` 中检查（中英资源一一对应，查一个即可）
3. 已存在 → **跳过不追加**，在结果清单中标注"⚠️ 已存在，跳过"。**展示清单中必须列出 grep 匹配到的具体行内容**，供人工核对是否为精确匹配还是一键多名
4. 不存在 → 用 Edit 替换 `</ResourceDictionary>` 为"新条目\n</ResourceDictionary>"
5. **禁止 Write 重写整个文件**（12000+ 行，极易截断丢失数据）

## 常见已存在条目（通常被去重跳过）

以下 x:Key 在 VM 全局语言资源中通常已存在，但仍按正常流程参与去重检查：

| x:Key | 中文值 |
|---|---|
| `ModuStatus` | 模块状态 |
| `OutImage` | 输出图像数据 |
| `OutImageWidth` | 输出图像宽度 |
| `OutImageHeight` | 输出图像高度 |
| `OutImagePixelFormat` | 输出图像像素格式 |

## 几何输出参数的完整资源映射

> ⚠️ **重要**：当模块输出 POINT / LINE / ROIBOX / ROIANNULUS 等几何类型时，**不仅要为叶子 Filter 添加语言资源，还必须为每一层 Combination（包括子 Combination）添加资源**。

### 各几何类型需要的完整 x:Key 条目

| 输出类型 | 需要的 x:Key | 数量 |
|---|---|---|
| **POINT** | Combination 名 + 2 个叶子 Filter（X/Y） | 1 + 2 = **3** |
| **LINE** | 根 Combination + StartPoint + EndPoint + 4 个叶子 Filter（StartX/Y, EndX/Y） | 3 + 4 = **7** |
| **ROIBOX** | 根 Combination + CenterPoint + 5 个叶子 Filter（CenterX/Y, Width, Height, Angle） | 2 + 5 = **7** |
| **ROIANNULUS** | 根 Combination + CenterPoint + 6 个叶子 Filter（CenterX/Y, InnerRadius, Radius, StartAngle, AngleExtend） | 2 + 6 = **8** |

### 示例：ROIBOX 输出（OutRect）

`<模块名>.xml` Output Category 定义：
```xml
<Combination Name="OutRect" Style="ROIBOX">
    <Filters>
        <Combination Name="OutRectCenterPoint" Style="POINT">
            <Filters>
                <Filter Name="OutRectCenterX" ValueType="float" .../>
                <Filter Name="OutRectCenterY" ValueType="float" .../>
            </Filters>
        </Combination>
        <Filter Name="OutRectWidth" ValueType="float" .../>
        <Filter Name="OutRectHeight" ValueType="float" .../>
        <Filter Name="OutRectAngle" ValueType="float" .../>
    </Filters>
</Combination>
```

需要添加的**全部 7 个**语言资源条目：

```
// zh-cn.xaml — 按层次：
OutRect               → 输出矩形
OutRectCenterPoint    → 输出矩形中心点
OutRectCenterX        → 输出矩形中心X
OutRectCenterY        → 输出矩形中心Y
OutRectWidth          → 输出矩形宽度
OutRectHeight         → 输出矩形高度
OutRectAngle          → 输出矩形角度

// en-us.xaml — 英文资源 x:Key 与值相同
```

**agent 自检**：生成语言资源建议清单时，必须遍历 `<模块名>.xml` Output Category 中**所有层级**的 Combination + Filter Name，**不得只遍历叶子 Filter**。
