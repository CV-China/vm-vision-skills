# 参数类型映射表

## 0. 基本铁律：**算法相关参数一律是运行参数**

> 基本参数 vs 运行参数的分类铁律与速判表见 **SKILL.md §E**。本文 §1-§6 为对应的 XML 节点示例、C++ 模板与命名规范。

## 1. 基本参数 vs 运行参数（强制区分）

| 项 | 基本参数 | 运行参数 |
|---|---|---|
| 典型类型 | image / point / line / rect / point数组 / rect数组 / int/float/string 形式的标量 I/O / Fixture | 阈值/类型/使能/模型路径/枚举选择/缩放级别等"算法旋钮" |
| 配置 XML | `<模块名>.xml`（`<ParamRoot>` 根节点） | `<模块名>AlgorithmTab.xml`（`<AlgorithmTabRoot>` 根节点） + `<模块名>Algorithm.xml`（`<AlgorithmParamList>` 根节点） |
| C++ 读 | `Process()` 内：`VmModule_GetInputImageEx` / `VM_M_Get*` | `SetParam(szName, pData, nLen)` 内 `strcmp` 分支 |
| C++ 写 | `Process()` 内：`VM_M_Set*` | `GetParam(szName, pBuff, nBuffSize, ...)` 内 `strcmp` 分支 |
| UI 控件 | `Combination`（IMAGE/ROIBOX/POINT/...）/ `Filter` | `Integer/Float/Boolean/String/Enumeration/OpenFile/OpenFolderDialogEx/OpenFileForCNNDialog/OpenFileForCalibDialog/SaveFileDialog/IntegerBettween/FloatBettween`（控件含 Description/DisplayName/MinValue 等） |
| 默认值来源 | 连线/上游模块输出 | `<模块名>Algorithm.xml` 的 `<ParamItem><DefaultValue>` |

**铁律**：
- 图像 / ROI / 点集 / 直线 / 矩形等几何类型**只能**作基本参数
- 阈值 / 类型 / 使能 / 路径等"算法旋钮"**只能**作运行参数

## 2. 脚本类型 → XML 类型 → C++ 类型映射

来源：模块敏捷封装工具 `ParamExtractor.cs` 中的类型映射逻辑。

| 脚本类型 | XML ValueType | C++ 类型 | 默认 UI |
|---|---|---|---|
| `int` | `int` | `int` | Integer |
| `float` | `float` | `float` | Float |
| `string` | `string` | `std::string` | String |
| `bool` | `bool` | `bool` | Boolean |
| `enumeration` | `int` | `int`（配合 Enumeration UI） | Enumeration |
| `openFile` | `string` | `std::string` | OpenFile（按钮+路径） |
| `POINT` | `point` | `PointData`（X/Y 两个 float） | Combination Style="POINT" |
| `LINE` | `line` | `LineData`（StartX/Y, EndX/Y 四个 float） | Combination Style="LINE" |
| `ROIBOX` | `rect` | `RoiBox`（CenterX/Y, Width, Height, Angle 五个 float） | Combination Style="ROIBOX" |
| `ROIANNULUS` | `circle/annulus` | `CircleData`（CenterX/Y, InnerRadius, Radius, StartAngle, AngleExtend 六个 float） | Combination Style="ROIANNULUS" |
| `IMAGE` | `image` | `HKA_IMAGE_S` / `HKA_IMAGE` | Combination Style="IMAGE" |
| `byte` | `byte` | `unsigned char` | （仅作输入/输出，不作运行参数） |

数组用 `IsArray="true"` 属性。

## 3. 基本参数 XML 节点示例

详见 [xml-schemas/module-io.xml.md](xml-schemas/module-io.xml.md) 和 [io-params/](io-params/) 各 txt。

输入图像（标准 Combination，**禁止**用裸 `<Image>`）：
```xml
<Combination Name="InputImage" Style="IMAGE" AccessMode="RW">
    <Filters>
        <Filter Name="InImage"            ValueType="image" IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageWidth"       ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImageHeight"      ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
        <Filter Name="InImagePixelFormat" ValueType="int"   IsForce="true" isShow="true" AccessMode="RO"/>
    </Filters>
</Combination>
```

