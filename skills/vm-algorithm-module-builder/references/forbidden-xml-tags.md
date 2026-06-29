# 编造 XML 标签黑名单（落盘后必须 grep 自检）

以下 XML 标签/属性**在 VM 模块 schema 中不存在**，Claude 历史上反复编造。生成 5 个界面 XML 后**必须**对所有 `<模块>/*.xml` 跑 grep，任何命中立即回滚改写。

## 黑名单（一次出现即视为编造）

| 编造写法 | 真实写法 |
|---|---|
| `<EnumEntryList>` | `<EnumEntrys>`（plural+s） |
| `<EnumEntries>`（标准英文复数） | `<EnumEntrys>`（HIK 命名约定就是 plural+s，原样照搬） |
| `<EnumEntry Value="X">`（Value 作属性） | `<Value>X</Value>` 是**子节点**；`Name="X"` 作**属性**是合法的 |
| `<Symbolic>` | `<Description>`（枚举项的内部名用 Description） |
| `<Step>` | `<IncValue>`（Integer/Float 的步长） |
| Integer/Float **仅** `<DefaultValue>` 无 `<CurValue>` | Integer/Float/Enumeration/Boolean **必须同时**含 `<CurValue>` + `<DefaultValue>`（仅 `IntegerBettween` 父节点例外） |
| `<Bool Name="X">` 作运行参数 | `<Boolean Name="X">`（`<Bool>` 仅 `<模块名>.xml` Base 段 IsLoalModule 等系统位） |
| `<Visibility>Beginner</Visibility>` 出现在所有控件 | 模板控件**不带** Visibility 节点（仅 ROISelecter 等特殊节点带）；自己加会被 VM 忽略或解析失败 |
| `<IntegerBetween>` / `<FloatBetween>`（单 t） | `<IntegerBettween>` / `<FloatBettween>`（**双 t**，VM 内部拼写） |
| `<Range_Int>` / `<Range_Float>` | `<IntegerBettween>` / `<FloatBettween>`（旧版控件名，不存在） |
| `<ToolItemInfo>` 作 ToolItemInfo.xml 根节点 | `<ToolBoxItemData>`（含 `<name>`/`<priority>`/`<toolTip>` 子节点） |

## 真实 XML 节点对照（来自用户实际工程 + `references/xml-schemas/algorithm-tab.xml.md`）

数值可用十六进制（`0x8`/`0x1`）或十进制；`<AlgorithmIndex>` 与 `<CustomizedParamType>` 都是合法可选字段。

### Integer
```xml
<Integer Name="OffsetWidth">
  <Description>RunParam_OffsetWidth</Description>
  <DisplayName>RunParam_OffsetWidth</DisplayName>
  <AccessMode>RW</AccessMode>
  <AlgorithmIndex>0x00150002</AlgorithmIndex>
  <CurValue>0x8</CurValue>
  <DefaultValue>0x8</DefaultValue>
  <MinValue>0x3</MinValue>
  <MaxValue>0xBB8</MaxValue>
  <IncValue>0x1</IncValue>
</Integer>
```

### Float
```xml
<Float Name="MinScore">
  <Description>Min Matching Score of Feature Matching</Description>
  <DisplayName>Min Match Score</DisplayName>
  <AccessMode>RW</AccessMode>
  <AlgorithmIndex>0x0301</AlgorithmIndex>
  <CurValue>0.5</CurValue>
  <DefaultValue>0.5</DefaultValue>
  <MinValue>0</MinValue>
  <MaxValue>1.0</MaxValue>
  <IncValue>0.01</IncValue>
  <CustomizedParamType>1</CustomizedParamType>
</Float>
```

### IntegerBettween（范围对：父只 DefaultValue，子 Integers 提供 CurValue）
```xml
<IntegerBettween Name="RangAngle">
  <Description>AngleRange</Description>
  <DisplayName>AngleRange</DisplayName>
  <AccessMode>RW</AccessMode>
  <AlgorithmIndex>0x0000</AlgorithmIndex>
  <DefaultValue>0</DefaultValue>
  <MinValue>-180</MinValue>
  <MaxValue>180</MaxValue>
  <IncValue>0x1</IncValue>
  <CustomizedParamType>1</CustomizedParamType>
  <Integers>
    <Integer Name="AngleStart">
      <Description>Angle Start</Description>
      <DisplayName>Angle Start</DisplayName>
      <AccessMode>RW</AccessMode>
      <AlgorithmIndex>0x0304</AlgorithmIndex>
      <CurValue>-180</CurValue>
      <DefaultValue>-180</DefaultValue>
      <MinValue>-180</MinValue>
      <MaxValue>180</MaxValue>
      <IncValue>0x1</IncValue>
    </Integer>
    <Integer Name="AngleEnd">
      <Description>Angle End</Description>
      <DisplayName>Angle End</DisplayName>
      <AccessMode>RW</AccessMode>
      <AlgorithmIndex>0x0305</AlgorithmIndex>
      <CurValue>180</CurValue>
      <DefaultValue>180</DefaultValue>
      <MinValue>-180</MinValue>
      <MaxValue>180</MaxValue>
      <IncValue>0x1</IncValue>
    </Integer>
  </Integers>
</IntegerBettween>
```

