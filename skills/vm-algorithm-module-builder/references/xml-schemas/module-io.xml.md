# `<模块名>.xml` —— 基本参数（I/O）定义

控制模块的输入/输出端口 + 模块元信息。VM 平台启动时解析此文件构建模块端口图与显示名。

> **来源**：本文档结构直接抄自 `templates/AlgTemplate/AlgTemplate/AlgTemplate.xml`。**不要**自己编造 `<ModuleConfig>` 之类的根节点 —— 真实根节点是 `<ParamRoot>`。

## 🚫 反编造对照表（写 I/O 端口前先核对）

| 编造写法（**禁用**） | 真实写法 |
|---|---|
| `<ModuleConfig>` / `<Module>` 作根节点 | `<ParamRoot>` |
| `<Inputs>` / `<Outputs>` 作 Category | `<Category Name="Input">` / `<Category Name="Output">`（用 Name 属性区分） |
| 图像输入用裸 `<Image Name="InImage"/>` | **必须** `<Combination Name="InputImage" Style="IMAGE">` + 4 Filter（InImage / InImageWidth / InImageHeight / InImagePixelFormat） |
| 图像输出用裸 `<Image Name="OutImage"/>` | **必须** `<Combination Name="OutputImage" Style="IMAGE">` + 4 Filter（OutImage / OutImageWidth / OutImageHeight / OutImagePixelFormat） |
| `<Filter ValueType="image" IsArray="true"/>` 表达多图 | 多图用**多个** `<Combination Style="IMAGE">`，每个独立 4 Filter |
| 在 `<模块名>.xml` 加 InROI/OutROI/ROI/FixROI 等 ROI 相关 Filter（`ValueType="rect"`）| **删除** —— ROI 是基类内置概念，**不是**用户自定义基本参数，Process 内用 `modu_input->vtFixRoiShapeObj` 访问，基类自动回显 |
| 在 `<模块名>.xml` Input/Output 加阈值/类型/使能等"算法旋钮" | 错位置 —— 运行参数走 `<模块名>AlgorithmTab.xml` + `<模块名>Algorithm.xml`，不进 `.xml` |
| ValueType 写为 `Image` / `Float32` / `Integer` | 全小写：`image` / `float` / `int` / `string` / `bool` / `point` / `line` / `rect` / `byte` |
| `AccessMode` 写 `Read` / `Write` / `ReadWrite` | `RO` / `RW`（仅两个值） |
| `<Bool Name="IsLoalModule">` 写为 `IsLocalModule`（修正拼写） | **原样保留** `IsLoalModule`（VM 内部就是这个拼写，自己改了会失效） |

**写端口前先 grep `templates/AlgTemplate/AlgTemplate/AlgTemplate.xml` 验证 Combination/Filter 结构**。

## 顶层结构（与模板一致，**根节点是 `<ParamRoot>`**）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ParamRoot>
    <Categorys>
        <Category Name="Base"> ... </Category>          <!-- 模块元信息：名称/显示名/帮助文本 -->
        <Category Name="Input"> ... </Category>         <!-- 基本输入：图像/ROI/点/线/矩形 -->
        <Category Name="Output"> ... </Category>        <!-- 基本输出：图像/标量/点集/矩形/状态 -->
        <Category Name="TransmitInfo"/>                  <!-- 透传信息，一般为空节点 -->
    </Categorys>
</ParamRoot>
```

四个 `Category Name="Base|Input|Output|TransmitInfo"` 都**必须**保留（含 `TransmitInfo` 空节点）。

## Category Name="Base"（模块元信息）

```xml
<Category Name="Base">
    <Items>
        <String  Name="ServerRepAddress">  <CurValue>tcp://127.0.0.1:5555</CurValue></String>
        <String  Name="ModuleName">         <CurValue><模块名></CurValue></String>
        <Bool    Name="IsLoalModule">       <CurValue>0</CurValue></Bool>
        <Integer Name="ModuleViewMode">     <CurValue>1</CurValue></Integer>
        <String  Name="ModuleDisplayName">  <CurValue><模块显示名></CurValue></String>
        <String  Name="ModuleHelp">         <CurValue><模块帮助文本></CurValue></String>
        <String  Name="IsSaveTabXml">       <CurValue>False</CurValue></String>
    </Items>
