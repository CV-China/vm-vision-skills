# `<模块名>Display.xml` —— 结果渲染

控制模块运行完成后，VM 主界面**预览窗口**和**结果面板**显示什么。

## 🚫 反编造对照表（写渲染节点前先核对）

| 编造写法（**禁用**） | 真实写法 |
|---|---|
| `<DisplayRoot>` / `<DisplayConfig>` / `<Display Name="..." Version="...">` 作根节点 | 根节点是 `<ParamRoot><Categorys><Category Name="Display">` |
| `<Objects>` 包一层 | `<Category Name="Display"><Items>` 下直接挂 `<Object>`，无 `<Objects>` 中间层 |
| `<Object Mapping="OutImage,...">` 在 Object 标签上用 Mapping 属性 | Object **无** Mapping 属性；用 `<Features><Feature Name="Image" Mapping="OutImage" Value="{0}"/>` 子节点 |
| 图像 Object 只写 1 个 Feature | 图像必须 **4 个** Feature（Image / Height / Width / PixelFormat），名称与 `<模块名>.xml` Combination Filter 对齐 |
| `<Object Type="Image">` / `Rect` / `Point` （大写） | 全小写：`image` / `rect` / `point` / `line` / `datarecord` / `datalist` |
| `<Object Name="Result List" Type="resultlist"/>` | 真实类型是 `datalist`（不是 resultlist） |
| 缺 `Data Record` 和 `Result List` 两个 Object | 这两个**必带**，否则结果面板不显示运行数据 |
| `IsArray="True"` / `"true"` 不统一 | 用 `IsArray="true"`（全小写） |
| 想输出 ROI 给基类 → 加 `<Object Name="OutROI" Type="rect" .../>` | **删除** —— ROI 由基类自动回显（保留模板自带的 `<Object Name="ROI">` 节点即可，**不要**重复加 OutROI） |

**写渲染节点前先 grep `templates/AlgTemplate/AlgTemplate/AlgTemplateDisplay.xml` 验证**。

## 顶层结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ParamRoot>
    <Categorys>
        <Category Name="Display" okcolor="#7cfc00" ngcolor="#ff0000">
            <Items>
                <Object Name="InputImage" Type="image" okcolor="#66ff00" ngcolor="#ff0000"
                        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1" IsDisplay="true">
                    <Features>
                        <Feature Name="Image"       Mapping="InImage"            Value="{0}"/>
                        <Feature Name="Height"      Mapping="InImageHeight"      Value="0"/>
                        <Feature Name="Width"       Mapping="InImageWidth"       Value="0"/>
                        <Feature Name="PixelFormat" Mapping="InImagePixelFormat" Value="0"/>
                    </Features>
                </Object>
                <Object Name="OutputImage" Type="image" okcolor="#66ff00" ngcolor="#ff0000"
                        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1" IsDisplay="true">
                    <Features>
                        <Feature Name="Image"       Mapping="OutImage"            Value="{0}"/>
                        <Feature Name="Height"      Mapping="OutImageHeight"      Value="0"/>
                        <Feature Name="Width"       Mapping="OutImageWidth"       Value="0"/>
                        <Feature Name="PixelFormat" Mapping="OutImagePixelFormat" Value="0"/>
                    </Features>
                </Object>
                <Object Name="ROI" Type="rect" okcolor="#66ff00" ngcolor="#ff0000"
                        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1" IsDisplay="true"
                        highLightEnable="false">
                    <Features>
                        <Feature Name="CenterX" Mapping="DetectCenterX" Value="0"/>
                        <Feature Name="CenterY" Mapping="DetectCenterY" Value="0"/>
                        <Feature Name="Width"   Mapping="DetectWidth"   Value="0"/>
                        <Feature Name="Height"  Mapping="DetectHeight"  Value="0"/>
                        <Feature Name="Angle"   Mapping="DetectAngle"   Value="0"/>
                        <Feature Name="Tips"
                                 Mapping="DetectCenterX,DetectCenterY,DetectWidth,DetectHeight,DetectAngle"
                                 Value="CenterX:{0},CenterY:{1} Width:{2} Height:{3} Angle:{4}"/>
                        <Feature Name="Status"  Mapping="NULL" Value="1"/>
                    </Features>
                </Object>
                <Object Name="Data Record" Type="datarecord" okcolor="#66ff00" ngcolor="#ff0000"
                        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="2" IsDisplay="true">
                    <Features>
                        <Feature Name="Content" Value="Module State:{0}" Mapping="ModuStatus"/>
                        <Feature Name="Num"     Value="1"                Mapping="NULL"/>
                    </Features>
                </Object>
                <Object Name="Result List" Type="datalist" okcolor="#66ff00" ngcolor="#ff0000"
                        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="2" IsDisplay="true">
                    <Features>
                        <Feature Name="Colume" Value="ModuStatus" Mapping="ModuStatus"/>
                        <Feature Name="Num"    Value="1"          Mapping="NULL"/>
                    </Features>
                </Object>
            </Items>
        </Category>
    </Categorys>
