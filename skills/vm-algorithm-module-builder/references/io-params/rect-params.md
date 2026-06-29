# ROIBOX 矩形专题 —— 完整参考

> 本文档聚焦 ROIBOX 矩形的**C++ 读写辅助函数**、**XML Combination 变体**和 **Display.xml 渲染**。
> POINT / LINE 及 ButtonSelecter 通用规律见 [geometric-params.txt](geometric-params.txt)。

## RoiBox 结构体(建议在 AlgorithmModule.h 中定义)

```cpp
struct RoiBox {
    HKA_F32 fCenterX;
    HKA_F32 fCenterY;
    HKA_F32 fWidth;
    HKA_F32 fHeight;
    HKA_F32 fAngle;

    RoiBox() : fCenterX(0), fCenterY(0), fWidth(0), fHeight(0), fAngle(0) {}

    RoiBox(float centerX, float centerY, float width, float height, float angle)
    {
        this->fCenterX = centerX;
        this->fCenterY = centerY;
        this->fWidth    = width;
        this->fHeight   = height;
        this->fAngle    = angle;
    }
};
```

## 一、C++ 读取 —— GetBatchBoxByName(批量矩形输入)

用于读取上游模块传入的**多个矩形**(如 DetectRect 数组)。

```cpp
int CAlgorithmModule::GetBatchBoxByName(IN void* hInput, IN const char* xmlName,
                                         OUT HKA_U32& nBoxArrayCount,
                                         OUT HKA_U32& status,
                                         OUT std::vector<RoiBox>& boxes)
{
    int nRet = IMVS_EC_OK;
    float fValue = 0.0f;
    int nCount = 0;
    std::vector<float> boxCenterX, boxCenterY, boxWidth, boxHeight, boxAngle;
    boxes.clear();

    // 构建分量名: xmlName + "CenterX" / "CenterY" / "Width" / "Height" / "Angle"
    std::string xmlNameStr = xmlName;
    const char* nameCX = (xmlNameStr + "CenterX").c_str();
    const char* nameCY = (xmlNameStr + "CenterY").c_str();
    const char* nameW  = (xmlNameStr + "Width").c_str();
    const char* nameH  = (xmlNameStr + "Height").c_str();
    const char* nameA  = (xmlNameStr + "Angle").c_str();

    // 1) 通过 CenterX 获取数组长度
    nRet = VmModule_GetInputVectorCount(hInput, nameCX, &nBoxArrayCount, &status);
    if (IMVS_EC_OK != nRet || nBoxArrayCount == 0)
        return nRet;

    // 2) 逐分量读取
    for (HKA_U32 i = 0; i < nBoxArrayCount; ++i)
    {
        nRet = VM_M_GetFloat(hInput, nameCX, i, &fValue, &nCount);
        if (IMVS_EC_OK != nRet) break;
        boxCenterX.emplace_back(fValue);
    }
    HKA_MODU_CHECK_ERROR(IMVS_EC_OK != nRet, nRet);

    for (HKA_U32 i = 0; i < nBoxArrayCount; ++i)
    {
        nRet = VM_M_GetFloat(hInput, nameCY, i, &fValue, &nCount);
        if (IMVS_EC_OK != nRet) break;
        boxCenterY.emplace_back(fValue);
    }
    HKA_MODU_CHECK_ERROR(IMVS_EC_OK != nRet, nRet);

    for (HKA_U32 i = 0; i < nBoxArrayCount; ++i)
    {
        nRet = VM_M_GetFloat(hInput, nameW, i, &fValue, &nCount);
        if (IMVS_EC_OK != nRet) break;
        boxWidth.emplace_back(fValue);
    }
    HKA_MODU_CHECK_ERROR(IMVS_EC_OK != nRet, nRet);

    for (HKA_U32 i = 0; i < nBoxArrayCount; ++i)
    {
        nRet = VM_M_GetFloat(hInput, nameH, i, &fValue, &nCount);
        if (IMVS_EC_OK != nRet) break;
        boxHeight.emplace_back(fValue);
    }
    HKA_MODU_CHECK_ERROR(IMVS_EC_OK != nRet, nRet);

    for (HKA_U32 i = 0; i < nBoxArrayCount; ++i)
    {
        nRet = VM_M_GetFloat(hInput, nameA, i, &fValue, &nCount);
        if (IMVS_EC_OK != nRet) break;
        boxAngle.emplace_back(fValue);
    }
    HKA_MODU_CHECK_ERROR(IMVS_EC_OK != nRet, nRet);

    // 3) 一致性校验 + 组装
    size_t numBoxes = boxCenterX.size();
    if (boxCenterY.size() != numBoxes || boxWidth.size()  != numBoxes ||
        boxHeight.size()  != numBoxes || boxAngle.size()  != numBoxes)
    {
        return IMVS_EC_PARAM;
    }
    for (size_t i = 0; i < numBoxes; ++i)
    {
        boxes.emplace_back(RoiBox(boxCenterX[i], boxCenterY[i],
                                   boxWidth[i], boxHeight[i], boxAngle[i]));
    }
    return IMVS_EC_OK;
}
```

**使用示例**:
```cpp
std::vector<RoiBox> BaseModelRect;
HKA_U32 nBoxArrayCount = 0, status = 0;
int nRet = GetBatchBoxByName(hInput, "DetectRect", nBoxArrayCount, status, BaseModelRect);
```

## 二、C++ 读取 —— GetBoxByName(单矩形输入)

