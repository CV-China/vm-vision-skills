# Modify 命令 — 修改指令 Schema

changes.json 是 modify 命令的修改指令文件，由 AI 根据用户自然语言描述生成，CLI 执行。

## CLI 用法

```
Cli.exe modify -f <sol> -c <changes.json> -o <output.sol> [-p <password>]
```

## JSON Schema

```json
{
  "changes": [
    {
      "action": "setParam | setBinaryParam | setBasicSub | addBasicSub | removeBasicSub | setParamSub | addParamSub | removeParamSub | addModule | setDisplayName | setEnabled | deleteModule | addConnection | removeConnection",
      "target": "模块 FullPath（如 流程0.BLOB分析）",
      "paramName": "参数名",
      "value": "新值（字符串）"
    }
  ]
}
```

## Action 类型

### setParam

修改 algori 参数值（固定 1024 字节槽位内的字符串参数）。

```json
{ "action": "setParam", "target": "流程0.BLOB分析", "paramName": "EdgeThreshold", "value": "30" }
```

修改仅影响 algori 参数值，该模块 rawData 长度不变。内部实现在 1024 字节槽内覆盖新值。

### setBinaryParam

修改 binary 参数值（可变长度）。字符串类参数（如 ShellContent、DynamicInData 等）直接编码为 bytes。

```json
{ "action": "setBinaryParam", "target": "流程0.高精度匹配", "paramName": "ShellContent", "value": "int x = 1;" }
```

注意：binary 参数长度变化会导致该模块 rawData 长度变化，进而触发 ModuleFrame 整体重建。

## target 定位规则

target 对应模块的 FullPath，格式为 `流程名.组名.模块名`（如 `流程0.BLOB分析`）。

解析后的 JSON 输出中每个模块有 `fullPath` 字段，AI 据此生成 target。

查找规则：忽略大小写、忽略前后空白。

## 回写策略（字节级保留）

ModuleFrame 始终整体重建（因 rawData 长度可能变化）。但模块 rawData 遵循"字节级保留"：

- **被修改的模块**：根据 algori/binary 参数列表重建 rawData
- **未被修改的模块**：直接复用解析时的 RawFrameData 原字节

这意味着 ShellModule 等有特殊字段的模块，只要未被修改就不会丢失数据。

## 加密处理

使用 VM 自带的 Hzip.dll 处理加密/解密：
- 输入无密码 → 输出不加密
- 输入有密码 → 输出同密码加密（Hzip Compress 原生支持 ZipCrypto）

## 结构化报告

modify 命令执行后会在输出路径旁生成 `<output>.modify.json` 报告文件：