### Enumeration（EnumEntry Name 作属性，Value 仍是子节点）
```xml
<Enumeration Name="RunType" NameSpace="Standard">
  <Description>运行模式</Description>
  <DisplayName>运行模式</DisplayName>
  <AccessMode>RW</AccessMode>
  <CurValue>0x1</CurValue>
  <DefaultValue>0x1</DefaultValue>
  <EnumEntrys>
    <EnumEntry Name="TrainingMode">
      <Description>建模模式</Description>
      <DisplayName>建模模式</DisplayName>
      <Value>0x0</Value>
    </EnumEntry>
    <EnumEntry Name="RunningMode">
      <Description>生产模式</Description>
      <DisplayName>生产模式</DisplayName>
      <Value>0x1</Value>
    </EnumEntry>
  </EnumEntrys>
</Enumeration>
```

### Boolean（CurValue + DefaultValue 同时存在）
```xml
<Boolean Name="OutLinePointEnable">
  <AlgorithmIndex>0</AlgorithmIndex>
  <CurValue>True</CurValue>
  <DefaultValue>True</DefaultValue>
  <Description>轮廓点使能(关闭可以提升速度)</Description>
  <DisplayName>轮廓点使能</DisplayName>
  <AccessMode>RW</AccessMode>
</Boolean>
```

### String / OpenFile / IntegerBettween / FloatBettween（双 t,VM 内部拼写）
详见 [xml-schemas/algorithm-tab.xml.md](xml-schemas/algorithm-tab.xml.md)。

## 关于 `NameSpace="Standard"`

**不是强制**。Enumeration 常带，Integer/Float/Boolean 可不带（见上方真实示例）。原模板带就保留，原模板不带就不要主动加。

## 落盘后强制 grep 自检命令

```bash
OUT=<outputDir>/<模块名>

# 1. 编造标签扫描（命中任何一条 → 必须回滚改写）
grep -nE "<EnumEntryList>|<Symbolic>|<Step>|<EnumEntries>" "$OUT"/*/[!_]*AlgorithmTab.xml \
    && echo "❌ 编造 XML 标签" || echo "✅ XML 标签合法"

# 2. EnumEntry Value 必须是子节点而非属性（Name 作属性合法，Value 不合法）
grep -nE '<EnumEntry\s+[^>]*Value\s*=\s*"' "$OUT"/*/[!_]*AlgorithmTab.xml \
    && echo "❌ EnumEntry Value 应为子节点 <Value>X</Value>" || echo "✅"

# 3. Integer/Float/Enumeration/Boolean 必须同时含 CurValue + DefaultValue
awk '/<Tab Name="Tab_Run Params">/,/<\/Tab>/' "$OUT"/*/[!_]*AlgorithmTab.xml | \
    awk '
        /<(Integer|Float|Enumeration|Boolean)\s+Name=/ { in_node=1; has_cur=0; has_def=0; name=$0 }
        in_node && /<CurValue>/ { has_cur=1 }
        in_node && /<DefaultValue>/ { has_def=1 }
        in_node && /<\/(Integer|Float|Enumeration|Boolean)>/ {
            if (!has_cur || !has_def) print "❌ 缺 CurValue 或 DefaultValue: " name
            in_node=0
        }'
```

## 头文件位置（grep 验证真实 schema 的去处）

- `references/xml-schemas/algorithm-tab.xml.md` — 所有运行参数控件（Integer/Float/IntegerBettween/FloatBettween/Enumeration/Boolean/String/OpenFile/OpenFolderDialogEx/OpenFileForCNNDialog/OpenFileForCalibDialog/SaveFileDialog）的标准 schema
- `references/xml-schemas/algorithm-default.xml.md` — `<模块名>Algorithm.xml` (`<AlgorithmParamList>` + `<ParamItem>`)
- `references/xml-schemas/module-io.xml.md` — `<模块名>.xml` (`<ParamRoot>` + Combination IMAGE/ROIBOX/FIXTURE)
- `references/xml-schemas/display.xml.md` — `<模块名>Display.xml`
- `references/xml-schemas/tool-item-info.xml.md` — `ToolItemInfo.xml`

**不确定某标签 / 属性是否合法 → 立即 grep 上述 schema 文件 → grep 不到就向用户报告"该字段 schema 中无对应定义"，绝不编造**。
