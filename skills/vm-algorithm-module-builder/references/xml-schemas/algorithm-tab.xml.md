# `<模块名>AlgorithmTab.xml` —— 界面控件配置

定义模块属性页（VM 工具 UI 双击模块弹出的对话框）中**所有控件**：图像源 + ROI + 运行参数 + 结果展示。

> **来源**：本文档结构直接抄自 `templates/AlgTemplate/AlgTemplate/AlgTemplateAlgorithmTab.xml`。**不要**自己编造 `<AlgorithmTab Name="..." Version="...">` 之类的根节点 —— 真实根节点是 `<AlgorithmTabRoot>`。

## 🚫 反编造对照表（写控件前先核对，命中编造写法立刻改正）

| 编造写法（**禁用**） | 真实写法 |
|---|---|
| `<AlgorithmTab Name="..." Version="...">` 作根节点 | `<AlgorithmTabRoot>` |
| `<EnumEntryList>` / `<EnumEntries>` | `<EnumEntrys>` （HIK 命名约定：plural+s） |
| `<EnumEntry Value="X" Name="Y"/>` （Value 作属性） | `<EnumEntry Name="Y"><Value>X</Value></EnumEntry>` （Name 作属性合法，Value 必须子节点） |
| `<Symbolic>X</Symbolic>` | `<Description>X</Description>` （枚举项的内部名/描述用 Description） |
| `<Step>X</Step>` | `<IncValue>X</IncValue>` （Integer/Float 步长） |
| Integer/Float/Enumeration/Boolean 仅写 `<DefaultValue>` 缺 `<CurValue>` | **必须同时写**两者（仅 `IntegerBettween` 父节点例外） |
| `<Bool Name="...">` 作运行参数 | `<Boolean Name="...">` （`<Bool>` 只用于 `<模块名>.xml` Base 段系统位） |
| `<Visibility>Beginner</Visibility>` 加在所有控件上 | 模板控件**不带** Visibility 节点；自己加会被 VM 忽略或解析失败 |
| `<Tab Name="Tab_Run_Params">` / `Tab_Basic_Params`（下划线） | `<Tab Name="Tab_Run Params">` / `Tab_Basic Params`（**空格**） |
| 运行参数控件放在 `Tab_Basic Params` | 必须放 `Tab_Run Params`；`Tab_Basic Params` 仅放 `ImageSourceGroup`/`RoiSelectGroup`/`Tab_ROI Area` + **输入基本参数的 ButtonSelecter** |
| `<Trigger Value="False"><Action Type="Hide">target</Action></Trigger>` | `<Trigger><Value>False</Value><Setters><Setter><TargetName>X</TargetName><OperationName>HiddenOperation</OperationName></Setter></Setters></Trigger>` |
| `<Range_Int>` / `<Range_Float>` / `<IntegerBetween>` / `<FloatBetween>`（单 t） | `<IntegerBettween>` / `<FloatBettween>`（**双 t**，VM 内部拼写） |
| 控件缺 `<Description>` 或 `<DisplayName>` 子节点 | **必填**；用户提供了中文名/描述则必须写入（中文名列→DisplayName，描述列→Description），仅用户未提供时**默认填英文名** Name 属性值,**不允许**省略整个节点 |
| 用户列了 N 个运行参数,产物多出第 N+1 个（如多出 `enableThreshold` Boolean） | **删掉多余的**；只生成用户清单内的参数,**不自作主张**加使能开关 |

**写控件前若不确定标签合法性 → 立即 grep `templates/AlgTemplate/AlgTemplate/AlgTemplateAlgorithmTab.xml` 验证；grep 不到的标签 = 编造**。完整黑名单见 [../forbidden-xml-tags.md](../forbidden-xml-tags.md)。

## 顶层结构（**根节点是 `<AlgorithmTabRoot>`**）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<AlgorithmTabRoot>
    <Tabs>
        <Tab Name="Tab_Basic Params"> ... </Tab>   <!-- 图像源 + ROI 区域，不放算法参数 -->
        <Tab Name="Tab_Run Params">   ... </Tab>   <!-- 算法运行参数（阈值/类型/使能/模型路径...） -->
        <Tab Name="ResultShow">       ... </Tab>   <!-- 结果展示（一般空，由 Display.xml 驱动） -->
    </Tabs>
    <BottomExcuteButtonsLeft> ... </BottomExcuteButtonsLeft>
    <BottomExcuteButtons>     ... </BottomExcuteButtons>
