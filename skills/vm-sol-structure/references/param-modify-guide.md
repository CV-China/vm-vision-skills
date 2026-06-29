# 参数修改指南

AI 在生成 changes.json 修改指令时，参考本指南判断参数的独立性和联动关系。

## 基本原则

1. **独立参数可直接修改**：大部分 algori 参数独立生效，设置新值即可
2. **联动参数需同步修改**：部分参数之间存在依赖，改一处必须同步改关联参数
3. **枚举参数需查值**：枚举类参数的值是整数，需从 AlgorithmTab.xml 或 module-params.md 查对应关系

## 已知联动关系

### RoiType ↔ 坐标参数
修改 `RoiType`（binary param）时，如果 ROI 形状从矩形切换为圆形/旋转矩形等，对应的坐标参数意义会变化。建议保持 RoiType 不变，或同步更新全套坐标（x, y, width, height, angle）。

### 阈值类参数
`LowThreshold` 和 `HighThreshold` 成对出现时，确保 LowThreshold ≤ HighThreshold。部分模块还有 `LowSoftThreshold` / `HighSoftThreshold`，需保持大小关系一致。

### ShellContent（脚本模块）
ShellContent 是 binary 参数，包含完整 C# 脚本源码。**不要简单替换字符串**——需通过 vm-shell-to-as 等 Skill 处理脚本翻译和模块类型切换。

### DynamicInData / DynamicOutData
这两个 binary 参数定义 Shell 模块的动态输入输出端口。修改时需确保 XML 格式正确、端口名称与订阅关系一致。

### 全局变量绑定
将模块参数绑定到全局变量需要**四步操作**（CLI `setParamSub` 自动完成，不可跳过或调换顺序）：
1. UiParamData 中 `@参数名` 改为 `True`
2. 读取全局变量当前值
3. ModuleParamBinding protobuf 添加绑定映射
4. 目标模块 rawData 中参数值改为变量当前值

> `setParamSub` 会自动同步参数值到变量当前值。

## 无需修改的参数

以下参数通常不需要、也不应该被修改：

- `Version`：模块版本号，只读
- `AssemblyGuid`：脚本模块编译 GUID，由 VM 自动管理
- `GUID` / `Position`：UiParamData 中的画布位置标识
- `ModuRunTime` / `ResultShow` / `ModuStatus`：系统保留参数

## 参数值格式

| 类型 | 格式 | 示例 |
|------|------|------|
| 整数 | 字符串形式数字 | `"30"` |
| 浮点数 | 字符串，可用小数 | `"0.5"` |
| 布尔 | `"True"` / `"False"` | `"True"` |
| 枚举 | 整数（十进制字符串） | `"1"` = 最强模式 |
| 字符串 | 原始字符串 | `"hello"` |

枚举值含义参考 `vm-sol-structure/references/module-params.md`。

## 查找参数名

1. 使用 `Cli.exe inspect -f <sol> --list` 列出所有模块的 fullPath、name、displayName、moduleId
2. 使用 `Cli.exe inspect -f <sol> -m "<fullPath>"` 查看目标模块的全部参数
3. 从输出中取 `algoriParams[].name` 作为 `paramName`

target 填 `inspect` 输出中的 `fullPath` 字段。如果同名模块只在路径上不同（如"流程A.屏蔽掩膜"和"流程B.屏蔽掩膜"），fullPath 已包含流程名作为前缀，可区分。

**与用户确认时**，建议使用"全路径 + moduleId"双重描述，避免歧义。例如："纠偏处理.屏蔽掩膜1（moduleId=105）"。

## 新增模块（addModule）

**推荐模板方式**：先让用户在 VM 中建一个包含目标模块类型的 sol 作为模板，然后用 addModule 复制：

```json
{ "action": "addModule", "target": "流程名", "paramName": "模块类型名",
  "value": "显示名称", "templateFile": "模板.sol", "templateModule": "流程.模板模块" }
```

不提供 templateFile 时使用内置 BlobFind 默认值。详见 `format-sol-rebuild.md` → addModule 模板方式。

## ROI 参数格式

RoiType 有两种格式，由字节长度区分：
- **22 字节（矩形）**：int32 shapeType + 4×float32 (x, y, w, h) + int16 flag，值为绝对坐标
- **34 字节（圆形）**：int16 shapeType + 6×float32（归一化值）+ int16 caliperNum。坐标 **归一化到图像尺寸**（sol 不存储图像尺寸），解析标记 `(n)` 后缀

## 命名规范

修改模块 DisplayName 时：
- 可使用中文
- **分隔符只用下划线 `_`**，不要用 `-`、空格等特殊字符
- 示例：`根部破损_改名测试` ✅，`根部破损-改名测试` ❌

## 验证描述规范

向用户描述 VM 验证步骤时，必须使用**完整原始全路径 + 预期变化**，避免歧义：

- ❌ `VM 打开验证：流程1 里的模块是否显示为 "xxx"`
- ✅ `VM 打开验证：原模块"流程1.模块A"是否显示为"xxx"`