</Category>
```

`ModuleName` 必须与模块英文名严格一致（sed 改名后等于 `<模块名>`）；`ModuleDisplayName` 改名后也等于 `<模块名>`（模板默认值 `AlgTemplate` 已由 sed 替换），模块中文显示名由 VM 语言资源文件定义，**不需要**在此 XML 中额外配置。

## Category Name="Input"（基本输入）

只放**图像/ROI/点/直线/矩形/Fixture** 等"几何/数据型"输入。**所有阈值/类型/使能/路径等都不在这里**（它们是运行参数，去 [algorithm-tab.xml.md](algorithm-tab.xml.md)）。

### 输入图像（标准）

```xml
<Combination Name="InputImage" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageWidth"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageHeight"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImagePixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>
```

⚠️ **不要**写成 `<Image Name="InImage"/>` 单标签 —— VM 解析不了，模块端口图为空。**必须**用上面的 Combination + 4 个 Filter。

### 多张输入图像（参考 VM430 多图像源输入示例）

**示例来源**：VM430 多图像源输入官方示例（内部参考路径，外部不可访问）

每张额外图独立一个 `<Combination Style="IMAGE">`,Combination Name 与 Filter Name **都必须唯一**（不能重名,加序号后缀）：

```xml
<!-- 主图 -->
<Combination Name="InputImage" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageWidth"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageHeight"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImagePixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>

<!-- 第二张图 -->
<Combination Name="InputImage2" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage2"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2Width"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2Height"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2PixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>

<!-- 第三张图同上,Name="InputImage3" / Filter "InImage3*" -->
```

🚫 **反例**：
- ❌ 用 `IsArray="true"` 的单个 Combination 表示多图 —— VM 不支持
- ❌ 多张图共用 `InImage` Filter / `InputImage` Combination Name —— 重名 → VM 解析失败 / Process 拿不到第二张图
- ❌ Filter 名只加数字而 Combination 不加（如两个都叫 `InputImage`,Filter 区分） —— Combination 名同样必须唯一

C++ 端取第二张图用 `VmModule_GetInputImageByName(hInput, "InImage2", "InImage2Width", "InImage2Height", "InImage2PixelFormat", &stImage2, &nStatus2, szSharedName2)`,详见 [process-overload.md §规则 3](../process-overload.md)。

### 输入 POINT

```xml
<Combination Name="OriginPoint" Style="POINT" IsPrefer="true">
    <Filters>
        <Filter Name="OriginPointX" ValueType="float" IsForce="false"></Filter>
        <Filter Name="OriginPointY" ValueType="float" IsForce="false"></Filter>
    </Filters>
</Combination>
```

### 输入 LINE

```xml
<Combination Name="Input Line 1" Style="LINE">
    <Filters>
        <Combination Name="Line1StartPoint" Style="POINT">
            <Filters>
                <Filter Name="Line1PointStartX" ValueType="float" IsForce="false"></Filter>
                <Filter Name="Line1PointStartY" ValueType="float" IsForce="false"></Filter>
            </Filters>
        </Combination>
        <Combination Name="Line1EndPoint" Style="POINT">
            <Filters>
                <Filter Name="Line1PointEndX" ValueType="float" IsForce="false"></Filter>
                <Filter Name="Line1PointEndY" ValueType="float" IsForce="false"></Filter>
            </Filters>
        </Combination>
    </Filters>
</Combination>
```

### 输入 ROI Box(两种模式)

**模式 A:只读数组输入**(上游驱动,用户不可编辑):
```xml
<Combination Name="DetectRect" Style="ROIBOX">
    <Filters>
        <Combination Name="DetectRectCenterPoint" Style="POINT">
            <Filters>
                <Filter Name="DetectRectCenterX" ValueType="float" IsForce="true"></Filter>
                <Filter Name="DetectRectCenterY" ValueType="float" IsForce="true"></Filter>
            </Filters>
        </Combination>
        <Filter Name="DetectRectWidth" ValueType="float" IsForce="true"></Filter>
        <Filter Name="DetectRectHeight" ValueType="float" IsForce="true"></Filter>
        <Filter Name="DetectRectAngle" ValueType="float" IsForce="true"></Filter>
    </Filters>