</AlgorithmTabRoot>
```

**层次必须是**：`AlgorithmTabRoot > Tabs > Tab > Categorys > Category > Items > <控件>`。Tab 名以 `Tab_` 开头（`ResultShow` 是历史保留名，不加前缀）。

## Tab Name="Tab_Basic Params"（有图像输入时的标准骨架）

**放**图像源组 + ROI 区域 + **用户输入基本参数(ButtonSelecter)**。**不放**任何阈值/使能/模型/类型选择 —— 那些是运行参数。

```xml
<Tab Name="Tab_Basic Params">
    <Categorys>
        <!-- 图像源（自动绑定到 <模块名>.xml 的 InputImage Combination） -->
        <GroupLinkItem Name="ImageSourceGroup">
            <LinkName>ImageSourceGroup</LinkName>
        </GroupLinkItem>

        <!-- ROI 区域 -->
        <Category Name="Tab_ROI Area">
            <Items>
                <GroupLinkItem Name="RoiSelectGroup">
                    <LinkName>RoiSelectGroup</LinkName>
                </GroupLinkItem>

                <ROISelecter Name="RoiType">
                    <Description>Shape</Description>
                    <DisplayName>Shape</DisplayName>
                    <Visibility>Beginner</Visibility>
                    <AccessMode>RW</AccessMode>
                    <FullScreenEnable>True</FullScreenEnable>
                    <SelectType>Single</SelectType>
                    <CustomVisible>False</CustomVisible>
                    <ROISelection>Box</ROISelection>
                </ROISelecter>

                <GroupLinkItem Name="InheritWayGroup">
                    <LinkName>InheritWayGroup</LinkName>
                </GroupLinkItem>
                <GroupLinkItem Name="ExternROITypeGroup">
                    <LinkName>ExternROITypeGroup</LinkName>
                </GroupLinkItem>
                <GroupLinkItem Name="AssistGroup">
                    <LinkName>AssistGroup</LinkName>
                </GroupLinkItem>
            </Items>
        </Category>
    </Categorys>
</Tab>
```

`ImageSourceGroup` / `RoiSelectGroup` / `InheritWayGroup` / `ExternROITypeGroup` / `AssistGroup` 都是 VM 内置组件，**直接 LinkName 引用**即可，**不要**自己改写。

### Tab_Basic Params 中的用户输入基本参数(ButtonSelecter)

`<模块名>.xml` Input Category 中定义的每一个用户可配置的输入基本参数(图形像外的 Point / Line / Rect / 标量 Filter),需要在 Tab_Basic Params 中配一个 `ButtonSelecter` 控件,将 UI 交互与数据源绑定。

**公式**:每个 XML Combination + 叶子 Filter 各一个 `ButtonSelecter`,层级完全镜像 XML 树。

**两类 Operation**:

| XML 元素类型 | DropOpenSetter OperationName | Trigger Setter OperationName | OperationParams |
|---|---|---|---|
| `<Combination Style="ROIBOX/POINT/LINE/ROIANNULUS">` | `GetFrontCombinationTreeOperation` | `SetCombinationSourceOperation` | XML Combination Name |
| `<Filter ValueType="int/float/string">` | `GetFrontFilterTreeOperation` | `SetFilterSourceOperation` | XML Filter Name |

#### 标量 Filter(int / float / string)

```xml
<ButtonSelecter Name="RefreshSignal">
    <Description>Refresh Signal</Description>
    <DisplayName>Refresh Signal</DisplayName>
    <AccessMode>O</AccessMode>
    <DropOpenSetter>
        <TargetName>EnumEntrys</TargetName>
        <OperationName>GetFrontFilterTreeOperation</OperationName>
        <OperationParams>int</OperationParams>
    </DropOpenSetter>
    <Triggers>
        <Trigger>
            <Property>CurValue</Property>
            <Setters>
                <Setter>
                    <OperationName>SetFilterSourceOperation</OperationName>
                    <OperationParams>RefreshSignal</OperationParams>
                </Setter>
            </Setters>
        </Trigger>
    </Triggers>
    <Initers>
        <Setter>
            <TargetName>CurValue</TargetName>
            <OperationName>GetSelectedFilterOperation</OperationName>
            <OperationParams>RefreshSignal</OperationParams>
        </Setter>
    </Initers>
