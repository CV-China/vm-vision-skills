# Process 函数骨架与重载规则

`AlgorithmModule.cpp` 中的 `Process` 是算法模块的**核心入口**。根据**输入形态**有两种声明方式。

## 标准 3 参数 Process（有图像输入）

> **拷贝策略决策(必做)**:Process 内访问图像数据前,先判断算法是否会**修改**像素:
> - 修改像素(二值化/滤波/形态学/绘制) → **深拷贝**(见骨架 A) + Output `bDeepCopy=false`
> - 仅读取(检测/统计/匹配) → **浅拷贝**(见骨架 B) + Output 若输出原图 `bDeepCopy=true`
> - 不能推断 → 默认深拷贝或询问用户(详见 [../SKILL.md §G](../SKILL.md))

### 骨架 A:深拷贝(算法会修改图像数据)

```cpp
int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
    int nErrCode = IMVS_EC_OK;
    int errorStatus = 0;  // VM 模块状态：0=NG, 1=OK
    double fStart = MyMilliseconds();

    try
    {
        // === 1. 获取输入图像（深拷贝，VM431+） ===
        HKA_IMAGE pImage;
        pImage.height = modu_input->pImageInObj->GetHeight();
        pImage.width  = modu_input->pImageInObj->GetWidth();
        int nLen = pImage.height * pImage.width;
        if (MVD_PIXEL_RGB_RGB24_C3 == modu_input->pImageInObj->GetPixelFormat())
        {
            pImage.format = HKA_IMG_RGB_RGB24_C3;
            nLen = pImage.height * pImage.width * 3;
        }
        else
        {
            pImage.format = HKA_IMG_MONO_08;  // 默认灰度格式
        }
        char* pSharedName = NULL;
        nErrCode = AllocateSharedMemory(m_nModuleId, nLen,
                                        (char**)(&pImage.data), &pSharedName);
        if (nErrCode != IMVS_EC_OK) {
            MLOG_ERROR(m_nModuleId, "AllocateSharedMemory failed: 0x%x", nErrCode);
            return IMVS_EC_RESOURCE_CREATE;
        }
        memcpy_s(pImage.data[0], nLen,
                 modu_input->pImageInObj->GetImageData(0)->pData,
                 modu_input->pImageInObj->GetImageData(0)->nSize);

        // === 2. 生成掩膜图像（ROI + 屏蔽区） —— 仅启用 ROI 时调用 ===
        // 用户描述含 "在 ROI 内 / 支持 ROI / 屏蔽区" → 保留该调用
        // 用户未提 ROI / 默认全图处理 → 删除该调用,后续循环不查 pImgDataMask
        GenerateMaskImage(modu_input,
                          modu_input->vtFixRoiShapeObj,
                          modu_input->vctfixShieldedPolygon);

        // === 3. 算法核心处理（占位 / 由用户实现 / 由脚本翻译） ===
        // ★ 仅启用 ROI 时(用户描述含 ROI/屏蔽区)使用 pImgDataMask 判断;
        //   未启用 ROI 时直接全图循环,不要套 pImgDataMask 判断(多余开销)。
        // === 启用 ROI 版(二值化, switch+阈值化类型)——基础双重循环: ===
        // unsigned char* pImgData     = (unsigned char*)pImage.data[0];
        // unsigned char* pImgDataMask = (unsigned char*)modu_input->pImageMaskObj->GetImageData(0)->pData;
        // int rows = pImage.height;
        // int cols = pImage.width;
        // if (MVD_PIXEL_MONO_08 == modu_input->pImageInObj->GetPixelFormat())
        // {
        //     for (int row = 0; row < rows; row++) {
        //         for (int col = 0; col < cols; col++) {
        //             int pos = col + row * cols;
        //             if (pImgDataMask[pos] == 255) {
        //                 switch (m_nthresholdType) {
        //                 case 1:  // BINARY:大于阈值→255,否则→0
        //                     pImgData[pos] = (pImgData[pos] > m_nthresholdValue) ? 255 : 0;
        //                     break;
        //                 case 2:  // BINARY_INV:大于阈值→0,否则→255
        //                     pImgData[pos] = (pImgData[pos] > m_nthresholdValue) ? 0 : 255;
        //                     break;
        //                 }
        //             }
        //         }
        //     }
        // }
        //
        // === 未启用 ROI 版（默认全图处理）: 删 GenerateMaskImage 调用 + 不查 mask ===
        // unsigned char* pImgData = (unsigned char*)pImage.data[0];
        // int rows = pImage.height;
        // int cols = pImage.width;
        // if (MVD_PIXEL_MONO_08 == modu_input->pImageInObj->GetPixelFormat())
        // {
        //     for (int i = 0; i < rows * cols; i++) {
        //         switch (m_nthresholdType) {
        //         case 1: pImgData[i] = (pImgData[i] > m_nthresholdValue) ? 255 : 0; break;
        //         case 2: pImgData[i] = (pImgData[i] > m_nthresholdValue) ? 0 : 255; break;
        //         }
        //     }
        // }
        // 性能优化变体(单循环 / OpenMP / OpenMP+AVX2)见同目录 io-params/input-image.txt
        // **绝不输出 ROI**:不要 VM_M_Set*(hOutput, "OutROI", ...) —— 模块基类自动回显

        // === 4. 输出结果 ===
        errorStatus = 1;  // 算法成功
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);

        // 输出图像（按像素格式分支）
        if (MVD_PIXEL_MONO_08 == modu_input->pImageInObj->GetPixelFormat()) {
            VmModule_OutputImageByName_8u_C1R(hOutput, 1,
                "OutImage", "OutImageWidth", "OutImageHeight", "OutImagePixelFormat",
                &pImage, /*bDeepCopy*/ false, pSharedName);
        } else if (MVD_PIXEL_RGB_RGB24_C3 == modu_input->pImageInObj->GetPixelFormat()) {
            VmModule_OutputImageByName_8u_C3R(hOutput, 1,
                "OutImage", "OutImageWidth", "OutImageHeight", "OutImagePixelFormat",
                &pImage, /*bDeepCopy*/ false, pSharedName);
        }

        // 其他输出（按基本参数清单生成对应 VM_M_Set*）
        // VM_M_SetInt(hOutput,    "OutValue", 0, intResult);
        // VM_M_SetFloat(hOutput,  "OutFloat", 0, floatResult);
        // VM_M_SetString(hOutput, "OutStr",   0, strResult.c_str());  // 注意:VM_M_SetString 只接 4 参,不带 length
    }
    catch (const std::exception& e)
    {
        MLOG_ERROR(m_nModuleId, "Process exception: %s", e.what());
        errorStatus = 0;
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);
        nErrCode = IMVS_EC_PARAM;
    }
    catch (...)
    {
        MLOG_ERROR(m_nModuleId, "Process unknown exception.");
        errorStatus = 0;
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);
        nErrCode = IMVS_EC_PARAM;
    }

    // === 5. 写运行耗时 ===
    MODULE_RUNTIME_INFO struRunInfo = { 0 };
    struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
    VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);

    return nErrCode;
}
```

