# C++ 接口速查(以 templates/AlgTemplate/common/ 下真实头文件为准)

⚠️ **铁律**:本文所有接口签名都是从真实头文件 grep 出来的,**不要**自创任何 VM_M_*/VmModule_*/IMVS_EC_*/HKA_* 符号,所有 API 使用前必须能在以下头文件中找到:
- `common/VM400/include/VmModuleFrame/VmModuleBase.h` —— VM_M_Get*/Set* 系列
- `common/src/VmModule_IO.h` —— VmModule_Get*/Output* 系列
- `common/src/VmAlgModuBase.h` —— 基类（CVmAlgModuleBase）
- `common/src/VmModuleSharedMemoryBase.h` —— AllocateSharedMemory
- `common/src/ErrorCodeDefine.h` —— IMVS_EC_*
- `common/src/HSlog/HSlogDefine.h` —— MLOG_*

## 输入图像 I/O(来自 VmModule_IO.h)

```cpp
// 单图(默认输入图,带共享内存名)
HKA_S32 VmModule_GetInputImageEx(IN const void * const hInput,
                                 HKA_IMAGE *image,
                                 HKA_S32   &iImageDataLen,
                                 char      *strSharedMemoryName,
                                 HKA_S32   *imageStatus);

// 单图(不要共享内存名)
HKA_S32 VmModule_GetInputImageEx(IN const void * const hInput,
                                 HKA_IMAGE *image,
                                 HKA_S32   &iImageDataLen,
                                 HKA_S32   *imageStatus);

// 多图按名取
HKA_S32 VmModule_GetInputImageByName(IN const void * const hInput,
                                     char *strImage, char *strWidth,
                                     char *strHeight, char *strFormat,
                                     HKA_IMAGE *image,
                                     HKA_S32 *imageStatus,
                                     char *strSharedMemName = NULL);

// 屏蔽图(可选)
HKA_S32 VmModule_GetMaskImage(IN const void * const hInput,
                              HKA_IMAGE *image, HKA_S32 &iImageDataLen,
                              HKA_S32 *imageStatus);
```

> 🚫 **易编造伪接口（禁用）**：
> - `VmModule_GetInputImageEx(hInput, "InImage", &pImage)` —— 参数顺序/数量全错；真实签名第二参是 `HKA_IMAGE*` 不是字符串
> - `VM_M_GetImageInfo(hInput, ...)` —— 不存在；图像尺寸/格式用 `modu_input->pImageInObj->GetWidth()/GetHeight()/GetPixelFormat()`
> - `VM_M_GetImageData(hInput, ...)` —— 不存在；图像数据用 `modu_input->pImageInObj->GetImageData(0)->pData`
> - `VM_M_GetImage(hInput, "InImage", &img)` 当多图取 —— 多图必须 `VmModule_GetInputImageByName`，**不是** `VM_M_GetImage`
> - `VmModule_GetInputImage` （无 Ex 后缀）—— 不存在

## 输出图像 I/O(来自 VmModule_IO.h)

```cpp
// 命名输出灰度图(C1R)/彩色图(C3R)
HKA_S32 VmModule_OutputImageByName_8u_C1R(IN const void * const hOutput,
                                          HKA_U32 status,
                                          const char *strImage, const char *strWidth,
                                          const char *strHeight, const char *strFormat,
                                          HKA_IMAGE *image,
                                          bool bDeepCopy /*= false*/,
                                          const char *pSharedMemoryName /*= NULL*/);

HKA_S32 VmModule_OutputImageByName_8u_C3R(...同上...);

// 默认输出图(Dst)/源图传递(Src)
HKA_S32 VmModule_OutputDstImage_8u_C1R(hOutput, status, HKA_IMAGE*, bDeepCopy, pSharedName);
HKA_S32 VmModule_OutputDstImage_8u_C3R(hOutput, status, HKA_IMAGE*, bDeepCopy, pSharedName);
HKA_S32 VmModule_OutputSrcImage_8u_C1R(hOutput, status, HKA_IMAGE*, pSharedName);
```

> 🚫 **易编造伪接口（禁用）**：
> - `VM_M_SetOutputImage(hOutput, ...)` / `VM_M_SetImage(hOutput, "OutImage", &img)` —— 输出图像**必须**用 `VmModule_OutputImageByName_8u_C1R/C3R`，VM_M_Set 系列没有图像输出
> - `VmModule_OutputImage_C1R` （缺 `8u_` 段）/ `VmModule_OutputImageByName_C1R` （缺 `8u_` 段）—— 真实命名必须是 `8u_C1R/C3R`
> - `bDeepCopy=1` 时仍传 `pSharedMemoryName` —— 浅拷贝场景下 `pSharedMemoryName` 应传 `NULL`
> - `VM_M_DestroyImage(pImage)` —— 不存在；共享内存由 SDK 管理，无需手动销毁