</ParamRoot>
```

`Data Record`（Type="datarecord"）与 `Result List`（Type="datalist"）**必须保留**，VM 用这两个节点更新结果面板与历史记录。

## Object 类型

| Type | 用途 | 标准 Feature Name | 说明 |
|---|---|---|---|
| `image` | 渲染图像 | Image / Height / Width / PixelFormat | 4 个 Feature，Mapping 引用 `<模块名>.xml` 对应 Filter Name |
| `rect` | 渲染矩形 | CenterX / CenterY / Width / Height / Angle / Tips / Status | ArrayMatch 不支持 |
| `circle` | 渲染圆/扇环 | CenterX / CenterY / MajorRadius / MinorRadius / Tips / Status | 圆时 MajorRadius = MinorRadius；扇环时 MajorRadius 为外径。圆和扇环是同一种参数类型 |
| `line` | 渲染直线 | StartLineX / StartLineY / EndLineX / EndLineY / Tips / Status | 可选属性：`NeedLabel` / `arrowsize` |
| `point` | 渲染点 | CenterX / CenterY / Tips / Status | 数组时加 `ArrayMatch="true"` |
| `text` | 显示文本叠加 | Content | Mapping 引用 string Filter |
| `datarecord` | 数据历史区 | Content（格式串）+ Num | 必带 |
| `datalist` | 结果列表 | Colume（列字段名）+ Num | 必带 |

### Feature Name 约束

- **Feature `Name` 是固定值**（如 `StartLineX` / `CenterX`），不可自定义
- **Feature `Mapping` 引用 `<模块名>.xml` 中对应 Filter Name**，需一一对应
- **Status Feature**: `Mapping="ModuStatus"`（结果有效时才渲染）或 `Mapping="NULL" Value="1"`（始终渲染）
- **Tips Feature**: `Mapping` 为逗号拼接的多个 Filter Name，`Value` 为格式化串 `{0}`~`{N}`

### 几何 Object 模板

```xml
<!-- 矩形 -->
<Object Name="Box Result" Type="rect" okcolor="#66ff00" ngcolor="#ff0000"
        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="2"
        IsDisplay="true" highLightEnable="false">
    <Features>
        <Feature Name="CenterX" Mapping="ListBoxCenterX" Value="0" />
        <Feature Name="CenterY" Mapping="ListBoxCenterY" Value="0" />
        <Feature Name="Width"   Mapping="ListBoxWidth"   Value="0" />
        <Feature Name="Height"  Mapping="ListBoxHeight"  Value="0" />
        <Feature Name="Angle"   Mapping="ListBoxAngle"   Value="0" />
        <Feature Name="Tips"    Mapping="ListBoxCenterX,ListBoxCenterY,ListBoxWidth,ListBoxHeight,ListBoxAngle"
                Value="CenterX:{0},CenterY:{1} Width:{2} Height:{3} Angle:{4}" />
        <Feature Name="Status"  Mapping="ModuStatus" Value="1" />
    </Features>
</Object>

<!-- 圆/扇环 -->
<Object Name="Circle Result" Type="circle" okcolor="#66ff00" ngcolor="#ff0000"
        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1" IsDisplay="true">
    <Features>
        <Feature Name="CenterX"     Mapping="ListCircleCenterX" Value="0" />
        <Feature Name="CenterY"     Mapping="ListCircleCenterY" Value="0" />
        <Feature Name="MajorRadius" Mapping="ListRadius"        Value="0" />
        <Feature Name="MinorRadius" Mapping="ListRadius"        Value="0" />
        <Feature Name="Tips"        Mapping="ListCircleCenterX,ListCircleCenterY,ListRadius"
                Value="CircleSite:Center({0},{1}) Radius={2}" />
        <Feature Name="Status"      Mapping="ModuStatus" Value="0" />
    </Features>
</Object>

<!-- 直线 -->
<Object Name="Line Result" Type="line" okcolor="#66ff00" ngcolor="#ff0000"
        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="2"
        IsDisplay="true" NeedLabel="false" arrowsize="10">
    <Features>
        <Feature Name="StartLineX" Mapping="ListStartX" Value="0" />
        <Feature Name="StartLineY" Mapping="ListStartY" Value="0" />
        <Feature Name="EndLineX"   Mapping="ListEndX"   Value="0" />
        <Feature Name="EndLineY"   Mapping="ListEndY"   Value="0" />
        <Feature Name="Tips"       Mapping="ListStartX,ListStartY,ListEndX,ListEndY"
                Value="LineSite:StartPoint({0},{1}) EndPoint({2},{3})" />
        <Feature Name="Status"     Mapping="ModuStatus" Value="0" />
    </Features>
</Object>

<!-- 点(数组) -->
<Object Name="Contour Point Result" Type="point" okcolor="#66ff00" ngcolor="#ff0000"
        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1" IsDisplay="true">
    <Features>
        <Feature Name="CenterX" Mapping="ListPointX" Value="0" ArrayMatch="true" />
        <Feature Name="CenterY" Mapping="ListPointY" Value="0" ArrayMatch="true" />
        <Feature Name="Tips"    Mapping="ListPointX,ListPointY"
                Value="CountourPoint:({0},{1}) " ArrayMatch="true" />
        <Feature Name="Status"  Mapping="ModuStatus" Value="0" />
    </Features>
