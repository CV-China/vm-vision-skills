# 接口黑名单（落盘后必须 grep 自检）

以下接口**禁止在几何参数（点/线/矩形/圆）读写中使用**。其中编造接口（标注"不存在"）在 SDK 中不存在；复合接口（标注"不应使用"）虽存在于 SDK，但几何参数统一使用 `VM_M_GetFloat/VM_M_SetFloat` 逐分量方式。

生成 `AlgorithmModule.cpp/.h` 后**必须**对该文件跑 grep，任何命中立即回滚改写。

## 黑名单

| 禁止接口 | 正确替代 |
|---|---|
| `VM_M_GetImageInfo` | `modu_input->pImageInObj->GetHeight()/GetWidth()/GetPixelFormat()` |
| `VM_M_CreateImage` | `AllocateSharedMemory(m_nModuleId, nLen, &pImage.data, &pSharedName)` |
| `VM_M_GetImageData` | `modu_input->pImageInObj->GetImageData(0)->pData` |
| `VM_M_SetOutputImage` | `VmModule_OutputImageByName_8u_C1R` / `_C3R` |
| `VM_M_DestroyImage` | 共享内存由 SDK 管理，**不需要**手动销毁 |
| `VM_M_CopyImage` | `memcpy_s(dst, dstLen, src, srcLen)` |
| `VM_M_SetIntValue` / `VM_M_SetFloatValue` / `VM_M_SetStringValue` | `VM_M_SetInt(hOutput, name, nIndex, value)` / `SetFloat` / `SetString`（4 参） |
| `VM_M_GetIntValue` / `VM_M_GetFloatValue` | `VM_M_GetInt(hInput, name, nIndex, &val, &count)`（5 参） |
| `VM_M_SetParam(hOutput, ...)` | 运行参数走成员函数 `CAlgorithmModule::SetParam(szName, pData, nLen)` |
| `VM_M_GetLine` / `VM_M_SetLine` | `VM_M_GetFloat/VM_M_SetFloat` 逐分量(StartX/StartY/EndX/EndY × 4) |
| `VM_M_GetRect` / `VM_M_SetRect` | `VM_M_GetFloat/VM_M_SetFloat` 逐分量(CenterX/CenterY/Width/Height/Angle × 5) |
| `VmModule_GetInputRoiBox` | `VM_M_GetFloat` 逐分量读取矩形分量——SDK 复合接口,几何参数**不应使用** |
| `VmModule_OutputVector_BoxF` | `VM_M_SetFloat` 逐分量输出矩形分量——SDK 复合接口,几何参数**不应使用** |
| `VmModule_OutputVector_PointF` | `VM_M_SetFloat` 逐分量输出点分量——SDK 复合接口,几何参数**不应使用**。批量检测点(轮廓/角点)不受此限 |
| `VM_M_GetPoint` / `VM_M_SetPoint` | **编造**（不存在）—— 用 `VM_M_GetFloat/VM_M_SetFloat` 逐分量(CenterX/CenterY × 2) |
| `VM_M_GetCircle` / `VM_M_SetCircle` | **编造**（不存在）—— 用 `VM_M_GetFloat/VM_M_SetFloat` 逐分量(CenterX/CenterY/InnerRadius/Radius/StartAngle/AngleExtend × 6) |
| `IMVS_EC_NOMEM` | `IMVS_EC_OUTOFMEMORY` 或 `IMVS_EC_RESOURCE_CREATE` |
| `VmModule_GetInputImageEx(hInput, "InImage", &pImage)` | `VmModule_GetInputImageEx(hInput, &pImage, nLen, pSharedName, &status)` |
| `AlgCommon_TimeMilliseconds` / `clock()` / `std::chrono::*` 计时 | `MyMilliseconds()`（模板 `AlgorithmModule.h` 内联定义，**唯一**正确写法） |

## 真实接口签名（来自 `templates/AlgTemplate/common/`）

### 图像输入（深拷贝）
```cpp
char* pSharedName = NULL;
int nErrCode = AllocateSharedMemory(m_nModuleId, nLen, (char**)(&pImage.data), &pSharedName);
if (nErrCode != IMVS_EC_OK) return IMVS_EC_RESOURCE_CREATE;
memcpy_s(pImage.data[0], nLen,
         modu_input->pImageInObj->GetImageData(0)->pData,
         modu_input->pImageInObj->GetImageData(0)->nSize);
```

### 图像输入（浅拷贝）
```cpp
char pSharedName[128] = { 0 };
int status;
VmModule_GetInputImageEx(hInput, &pImage, nLen, pSharedName, &status);
```

### 图像输出
```cpp
// 自己已深拷贝 → bDeepCopy=0；浅拷贝且想输出原图 → bDeepCopy=1
VmModule_OutputImageByName_8u_C1R(hOutput, 1, "OutImage", "OutImageWidth",
    "OutImageHeight", "OutImagePixelFormat", &pImage, 0, pSharedName);
VmModule_OutputImageByName_8u_C3R(hOutput, 1, "OutImage", "OutImageWidth",
    "OutImageHeight", "OutImagePixelFormat", &pImage, 0, pSharedName);
```