</ButtonSelecter>
```

**标量 ButtonSelecter 必含子节点**:`Description` + `DisplayName` + `AccessMode` + `DropOpenSetter` + `Triggers`(含 1 个 Trigger/Property=CurValue/Setter) + `Initers`(含 1 个 Setter)。可选:`Visibility` / `CustomVisible` / `CustomizedParamType`。

#### Combination(ROIBOX / POINT / LINE / ROIANNULUS)

与标量的唯一区别是 DropOpenSetter 和 Trigger Setter 用了 **Combination** 而非 Filter:

```xml
<ButtonSelecter Name="DetectRect">
    <Description>建模区域</Description>
    <DisplayName>建模区域</DisplayName>
    <Visibility>Beginner</Visibility>
    <AccessMode>O</AccessMode>
    <CustomVisible>True</CustomVisible>
    <DropOpenSetter>
        <TargetName>EnumEntrys</TargetName>
        <OperationName>GetFrontCombinationTreeOperation</OperationName>
        <OperationParams>ROIBOX</OperationParams>
    </DropOpenSetter>
    <Triggers>
        <Trigger>
            <Property>CurValue</Property>
            <Setters>
                <Setter>
                    <OperationName>SetCombinationSourceOperation</OperationName>
                    <OperationParams>DetectRect</OperationParams>
                </Setter>
            </Setters>
        </Trigger>
    </Triggers>
    <Initers>
        <Setter>
            <TargetName>CurValue</TargetName>
            <OperationName>GetSelectedCombinationOperation</OperationName>
            <OperationParams>DetectRect</OperationParams>
        </Setter>
    </Initers>
</ButtonSelecter>
```

**Combination ButtonSelecter 递归展开规则**:

| XML 层级 | ButtonSelecter 数量 | 示例(ROIBOX) |
|---|---|---|
| 根 Combination | 1 | `DetectRect` (GetFrontCombinationTreeOperation + ROIBOX) |
| 子 Combination(如 CenterPoint POINT) | 1 | `DetectRectCenterPoint` (GetFrontCombinationTreeOperation + POINT) |
| 叶子 Filter(如 CenterX/CenterY/Width/Height/Angle) | 每个 1 | `DetectRectCenterX` 等 (GetFrontFilterTreeOperation + float) |

**ROIBOX 完整展开 = 1 + 1 + 5 = 7 个 ButtonSelecter**。LINE 完整展开 = 1 + 2 + 4 = 7 个。POINT 完整展开 = 1 + 2 = 3 个。**ROIANNULUS 完整展开 = 1 + 1 + 6 = 8 个**。

**关键规则**:
- **输出参数不出现在 AlgorithmTab.xml** —— ButtonSelecter 仅用于 Input Category
- Image 类型输入不需要 ButtonSelecter(由 ImageSourceGroup LinkName 处理)
- 所有 ButtonSelecter 放在 `Tab_Basic Params` 内,**不放** Tab_Run Params
- **CustomVisible 规则**：根 Combination 的 ButtonSelecter 必须设 `<CustomVisible>True</CustomVisible>`（否则基本参数界面不显示该参数入口）；子 Combination 和叶子 Filter 的 ButtonSelecter 设 `<CustomVisible>False</CustomVisible>`（子属性不需要顶层显示）
- **所有 ButtonSelecter 必须包裹在 `<Category Name="Class Inputs"><Items>...</Items></Category>` 内**，不可直接作为 `<Categorys>` 的直接子节点。**多个几何输入参数（如多个 ROIBOX/POINT）的所有 ButtonSelecter 合并到一个 Class Inputs Category 中**，不需要为每个几何类型创建独立的 Category
- 更多示例(POINT/LINE/ROIANNULUS)见 [../io-params/geometric-params.txt](../io-params/geometric-params.txt)

### ButtonSelecter 必须在 Category 内（结构约束）

🚫 **错误示例**（ButtonSelecter 直接放在 `<Categorys>` 下，缺少 Category/Items 包裹）：
```xml
<Categorys>
    <GroupLinkItem Name="ImageSourceGroup">...</GroupLinkItem>
    <Category Name="Tab_ROI Area">...</Category>
    <ButtonSelecter Name="DetectRect">...</ButtonSelecter>   <!-- ❌ 缺少 Category 包裹 -->
    <ButtonSelecter Name="DetectRectCenterX">...</ButtonSelecter>
