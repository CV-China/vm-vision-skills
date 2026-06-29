# 连线与数据流

VM 方案中，"连线"有三种不同的概念，容易混淆。

## 三种连线的区别

| 概念 | 定义位置 | 作用 |
|------|----------|------|
| 执行连线（ModuleCommonConnect） | VmServer.xml | 决定模块执行顺序（谁先谁后） |
| 参数订阅（ModuleSubscribe） | VmServer.xml | 决定数据从哪个模块的哪个参数流向哪里 |
| 连线槽位（UiParamData SourceIndex/TargetIndex） | UiParamData | 画布上连线的视觉表示，高字节=槽位，低3字节=端口 |

## ModuleCommonConnect — 执行连线

定义模块间的执行顺序，不是数据流向：

```xml
<Module Index="2">
    <FrontModules>
        <Front Index="4" />   <!-- 模块4 先于 模块2 执行 -->
    </FrontModules>
    <FollowingModules>
        <Following Index="0" /> <!-- 模块0 在 模块2 之后执行 -->
    </FollowingModules>
</Module>
```

## ModuleSubscribe — 参数订阅（数据流）

### 8 字段格式

```
curModuleId . curParamName . tarModuleId . tarParamName . isBind . indexTarModuId . indexTarParamName . isIndexBind
```

| 字段 | 说明 |
|------|------|
| curModuleId | 当前模块 ID |
| curParamName | 当前模块的输入参数名（可为 base64 编码的 `%xxx%` 格式） |
| tarModuleId | 目标（数据源）模块 ID |
| tarParamName | 目标模块的输出参数名 |
| isBind | 0=订阅输入（绑定到另一模块输出），1=手动输入（常量值，此时 `tarParamName` 即为常量值，XML 节点中不存在 `indexTarModuId`/`indexTarParamName`/`isIndexBind` 三个字段） |
| indexTarModuId | 索引目标模块 ID（通常为 0，非 0 时含义待更多样本确认） |
| indexTarParamName | 索引目标参数名（已观察样本中均为 "All"，其他值含义目前未知） |
| isIndexBind | 索引绑定标志（已观察样本中均为 1，其他值含义目前未知） |

### isBind 两种模式

- `isBind=0`：订阅输入，绑定到另一模块的输出，`tarParamName` 是参数名，8 字段完整
- `isBind=1`：手动输入，常量值，`tarParamName` 即为常量值本身，后续 `indexTarModuId`/`indexTarParamName`/`isIndexBind` 三个字段省略

## 参数订阅的两种存储机制

sol 中参数订阅存在两种不同的存储方式，对应不同的 CLI action：

### 基本 + 动态 IO 参数订阅（BasicSub）→ VmServer.xml Relation

存储在 `<ModuleSubscribe>` 的 `<Subscribe Relation="8 元组">` 中。覆盖两类参数：
- **基本参数**：`<module>.xml` 静态定义的 I/O 端口
- **动态 IO**：运行时通过 `AddIoByType` 动态添加的端口（以 `%` 首尾包裹命名，如 `%int0%`）

两类参数均走 Relation 机制订阅，存储位置相同，不涉及 UiParamData @标记和 ModuleParamBinding。CLI 统一用 BasicSub 系列 action。

CLI: `setBasicSub` / `addBasicSub` / `removeBasicSub`

### 运行参数订阅（ParamSub）→ @标记 + ModuleParamBinding

存储在 UiParamData `@参数名=True`（5 字节 `"True\0"`）+ ModuleParamBinding protobuf 272B blob 中。blob[0x8C] 指向目标 ID，blob[0x90] 指向目标名。目标可以是另一模块的输出参数，也可以是变量模块的变量。

CLI: `setParamSub` / `addParamSub` / `removeParamSub`（合并原 `setParamBinding`）

### curParamName base64 编码

若 `curParamName` 为 base64 编码（如 `%Q2FsY3VsYXRvcklucHV0MA==%`），解码后是模块内部占位符名（如 `CalculatorInput0`）。

### 变量模块的订阅

变量模块（GlobalVariableModule/LocalVariableModule）作为数据源时：
- `tarModuleId` = 变量模块的 ID（如 13000/24001/31001）
- `tarParamName` = 变量名（如 `%标定类型%`）

### 图像订阅 4 元组

算法模块订阅相机图像时，需订阅 4 个参数：

```
{modId} . InImage . {camId} . Image . 0 . 0 . All . 1
{modId} . InImageWidth . {camId} . Width . 0 . 0 . All . 1
{modId} . InImageHeight . {camId} . Height . 0 . 0 . All . 1
{modId} . InImagePixelFormat . {camId} . PixelFormat . 0 . 0 . All . 1
```

## 两种绑定机制的区别

