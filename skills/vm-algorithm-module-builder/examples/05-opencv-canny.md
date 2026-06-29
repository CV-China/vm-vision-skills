# 示例 05 —— OpenCV 集成（Canny 边缘检测）

## 场景
模块接收 1 张灰度图，调用 OpenCV `cv::Canny` 输出边缘图。

## 前置条件（必须先与用户确认）

- OpenCV 头文件目录（如 `D:\opencv\build\include`）
- OpenCV 库目录（如 `D:\opencv\build\x64\vc16\lib`）
- .lib 名称（如 `opencv_world460.lib`）
- 运行时 dll 目录
- OpenCV 版本

详见 [../references/third-party-libs.md](../references/third-party-libs.md)。

## `.vcxproj` 修改要点

```xml
<AdditionalIncludeDirectories>
    $(SolutionDir)common\src;$(SolutionDir)common\VM400\include\VmModuleFrame;D:\opencv\build\include;%(AdditionalIncludeDirectories)
</AdditionalIncludeDirectories>
<AdditionalLibraryDirectories>
    $(SolutionDir)common\VM400\lib\Win64;D:\opencv\build\x64\vc16\lib;%(AdditionalLibraryDirectories)
</AdditionalLibraryDirectories>
<AdditionalDependencies>
    VmModule_IO.lib;opencv_world460.lib;%(AdditionalDependencies)
</AdditionalDependencies>
```

## 运行参数（`AlgorithmTab.xml` / `Algorithm.xml`）

```xml
<Integer Name="cannyLow"  NameSpace="Standard">
    <DisplayName>低阈值</DisplayName>
    <MinValue>0</MinValue><MaxValue>255</MaxValue><CurValue>50</CurValue><IncValue>1</IncValue>
    <AccessMode>RW</AccessMode>
</Integer>
<Integer Name="cannyHigh" NameSpace="Standard">
    <DisplayName>高阈值</DisplayName>
    <MinValue>0</MinValue><MaxValue>255</MaxValue><CurValue>150</CurValue><IncValue>1</IncValue>
    <AccessMode>RW</AccessMode>
</Integer>
```

## Process 关键代码

```cpp
#include <opencv2/opencv.hpp>

int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
    int nErrCode = IMVS_EC_OK;
    int errorStatus = 0;
    double fStart = MyMilliseconds();

    try
    {
        // === 1. 输入图像 ===
        int h = modu_input->pImageInObj->GetHeight();
        int w = modu_input->pImageInObj->GetWidth();
        cv::Mat src(h, w, CV_8UC1,
                    modu_input->pImageInObj->GetImageData(0)->pData);

        // === 2. OpenCV 处理 ===
        cv::Mat dst;
        cv::Canny(src, dst, m_nCannyLow, m_nCannyHigh);

        // === 3. 输出到共享内存 ===
        HKA_IMAGE pImage;
        pImage.height = h; pImage.width = w; pImage.format = HKA_IMG_MONO_08;
        int nLen = h * w;
        char* pSharedName = NULL;
        AllocateSharedMemory(m_nModuleId, nLen, (char**)(&pImage.data), &pSharedName);
        memcpy_s(pImage.data[0], nLen, dst.data, dst.total() * dst.elemSize());

        errorStatus = 1;
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);
        VmModule_OutputImageByName_8u_C1R(hOutput, 1,
            "OutImage", "OutImageWidth", "OutImageHeight", "OutImagePixelFormat",
            &pImage, 0, pSharedName);
    }
    catch (const cv::Exception& e) {
        MLOG_ERROR(m_nModuleId, "OpenCV exception: %s", e.what());
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        nErrCode = IMVS_EC_PARAM;
    }
    catch (...) {
        MLOG_ERROR(m_nModuleId, "Unknown exception.");
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        nErrCode = IMVS_EC_PARAM;
    }

    MODULE_RUNTIME_INFO struRunInfo = { 0 };
    struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
    VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);
    return nErrCode;
}

int CAlgorithmModule::GetParam(IN const char* szParamName, OUT char* pBuff, IN int nBuffSize, OUT int* pDataLen)
{
    if (0 == strcmp("cannyLow", szParamName))
        sprintf_s(pBuff, nBuffSize, "%d", m_nCannyLow);
    else if (0 == strcmp("cannyHigh", szParamName))
        sprintf_s(pBuff, nBuffSize, "%d", m_nCannyHigh);
    else
        return CVmAlgModuleBase::GetParam(szParamName, pBuff, nBuffSize, pDataLen);
    return IMVS_EC_OK;
}

int CAlgorithmModule::SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen)
{
    if (0 == strcmp("cannyLow", szParamName))
        sscanf_s(pData, "%d", &m_nCannyLow);
    else if (0 == strcmp("cannyHigh", szParamName))
        sscanf_s(pData, "%d", &m_nCannyHigh);
    else
        return CVmAlgModuleBase::SetParam(szParamName, pData, nDataLen);
    return IMVS_EC_OK;
}
```

## 注意

- OpenCV 处理彩色图时改用 `CV_8UC3` 和 `HKA_IMG_RGB_RGB24_C3`
- 用户编译完成后必须将 `opencv_world460.dll` 复制到模块部署目录（与算法 .dll 同目录）