</Categorys>
```

✅ **正确示例**（包裹在 `<Category Name="Class Inputs"><Items>` 内）：
```xml
<Categorys>
    <GroupLinkItem Name="ImageSourceGroup">...</GroupLinkItem>
    <Category Name="Tab_ROI Area">...</Category>
    <Category Name="Class Inputs">
        <Items>
            <ButtonSelecter Name="DetectRect">
                ... GetFrontCombinationTreeOperation + ROIBOX ...
            </ButtonSelecter>
            <ButtonSelecter Name="DetectRectCenterPoint">
                ... GetFrontCombinationTreeOperation + POINT ...
            </ButtonSelecter>
            <ButtonSelecter Name="DetectRectCenterX">
                ... GetFrontFilterTreeOperation + float ...
            </ButtonSelecter>
            <!-- 其余子 Filter 同理 -->
        </Items>
    </Category>
</Categorys>
```

## Tab Name="Tab_Run Params"（运行参数）

所有阈值/类型/使能/模型路径/枚举选择 **都放这里**，包在 `<Categorys><Category Name="Tab_Run Params"><Items>` 三层结构内。

⚠️ **铁律**：只生成用户在步骤 4 列出的参数,**不要**自作主张添加使能开关或其他"完善性"参数。已知反例:用户描述二值化模块"运行参数有阈值和阈值化类型",最终生成的 AlgorithmTab.xml 多出 `enableThreshold` —— 必须严格按用户清单生成。

⚠️ **每个控件的子节点完整性铁律**：所有 `<Integer>` / `<Float>` / `<Boolean>` / `<Enumeration>` / `<IntegerBettween>` / `<FloatBettween>` 必须含 `<Description>` + `<DisplayName>` + `<AccessMode>` + `<CurValue>` + `<DefaultValue>`（数值类追加 `<MinValue>` + `<MaxValue>` + `<IncValue>`）。用户提供了中文名/描述就必须写入（中文名列→DisplayName，描述列→Description，英文名列→Name），仅用户未提供时**默认 = 英文名**（即 Name 属性值）,**不允许**省略整个子节点。

### 控件标准模板（按用户提供的"英文名/中文名/描述"三元组生成）

```xml
<Tab Name="Tab_Run Params">
    <Categorys>
        <Category Name="Tab_Run Params">
            <Items>

                <!-- 整型（用户回复:英文名 thresholdValue,中文名 阈值,描述 阈值(一般范围是0~255) ）-->
                <Integer Name="thresholdValue" NameSpace="Standard">
                    <Description>阈值(一般范围是0~255)</Description>
                    <DisplayName>阈值</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <MinValue>0</MinValue>
                    <MaxValue>255</MaxValue>
                    <CurValue>128</CurValue>
                    <DefaultValue>128</DefaultValue>
                    <IncValue>1</IncValue>
                </Integer>

                <!-- 浮点 -->
                <Float Name="ratioValue" NameSpace="Standard">
                    <Description>比率</Description>
                    <DisplayName>比率</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <MinValue>0.0</MinValue>
                    <MaxValue>1.0</MaxValue>
                    <CurValue>0.5</CurValue>
                    <DefaultValue>0.5</DefaultValue>
                    <IncValue>0.01</IncValue>
                    <DecimalDigits>2</DecimalDigits>
                </Float>

                <!-- 枚举（EnumEntry 子节点必须每个独占一行，便于阅读） -->
                <Enumeration Name="thresholdType" NameSpace="Standard">
                    <Description>阈值化类型</Description>
                    <DisplayName>阈值化类型</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <CurValue>1</CurValue>
                    <DefaultValue>1</DefaultValue>
                    <EnumEntrys>
                        <EnumEntry>
                            <Description>BINARY</Description>
                            <DisplayName>BINARY</DisplayName>
                            <Value>1</Value>
                        </EnumEntry>
                        <EnumEntry>
                            <Description>BINARY_INV</Description>
                            <DisplayName>BINARY_INV</DisplayName>
                            <Value>2</Value>
                        </EnumEntry>
                    </EnumEntrys>
                </Enumeration>

                <!-- 布尔（使能开关,仅当用户主动要求时才生成） -->
                <Boolean Name="PyramidModeEnable" NameSpace="Standard">
                    <Description>手动尺度使能</Description>
                    <DisplayName>手动尺度使能</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <CurValue>False</CurValue>
                    <DefaultValue>False</DefaultValue>
                </Boolean>

                <!-- 字符串 -->
                <String Name="modelName" NameSpace="Standard">
                    <Description>模型名称</Description>
                    <DisplayName>模型名称</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <CurValue></CurValue>
                    <DefaultValue></DefaultValue>
                </String>

                <!-- 文件选择 -->
                <OpenFile Name="modelPath" NameSpace="Standard">
                    <Description>模型路径</Description>
                    <DisplayName>模型路径</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <CurValue></CurValue>
                    <DefaultValue></DefaultValue>
                    <Filter>Model files (*.dat)|*.dat</Filter>
                </OpenFile>

                <!-- 文件夹选择（加载/导出文件夹,语义由 Name/Description 区分） -->
                <OpenFolderDialogEx Name="LoadModelPath">
                    <Description>加载模型</Description>
                    <DisplayName>加载模型</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <MaxFileDirLength>200</MaxFileDirLength>
                    <CustomVisible>True</CustomVisible>
                </OpenFolderDialogEx>

                <!-- 深度学习模型文件选择 -->
                <OpenFileForCNNDialog Name="LoadCNNModelPath">
                    <Description>Model File Path</Description>
                    <DisplayName>Model File Path</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <CurValue>cmd</CurValue>
                    <DefaultValue>cmd</DefaultValue>
                    <FileOption>
                        <IsMultiselect>true</IsMultiselect>
                        <FilterName>模型文件|*.bin</FilterName>
                    </FileOption>
                </OpenFileForCNNDialog>

                <!-- 标定文件选择 -->
                <OpenFileForCalibDialog Name="LoadCalibPath">
                    <Description>Load Calib File Path</Description>
                    <DisplayName>Load Calibration File</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <CurValue></CurValue>
                    <DefaultValue></DefaultValue>
                    <FileOption>
                        <IsMultiselect>false</IsMultiselect>
                        <FilterName>.iwcal;.txt;.xml|*.iwcal;*.txt;*.xml</FilterName>
                    </FileOption>
                </OpenFileForCalibDialog>

                <!-- 保存文件（标定文件/配置文件） -->
                <SaveFileDialog Name="SaveCalibPath">
                    <Description>Create Calibration File Path</Description>
                    <DisplayName>Create Calibration File</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <CustomVisible>False</CustomVisible>
                    <CurValue>cmd</CurValue>
                    <DefaultValue>cmd</DefaultValue>
                    <SaveType>CalibPath</SaveType>
                    <FileOption>
                        <IsMultiselect>false</IsMultiselect>
                        <FilterName>.txt|*.txt</FilterName>
                    </FileOption>
                </SaveFileDialog>

                <!-- 整数范围型（IntegerBettween，注意 VM 内部就是这个拼写） -->
                <IntegerBettween Name="GrayRange" NameSpace="Standard">
                    <Description>灰度范围</Description>
                    <DisplayName>灰度范围</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <DefaultValue>0</DefaultValue>
                    <MinValue>0</MinValue>
                    <MaxValue>255</MaxValue>
                    <IncValue>1</IncValue>
                    <CustomVisible>False</CustomVisible>
                    <Integers>
                        <Integer Name="MinGray">
                            <Description>Min Gray</Description>
                            <DisplayName>Min Gray</DisplayName>
                            <AccessMode>RW</AccessMode>
                            <CurValue>50</CurValue>
                            <DefaultValue>50</DefaultValue>
                            <MinValue>0</MinValue>
                            <MaxValue>255</MaxValue>
                            <IncValue>1</IncValue>
                        </Integer>
                        <Integer Name="MaxGray">
                            <Description>Max Gray</Description>
                            <DisplayName>Max Gray</DisplayName>
                            <AccessMode>RW</AccessMode>
                            <CurValue>200</CurValue>
                            <DefaultValue>200</DefaultValue>
                            <MinValue>0</MinValue>
                            <MaxValue>255</MaxValue>
                            <IncValue>1</IncValue>
                        </Integer>
                    </Integers>
                </IntegerBettween>

                <!-- 浮点数范围型（FloatBettween） -->
                <FloatBettween Name="RangCircularity">
                    <Description>This Value is the range of Blob Roundness</Description>
                    <DisplayName>Circularity Range</DisplayName>
                    <AccessMode>RW</AccessMode>
                    <AlgorithmIndex>0x0001</AlgorithmIndex>
                    <DefaultValue>1</DefaultValue>
                    <MinValue>0</MinValue>
                    <MaxValue>1</MaxValue>
                    <IncValue>0.01</IncValue>
                    <CustomVisible>False</CustomVisible>
                    <Floats>
                        <Float Name="MinCircularity">
                            <Description>Min Circularity</Description>
                            <DisplayName>Min Circularity</DisplayName>
                            <AccessMode>RW</AccessMode>
                            <AlgorithmIndex>0x0618</AlgorithmIndex>
                            <CurValue>0.1</CurValue>
                            <DefaultValue>0.1</DefaultValue>
                            <MinValue>0</MinValue>
                            <MaxValue>1</MaxValue>
                            <IncValue>0.01</IncValue>
                        </Float>
                        <Float Name="MaxCircularity">
                            <Description>Max Circularity</Description>
                            <DisplayName>Max Circularity</DisplayName>
                            <AccessMode>RW</AccessMode>
                            <AlgorithmIndex>0x0619</AlgorithmIndex>
                            <CurValue>1</CurValue>
                            <DefaultValue>1</DefaultValue>
                            <MinValue>0</MinValue>
                            <MaxValue>1</MaxValue>
                            <IncValue>0.01</IncValue>
                        </Float>
                    </Floats>
                </FloatBettween>

            </Items>
        </Category>
    </Categorys>