输出 int：
```xml
<Filter Name="thresholdOut" ValueType="int" IsForce="true" isShow="true" AccessMode="RW"/>
```

## 4. 运行参数 XML 控件示例（在 `<模块名>AlgorithmTab.xml` Tab_Run Params 内）

详见 [xml-schemas/algorithm-tab.xml.md](xml-schemas/algorithm-tab.xml.md)。所有控件**包在** `<Tab Name="Tab_Run Params"><Categorys><Category Name="Tab_Run Params"><Items>...</Items></Category></Categorys></Tab>` 三层结构中。

Integer：
```xml
<Integer Name="thresholdValue" NameSpace="Standard">
    <Description>阈值</Description>
    <DisplayName>阈值</DisplayName>
    <AccessMode>RW</AccessMode>
    <MinValue>0</MinValue>
    <MaxValue>255</MaxValue>
    <CurValue>128</CurValue>
    <DefaultValue>128</DefaultValue>
    <IncValue>1</IncValue>
</Integer>
```

Float：
```xml
<Float Name="ratioValue" NameSpace="Standard">
    <Description>比率</Description>
    <DisplayName>比率</DisplayName>
    <AccessMode>RW</AccessMode>
    <MinValue>0.0</MinValue>
    <MaxValue>1.0</MaxValue>
    <CurValue>0.5</CurValue>
    <DefaultValue>0.5</DefaultValue>
    <IncValue>0.01</IncValue>
    <DecimalDigits>2</DecimalDigits>
</Float>

```

Enumeration：
```xml
<Enumeration Name="thresholdType" NameSpace="Standard">
    <Description>阈值化类型</Description>
    <DisplayName>阈值化类型</DisplayName>
    <AccessMode>RW</AccessMode>
    <CurValue>1</CurValue>
    <DefaultValue>1</DefaultValue>
    <EnumEntrys>
        <EnumEntry><Description>BINARY</Description>    <DisplayName>BINARY</DisplayName>    <Value>1</Value></EnumEntry>
        <EnumEntry><Description>BINARY_INV</Description><DisplayName>BINARY_INV</DisplayName><Value>2</Value></EnumEntry>
    </EnumEntrys>
</Enumeration>
```

**使能开关用 Boolean（不是 Bool）+ Trigger 联动**（关闭隐藏依赖参数，打开显示）：
```xml
<Boolean Name="PyramidModeEnable">
    <AlgorithmIndex>0</AlgorithmIndex>
    <CurValue>False</CurValue>
    <DefaultValue>False</DefaultValue>
    <Description>手动尺度使能</Description>
    <DisplayName>手动尺度使能</DisplayName>
    <AccessMode>RW</AccessMode>
    <Triggers>
        <Trigger>
            <Property>CurValue</Property>
            <Value>False</Value>
            <Setters>
                <Setter><TargetName>PyramidScaleLevel</TargetName><OperationName>HiddenOperation</OperationName></Setter>
                <Setter><TargetName>PyramidScaleRLevel</TargetName><OperationName>HiddenOperation</OperationName></Setter>
            </Setters>
        </Trigger>
        <Trigger>
            <Property>CurValue</Property>
            <Value>True</Value>
            <Setters>
                <Setter><TargetName>PyramidScaleLevel</TargetName><OperationName>VisibleOperation</OperationName></Setter>
                <Setter><TargetName>PyramidScaleRLevel</TargetName><OperationName>VisibleOperation</OperationName></Setter>
            </Setters>
        </Trigger>
    </Triggers>
</Boolean>
```

> Boolean 的 `CurValue`/`DefaultValue` 必须 `True`/`False`（首字母大写）。`OperationName` 取值：`VisibleOperation` / `HiddenOperation` / `EnableOperation` / `DisableOperation`。**默认开/关**必须按客户描述确认，不明确则**主动问**用户。

String：
```xml
<String Name="modelName" NameSpace="Standard">
    <Description>模型名称</Description>
    <DisplayName>模型名称</DisplayName>
    <AccessMode>RW</AccessMode>
    <CurValue></CurValue>
    <DefaultValue></DefaultValue>
</String>
```