## 关键约束（编译/运行）

| 约束 | 不可违反原因 |
|---|---|
| `try/catch + errorStatus` 必须包裹 | 算法异常未捕获会导致 VM 闪退 |
| 日志只能用 `MLOG_*` | 编译期不会失败但运行时无日志记录 |
| 传入 VM SDK 的中文参数名/值必须加 `u8`（原因见 SKILL.md §J）；MLOG 中文同理；纯本地中文见 §J Python GB2312 备选方案 | 否则日志/UI 乱码 |
| 浅拷贝改写图像数据前必须深拷贝 | 浅拷贝直接改会污染前后模块 |
| `VM_M_SetModuleRuntimeInfo` 必须调用 | 不调用则 VM 无法统计模块耗时 |
| **SDK 调用失败必须 `return nErrCode` 传播具体错误码**，不得改写为 `IMVS_EC_PARAM` | SDK 返回的 `nErrCode` 已是 `ErrorCodeDefine.h` 中定义的已知错误码（如 `IMVS_EC_MODULE_SUB_RST_NOT_FOUND`）。改写为通用码会丢失根因信息，导致用户无法排查。`IMVS_EC_PARAM` 仅用于纯参数校验失败或 catch(...) 异常捕获 |

### 骨架 B:浅拷贝(算法只读取图像数据,如直线检测/缺陷检测/特征匹配)