</Tab>
```

控件 `Name` 必须与 `<模块名>Algorithm.xml` 中的 `<ParamItem><Name>` 以及 C++ `GetParam`/`SetParam` 内的 `szParamName` 完全一致。

### 用户清单 → XML 的映射规则

| 用户提供 | XML 节点 |
|---|---|
| 英文名 `thresholdValue` | `<Integer Name="thresholdValue">` 的 `Name` 属性 |
| 中文名 `阈值` | `<DisplayName>阈值</DisplayName>` |
| 描述 `阈值(一般范围是0~255)` | `<Description>阈值(一般范围是0~255)</Description>` |
| 默认值 `128` | **同时**写 `<CurValue>128</CurValue>` + `<DefaultValue>128</DefaultValue>` |
| 最小/最大/步长 | `<MinValue>` / `<MaxValue>` / `<IncValue>` |

**未提供时默认值**：
- 中文名未提供 → `<DisplayName>` 填英文名（如 `<DisplayName>thresholdValue</DisplayName>`）
- 描述未提供 → `<Description>` 填英文名（如 `<Description>thresholdValue</Description>`）
- **绝不**省略整个 `<DisplayName>` 或 `<Description>` 节点

### IntegerBettween / FloatBettween 注意

- 这两个标签**就是 VM 内部使用的拼写**（"Bettween" 是 VM 团队的拼写习惯,与 `IsLoalModule` 同类）—— **不要**自作主张改成 `IntegerBetween` / `Range_Int` / `Range_Float`
- 父节点（`IntegerBettween`/`FloatBettween`）只有 `<DefaultValue>`,**没有** `<CurValue>`（CurValue 在子节点 `<Integers>` / `<Floats>` 内的具体 Integer/Float 里）
- 子节点 `<Integer Name="MinX">` / `<Integer Name="MaxX">`（或 Float 同理）必须**完整含** `<CurValue>` + `<DefaultValue>` 等所有子节点

## 使能开关（Boolean）+ Trigger 联动（隐藏/显示其他参数）

使能开关用 `<Boolean>`（**不**是 `<Bool>`），并通过 `<Triggers>` 控制其他控件的显隐。

```xml
<Boolean Name="PyramidModeEnable">
    <AlgorithmIndex>0</AlgorithmIndex>
    <CurValue>False</CurValue>
    <DefaultValue>False</DefaultValue>
    <Description>手动尺度使能</Description>
    <DisplayName>手动尺度使能</DisplayName>
    <AccessMode>RW</AccessMode>
    <Triggers>
        <Trigger>
            <Property>CurValue</Property>
            <Value>False</Value>           <!-- 关闭时:隐藏下面两个参数 -->
            <Setters>
                <Setter><TargetName>PyramidScaleLevel</TargetName>  <OperationName>HiddenOperation</OperationName></Setter>
                <Setter><TargetName>PyramidScaleRLevel</TargetName> <OperationName>HiddenOperation</OperationName></Setter>
            </Setters>
        </Trigger>
        <Trigger>
            <Property>CurValue</Property>
            <Value>True</Value>            <!-- 打开时:显示这两个参数 -->
            <Setters>
                <Setter><TargetName>PyramidScaleLevel</TargetName>  <OperationName>VisibleOperation</OperationName></Setter>
                <Setter><TargetName>PyramidScaleRLevel</TargetName> <OperationName>VisibleOperation</OperationName></Setter>
            </Setters>
        </Trigger>
    </Triggers>
