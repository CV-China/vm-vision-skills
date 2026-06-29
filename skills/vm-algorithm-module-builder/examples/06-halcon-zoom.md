# 示例 06 —— HALCON 集成（图像缩放）

## 场景
模块接收 1 张灰度图，调用 HALCON `ZoomImageFactor` 按比例缩放，输出缩放后的图像。

## 前置条件（必须先与用户确认）

- HALCON 头文件目录（如 `E:\HalconRuntime\include`，需同时包含 `halconcpp` 子目录）
- HALCON 库目录（如 `E:\HalconRuntime\lib\x64-win64`）
- .lib 名称（`halconcpp.lib`）
- 运行时 dll 目录（`halcon.dll` / `halconcpp.dll` 所在目录）
- HALCON 版本（如 20.11 / 23.05）

详见 [../references/third-party-libs.md](../references/third-party-libs.md)。

## `.vcxproj` 修改要点

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <IncludePath>E:\HalconRuntime\include;E:\HalconRuntime\include\halconcpp;$(IncludePath)</IncludePath>
    <LibraryPath>E:\HalconRuntime\lib\x64-win64;$(LibraryPath)</LibraryPath>
</PropertyGroup>
<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <ClCompile>
        <!-- ⚠️ 必须关闭预编译头：HALCON 头文件与 stdafx.h 冲突 -->
        <PrecompiledHeader>NotUsing</PrecompiledHeader>
        <AdditionalIncludeDirectories>
            ..\common\src;..\common;..\common\VM400\include\VmModuleFrame;..\common\SDK\Includes\Algorithms;..\common\SDK\Includes\Common\VisionDesigner;%(AdditionalIncludeDirectories)
        </AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
        <AdditionalLibraryDirectories>
            ..\common\include\lib;..\common\VM400\lib;..\common\SDK\Libraries\x64\Algorithms;..\common\SDK\Libraries\x64\Common;%(AdditionalLibraryDirectories)
        </AdditionalLibraryDirectories>
        <AdditionalDependencies>
            ModuleFrame.lib;MVDShapeCpp.lib;MVDImageCpp.lib;MVDPositionFixCpp.lib;MVDPreproMaskCpp.lib;HSlog.lib;halconcpp.lib;%(AdditionalDependencies)
        </AdditionalDependencies>
    </Link>
</ItemDefinitionGroup>
```

## 运行参数（`AlgorithmTab.xml` / `Algorithm.xml`）

```xml
<Float Name="scaleWidth" NameSpace="Standard">
    <DisplayName>宽度缩放比例</DisplayName>
    <MinValue>0.001</MinValue><MaxValue>100</MaxValue><CurValue>1</CurValue><IncValue>0.1</IncValue>
    <AccessMode>RW</AccessMode>
</Float>
<Float Name="scaleHeight" NameSpace="Standard">
    <DisplayName>高度缩放比例</DisplayName>
    <MinValue>0.001</MinValue><MaxValue>100</MaxValue><CurValue>1</CurValue><IncValue>0.1</IncValue>
    <AccessMode>RW</AccessMode>
</Float>
<Enumeration Name="interpolation" NameSpace="Standard">
    <DisplayName>插值方式</DisplayName>
    <EnumEntrys>
        <EnumEntry Name="nearest_neighbor"><Value>1</Value><DisplayName>最近邻</DisplayName></EnumEntry>
        <EnumEntry Name="bilinear"><Value>2</Value><DisplayName>双线性</DisplayName></EnumEntry>
        <EnumEntry Name="constant"><Value>3</Value><DisplayName>恒定</DisplayName></EnumEntry>
    </EnumEntrys>
    <CurValue>1</CurValue>
    <AccessMode>RW</AccessMode>
</Enumeration>
<Integer Name="DeviceType" NameSpace="Standard">
    <DisplayName>加速设备</DisplayName>
    <MinValue>1</MinValue><MaxValue>4</MaxValue><CurValue>1</CurValue><IncValue>1</IncValue>
    <AccessMode>RW</AccessMode>