```cpp
int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
    int nErrCode = IMVS_EC_OK;
    int errorStatus = 0;
    double fStart = MyMilliseconds();

    try
    {
        // === 1. 浅拷贝:直接引用平台图像内存,绝不写入 ===
        const unsigned char* pSrcData = modu_input->pImageInObj->GetImageData(0)->pData;
        int nWidth  = modu_input->pImageInObj->GetWidth();
        int nHeight = modu_input->pImageInObj->GetHeight();
        int nFormat = modu_input->pImageInObj->GetPixelFormat();

        // === 2. 生成掩膜 —— 仅启用 ROI 时调用(未启用 ROI 时整段删除) ===
        GenerateMaskImage(modu_input, modu_input->vtFixRoiShapeObj,
                          modu_input->vctfixShieldedPolygon);
        const unsigned char* pMask = modu_input->pImageMaskObj->GetImageData(0)->pData;

        // === 3. 算法核心(只读,不写 pSrcData) ===
        // 例如检测直线/缺陷:遍历 pSrcData 累计统计量,得 outPoints / outBoxes
        std::vector<HKA_POINT_F> outPoints;
        // for (int i = 0; i < nHeight * nWidth; ++i) { if (pMask[i]==255) {...} }

        // === 4. 输出几何结果(无图像输出场景) ===
        errorStatus = 1;
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);
        // 注意:VmModule_OutputVector_PointF 仅用于输出批量检测点(如轮廓/角点)。
        // 对于 XML 中定义为 POINT/ROIBOX/LINE/ROIANNULUS Combination 的几何基本参数，
        // 必须用 VM_M_SetFloat 逐分量输出(X/Y/Width 等),不要用此接口。
        VmModule_OutputVector_PointF(hOutput, 1, outPoints.data(),
                                     "OutPoints", (HKA_S32)outPoints.size());

        // === 4'. 若仍需把"原图"输出给下游(浅拷贝场景下,bDeepCopy=true 让 SDK 复制)===
        // HKA_IMAGE shallowImg;
        // shallowImg.height = nHeight; shallowImg.width = nWidth;
        // shallowImg.format = (nFormat == MVD_PIXEL_RGB_RGB24_C3)
        //                     ? HKA_IMG_RGB_RGB24_C3 : HKA_IMG_MONO_08;
        // shallowImg.data[0] = (HKA_U8*)pSrcData;
        // VmModule_OutputImageByName_8u_C1R(hOutput, 1,
        //     "OutImage", "OutImageWidth", "OutImageHeight", "OutImagePixelFormat",
        //     &shallowImg, /*bDeepCopy*/ true, /*pSharedMemoryName*/ NULL);
    }
    catch (const std::exception& e) {
        MLOG_ERROR(m_nModuleId, "Process exception: %s", e.what());
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        nErrCode = IMVS_EC_PARAM;
    }
    catch (...) {
        MLOG_ERROR(m_nModuleId, "Process unknown exception.");
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        nErrCode = IMVS_EC_PARAM;
    }

    MODULE_RUNTIME_INFO struRunInfo = { 0 };
    struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
    VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);
    return nErrCode;
}
```

**浅拷贝铁律**:`pSrcData` 是 `const`,**禁止**写入。一旦改了一个字节,上游/共享内存会被污染。需要写入立刻改回骨架 A。

## 关键约束（编译/运行）