</Boolean>
```

| 字段 | 取值/含义 |
|---|---|
| `Property` | 触发属性，一般固定 `CurValue` |
| `Value` | 当 Property 取该值时触发 Setters 里的操作 |
| `TargetName` | 被控制的另一个运行参数的 `Name` |
| `OperationName` | `VisibleOperation`（显示） / `HiddenOperation`（隐藏） / `EnableOperation` / `DisableOperation` |

**默认开/关**必须按客户描述确认；不明确则**主动问**，不要擅自定 True/False。

## ResultShow Tab（一般留空）

```xml
<Tab Name="ResultShow">
    <Categorys/>
</Tab>
```

结果展示由 `<模块名>Display.xml` 驱动，本 Tab 一般留空即可。

## 底部按钮（**必须保留**，照搬模板）

```xml
<BottomExcuteButtonsLeft>
    <Button_ResetAlgoParams Name="Button_ResetAlgoParams">
        <Visibility>Beginner</Visibility>
        <AccessMode>O</AccessMode>
    </Button_ResetAlgoParams>
</BottomExcuteButtonsLeft>
<BottomExcuteButtons>
    <GroupLinkItem Name="BottomCommandGroup">
        <LinkName>BottomCommandGroup</LinkName>
    </GroupLinkItem>
</BottomExcuteButtons>
```

## 无图像输入时的修改

- **Tab_Basic Params**：删除 `ImageSourceGroup` 与整个 `<Category Name="Tab_ROI Area">`，但**保留** `<Tab Name="Tab_Basic Params"><Categorys/></Tab>` 空壳
- **Tab_Run Params**：照常保留

## 控件元素属性

**通用必备子节点（所有类型都要）**：`<Description>` + `<DisplayName>` + `<AccessMode>` + `<CurValue>` + `<DefaultValue>`
**例外**：`IntegerBettween` / `FloatBettween` 父节点仅有 `<DefaultValue>` 无 `<CurValue>`（子 `Integer` / `Float` 控件各自含 `CurValue`）。
（中文名/描述用户未提供时默认 = 英文名,**不允许**省略整个节点）

| 元素 | 通用必备外的额外必需 | 备注 |
|---|---|---|
| `Integer` | MinValue/MaxValue/IncValue | 数值类 |
| `Float` | MinValue/MaxValue/IncValue/DecimalDigits | DecimalDigits 控制小数位 |
| `Boolean` | — | CurValue/DefaultValue 写 `True`/`False`（首字母大写） |
| `String` | — | CurValue 可空 |
| `Enumeration` | EnumEntrys | Value 必须为 int（写为子节点 `<Value>X</Value>`,**不**作属性） |
| `OpenFile` | Filter | Filter 格式 `"desc\|*.ext"` |
| `OpenFolderDialogEx` | MaxFileDirLength + CustomVisible | **无** CurValue/DefaultValue/MinValue/MaxValue;加载/导出文件夹同标签,语义由 Name/Description 区分 |
| `OpenFileForCNNDialog` | FileOption (IsMultiselect + FilterName) | 深度学习模型文件选择;FilterName 格式 `"desc\|*.ext"` |
| `OpenFileForCalibDialog` | FileOption (IsMultiselect + FilterName) | 标定文件选择;多扩展用 `;` 分隔 `".a;.b\|*.a;*.b"` |
| `SaveFileDialog` | SaveType + FileOption | SaveType 如 `CalibPath`;FilterName 同 OpenFileForCalibDialog |
| `ButtonSelecter` | `Description` + `DisplayName` + `AccessMode` + `DropOpenSetter` + `Triggers`(含 1 个 Trigger/Setter) + `Initers`(含 1 个 Setter) | **仅用于 Tab_Basic Params** 的输入基本参数; DropOpenSetter.OperationName = `GetFrontFilterTreeOperation`(标量 Filter) / `GetFrontCombinationTreeOperation`(Combination); OperationParams = XML Name 或类型名(int/float/string/ROIBOX/POINT/LINE/ROIANNULUS); 详见 [../io-params/geometric-params.txt](../io-params/geometric-params.txt) |

🚫 **禁用旧拼写**：`Range_Int` / `Range_Float` / `IntegerBetween`（单 t）/ `FloatBetween`（单 t） —— VM 内部就是 `IntegerBettween` / `FloatBettween` 双 t 拼写,改了会被 VM 解析器忽略。

## 落盘自检

```bash
# 1. 根节点结构必须正确
grep -n "<AlgorithmTabRoot>"          <模块名>AlgorithmTab.xml || echo "❌ 根节点错"
grep -n '<Tab Name="Tab_Basic Params"' <模块名>AlgorithmTab.xml || echo "❌ 缺 Tab_Basic Params"