</Object>
```

## 无图像输入修改

删除：
- `<Object Name="InputImage" Type="image">` 及其 `<Features>` 子树
- `<Object Name="OutputImage" Type="image">` 及其 `<Features>` 子树（如也无图像输出）
- `<Object Name="ROI" Type="rect">` 及其 `<Features>` 子树

保留：
- `<Object Name="Data Record" Type="datarecord" ...>` + `<Features>` 子树
- `<Object Name="Result List" Type="datalist" ...>` + `<Features>` 子树

**删除前务必检查**：是否仍有需要渲染的几何输出（如点集、直线、矩形）。

## 多图像输出

每个图像独立 Object，Feature 字段名与 `<模块名>.xml` 输出 Combination Filter Name **完全一致**：

```xml
<Object Name="OutputImage1" Type="image" okcolor="#66ff00" ngcolor="#ff0000"
        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1" IsDisplay="true">
    <Features>
        <Feature Name="Image"       Mapping="OutImage1"            Value="{0}"/>
        <Feature Name="Height"      Mapping="OutImage1Height"      Value="0"/>
        <Feature Name="Width"       Mapping="OutImage1Width"       Value="0"/>
        <Feature Name="PixelFormat" Mapping="OutImage1PixelFormat" Value="0"/>
    </Features>
</Object>
<Object Name="OutputImage2" Type="image" okcolor="#66ff00" ngcolor="#ff0000"
        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1" IsDisplay="true">
    <Features>
        <Feature Name="Image"       Mapping="OutImage2"            Value="{0}"/>
        <Feature Name="Height"      Mapping="OutImage2Height"      Value="0"/>
        <Feature Name="Width"       Mapping="OutImage2Width"       Value="0"/>
        <Feature Name="PixelFormat" Mapping="OutImage2PixelFormat" Value="0"/>
    </Features>
</Object>
```

## 命名约束

- `Object Name` 在 VM 渲染层只是标识，但**约定俗成**：InputImage / OutputImage / ROI 等保持一致
- Feature `Mapping` 中字段名必须与 `<模块名>.xml` 中 Filter Name **完全一致**（含大小写）

## ⚠️ Edit 工具插入 Object 的铁律（防止 XML 嵌套错乱）

### 问题

用 Edit 工具在模板中**插入**新 `<Object>`（如几何输出的 OutRect）时，必须用**前一个 Object 的 `</Object>` + 后一个 Object 的 `<Object Name="...">`** 组合作为 `old_string` 锚点（单独 `</Object>` 不唯一，模板有 5 个）。

**Agent 极易在这个操作中把前一个 Object 的 `</Object>` 吃掉而不还原**，导致前一个 Object 失去闭合标签 → 新 Object 被错误嵌套进去 → 文件末尾多出一个孤儿 `</Object>`。

### 错例（ROI 的 `</Object>` 被吃掉）

```
old_string:
"                </Object>
					<Object Name=\"Data Record\" Type=\"datarecord\""

new_string:
"
                <Object Name=\"OutRect\" Type=\"rect\" ...>
                    <Features>...</Features>
                </Object>
					<Object Name=\"Data Record\" Type=\"datarecord\""
```

结果：ROI 没有 `</Object>` 闭合 → OutRect 嵌套在 ROI 内部 → 末尾多一个孤儿 `</Object>`。

### 正例（ROI 的 `</Object>` 原样保留）

```
old_string:
"                </Object>
					<Object Name=\"Data Record\" Type=\"datarecord\""

new_string:
"                </Object>
                <Object Name=\"OutRect\" Type=\"rect\" ...>
                    <Features>...</Features>
                </Object>
					<Object Name=\"Data Record\" Type=\"datarecord\""
```

> **铁律**：`old_string` 中如果包含前一个元素的 `</Object>`，`new_string` 的**第一个非空行必须是这个 `</Object>`**（原样保留），然后才是新插入的 `<Object>...</Object>`，最后恢复 `old_string` 的剩余部分。

### 多个几何输出 Object 连续插入

若需插入多个几何 Object（如 OutRect + OutLine），**一次性完成**，不要多次 Edit 累积风险：

```
old_string:
"                </Object>
					<Object Name=\"Data Record\" Type=\"datarecord\""

new_string:
"                </Object>
                <Object Name=\"OutRect\" Type=\"rect\" ...>...</Object>
                <Object Name=\"OutLine\" Type=\"line\" ...>...</Object>
					<Object Name=\"Data Record\" Type=\"datarecord\""
```

### 自检

写完 Display.xml 后立即检查：
1. 统计 `<Object ` 和 `</Object>` 数量是否相等
2. 每个几何输出 Object 的 `</Object>` 是否都在**同级**（不在其他 Object 内部）
3. Data Record 和 Result List 的 `</Object>` 是否存在
