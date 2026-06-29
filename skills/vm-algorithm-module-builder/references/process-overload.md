# Process 函数重载规则（3 参数版是纯虚函数，必须实现）

## ⚠️ 铁律：3 参数 `Process(hInput, hOutput, modu_input)` 是基类 **纯虚函数**(`=0`)，必须实现

VM 模板自带两份 Process 声明（3 参数 + 2 参数）。3 参数版在基类 `VmAlgModuBase.h` 中声明为 `=0`，**不实现会编译报 C2259「无法实例化抽象类」**。2 参数版有基类默认实现，按需覆盖。

| 输入形态 | 策略 |
|---|---|
| 有图像输入 | 只覆盖 3 参数版（删除 2 参数版声明） |
| 无图像输入 | 两版都声明。2 参数版写算法逻辑，3 参数版委托 `return Process(hInput, hOutput);` |
| 多图像输入 | 只覆盖 3 参数版（内部多次 `VmModule_GetInputImageByName` 取不同图） |

| 实测后果 | 表现 |
|---|---|
| 有图像模块两个版本都写了独立逻辑 | VM 框架优先调用 2 参数版 → 3 参数版算法不被执行 |
| 无图像模块只写 2 参数版不写 3 参数版 | 编译报 `C2259: 无法实例化抽象类`（纯虚函数未实现） |

## 决策表

> 输入形态 vs Process 重载的完整决策表见 **SKILL.md §F**。下方规则 1/2/3 为对应的 `.h` / `.cpp` / XML 详细代码模板。

## 规则 1：单张图像输入（**最常见**）

### .h（只留 3 参数版）

```cpp
class LINEMODULE_API CAlgorithmModule : public CVmAlgModuleBase, public CModuleSharedMemoryBase
{
public:
    int Init();
    int Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input);
    int GetParam(IN const char* szParamName, OUT char* pBuff, IN int nBuffSize, OUT int* pDataLen);
    int SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen);
    // ...
};
```

⚠️ **如果模板原本有 `int Process(IN void* hInput, IN void* hOutput);` 这一行,必须删除**。

### .cpp 实现见 [process-function.md](process-function.md)

### XML
- `<模块名>.xml`：保留 `<Combination Name="InputImage" Style="IMAGE" ...>` 节点
- `<模块名>AlgorithmTab.xml`：保留 `<GroupLinkItem Name="ImageSourceGroup">` 和 `RoiSelectGroup`

## 规则 2：无图像输入（两个版本都声明，3 参数版委托到 2 参数版）

### .h —— 两个版本都声明（3 参数版是纯虚函数，必须声明）

```cpp
class LINEMODULE_API CAlgorithmModule : public CVmAlgModuleBase, public CModuleSharedMemoryBase
{
public:
    int Init();

    // 无图像输入：两个版本都声明。算法逻辑在 2 参数版，3 参数版委托调用。
    // 3 参数版是基类纯虚函数(=0)，必须实现，否则编译报 C2259 无法实例化抽象类。
    int Process(IN void* hInput, IN void* hOutput);
    int Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input);

    int GetParam(IN const char* szParamName, OUT char* pBuff, IN int nBuffSize, OUT int* pDataLen);
    int SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen);
};
```

### .cpp —— 2 参数版写算法逻辑，3 参数版委托

```cpp
int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput)
{
    int nErrCode = IMVS_EC_OK;
    int errorStatus = 0;
    double fStart = MyMilliseconds();

    try
    {
        // === 1. 获取输入参数（非图像） ===
        // 注意 VM_M_Get* 真实签名: (hInput, szName, nIndex, &val, &count) — 见 cpp-api.md

        // === 2. 算法处理 ===
        // TODO: 用户实现 / 脚本翻译插入此处

        // === 3. 输出结果 ===
        errorStatus = 1;
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);
    }
    catch (const std::exception& e)
    {
        MLOG_ERROR(m_nModuleId, "Process exception: %s", e.what());
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        nErrCode = IMVS_EC_PARAM;
    }
    catch (...)
    {
        MLOG_ERROR(m_nModuleId, "Process unknown exception.");
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        nErrCode = IMVS_EC_PARAM;
    }

    MODULE_RUNTIME_INFO struRunInfo = { 0 };
    struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
    VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);

    return nErrCode;
}

// 3 参数版是基类纯虚函数(=0)，必须实现。无图像模块直接委托到 2 参数版。
int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
    return Process(hInput, hOutput);
}
```

### XML 同步改动

`<模块名>.xml`：
- ❌ 删除 `<Combination Name="InputImage" Style="IMAGE">` 整个节点
- ❌ 删除 `<Combination Name="InputROI" Style="ROIBOX">` 整个节点
- ❌ 删除 `<Combination Name="Position Correction Info" Style="FIXTURE">` 整个节点
- ✅ 保留 Output 中你需要的输出项
- ✅ 也可在 Input 中加非图像输入（如 string、point、int 等）

`<模块名>AlgorithmTab.xml`：
- ❌ 删除 `<GroupLinkItem Name="ImageSourceGroup">`
- ❌ 删除 `<Category Name="Tab_ROI Area">` 整个 Category
- ✅ 保留 `Tab_Run Params`

