# 日志规范

VM 算法模块的日志接口**有严格白名单**，违反会导致：
- 模块无法被 VM 平台收集日志
- 客户机器上没有日志文件可供排查
- 严重时弹窗阻塞自动化流程

## 允许使用的日志接口（白名单）—— **第一参数必须是 moduleId**

真实宏签名(来自 `templates/AlgTemplate/common/src/HSlog/HSlogDefine.h`):

> ⚠️ **只允许** `MLOG_*` 系列。`LOG_*` 是 SDK 内部别名，**不要**在用户代码中直接使用（SDK 头文件内部有定义但不对外暴露，生成代码统一用 `MLOG_*`）。
```cpp
MLOG_ERROR(mid, fmt, ...)
MLOG_WARN (mid, fmt, ...)
MLOG_INFO (mid, fmt, ...)
MLOG_DEBUG(mid, fmt, ...)
MLOG_TRACE(mid, fmt, ...)
```

`mid` 是 `m_nModuleId`,在 `Init()` 中由 `VM_M_GetModuleId(m_hModule, &m_nModuleId)` 取回并缓存(成员变量,基类 `CVmAlgModuleBase` 已声明)。

| 宏 | 等级 | 使用场景 |
|---|---|---|
| `MLOG_ERROR(m_nModuleId, fmt, ...)` | ERROR | 算法失败、异常被捕获、关键参数错误 |
| `MLOG_WARN (m_nModuleId, fmt, ...)` | WARN  | 配置异常但可降级运行、屏蔽功能 |
| `MLOG_INFO (m_nModuleId, fmt, ...)` | INFO  | 关键流程节点（如算法开始/结束） |
| `MLOG_DEBUG(m_nModuleId, fmt, ...)` | DEBUG | 中间结果，调试期可开启 |
| `MLOG_TRACE(m_nModuleId, fmt, ...)` | TRACE | 最细粒度，循环内详细信息 |

（`LOG_*` 是 SDK 内部别名，不对外暴露；用户代码统一使用 `MLOG_*`。）

## 严禁使用的输出接口（黑名单）

| 接口 | 禁用原因 |
|---|---|
| `MessageBox / MessageBoxA / MessageBoxW` | 阻塞自动化流程 |
| `std::cout / std::cerr / std::clog` | 算法 DLL 中无控制台输出 |
| `printf / puts / fprintf(stdout, ...)` | 同上 |
| `std::cin`（任何输入） | 算法不能交互输入 |
| `OutputDebugStringA/W` | 不进 VM 日志系统 |
| 裸 `sprintf`（用作日志） | 不进 VM 日志系统；安全风险 |

**注意**：`sprintf_s` / `sscanf_s` 作为**格式化辅助**（如在 GetParam/SetParam 内部用于格式转换）**允许**使用，但**禁止**用 `sprintf_s` 拼出字符串后再调用 `OutputDebugString` 当日志用。

## 中文日志：仅含中文时加 u8（英文不需要）

> 详细编码规则见 SKILL.md §J。要点：VM 日志系统按 UTF-8 解析，含中文的字面量须加 `u8` 前缀才能正确显示；
> ASCII/英文日志字符串**不需要** `u8`（UTF-8 与 GB2312 对 ASCII 字节完全一致）。
> **默认策略（推荐）**：优先使用英文日志字面量（SKILL.md §J）；仅在用户明确要求中文时才使用 `u8"..."` 格式。

```cpp
MLOG_INFO(m_nModuleId, u8"开始处理图像 %d x %d", width, height);
MLOG_ERROR(m_nModuleId, u8"输入参数 %s 非法", pName);  // 含中文必须 u8
```

英文日志可不加 u8：
```cpp
MLOG_ERROR(m_nModuleId, "AllocateSharedMemory failed: 0x%x", nErrCode);
```

详见 [encoding.md](encoding.md)（运行时路径转换）和 [SKILL.md §J](../SKILL.md)。

## 日志级别选择决策

```
是否影响算法继续运行？
├─ 是 → 算法是否能继续输出有意义结果？
│       ├─ 否 → MLOG_ERROR（并设 errorStatus=0）
│       └─ 是（降级或忽略部分功能） → MLOG_WARN
└─ 否 → 是否关键流程节点？
        ├─ 是 → MLOG_INFO
        └─ 否 → MLOG_DEBUG / MLOG_TRACE
```

## 常见错误改写

### ❌ 模板里残留的 OutputDebugStringA
```cpp
OutputDebugStringA("Process start\n");  // 黑名单！
```
✅ 改写：
```cpp
MLOG_INFO(m_nModuleId, "Process start");
```

### ❌ MessageBox 提示用户
```cpp
MessageBoxA(NULL, "参数错误", "提示", MB_OK);  // 黑名单！
```
✅ 改写：
```cpp
MLOG_ERROR(m_nModuleId, u8"参数 %s 错误", pName);
return IMVS_EC_PARAM;
```

### ❌ std::cout 调试
```cpp
std::cout << "value = " << v << std::endl;  // 黑名单！
```
✅ 改写：
```cpp
MLOG_DEBUG(m_nModuleId, "value = %d", v);
```

## 日志输出位置

VM 模块的 MLOG 输出写入 VM 安装目录的 `Applications\log\` 子目录,由 VM 平台统一管理:
```
VisionMaster4.X.0\Applications\log\Modules\Modules.log   (VM430+ 模块统一日志)
VisionMaster4.X.0\Applications\log\Module\<模块名>.log   (VM430 早期版本,分模块文件)
```
开发期可在 VM 配置中调高日志级别（默认 INFO）以查看 DEBUG/TRACE。