OpenFile（文件加载）：
```xml
<OpenFile Name="modelPath" NameSpace="Standard">
    <Description>模型路径</Description>
    <DisplayName>模型路径</DisplayName>
    <AccessMode>RW</AccessMode>
    <CurValue></CurValue>
    <DefaultValue></DefaultValue>
    <Filter>Model files (*.dat)|*.dat</Filter>
</OpenFile>
```

IntegerBettween / FloatBettween（双 t,VM 内部拼写）：详见 [io-params/run-params.txt](io-params/run-params.txt)。

## 5. 运行参数的 Algorithm.xml 默认值（**必须**与 AlgorithmTab.xml 同名）

详见 [xml-schemas/algorithm-default.xml.md](xml-schemas/algorithm-default.xml.md)。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<AlgorithmParamList>
    <ParamItem>
        <Name>thresholdType</Name>
        <DefaultValue>1</DefaultValue>
    </ParamItem>
    <ParamItem>
        <Name>thresholdValue</Name>
        <DefaultValue>128</DefaultValue>
    </ParamItem>
    <ParamItem>
        <Name>PyramidModeEnable</Name>
        <DefaultValue>False</DefaultValue>
    </ParamItem>
</AlgorithmParamList>
```

**三方一致**自检（任一缺失或拼错 → 参数无法生效）：
- `AlgorithmTab.xml` 控件 `Name="..."`
- `Algorithm.xml` `<ParamItem><Name>...</Name></ParamItem>`
- `AlgorithmModule.cpp` `strcmp("...", szParamName)`

## 6. 运行参数获取设置模板（C++ 端）

> **GetParam 规范**：**不**包 `MVDSDK_TRY/CATCH`；**不**赋值 `*pDataLen`（VM 底层会自己根据返回的 pBuff 计算长度，重复赋值反而干扰）。SetParam 同理不包 try/catch。

`AlgorithmModule.cpp` 中：

```cpp
int CAlgorithmModule::GetParam(IN const char* szParamName, OUT char* pBuff,
                               IN int nBuffSize, OUT int* pDataLen)
{
    if (szParamName == NULL || strlen(szParamName) == 0 || pBuff == NULL ||
        nBuffSize <= 0 || pDataLen == NULL)
        return IMVS_EC_PARAM;

    if (0 == strcmp("thresholdType", szParamName))
    {
        sprintf_s(pBuff, nBuffSize, "%d", m_nThresholdType);
    }
    else if (0 == strcmp("thresholdValue", szParamName))
    {
        sprintf_s(pBuff, nBuffSize, "%d", m_nThresholdValue);
    }
    else if (0 == strcmp("PyramidModeEnable", szParamName))
    {
        if (m_bPyramidModeEnable)
            memcpy_s(pBuff, nBuffSize, "True",  strlen("True")  + 1);
        else
            memcpy_s(pBuff, nBuffSize, "False", strlen("False") + 1);
    }
    else if (0 == strcmp("modelName", szParamName))
    {
        sprintf_s(pBuff, nBuffSize, "%s", m_strModelName.c_str());
    }
    else
    {
        return CVmAlgModuleBase::GetParam(szParamName, pBuff, nBuffSize, pDataLen);
    }
    return IMVS_EC_OK;
}