`<模块名>Display.xml`：
- ❌ 删除 `<Object Name="InputImage" Type="image">` 节点
- ❌ 删除 `<Object Name="OutputImage" Type="image">` 节点（除非你有图像输出）
- ❌ 删除 `<Object Name="ROI" Type="rect">` 节点
- ✅ 保留 `Data Record` 和 `Result List`（**禁止删除**，否则结果不刷新）

## 规则 3：多图像输入（参考 VM430 多图像源输入示例）

**示例来源**：VM430 多图像源输入官方示例（内部参考路径，外部不可访问）

### .h —— **只**声明 3 参数版（与规则 1 完全相同）

```cpp
int Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input);
```

### .cpp —— Process 内分别取多张图

主图通过 `modu_input->pImageInObj` 访问；其他图按 Filter 名取：

```cpp
int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
    int nErrCode = IMVS_EC_OK;
    int errorStatus = 0;
    double fStart = MyMilliseconds();

    try
    {
        // === 主图（用 modu_input->pImageInObj）===
        int nWidth  = modu_input->pImageInObj->GetWidth();
        int nHeight = modu_input->pImageInObj->GetHeight();
        int nFormat = modu_input->pImageInObj->GetPixelFormat();
        const unsigned char* pImg1Data = modu_input->pImageInObj->GetImageData(0)->pData;

        // === 第二张图：按 Filter 名取 ===
        HKA_IMAGE stImage2;
        HKA_S32   nStatus2 = 0;
        HKA_S32   nDataLen2 = 0;
        char      szSharedMem2[256] = {0};
        nErrCode = VmModule_GetInputImageByName(hInput,
                       "InImage2", "InImage2Width", "InImage2Height", "InImage2PixelFormat",
                       &stImage2, &nStatus2, szSharedMem2);
        if (nErrCode != IMVS_EC_OK) {
            MLOG_ERROR(m_nModuleId, "Get InImage2 failed: 0x%x", nErrCode);
            VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
            return nErrCode;
        }
        // 注意:此为浅拷贝。若要修改 stImage2 数据须先 AllocateSharedMemory + memcpy_s

        // === 第三张图（同上） ===
        // HKA_IMAGE stImage3; ...
        // VmModule_GetInputImageByName(hInput,
        //     "InImage3", "InImage3Width", "InImage3Height", "InImage3PixelFormat",
        //     &stImage3, &nStatus3, szSharedMem3);

        // === 算法处理 ===
        // ...

        errorStatus = 1;
        VM_M_SetInt(hOutput, "ModuStatus", 0, errorStatus);
    }
    catch (...) {
        MLOG_ERROR(m_nModuleId, "Process exception.");
        VM_M_SetInt(hOutput, "ModuStatus", 0, 0);
        nErrCode = IMVS_EC_PARAM;
    }

    MODULE_RUNTIME_INFO struRunInfo = { 0 };
    struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
    VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);
    return nErrCode;
}
```

### XML —— `<模块名>.xml` Input Category 增加多个 Combination

**每张额外图独立一个 `<Combination Style="IMAGE">`**,Filter 名加序号后缀（`InImage2`/`InImage3`,**不能**重名）：

```xml
<!-- 主图（与单图模块相同）-->
<Combination Name="InputImage" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageWidth"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageHeight"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImagePixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>

<!-- 第二张图 -->
<Combination Name="InputImage2" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage2"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2Width"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2Height"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImage2PixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>

<!-- 第三张图同上,Name="InputImage3" / Filter Name="InImage3*" -->
```

🚫 **反例**：
- ❌ 用 `IsArray="true"` 的单个 Combination 表示多图 —— VM 不支持
- ❌ 多张图共用 `InImage` Filter —— 重名,VM 解析失败
- ❌ 第二张图也用 `Name="InputImage"` —— Combination 名也必须唯一

### `<模块名>AlgorithmTab.xml`（多图）

`Tab_Basic Params` 内 `ImageSourceGroup` 通常每张图一份,可参考示例;若不确定保持单图模板的一份即可（图像源选择 UI 是辅助,**不**影响 Process 运行）。

### `<模块名>Display.xml`（多图）

若要分别渲染每张输入图：

```xml
<Object Name="InputImage"  Type="image" Mapping="InImage,InImageWidth,InImageHeight,InImagePixelFormat" />
<Object Name="InputImage2" Type="image" Mapping="InImage2,InImage2Width,InImage2Height,InImage2PixelFormat" />
```

## 多图像输出（独立形态）

详见 [io-params/output-image.txt](io-params/output-image.txt) §多图像输出。要点：
- Process 内多次 `VmModule_OutputImageByName_8u_C*R`，每张图独立的 `pSharedName`
- `<模块名>.xml` Output Category 多个 Combination（`OutputImage` / `OutputImage2` / ...）
- `<模块名>Display.xml` 多个 `<Object Type="image">` 节点

## 自检（落盘后必做）

```bash
# Process 定义数必须为 1（有图像输入）或 2（无图像输入，2 参数写逻辑 + 3 参数纯虚函数委托）
grep -cE "^int\s+CAlgorithmModule::Process\s*\(" <模块>/AlgorithmModule.cpp
# 输出 1 或 2 才对;输出 0 → 未实现,输出 ≥3 → 重复定义

# .h 中 Process 声明数也必须为 1 或 2
grep -cE "^\s*int\s+Process\s*\(" <模块>/AlgorithmModule.h
```