</Combination>
```
- `IsForce="true"`:上游必须连接
- 无 `AccessMode` / `isShow`:不可交互编辑

**模式 B:可编辑单输入**(用户可在图像上拖动调整):
```xml
<Combination Name="BlockRect" Style="ROIBOX" AccessMode="RW">
    <Filters>
        <Combination Name="BlockRectCenterPoint" Style="POINT" AccessMode="RW">
            <Filters>
                <Filter Name="BlockRectCenterX" ValueType="float" IsForce="false" isShow="true" AccessMode="RW"/>
                <Filter Name="BlockRectCenterY" ValueType="float" IsForce="false" isShow="true" AccessMode="RW"/>
            </Filters>
        </Combination>
        <Filter Name="BlockRectWidth" ValueType="float" IsForce="false" isShow="true" AccessMode="RW"/>
        <Filter Name="BlockRectHeight" ValueType="float" IsForce="false" isShow="true" AccessMode="RW"/>
        <Filter Name="BlockRectAngle" ValueType="float" IsForce="false" isShow="true" AccessMode="RW"/>
    </Filters>
</Combination>
```
- `AccessMode="RW"` + `IsForce="false"`:可交互编辑
- `isShow="true"`:端口图可见

> 几何输入参数在 AlgorithmTab.xml 中需配 ButtonSelecter 控件,详见 [../xml-schemas/algorithm-tab.xml.md](../xml-schemas/algorithm-tab.xml.md)；C++ 读写模式详见 [../io-params/geometric-params.txt](../io-params/geometric-params.txt) 和 [../io-params/rect-params.md](../io-params/rect-params.md)。

### 输入位置校正（Fixture）

```xml
<Combination Name="Position Correction Info" Style="FIXTURE" AccessMode="RW">
    <Filters>
        <Filter Name="InFixtureBaseCol"   ValueType="float" IsForce="false" isShow="true" AccessMode="RO"/>
        <Filter Name="InFixtureBaseRow"   ValueType="float" IsForce="false" isShow="true" AccessMode="RO"/>
        <Filter Name="InFixtureBaseAngle" ValueType="float" IsForce="false" isShow="true" AccessMode="RO"/>
        <Filter Name="InFixtureCurCol"    ValueType="float" IsForce="false" isShow="true" AccessMode="RO"/>
        <Filter Name="InFixtureCurRow"    ValueType="float" IsForce="false" isShow="true" AccessMode="RO"/>
        <Filter Name="InFixtureCurAngle"  ValueType="float" IsForce="false" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>
```

## Category Name="Output"（基本输出）

> ⚠️ **输出参数中文名策略**：Output Category 的各 Filter 无 DisplayName/Description 字段——其中文名由 VM 语言资源文件管理。XML 中只配置 Name/ValueType/IsForce/isShow/AccessMode，不需要处理 DisplayName/Description。

```xml
<Category Name="Output">
    <Items>
        <!-- ModuStatus 是所有模块强制输出: 0=NG, 1=OK -->
        <Filter Name="ModuStatus" StructName="ModuStatus" ValueType="int"
                IsForce="true" isShow="true" AccessMode="RW"/>

        <!-- 输出图像 -->
        <Combination Name="OutputImage" Style="IMAGE" AccessMode="RW">
            <Filters>
                <Filter Name="OutImage"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
                <Filter Name="OutImageWidth"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
                <Filter Name="OutImageHeight"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
                <Filter Name="OutImagePixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
            </Filters>
        </Combination>

        <!-- 输出标量 -->
        <Filter Name="thresholdOut" ValueType="int"    IsForce="true" isShow="true" AccessMode="RW"/>
        <Filter Name="OutRatio"     ValueType="float"  IsForce="true" isShow="true" AccessMode="RW"/>
        <Filter Name="OutString"    ValueType="string" IsForce="true" isShow="true" AccessMode="RW"/>

        <!-- 输出点集 / 矩形（数组） -->
        <Filter Name="OutPoints" ValueType="point" IsForce="true" isShow="true" AccessMode="RW" IsArray="true"/>
        <Filter Name="OutRect"   ValueType="rect"  IsForce="true" isShow="true" AccessMode="RW" IsArray="true"/>

        <!-- 输出几何 Combination（含嵌套结构,用于 Display.xml 渲染） -->
        <!-- 输出矩形(ROIBOX) -->
        <Combination Name="PatMatchRect" Style="ROIBOX">
            <Filters>
                <Combination Name="PatMatchRectCenterPoint" Style="POINT">
                    <Filters>
                        <Filter Name="PatMatchRectCenterX" ValueType="float" IsForce="true"></Filter>
                        <Filter Name="PatMatchRectCenterY" ValueType="float" IsForce="true"></Filter>
                    </Filters>
                </Combination>
                <Filter Name="PatMatchRectWidth" ValueType="float" IsForce="true"></Filter>
                <Filter Name="PatMatchRectHeight" ValueType="float" IsForce="true"></Filter>
                <Filter Name="PatMatchRectAngle" ValueType="float" IsForce="true"></Filter>
            </Filters>
        </Combination>
        <!-- 输出点(POINT) -->
        <Combination Name="OutputPoint" Style="POINT" AccessMode="RW">
            <Filters>
                <Filter Name="OutputPointX" ValueType="float" IsForce="true" isShow="true" AccessMode="RW"/>
                <Filter Name="OutputPointY" ValueType="float" IsForce="true" isShow="true" AccessMode="RW"/>
            </Filters>
        </Combination>
        <!-- 输出直线(LINE) -->
        <Combination Name="OutputLine" Style="LINE" AccessMode="RW">
            <Filters>
                <Combination Name="OutputLineStartPoint" Style="POINT" AccessMode="RW">
                    <Filters>
                        <Filter Name="OutputLineStartX" ValueType="float" IsForce="true" isShow="true" AccessMode="RW"/>
                        <Filter Name="OutputLineStartY" ValueType="float" IsForce="true" isShow="true" AccessMode="RW"/>
                    </Filters>
                </Combination>
                <Combination Name="OutputLineEndPoint" Style="POINT" AccessMode="RW">
                    <Filters>
                        <Filter Name="OutputLineEndX" ValueType="float" IsForce="true" isShow="true" AccessMode="RW"/>
                        <Filter Name="OutputLineEndY" ValueType="float" IsForce="true" isShow="true" AccessMode="RW"/>
                    </Filters>
                </Combination>
            </Filters>
        </Combination>
    </Items>