| 机制 | 存储位置 | 作用 |
|------|----------|------|
| `ModuleSubscribe` | VmServer.xml | 模块**输入端口**（DynamicInData 里的 Filter 参数）绑定到另一模块的输出端口 |
| `ModuleParamBinding` | ModuleFrame（protobuf） | 模块的 **algori 运行参数**（算法配置参数）绑定到另一模块的输出参数 |

ModuleParamBinding 的二进制格式见 `vm-sol-format` 的 `format-special-modules.md`。

## DynamicParamInfo — Group DynamicIO

```xml
<DynamicParamInfo>
    <Object Index="21004">
        <DynamicParam ParamName="%根部圆弧ROI1%">
            <Module Index="103" ParamName="RoiType" />
        </DynamicParam>
    </Object>
</DynamicParamInfo>
```

- `Object Index` = Group ID
- `DynamicParam ParamName` = Group 对外暴露的输出参数名
- `Module Index/ParamName` = Group 内部模块 ID 和对应的 algori 参数名
- 作用：Group 将内部模块的 algori 参数直接暴露为自己的输出端口

## 拓扑表示

VmServer.xml 中模块间拓扑关系的三种 XML 元素：

| XML 元素 | 含义 | 示例 |
|----------|------|------|
| `<FrontModules>` / `<FollowingModules>` | 执行连线（串行先后顺序）。Front=前序模块（先执行），Following=后序模块 | `<FrontModules><Front Index="21004"/></FrontModules>` |
| `<InsideModules>` | 嵌套关系。Procedure 或 Group 包含哪些子模块 | `<ProcedureInsideModules><X Index="101"/></ProcedureInsideModules>` |
| `<ContainerRelateModules>` | 容器关联模块。局部变量、流程通信等不直接参与执行连线的辅助模块 | `LocalVariableModule`、`ProcedureComm` |

## 订阅作用域规则

在嵌套拓扑中，参数订阅受层级作用域限制：

| 方向 | 规则 | 说明 |
|------|------|------|
| 内层 → 外层 INPUT | ✅ 允许 | 流程内模块可以订阅流程的输入参数；Group 内模块可以订阅 Group 的输入参数 |
| 外层 → 内层 OUTPUT | ✅ 允许 | 流程可以订阅其内部模块的输出参数；Group 可以订阅其内部模块的输出参数 |
| 内层 → 外层 OUTPUT | ❌ 不允许 | 流程内模块不能订阅流程自身的输出 |
| 外层 → 内层 INPUT | ❌ 不允许 | 流程不能订阅其内部模块的输入参数 |
| 跨层级 | ❌ 不允许 | Group 内嵌套的模块不能订阅其祖先流程的局部变量，只能订阅**直属**容器（Group）的局部变量 |

## 变量绑定作用域规则

| 容器类型 | 可绑定范围 |
|----------|-----------|
| 流程局部变量（LocalVariableModule，ContainerType=1） | 仅流程内**第一层**模块（不含 Group 内嵌套的模块） |
| Group 局部变量（LocalVariableModule，ContainerType=20） | 仅该 Group 内**第一层**模块 |

## 典型数据流模式

### 模式一：累积-批量输出

```
检测模块 → 脚本（累积N次数据）→ 条件检测（判断是否达到N）→ 批量输出
```

### 模式二：数组预处理

```
相机 → 脚本（数组变换）→ 检测模块（使用变换后的 ROI 高度）
```

### 模式三：状态汇总判断

```
多个检测模块 → 条件检测（汇总 ModuStatus）→ 通信输出
```

## Dynamic IO 机制

DynamicIO 允许模块在运行时动态增删输入/输出端口，而非在 `<module>.xml` 中静态定义。

### 核心特性

| 特性 | 说明 |
|------|------|
| 容器类型 | `DynamicIOContainer<T>`，黑盒实现 |
| 创建槽位 | `AddIoByType()` 创建真正的 VmIO 槽位 |
| 命名约定 | 动态 IO 参数名首尾加 `%` 区分（如 `%动态参数%`），经验推测，待验证 |
| 固化行为 | 动态增删后的 IO 会固化到 sol 文件中，再次打开方案后仍可继续增删 |
| CombineType 切换 | 复合类型（IMAGE/ROIBOX/POINT/LINE 等）切换时必须「先删后加」，单值类型可直接修改 TypeName |
| Init() 绑定 | VM4.2.0+ 必须在 Init() 中完成动态 IO 绑定，升级旧模块时常遗漏此项 |

### 动态 IO 在 sol 中的体现

- 动态 IO 端口信息存储在 VmServer.xml 的 `DynamicInData` / `DynamicOutData` 中
- Group 通过 `DynamicParamInfo` 将内部模块的 algori 参数暴露为输出端口
- `InniterBusiness` 时机：首次打开模块参数面板时触发