| 约束 | 不可违反原因 |
|---|---|
| 拷贝策略必须显式注释 | 浅拷贝改像素会污染上游;深拷贝忘检失败码会闪退 |
| `try/catch + errorStatus` 必须包裹 | 算法异常未捕获会导致 VM 闪退 |
| 日志只能用 `MLOG_*` | 编译期不会失败但运行时无日志记录 |
| 传入 VM SDK 的中文参数名/值必须加 `u8`（原因见 SKILL.md §J）；MLOG 中文同理；纯本地中文见 §J Python GB2312 备选方案 | 否则日志/UI 乱码 |
| 浅拷贝改写图像数据前必须深拷贝 | 浅拷贝直接改会污染前后模块 |
| Output `bDeepCopy` 必须与上游拷贝策略匹配 | 已自深拷贝 → false;浅拷贝输出原图 → true |
| `VM_M_SetModuleRuntimeInfo` 必须调用 | 不调用则 VM 无法统计模块耗时 |
| **SDK 调用失败必须 `return nErrCode` 传播具体错误码**，不得改写为 `IMVS_EC_PARAM` | SDK 返回的 `nErrCode` 已是已知错误码。改写为 `IMVS_EC_PARAM` 丢失根因。仅 catch(...) 或参数校验失败时用 `IMVS_EC_PARAM` |

## 输入形态影响的差异

⚠️ **铁律**：3 参数 `Process(hInput, hOutput, modu_input)` 是基类纯虚函数(`=0`)，必须实现。有图像模块只覆盖 3 参数版；无图像模块两版都声明，2 参数版写算法逻辑，3 参数版委托 `return Process(hInput, hOutput);`。完整规则见 [process-overload.md](process-overload.md)。

| 输入形态 | `.h` 声明 | `.cpp` 实现 |
|---|---|---|
| **单张图像输入**（默认） | **只**声明 3 参数 `Process(hInput, hOutput, modu_input)` | 标准骨架 A/B（如上） |
| **无图像输入** | 两个版本都声明。3 参数版是纯虚函数必须实现 | 2 参数版写算法逻辑,3 参数版委托 `return Process(hInput, hOutput);` |
| **多图像输入** | **只**声明 3 参数 `Process(hInput, hOutput, modu_input)` | 主图用 `modu_input->pImageInObj`,其他图用 `VmModule_GetInputImageByName(hInput, "InImage2", ...)` |

## 输出形态影响

| 输出形态 | Process 内调用 | XML 改动 |
|---|---|---|
| 单图像 | `VmModule_OutputImageByName_8u_C1R` 或 `_C3R` | `<模块名>.xml` 单 OutputImage |
| 多图像 | 多次调用上述接口，每次用独立 `共享内存名` | `<模块名>.xml` 多个 OutputImage Combination + `Display.xml` 多渲染节点 |
| 矩形 / 点集 / 直线 | `VM_M_Set*` 系列（详见 [cpp-api.md](cpp-api.md)） | `<模块名>.xml` 增对应 Combination + `Display.xml` 增对应 Object |

## 不要做的

- ❌ 在 Process 内 `new`/`malloc` 但不 `delete`/`free`（内存泄漏）
- ❌ 在 Process 内启用未询问过的 OpenMP/SIMD 优化（生成额外编译依赖）
- ❌ 假设输入图像永远是灰度（必须按 `GetPixelFormat()` 分支处理）
- ❌ 假设掩膜图像永远存在（无图像输入时不存在）
- ❌ 用 `OutputDebugStringA` 替代 `MLOG_*`（模板里有残留，须清理；**例外**：`CreateModule`/`DestroyModule` 这 2 个 DLL 入口函数允许保留 `OutputDebugStringA`，因为全局函数作用域下没有 `m_nModuleId` 可用，用 `MLOG_*` 会编译失败）
- ❌ **把 ROI 当作 Process 输出**:`VM_M_Set*` / `VmModule_OutputVector_BoxF` 输出 `OutROI`/`ROI`/`FixROI` —— 模块基类自动回显当前 ROI 与屏蔽区,**用户在 Process 里再输出一次属于重复+错误**(详见 [../SKILL.md §H](../SKILL.md))
- ❌ 算法循环对全图处理而不查 `pImgDataMask` —— "在 ROI 内处理"语义不成立
- ❌ 没调 `GenerateMaskImage` 就访问 `modu_input->pImageMaskObj`(数据为空)