## 共享内存(来自 VmAlgModuBase 基类)

```cpp
// 申请共享内存(用于新建输出图像缓冲)
int AllocateSharedMemory(HKA_S32 moduleId, HKA_S32 nLen,
                         char **ppData, char **ppSharedName);
```

> 🚫 **易编造伪接口（禁用）**：
> - `VM_M_CreateImage(nLen, &pData)` / `VM_M_AllocImage` —— 不存在；申请图像缓冲**必须**用 `AllocateSharedMemory`
> - `malloc(nLen)` 后传给 `VmModule_OutputImageByName_*` —— 必须用 SDK 的共享内存，普通 malloc 内存不能跨模块传递
> - `AllocateSharedMemory` 不检查返回值 → 失败时 `pImage.data` 是野指针 → memcpy_s 写飞内存。**必须** `if (nErrCode != IMVS_EC_OK) return IMVS_EC_RESOURCE_CREATE;`

## 基本参数 Get(输入,来自 VmModuleBase.h)——**注意 nIndex 参数**

```cpp
// ⚠️ 真实签名顺序: hInput, szName, nIndex, &val, &count
int VM_M_GetInt(const void* hInput,    const char* szName, int nIndex, int*   pValue,  int* pCount);
int VM_M_GetFloat(const void* hInput,  const char* szName, int nIndex, float* pValue,  int* pCount);
int VM_M_GetString(const void* hInput, const char* szName, int nIndex,
                   char* pBuff, int nBuffLen, int* pDataLen, int* pCount);
int VM_M_GetImage(const void* hInput,    const char* szName, int nIndex,
                  IMAGE_DATA*   pImageData, int* pCount);
int VM_M_GetImageEx(const void* hInput,  const char* szName, int nIndex,
                    IMAGE_DATA_V2* pImageData, int* pCount);
int VM_M_GetPointset(const void* hInput, const char* szName, int nIndex,
                     POINTSET_DATA** ppData, int* pDataLen, int* pCount);
int VM_M_GetBytes(const void* hInput,    const char* szName, int nIndex,
                  void** ppData, int* pDataLen, int* pCount);
```

> 🚫 **易编造伪接口（禁用）**：
> - `VM_M_GetIntValue` / `VM_M_GetFloatValue` / `VM_M_GetStringValue` —— **没有 Value 后缀**，真实是 `VM_M_GetInt/Float/String`
> - `VM_M_GetInt(hInput, "X", &val)` （缺 nIndex 和 pCount，4 参版） —— 真实签名是 **5 参**，必传 `nIndex=0` 和 `&nCount`
> - `VM_M_GetLine(hInput, "X", &line)` / `VM_M_GetRect(hInput, "X", &rect)` —— **不存在**；直线用 `VM_M_GetFloat` 逐分量(StartX/StartY/EndX/EndY)，矩形用 `VM_M_GetFloat` 逐分量(CenterX/CenterY/Width/Height/Angle)
> - `VM_M_GetPoint(hInput, "X", &pt)` / `VM_M_SetPoint` —— **不存在**；用 `VM_M_GetFloat/VM_M_SetFloat` 逐分量(CenterX/CenterY)
> - `VM_M_GetCircle` / `VM_M_SetCircle` —— **不存在**；用 `VM_M_GetFloat/VM_M_SetFloat` 逐分量(CenterX/CenterY/InnerRadius/Radius/StartAngle/AngleExtend)
> - `VM_M_GetPoints` / `VM_M_GetPointArray` —— 不存在；点集**必须** `VM_M_GetPointset`（带 `set` 后缀）
> - `VM_M_GetByteArray` / `VM_M_GetBuffer` —— 不存在；字节数组**必须** `VM_M_GetBytes`

**使用模板**:
```cpp
int nCount = 0;
int nVal   = 0;
int nRet = VM_M_GetInt(hInput, "InputIntParam", 0, &nVal, &nCount);
if (nRet != IMVS_EC_OK || nCount <= 0) {
    MLOG_ERROR(m_nModuleId, "Get InputIntParam failed: 0x%x, count=%d", nRet, nCount);
    return IMVS_EC_PARAM;
}
```

## 基本参数 Set(输出,来自 VmModuleBase.h)

```cpp
// ⚠️ 真实签名顺序: hOutput, szName, nIndex, value
int VM_M_SetInt(const void* hOutput,    const char* szName, int nIndex, int   nValue);
int VM_M_SetFloat(const void* hOutput,  const char* szName, int nIndex, float fValue);
int VM_M_SetString(const void* hOutput, const char* szName, int nIndex, const char* pValue);
int VM_M_SetImage(const void* hOutput,  const char* szName, int nIndex, IMAGE_DATA* pImageData);
int VM_M_SetImageEx(const void* hOutput,const char* szName, int nIndex,
                    IMAGE_DATA_V2* pImageData, const char* szSharedMemoryName);
int VM_M_SetPointset(const void* hOutput, const char* szName, int nIndex,
                     POINTSET_DATA* pData, int nDataLen);
int VM_M_SetBytes(const void* hOutput,  const char* szName, int nIndex,
                  void* pData, int nDataLen);
```