</Category>
```

## Category Name="TransmitInfo"

```xml
<Category Name="TransmitInfo"/>
```

**必须**保留（哪怕空），否则部分版本 VM 解析报错。

## 与运行参数的边界（**最常踩坑**）

| 应当放入 `<模块名>.xml` Input/Output | 应当放入 `<模块名>AlgorithmTab.xml` Tab_Run Params |
|---|---|
| 输入图像、ROI Box、Fixture、点、直线、矩形 | **阈值化类型**（thresholdType） |
| 输出图像、模块状态（ModuStatus） | **阈值**（thresholdValue） |
| 输出标量（计算结果） | **使能开关**（如 PyramidModeEnable） |
| 输出点集、矩形数组、字符串 | **模型路径** / OpenFile |
| C# 脚本输入参数（image/ROI/point/line/rect 类型） | **检测模式枚举** / 显示开关 / 算子级别参数 |

**铁律**：阈值/类型/使能/路径/数值范围/模式选择 → 一律**运行参数**，**不**进 `<模块名>.xml`。

## 属性含义

| 属性 | 说明 |
|---|---|
| `Name` | 端口名（C++ 端 `VM_M_Get*`/`VM_M_Set*` 的 szName） |
| `ValueType` | image / int / float / string / bool / point / line / rect / byte |
| `IsForce` | true=强制连接 / false=可选 |
| `isShow` | UI 端口图是否显示（false 时仍可程序读写） |
| `AccessMode` | RW=读写 / RO=只读 |
| `IsArray` | true 时支持多个值（多 ROI / 多点等） |
| `Style`（Combination） | IMAGE / ROIBOX / FIXTURE / POINT / LINE / ROIANNULUS |

## 落盘自检

```bash
# 1. 根节点必须是 ParamRoot/Categorys/Category
grep -n "<ParamRoot>"   <模块名>.xml || echo "❌ 根节点错"
grep -n 'Category Name="Base"'         <模块名>.xml || echo "❌ 缺 Base"
grep -n 'Category Name="Input"'        <模块名>.xml || echo "❌ 缺 Input"
grep -n 'Category Name="Output"'       <模块名>.xml || echo "❌ 缺 Output"
grep -n 'Category Name="TransmitInfo"' <模块名>.xml || echo "❌ 缺 TransmitInfo"

# 2. 有图像输入时,必须用 Combination Style="IMAGE",不能用裸 <Image>
grep -n '<Image Name=' <模块名>.xml && echo "❌ 用了裸 <Image>,应改 Combination Style=IMAGE"

# 3. 阈值/使能等运行参数不应出现在 .xml 里
grep -nE '(threshold|enable|model|mode|pyramid)' <模块名>.xml && echo "⚠️ 疑似运行参数误放入 .xml,核对应否在 AlgorithmTab.xml"
```