### 标量输出
```cpp
VM_M_SetInt(hOutput,    "ModuStatus",  0, 1);          // 4 参
VM_M_SetFloat(hOutput,  "OutFloat",    0, 3.14f);      // 4 参
VM_M_SetString(hOutput, "OutStr",      0, str.c_str());// 4 参（无 length）
```

### 模块耗时
**注意**：`MyMilliseconds()` 不是 SDK 接口，而是模板的 `AlgorithmModule.h` 第 39 行**内联定义**（用 `QueryPerformanceCounter` 实现）。不要写 `AlgCommon_TimeMilliseconds`（编造）或 `clock()`/`std::chrono`（与模板不一致）。

```cpp
double fStart = MyMilliseconds();  // Process 入口（定义见 AlgorithmModule.h）
// ... 算法 ...
MODULE_RUNTIME_INFO struRunInfo = { 0 };
struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);
```

## OutputDebugStringA in DLL entry functions (exception)

`OutputDebugStringA` is blacklisted in algorithm-layer code (Process/GetParam/SetParam), but it is **allowed** in `CreateModule` and `DestroyModule` — these are global C entry functions that have `m_hModule` but NOT `m_nModuleId`, so they cannot use `MLOG_*`.

```cpp
// Correct — DLL entry functions may use OutputDebugStringA
LINEMODULE_API CAbstractUserModule* __stdcall CreateModule(void* hModule)
{
    // ...
    OutputDebugStringA("###Call CreateModule");  // OK here
    return pUserModule;
}
```

**Do NOT** replace `OutputDebugStringA` with `MLOG_*(m_nModuleId, ...)` in CreateModule/DestroyModule — `m_nModuleId` is not in scope at global scope.

## 落盘后强制 grep 自检命令

```bash
# 1. 黑名单扫描（命中任何一条 → 必须回滚改写）
grep -nE "VM_M_GetImageInfo|VM_M_CreateImage|VM_M_GetImageData|VM_M_SetOutputImage|VM_M_DestroyImage|VM_M_CopyImage|VM_M_SetIntValue|VM_M_SetFloatValue|VM_M_SetStringValue|VM_M_GetIntValue|VM_M_GetFloatValue|VM_M_GetLine|VM_M_SetLine|VM_M_GetRect|VM_M_SetRect|VM_M_GetPoint|VM_M_SetPoint|VM_M_GetCircle|VM_M_SetCircle|VmModule_OutputVector_BoxF|VmModule_GetInputRoiBox|VmModule_OutputVector_PointF|IMVS_EC_NOMEM|AlgCommon_TimeMilliseconds" <模块>/AlgorithmModule.cpp <模块>/AlgorithmModule.h

# 2. 必备接口存在性检查（缺失任一 → 必须补全）
grep -n "MyMilliseconds"      <模块>/AlgorithmModule.cpp  # 计时入口
grep -n "VM_M_SetModuleRuntimeInfo"       <模块>/AlgorithmModule.cpp  # 计时输出
grep -n "VmModule_OutputImageByName"      <模块>/AlgorithmModule.cpp  # 图像输出（有图像输出时）

# 3. 拷贝策略一致性（修改像素的算法必须深拷贝）
grep -n "AllocateSharedMemory"            <模块>/AlgorithmModule.cpp  # 深拷贝
grep -n "VmModule_GetInputImageEx"        <模块>/AlgorithmModule.cpp  # 浅拷贝
# 二值化/滤波/形态学/绘制类 → 必须有 AllocateSharedMemory + memcpy_s
```

## 头文件位置（grep 验证真实接口的去处）

- `templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common/VM400/include/VmModuleFrame/VmModuleBase.h` — `VM_M_Get*/Set*` / `VM_M_SetModuleRuntimeInfo`
- `templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common/src/VmModule_IO.h` — `VmModule_GetInputImageEx` / `OutputImageByName_*` / `GetInputRoiBox` / `OutputVector_*`
- `templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common/src/VmModuleSharedMemoryBase.h` — `AllocateSharedMemory`
- `templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common/src/VmAlgModuBase.h` — `CVmAlgModuleBase` 基类
- `templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/AlgTemplate/AlgorithmModule.h` — `MyMilliseconds`（模板内联,**非 SDK 接口**;切勿写成 `AlgCommon_TimeMilliseconds`）
- `templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common/src/ErrorCodeDefine.h` — `IMVS_EC_*`
- `templates/AlgTemplate/AlgTemplate_CProj/AlgTemplate/common/src/HSlog/HSlogDefine.h` — `MLOG_*`

**不确定某接口是否存在 → 立即 grep 上述头文件 → grep 不到就向用户报告"SDK 无对应接口"，绝不编造**。