> 🚫 **易编造伪接口（禁用）**：
> - `VM_M_SetIntValue` / `VM_M_SetFloatValue` / `VM_M_SetStringValue` —— 无 Value 后缀；真实是 `VM_M_SetInt/Float/String`
> - `VM_M_SetString(hOutput, "X", 0, str.c_str(), len)` （5 参带 length）—— **只 4 参**，无 length
> - `VM_M_SetInt(hOutput, "X", value)` （缺 nIndex，3 参版）—— 必传 `nIndex=0`
> - `VM_M_SetParam(hOutput, "X", val)` —— **不存在**；运行参数走成员函数 `CAlgorithmModule::SetParam`，**不是**通过 hOutput
> - `VM_M_SetLine` / `VM_M_SetRect` —— 不存在；直线用 `VM_M_SetFloat` 逐分量(StartX/StartY/EndX/EndY)，矩形用 `VM_M_SetFloat` 逐分量(CenterX/CenterY/Width/Height/Angle)
> - `VM_M_SetPoint` / `VM_M_SetCircle` —— 不存在；用 `VM_M_SetFloat` 逐分量
> - `VM_M_SetPoints` / `VM_M_SetPointArray` —— 不存在；点集**必须** `VM_M_SetPointset`
> - `VM_M_Set*(hOutput, "OutROI"/"ROI"/"FixROI", ...)` —— ROI 由基类回显，**不允许**手动输出

## 模块状态/信息(来自 VmModuleBase.h)

```cpp
int VM_M_GetModuleId(const void* hModule, int* pModuleId);
int VM_M_SetModuleRuntimeInfo(const void* hModule, MODULE_RUNTIME_INFO* pRuntimeInfo);
```

> 🚫 **易编造伪接口（禁用）**：
> - `VM_M_GetModuleHandle` / `VM_M_GetModule` —— 不存在；模块 ID 用 `VM_M_GetModuleId`
> - `VM_M_SetModuleTime(hModule, ms)` / `VM_M_SetRuntime` —— 不存在；耗时**必须**通过 `MODULE_RUNTIME_INFO` 结构体 + `VM_M_SetModuleRuntimeInfo`
> - `AlgCommon_TimeMilliseconds()` / `VM_M_GetTickCount()` —— 不存在；用模板 `AlgorithmModule.h` 内联的 `MyMilliseconds()`

## 日志(来自 HSlogDefine.h)——**第一参数是 moduleId**

```cpp
MLOG_ERROR(m_nModuleId, "fmt %d", x);
MLOG_WARN (m_nModuleId, "fmt %d", x);
MLOG_INFO (m_nModuleId, "fmt %d", x);
MLOG_DEBUG(m_nModuleId, "fmt %d", x);
MLOG_TRACE(m_nModuleId, "fmt %d", x);
```

`m_nModuleId` 在 `Init()` 内由 `VM_M_GetModuleId(m_hModule, &m_nModuleId)` 拿到并缓存。

**禁止**:`MessageBox / AfxMessageBox / std::cout / std::cerr / printf / sprintf 裸用 / OutputDebugString / ConsoleWrite`。

> 🚫 **易编造伪接口（禁用）**：
> - `MLOG_ERROR("fmt", x)` （缺第一参数 moduleId）—— 真实签名第一参**必须**是 `m_nModuleId`
> - `MLOG_FATAL` / `MLOG_CRITICAL` / `MLOG_VERBOSE` —— 不存在；只有 ERROR/WARN/INFO/DEBUG/TRACE 5 个等级
> - `HSLOG_ERROR` / `Log_Error` / `LOG_ERR` —— 命名错；用 `MLOG_*`
> - `MLOG_INFO(m_nModuleId, std::string("X").c_str())` —— 直接传字符串字面量即可，无需 `.c_str()`

## 运行参数(GetParam / SetParam 成员函数,**不**用 VM_M_*)

运行参数**全部是输入**(无输出概念),通过基类的两个虚函数 `GetParam` / `SetParam` 在内存中保存/读取:

```cpp
int CAlgorithmModule::GetParam(IN const char* szParamName, OUT char* pBuff,
                               IN int nBuffSize, OUT int* pDataLen)
{
    if (szParamName == NULL || pBuff == NULL || nBuffSize <= 0 || pDataLen == NULL)
        return IMVS_EC_PARAM;

    if (0 == strcmp(szParamName, "thresholdValue")) {
        sprintf_s(pBuff, nBuffSize, "%d", m_nThresholdValue);
        return IMVS_EC_OK;
    }
    // ... 其他运行参数分支 ...

    return CVmAlgModuleBase::GetParam(szParamName, pBuff, nBuffSize, pDataLen);
}

int CAlgorithmModule::SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen)
{
    if (szParamName == NULL || pData == NULL || nDataLen == 0)
        return IMVS_EC_PARAM;

    if (0 == strcmp(szParamName, "thresholdValue")) {
        m_nThresholdValue = atoi(pData);
        return IMVS_EC_OK;
    }
    // ... 其他运行参数分支 ...

    return CVmAlgModuleBase::SetParam(szParamName, pData, nDataLen);
}
```

⚠️ **禁止**把运行参数当输出用:`VM_M_SetParam(...)` 不存在,**不要**写 `VM_M_SetInt(hOutput, "RunParamName", ...)`。

> 🚫 **易编造伪接口（禁用）**：
> - `MVDSDK_TRY { ... } MVDSDK_CATCH { ... }` 包裹 GetParam/SetParam 内部 —— 不需要，基类已有异常处理
> - 手动 `*pDataLen = strlen(pBuff)` —— 用 `sprintf_s` 的返回值即可（它返回写入字节数）
> - Boolean 用 `*(bool*)pData` / `atoi(pData)` 解析 —— pData 是字符串 `"True"`/`"False"`，用 `strcmp("True", pData) == 0`
> - 运行参数走 `VM_M_GetParam` / `VM_M_SetParam` —— 不存在；运行参数**只**通过成员函数 `GetParam`/`SetParam`

## 错误码(来自 ErrorCodeDefine.h，常用子集)

| 宏 | 值 | 含义 |
|---|---|---|
| `IMVS_EC_OK` | 0x00000000 | 成功 |
| `IMVS_EC_VERSION` | 0xE0000000 | 版本错误 |
| `IMVS_EC_PARAM` | 0xE0000001 | 参数错误 |
| `IMVS_EC_RESOURCE_CREATE` | 0xE0000002 | 资源创建失败 |
| `IMVS_EC_OUTOFMEMORY` | 0xE0000003 | 内存不足(**不是** `IMVS_EC_NOMEM`!) |
| `IMVS_EC_NULL_PTR` | - | 空指针 |
| `IMVS_EC_INVALID_HANDLE` | - | 无效句柄 |
| `IMVS_EC_NOT_SUPPORT` | - | 不支持 |
| `IMVS_EC_NOT_READY` | - | 未就绪 |
| `IMVS_EC_WAIT_TIMEOUT` | - | 等待超时 |
| `IMVS_EC_PARAM_BUF_LEN` | - | 参数缓冲长度错 |
| `IMVS_EC_UNKNOWN` | 0xE00000FF | 未知错误 |

**绝不**使用 `IMVS_EC_NOMEM`(不存在)。完整定义见 [error-code.md](error-code.md) 或直接 grep `templates/AlgTemplate/common/src/ErrorCodeDefine.h`。

> 🚫 **易编造错误码（禁用）**：
> - `IMVS_EC_NOMEM` → 用 `IMVS_EC_OUTOFMEMORY`
> - `IMVS_EC_INVALID_PARAM` / `IMVS_EC_BAD_PARAM` → 用 `IMVS_EC_PARAM`
> - `IMVS_EC_ALLOC_FAILED` / `IMVS_EC_RESOURCE_FAIL` → 用 `IMVS_EC_RESOURCE_CREATE`
> - `IMVS_EC_NULLPTR` （无下划线）→ 用 `IMVS_EC_NULL_PTR`
> - `IMVS_OK` / `EC_OK` （缺前缀）→ 用 `IMVS_EC_OK`

## 字符编码(中文路径)

```cpp
#ifdef _WIN32
CStringA UTF8toANSI(const char* strUTF8);
CStringA ANSItoUTF8(CStringA bufRecv);
#endif
```

详见 [encoding.md](encoding.md)。

## 图像格式宏

| 像素格式宏 | 对应 HKA_IMG_* | 通道数 |
|---|---|---|
| `MVD_PIXEL_MONO_08` | `HKA_IMG_MONO_08` | 1(灰度) |
| `MVD_PIXEL_RGB_RGB24_C3` | `HKA_IMG_RGB_RGB24_C3` | 3(RGB24) |
| `MVD_PIXEL_BGR_BGR24_C3` | `HKA_IMG_BGR_BGR24_C3` | 3(BGR24) |

## 自检要求(落盘前必做)

生成的 .cpp/.h 中所有 `VM_M_` / `VmModule_` / `IMVS_EC_` / `HKA_IMG_` / `MLOG_` 符号都必须能在 `templates/AlgTemplate/common/` 下 grep 到。grep 不到 → 该接口是**编造的**,删除或换成真实接口。