</Integer>
```

## Process 关键代码

### AlgorithmModule.h —— 声明

```cpp
#include "HalconCpp.h"

using namespace std;
using namespace HalconCpp;

class LINEMODULE_API CAlgorithmModule : public CVmAlgModuleBase, public CModuleSharedMemoryBase
{
public:
    int Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input);
    int GetParam(IN const char* szParamName, OUT char* pBuff, IN int nBuffSize, OUT int* pDataLen);
    int SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen);

private:
    // IMvdImage → Halcon HObject（浅拷贝，不复制像素数据）
    int ConvertMvdImage2Halcon_ShallowCopy(IN IMvdImage* pMvdImg, INOUT HObject* pHObject);

    // Halcon HImage → HKA_IMAGE（深拷贝，输出场景用）
    int HImage2HKAIMAGE(HImage himage, INOUT HKA_IMAGE hka_Image);

    // 运行参数成员
    float    m_fscaleWidth;
    float    m_fscaleHeight;
    int      m_ninterpolation;
    int      m_ndeviceType;
    const char* m_cInterpolation;   // Halcon 插值字符串

    // Halcon 对象（成员变量，避免每次 Process 重复构造）
    HalconCpp::HImage  ho_Image, ho_ImageZoomed;
    HalconCpp::HTuple  hv_Zoom_Width, hv_Zoom_Height;
    HKA_IMAGE          Image_Zoomed;
};
```

### AlgorithmModule.cpp —— Process

```cpp
#include "AlgorithmModule.h"
#include "ErrorCodeDefine.h"
#include "iMVS-6000PixelFormatDefine.h"