```json
{
  "applied": 1,
  "errors": 0,
  "warnings": []
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `applied` | int | 成功应用的修改数 |
| `errors` | int | 失败的修改数（模块未找到/未知操作） |
| `warnings` | string[] | 警告信息列表（参数不存在/值被截断等） |

## 错误处理

| 场景 | 行为 |
|------|------|
| 模块未找到 | 修改警告: 未找到模块 "xxx"，继续执行其他指令 |
| 参数名不存在 | 修改警告: 模块 "xxx" 无参数 "yyy"（setParam）或无 binary 参数（setBinaryParam）或无订阅参数（setBasicSub） |
| 未知 action | 修改警告: 未知操作类型 "xxx" |
| setParamSub/addParamSub 参数名不存在 | 警告但不阻塞，仍创建绑定 |
| 目标路径大小写 | 自动忽略大小写 |
| 加密 sol 无密码 | 报错：解压失败 |
| 输出文件已存在 | 报错：输出文件已存在（不覆盖） |
| 输出密码 | 与输入密码相同（不支持指定不同密码） |

警告不影响其他指令执行。CLI stdout 报告应用数/总数。

### BasicSub（setBasicSub / addBasicSub / removeBasicSub）

操作 VmServer.xml `<Subscribe Relation="8元组">`。覆盖基本参数（`<module>.xml` 静态 I/O）和动态 IO（`AddIoByType` 运行时添加，`%` 首尾包裹命名，如 `%int0%`）。不涉及 UiParamData @标记和 ModuleParamBinding。

### ParamSub（setParamSub / addParamSub / removeParamSub）

操作 UiParamData `@参数名=True` + ModuleParamBinding protobuf 272B blob。仅用于运行参数（algori params）。合并了原 `setParamBinding`（变量绑定是 ParamSub 的一种）。

### 旧名映射

| 旧 action | 新 action |
|-----------|----------|
| `setSubscription` | `setBasicSub` |
| `addSubscription` | `addBasicSub` |
| `removeSubscription` | `removeBasicSub` |
| `setParamBinding` | `setParamSub`（合并） |

### setBasicSub / addBasicSub / removeBasicSub

操作 VmServer.xml `<Subscribe Relation="8元组">`。覆盖基本参数和动态 IO 参数。字段与旧 `setSubscription` 兼容，新增可达性和类型匹配校验。

```json
// 修改已有订阅
{ "action": "setBasicSub", "target": "...", "paramName": "%int0%", "newTargetModuleId": 219, "newTargetParamName": "ModuStatus" }
// 新增订阅
{ "action": "addBasicSub", "target": "...", "paramName": "InImage", "newTargetModuleId": 21016, "newTargetParamName": "%Imagein%" }
// 删除订阅
{ "action": "removeBasicSub", "target": "...", "paramName": "InImage" }
```

字段说明：`target`=模块 FullPath, `paramName`=输入参数名, `newTargetModuleId`/`newTargetPath`=目标模块, `newTargetParamName`=目标输出参数, `isBind=false`=常量模式。

### setParamSub / addParamSub / removeParamSub

操作 UiParamData `@参数名=True` + ModuleParamBinding protobuf 272B blob。合并原 `setParamBinding`。

```json
// 变量绑定
{ "action": "setParamSub", "target": "...", "paramName": "LowThreshold", "value": "%var0%", "newTargetModuleId": 13000 }
// 模块输出绑定
{ "action": "addParamSub", "target": "...", "paramName": "FindNum", "newTargetModuleId": 101, "newTargetParamName": "ModuStatus" }
// 删除
{ "action": "removeParamSub", "target": "...", "paramName": "FindNum" }
```

字段说明：`target`=模块 FullPath, `paramName`=运行参数名, `value`=变量名（变量绑定时）, `newTargetModuleId`=目标模块 ID, `newTargetParamName`=目标参数名（模块输出绑定时）。CLI 自动完成 @标记+MPB+值同步，校验可达性和类型匹配。

### addConnection / removeConnection

操作 VmServer.xml `<ModuleCommonConnect>` 中的执行连线（FrontModules/FollowModules）。连线决定模块执行顺序，订阅依赖连线建立的可达性。

```json
{ "action": "addConnection", "target": "纠偏处理.极耳角处理1.根部破损", "newTargetModuleId": 102 }
{ "action": "removeConnection", "target": "纠偏处理.极耳角处理1.根部破损", "newTargetModuleId": 102 }
```

`target`=源模块 FullPath, `newTargetModuleId`=目标模块 ID。addConnection 同时更新源模块的 FollowModules 和目标模块的 FrontModules。

### addModule

新增模块到方案中。支持**模板方式**（推荐，适用任何模块类型）和**内置默认值**（仅 BlobFind）。

#### 模板方式（推荐）

指定一个参考 sol 和其中的模块，复制其 rawData 作为新模块模板：

```json
{
  "action": "addModule",
  "target": "流程名",
  "paramName": "IMVSBinaryModu",
  "value": "二值化1",
  "templateFile": "path/to/template.sol",
  "templateModule": "流程1.二值化模板"
}
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `action` | 是 | `"addModule"` |
| `target` | 是 | 目标流程 FullPath |
| `paramName` | 是 | 模块类型名（如 `IMVSBinaryModu`） |
| `value` | 是 | DisplayName |
| `templateFile` | 推荐 | 模板 sol 路径，从此复制 rawData |
| `templateModule` | 推荐 | 模板模块 FullPath，定位模板 sol 中的模块 |
| `newTargetModuleId` | 否 | 指定 ID（不填自动 gap-fill，10000 以内） |

