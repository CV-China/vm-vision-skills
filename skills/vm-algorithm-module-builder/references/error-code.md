# 错误码

`common/src/ErrorCodeDefine.h` 定义 VM SDK 错误码常量。算法模块返回值**必须**用这些宏，**禁止**自定义裸数字。

## 通用错误码（高频使用,均来自 `common/src/ErrorCodeDefine.h`）

| 宏 | 值 | 含义 |
|---|---|---|
| `IMVS_EC_OK` | 0x00000000 | 成功 |
| `IMVS_EC_VERSION` | 0xE0000000 | SDK 版本错误 |
| `IMVS_EC_PARAM` | 0xE0000001 | 参数错误（最常用的兜底错误） |
| `IMVS_EC_RESOURCE_CREATE` | 0xE0000002 | 资源（图像/内存/线程）创建失败 |
| `IMVS_EC_OUTOFMEMORY` | 0xE0000003 | 内存不足 |
| `IMVS_EC_POINTER_CAST` | 0xE0000004 | 指针转换错误 |
| `IMVS_EC_INVALID_HANDLE` | 0xE0000006 | 句柄无效 |
| `IMVS_EC_NOT_SUPPORT` | 0xE0000007 | 该操作不支持 |
| `IMVS_EC_NOT_READY` | 0xE0000008 | 资源未初始化/未准备好 |
| `IMVS_EC_WAIT_TIMEOUT` | 0xE0000009 | 等待超时 |
| `IMVS_EC_NULL_PTR` | 0xE000000A | 空指针 |
| `IMVS_EC_CALL_ORDER` | 0xE000000F | 接口调用顺序错误(注意是 `CALL_ORDER`,不是 `CALLORDER`) |
| `IMVS_EC_LOAD_LIBRARY` | 0xE0000010 | 动态库加载失败 |
| `IMVS_EC_PARAM_BUF_LEN` | 0xE0000012 | 参数缓冲区长度不足 |
| `IMVS_EC_INDEX_OUT_OF_BOUNDARY` | 0xE0000014 | 索引越界 |
| `IMVS_EC_DATA_ERROR` | 0xE0000018 | 数据错误 |
| `IMVS_EC_PRECONDITION` | 0xE000001B | 前置条件错误 |
| `IMVS_EC_RUNTIME` | 0xE000001C | 运行环境错误 |
| `IMVS_EC_MODULE_SUB_RST_NOT_FOUND` | 0xE0000314 | 模块订阅结果未找到（SDK 调用返回值，Process 中应传播此错误码而非改写为 `IMVS_EC_PARAM`） |
| `IMVS_EC_UNKNOWN` | 0xE00000FF | 未知错误 |

⚠️ **禁止编造**(不存在的常见错码):
- ❌ `IMVS_EC_NOMEM`(用 `IMVS_EC_OUTOFMEMORY`)
- ❌ `IMVS_EC_TIMEOUT`(用 `IMVS_EC_WAIT_TIMEOUT`)
- ❌ `IMVS_EC_CALLORDER` 无下划线(用 `IMVS_EC_CALL_ORDER`)
- ❌ `IMVS_EC_NOENOUGHBUF`(用 `IMVS_EC_PARAM_BUF_LEN`)
- ❌ `IMVS_EC_NETER`(网络错误用 `IMVS_EC_COMMU_*` 系列)

## 算法模块返回值典型用法

```cpp
int CAlgorithmModule::Process(...)
{
    if (modu_input == nullptr || modu_input->pImageInObj == nullptr)
        return IMVS_EC_PARAM;

    int nErrCode = AllocateSharedMemory(m_nModuleId, nLen,
                                        (char**)(&pImage.data), &pSharedName);
    if (nErrCode != IMVS_EC_OK)
        return IMVS_EC_RESOURCE_CREATE;

    // 算法成功
    return IMVS_EC_OK;
}
```

## 自定义错误码

如需算法专属错误码，在 `AlgorithmModule.h` 中定义专用宏（高位 0xE 段已被 SDK 占用，自定义建议 0xA 段起）：

```cpp
#define IMVS_EC_ALG_INVALID_MODEL   0xA0000001  // 模型文件无效
#define IMVS_EC_ALG_NO_FEATURE      0xA0000002  // 未提取到特征
```

但**不推荐**——VM 平台对未知错误码统一显示"算法异常"，不如直接 `MLOG_ERROR` 写明原因并 `return IMVS_EC_PARAM`。

## 与 errorStatus 的区别

- `nErrCode`（函数返回值）：表示**框架是否能正常工作**，影响 VM 调度（如返回非 OK，VM 视为模块故障）
- `errorStatus`（写到 `ModuStatus` 基本参数）：表示**算法是否得到有效结果**，1=OK / 0=NG，下游模块用此判断

```cpp
// 算法本身没出错，但结果是 NG（如阈值未通过）
VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
return IMVS_EC_OK;  // 框架返回 OK
```

```cpp
// 算法出错（异常/参数错）
VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
return IMVS_EC_PARAM;  // 框架返回错误
```

两个值是独立维度，**都要设**。