int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
    int     nRet = IMVS_EC_OK;
    double  fStart = MyMilliseconds();

    try
    {
        // === 1. IMvdImage → Halcon HObject（浅拷贝，零拷贝） ===
        nRet = ConvertMvdImage2Halcon_ShallowCopy(modu_input->pImageInObj, &ho_Image);
        HKA_CHECK_ERROR(IMVS_EC_OK != nRet, nRet);

        // === 2. 仅支持单通道灰度图 ===
        if (1 != ho_Image.CountChannels()[0].I())
        {
            return IMVS_EC_ALGORITHM_IMG_FORMAT;
        }

        // === 3. Halcon 算法：缩放 ===
        ZoomImageFactor(ho_Image, &ho_ImageZoomed,
            m_fscaleWidth, m_fscaleHeight, m_cInterpolation);

        // === 4. HImage → HKA_IMAGE（深拷贝到共享内存） ===
        // 4.1 获取缩放后图像的指针和属性
        HTuple hv_Pointer, hv_Type;
        GetImagePointer1(ho_ImageZoomed, &hv_Pointer, &hv_Type,
            &hv_Zoom_Width, &hv_Zoom_Height);

        // 4.2 计算数据大小
        int nWidth  = hv_Zoom_Width[0].I();
        int nHeight = hv_Zoom_Height[0].I();
        int nDataSize = nWidth * nHeight;

        // 4.3 分配共享内存
        char* pSharedName = NULL;
        nRet = AllocateSharedMemory(m_nModuleId, nDataSize,
            (char**)(&Image_Zoomed.data), &pSharedName);
        HKA_CHECK_ERROR(IMVS_EC_OK != nRet, nRet);

        // 4.4 填充 HKA_IMAGE 结构体
        Image_Zoomed.format   = HKA_IMG_MONO_08;
        Image_Zoomed.width    = nWidth;
        Image_Zoomed.height   = nHeight;
        Image_Zoomed.step[0]  = nWidth;

        // 4.5 从 Halcon 指针拷贝像素数据
        memcpy_s(Image_Zoomed.data[0], nDataSize,
            (void*)hv_Pointer[0].L(), nDataSize);

        // === 5. 输出到 VM ===
        VM_M_SetInt(hOutput, "ModuStatus", 0, 1);
        VmModule_OutputImageByName_8u_C1R(hOutput, 1,
            "OutImage", "OutImageWidth", "OutImageHeight", "OutImagePixelFormat",
            &Image_Zoomed, 0, pSharedName);
    }
    catch (HException& ex)
    {
        MLOG_ERROR(m_nModuleId, "Halcon error.Fail with ErrorMessage: %s,Fail with ErrorCode: %d.",
            ex.ErrorMessage().Text(), ex.ErrorCode());
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        return IMVS_EC_UNKNOWN;
    }
    catch (std::exception& ex)
    {
        MLOG_ERROR(m_nModuleId, "Standard C++ error.Fail with ErrorMessage: %s.", ex.what());
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        return IMVS_EC_UNKNOWN;
    }
    catch (...)
    {
        MLOG_ERROR(m_nModuleId, "Unknown error.");
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        return IMVS_EC_UNKNOWN;
    }

    MODULE_RUNTIME_INFO struRunInfo = { 0 };
    struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
    VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);
    return IMVS_EC_OK;
}
```

### AlgorithmModule.cpp —— IMvdImage → Halcon HObject（浅拷贝）

```cpp
int CAlgorithmModule::ConvertMvdImage2Halcon_ShallowCopy(
    IN IMvdImage* pMvdImg, INOUT HObject* pHObject)
{
    if (NULL == pMvdImg || NULL == pHObject)
    {
        MLOG_ERROR(m_nModuleId, "InputImage is empty.");
        return IMVS_EC_ALGORITHM_IMG_DATA_NULL;
    }

    try
    {
        MVD_PIXEL_FORMAT enPixelFormat = pMvdImg->GetPixelFormat();
        int nWidth  = pMvdImg->GetWidth();
        int nHeight = pMvdImg->GetHeight();

        if (MVD_PIXEL_MONO_08 == enPixelFormat)
        {
            // 灰度图：GenImage1Extern 直接引用 MVDImage 内存（零拷贝）
            if (nWidth * nHeight == pMvdImg->GetImageData(0)->nLen)
            {
                GenImage1Extern(pHObject, "byte",
                    nWidth, nHeight,
                    (Hlong)pMvdImg->GetImageData(0)->pData,
                    (Hlong)0);
            }
            else
            {
                return IMVS_EC_ALGORITHM_IMG_SIZE;
            }
        }
        else if (MVD_PIXEL_RGB_RGB24_C3 == enPixelFormat)
        {
            // 彩色图：GenImageInterleaved 直接引用交错 RGB 数据（零拷贝）
            void* pSrcData = pMvdImg->GetImageData(0)->pData;
            GenImageInterleaved(pHObject,
                (Hlong)pSrcData, "rgb",
                nWidth, nHeight, -1, "byte",
                nWidth, nHeight, 0, 0, -1, 0);
        }
        else
        {
            MLOG_ERROR(m_nModuleId, "Pixel format not supported.");
            return IMVS_EC_ALGORITHM_IMG_FORMAT;
        }
    }
    catch (HalconCpp::HException& ex)
    {
        MLOG_ERROR(m_nModuleId, "Halcon error.Fail with ErrorMessage: %s,Fail with ErrorCode: %d.",
            ex.ErrorMessage().Text(), ex.ErrorCode());
        return IMVS_EC_ALGORITHM_INPUT_IMAGE_ERROR;
    }
    catch (std::exception& ex)
    {
        MLOG_ERROR(m_nModuleId, "Standard C++ error.Fail with ErrorMessage: %s.", ex.what());
        return IMVS_EC_ALGORITHM_INPUT_IMAGE_ERROR;
    }
    catch (...)
    {
        MLOG_ERROR(m_nModuleId, "Unknown error.");
        return IMVS_EC_ALGORITHM_INPUT_IMAGE_ERROR;
    }
    return IMVS_EC_OK;
}
```

### AlgorithmModule.cpp —— GetParam / SetParam

```cpp
int CAlgorithmModule::GetParam(IN const char* szParamName, OUT char* pBuff,
    IN int nBuffSize, OUT int* pDataLen)
{
    if (0 == strcmp("scaleWidth", szParamName))
        sprintf_s(pBuff, nBuffSize, "%f", m_fscaleWidth);
    else if (0 == strcmp("scaleHeight", szParamName))
        sprintf_s(pBuff, nBuffSize, "%f", m_fscaleHeight);
    else if (0 == strcmp("interpolation", szParamName))
        sprintf_s(pBuff, nBuffSize, "%d", m_ninterpolation);
    else if (0 == strcmp("DeviceType", szParamName))
        sprintf_s(pBuff, nBuffSize, "%d", m_ndeviceType);
    else
        return CVmAlgModuleBase::GetParam(szParamName, pBuff, nBuffSize, pDataLen);
    return IMVS_EC_OK;
}

