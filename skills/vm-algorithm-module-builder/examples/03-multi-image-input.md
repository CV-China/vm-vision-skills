# 示例 03 —— 多图像输入

## 场景
模块接收 2 张图像（主图 + 参考图），输出比较结果。

## XML 关键差异（`<模块名>.xml` Input Category）

```xml
<Combination Name="InputImage" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageWidth"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageHeight"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImagePixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>
<Combination Name="InputImage2" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage2"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2Width"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2Height"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2PixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>
```

`<模块名>AlgorithmTab.xml` 的 `Tab_Image Source` 仍只使用主图（ImageSourceGroup 自动绑定 InputImage）；第二张图只在端口图上连接，无 UI 配置。

## Process 关键代码

```cpp
int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
    int nErrCode = IMVS_EC_OK;
    int errorStatus = 0;
    double fStart = MyMilliseconds();

    try
    {
        // === 主图像（深拷贝） ===
        HKA_IMAGE pImage1;
        pImage1.height = modu_input->pImageInObj->GetHeight();
        pImage1.width  = modu_input->pImageInObj->GetWidth();
        int nLen1 = pImage1.height * pImage1.width;
        pImage1.format = HKA_IMG_MONO_08;
        char* pSharedName1 = NULL;
        AllocateSharedMemory(m_nModuleId, nLen1, (char**)(&pImage1.data), &pSharedName1);
        memcpy_s(pImage1.data[0], nLen1,
                 modu_input->pImageInObj->GetImageData(0)->pData,
                 modu_input->pImageInObj->GetImageData(0)->nSize);

        // === 第二张图像(用 VmModule_GetInputImageByName,真实签名带 strW/strH/strFormat) ===
        HKA_IMAGE pImage2;
        char szShared2[256] = {0};
        int status2 = 0;
        int nErr2 = VmModule_GetInputImageByName(hInput,
                       "InImage2", "InImage2Width", "InImage2Height", "InImage2PixelFormat",
                       &pImage2, &status2, szShared2);
        if (nErr2 != IMVS_EC_OK) {
            MLOG_ERROR(m_nModuleId, "Get InImage2 failed: 0x%x", nErr2);
            return IMVS_EC_PARAM;
        }

        // === 算法核心处理（占位） ===
        // TODO: 比较两张图像，输出结果

        errorStatus = 1;
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);
        VmModule_OutputImageByName_8u_C1R(hOutput, 1,
            "OutImage", "OutImageWidth", "OutImageHeight", "OutImagePixelFormat",
            &pImage1, 0, pSharedName1);
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