```cpp
int CAlgorithmModule::GetBoxByName(IN void* hInput, IN const char* xmlName, OUT RoiBox& box)
{
    int nCount = 0;
    float fValue = 0.0f;

    std::string xmlNameStr = xmlName;

    VM_M_GetFloat(hInput, (xmlNameStr + "CenterX").c_str(), 0, &fValue, &nCount);
    box.fCenterX = fValue;

    VM_M_GetFloat(hInput, (xmlNameStr + "CenterY").c_str(), 0, &fValue, &nCount);
    box.fCenterY = fValue;

    VM_M_GetFloat(hInput, (xmlNameStr + "Width").c_str(),   0, &fValue, &nCount);
    box.fWidth = fValue;

    VM_M_GetFloat(hInput, (xmlNameStr + "Height").c_str(),  0, &fValue, &nCount);
    box.fHeight = fValue;

    VM_M_GetFloat(hInput, (xmlNameStr + "Angle").c_str(),   0, &fValue, &nCount);
    box.fAngle = fValue;

    return IMVS_EC_OK;
}
```

**使用示例**:
```cpp
RoiBox BlockRect;
GetBoxByName(hInput, "BlockRect", BlockRect);
```

## 三、C++ 写输出 —— SetBatchBoxByName(批量矩形输出)

```cpp
int CAlgorithmModule::SetBatchBoxByName(void* hOutput, const char* xmlName,
                                         std::vector<RoiBox>& boxes)
{
    int nRet = IMVS_EC_OK;
    int boxSize = (int)boxes.size();

    std::string xmlNameStr = xmlName;

    for (int i = 0; i < boxSize; i++)
    {
        nRet = VM_M_SetFloat(hOutput, (xmlNameStr + "CenterX").c_str(), i, boxes[i].fCenterX);
        if (IMVS_EC_OK != nRet) break;
        nRet = VM_M_SetFloat(hOutput, (xmlNameStr + "CenterY").c_str(), i, boxes[i].fCenterY);
        if (IMVS_EC_OK != nRet) break;
        nRet = VM_M_SetFloat(hOutput, (xmlNameStr + "Width").c_str(),   i, boxes[i].fWidth);
        if (IMVS_EC_OK != nRet) break;
        nRet = VM_M_SetFloat(hOutput, (xmlNameStr + "Height").c_str(),  i, boxes[i].fHeight);
        if (IMVS_EC_OK != nRet) break;
        nRet = VM_M_SetFloat(hOutput, (xmlNameStr + "Angle").c_str(),   i, boxes[i].fAngle);
        if (IMVS_EC_OK != nRet) break;
    }
    return nRet;
}
```

**使用示例**:
```cpp
SetBatchBoxByName(hOutput, "PatMatchRect", RunModelRect);
```

## 四、XML Combination 变体速查

| 场景 | Style | AccessMode | IsForce | isShow | AlgorithmTab ButtonSelecter |
|---|---|---|---|---|---|
| 上游驱动的多个 Rect | ROIBOX | (无) | true | (无) | 父 Combination 1 个(可选) |
| 用户可编辑的单个 Rect | ROIBOX | RW | false | true | 完整展开 7 个 |
| 简单的输出 Rect 数组 | ROIBOX(或 Filter rect IsArray) | RW | true | true | **不需要**(仅 Output) |

> ⚠️ **矩形数据只能用 `VM_M_GetFloat/VM_M_SetFloat` 逐分量读写（5 个 float: CenterX/CenterY/Width/Height/Angle）。不要使用 `VmModule_OutputVector_BoxF` 或 `VmModule_GetInputRoiBox`。**

## 五、Display.xml 中矩形渲染模板

```xml
<Object Name="PatMatchBox" Type="rect" okcolor="#66ff00" ngcolor="#ff0000"
        hotcolor="#66ff00" opacity="1" linetype="1" linewidth="1"
        IsDisplay="true" highLightEnable="false">
    <Features>
        <Feature Name="CenterX" Mapping="PatMatchRectCenterX" Value="0"/>
        <Feature Name="CenterY" Mapping="PatMatchRectCenterY" Value="0"/>
        <Feature Name="Width"   Mapping="PatMatchRectWidth"   Value="0"/>
        <Feature Name="Height"  Mapping="PatMatchRectHeight"  Value="0"/>
        <Feature Name="Angle"   Mapping="PatMatchRectAngle"   Value="0"/>
        <Feature Name="Tips"
                 Mapping="PatMatchRectCenterX,PatMatchRectCenterY,PatMatchRectWidth,PatMatchRectHeight,PatMatchRectAngle"
                 Value="CenterX:{0},CenterY:{1} Width:{2} Height:{3} Angle:{4}"/>
        <Feature Name="Status"  Mapping="ModuStatus" Value="1"/>
    </Features>
</Object>
```

**逐字段说明**（Feature `Name` 为固定值，不可自定义）:

| Feature Name | Mapping 来源 | 说明 |
|---|---|---|
| CenterX | `<模块名>.xml` Output 中 CenterX Filter Name | 矩形中心 X |
| CenterY | 同上 CenterY | 矩形中心 Y |
| Width | 同上 Width | 矩形宽度 |
| Height | 同上 Height | 矩形高度 |
| Angle | 同上 Angle | 矩形旋转角度(度) |
| Tips | 5 个 Filter Name 逗号拼接 | 鼠标悬停提示,Value 为格式化串 `{0}`~`{4}` |
| Status | `ModuStatus`（结果有效时渲染）或 `NULL`（始终渲染） | `Value="1"` |