int CAlgorithmModule::SetParam(IN const char* szParamName, IN const char* pData,
    IN int nDataLen)
{
    if (0 == strcmp("scaleWidth", szParamName))
        sscanf_s(pData, "%f", &m_fscaleWidth);
    else if (0 == strcmp("scaleHeight", szParamName))
        sscanf_s(pData, "%f", &m_fscaleHeight);
    else if (0 == strcmp("interpolation", szParamName))
    {
        sscanf_s(pData, "%d", &m_ninterpolation);
        // 将枚举数值映射为 Halcon 插值字符串
        switch (m_ninterpolation)
        {
        case 1: m_cInterpolation = "nearest_neighbor"; break;
        case 2: m_cInterpolation = "bilinear";         break;
        case 3: m_cInterpolation = "constant";          break;
        default: m_cInterpolation = "nearest_neighbor"; break;
        }
    }
    else if (0 == strcmp("DeviceType", szParamName))
        sscanf_s(pData, "%d", &m_ndeviceType);
    else
        return CVmAlgModuleBase::SetParam(szParamName, pData, nDataLen);
    return IMVS_EC_OK;
}
```

## 注意事项

- **关闭预编译头**：HALCON 头文件（`HalconCpp.h`）与 `stdafx.h` 预编译头机制冲突，`AlgorithmModule.cpp` 中 `#include "stdafx.h"` 改为 `#include "AlgorithmModule.h"`，vcxproj 必须设置 `<PrecompiledHeader>NotUsing</PrecompiledHeader>`
- **浅拷贝 vs 深拷贝**：输入侧用 `GenImage1Extern`（零拷贝，直接引用 MVDImage 内存），输出侧需要 `AllocateSharedMemory` + `memcpy_s`（VM 共享内存生命周期管理）
- **HException 必须单独 catch**：HALCON 异常类型为 `HalconCpp::HException`，需在 `std::exception` 之前捕获，否则会被 `std::exception` 吞掉
- **`HKA_CHECK_ERROR` 宏**：模板 SDK 提供的错误检查宏，等价于 `if (condition) { return errorCode; }`，可简化错误分支
- **彩色图支持**：灰度图用 `GenImage1Extern`，RGB 交错格式用 `GenImageInterleaved`；Planar RGB 需手动分通道后 `GenImage3`
- **GPU 加速**：如需 HALCON GPU 加速，在 `Init()` 或构造函数中调 `QueryAvailableComputeDevices` → `OpenComputeDevice` → `ActivateComputeDevice`，并在析构函数中 `DeactivateComputeDevice`
- **用户编译完成后**必须将 `halcon.dll` / `halconcpp.dll` 复制到 VM 的 `Applications\PublicFile\x64\` 或加入系统 PATH
- **深拷贝备选**：如需修改 Halcon 图像（非缩放等纯读取场景），改用 `GenImage1`（灰度）/ `GenImage3`（RGB Planar），Halcon 内部会自动拷贝数据，避免污染上游 MVDImage