int CAlgorithmModule::SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen)
{
    if (szParamName == NULL || strlen(szParamName) == 0 || pData == NULL || nDataLen == 0)
        return IMVS_EC_PARAM;

    if (0 == strcmp("thresholdType", szParamName))
    {
        m_nThresholdType = atoi(pData);
    }
    else if (0 == strcmp("thresholdValue", szParamName))
    {
        m_nThresholdValue = atoi(pData);
    }
    else if (0 == strcmp("PyramidModeEnable", szParamName))
    {
        // Boolean 的 pData 是 "True"/"False" 字符串
        if (0 == strcmp("False", pData))
            m_bPyramidModeEnable = false;
        else
            m_bPyramidModeEnable = true;
    }
    else if (0 == strcmp("modelName", szParamName))
    {
        // pData 含中文时是 UTF-8,作文件路径用时须 UTF8toANSI
        m_strModelName = std::string(pData);
    }
    else
    {
        return CVmAlgModuleBase::SetParam(szParamName, pData, nDataLen);
    }
    return IMVS_EC_OK;
}
```

### 成员变量命名规范（**所有 `CAlgorithmModule` 成员严格遵循**）

| 前缀 | 类型 | 示例 |
|---|---|---|
| `m_n` | 整型（int/short/long） | `m_nThresholdValue` |
| `m_f` | 浮点型（float/double） | `m_fRatioValue` |
| `m_b` | 布尔型（bool） | `m_bPyramidModeEnable` |
| `m_str` | 字符串（std::string/CString） | `m_strModelName` |
| `m_stru` | 自定义结构体（**结构体定义放在 `CAlgorithmModule` 类声明上方**） | `m_struCalibInfo` |
| `m_vct` | vector 容器 | `m_vctPoints` |
| `m_G` | 全局类型 | `m_GConfig` |
| `m_ptr` | 指针 | `m_ptrBuffer` |

**数组类型必须在构造函数中 `memset` 初始化**（不能依赖默认零值）：

```cpp
CAlgorithmModule::CAlgorithmModule()
{
    m_nThresholdValue = 128;
    m_fRatioValue     = 0.5f;
    // 数组：必须 memset
    memset(m_fBasePointX, 0, sizeof(m_fBasePointX));
    memset(m_fBasePointY, 0, sizeof(m_fBasePointY));
}
```

### 头文件（`.h`）成员变量声明 + 构造函数初始化

```cpp
// .h
private:
    int   m_nThresholdType;          // 阈值化类型: 1=BINARY, 2=BINARY_INV
    int   m_nThresholdValue;         // 阈值
    bool  m_bPyramidModeEnable;      // 手动尺度使能
    std::string m_strModelName;      // 模型名称
```

```cpp
// .cpp 构造函数
CAlgorithmModule::CAlgorithmModule()
{
    m_nThresholdType     = 1;
    m_nThresholdValue    = 128;
    m_bPyramidModeEnable = false;     // 默认开/关须按客户描述确认
    m_strModelName       = "";
}
```

**默认值恢复机制**：VM 工具"重置参数"按钮触发基类 `CVmAlgModuleBase::ResetDefaultParam()` —— 该函数读取 `<模块名>Algorithm.xml` 的 `<ParamItem>` 并依次调 `SetParam` 回写,**末尾还会调 `DynamicIOInit()`**。**绝对禁止**在 `AlgorithmModule.h/.cpp` 重载 `ResetDefaultParam`,模板里也**没有**该函数 —— 重载即破坏初始化链路(常见症状:模块加载后参数为空、动态 I/O 端口缺失)。

🚫 **绝对禁止重载的基类虚函数**(模板未声明 = 永远不要新增):
- `ResetDefaultParam` —— 基类读 Algorithm.xml + SetParam + DynamicIOInit
- `GetAllParamList` / `SetAllParamList` —— 基类遍历 XML 自动处理
- `GetProcessInput` —— 基类自动绑定输入/ROI/Fixture
- `GenerateMaskImage` / `ClearRoiData` / `ResetDefaultRoi` —— 基类内置 ROI/屏蔽区逻辑
- `DynamicIOInit` —— 基类按 XML 动态创建 I/O 端口

**唯一允许重载**的基类虚函数:`Process`(3 参数 + 2 参数,二选一)、`GetParam`、`SetParam`。`SaveModuleData/LoadModuleData` 仅当需要持久化**非标准数据**(模型 buffer/查找表等,标准运行参数 VM 已自动处理)时才重载,详见 [param-save-load.md](param-save-load.md)。

**注意**：
- `sprintf_s` / `sscanf_s` / `atoi` / `memcpy_s` 是格式化辅助函数，**不属于**日志接口禁用范畴
- 字符串型运行参数（OpenFile/String）含中文时必须按 [encoding.md](encoding.md) 处理
- `MVDSDK_TRY` / `MVDSDK_CATCH` **不要**用在 GetParam/SetParam 内（与 VM 底层异常处理冲突）；Process 内的 try/catch 才是合理位置
- Boolean 在 `pData` 中是字符串 `"True"`/`"False"`（首字母大写），不是 `1`/`0`