**工作原理**：解析模板 sol → 找到模板模块 → 复制其 `RawFrameData` 字节 → 分配给新模块。不解析参数细节，因此支持**任何模块类型**。

#### 内置默认值（仅 BlobFind）

不提供 templateFile 时，使用内置的 IMVSBlobFindModu 114 参数默认值：

```json
{ "action": "addModule", "target": "流程名", "paramName": "IMVSBlobFindModu", "value": "BLOB1" }
```

### setDisplayName

修改模块显示名称。仅改动 VmServer.xml 中 `<Module>` 的 `DisplayName` 属性（一行）。

订阅 Relation、ModuleParamBinding 均使用模块 ID 引用，不受显示名称影响，无需级联修改。

```json
{ "action": "setDisplayName", "target": "流程.模块名", "value": "新名称" }
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `action` | 是 | `"setDisplayName"` |
| `target` | 是 | 模块 FullPath |
| `value` | 是 | 新显示名称 |

### setEnabled

启用或禁用模块。仅改动 VmServer.xml 中 `<Module>` 的 `EnableModule` 属性（一行）。

```json
{ "action": "setEnabled", "target": "流程.模块名", "value": "true" }
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `action` | 是 | `"setEnabled"` |
| `target` | 是 | 模块 FullPath |
| `value` | 是 | `"true"`/`"1"` 启用，`"false"`/`"0"` 禁用 |

### deleteModule

删除普通模块（不支持 Group/Procedure/全局模块）。

自动清理：VmServer.xml 条目 + 连线 + 订阅 + ModuleParamBinding + UiParamData 文件 + MoudleFrame 条目。每项清理输出 warning。

```json
{ "action": "deleteModule", "target": "流程.模块名" }
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `action` | 是 | `"deleteModule"` |
| `target` | 是 | 模块 FullPath |

## CLI 回写命令（预留）

当前 modify 命令已实现 parse→modify→rebuild→repack 闭环。如需更细粒度控制，可扩展：

```
# 仅重建（输入解析后 JSON、输出 sol）
Cli.exe rebuild -f <origin.sol> -j <parsed.json> -o <output.sol>

# 批量修改（不经过 AI，直接命令行指定参数）
Cli.exe set -f <sol> --param "流程0.BLOB分析.EdgeThreshold=30" -o <output.sol>
```

## changes.json 生成规范

AI 生成 changes.json 时必须遵守以下规则：

### 1. 参数类型匹配

订阅操作（BasicSub/ParamSub）必须确保源参数类型与目标参数类型一致：
- 使用 `Cli.exe inspect -m <fullPath>` 查看 DynamicInData/DynamicOutData 中参数的 ValueType
- `image`→`image`、`int`→`int`、`float`→`float` 等
- CLI 在运行时校验，类型不匹配会报错

### 2. 执行可达性

订阅目标必须在源模块的前序执行链中（目标先执行，源才能订阅其输出）：
- `addParamSub`/`setParamSub`/`addBasicSub`/`setBasicSub` 均校验可达性
- 目标为变量模块时无需检查（全局可访问）
- 先 `addConnection` 建立连线，再订阅

### 3. 变量作用域

- 流程局部变量：仅流程内第一层模块可绑定（Group 内模块不行）
- Group 局部变量：仅该 Group 内第一层模块可绑定

### 4. 订阅方向

- 后执行模块订阅前执行模块的输出
- 内层模块订阅父容器的输入
- 父容器订阅内层模块的输出

### 5. 命名规范

- DisplayName 只用中文 + 下划线 `_`
- 描述模块用完整全路径（如 `纠偏处理.极耳角处理1.根部破损`）或 `moduleId`