# 2. 有运行参数时,必须有 Tab_Run Params
grep -n '<Tab Name="Tab_Run Params"'  <模块名>AlgorithmTab.xml || echo "❌ 缺 Tab_Run Params"

# 3. 阈值/使能等运行参数不应出现在 Tab_Basic Params 内
#    (用 awk 提取 Tab_Basic Params 段后再 grep)
awk '/<Tab Name="Tab_Basic Params">/,/<\/Tab>/' <模块名>AlgorithmTab.xml | \
    grep -nE '(threshold|enable|model|pyramid)' && echo "❌ 运行参数误放 Tab_Basic Params"

# 4. 三处 Name 一致性
grep -oE 'Name="[a-zA-Z][a-zA-Z0-9]*"' <模块名>AlgorithmTab.xml | sort -u
grep -oE '<Name>[^<]+</Name>'           <模块名>Algorithm.xml    | sort -u
grep -oE 'strcmp\("[^"]+"'              AlgorithmModule.cpp     | sort -u
# 三组运行参数集合应一致

# 5. ButtonSelecter 与 <模块名>.xml Input Category 一致性
#    SetFilterSourceOperation / SetCombinationSourceOperation 的 OperationParams
#    必须是 <模块名>.xml Input Category 中实际存在的 Filter / Combination Name
grep -oE 'SetFilterSourceOperation.*<OperationParams>[^<]+</OperationParams>' <模块名>AlgorithmTab.xml | grep -oP '(?<=OperationParams>)[^<]+' | sort -u
grep -oE 'SetCombinationSourceOperation.*<OperationParams>[^<]+</OperationParams>' <模块名>AlgorithmTab.xml | grep -oP '(?<=OperationParams>)[^<]+' | sort -u
grep -oE 'Name="[a-zA-Z][a-zA-Z0-9]*"' <模块名>.xml | sort -u
# ButtonSelecter 引用的数据源名称(Filter/Combination Name)必须出现在 <模块名>.xml 中
```
