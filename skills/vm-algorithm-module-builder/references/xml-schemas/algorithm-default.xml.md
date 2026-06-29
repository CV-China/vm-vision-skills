# `<模块名>Algorithm.xml` —— 运行参数默认值

模块**首次创建**时，VM 从此文件读取每个运行参数的初始值，写入模块实例（再由 SDK 调用 `CAlgorithmModule::SetParam` 把字符串解析到成员变量）。后续用户修改后，由 VM 在工程文件中保存（不再读此文件）。

> **来源**：本文档结构直接抄自 `templates/AlgTemplate/AlgTemplate/AlgTemplateAlgorithm.xml` + VM431 ExampleModu。**不要**自己编造 `<Algorithm Name="..." Version="...">` 之类的根节点 —— 真实根节点是 `<AlgorithmParamList>`，**每个参数一个 `<ParamItem>`**。

## 🚫 反编造对照表（写默认值前先核对）

| 编造写法（**禁用**） | 真实写法 |
|---|---|
| `<Algorithm Name="..." Version="...">` 作根节点 | `<AlgorithmParamList>` |
| `<Params>` / `<Parameters>` 包一层 | `<AlgorithmParamList>` 直接挂 `<ParamItem>`，无中间层 |
| `<ParamItem Name="X" Value="Y"/>`（Name/Value 作属性） | `<ParamItem><Name>X</Name><DefaultValue>Y</DefaultValue></ParamItem>`（**都是子节点**） |
| `<DefaultValue>` 写为 `<Value>` 或 `<Default>` | 标签**必须**是 `<DefaultValue>` |
| 运行参数在 AlgorithmTab.xml 出现，但本文件留 `<AlgorithmParamList/>` 空壳 | 三方一致铁律：AlgorithmTab.xml 每个 `Name="X"` → 本文件**必须**有 `<ParamItem><Name>X</Name>...` → cpp 也要 `strcmp("X",...)` |
| Boolean 默认值写 `0` / `1` / `true` / `false` | 写 `True` / `False`（首字母大写，与 cpp 端 `strcmp("True",pData)` 对齐） |
| Enumeration 默认值写枚举项的 Name（如 `BINARY`） | 写**整数 Value**（如 `1`），与 AlgorithmTab.xml `<EnumEntry Name="BINARY"><Value>1</Value>` 的 Value 对齐 |

**写默认值前先 grep `templates/AlgTemplate/AlgTemplate/AlgTemplateAlgorithm.xml` 验证结构**。

## 顶层结构（**根节点是 `<AlgorithmParamList>`**，每个参数用 `<ParamItem>`）

模板里是空壳：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<AlgorithmParamList/>
```

有运行参数时填入 `<ParamItem>`：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<AlgorithmParamList>
    <ParamItem>
        <Name>thresholdType</Name>
        <DefaultValue>1</DefaultValue>
    </ParamItem>
    <ParamItem>
        <Name>thresholdValue</Name>
        <DefaultValue>128</DefaultValue>
    </ParamItem>
    <ParamItem>
        <Name>PyramidModeEnable</Name>
        <DefaultValue>False</DefaultValue>
    </ParamItem>
    <ParamItem>
        <Name>modelPath</Name>
        <DefaultValue></DefaultValue>
    </ParamItem>
</AlgorithmParamList>
```

## 字段说明

| 字段 | 含义 |
|---|---|
| `<Name>` | 运行参数名，与 `AlgorithmTab.xml` 中控件的 `Name` 属性、C++ `GetParam`/`SetParam` 中 `strcmp(szParamName, "...")` 完全一致 |
| `<DefaultValue>` | 字符串形式的默认值；数值类型按字面写（`128`/`0.5`），Boolean 用 `True`/`False`（**首字母大写**），Enumeration 用对应的整数 Value，OpenFile/String 默认空就留空标签 |

## 与 `AlgorithmTab.xml` / C++ 三方一致

| 三处 | 内容 |
|---|---|
| `AlgorithmTab.xml` | 控件 `<Integer Name="thresholdValue">`...`<CurValue>128</CurValue>` |
| `Algorithm.xml` | `<ParamItem><Name>thresholdValue</Name><DefaultValue>128</DefaultValue></ParamItem>` |
| `AlgorithmModule.cpp` | `if (0 == strcmp("thresholdValue", szParamName)) { sscanf_s(pData, "%d", &m_nThresholdValue); }` |

三处任一缺失或拼错 → 参数无法生效（VM 不会报错，只是控件值改了底层不响应）。

## 与 `AlgorithmTab.xml` 的区别

| 项 | AlgorithmTab.xml | Algorithm.xml |
|---|---|---|
| 用途 | UI 控件完整配置（范围/显示名/类型/枚举项/Trigger） | 仅默认值 |
| 节点 | `<Integer>`/`<Float>`/`<Boolean>`/`<Enumeration>`/`<OpenFile>` 等，含 Min/Max/Description/DisplayName/EnumEntrys 等子节点 | `<ParamItem>` 内仅 `<Name>` + `<DefaultValue>` 两项 |
| 根节点 | `<AlgorithmTabRoot>` | `<AlgorithmParamList>` |
| 读取时机 | 每次打开属性页 | 模块首次创建 |

## 落盘自检

```bash
# 1. 根节点
grep -n "<AlgorithmParamList" <模块名>Algorithm.xml || echo "❌ 根节点错"

# 2. 每个 AlgorithmTab.xml 里的运行参数,必须在 Algorithm.xml 有对应 ParamItem
RUN_PARAMS=$(awk '/<Tab Name="Tab_Run Params">/,/<\/Tab>/' <模块名>AlgorithmTab.xml \
    | grep -oE '(Integer|Float|Boolean|Enumeration|String|OpenFile|IntegerBettween|FloatBettween) Name="[^"]+"' \
    | grep -oE 'Name="[^"]+"' | sed 's/Name="//;s/"//')
for p in $RUN_PARAMS; do
    grep -q "<Name>$p</Name>" <模块名>Algorithm.xml || echo "❌ 缺 ParamItem: $p"
done

# 3. 每个 ParamItem 必须有 Name 和 DefaultValue
grep -nE "<ParamItem>" <模块名>Algorithm.xml | while read -r line; do
    # 简化版:用 xmllint 更可靠
    :
done
```

## 常见错误

- ❌ `<AlgorithmParamList/>` 空壳 + AlgorithmTab.xml 里却有运行参数 → 用户首次创建模块时参数都是 UI 默认值，**未与 C++ 默认值同步**（仅当 UI 默认值和 C++ 构造函数默认值刚好一致时才"碰巧"工作）
- ❌ `<DefaultValue>true</DefaultValue>`（小写）—— Boolean 必须 `True`/`False`
- ❌ `<DefaultValue>BINARY</DefaultValue>`（枚举写描述）—— Enumeration 必须写 `<Value>` 对应的整数
- ❌ ParamItem 名字与 AlgorithmTab.xml 不一致 → 参数读不到默认值
