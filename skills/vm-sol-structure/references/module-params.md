# 模块运行参数速查

从 VisionMaster 4.4.0 AlgorithmTab.xml 自动提取。

| 统计项 | 值 |
|--------|-----|
| 模块数 | 223 |
| 参数总数 | 3436 |
| 控件类型 | 21 种（Integer/Boolean/ButtonSelecter/RadioSelecter/String 等） |

## 参数说明

- **algoIdx**: AlgorithmIndex，对应 ModuleFrame 1024 字节 algori 区的字段索引（- 表示未使用）
- **default**: 默认值

> 标记 ⚠️ 的模块有 AlgorithmTab.xml 定义了运行参数，但其 ToolItemInfo.xml 缺少 `<helpUrl>` 标签（即没有关联的帮助文档），因此未被收录到 module-index.md 索引中。

---

### AndModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| LogicItemFields | ButtonSelecter_LogicItem | - | - | Data Set Field List |

### AsShellModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ShellContent | ButtonSelecter_AsShell | - | - | RunParam_Shell Module |

### BackgroundExtract ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BackgroundGrayReference | Integer | - | - | 背景灰度参考 |
| BackgroundGrayScale | Integer | - | - | 背景灰度等级 |
| BackgroundOffset | Integer | - | - | 背景偏差阈值 |
| SampleNum | Integer | - | - | 采样点数量 |
| BackgroundOptimEnable | Boolean | 0 | True | 背景优化使能 |
| ImageOutputEnable | Boolean | 0 | True | 输出图像使能 |
| RegionAngles | ButtonSelecter | - | - | 区域角度 |
| RegionCenterXs | ButtonSelecter | - | - | 区域中心X |
| RegionCenterYs | ButtonSelecter | - | - | 区域中心Y |
| RegionHeights | ButtonSelecter | - | - | 区域高度 |
| RegionWidths | ButtonSelecter | - | - | 区域宽度 |

### BranchDataSelectModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputBranchSources | ButtonSelecter | - | - | 条件输入 |
| BranchDataSelectDynamicIO | ButtonSelecter_BranchDataSelect | - | - | - |

### BranchModule_STD

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ConditionInput | ButtonSelecter | - | - | Condition Input |

### BranchStringCpmL ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| TextInput | ButtonSelecter | - | - | Input Text |

### CalculatorModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| command#restvalue | Command | - | - | Reset |
| CalculatorPro | ButtonSelecter_CalculatorPro | - | - | - |

### CameraIOModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| IODurationTime | Integer | - | 500 | RunParam_Duration |
| DurationTimeEnable | Boolean | 0 | True | DurationTimeEnable |
| IO0InputString | ButtonSelecter | - | - | RunParam_IO0 |
| IO1InputString | ButtonSelecter | - | - | IO1 Output Condition |
| IO2InputString | ButtonSelecter | - | - | IO2 Output Condition |
| IO3InputString | ButtonSelecter | - | - | IO3 Output Condition |
| IO4InputString | ButtonSelecter | - | - | IO4 Output Condition |

### CharSegmentModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| MaxCharArea | Integer | - | 500000 | Max. Fragment Size |
| MaxCharHeight | Integer | - | 128 | Character Max Height |
| MaxCharWidth | Integer | - | 128 | Character Max Width |
| MinCharArea | Integer | - | 15 | Min. Fragment Size |
| MinCharHeight | Integer | - | 8 | Character Min Height |
| MinCharWidth | Integer | - | 4 | Character Min Width |
| MinInterCharGap | Integer | - | 1 | RunParam_Min Char Gap |
| Text | ButtonSelecter | - | - | 文本 |
| TextBox | ButtonSelecter | - | - | 文本行区域 |

### CommDeviceModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CameraRespnseControl | Boolean | 0 | False | RunParam_Camera Control |
| LoadSolution | Boolean | 0 | False | Lang_SolLoad |
| ProcessControl | Boolean | 0 | False | IMVSProcessControl |
| ConnectTrigger | String | - | - | RunParam_Connect Trigger |
| DisConnectTrigger | String | - | - | RunParam_Disconnect Trigger |
| ProcessBusyTrigger | String | - | - | RunParam_Busy Trigger |
| ProcessFreeTrigger | String | - | - | RunParam_Free Trigger |
| SolutionTrigger | String | - | - | TriggerString |

### CommManagerModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SolutionTimeOut | Integer | - | 0x00 | RunParam_SolutionTimeOut |
| CameraRespnseControl | Boolean | 0 | False | RunParam_Camera Control |
| IsCameraEndChar | Boolean | 0 | False | End Char |
| IsPrcEndChar | Boolean | 0 | False | End Char |
| IsSolEndChar | Boolean | 0 | False | End Char |
| LoadSolution | Boolean | 0 | False | Lang_SolLoad |
| ProcessControl | Boolean | 0 | False | IMVSProcessControl |
| ConnectTrigger | String | - | - | RunParam_Connect Trigger |
| DisConnectTrigger | String | - | - | RunParam_Disconnect Trigger |
| ProcessBusyTrigger | String | - | - | RunParam_Busy Trigger |
| ProcessFreeTrigger | String | - | - | RunParam_Free Trigger |
| SolutionTrigger | String | - | - | TriggerString |

### CoordinateModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SrcInputAngle | ButtonSelecter | - | - | Angle |
| SrcInputMatrix | ButtonSelecter | - | - | Matrix |
| SrcInputPoints | ButtonSelecter | - | - | Point |
| SrcInputPointsX | ButtonSelecter | - | - | PointX |
| SrcInputPointsY | ButtonSelecter | - | - | pointy |

### CoordinateTransform

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CorrectEnable | Boolean | 0 | False | Coordinate Conversion Enable |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| ActualCenterPoints | ButtonSelecter | - | - | Dicing Center Point |
| ActualCenterPointsX | ButtonSelecter | - | - | Dicing Center Point X |
| ActualCenterPointsY | ButtonSelecter | - | - | Dicing Center Point Y |
| DicingHeight | ButtonSelecter | - | - | Dicing Image Height |
| DicingWidth | ButtonSelecter | - | - | Dicing Image Width |
| SrcInputPoints | ButtonSelecter | - | - | Point |
| SrcInputPointsX | ButtonSelecter | - | - | PointX |
| SrcInputPointsY | ButtonSelecter | - | - | pointy |

### CropAlignModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 180 | Angle End |
| AngleStart | Integer | - | -180 | Angle Start |
| OffsetHeight | Integer | - | 0x8 | RunParam_OffsetHeight |
| OffsetWidth | Integer | - | 0x8 | RunParam_OffsetWidth |
| PyramidScaleLevel | Integer | - | 0x5 | 速度尺度 |
| PyramidScaleRLevel | Integer | - | 0x2 | 特征尺度 |
| OutLineEnable | Boolean | 0 | True | RunParam_Contour Enabled |
| OutLinePointEnable | Boolean | 0 | True | 轮廓点使能 |
| PyramidModeEnable | Boolean | 0 | False | 手动尺度使能 |
| BlockRect | ButtonSelecter | - | - | 块定位区域 |
| DetectRect | ButtonSelecter | - | - | 建模区域 |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |

### CropResizeModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| DefectDefineThreshold | Integer | - | 0x10 | 缺陷大小阈值 |
| HeightValue | Integer | - | 0xE0 | OutImageHeight |
| HightThreshold | Integer | - | 0xC | High Threshold |
| LowThreshold | Integer | - | 0x5 | Low Threshold |
| ResizeFillValue | Integer | - | 0x7F | Fill Value |
| TopClassK | Integer | - | 1 | First K Categories |
| WidthValue | Integer | - | 0xE0 | OutImageWidth |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| SaveImageEnable | Boolean | 0 | False | 保存缺陷小图 |
| Area | ButtonSelecter | - | - | 缺陷面积 |
| DefectBox | ButtonSelecter | - | - | 缺陷框列表 |
| GrayContrast | ButtonSelecter | - | - | 缺陷对比度 |

### CutDefectStats ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ATEnables | ButtonSelecter | - | - | ATEnable |
| ATStates | ButtonSelecter | - | - | ATState |
| CaiqieStates | ButtonSelecter | - | - | CaiqieState |
| JierEnables | ButtonSelecter | - | - | JierEnable |
| JierStates | ButtonSelecter | - | - | JierState |
| JipianEnables | ButtonSelecter | - | - | JipianEnable |
| JipianStates | ButtonSelecter | - | - | JipianState |
| LightEnables | ButtonSelecter | - | - | LightEnable |
| LightStates | ButtonSelecter | - | - | LightState |
| MarkEnables | ButtonSelecter | - | - | MarkEnable |
| MarkStates | ButtonSelecter | - | - | MarkState |

### CutPointSelect ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| 点位选择s | ButtonSelecter | - | - | 点位选择 |
| 角度阈值s | ButtonSelecter | - | - | 角度阈值 |
| 右侧夹角s | ButtonSelecter | - | - | 右侧夹角 |
| 右侧交点状态s | ButtonSelecter | - | - | 右侧交点状态 |
| 右侧交点Xs | ButtonSelecter | - | - | 右侧交点X |
| 右侧交点Ys | ButtonSelecter | - | - | 右侧交点Y |
| 左侧夹角s | ButtonSelecter | - | - | 左侧夹角 |
| 左侧交点状态s | ButtonSelecter | - | - | 左侧交点状态 |
| 左侧交点Xs | ButtonSelecter | - | - | 左侧交点X |
| 左侧交点Ys | ButtonSelecter | - | - | 左侧交点Y |

### CutStackingRectify ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BaseSnapWorldRs | ButtonSelecter | - | - | 基准拍照点R |
| BaseSnapWorldXs | ButtonSelecter | - | - | 基准拍照点X |
| BaseSnapWorldYs | ButtonSelecter | - | - | 基准拍照点Y |
| CurImageRs | ButtonSelecter | - | - | 运行像素点R |
| CurImageXs | ButtonSelecter | - | - | 运行像素点X |
| CurImageYs | ButtonSelecter | - | - | 运行像素点Y |
| CurSnapWorldRs | ButtonSelecter | - | - | 运行拍照点R |
| CurSnapWorldXs | ButtonSelecter | - | - | 运行拍照点X |
| CurSnapWorldYs | ButtonSelecter | - | - | 运行拍照点Y |
| NozzleIndexs | ButtonSelecter | - | - | 吸嘴序号 |
| RecheckLimitRs | ButtonSelecter | - | - | 复检偏差R |
| RecheckLimitXs | ButtonSelecter | - | - | 复检偏差X |
| RecheckLimitYs | ButtonSelecter | - | - | 复检偏差Y |
| RectifyFlags | ButtonSelecter | - | - | 超限标志位 |
| RectifyLimitRs | ButtonSelecter | - | - | 纠偏偏差R |
| RectifyLimitXs | ButtonSelecter | - | - | 纠偏偏差X |
| RectifyLimitYs | ButtonSelecter | - | - | 纠偏偏差Y |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |

### DataQueueModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Clear | Command | - | - | ClearDataQueue |

### DataRecordModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClearSignal | ButtonSelecter | - | - | Tab_Clear Signal |
| DataRecordFields | ButtonSelecter_IOVar_Record | - | - | Data Set Field List |

### DataSetModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| DefaultIntValue | Integer | 3 | 0 | Default int Value |
| EnableFillValue | Boolean | 1 | False | EnableFillDefaultValue |
| OutputAssembly | Boolean | 0 | False | OutputAssembly |
| ClearSignal | ButtonSelecter | - | - | Tab_Clear Signal |
| DefaultStringValue | String | 2 | null | String Default Value |
| DataSetFields | ButtonSelecter_IOVar | - | - | Data Set Field List |

### DefectDataProcess ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| DefectDatas | ButtonSelecter | - | - | 工艺参数 |
| Param | String | - | "1" | Param |

### DefectSearch ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AreaScreenSize | Integer | - | - | 面积过滤大小 |
| BrightDefect | Integer | - | - | 亮缺陷提取阈值 |
| DarkDefect | Integer | - | - | 暗缺陷提取阈值 |
| DefectFusionDistance | Integer | - | - | 缺陷融合距离 |
| DefectFusionRate | Integer | - | - | 缺陷融合率 |
| DefectMaxNum | Integer | - | - | 最大缺陷个数 |
| FilterSize | Integer | - | - | 滤波尺寸 |
| MorphSize | Integer | - | - | 形态学尺寸 |
| AreaScreenEnable | Boolean | 0 | False | 面积过滤使能 |
| DefectFusionEnable | Boolean | 0 | False | 缺陷融合使能 |
| FilterEnable | Boolean | 0 | True | 滤波使能 |
| MorphEnable | Boolean | 0 | True | 形态学使能 |
| OutPutImageEnable | Boolean | 0 | True | 输出图像使能 |
| BackgroundGrays | ButtonSelecter | - | - | 背景灰度 |
| RegionAngles | ButtonSelecter | - | - | 区域角度 |
| RegionCenterXs | ButtonSelecter | - | - | 区域中心X |
| RegionCenterYs | ButtonSelecter | - | - | 区域中心Y |
| RegionHeights | ButtonSelecter | - | - | 区域高度 |
| RegionWidths | ButtonSelecter | - | - | 区域宽度 |

### DiffCalcuateModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| DistLimitEnable | Boolean | 0 | False | 差值判断 |
| InputAs | ButtonSelecter | - | - | 输入值A |
| InputBs | ButtonSelecter | - | - | 输入值B |

### ExpressionModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ShellContent | ButtonSelecter_Expression | - | - | ExpressionModule |

### FeatrueExtraction ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BrightOrDarkPriority | Integer | - | - | 亮暗优先级 |
| BrightPriorityThreshold | Integer | - | 200 | 优先级高阈值 |
| DarkPriorityThreshold | Integer | - | 30 | 优先级低阈值 |
| DefectNumMax | Integer | - | - | 最大缺陷个数 |
| LowThreshold | Integer | - | - | 暗提取阈值 |
| LowThresholdLight | Integer | - | - | 亮提取阈值 |
| MaxGrayParma | Integer | - | - | 灰度统计个数 |
| MorphSize | Integer | - | - | 形态学尺寸 |
| RemovalHeightGray | Integer | - | 150 | 剔除高阈值 |
| RemovalLowGray | Integer | - | 70 | 剔除低阈值 |
| RemovalSize | Integer | - | - | 剔除尺寸 |
| IsOutputImage | Boolean | 0 | False | 是否输出图像 |
| MorphEnable | Boolean | 0 | False | 形态学使能 |
| PriorityOptimEnable | Boolean | 0 | False | 缺陷极性优化 |
| RemovalEnable | Boolean | 0 | False | 剔除使能 |
| BackgroundGrays | ButtonSelecter | - | - | 背景灰度 |
| DefectAngles | ButtonSelecter | - | - | 缺陷角度 |
| DefectCenterXs | ButtonSelecter | - | - | 缺陷中心X |
| DefectCenterYs | ButtonSelecter | - | - | 缺陷中心Y |
| DefectHeignts | ButtonSelecter | - | - | 缺陷高 |
| DefectNums | ButtonSelecter | - | - | 缺陷数量 |
| DefectPolaritys | ButtonSelecter | - | - | 缺陷极性 |
| DefectWidths | ButtonSelecter | - | - | 缺陷宽 |

### FormatModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| FormatMerge | Boolean | 0 | False | Formalization |

### GenAffineMat ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Phis | ButtonSelecter | - | - | 旋转角度 |
| Sxs | ButtonSelecter | - | - | X方向缩放率 |
| Sys | ButtonSelecter | - | - | Y方向缩放率 |
| Thetas | ButtonSelecter | - | - | 斜切角度(Y轴) |
| Txs | ButtonSelecter | - | - | X方向平移量 |
| Tys | ButtonSelecter | - | - | Y方向平移量 |

### GeometryCreate

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Assist0 | Boolean | 0 | False | Fixture |
| InputType | RadioSelecter | - | 0 | RunParam_Input Type |
| SubInputBox | RadioSelecter | - | 0 | Input Mode |
| SubInputCircle | RadioSelecter | - | 0 | Input Mode |
| SubInputPoint | RadioSelecter | - | 0 | Input Mode |
| ElementType | RadioSelecter3 | - | 0 | Type |
| SelectWay | RadioSelecter3 | - | 0 | Choose Mode |
| SubInputLine | RadioSelecter3 | - | 0 | Input Mode |
| Angle | ButtonSelecter | - | - | Angle |
| Box | ButtonSelecter | - | - | Box |
| BoxAngle | ButtonSelecter | - | - | BoxAngle |
| BoxCenterX | ButtonSelecter | - | - | BoxCenterX |
| BoxCenterY | ButtonSelecter | - | - | BoxCenterY |
| BoxHeight | ButtonSelecter | - | - | BoxHeight |
| BoxWidth | ButtonSelecter | - | - | BoxWidth |
| CenterPointX | ButtonSelecter | - | - | Circle Center X |
| CenterPointY | ButtonSelecter | - | - | Circle Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| CorrectInfo | ButtonSelecter | - | - | Fixture Info |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| InitAngle | ButtonSelecter | - | - | InitAngle |
| InitPoint | ButtonSelecter | - | - | Fixtured Point |
| InitPointBaseX | ButtonSelecter | - | - | InitPointX |
| InitPointBaseY | ButtonSelecter | - | - | InitPointY |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | Point |
| OriginPointX | ButtonSelecter | - | - | PointX |
| OriginPointY | ButtonSelecter | - | - | pointy |
| Radius | ButtonSelecter | - | - | radius |
| RunAngle | ButtonSelecter | - | - | RunAngle |
| RunPoint | ButtonSelecter | - | - | Unfixtured Point |
| RunPointBaseX | ButtonSelecter | - | - | RunPointX |
| RunPointBaseY | ButtonSelecter | - | - | RunPointY |
| RunScaleX | ButtonSelecter | - | - | RunScaleX |
| RunScaleY | ButtonSelecter | - | - | RunScaleY |
| ScaleX | ButtonSelecter | - | - | InitScaleX |
| ScaleY | ButtonSelecter | - | - | InitScaleY |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### GeometryTransform ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Assist0 | Boolean | 0 | False | Fixture |
| InputType | RadioSelecter | - | 0 | RunParam_Input Type |
| SubInputBox | RadioSelecter | - | 0 | Input Mode |
| SubInputCircle | RadioSelecter | - | 0 | Input Mode |
| SubInputPoint | RadioSelecter | - | 0 | Input Mode |
| ElementType | RadioSelecter3 | - | 0 | Type |
| SelectWay | RadioSelecter3 | - | 0 | Choose Mode |
| SubInputLine | RadioSelecter3 | - | 0 | Input Mode |
| Angle | ButtonSelecter | - | - | Angle |
| Box | ButtonSelecter | - | - | Box |
| BoxAngle | ButtonSelecter | - | - | BoxAngle |
| BoxCenterX | ButtonSelecter | - | - | BoxCenterX |
| BoxCenterY | ButtonSelecter | - | - | BoxCenterY |
| BoxHeight | ButtonSelecter | - | - | BoxHeight |
| BoxWidth | ButtonSelecter | - | - | BoxWidth |
| CenterPointX | ButtonSelecter | - | - | Circle Center X |
| CenterPointY | ButtonSelecter | - | - | Circle Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| CorrectInfo | ButtonSelecter | - | - | Fixture Info |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| HomoMat | ButtonSelecter | - | - | 变换矩阵 |
| InitAngle | ButtonSelecter | - | - | InitAngle |
| InitPoint | ButtonSelecter | - | - | Fixtured Point |
| InitPointBaseX | ButtonSelecter | - | - | InitPointX |
| InitPointBaseY | ButtonSelecter | - | - | InitPointY |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | Point |
| OriginPointX | ButtonSelecter | - | - | PointX |
| OriginPointY | ButtonSelecter | - | - | pointy |
| Radius | ButtonSelecter | - | - | radius |
| RunAngle | ButtonSelecter | - | - | RunAngle |
| RunPoint | ButtonSelecter | - | - | Unfixtured Point |
| RunPointBaseX | ButtonSelecter | - | - | RunPointX |
| RunPointBaseY | ButtonSelecter | - | - | RunPointY |
| RunScaleX | ButtonSelecter | - | - | RunScaleX |
| RunScaleY | ButtonSelecter | - | - | RunScaleY |
| ScaleX | ButtonSelecter | - | - | InitScaleX |
| ScaleY | ButtonSelecter | - | - | InitScaleY |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### GlobalCameraModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ConditionalTriggerNumber | Integer | - | 1 | Tab_ConditionalTriggerNumber |
| ConditionalTriggerTimeOut | Integer | - | 0 | Tab_ConditionalTriggerTimeout |
| ImageCacheNum | Integer | 0 | 50 | ImageCacheNum |
| ReconnectTime | Integer | 0 | 0 | RunParam_Reconnect Time |
| SoftTriggerWaitTime | Integer | 0 | 2 | RunParam_SoftTriggerWaitTime |
| WaitForConnectingTime | Integer | 0 | 2 | RunParam_WaitForConnectingTime |
| AutoConnect | Boolean | 0 | False | RunParam_AutoReconnect |
| CloseCache | Boolean | 0 | False | CloseCache |
| Type | RadioSelecter | - | 0 | TypeSelect |
| CameraJack | String | - | 
               | 
               |
| CameraType | String | - | - | - |
| ManufacturerName | String | - | - | - |
| SaveParams | Command | 0 | 0 | SaveCameraParams |
| TriggerSoftware1 | Command | 0 | 0 | 电平触发 |

### GraphicsSetModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CorrectEnable | Boolean | 0 | False | Coordinate Conversion Enable |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| ActualCenterPoints | ButtonSelecter | - | - | Dicing Center Point |
| ActualCenterPointsX | ButtonSelecter | - | - | Dicing Center Point X |
| ActualCenterPointsY | ButtonSelecter | - | - | Dicing Center Point Y |
| DicingHeight | ButtonSelecter | - | - | Dicing Image Height |
| DicingWidth | ButtonSelecter | - | - | Dicing Image Width |

### HandEyeCalibModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RotPointTotalNum | Integer | - | 0 | RotNum |
| RefreshFileEnable | Boolean | - | True | RefreshFileEnable |
| TeachEnable | Boolean | - | False | TeachEnable |
| UnionCalibEnable | Boolean | - | False | UnionCalibEnable |
| CalibPointInput | RadioSelecter | - | 0 | Calibration Points Input |
| ImageRotateAngle | ButtonSelecter | - | - | Image Angle |
| PhyPoint | ButtonSelecter | - | - | WorldPointLst |
| PhyPointX | ButtonSelecter | - | - | Physical Coordinate X |
| PhyPointY | ButtonSelecter | - | - | Physical Coordinate Y |
| PicPoint | ButtonSelecter | - | - | Image Point |
| PicPointX | ButtonSelecter | - | - | ImagePointX |
| PicPointY | ButtonSelecter | - | - | ImagePointY |
| TeachFlag | ButtonSelecter | - | - | External Triggered Character |
| Trigger | ButtonSelecter | - | - | External Input Character |
| WorldRotateAngle | ButtonSelecter | - | - | RunParam_WorldRotateAngle |
| Clear | Command | - | - | ClearPoint |

### IMVS2dArrayCorrectModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ArrayColsNum | Integer | - | 0x0c | RunParam_Array clos |
| ArrayRowsNum | Integer | - | 0x06 | RunParam_Array rows |
| MatchNum | ButtonSelecter | - | - | MatchNum |
| MatchScore | ButtonSelecter | - | - | RunParam_matchscore |
| Region | ButtonSelecter | - | - | Region |

### IMVS2dBcrModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| LocCodeNum | Integer | - | 0x5 | RunParam_2D Code Number |
| MaxBarSize | Integer | - | 300 | Max. Code Width |
| MinBarSize | Integer | - | 40 | Min. Code Width |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| SampleLevel | Integer | - | 1 | RunParam_Subsampling Ratio |
| WaitingTime | Integer | - | 1000 | RunParam_Timeout-Period to Exit |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| DMCode | Boolean | 0 | True | DM Code |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| QRCode | Boolean | 0 | True | QR Code |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| UserString | String | - | 0 | UDC |

### IMVSAffineTransformModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ExtensionValue | Integer | - | 0x0 | Fill Value |
| HeightValue | Integer | - | 0x64 | MergeBoxHeight |
| MoveXValue | Integer | - | 0x0 | RunParam_MoveX Value |
| MoveYValue | Integer | - | 0x0 | RunParam_MoveY Value |
| WidthValue | Integer | - | 0x64 | OverRideWidth |
| LockOutputImageSize | Boolean | 0 | False | RunParam_Lock OutputImageSize |

### IMVSAngleBisectorFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| Angle | ButtonSelecter | - | - | Angle |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPoint2 | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointX2 | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| EndPointY2 | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| LINE2 | ButtonSelecter | - | - | select Line |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPoint2 | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointX2 | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |
| StartPointY2 | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSBcrModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BarNum | Integer | - | 0x1 | RunParam_Bar Code Number |
| DfkMaxSize | Integer | - | 2400 | DfkSize Upper Limit |
| DfkMinSize | Integer | - | 30 | DfkSize Lower Limit |
| LocWinSize | Integer | - | 0x5 | Detection Window Size |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| PreSampleLevel | Integer | - | 0x1 | 降采样系数 |
| SegQuietW | Integer | - | 30 | RunParam_Quiet Zone Width |
| WaitingTime | Integer | - | 1000 | RunParam_Timeout-Period to Exit |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| CODABAR | Boolean | 0 | True | Codabar |
| CODE128 | Boolean | 0 | True | CODE 128 |
| CODE39 | Boolean | 0 | True | CODE 39 |
| CODE93 | Boolean | 0 | True | CODE 93 |
| DebugFlag | Boolean | 0 | True | Debugging Info. Switch |
| DelErrFlag | Boolean | 0 | True | RunParam_ |
| EAN | Boolean | 0 | True | EAN |
| ITF25 | Boolean | 0 | True | ITF25 |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| UserString | String | - | 0 | UDC |

### IMVSBinaryModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| GaussKernelSize | Integer | - | 0x3 | Gaussian Filter Kernel |
| HighThreshold | Integer | - | 0xFF | High Threshold |
| KernelHeight | Integer | - | 0x3 | Filter Kernel Height |
| KernelWidth | Integer | - | 0x3 | Filter Kernel Width |
| LowThreshold | Integer | - | 0x64 | Low Threshold |
| SauvolaWinHeight | Integer | - | 0x0F | Filter Kernel Height |
| SauvolaWinWidth | Integer | - | 0x0F | Filter Kernel Width |
| ThresholdOffset | Integer | - | 0x0 | Threshold Offset |

### IMVSBlobFindLabelsModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlobNumLimitHigh | Integer | - | 99999 | Blob Number Upper Limit |
| BlobNumLimitLow | Integer | - | 1 | Blob Number Lower Limit |
| FindNum | Integer | - | 0x64 | RunParam_Number to Find |
| MaxArea | Integer | - | 999999999 | Max Area |
| MaxLongAxis | Integer | - | 999999999 | Max Major Axis |
| MaxOutPixelNum | Integer | - | 0 | MaxOutPixelNum |
| MaxPerimeter | Integer | - | 999999999 | Max Perimeter |
| MaxShortAxis | Integer | - | 999999999 | Max Minor Axis |
| MinArea | Integer | - | 10 | Min Area |
| MinLongAxis | Integer | - | 10 | Min Major Axis |
| MinPerimeter | Integer | - | 10 | Min Perimeter |
| MinShortAxis | Integer | - | 1 | Min Minor Axis |
| OverlapRatio | Integer | - | 0 | MinOverlap |
| AngleLimitEnable | Boolean | 0 | False | RunParam_BoxAngle Check |
| AxisRatioEnable | Boolean | 0 | False | RunParam_Axial Ratio |
| BlobAreaLimitEnable | Boolean | 0 | False | Blob Area Check |
| BlobNumLimitEnable | Boolean | 0 | False | Blob Number Check |
| BlobTotalAreaLimitEnable | Boolean | 0 | False | RunParam_Blob Total Area Check |
| BolbImageEnable | Boolean | 0 | True | RunParam_BolbImageEnable |
| BolbOutLineEnable | Boolean | 0 | False | RunParam_BolbOutLineEnable |
| BoxHeightLimitEnable | Boolean | 0 | False | Box Height Check |
| BoxWidthLimitEnable | Boolean | 0 | False | RunParam_Box Width Check |
| CenterXLimitEnable | Boolean | 0 | False | Center X Check |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| CentroidXLimitEnable | Boolean | 0 | False | Barycenter X Check |
| CentroidYLimitEnable | Boolean | 0 | False | Barycenter Y Check |
| CircularityLimitEnable | Boolean | 0 | False | Circularity Check |
| LabelWiseAreaSelectEnable | Boolean | 0 | False | Enable label-level area filtering |
| LongAxisLimitEnable | Boolean | 0 | False | Major Axis Check |
| MaxOutPixelNumEnable | Boolean | - | False | RunParam_MaxOutPixelNumEnable |
| PerimeterLimitEnable | Boolean | 0 | False | Perimeter Check |
| RectangularityLimitEnable | Boolean | 0 | False | Rectangularity Check |
| SelectByArea | Boolean | 0 | False | Global Area Enable |
| SelectByCentraBias | Boolean | 0 | False | RunParam_Barycenter Offset Enable |
| SelectByCircularuty | Boolean | 0 | False | Circularity Enable |
| SelectByLongAxis | Boolean | 0 | False | Major Axis Enable |
| SelectByPerimeter | Boolean | 0 | False | RunParam_Perimeter Enable |
| SelectByRectangularity | Boolean | 0 | False | Rectangularity Enable |
| SelectByShortAxis | Boolean | 0 | False | Minor Axis Enable |
| ShortAxisLimitEnable | Boolean | 0 | False | Minor Axis Check |
| ClassName | ButtonSelecter | - | - | ClassName |
| GrayValue | ButtonSelecter | - | - | GrayValue |

### IMVSBlobFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlobNumLimitHigh | Integer | - | 99999 | Blob Number Upper Limit |
| BlobNumLimitLow | Integer | - | 1 | Blob Number Lower Limit |
| FindNum | Integer | - | 100 | RunParam_Number to Find |
| HightSoftThreshold | Integer | - | 0x96 | RunParam_Soft High Threshold |
| HightThreshold | Integer | - | 0x96 | High Threshold |
| HoleMinArea | Integer | - | 0 | Fill Area Threshold |
| LowSoftThreshold | Integer | - | 0x64 | RunParam_Soft Low Threshold |
| LowThreshold | Integer | - | 0x64 | Low Threshold |
| MaxArea | Integer | - | 999999999 | Max Area |
| MaxAreaInnerRectNum | Integer | - | 0x0 | RunParam_MaxAreaInnerRectNum |
| MaxBoxAngle | Integer | - | 90 | RunParam_Max BoxAngle |
| MaxLongAxis | Integer | - | 999999999 | Max Major Axis |
| MaxOutPixelNum | Integer | - | 0 | MaxOutPixelNum |
| MaxPerimeter | Integer | - | 999999999 | Max Perimeter |
| MaxRectHeight | Integer | - | 200 | Max RectHeight |
| MaxRectWidth | Integer | - | 200 | Max RectWidth |
| MaxShortAxis | Integer | - | 999999999 | Max Minor Axis |
| MinArea | Integer | - | 10 | Min Area |
| MinBoxAngle | Integer | - | -90 | RunParam_Min BoxAngle |
| MinLongAxis | Integer | - | 10 | Min Major Axis |
| MinPerimeter | Integer | - | 10 | Min Perimeter |
| MinRectHeight | Integer | - | 100 | Min RectHeight |
| MinRectWidth | Integer | - | 100 | Min RectWidth |
| MinShortAxis | Integer | - | 1 | Min Minor Axis |
| OverlapRatio | Integer | - | 0 | MinOverlap |
| SoftHighRatio | Integer | - | 60 | High Threshold Ratio |
| SoftLeftRatio | Integer | - | 5 | RunParam_Low Tail Ratio |
| SoftLowRatio | Integer | - | 40 | Low Threshold Ratio |
| Softness | Integer | - | 254 | Soft Threshold Softness |
| SoftRightRatio | Integer | - | 5 | RunParam_High Tail Ratio |
| AngleLimitEnable | Boolean | 0 | False | RunParam_BoxAngle Check |
| AxisRatioEnable | Boolean | 0 | False | RunParam_Axial Ratio |
| BinaryImageEnable | Boolean | 0 | True | RunParam_BinaryImageEnable |
| BlobAreaLimitEnable | Boolean | 0 | False | Blob Area Check |
| BlobAreaProportionLimitEnable | Boolean | 0 | False | Blob Area Proportion Check |
| BlobNumLimitEnable | Boolean | 0 | False | Blob Number Check |
| BlobTotalAreaLimitEnable | Boolean | 0 | False | RunParam_Blob Total Area Check |
| BlobTotalAreaProportionLimitEnable | Boolean | - | False | Blob Total Area Proportion Check |
| BolbImageEnable | Boolean | 0 | True | RunParam_BolbImageEnable |
| BoxHeightLimitEnable | Boolean | 0 | False | Box Height Check |
| BoxWidthLimitEnable | Boolean | 0 | False | RunParam_Box Width Check |
| CenterXLimitEnable | Boolean | 0 | False | Center X Check |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| CentroidXLimitEnable | Boolean | 0 | False | Barycenter X Check |
| CentroidYLimitEnable | Boolean | 0 | False | Barycenter Y Check |
| CircularityLimitEnable | Boolean | 0 | False | Circularity Check |
| LongAxisLimitEnable | Boolean | 0 | False | Major Axis Check |
| MaxOutPixelNumEnable | Boolean | 0 | False | RunParam_MaxOutPixelNumEnable |
| OKWhenNumIsZero | Boolean | 0 | False | OKWhenNumIsZero |
| PerimeterLimitEnable | Boolean | 0 | False | Perimeter Check |
| RectangularityLimitEnable | Boolean | 0 | False | Rectangularity Check |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |
| SelectByArea | Boolean | 0 | True | Area Enable |
| SelectByBoxAngle | Boolean | 0 | False | Angle Enable |
| SelectByCentraBias | Boolean | 0 | False | RunParam_Barycenter Offset Enable |
| SelectByCircularuty | Boolean | 0 | False | Circularity Enable |
| SelectByHistInfo | Boolean | 0 | False | RunParam_SelectByHistInfoEnable |
| SelectByLongAxis | Boolean | 0 | False | Major Axis Enable |
| SelectByPerimeter | Boolean | 0 | False | RunParam_Perimeter Enable |
| SelectByRectangularity | Boolean | 0 | False | Rectangularity Enable |
| SelectByRectHeight | Boolean | 0 | False | RectHeight Enable |
| SelectByRectWidth | Boolean | 0 | False | RectWidth Enable |
| SelectByShortAxis | Boolean | 0 | False | Minor Axis Enable |
| ShortAxisLimitEnable | Boolean | 0 | False | Minor Axis Check |

### IMVSBlobFindMultiModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlobNumLimitHigh | Integer | - | 99999 | Blob Number Upper Limit |
| BlobNumLimitHigh | Integer | - | 99999 | Blob Number Upper Limit |
| BlobNumLimitLow | Integer | - | 1 | Blob Number Lower Limit |
| BlobNumLimitLow | Integer | - | 1 | Blob Number Lower Limit |
| FindNum | Integer | - | 100 | RunParam_Number to Find |
| HightSoftThreshold | Integer | - | 0x96 | RunParam_Soft High Threshold |
| HightThreshold | Integer | - | 0x96 | High Threshold |
| HoleMinArea | Integer | - | 0 | Fill Area Threshold |
| LowSoftThreshold | Integer | - | 0x64 | RunParam_Soft Low Threshold |
| LowThreshold | Integer | - | 0x64 | Low Threshold |
| MaxArea | Integer | - | 999999999 | Max Area |
| MaxLongAxis | Integer | - | 999999999 | Max Major Axis |
| MaxOutPixelNum | Integer | - | 0 | MaxOutPixelNum |
| MaxPerimeter | Integer | - | 999999999 | Max Perimeter |
| MaxRectHeight | Integer | - | 200 | Max RectHeight |
| MaxRectWidth | Integer | - | 200 | Max RectWidth |
| MaxShortAxis | Integer | - | 999999999 | Max Minor Axis |
| MinArea | Integer | - | 10 | Min Area |
| MinLongAxis | Integer | - | 10 | Min Major Axis |
| MinPerimeter | Integer | - | 10 | Min Perimeter |
| MinRectHeight | Integer | - | 100 | Min RectHeight |
| MinRectWidth | Integer | - | 100 | Min RectWidth |
| MinShortAxis | Integer | - | 1 | Min Minor Axis |
| OverlapRatio | Integer | - | 0 | MinOverlap |
| SoftHighRatio | Integer | - | 60 | High Threshold Ratio |
| SoftLeftRatio | Integer | - | 5 | RunParam_Low Tail Ratio |
| SoftLowRatio | Integer | - | 40 | Low Threshold Ratio |
| Softness | Integer | - | 254 | Soft Threshold Softness |
| SoftRightRatio | Integer | - | 5 | RunParam_High Tail Ratio |
| AngleLimitEnable | Boolean | 0 | False | RunParam_BoxAngle Check |
| BinaryImageEnable | Boolean | 0 | True | RunParam_BinaryImageEnable |
| BinaryImageEnable | Boolean | 0 | True | RunParam_BinaryImageEnable |
| BlobAreaLimitEnable | Boolean | 0 | False | Blob Area Check |
| BlobAreaProportionLimitEnable | Boolean | 0 | False | Blob Area Proportion Check |
| BlobNumLimitEnable | Boolean | 0 | False | Blob Number Check |
| BlobNumLimitEnable | Boolean | 0 | False | Blob Number Check |
| BlobTotalAreaLimitEnable | Boolean | 0 | False | RunParam_Blob Total Area Check |
| BlobTotalAreaLimitEnable | Boolean | 0 | False | RunParam_Blob Total Area Check |
| BlobTotalAreaProportionLimitEnable | Boolean | - | False | Blob Total Area Proportion Check |
| BlobTotalAreaProportionLimitEnable | Boolean | - | False | Blob Total Area Proportion Check |
| BolbImageEnable | Boolean | 0 | True | RunParam_BolbImageEnable |
| BolbImageEnable | Boolean | 0 | True | RunParam_BolbImageEnable |
| BoxHeightLimitEnable | Boolean | 0 | False | Box Height Check |
| BoxWidthLimitEnable | Boolean | 0 | False | RunParam_Box Width Check |
| CenterXLimitEnable | Boolean | 0 | False | Center X Check |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| CentroidXLimitEnable | Boolean | 0 | False | Barycenter X Check |
| CentroidYLimitEnable | Boolean | 0 | False | Barycenter Y Check |
| CircularityLimitEnable | Boolean | 0 | False | Circularity Check |
| InputMaskEnable | Boolean | 0 | False | Input Mask Enable |
| LongAxisLimitEnable | Boolean | 0 | False | Major Axis Check |
| MaxOutPixelNumEnable | Boolean | 0 | False | RunParam_MaxOutPixelNumEnable |
| OKWhenNumIsZero | Boolean | 0 | False | OKWhenNumIsZero |
| PerimeterLimitEnable | Boolean | 0 | False | Perimeter Check |
| RectangularityLimitEnable | Boolean | 0 | False | Rectangularity Check |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |
| SelectByArea | Boolean | 0 | True | Area Enable |
| SelectByAxisRatio | Boolean | 0 | False | RunParam_Axial Ratio |
| SelectByBoxAngle | Boolean | 0 | False | Angle Enable |
| SelectByCentraBias | Boolean | 0 | False | RunParam_Barycenter Offset Enable |
| SelectByCircularuty | Boolean | 0 | False | Circularity Enable |
| SelectByHistInfo | Boolean | 0 | False | RunParam_SelectByHistInfoEnable |
| SelectByLongAxis | Boolean | 0 | False | Major Axis Enable |
| SelectByPerimeter | Boolean | 0 | False | RunParam_Perimeter Enable |
| SelectByRectangularity | Boolean | 0 | False | Rectangularity Enable |
| SelectByRectHeight | Boolean | 0 | False | RectHeight Enable |
| SelectByRectWidth | Boolean | 0 | False | RectWidth Enable |
| SelectByShortAxis | Boolean | 0 | False | Minor Axis Enable |
| ShortAxisLimitEnable | Boolean | 0 | False | Minor Axis Check |
| UseFirstROIRunParamEnable | Boolean | 0 | True | RunParam_UseFirstROIRunParamEnable |
| InheritWay | RadioSelecter3 | - | 0 | Inheritance Mode |
| ClassLabel | ButtonSelecter | - | - | Tag Attribute |
| Region | ButtonSelecter | - | - | Region |
| Region2 | ButtonSelecter | - | - | Region |
| ROIAngle | ButtonSelecter | - | - | roiangle |
| ROIAnnulusAngleExtend | ButtonSelecter | - | - | AngleRange |
| ROIAnnulusCenterX | ButtonSelecter | - | - | roiAnnulusCenterX |
| ROIAnnulusCenterY | ButtonSelecter | - | - | roiAnnulusCenterY |
| ROIAnnulusInnerRadius | ButtonSelecter | - | - | CircleInnerRadius |
| ROIAnnulusOuterRadius | ButtonSelecter | - | - | roiAnnulusOuterRadius |
| ROIAnnulusStartAngle | ButtonSelecter | - | - | Angle Start |
| ROICenterX | ButtonSelecter | - | - | roicenterx |
| ROICenterY | ButtonSelecter | - | - | roicentery |
| ROIHeight | ButtonSelecter | - | - | roiheight |
| ROIWidth | ButtonSelecter | - | - | roiwidth |

### IMVSBoxFilterModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InheritWay | RadioSelecter | - | 0 | - |
| Region | ButtonSelecter | - | - | Region |
| ROIAngle | ButtonSelecter | - | - | roiangle |
| ROICenterX | ButtonSelecter | - | - | roicenterx |
| ROICenterY | ButtonSelecter | - | - | roicentery |
| ROIHeight | ButtonSelecter | - | - | roiheight |
| ROIWidth | ButtonSelecter | - | - | roiwidth |

### IMVSBoxMergeModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| MergeWinNumThresh | Integer | - | 50 | MergeWinNumThresh |
| MergeWinSizeX | Integer | - | 50 | MergeWinSizeX |
| MergeWinSizeY | Integer | - | 50 | MergeWinSizeY |
| OverlapThresh | Integer | - | - | OverlapRate |
| InheritWay | RadioSelecter | - | 0 | - |
| BoxArea | ButtonSelecter | - | - | Box面积 |
| BoxLabel | ButtonSelecter | - | - | MergeBoxLabel |
| BoxLabel | ButtonSelecter | - | - | MergeBoxLabel |
| BoxLongAxis | ButtonSelecter | - | - | BoxLongAxis |
| BoxShortAxis | ButtonSelecter | - | - | BoxShortAxis |
| FlawPriority | ButtonSelecter | - | - | Flaw Priority |
| MatchNum | ButtonSelecter | - | - | MatchNum |
| MatchScore | ButtonSelecter | - | - | RunParam_matchscore |
| ROIAngle | ButtonSelecter | - | - | roiangle |
| ROICenterX | ButtonSelecter | - | - | roicenterx |
| ROICenterY | ButtonSelecter | - | - | roicentery |
| ROIHeight | ButtonSelecter | - | - | roiheight |
| ROIWidth | ButtonSelecter | - | - | roiwidth |
| RunParam_Region | ButtonSelecter | - | - | Region |

### IMVSBoxOverlapCalculationModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Threshold | Integer | - | 0x32 | OverlapRate |
| InheritWay | RadioSelecter | - | 0 | - |
| ROI1Angle | ButtonSelecter | - | - | Roi1Angle |
| ROI1CenterX | ButtonSelecter | - | - | Roi1CenterX |
| ROI1CenterY | ButtonSelecter | - | - | Roi1CenterY |
| ROI1Height | ButtonSelecter | - | - | Roi1Height |
| ROI1Width | ButtonSelecter | - | - | Roi1Width |
| ROI2Angle | ButtonSelecter | - | - | Roi2Angle |
| ROI2CenterX | ButtonSelecter | - | - | Roi2CenterX |
| ROI2CenterY | ButtonSelecter | - | - | Roi2CenterY |
| ROI2Height | ButtonSelecter | - | - | Roi2Height |
| ROI2Width | ButtonSelecter | - | - | Roi2Width |
| RunParam_Region1 | ButtonSelecter | - | - | RunParam_Region1 |
| RunParam_Region2 | ButtonSelecter | - | - | RunParam_Region2 |

### IMVSC2CMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CCDCircleThresh1 | Integer | - | 0xa | RunParam_Locating Sensitivity1 |
| CCDCircleThresh2 | Integer | - | 0xa | RunParam_Locating Sensitivity2 |
| CCDSampleScale1 | Integer | - | 0x8 | RunParam_Subsampling Coefficient1 |
| CCDSampleScale2 | Integer | - | 0x8 | RunParam_Subsampling Coefficient2 |
| EdgeThresh1 | Integer | - | 0xf | RunParam_Contrast Threshold1 |
| EdgeThresh2 | Integer | - | 0xf | RunParam_Contrast Threshold2 |
| EdgeWidth1 | Integer | - | 0x1 | RunParam_EdgeWidth1 |
| EdgeWidth2 | Integer | - | 0x1 | RunParam_EdgeWidth2 |
| ProLength1 | Integer | - | 0x5 | RunParam_Projection Width1 |
| ProLength2 | Integer | - | 0x5 | RunParam_Projection Width2 |
| RadNum1 | Integer | - | 0x1e | RunParam_Caliper Number1 |
| RadNum2 | Integer | - | 0x1e | RunParam_Caliper Number2 |
| RejectDist1 | Integer | - | 5 | RunParam_Distance to remove1 |
| RejectDist2 | Integer | - | 5 | RunParam_Distance to remove2 |
| RejectNum1 | Integer | - | 0 | RunParam_Number of Points to remove1 |
| RejectNum2 | Integer | - | 0 | RunParam_Number of Points to remove2 |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| CoarseDetectFlag1 | Boolean | 0 | False | RunParam_Init Locating1 |
| CoarseDetectFlag2 | Boolean | 0 | False | RunParam_Init Locating2 |
| DistLimitEnable | Boolean | 0 | False | Distance Check |
| Inter1XLimitEnable | Boolean | 0 | False | Intersection 1X Check |
| Inter1YLimitEnable | Boolean | 0 | False | Intersection 1Y Check |
| Inter2XLimitEnable | Boolean | 0 | False | Intersection 2X Check |
| Inter2YLimitEnable | Boolean | 0 | False | Intersection 2Y Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay2 | RadioSelecter | - | 0 | Input Mode |
| SourceSelect | RadioSelecter | - | 1 | Source_selection |
| AngleExtend | ButtonSelecter | - | - | AngleRange |
| AngleExtend2 | ButtonSelecter | - | - | AngleRange |
| CenterPointX | ButtonSelecter | - | - | Circle Center X |
| CenterPointX2 | ButtonSelecter | - | - | Circle Center X |
| CenterPointY | ButtonSelecter | - | - | Circle Center Y |
| CenterPointY2 | ButtonSelecter | - | - | Circle Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| Circle2 | ButtonSelecter | - | - | Circle |
| InnerRadius | ButtonSelecter | - | - | InnerRadius |
| InnerRadius2 | ButtonSelecter | - | - | InnerRadius |
| OriginPoint | ButtonSelecter | - | - | CorCalibMatrix |
| Radius | ButtonSelecter | - | - | radius |
| Radius2 | ButtonSelecter | - | - | radius |
| StartAngle | ButtonSelecter | - | - | StartAngle |
| StartAngle2 | ButtonSelecter | - | - | StartAngle |

### IMVSCalibBoardCalibModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Circularity | Integer | - | 50 | RunParam_Dot Circularity |
| DistThreshold | Integer | - | 30 | Dis Thre |
| EdgeThreshHigh | Integer | - | 40 | Edge High Threshold |
| EdgeThreshLow | Integer | - | 20 | Edge Low Threshold |
| GrayContrast | Integer | - | 15 | RunParam_Grayscale Contrast |
| SampleRatio | Integer | - | 60 | Sampling Rate |
| SubPixelWindowSize | Integer | - | 30 | 设置窗口大小 |
| WeightFactor | Integer | - | 20 | RunParam_Weighting Coefficient |
| RefreshFileEnable | Boolean | - | False | RefreshFileEnable |

### IMVSCalibTransformModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CalibLoadType | RadioSelecter | - | 0 | CalibLoadType |
| InputMode | RadioSelecter | - | 0 | Input Mode |
| CalibMatrix | ButtonSelecter | - | - | CalibMatrix |
| PicPoint | ButtonSelecter | - | - | Trans Point |
| PicPointA | ButtonSelecter | - | - | Angle |
| PicPointX | ButtonSelecter | - | - | Trans Coordinate X |
| PicPointY | ButtonSelecter | - | - | Trans Coordinate Y |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |

### IMVSCaliperCornerModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperNum | Integer | - | 30 | Caliper Number |
| EdgeStrength | Integer | - | 0x5 | EdgeThreshold |
| KernelSize | Integer | - | 0x1 | KernelSize |
| ProjectLen | Integer | - | 0x5 | Projection Width |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0x0 | Number of Points to remove |
| CornerAngleLimitEnable | Boolean | 0 | False | RunParam_Intersection Angle Check |
| CornerPointXLimitEnable | Boolean | 0 | False | Intersection X Check |
| CornerPointYLimitEnable | Boolean | 0 | False | Intersection Y Check |
| InheritWay | RadioSelecter | - | 0 | Inheritance Mode |
| Region1 | ButtonSelecter | - | - | RunParam_Region1 |
| Region2 | ButtonSelecter | - | - | RunParam_Region2 |
| ROI1Angle | ButtonSelecter | - | - | Roi1Angle |
| ROI1CenterX | ButtonSelecter | - | - | Roi1CenterX |
| ROI1CenterY | ButtonSelecter | - | - | Roi1CenterY |
| ROI1Height | ButtonSelecter | - | - | Roi1Height |
| ROI1Width | ButtonSelecter | - | - | Roi1Width |
| ROI2Angle | ButtonSelecter | - | - | Roi2Angle |
| ROI2CenterX | ButtonSelecter | - | - | Roi2CenterX |
| ROI2CenterY | ButtonSelecter | - | - | Roi2CenterY |
| ROI2Height | ButtonSelecter | - | - | Roi2Height |
| ROI2Width | ButtonSelecter | - | - | Roi2Width |

### IMVSCaliperEdgeModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ContrastTH | Integer | - | 0x5 | EdgeThreshold |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| Maximum | Integer | - | 0x1 | Max Result Number |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| EdgePointXLimitEnable | Boolean | 0 | False | Edge Point X Check |
| EdgePointYLimitEnable | Boolean | 0 | False | Edge Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |

### IMVSCaliperModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ContrastTH | Integer | - | 0xf | EdgeThreshold |
| ContrastX0 | Integer | - | 0x0 | Startpoint |
| ContrastX1 | Integer | - | 0x0 | RunParam_Midpoint |
| ContrastXC | Integer | - | 0xff | Endpoint |
| ContrastY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| ContrastY1 | Integer | - | 0x64 | RunParam_Highest Score |
| EdgePairWidth | Integer | - | 0xa | EdgePairWidth |
| GrayscaleX0 | Integer | - | 0x0 | Startpoint |
| GrayscaleX1 | Integer | - | 0x0 | RunParam_Midpoint |
| GrayscaleXC | Integer | - | 0xff | Endpoint |
| GrayscaleY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| GrayscaleY1 | Integer | - | 0x64 | RunParam_Highest Score |
| HalfKernelSize | Integer | - | 0x2 | KernelSize |
| Maximum | Integer | - | 0x1 | Max Result Number |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| PositionNegX0 | Integer | - | 0xffffff9c | Startpoint |
| PositionNegX1 | Integer | - | 0x64 | RunParam_Midpoint |
| PositionNegXC | Integer | - | 0x2710 | Endpoint |
| PositionNegY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| PositionNegY1 | Integer | - | 0x64 | RunParam_Highest Score |
| PositionNormNegX0 | Integer | - | 0xfffffffb | Startpoint |
| PositionNormNegX1 | Integer | - | 0x5 | RunParam_Midpoint |
| PositionNormNegXC | Integer | - | 0x5 | Endpoint |
| PositionNormNegY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| PositionNormNegY1 | Integer | - | 0x64 | RunParam_Highest Score |
| PositionNormX0 | Integer | - | 0x0 | Startpoint |
| PositionNormX1 | Integer | - | 0x5 | RunParam_Midpoint |
| PositionNormXC | Integer | - | 0x5 | Endpoint |
| PositionNormY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| PositionNormY1 | Integer | - | 0x64 | RunParam_Highest Score |
| PositionX0 | Integer | - | 0x0 | Startpoint |
| PositionX1 | Integer | - | 0x64 | RunParam_Midpoint |
| PositionXC | Integer | - | 0x2710 | Endpoint |
| PositionY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| PositionY1 | Integer | - | 0x64 | RunParam_Highest Score |
| SizeDiffNormAsymX0 | Integer | - | 0xffffffff | Startpoint |
| SizeDiffNormAsymX0H | Integer | - | 0x0 | Startpoint |
| SizeDiffNormAsymX1 | Integer | - | 0xffffffff | RunParam_Midpoint |
| SizeDiffNormAsymX1H | Integer | - | 0x2 | RunParam_Midpoint |
| SizeDiffNormAsymXC | Integer | - | 0x0 | Endpoint |
| SizeDiffNormAsymXCH | Integer | - | 0x2 | Endpoint |
| SizeDiffNormAsymY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| SizeDiffNormAsymY0H | Integer | - | 0x0 | RunParam_Lowest Score |
| SizeDiffNormAsymY1 | Integer | - | 0x64 | RunParam_Highest Score |
| SizeDiffNormAsymY1H | Integer | - | 0x64 | RunParam_Highest Score |
| SizeDiffNormX0 | Integer | - | 0x0 | Startpoint |
| SizeDiffNormX1 | Integer | - | 0x1 | RunParam_Midpoint |
| SizeDiffNormXC | Integer | - | 0x1 | Endpoint |
| SizeDiffNormY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| SizeDiffNormY1 | Integer | - | 0x64 | RunParam_Highest Score |
| SizeNormX0 | Integer | - | 0x0 | Startpoint |
| SizeNormX1 | Integer | - | 0x0 | RunParam_Midpoint |
| SizeNormXC | Integer | - | 0x5 | Endpoint |
| SizeNormY0 | Integer | - | 0x0 | RunParam_Lowest Score |
| SizeNormY1 | Integer | - | 0x64 | RunParam_Highest Score |
| TotalNumLimitHigh | Integer | - | 99999 | Total Quantity Upper Limit |
| TotalNumLimitLow | Integer | - | 0 | Total Quantity Lower Limit |
| ContrastEnable | Boolean | 0 | True | HistContrast |
| ContrastPairEnable | Boolean | 0 | False | RunParam_Contrast Pair |
| Edge0PointXLimitEnable | Boolean | 0 | False | Edge Point 0X Check |
| Edge0PointYLimitEnable | Boolean | 0 | False | Edge Point 0Y Check |
| Edge1PointXLimitEnable | Boolean | 0 | False | Edge Point 1X Check |
| Edge1PointYLimitEnable | Boolean | 0 | False | Edge Point 1Y Check |
| EdgeWidthLimitEnable | Boolean | 0 | False | Width Check |
| FuzzyedgeFlag | Boolean | 0 | False | RunParam_Fuzzyedge Considered |
| GrayscaleEnable | Boolean | 0 | False | RunParam_Grayscale |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| PositionEnable | Boolean | 0 | False | RunParam_Position |
| PositionNegEnable | Boolean | 0 | False | RunParam_Relative Position |
| PositionNormEnable | Boolean | 0 | False | RunParam_Normalized Position |
| PositionNormNegEnable | Boolean | 0 | False | RunParam_Normalized Relative Position |
| SizeDiffNormAsymEnable | Boolean | 0 | False | RunParam_Relative Interval Difference |
| SizeDiffNormEnable | Boolean | 0 | True | RunParam_Interval Difference |
| SizeNormEnable | Boolean | 0 | False | RunParam_Interval |
| TotalNumLimitEnable | Boolean | 0 | False | Total Quantity Check |

### IMVSCameraMapModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| WeightFactor | Integer | - | 20 | RunParam_Weighting Coefficient |
| RefreshFileEnable | Boolean | - | False | RefreshFileEnable |
| InputWay | RadioSelecter | - | 0 | Input Mode |

### IMVSCellLocationModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| FrontSolarCellNum | Integer | - | - | Front Solar Cell Num |
| ReverseSolarCellNum | Integer | - | - | Reverse Solar Cell Num |
| MatchBoxAngle | ButtonSelecter | - | - | MatchBoxAngle |
| MatchBoxCenterX | ButtonSelecter | - | - | MatchBoxCenterX |
| MatchBoxCenterY | ButtonSelecter | - | - | MatchBoxCenterY |
| MatchBoxHeight | ButtonSelecter | - | - | MatchBoxHeight |
| MatchBoxWidth | ButtonSelecter | - | - | MatchBoxWidth |
| MatchNums | ButtonSelecter | - | - | MatchNum |
| MatchPointX | ButtonSelecter | - | - | MatchPointX |
| MatchPointY | ButtonSelecter | - | - | MatchPointY |
| MatchRmss | ButtonSelecter | - | - | Match Rms |
| MatchScales | ButtonSelecter | - | - | Match Scale |
| MatchScaleXs | ButtonSelecter | - | - | Match Scale X |
| MatchScaleYs | ButtonSelecter | - | - | Match Scale Y |
| MatchScores | ButtonSelecter | - | - | Match Score |

### IMVSCharExtractionModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BinarizeWinSize | Integer | - | 0xF | 二值化窗口大小 |
| HardThreshold | Integer | - | 0x80 | 字符分割硬阈值 |
| MaxCharWidth | Integer | - | 0xF | 最大字符宽度 |
| MinCharArea | Integer | - | 0xA | 最小字符面积 |
| MinCharWidth | Integer | - | 0xA | 最小字符宽度 |

### IMVSCircleEdgeInspModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperWidth | Integer | - | 0x5 | CaliperWidth |
| CircleCaliperNum | Integer | - | 20 | Caliper Number |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinDis | Integer | - | 5 | RunParam_RoughMinDis |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| StandardInput | Boolean | 0 | False | 标准输入 |
| InputWay2 | RadioSelecter | - | 0 | Input Mode |
| AngleExtend | ButtonSelecter | - | - | AngleRange |
| CenterPointX | ButtonSelecter | - | - | Circular Annulus Center X |
| CenterPointY | ButtonSelecter | - | - | Circular Annulus Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| InnerRadius | ButtonSelecter | - | - | InnerRadius |
| OuterRadius | ButtonSelecter | - | - | OuterRadius |
| StartAngle | ButtonSelecter | - | - | Angle Start |

### IMVSCircleEdgePairInspModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperWidth | Integer | - | 0x5 | CaliperWidth |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| FitCaliperNum | Integer | - | 20 | Caliper Number |
| FitConcentricTol | Integer | - | 50 | RunParam_AngleTolerance |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| RoughMaxDis | Integer | - | 50 | Max. Distance |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinDis | Integer | - | 5 | Min. Distance |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| StandardInput | Boolean | 0 | False | 标准输入 |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay2 | RadioSelecter | - | 0 | Input Mode |
| AngleExtend1 | ButtonSelecter | - | - | AngleRange |
| AngleExtend2 | ButtonSelecter | - | - | AngleRange |
| CenterPointX1 | ButtonSelecter | - | - | Circular Annulus Center X |
| CenterPointX2 | ButtonSelecter | - | - | Circular Annulus Center X |
| CenterPointY1 | ButtonSelecter | - | - | Circular Annulus Center Y |
| CenterPointY2 | ButtonSelecter | - | - | Circular Annulus Center Y |
| Circle1 | ButtonSelecter | - | - | Circle |
| Circle2 | ButtonSelecter | - | - | Circle |
| InnerRadius1 | ButtonSelecter | - | - | InnerRadius |
| InnerRadius2 | ButtonSelecter | - | - | InnerRadius |
| OuterRadius1 | ButtonSelecter | - | - | OuterRadius |
| OuterRadius2 | ButtonSelecter | - | - | OuterRadius |
| StartAngle1 | ButtonSelecter | - | - | Angle Start |
| StartAngle2 | ButtonSelecter | - | - | Angle Start |

### IMVSCircleFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CCDCircleThresh | Integer | - | 0xa | RunParam_Locating Sensitivity |
| CCDSampleScale | Integer | - | 0x8 | Subsampling Coefficient |
| EdgeThresh | Integer | - | 0xf | EdgeThreshold |
| EdgeWidth | Integer | - | 0x2 | KernelSize |
| FitPointsLimitHigh | Integer | - | 200 | Fit Error Upper Limit |
| FitPointsLimitLow | Integer | - | 3 | Fit Points Lower Limit |
| ProLength | Integer | - | 0x5 | Projection Width |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0 | Number of Points to remove |
| CenterXLimitEnable | Boolean | 0 | False | Center X Check |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| CoarseDetectFlag | Boolean | 0 | False | Init Locating |
| FitErrorLimitEnable | Boolean | 0 | False | Fit Error Check |
| FitPointsLimitEnable | Boolean | 0 | False | Fit Points Check |
| RadiusLimitEnable | Boolean | 0 | False | Radius Check |

### IMVSCircleFitModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| MaxIters | Integer | - | 20 | Max Iteration Times |
| NumLimitHigh | Integer | - | 10 | RunParam_Fit Points Upper Limit |
| NumLimitLow | Integer | - | 0 | Fit Points Lower Limit |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0 | Number of Points to remove |
| CenterXLimitEnable | Boolean | 0 | False | Center X Check |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| NumLimitEnable | Boolean | 0 | False | Fit Points Check |
| RadiusLimitEnable | Boolean | 0 | False | Radius Check |
| ScoreLimitEnable | Boolean | 0 | False | Fit Error Check |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| FittingPoints | ButtonSelecter | - | - | Point |
| FittingPointsX | ButtonSelecter | - | - | PointX |
| FittingPointsY | ButtonSelecter | - | - | pointy |

### IMVSCnnAnomalyDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| MaxObjNum | Integer | - | - | Max Number to Find |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| MaskImageEnable | Boolean | 0 | False | OutMaskImage |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| RenderMaskEnable | Boolean | 0 | False | Render mask image |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnChangeDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| EndAngle | Integer | - | 180 | Angle End |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | RunParam_Max Number to Find |
| MaxWidth | Integer | - | 4000 | Max. Width |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | Min. Width |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| AngleEnable | Boolean | 0 | False | Angle Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| HeightEnable | Boolean | 0 | False | Height Enable |
| LoadImagePathEnable | Boolean | 0 | - | RunParam_LoadImagePathEnable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| SaveModelDataEnable | Boolean | 0 | - | RunParam_SaveModelDataEnable |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| UseGalleryFolderEnable | Boolean | 0 | False | Use gallery folder |
| WidthEnable | Boolean | 0 | False | Width Enable |
| GalleryFileName | ButtonSelecter | - | - | Gallery File Name |
| CategoryNameLimit | String | - | 0 | UserCategoryName |

### IMVSCnnChangeDetectModuC ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| EndAngle | Integer | - | 180 | Angle End |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | RunParam_Max Number to Find |
| MaxWidth | Integer | - | 4000 | Max. Width |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | Min. Width |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| AngleEnable | Boolean | 0 | False | Angle Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| HeightEnable | Boolean | 0 | False | Height Enable |
| LoadImagePathEnable | Boolean | 0 | - | RunParam_LoadImagePathEnable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| SaveModelDataEnable | Boolean | 0 | - | RunParam_SaveModelDataEnable |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| UseGalleryFolderEnable | Boolean | 0 | False | Use gallery folder |
| WidthEnable | Boolean | 0 | False | Width Enable |
| GalleryFileName | ButtonSelecter | - | - | Gallery File Name |
| CategoryNameLimit | String | - | 0 | UserCategoryName |

### IMVSCnnCharDetectModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| CnnModelType | Integer | - | - | CnnModelType |
| EndAngle | Integer | - | 180 | Angle End |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| MaxWidth | Integer | - | 4000 | MaxWidth |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | MinWidth |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| TopNum | Integer | - | 1 | Lang_ResultTextCount |
| AngleEnable | Boolean | 0 | False | Character Angle Enable |
| BatchProcessingEnable | Boolean | 0 | False | Batch Process Enable |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| HeightEnable | Boolean | 0 | False | Character Height Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| ScoreLimitEnable | Boolean | 0 | False | ObjectScore Check |
| TextComparisonEnable | Boolean | 0 | True | Lang_TextComparison |
| WidthEnable | Boolean | 0 | False | Character Width Enable |

### IMVSCnnCharDetectModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| CnnModelType | Integer | - | - | CnnModelType |
| EndAngle | Integer | - | 180 | Angle End |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| MaxWidth | Integer | - | 4000 | MaxWidth |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | MinWidth |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| TopNum | Integer | - | 1 | Lang_ResultTextCount |
| AngleEnable | Boolean | 0 | False | Character Angle Enable |
| BatchProcessingEnable | Boolean | 0 | False | Batch Process Enable |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| HeightEnable | Boolean | 0 | False | Character Height Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| ScoreLimitEnable | Boolean | 0 | False | ObjectScore Check |
| TextComparisonEnable | Boolean | 0 | True | Lang_TextComparison |
| WidthEnable | Boolean | 0 | False | Character Width Enable |

### IMVSCnnClassifyModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| LabelLimitHigh | Integer | - | 1000 | Category Upper Limit |
| LabelLimitLow | Integer | - | 0 | Category Lower Limit |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| TopClassK | Integer | - | 1 | First K Categories |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| LabelLimitEnable | Boolean | 0 | False | Category Check |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| ProbLimitEnable | Boolean | 0 | False | Probability Check |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnClassifyModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| LabelLimitHigh | Integer | - | 1000 | Category Upper Limit |
| LabelLimitLow | Integer | - | 0 | Category Lower Limit |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| TopClassK | Integer | - | 1 | First K Categories |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| LabelLimitEnable | Boolean | 0 | False | Category Check |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| ProbLimitEnable | Boolean | 0 | False | Probability Check |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnCodeRecgModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AdvanceParam | Integer | - | 0 | Parameter AdvanceParam |
| Aperture | Integer | - | 10 | ApertureIn |
| ApertureIn | Integer | - | 3 | ApertureIn |
| ArrangeColumnNum | Integer | - | 3 | Arrange Column Num |
| ArrangeRowNum | Integer | - | 3 | Arrange Row Num |
| BarCodeNum | Integer | - | 0x4 | RunParam_Bar Code Number |
| DecodabilityThrA | Integer | - | 62 | RunParam_DecodabilityThrA |
| DecodabilityThrB | Integer | - | 50 | RunParam_DecodabilityThrB |
| DecodabilityThrC | Integer | - | 37 | RunParam_DecodabilityThrC |
| DecodabilityThrD | Integer | - | 25 | RunParam_DecodabilityThrD |
| DefectsThrA | Integer | - | 15 | RunParam_DefectsThrA |
| DefectsThrB | Integer | - | 20 | RunParam_DefectsThrB |
| DefectsThrC | Integer | - | 25 | RunParam_DefectsThrC |
| DefectsThrD | Integer | - | 30 | RunParam_DefectsThrD |
| LocCodeNum | Integer | - | 0x5 | RunParam_2D Code Number |
| LocSDCodeNum | Integer | - | 0x5 | RunParam_LocSD Code Number |
| MaxCodeSize | Integer | - | 0x12C | Max. Code Width |
| MinEdgeContrastThrA | Integer | - | 15 | RunParam_MinEdgeContrastThrA |
| MinEdgeContrastThrB | Integer | - | 15 | RunParam_MinEdgeContrastThrB |
| MinEdgeContrastThrC | Integer | - | 15 | RunParam_MinEdgeContrastThrC |
| MinEdgeContrastThrD | Integer | - | 15 | RunParam_MinEdgeContrastThrD |
| MinReflectanceThrA | Integer | - | 50 | RunParam_MinReflectanceThrA |
| MinReflectanceThrB | Integer | - | 50 | RunParam_MinReflectanceThrB |
| MinReflectanceThrC | Integer | - | 50 | RunParam_MinReflectanceThrC |
| MinReflectanceThrD | Integer | - | 50 | RunParam_MinReflectanceThrD |
| ModulationThrA | Integer | - | 70 | RunParam_ModulationThrA |
| ModulationThrB | Integer | - | 60 | RunParam_ModulationThrB |
| ModulationThrC | Integer | - | 50 | RunParam_ModulationThrC |
| ModulationThrD | Integer | - | 40 | RunParam_ModulationThrD |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| SampleLevel | Integer | - | 1 | RunParam_Subsampling Ratio |
| SymbolCols | Integer | - | 16 | RunParam_2D Code Column |
| SymbolContrastThrA | Integer | - | 70 | RunParam_SymbolContrastThrA |
| SymbolContrastThrB | Integer | - | 55 | RunParam_SymbolContrastThrB |
| SymbolContrastThrC | Integer | - | 40 | RunParam_SymbolContrastThrC |
| SymbolContrastThrD | Integer | - | 20 | RunParam_SymbolContrastThrD |
| SymbolRows | Integer | - | 16 | RunParam_2D Code Row |
| WaitingTime | Integer | - | 1000 | RunParam_Timeout-Period to Exit |
| ApertureEnable | Boolean | 0 | False | ApertureEnable |
| ArrangeFlag | Boolean | 0 | False | Arrange Flag |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| DebugFlag | Boolean | 0 | False | Debugging Info. Switch |
| DecodabilityFlag | Boolean | 0 | True | Decodability |
| DecodeFlag | Boolean | 0 | True | Decode |
| DefectsFlag | Boolean | 0 | True | Defects |
| EdgeDeterminationFlag | Boolean | 0 | True | EdgeDetermination |
| GradeFlag | Boolean | 0 | False | CodeGrade |
| MinEdgeContrastFlag | Boolean | 0 | True | RunParam_MinEdgeContrastFlag |
| MinReflectanceFlag | Boolean | 0 | True | RunParam_MinReflectanceFlag |
| ModulationFlag | Boolean | 0 | True | RunParam_ModulationFlag |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| PerfMode | Boolean | 0 | False | High Performance Mode |
| QuietZoneFlag | Boolean | 0 | True | QuietZone |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| SymbolContrastFlag | Boolean | 0 | True | SymbolContrast |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| UserString | String | - | 0 | UDC |

### IMVSCnnCodeRecgModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AdvanceParam | Integer | - | 0 | Parameter AdvanceParam |
| Aperture | Integer | - | 10 | ApertureIn |
| ApertureIn | Integer | - | 3 | ApertureIn |
| ArrangeColumnNum | Integer | - | 3 | Arrange Column Num |
| ArrangeRowNum | Integer | - | 3 | Arrange Row Num |
| BarCodeNum | Integer | - | 0x4 | RunParam_Bar Code Number |
| DecodabilityThrA | Integer | - | 62 | RunParam_DecodabilityThrA |
| DecodabilityThrB | Integer | - | 50 | RunParam_DecodabilityThrB |
| DecodabilityThrC | Integer | - | 37 | RunParam_DecodabilityThrC |
| DecodabilityThrD | Integer | - | 25 | RunParam_DecodabilityThrD |
| DefectsThrA | Integer | - | 15 | RunParam_DefectsThrA |
| DefectsThrB | Integer | - | 20 | RunParam_DefectsThrB |
| DefectsThrC | Integer | - | 25 | RunParam_DefectsThrC |
| DefectsThrD | Integer | - | 30 | RunParam_DefectsThrD |
| LocCodeNum | Integer | - | 0x5 | RunParam_2D Code Number |
| LocSDCodeNum | Integer | - | 0x5 | RunParam_LocSD Code Number |
| MaxCodeSize | Integer | - | 0x12C | Max. Code Width |
| MinEdgeContrastThrA | Integer | - | 15 | RunParam_MinEdgeContrastThrA |
| MinEdgeContrastThrB | Integer | - | 15 | RunParam_MinEdgeContrastThrB |
| MinEdgeContrastThrC | Integer | - | 15 | RunParam_MinEdgeContrastThrC |
| MinEdgeContrastThrD | Integer | - | 15 | RunParam_MinEdgeContrastThrD |
| MinReflectanceThrA | Integer | - | 50 | RunParam_MinReflectanceThrA |
| MinReflectanceThrB | Integer | - | 50 | RunParam_MinReflectanceThrB |
| MinReflectanceThrC | Integer | - | 50 | RunParam_MinReflectanceThrC |
| MinReflectanceThrD | Integer | - | 50 | RunParam_MinReflectanceThrD |
| ModulationThrA | Integer | - | 70 | RunParam_ModulationThrA |
| ModulationThrB | Integer | - | 60 | RunParam_ModulationThrB |
| ModulationThrC | Integer | - | 50 | RunParam_ModulationThrC |
| ModulationThrD | Integer | - | 40 | RunParam_ModulationThrD |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| SampleLevel | Integer | - | 1 | RunParam_Subsampling Ratio |
| SymbolCols | Integer | - | 16 | RunParam_2D Code Column |
| SymbolContrastThrA | Integer | - | 70 | RunParam_SymbolContrastThrA |
| SymbolContrastThrB | Integer | - | 55 | RunParam_SymbolContrastThrB |
| SymbolContrastThrC | Integer | - | 40 | RunParam_SymbolContrastThrC |
| SymbolContrastThrD | Integer | - | 20 | RunParam_SymbolContrastThrD |
| SymbolRows | Integer | - | 16 | RunParam_2D Code Row |
| WaitingTime | Integer | - | 1000 | RunParam_Timeout-Period to Exit |
| ApertureEnable | Boolean | 0 | False | ApertureEnable |
| ArrangeFlag | Boolean | 0 | False | Arrange Flag |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| DebugFlag | Boolean | 0 | False | Debugging Info. Switch |
| DecodabilityFlag | Boolean | 0 | True | Decodability |
| DecodeFlag | Boolean | 0 | True | Decode |
| DefectsFlag | Boolean | 0 | True | Defects |
| EdgeDeterminationFlag | Boolean | 0 | True | EdgeDetermination |
| GradeFlag | Boolean | 0 | False | CodeGrade |
| MinEdgeContrastFlag | Boolean | 0 | True | RunParam_MinEdgeContrastFlag |
| MinReflectanceFlag | Boolean | 0 | True | RunParam_MinReflectanceFlag |
| ModulationFlag | Boolean | 0 | True | RunParam_ModulationFlag |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| PerfMode | Boolean | 0 | False | High Performance Mode |
| QuietZoneFlag | Boolean | 0 | True | QuietZone |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| SymbolContrastFlag | Boolean | 0 | True | SymbolContrast |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| UserString | String | - | 0 | UDC |

### IMVSCnnDetectModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| EndAngle | Integer | - | 180 | Angle End |
| MaxArea | Integer | - | 16000000 | Max. Area |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| MaxWidth | Integer | - | 4000 | MaxWidth |
| MinArea | Integer | - | 1 | Min. Area |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | MinWidth |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| XSlidingWinNumOfSOD | Integer | - | 1 | X Sliding Window Number |
| YSlidingWinNumOfSOD | Integer | - | 1 | Y Sliding Window Number |
| AngleEnable | Boolean | 0 | False | Angle Enable |
| AreaEnable | Boolean | 0 | False | Area Enable |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| HeightEnable | Boolean | 0 | False | Height Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| SODEnable | Boolean | 0 | False | Small Object Mode |
| WHRatioEnable | Boolean | 0 | False | WHRatio Enable |
| WidthEnable | Boolean | 0 | False | Width Enable |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnDetectModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| EndAngle | Integer | - | 180 | Angle End |
| MaxArea | Integer | - | 16000000 | Max. Area |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| MaxWidth | Integer | - | 4000 | MaxWidth |
| MinArea | Integer | - | 1 | Min. Area |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | MinWidth |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| XSlidingWinNumOfSOD | Integer | - | 1 | X Sliding Window Number |
| YSlidingWinNumOfSOD | Integer | - | 1 | Y Sliding Window Number |
| AngleEnable | Boolean | 0 | False | Angle Enable |
| AreaEnable | Boolean | 0 | False | Area Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| HeightEnable | Boolean | 0 | False | Height Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| SODEnable | Boolean | 0 | False | Small Object Mode |
| WHRatioEnable | Boolean | 0 | False | WHRatio Enable |
| WidthEnable | Boolean | 0 | False | Width Enable |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnExplosionDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| EndAngle | Integer | - | 180 | Angle End |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | RunParam_Max Number to Find |
| MaxWidth | Integer | - | 4000 | Max. Width |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | Min. Width |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| AngleEnable | Boolean | 0 | False | Angle Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| HeightEnable | Boolean | 0 | False | Height Enable |
| LoadImagePathEnable | Boolean | 0 | - | RunParam_LoadImagePathEnable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| SaveModelDataEnable | Boolean | 0 | - | RunParam_SaveModelDataEnable |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| UseGalleryFolderEnable | Boolean | 0 | False | Use gallery folder |
| WidthEnable | Boolean | 0 | False | Width Enable |
| GalleryFileName | ButtonSelecter | - | - | Gallery File Name |
| CategoryNameLimit | String | - | 0 | UserCategoryName |

### IMVSCnnExplosionDetectModuC ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| EndAngle | Integer | - | 180 | Angle End |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | RunParam_Max Number to Find |
| MaxWidth | Integer | - | 4000 | Max. Width |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | Min. Width |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| StartAngle | Integer | - | -180 | Angle Start |
| AngleEnable | Boolean | 0 | False | Angle Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| HeightEnable | Boolean | 0 | False | Height Enable |
| LoadImagePathEnable | Boolean | 0 | - | RunParam_LoadImagePathEnable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| SaveModelDataEnable | Boolean | 0 | - | RunParam_SaveModelDataEnable |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| UseGalleryFolderEnable | Boolean | 0 | False | Use gallery folder |
| WidthEnable | Boolean | 0 | False | Width Enable |
| GalleryFileName | ButtonSelecter | - | - | Gallery File Name |
| CategoryNameLimit | String | - | 0 | UserCategoryName |

### IMVSCnnFastFlawModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| MinScore | Integer | - | 60 | MinScore |
| XSlidingWinNumOfSOD | Integer | - | 1 | X Sliding Window Number |
| YSlidingWinNumOfSOD | Integer | - | 1 | Y Sliding Window Number |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| SaveModelDataEnable | Boolean | 0 | - | RunParam_SaveModelDataEnable |
| SODEnable | Boolean | 0 | False | Small Object Mode |

### IMVSCnnFlawAndBlobModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AdaptiveWindowsHeight | Integer | 0 | 1024 | Adaptive Window Height |
| AdaptiveWindowsWidth | Integer | 0 | 1024 | Adaptive Window Width |
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| BlobMaxArea | Integer | - | 999999999 | BlobMaxArea |
| BlobMaxArea | Integer | - | 999999999 | BlobMaxArea |
| BlobMaxFindNum | Integer | - | 100 | BlobMaxFindNum |
| BlobMaxFindNum | Integer | - | 100 | BlobMaxFindNum |
| BlobMaxLongAxis | Integer | - | 999999999 | BlobMaxLongAxis |
| BlobMaxLongAxis | Integer | - | 999999999 | BlobMaxLongAxis |
| BlobMaxShortAxis | Integer | - | 999999999 | BlobMaxShortAxis |
| BlobMaxShortAxis | Integer | - | 999999999 | BlobMaxShortAxis |
| BlobMinArea | Integer | - | 1 | BlobMinArea |
| BlobMinArea | Integer | - | 1 | BlobMinArea |
| BlobMinLongAxis | Integer | - | 10 | BlobMinLongAxis |
| BlobMinLongAxis | Integer | - | 10 | BlobMinLongAxis |
| BlobMinShortAxis | Integer | - | 1 | BlobMinShortAxis |
| BlobMinShortAxis | Integer | - | 1 | BlobMinShortAxis |
| DeepLearnModelType | Integer | - | - | DeepLearnModelType |
| FindNum | Integer | - | 0x64 | blob最大个数 |
| HoleMinArea | Integer | - | False | 孔洞最小面积 |
| MaxArea | Integer | - | 0x895440 | 面积上限 |
| MaxLongAxis | Integer | - | 0xF4240 | 长轴长度上限 |
| MaxShortAxis | Integer | - | 0xF4240 | 短轴长度上限 |
| MinArea | Integer | - | 0x1 | 面积下限 |
| MinLongAxis | Integer | - | 0x1 | 长轴长度下限 |
| MinScore | Integer | - | 0 | MinScore |
| MinShortAxis | Integer | - | 0x1 | 短轴长度下限 |
| SampleInterval | Integer | - | 2 | RunParam_Sampling Coefficient |
| XSlidingWinNumOfSOD | Integer | - | 1 | X Sliding Window Number |
| YSlidingWinNumOfSOD | Integer | - | 1 | Y Sliding Window Number |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| BlobAreaEnable | Boolean | - | False | BlobAreaEnable |
| BlobAreaEnable | Boolean | - | False | BlobAreaEnable |
| BlobEnable | Boolean | - | False | BlobEnable |
| BlobEnable | Boolean | - | False | BlobEnable |
| BlobFilterEnable | Boolean | - | False | BlobFilterEnable |
| BlobLongAxisEnable | Boolean | - | False | BlobLongAxisEnable |
| BlobLongAxisEnable | Boolean | - | False | BlobLongAxisEnable |
| BlobShortAxisEnable | Boolean | - | False | BlobShortAxisEnable |
| BlobShortAxisEnable | Boolean | - | False | BlobShortAxisEnable |
| FeatureEnable | Boolean | - | 0x0 | 特征使能 |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| UseFirstROIRunParamEnable | Boolean | 0 | True | RunParam_UseFirstROIRunParamEnable |
| UseFirstROIRunParamEnable | Boolean | 0 | True | RunParam_UseFirstROIRunParamEnable |
| InheritWay | RadioSelecter | - | 0 | Inheritance Mode |
| Region | ButtonSelecter | - | - | Region |

### IMVSCnnFlawAndBlobModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlobMaxArea | Integer | - | 999999999 | BlobMaxArea |
| BlobMaxArea | Integer | - | 999999999 | BlobMaxArea |
| BlobMaxFindNum | Integer | - | 100 | BlobMaxFindNum |
| BlobMaxFindNum | Integer | - | 100 | BlobMaxFindNum |
| BlobMaxLongAxis | Integer | - | 999999999 | BlobMaxLongAxis |
| BlobMaxLongAxis | Integer | - | 999999999 | BlobMaxLongAxis |
| BlobMaxShortAxis | Integer | - | 999999999 | BlobMaxShortAxis |
| BlobMaxShortAxis | Integer | - | 999999999 | BlobMaxShortAxis |
| BlobMinArea | Integer | - | 1 | BlobMinArea |
| BlobMinArea | Integer | - | 1 | BlobMinArea |
| BlobMinLongAxis | Integer | - | 10 | BlobMinLongAxis |
| BlobMinLongAxis | Integer | - | 10 | BlobMinLongAxis |
| BlobMinShortAxis | Integer | - | 1 | BlobMinShortAxis |
| BlobMinShortAxis | Integer | - | 1 | BlobMinShortAxis |
| DeepLearnModelType | Integer | - | - | DeepLearnModelType |
| MinScore | Integer | - | 0 | MinScore |
| SampleInterval | Integer | - | 2 | RunParam_Sampling Coefficient |
| XSlidingWinNumOfSOD | Integer | - | 1 | X Sliding Window Number |
| YSlidingWinNumOfSOD | Integer | - | 1 | Y Sliding Window Number |
| BlobAreaEnable | Boolean | - | False | BlobAreaEnable |
| BlobAreaEnable | Boolean | - | False | BlobAreaEnable |
| BlobEnable | Boolean | - | False | BlobEnable |
| BlobEnable | Boolean | - | False | BlobEnable |
| BlobFilterEnable | Boolean | - | False | BlobFilterEnable |
| BlobLongAxisEnable | Boolean | - | False | BlobLongAxisEnable |
| BlobLongAxisEnable | Boolean | - | False | BlobLongAxisEnable |
| BlobShortAxisEnable | Boolean | - | False | BlobShortAxisEnable |
| BlobShortAxisEnable | Boolean | - | False | BlobShortAxisEnable |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| UseFirstROIRunParamEnable | Boolean | 0 | True | RunParam_UseFirstROIRunParamEnable |
| UseFirstROIRunParamEnable | Boolean | 0 | True | RunParam_UseFirstROIRunParamEnable |
| InheritWay | RadioSelecter | - | 0 | Inheritance Mode |
| Region | ButtonSelecter | - | - | Region |

### IMVSCnnFlawModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| DeepLearnModelType | Integer | - | - | DeepLearnModelType |
| FindNum | Integer | - | 0x64 | blob最大个数 |
| HoleMinArea | Integer | - | False | 孔洞最小面积 |
| MaxArea | Integer | - | 0x895440 | 面积上限 |
| MaxLongAxis | Integer | - | 0xF4240 | 长轴长度上限 |
| MaxShortAxis | Integer | - | 0xF4240 | 短轴长度上限 |
| MinArea | Integer | - | 0x1 | 面积下限 |
| MinLongAxis | Integer | - | 0x1 | 长轴长度下限 |
| MinScore | Integer | - | 0 | MinScore |
| MinShortAxis | Integer | - | 0x1 | 短轴长度下限 |
| SampleInterval | Integer | - | 2 | RunParam_Sampling Coefficient |
| XSlidingWinNumOfSOD | Integer | - | 1 | X Sliding Window Number |
| YSlidingWinNumOfSOD | Integer | - | 1 | Y Sliding Window Number |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| FeatureEnable | Boolean | - | 0x0 | 特征使能 |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| SODEnable | Boolean | 0 | False | Small Object Mode |

### IMVSCnnFlawModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| DeepLearnModelType | Integer | - | - | DeepLearnModelType |
| FindNum | Integer | - | 0x64 | blob最大个数 |
| HoleMinArea | Integer | - | 0x0 | 孔洞最小面积 |
| MaxArea | Integer | - | 0x895440 | 面积上限 |
| MaxLongAxis | Integer | - | 0xF4240 | 长轴长度上限 |
| MaxShortAxis | Integer | - | 0xF4240 | 短轴长度上限 |
| MinArea | Integer | - | 0x1 | 面积下限 |
| MinLongAxis | Integer | - | 0x1 | 长轴长度下限 |
| MinScore | Integer | - | 0 | MinScore |
| MinShortAxis | Integer | - | 0x1 | 短轴长度下限 |
| SampleInterval | Integer | - | 2 | RunParam_Sampling Coefficient |
| XSlidingWinNumOfSOD | Integer | - | 1 | X Sliding Window Number |
| YSlidingWinNumOfSOD | Integer | - | 1 | Y Sliding Window Number |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| FeatureEnable | Boolean | - | False | 特征使能 |
| RoiFromModelEnable | Boolean | 0 | - | Get Roi From Model |
| SODEnable | Boolean | 0 | False | Small Object Mode |

### IMVSCnnInstanceSegmentModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| RenderMaskEnable | Boolean | 0 | - | Render mask image |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnInstanceSegmentModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| CutViaROIEnable | Boolean | 0 | False | Cut Via Roi |
| DiffClassNMSEnable | Boolean | 0 | False | DiffClassNMSEnable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| OutFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| RenderMaskEnable | Boolean | 0 | - | Render mask image |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnMultiSourceDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassLimitHigh | Integer | - | 99999 | Category Upper Limit |
| ClassLimitLow | Integer | - | 0 | Category Lower Limit |
| MaxObjNum | Integer | - | 1 | RunParam_Max Number to Find |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| PhotoSize | Integer | - | 4 | PhotoSize |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ClassLimitEnable | Boolean | 0 | False | Category Check |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| SaveModelDataEnable | Boolean | 0 | - | RunParam_SaveModelDataEnable |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| CategoryNameLimit | String | - | 0 | UserCategoryName |

### IMVSCnnRegisterClassifyModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| ImageIndexLimitHigh | Integer | - | 1000 | Image Index Upper Limit |
| ImageIndexLimitLow | Integer | - | 0 | Image Index Lower Limit |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| TopClsK | Integer | - | 1 | First K Categories |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ImageIndexLimitEnable | Boolean | 0 | False | Image Index Check |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| SimilarityLimitEnable | Boolean | 0 | False | Similaritys Check |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnRegisterClassifyModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ImageIndexLimitHigh | Integer | - | 1000 | Image Index Upper Limit |
| ImageIndexLimitLow | Integer | - | 0 | Image Index Lower Limit |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| TopClsK | Integer | - | 1 | First K Categories |
| CategoryNameLimitEnable | Boolean | 0 | False | CategoryName Check |
| ImageIndexLimitEnable | Boolean | 0 | False | Image Index Check |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| SimilarityLimitEnable | Boolean | 0 | False | Similaritys Check |
| CategoryNameLimit | String | - | 0 | ClassName |

### IMVSCnnRetrievalModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| TopClsK | Integer | - | 1 | First K Categories |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |

### IMVSCnnRetrievalModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| TopClsK | Integer | - | 1 | First K Categories |

### IMVSCnnSingleCharDetectModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| FontFilterNum | Integer | - | 4 | Identify Character Quantity |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| MaxWidth | Integer | - | 4000 | MaxWidth |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | MinWidth |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| TopNum | Integer | - | 1 | TopN |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| FontFilterEnable | Boolean | - | False | Character Filtration Enable |
| HeightEnable | Boolean | 0 | False | Text Line Height Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| WidthEnable | Boolean | 0 | False | Text Line Width Enable |
| FontFilterInfo | String | - | 0 | Character Filtration Info. |
| UserString | String | - | 0 | UDC |

### IMVSCnnSingleCharDetectModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| FontFilterNum | Integer | - | 4 | Identify Character Quantity |
| MaxHeight | Integer | - | 4000 | Max. Height |
| MaxObjNum | Integer | - | 1 | Max Number to Find |
| MaxWidth | Integer | - | 4000 | MaxWidth |
| MinHeight | Integer | - | 1 | Min. Height |
| MinWidth | Integer | - | 1 | MinWidth |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| TopNum | Integer | - | 1 | TopN |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| FontFilterEnable | Boolean | - | False | Character Filtration Enable |
| HeightEnable | Boolean | 0 | False | Text Line Height Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| OutRoiFilterEnable | Boolean | 0 | False | Lang_OutRoiFilterEnable |
| ScoreLimitEnable | Boolean | 0 | False | Confidence Check |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| WidthEnable | Boolean | 0 | False | Text Line Width Enable |
| FontFilterInfo | String | - | 0 | Character Filtration Info. |
| UserString | String | - | 0 | UDC |

### IMVSCodeFlawModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlackGridFlawThre_dc | Integer | - | 60 | BlackGridFlawThre_dc |
| BlackGridFlawThre_sc | Integer | - | 60 | BlackGridFlawThre_sc |
| CodeGridPolarityContrast | Integer | - | 50 | CodeGridPolarityContrast |
| CodeSize | Integer | - | 21 | CodeSize |
| FlawPixelNumThre_dc | Integer | - | 4 | FlawPixelNumThre_dc |
| FlawPixelNumThre_sc | Integer | - | 4 | FlawPixelNumThre_sc |
| LineFlawContrastThre | Integer | - | 50 | LineFlawContrastThre |
| LineFlawWidthThre | Integer | - | 2 | LineFlawWidthThre |
| SumCodeNumThre | Integer | - | 5 | SumCodeNumThre |
| SumFlawPixelThre | Integer | - | 5 | SumFlawPixelThre |
| WhiteGridFlawThre_dc | Integer | - | 180 | WhiteGridFlawThre_dc |
| WhiteGridFlawThre_sc | Integer | - | 180 | WhiteGridFlawThre_sc |
| DotMatrixCodeEnabled | Boolean | - | False | DotMatrixCodeEnabled |
| FpdFlawDetectEnable | Boolean | - | False | FpdFlawDetectEnable |
| GridFlawDetectEnable_dc | Boolean | - | False | GridFlawDetectEnable_dc |
| GridFlawDetectEnable_sc | Boolean | - | False | GridFlawDetectEnable_sc |
| IsAutoCalCodeNum | Boolean | - | False | IsAutoCalCodeNum |
| IsAutoCalContrast | Boolean | - | False | IsAutoCalContrast |
| LargeFlawDetectEnable | Boolean | - | False | LargeFlawDetectEnable |
| LineFlawDetectEnable | Boolean | - | False | LineFlawDetectEnable |

### IMVSColorExtract2Modu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AreaLimitEnable | Boolean | 0 | False | DispParam_Color Total Area Check |

### IMVSColorExtractModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AreaLimitEnable | Boolean | 0 | False | DispParam_Color Total Area Check |

### IMVSColorMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| C1MaxValueLimitHigh | Integer | - | 255 | Max Value Upper Limit |
| C1MaxValueLimitLow | Integer | - | 0 | Max Value Lower Limit |
| C1MinValueLimitHigh | Integer | - | 255 | Min Value Upper Limit |
| C1MinValueLimitLow | Integer | - | 0 | Min Value Lower Limit |
| C2MaxValueLimitHigh | Integer | - | 255 | Max Value Upper Limit |
| C2MaxValueLimitLow | Integer | - | 0 | Max Value Lower Limit |
| C2MinValueLimitHigh | Integer | - | 255 | Min Value Upper Limit |
| C2MinValueLimitLow | Integer | - | 0 | Min Value Lower Limit |
| C3MaxValueLimitHigh | Integer | - | 255 | Max Value Upper Limit |
| C3MaxValueLimitLow | Integer | - | 0 | Max Value Lower Limit |
| C3MinValueLimitHigh | Integer | - | 255 | Min Value Upper Limit |
| C3MinValueLimitLow | Integer | - | 0 | Min Value Lower Limit |
| C1MaxValueLimitEnable | Boolean | 0 | False | C1Max |
| C1MeanLimitEnable | Boolean | 0 | False | C1Mean |
| C1MinValueLimitEnable | Boolean | 0 | False | C1Min |
| C1StdLimitEnable | Boolean | 0 | False | C1Std |
| C2MaxValueLimitEnable | Boolean | 0 | False | C2Max |
| C2MeanLimitEnable | Boolean | 0 | False | C2Mean |
| C2MinValueLimitEnable | Boolean | 0 | False | C2Min |
| C2StdLimitEnable | Boolean | 0 | False | C2Std |
| C3MaxValueLimitEnable | Boolean | 0 | False | C3Max |
| C3MeanLimitEnable | Boolean | 0 | False | C3Mean |
| C3MinValueLimitEnable | Boolean | 0 | False | C3Min |
| C3StdLimitEnable | Boolean | 0 | False | C3Std |

### IMVSColorRecognitionModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| KnnK | Integer | - | 3 | RunParam_K value |
| TimeOut | Integer | - | 10000 | TimeOut |
| ColorType | Boolean | 0 | False | ColorType |
| TopTypeName | String | - | 0 | TopTypeName |

### IMVSColorSegmentModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClutterArea | Integer | - | 0x64 | RunParam_ClutterArea |
| HoleArea | Integer | - | 0x64 | RunParam_HoleArea |
| AreaLimitEnable | Boolean | 0 | False | DispParam_Color Total Area Check |

### IMVSColorTransformModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Bratio | Integer | - | 0x1 | RunParam_B Transfer Ratio |
| Gratio | Integer | - | 0x1 | RunParam_G Transfer Ratio |
| Rratio | Integer | - | 0x1 | RunParam_R Transfer Ratio |

### IMVSCombineDefectDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlobAreaLimitHigh | Integer | - | 999999999 | Blob Area Upper Limit |
| BlobAreaLimitLow | Integer | - | 10 | Blob Area Lower Limit |
| BlobLongAxisLimitHigh | Integer | - | 999999999 | Blob LongAxis Upper Limit |
| BlobLongAxisLimitLow | Integer | - | 10 | Blob LongAxis Lower Limit |
| BlobPerimeterLimitHigh | Integer | - | 999999999 | Blob Perimeter Upper Limit |
| BlobPerimeterLimitLow | Integer | - | 10 | Blob Perimeter Lower Limit |
| BlobRectRectHeightHigh | Integer | - | 200 | Blob RectHeight Upper Limit |
| BlobRectRectHeightLow | Integer | - | 100 | Blob RectHeight Lower Limit |
| BlobRectWidthLimitHigh | Integer | - | 200 | Blob RectWidth Upper Limit |
| BlobRectWidthLimitLow | Integer | - | 100 | Blob RectWidth Lower Limit |
| BlobShortAxisLimitHigh | Integer | - | 999999999 | Blob ShortAxis Upper Limit |
| BlobShortAxisLimitLow | Integer | - | 1 | Blob ShortAxis Lower Limit |
| ContrastThresh | Integer | - | 15 | RunParam_ContrastThresh |
| FilterSize | Integer | - | 4 | RunParam_FilterSize |
| MaxFindNum | Integer | - | 100 | RunParam_MaxFindNum |
| MinHoleArea | Integer | - | 0 | RunParam_MinHoleArea |
| MoveX | Integer | - | 4 | RunParam_MoveX |
| MoveY | Integer | - | 4 | RunParam_MoveY |
| SampleRate | Integer | - | 100 | RunParam_SampleRate |
| SampleX | Integer | - | 4 | RunParam_SampleX |
| SampleY | Integer | - | 4 | RunParam_SampleY |
| BlobAreaLimitEnable | Boolean | 0 | True | Blob Area Check |
| BlobAxisRatioLimitEnable | Boolean | 0 | False | Blob AxisRatio Check |
| BlobBoxAngleLimitEnable | Boolean | 0 | False | Blob BoxAngle Check |
| BlobCentroidBiasLimitEnable | Boolean | 0 | False | Blob CentroidBias Check |
| BlobCircularityLimitEnable | Boolean | 0 | False | Blob Circularity Check |
| BlobLongAxisLimitEnable | Boolean | 0 | False | Blob LongAxis Check |
| BlobPerimeterLimitEnable | Boolean | 0 | False | Blob Perimeter Check |
| BlobRectangularityLimitEnable | Boolean | 0 | False | Blob Rectangularity Check |
| BlobRectHeightLimitEnable | Boolean | 0 | False | Blob RectHeight Check |
| BlobRectWidthLimitEnable | Boolean | 0 | False | Blob RectWidth Check |
| BlobShortAxisLimitEnable | Boolean | 0 | False | Blob ShortAxis Check |
| EnableContourInfoFlag | Boolean | 0 | True | RunParam_EnableContourInfoFlag |
| EnableGrayInfoFlag | Boolean | 0 | True | RunParam_EnableGrayInfoFlag |
| EnableHistInfo | Boolean | 0 | True | RunParam_EnableHistInfo |
| InputMaskEnable | Boolean | 0 | False | Input Mask Enable |
| IsOutBinImg | Boolean | 0 | False | RunParam_IsOutBinImg |
| IsOutFlaw | Boolean | 0 | True | RunParam_IsOutFlaw |
| IsOutGradImg | Boolean | 0 | False | RunParam_IsOutGradImg |
| UseFirstROIRunParamEnable | Boolean | 0 | True | RunParam_UnifiedParameters |
| RoiSelect | RadioSelecter | - | 0 | ROI Creation |
| InheritWay | RadioSelecter3 | - | 0 | Inheritance Mode |
| Region | ButtonSelecter | - | - | Region |
| ROIAngle | ButtonSelecter | - | - | roiangle |
| ROICenterX | ButtonSelecter | - | - | roicenterx |
| ROICenterY | ButtonSelecter | - | - | roicentery |
| ROIHeight | ButtonSelecter | - | - | roiheight |
| ROIWidth | ButtonSelecter | - | - | roiwidth |

### IMVSCombineDefectFilterModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BinaryThresh | Integer | - | - | RunParam_BinaryThresh |
| FindNum | Integer | - | 100 | RunParam_Number to Find |
| HoleMinArea | Integer | - | 0 | Fill Area Threshold |
| kerHeight | Integer | - | - | Filter Kernel Height |
| kerNum | Integer | - | - | RunParam_KerNum |
| kerWidth | Integer | - | - | Filter Kernel Width |
| MaxArea | Integer | - | 999999999 | Max Area |
| MaxCenterBias | Integer | - | 999999999 | Max Barycenter Offset |
| MaxLongAxis | Integer | - | 999999999 | Max Major Axis |
| MaxPerimeter | Integer | - | 999999999 | Max Perimeter |
| MaxRectHeight | Integer | - | 200 | Max RectHeight |
| MaxRectWidth | Integer | - | 200 | Max RectWidth |
| MaxShortAxis | Integer | - | 999999999 | Max Minor Axis |
| MinArea | Integer | - | 10 | Min Area |
| MinCenterBias | Integer | - | 10 | Min Barycenter Offset |
| MinLongAxis | Integer | - | 10 | Min Major Axis |
| MinPerimeter | Integer | - | 10 | Min Perimeter |
| MinRectHeight | Integer | - | 100 | Min RectHeight |
| MinRectWidth | Integer | - | 100 | Min RectWidth |
| MinShortAxis | Integer | - | 1 | Min Minor Axis |
| offset | Integer | - | - | RunParam_Offset |
| SampleRate | Integer | - | - | RunParam_SampleRate |
| sigma | Integer | - | - | LumStd |
| BinaryImageEnable | Boolean | 0 | True | RunParam_BinaryImageEnable |
| BolbIGrayImageEnable | Boolean | 0 | True | RunParam_BolbIGrayImageEnable |
| EnableContourInfo | Boolean | 0 | False | RunParam_EnableContourInfoFlag |
| EnableGrayInfo | Boolean | 0 | False | RunParam_EnableGrayInfoFlag |
| EnableHistInfo | Boolean | 0 | False | RunParam_EnableHistInfo |
| SelectByArea | Boolean | 0 | True | Area Enable |
| SelectByAxisRatio | Boolean | 0 | False | RunParam_Axial Ratio |
| SelectByBoxAngle | Boolean | 0 | False | Angle Enable |
| SelectByCentroidBias | Boolean | 0 | False | RunParam_Barycenter Offset Enable |
| SelectByCircularity | Boolean | 0 | False | Circularity Enable |
| SelectByLongAxis | Boolean | 0 | False | Major Axis Enable |
| SelectByPerimeter | Boolean | 0 | False | RunParam_Perimeter Enable |
| SelectByRectangularity | Boolean | 0 | False | Rectangularity Enable |
| SelectByRectHeight | Boolean | 0 | False | RectHeight Enable |
| SelectByRectWidth | Boolean | 0 | False | RectWidth Enable |
| SelectByShortAxis | Boolean | 0 | False | Minor Axis Enable |
| UseFirstROIRunParamEnable | Boolean | 0 | False | RunParam_UseFirstROIRunParamEnable |

### IMVSContourMatchModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 180 | Angle End |
| AngleStart | Integer | - | -180 | Angle Start |
| MatchExtentRate | Integer | - | 0 | Extension Threshold |
| MatchModelIndex | Integer | - | 0x0 | Match Model Index |
| MatchThresholdHigh | Integer | - | 40 | EdgeThreshold |
| MaxMatchNum | Integer | - | 0x1 | RunParam_Max Number to find |
| MaxOverlap | Integer | - | 0x32 | Overlap Threshold |
| MultiModelMaxOverlap | Integer | - | 0x32 | NMS Overlap Threshold |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| SkewXEnd | Integer | - | 0 | SkewXEnd |
| SkewXStart | Integer | - | 0 | SkewXStart |
| TimeOut | Integer | - | 0x0 | RunParam_Overtime Control |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| BoxPointXLimitEnable | Boolean | 0 | False | Central Point X Check |
| BoxPointYLimitEnable | Boolean | 0 | False | Central Point Y Check |
| MatchPointXLimitEnable | Boolean | 0 | False | Match Point X Check |
| MatchPointYLimitEnable | Boolean | 0 | False | Match Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| OKWhenNumIsZero | Boolean | 0 | False | OKWhenMatchNumIsZero |
| OutLineEnable | Boolean | 0 | True | RunParam_Contour Enabled |
| OutLinePointEnable | Boolean | 0 | False | RunParam_ContourPoint Enabled |
| ScaleLimitEnable | Boolean | 0 | False | Scale Check |
| ScaleXLimitEnable | Boolean | 0 | False | X Scale Check |
| ScaleYLimitEnable | Boolean | 0 | False | Y Scale Check |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |
| SetModelIndex | Boolean | 0 | False | RunParam_Set Model Index |
| SpotterFlag | Boolean | 0 | False | Mottle Considered |
| UseMatchAllMode | Boolean | 0 | False | RunParam_Use Match All Mode |

### IMVSDirtyDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AreaMax | Integer | - | 99999999 | RunParam_AreaMax |
| AreaMin | Integer | - | 1 | RunParam_AreaMin |
| Contast | Integer | - | - | RunParam_Contast |
| FillVal | Integer | - | - | RunParam_FillVal |
| HighThresh | Integer | - | 255 | RunParam_HighThresh |
| LowThresh | Integer | - | 0 | RunParam_LowThresh |
| MaxFlawNum | Integer | - | - | RunParam_MaxFlawNum |
| ThreadCount | Integer | - | - | ThreadCount |
| AreaEnable | Boolean | 0 | False | RunParam_AreaEnable |
| CirEnable | Boolean | 0 | False | RunParam_CirEnable |
| InputMaskEnable | Boolean | 0 | False | InputMaskEnable |
| LongAxisEnable | Boolean | 0 | False | RunParam_LongAxisEnable |
| RectEnable | Boolean | 0 | False | RunParam_RectEnable |
| ShortAxisEnable | Boolean | 0 | False | RunParam_ShortAxisEnable |

### IMVSDivideImageModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| NumX | Integer | - | 1 | RunParam_NumX |
| NumY | Integer | - | 1 | RunParam_NumY |
| OverlaprateX | Integer | - | 0 | RunParam_OverlaprateX |
| OverlaprateY | Integer | - | 0 | RunParam_OverlaprateY |

### IMVSDynamicMarkInspModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 0xB4 | 匹配终止角度 |
| AngleEnd_Detect | Integer | - | 0xB4 | 匹配终止角度 |
| AngleStart | Integer | - | 0xFFFFFF4C | 匹配起始角度 |
| AngleStart_Detect | Integer | - | 0xFFFFFF4C | 匹配起始角度 |
| AreaThreshold | Integer | - | 10 | 单缺陷面积阈值 |
| BackGroundEdgeOffset | Integer | - | 6 | 背景边缘容忍 |
| BinarizeWinSize | Integer | - | 0xF | 二值化窗口大小 |
| CharAreaThreshold | Integer | - | 999999 | 字符区累计缺陷阈值 |
| CharColorOffset | Integer | - | 20 | 字符区域颜色偏差最大阈值 |
| CharEdgeOffset | Integer | - | 3 | 字符边缘容忍 |
| CharPixelBrightContrast | Integer | - | 20 | 字符区域亮缺陷阈值 |
| CharPixelDarkContrast | Integer | - | 20 | 字符区域暗缺陷阈值 |
| ColorOffset | Integer | - | 20 | 颜色偏差最大阈值 |
| EdgeThreshold | Integer | - | 0xF | 边缘阈值 |
| GradCellLen | Integer | - | 6 | 缺陷尺寸 |
| GradNoiseRatio | Integer | - | 10 | 背景噪声抑制参数 |
| GradNoiseThreshold | Integer | - | 10 | 背景噪声抑制阈值 |
| HardThreshold | Integer | - | 0x80 | 字符分割硬阈值 |
| HistNormRatio | Integer | - | 30 | 直方图归一化比率 |
| MarkMatchEnlargeHeight_Detect | Integer | - | 30 | 外扩高度 |
| MarkMatchEnlargeHeight_Train | Integer | - | 30 | 外扩高度 |
| MarkMatchEnlargeWidth_Detect | Integer | - | 30 | 外扩宽度 |
| MarkMatchEnlargeWidth_Train | Integer | - | 30 | 外扩宽度 |
| MaxCharWidth | Integer | - | 0xF | 最大字符宽度 |
| MaxFlawNum | Integer | - | 50 | 最大缺陷数 |
| MaxMatchNum | Integer | - | 0x1 | 最大匹配个数 |
| MaxMatchNum_Detect | Integer | - | 0x1 | 最大匹配个数 |
| MaxOverlap | Integer | - | 0x28 | 最大重叠率 |
| MaxOverlap_Detect | Integer | - | 0x28 | 最大重叠率 |
| MinChainLen | Integer | - | 0x4 | 最小链长长度 |
| MinCharArea | Integer | - | 0xA | 最小字符面积 |
| MinCharWidth | Integer | - | 0xA | 最小字符宽度 |
| PixelBrightContrast | Integer | - | 20 | 亮缺陷阈值 |
| PixelDarkContrast | Integer | - | 20 | 暗缺陷阈值 |
| PyramidScaleLevel | Integer | - | 5 | 模型层数 |
| PyramidScaleRLevel | Integer | - | 1 | 模型返回层 |
| ScoreThreshold | Integer | - | 50 | 分数阈值 |
| BinaryImageShow | Boolean | 0 | False | Display Binary Pic |
| ChainFlag | Boolean | - | True | 链长使能标记 |
| EdgeThresholdFlag | Boolean | - | True | 边缘阈值标记 |
| GradFlag_Detect | Boolean | - | True | 梯度特征开关 |
| GradFlag_Train | Boolean | - | True | 梯度特征标志 |
| MarkMatchFlag | Boolean | - | True | 精定位标志 |
| MaskModelFlag | Boolean | - | False | 掩膜形状建模使能 |
| PixelFlag_Detect | Boolean | - | True | 像素特征开关 |
| PixelFlag_Train | Boolean | - | True | 像素特征标志 |
| PyramidScaleFlag | Boolean | - | True | 特征尺度标记 |
| SaveEdgePointEnable | Boolean | - | True | 存储边缘点使能 |
| SpotterFlag | Boolean | - | False | 匹配噪点标记 |
| SpotterFlag_Detect | Boolean | - | False | 匹配噪点标记 |
| WeightMaskFlag | Boolean | - | False | 权重掩膜使能标记 |
| SubInputBox | RadioSelecter | - | 0 | Input Mode |
| Box | ButtonSelecter | - | - | Box |
| BoxAngle | ButtonSelecter | - | - | BoxAngle |
| BoxCenterX | ButtonSelecter | - | - | BoxCenterX |
| BoxCenterY | ButtonSelecter | - | - | BoxCenterY |
| BoxHeight | ButtonSelecter | - | - | BoxHeight |
| BoxWidth | ButtonSelecter | - | - | BoxWidth |
| TextInput | ButtonSelecter | - | - | Input Text |

### IMVSEdgeFlawInspModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperWidth | Integer | - | 5 | CaliperWidth |
| EdgeStrength | Integer | - | 25 | Edge Intensity |
| GradLen | Integer | - | 2 | 最小阶梯长度 |
| GradThresh | Integer | - | 3 | 阶梯偏离高度 |
| GrayTrackDistol | Integer | - | 0 | RunParam_GrayTrackDistol |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| LenThresh | Integer | - | 2 | Defect Length Threshold |
| MaxFlawNum | Integer | - | 500 | 最大缺陷数量 |
| ModCaliperDist | Integer | - | 3 | Caliper Spacing |
| ModCaliperHeight | Integer | - | 50 | CaliperHeight |
| ModCaliperWidth | Integer | - | 5 | CaliperWidth |
| ModEdgeStrength | Integer | - | 25 | Edge Intensity |
| ModHalfKernelSize | Integer | - | 0x1 | KernelSize |
| ModifyThresh | Integer | - | 5 | 拟合偏离阈值 |
| ModModifyThresh | Integer | - | 5 | 拟合偏离阈值 |
| OffsetThresh | Integer | - | 50 | Location Deviation Threshold |
| CrackEnable | Boolean | - | True | Fracture Defect Enable |
| GradEnable | Boolean | - | False | Enable Hierarchical Defect |
| GrayTrackEnable | Boolean | - | False | RunParam_GrayTrackEnable |
| ModFineEdgeEnable | Boolean | - | False | RunParam_FineEdgeEnable |
| ModifyWrongPts | Boolean | - | False | Modify Error Point |
| ModModifyWrongPts | Boolean | - | False | Modify Error Point |
| OffsetEnable | Boolean | - | True | Location Defect Enable |
| RoiSelect | RadioSelecter | - | 0 | ROI Creation |

### IMVSEdgeInspGroupModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperWidth | Integer | - | 5 | CaliperWidth |
| CaliperWidth | Integer | - | 0x5 | CaliperWidth |
| CircleCaliperNum | Integer | - | 20 | Caliper Number |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| LineCaliperNum | Integer | - | 20 | Caliper Number |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinDis | Integer | - | 5 | RunParam_RoughMinDis |
| RoughMinDis | Integer | - | 5 | RunParam_RoughMinDis |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| StandardInput | Boolean | 0 | False | 标准输入 |
| StandardInput | Boolean | 0 | False | 标准输入 |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| AngleExtend | ButtonSelecter | - | - | AngleRange |
| CenterPointX | ButtonSelecter | - | - | Circular Annulus Center X |
| CenterPointY | ButtonSelecter | - | - | Circular Annulus Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| InnerRadius | ButtonSelecter | - | - | InnerRadius |
| LINE | ButtonSelecter | - | - | select Line |
| OuterRadius | ButtonSelecter | - | - | OuterRadius |
| StartAngle | ButtonSelecter | - | - | Angle Start |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSEdgePairFlawInspModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AutoTrajMaxWidthBias | Integer | - | 50 | 最大偏差 |
| AutoTrajSmoCoef | Integer | - | 0 | 平滑系数 |
| AutoTrajStartEdgeStrength | Integer | - | 25 | Edge Intensity |
| AutoTrajStartIdeaWidth | Integer | - | 30 | Ideal Width |
| BubbleChangeThresh | Integer | - | - | RunParam_BubbleChangeThresh |
| BubbleGrayChangeNum | Integer | - | - | RunParam_BubbleGrayChangeNum |
| BubbleHighOffset | Integer | - | - | RunParam_BubbleLowOffset |
| BubbleLen | Integer | - | - | RunParam_BubbleLen |
| BubbleLowOffset | Integer | - | - | RunParam_BubbleHighOffset |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperWidth | Integer | - | 5 | CaliperWidth |
| EdgePairIdealWidth | Integer | - | 30 | Ideal Width |
| EdgeStrength | Integer | - | 25 | Edge Intensity |
| GradLen | Integer | - | 2 | 最小阶梯长度 |
| GradThresh | Integer | - | 3 | 阶梯偏离高度 |
| GrayTrackDistol | Integer | - | 0 | RunParam_GrayTrackDistol |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| LenThresh | Integer | - | 2 | Defect Length Threshold |
| MaxFlawNum | Integer | - | 500 | Defect Quantity |
| ModCaliperDistCourse | Integer | - | 3 | Caliper Spacing |
| ModCaliperHeight | Integer | - | 50 | CaliperHeight |
| ModCaliperWidth | Integer | - | 5 | CaliperWidth |
| ModEdgePairIdealWidth | Integer | - | 30 | Ideal Width |
| ModEdgeStrength | Integer | - | 25 | Edge Intensity |
| ModHalfKernelSize | Integer | - | 0x1 | KernelSize |
| ModifyThresh | Integer | - | 5 | 拟合偏离阈值 |
| ModModifyThresh | Integer | - | 5 | 拟合偏离阈值 |
| OffsetThresh | Integer | - | 50 | Location Deviation Threshold |
| WidthHighOffset | Integer | - | 150 | RunParam_Max. Width Proportion |
| WidthLowOffset | Integer | - | 50 | RunParam_Min. Width Proportion |
| AutoTrajAutoCfg | Boolean | - | False | 自动参数 |
| BubbleEnable | Boolean | - | True | RunParam_BubbleEnable |
| CrackEnable | Boolean | - | True | Fracture Defect Enable |
| GradEnable | Boolean | - | False | Enable Hierarchical Defect |
| GrayTrackEnable | Boolean | - | False | RunParam_GrayTrackEnable |
| MidPointEnable | Boolean | - | False | MidPointEnable |
| ModFineEdgeEnable | Boolean | - | False | RunParam_FineEdgeEnable |
| ModifyWrongPts | Boolean | - | False | Modify Error Point |
| ModModifyWrongPts | Boolean | - | False | Modify Error Point |
| OffsetEnable | Boolean | - | True | Location Defect Enable |
| WidthEnable | Boolean | - | True | Width Defect Enable |
| RoiSelect | RadioSelecter | - | 0 | ROI Creation |
| CreateAutoTraj | Command | - | - | Lang_CreateTraj |

### IMVSEdgePairInspGroupModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleTol | Integer | - | 50 | Angle Tolerance |
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperWidth | Integer | - | 5 | CaliperWidth |
| CaliperWidth | Integer | - | 0x5 | CaliperWidth |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| FitCaliperNum | Integer | - | 20 | Caliper Number |
| FitConcentricTol | Integer | - | 50 | Angle Tolerance |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| IdeaWidth | Integer | - | 40 | Ideal Width |
| IdeaWidth | Integer | - | 40 | Ideal Width |
| LineCaliperNum | Integer | - | 20 | Caliper Number |
| RoughMaxDis | Integer | - | 50 | Max. Distance |
| RoughMaxDis | Integer | - | 50 | Max. Distance |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinDis | Integer | - | 5 | Min. Distance |
| RoughMinDis | Integer | - | 5 | Min. Distance |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| MidPointEnable | Boolean | - | False | MidPointEnable |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| StandardInput | Boolean | 0 | False | 标准输入 |
| StandardInput | Boolean | 0 | False | 标准输入 |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay2 | RadioSelecter | - | 0 | Input Mode |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| AngleExtend1 | ButtonSelecter | - | - | AngleRange |
| AngleExtend2 | ButtonSelecter | - | - | AngleRange |
| CenterPointX1 | ButtonSelecter | - | - | Circular Annulus Center X |
| CenterPointX2 | ButtonSelecter | - | - | Circular Annulus Center X |
| CenterPointY1 | ButtonSelecter | - | - | Circular Annulus Center Y |
| CenterPointY2 | ButtonSelecter | - | - | Circular Annulus Center Y |
| Circle1 | ButtonSelecter | - | - | Circle |
| Circle2 | ButtonSelecter | - | - | Circle |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPoint2 | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointX2 | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| EndPointY2 | ButtonSelecter | - | - | Endpoint Y Coordinate |
| InnerRadius1 | ButtonSelecter | - | - | InnerRadius |
| InnerRadius2 | ButtonSelecter | - | - | InnerRadius |
| LINE | ButtonSelecter | - | - | select Line |
| LINE2 | ButtonSelecter | - | - | select Line |
| OuterRadius1 | ButtonSelecter | - | - | OuterRadius |
| OuterRadius2 | ButtonSelecter | - | - | OuterRadius |
| StartAngle1 | ButtonSelecter | - | - | Angle Start |
| StartAngle2 | ButtonSelecter | - | - | Angle Start |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPoint2 | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointX2 | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |
| StartPointY2 | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSEdgePairPosTrendAnalyModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperCount | Integer | - | 20 | Caliper Number |
| DistHigh | Integer | - | 10000 | Distance High Threshold |
| DistLow | Integer | - | 1 | Distance Lower Threshold |
| EdgeStrength | Integer | - | 25 | EdgeThreshold |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| IdeaWid | Integer | - | 30 | RunParam_IdeaEdgeWith |
| ProjectionLength | Integer | - | 5 | CaliperWidth |
| DistHighIsAutoEnable | Boolean | - | False | RunParam_High_Threshold_Enable |
| MidPointEnable | Boolean | - | True | MidPointEnable |

### IMVSEdgePosTrendAnalyModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperCount | Integer | - | 20 | Caliper Number |
| DistHigh | Integer | - | 10000 | Distance High Threshold |
| DistLow | Integer | - | 1 | Distance Lower Threshold |
| EdgeStrength | Integer | - | 25 | EdgeThreshold |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| ProjectionLength | Integer | - | 5 | CaliperWidth |
| DistHighIsAutoEnable | Boolean | - | False | RunParam_High_Threshold_Enable |

### IMVSEdgeTrendInspModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperCount | Integer | - | 20 | Caliper Number |
| DislocationLenHig | Integer | - | 0x4 | DislocationFlawHighThresh |
| DislocationLenLow | Integer | - | 0x1 | DislocationFlawLowThresh |
| EdgeStrength | Integer | - | 25 | EdgeThreshold |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| MinLengthThresh | Integer | - | 0x5 | RunParam_RoughMinSize |
| ProjectionLength | Integer | - | 5 | CaliperWidth |
| MinLengthEnable | Boolean | - | True | Defect Size Enable |

### IMVSEdgeWidthFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ContrastTH | Integer | - | 0x5 | EdgeThreshold |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| IdeaWidth | Integer | - | 0xa | RunParam_Ideal_Space |
| Maximum | Integer | - | 0x1 | Max Result Number |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| Edge0PointXLimitEnable | Boolean | 0 | False | Edge Point 0X Check |
| Edge0PointYLimitEnable | Boolean | 0 | False | Edge Point 0Y Check |
| Edge1PointXLimitEnable | Boolean | 0 | False | Edge Point 1X Check |
| Edge1PointYLimitEnable | Boolean | 0 | False | Edge Point 1Y Check |
| EdgeWidthLimitEnable | Boolean | 0 | False | Width Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |

### IMVSEllipseFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| EdgeThresh | Integer | - | 0xf | EdgeThreshold |
| EdgeWidth | Integer | - | 5 | KernelSize |
| FitErrorTolerance | Integer | - | 0x3 | RunParam_ErrorTolerance |
| RaysNum | Integer | - | 0x32 | Caliper Number |
| RegionWidth | Integer | - | 0x5 | Projection Width |
| RegionWidth | Integer | - | 0x5 | Projection Width |

### IMVSEllipseFitModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ErrorTolerance | Integer | - | 3 | RunParam_ErrorTolerance |
| NumLimitHigh | Integer | - | 10 | RunParam_Fit Points Upper Limit |
| NumLimitLow | Integer | - | 0 | Fit Points Lower Limit |
| CenterXLimitEnable | Boolean | 0 | False | Center X Check |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| NumLimitEnable | Boolean | 0 | False | Fit Points Check |
| ScoreLimitEnable | Boolean | 0 | False | Fit Error Check |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| FittingPoints | ButtonSelecter | - | - | Point |
| FittingPointsX | ButtonSelecter | - | - | PointX |
| FittingPointsY | ButtonSelecter | - | - | pointy |

### IMVSFastFeatureMatchModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 180 | Angle End |
| AngleStart | Integer | - | -180 | Angle Start |
| MatchExtentRate | Integer | - | 0 | Extension Threshold |
| MatchThresholdHigh | Integer | - | 40 | EdgeThreshold |
| MaxMatchNum | Integer | - | 0x1 | RunParam_Max Number to find |
| MaxOverlap | Integer | - | 0x32 | Overlap Threshold |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| TimeOut | Integer | - | 0x0 | RunParam_Overtime Control |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| BoxPointXLimitEnable | Boolean | 0 | False | Central Point X Check |
| BoxPointYLimitEnable | Boolean | 0 | False | Central Point Y Check |
| MatchPointXLimitEnable | Boolean | 0 | False | Match Point X Check |
| MatchPointYLimitEnable | Boolean | 0 | False | Match Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| OKWhenNumIsZero | Boolean | 0 | False | OKWhenMatchNumIsZero |
| OutLineEnable | Boolean | 0 | True | RunParam_Contour Enabled |
| ScaleLimitEnable | Boolean | 0 | False | Scale Check |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |
| SpotterFlag | Boolean | 0 | False | Mottle Considered |
| UseMatchAllMode | Boolean | 0 | False | RunParam_Use Match All Mode |

### IMVSFixtureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Select | RadioSelecter | - | 0 | Choose Mode |
| ScaleX | ButtonSelecter | - | - | RunParam_ScaleX |
| ScaleY | ButtonSelecter | - | - | RunParam_ScaleY |
| StandAngle | ButtonSelecter | - | - | Angle |
| StandPoint | ButtonSelecter | - | - | Origin |
| StandPointX | ButtonSelecter | - | - | Origin X |
| StandPointY | ButtonSelecter | - | - | Origin Y |

### IMVSFrameMeanModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RoiSelect | RadioSelecter | - | 0 | ROI Creation |

### IMVSGluePathConductModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ModCaliperHeight | Integer | - | 50 | CaliperHeight |
| ModCaliperWidth | Integer | - | 5 | CaliperWidth |
| ModEdgeStrength | Integer | - | 25 | EdgeThreshold |
| ModHalfKernelSize | Integer | - | 0x1 | KernelSize |
| ModHalfKernelSize | Integer | - | 0x1 | KernelSize |
| ModMaxPointNum | Integer | - | 25 | RunParam_Path Point Number |
| ModPointOffsetLen | Integer | - | 0x0 | RunParam_Position Offset |
| ArcParamEnable | Boolean | - | False | RunParam_ArcParamEnable |

### IMVSGrayMatchModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 45 | Angle End |
| AngleStart | Integer | - | -45 | Angle Start |
| AngleStep | Integer | - | 8 | Step Of Angle |
| MaxMatchNum | Integer | - | 0x1 | RunParam_Max Number to find |
| MaxOverlap | Integer | - | 0x28 | Overlap Threshold |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| TimeOut | Integer | - | 0x0 | RunParam_Overtime Control |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| BoxPointXLimitEnable | Boolean | 0 | False | Central Point X Check |
| BoxPointYLimitEnable | Boolean | 0 | False | Central Point Y Check |
| MatchPointXLimitEnable | Boolean | 0 | False | Match Point X Check |
| MatchPointYLimitEnable | Boolean | 0 | False | Match Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| OKWhenNumIsZero | Boolean | 0 | False | OKWhenMatchNumIsZero |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |

### IMVSGrayMatchModuVA

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 45 | Angle End |
| AngleStart | Integer | - | -45 | Angle Start |
| EndPyramidLevel | Integer | - | 0x0 | RunParam_EndPyramidLevel Feature |
| MaxMatchNum | Integer | - | 0x1 | RunParam_Max Number to find |
| MaxOverlap | Integer | - | 0x28 | Overlap Threshold |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| Polarity | Integer | - | 0x1 | Match Polarity |
| TimeOut | Integer | - | 0x0 | RunParam_Overtime Control |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| BoxPointXLimitEnable | Boolean | 0 | False | Central Point X Check |
| BoxPointYLimitEnable | Boolean | 0 | False | Central Point Y Check |
| MatchPointXLimitEnable | Boolean | 0 | False | Match Point X Check |
| MatchPointYLimitEnable | Boolean | 0 | False | Match Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| OKWhenNumIsZero | Boolean | 0 | False | OKWhenMatchNumIsZero |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |
| UseMatchAllMode | Boolean | 0 | False | RunParam_Use Match All Mode |

### IMVSGrayRangeModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| MaskHeight | Integer | - | - | 掩膜高度 |
| MaskWidth | Integer | - | - | 掩膜宽度 |

### IMVSGridLocationModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| FrontMainGridNum | Integer | - | 9 | FrontMain Grid Num |
| ReverseMainGridNum | Integer | - | 9 | ReverseMain Grid Num |
| InheritWay | RadioSelecter | - | 0 | - |
| CellBoxAngle | ButtonSelecter | - | - | CellBox Angle |
| CellBoxCenterX | ButtonSelecter | - | - | CellBox Center Point X |
| CellBoxCenterY | ButtonSelecter | - | - | CellBox Center Point Y |
| CellBoxHeight | ButtonSelecter | - | - | CellBox Height |
| CellBoxNum | ButtonSelecter | - | - | RunParam_CellBoxNum |
| CellBoxWidth | ButtonSelecter | - | - | CellBox Width |
| MatchBoxAngle | ButtonSelecter | - | - | MatchBox Angle |
| MatchBoxCenterX | ButtonSelecter | - | - | MatchBox Center Point X |
| MatchBoxCenterY | ButtonSelecter | - | - | MatchBox Center Point Y |
| MatchBoxHeight | ButtonSelecter | - | - | MatchBox Height |
| MatchBoxNums | ButtonSelecter | - | - | MatchBoxNums |
| MatchBoxWidth | ButtonSelecter | - | - | MatchBox Width |
| Region_CellBox | ButtonSelecter | - | - | Region_CellBox |
| Region_MatchBox | ButtonSelecter | - | - | Region_MatchBox |
| Region_ROI | ButtonSelecter | - | - | Region_ROI |
| ROIAngle | ButtonSelecter | - | - | Region_ROI Angle |
| ROICenterX | ButtonSelecter | - | - | Region_ROI Center Point X |
| ROICenterY | ButtonSelecter | - | - | Region_ROI Center Point Y |
| ROIHeight | ButtonSelecter | - | - | Region_ROI Height |
| ROIWidth | ButtonSelecter | - | - | Region_ROI Width |

### IMVSGroup ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| DebugIndex | Integer | 0 | 0 | Debug Index |
| LoopTimeGap | Integer | 0 | 0 | Cycle Time(ms) |
| EnableBreak | Boolean | 0 | False | RunParam_Break Loop |
| EnableDebug | Boolean | 0 | False | Enable Debug |
| EnableLoop | Boolean | 0 | False | Loop Enable |
| BaseX1 | ButtonSelecter | - | - | Lang_Base Compare Value |
| BaseX1b | ButtonSelecter | - | - | Lang_Target Compare Value |
| BaseX2 | ButtonSelecter | - | - | Lang_Base Compare Value |
| BaseX2b | ButtonSelecter | - | - | Lang_Target Compare Value |
| BaseX3 | ButtonSelecter | - | - | Lang_Base Compare Value |
| BaseX3b | ButtonSelecter | - | - | Lang_Target Compare Value |
| LoopEndCount | ButtonSelecter | - | - | Cycle End Value |
| LoopStartCount | ButtonSelecter | - | - | Cycle Start Value |
| BaseX1T | ButtonSelecter_LoopControl | - | - | Lang_Target Compare Value |
| BaseX2T | ButtonSelecter_LoopControl | - | - | Lang_Target Compare Value |
| BaseX3T | ButtonSelecter_LoopControl | - | - | Lang_Target Compare Value |

### IMVSHPFeatureMatchModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 180 | Angle End |
| AngleStart | Integer | - | -180 | Angle Start |
| MatchExtentRate | Integer | - | 0 | Extension Threshold |
| MatchThresholdHigh | Integer | - | 40 | EdgeThreshold |
| MaxMatchNum | Integer | - | 0x1 | RunParam_Max Number to find |
| MaxOverlap | Integer | - | 0x32 | Overlap Threshold |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| TimeOut | Integer | - | 0x0 | RunParam_Overtime Control |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| BoxPointXLimitEnable | Boolean | 0 | False | Central Point X Check |
| BoxPointYLimitEnable | Boolean | 0 | False | Central Point Y Check |
| MatchPointXLimitEnable | Boolean | 0 | False | Match Point X Check |
| MatchPointYLimitEnable | Boolean | 0 | False | Match Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| OKWhenNumIsZero | Boolean | 0 | False | OKWhenMatchNumIsZero |
| OutLineEnable | Boolean | 0 | True | RunParam_Contour Enabled |
| ScaleLimitEnable | Boolean | 0 | False | Scale Check |
| ScaleXLimitEnable | Boolean | 0 | False | X Scale Check |
| ScaleYLimitEnable | Boolean | 0 | False | Y Scale Check |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |
| SpotterFlag | Boolean | 0 | False | Mottle Considered |
| UseMatchAllMode | Boolean | 0 | False | RunParam_Use Match All Mode |

### IMVSHistToolModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CountLimitHigh | Integer | - | 999999999 | Quantity Upper Limit |
| CountLimitLow | Integer | - | 0 | Quantity Lower Limit |
| MaxValueLimitHigh | Integer | - | 255 | Max Value Upper Limit |
| MaxValueLimitLow | Integer | - | 0 | Max Value Lower Limit |
| MedianValueLimitHigh | Integer | - | 255 | Mid Value Upper Limit |
| MedianValueLimitLow | Integer | - | 0 | Mid Value Lower Limit |
| MinValueLimitHigh | Integer | - | 255 | Min Value Upper Limit |
| MinValueLimitLow | Integer | - | 0 | Min Value Lower Limit |
| ModeValueLimitHigh | Integer | - | 255 | Peak Value Upper Limit |
| ModeValueLimitLow | Integer | - | 0 | Peak Value Lower Limit |
| ContrastLimitEnable | Boolean | 0 | False | Contrast Judge |
| CountLimitEnable | Boolean | 0 | False | Quantity Check |
| MaxValueLimitEnable | Boolean | 0 | False | Max Value Check |
| MeanLimitEnable | Boolean | 0 | False | Mean Value Check |
| MedianValueLimitEnable | Boolean | 0 | False | Mid Value Check |
| MinValueLimitEnable | Boolean | 0 | False | Min Value Check |
| ModeValueLimitEnable | Boolean | 0 | False | Peak Value Check |
| StdLimitEnable | Boolean | 0 | False | SD Check |

### IMVSImageCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Circularity | Integer | - | 60 | RunParam_Dot Circularity |
| DistThreshold | Integer | - | 30 | Dis Thre |
| EdgeThreshHigh | Integer | - | 40 | Edge High Threshold |
| EdgeThreshLow | Integer | - | 20 | Edge Low Threshold |
| GrayContrast | Integer | - | 15 | RunParam_Grayscale Contrast |
| SampleRatio | Integer | - | 60 | Sampling Rate |
| SubPixelWindowSize | Integer | - | 7 | 设置窗口大小 |
| WeightFactor | Integer | - | 20 | RunParam_Weighting Coefficient |
| DistortionEvaluationEnable | Boolean | - | False | DistortionEvaluationEnable |
| OutputPostCorrectionEnable | Boolean | - | False | OutputPostCorrectionEnable |
| RefreshFileEnable | Boolean | - | False | RefreshFileEnable |
| CorrectCenterPointInput | RadioSelecter | - | 0 | Correct Center Input |
| CorrectCenterPoint | ButtonSelecter | - | - | CorrectCenterPoint |
| CorrectCenterPointX | ButtonSelecter | - | - | Correct Center X |
| CorrectCenterPointY | ButtonSelecter | - | - | Correct Center Y |

### IMVSImageCombineProcessModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BrightGain | Integer | - | 0 | Tab_Gain |
| BrightOffset | Integer | - | 0 | RunParam_Compensation |
| ContrastFactor | Integer | - | 0x64 | RunParam_Contrast Coefficient |
| EdegHighThreshold | Integer | - | 0x0 | Edge High Threshold |
| EdegLowThreshold | Integer | - | 0x0 | Edge Low Threshold |
| Gain | Integer | - | 0x0 | Tab_Gain |
| GaussKernelSize | Integer | - | 0x3 | Gaussian Filter Kernel |
| GaussKernelSize | Integer | - | 0x3 | Gaussian Filter Kernel |
| HighThreshold | Integer | - | 0xFF | High Threshold |
| KernelHeight | Integer | - | 0x3 | Filter Kernel Height |
| KernelHeight | Integer | - | 0x3 | RunParam_Element Height |
| KernelHeight | Integer | - | 0x3 | Filter Kernel Height |
| KernelWidth | Integer | - | 0x3 | Filter Kernel Width |
| KernelWidth | Integer | - | 0x3 | RunParam_Element Width |
| KernelWidth | Integer | - | 0x3 | Filter Kernel Width |
| LowThreshold | Integer | - | 0x0 | Low Threshold |
| MorphIterNum | Integer | - | 0x1 | RunParam_Iteration Times |
| Noise | Integer | - | 0x0 | Noise |
| Offset | Integer | - | 0x80 | RunParam_Compensation |
| Ratio | Integer | - | 0x1 | KernelSize |
| SauvolaWinHeight | Integer | - | 0x0F | Filter Kernel Height |
| SauvolaWinWidth | Integer | - | 0x0F | Filter Kernel Width |
| SharpenKernelSize | Integer | - | 0x3 | RunParam_Kernel Size |
| SharpenStrength | Integer | - | 0x0 | Sharpen Intensity |
| ThresholdOffset | Integer | - | 0x0 | Threshold Offset |

### IMVSImageCorrectCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |

### IMVSImageCorrectManualModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| WarpPara | Integer | - | 0 | RunParam_DistortWarp |
| ZoomPara | Integer | - | 0 | RunParam_DistortZoom |

### IMVSImageEnhanceModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BrightGain | Integer | - | 0 | Tab_Gain |
| BrightOffset | Integer | - | 0 | RunParam_Compensation |
| ContrastFactor | Integer | - | 0x64 | RunParam_Contrast Coefficient |
| SharpenKernelSize | Integer | - | 0x3 | RunParam_Kernel Size |
| SharpenStrength | Integer | - | 0x0 | Sharpen Intensity |

### IMVSImageFilterModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| EdegHighThreshold | Integer | - | 0x0 | Edge Threshold Upper Limit |
| EdegLowThreshold | Integer | - | 0x0 | Edge Threshold Lower Limit |
| GaussKernelSize | Integer | - | 0x3 | Gaussian Filter Kernel |
| KernelHeight | Integer | - | 0x3 | Filter Kernel Height |
| KernelWidth | Integer | - | 0x3 | Filter Kernel Width |

### IMVSImageFixtureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SelectWay | RadioSelecter3 | - | 0 | Choose Mode |
| Angle | ButtonSelecter | - | - | InitAngle |
| BaseX | ButtonSelecter | - | - | InitPointX |
| BaseY | ButtonSelecter | - | - | InitPointY |
| CorrectInfo | ButtonSelecter | - | - | Fixture Info |
| OriginPoint | ButtonSelecter | - | - | Fixtured Point |
| RunAngle | ButtonSelecter | - | - | RunAngle |
| RunPoint | ButtonSelecter | - | - | Unfixtured Point |
| RunPointBaseX | ButtonSelecter | - | - | RunPointX |
| RunPointBaseY | ButtonSelecter | - | - | RunPointY |
| RunScaleX | ButtonSelecter | - | - | RunScaleX |
| RunScaleY | ButtonSelecter | - | - | RunScaleY |
| ScaleX | ButtonSelecter | - | - | InitScaleX |
| ScaleY | ButtonSelecter | - | - | InitScaleY |

### IMVSImageMorphModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| KernelHeight | Integer | - | 0x3 | RunParam_Element Height |
| KernelWidth | Integer | - | 0x3 | RunParam_Element Width |
| MorphIterNum | Integer | - | 0x1 | RunParam_Iteration Times |

### IMVSImageResizeModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| HeightValue | Integer | - | 0x320 | OutImageHeight |
| LowThreshold | Integer | - | 0x0 | Low Threshold |
| ResizeFillValue | Integer | - | 0x7F | Fill Value |
| WidthValue | Integer | - | 0x320 | OutImageWidth |
| AntiAliasing | Boolean | 0 | False | RunParam_AntiAliasing |

### IMVSImageSharpnessModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| NoiseLevel | Integer | - | 0 | Noise Level |

### IMVSImgStitchCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CutRatio | Integer | - | 0x0 | CutRatio |
| CutRatioX | Integer | - | 0x0 | CutRatioX |
| CutRatioY | Integer | - | 0x0 | CutRatioY |
| AutoClear | Boolean | 0 | False | AutoClear |
| AutoFill | Boolean | 0 | False | RunParam_AutoFill |
| FirstImageFlag | ButtonSelecter | - | - | FirstImageFlag |

### IMVSInspectModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlockNum | Integer | - | 6 | Min size of flaw |
| DownSampleRate | Integer | - | 100 | Rate |
| MatchAngleEnd | Integer | - | 180 | Angle End |
| MatchAngleEnd | Integer | - | 180 | Angle End |
| MatchAngleStart | Integer | - | -180 | Angle Start |
| MatchAngleStart | Integer | - | -180 | Angle Start |
| MatchExtentRate | Integer | - | 0 | Extension Threshold |
| MatchThreshold | Integer | - | 40 | EdgeThreshold |
| MatchThreshold | Integer | - | 40 | EdgeThreshold |

### IMVSInspectV2Modu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlockNum | Integer | - | 6 | Block Num |
| ColorPixelArea | Integer | - | 0xA | RunParam_ColorPixelArea |
| ColorPixelEdgeOffsetMax | Integer | - | 0x3 | PixelEdgeOffsetMaxValue |
| ColorPixelIsOutFlaw | Integer | - | 0x1 | RunParam_ColorPixelIsOutFlaw |
| ColorPixelLearnScale | Integer | - | 0xA | RunParam_ColorPixelLearnScale |
| ColorPixelLowerEdgeOffset | Integer | - | 0x6 | PixelLowerEdgeOffset |
| ColorPixelMaxOffset | Integer | - | 0xF | RunParam_ColorPixelMaxOffset |
| ColorPixelSampleRate | Integer | - | 0x64 | PixelSampleRate |
| DarkScale | Integer | - | 0xA | RunParam_DarkScale |
| DarkThres | Integer | - | 0x14 | RunParam_DarkThres |
| DownSampleRate | Integer | - | 100 | Rate |
| DownSampleRate | Integer | - | 100 | Rate |
| EdgeTolerance | Integer | - | 0x0 | RunParam_EdgeTolerance |
| LightScale | Integer | - | 0xA | RunParam_LightScale |
| LightThres | Integer | - | 0x14 | RunParam_LightThres |
| MatchAngleEnd | Integer | - | 180 | Angle End |
| MatchAngleEnd | Integer | - | 180 | Angle End |
| MatchAngleStart | Integer | - | -180 | Angle Start |
| MatchAngleStart | Integer | - | -180 | Angle Start |
| MatchThreshold | Integer | - | 40 | EdgeThreshold |
| MatchThreshold | Integer | - | 40 | EdgeThreshold |
| MinFlawArea | Integer | - | 0xA | RunParam_MinFlawArea |
| PixelEdgeOffsetMax | Integer | - | 0x3 | PixelEdgeOffsetMaxValue |
| PixelLowerEdgeOffset | Integer | - | 0x6 | PixelLowerEdgeOffset |
| PixelNormBrightScale | Integer | - | 30 | BrightnessNormalizationScale |
| PixelNormBrightScaleRunParam | Integer | - | 0x1E | BrightnessNormalizationScale |
| PixelSampleRate | Integer | - | 0x64 | PixelSampleRate |
| RestrainRatio | Integer | - | 10 | RestrainRatio |
| RestrainRatio | Integer | - | 10 | RestrainRatio |
| RestrainThreshold | Integer | - | 50 | Restrain threshold of background noise |
| RestrainThreshold | Integer | - | 50 | RestrainThreshold |
| ThreadCount | Integer | - | - | ThreadCount |
| IsFeatureMatchEnable | Boolean | 0 | False | FeatureMatchEnable |
| ISImageP3 | Boolean | 0 | False | 输入P3图 |
| IsOutFlawInfo | Boolean | 0 | True | RunParam_IsOutFlawInfo |
| IsSubscribeMaskImage | Boolean | 0 | False | Direct Subscription Mask |
| IsSubscribeROIData | Boolean | 0 | False | Direct Subscription |
| MatchEnable | Boolean | - | False | FeatureMatchEnable |
| OutHighDiffImgEnable | Boolean | 0 | False | RunParam_OutHighDiffImgEnable |
| OutLowDiffImgEnable | Boolean | 0 | False | RunParam_OutLowDiffImgEnable |
| OutLowHighDiffImgEnable | Boolean | 0 | False | RunParam_OutLowHighDiffImgEnable |
| OutModelMaxMinImgEnable | Boolean | 0 | False | RunParam_OutModelMaxMinImgEnable |
| OutNgPointEnable | Boolean | 0 | False | RunParam_OutNgPointEnable |
| OutOkPointEnable | Boolean | 0 | False | RunParam_OutOkPointEnable |
| PixelModelRefFlag | Boolean | - | True | PixelModelRefFlag |
| UseEdgeTolerMapImage | Boolean | 0 | False | UseEdgeTolerMapImage |
| MatchInputRangleROISelecter | ButtonSelecter | - | - | Box ROI |
| ModelLabel | ButtonSelecter | - | - | ModelLabel |

### IMVSIntensityMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| MaxValueLimitHigh | Integer | - | 255 | Max Value Upper Limit |
| MaxValueLimitLow | Integer | - | 0 | Max Value Lower Limit |
| MinValueLimitHigh | Integer | - | 255 | Min Value Upper Limit |
| MinValueLimitLow | Integer | - | 0 | Min Value Lower Limit |
| ContrastLimitEnable | Boolean | 0 | False | Contrast Judge |
| MaxValueLimitEnable | Boolean | 0 | False | Max Value Check |
| MeanLimitEnable | Boolean | 0 | False | Mean Value Check |
| MinValueLimitEnable | Boolean | 0 | False | Min Value Check |
| StdLimitEnable | Boolean | 0 | False | SD Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |

### IMVSInverseAffineTransformModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InheritWay | RadioSelecter | - | 0 | Inheritance Mode |
| InputType | RadioSelecter | - | 0 | RunParam_Input Type |
| ImageHeight | ButtonSelecter | - | - | ImageHeight |
| ImageWidth | ButtonSelecter | - | - | ImageWidth |
| Region | ButtonSelecter | - | - | Region |
| ROIAngle | ButtonSelecter | - | - | roiangle |
| ROICenterX | ButtonSelecter | - | - | roicenterx |
| ROICenterY | ButtonSelecter | - | - | roicentery |
| ROIHeight | ButtonSelecter | - | - | roiheight |
| ROIWidth | ButtonSelecter | - | - | roiwidth |

### IMVSInverseAffineTransformShapeModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Assist0 | Boolean | 0 | False | Fixture |
| SubInputBox | RadioSelecter | - | 0 | Input Mode |
| SubInputCircle | RadioSelecter | - | 0 | Input Mode |
| SubInputPoint | RadioSelecter | - | 0 | Input Mode |
| SelectWay | RadioSelecter3 | - | 0 | Choose Mode |
| SubInputLine | RadioSelecter3 | - | 0 | Input Mode |
| Box | ButtonSelecter | - | - | Box |
| BoxAngle | ButtonSelecter | - | - | BoxAngle |
| BoxCenterX | ButtonSelecter | - | - | BoxCenterX |
| BoxCenterY | ButtonSelecter | - | - | BoxCenterY |
| BoxHeight | ButtonSelecter | - | - | BoxHeight |
| BoxWidth | ButtonSelecter | - | - | BoxWidth |
| CenterPointX | ButtonSelecter | - | - | Circle Center X |
| CenterPointY | ButtonSelecter | - | - | Circle Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| CorrectInfo | ButtonSelecter | - | - | Fixture Info |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| InitAngle | ButtonSelecter | - | - | InitAngle |
| InitPoint | ButtonSelecter | - | - | Fixtured Point |
| InitPointBaseX | ButtonSelecter | - | - | InitPointX |
| InitPointBaseY | ButtonSelecter | - | - | InitPointY |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | Point |
| OriginPointX | ButtonSelecter | - | - | PointX |
| OriginPointY | ButtonSelecter | - | - | pointy |
| Radius | ButtonSelecter | - | - | radius |
| RunAngle | ButtonSelecter | - | - | RunAngle |
| RunPoint | ButtonSelecter | - | - | Unfixtured Point |
| RunPointBaseX | ButtonSelecter | - | - | RunPointX |
| RunPointBaseY | ButtonSelecter | - | - | RunPointY |
| RunScaleX | ButtonSelecter | - | - | RunScaleX |
| RunScaleY | ButtonSelecter | - | - | RunScaleY |
| ScaleX | ButtonSelecter | - | - | InitScaleX |
| ScaleY | ButtonSelecter | - | - | InitScaleY |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSL2CMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperNum1 | Integer | - | 0x6 | RunParam_Caliper Number1 |
| CCDCircleThresh2 | Integer | - | 0xa | RunParam_Locating Sensitivity2 |
| CCDSampleScale2 | Integer | - | 0x8 | RunParam_Subsampling Coefficient2 |
| EdgeThresh2 | Integer | - | 0xf | RunParam_Contrast Threshold2 |
| EdgeThreshold1 | Integer | - | 5 | RunParam_Contrast Threshold1 |
| EdgeWidth2 | Integer | - | 0x1 | RunParam_EdgeWidth2 |
| KernelSize1 | Integer | - | 1 | RunParam_Filter Size1 |
| ProLength2 | Integer | - | 0x5 | RunParam_Projection Width2 |
| RadNum2 | Integer | - | 0x1e | RunParam_Caliper Number2 |
| RegionWidth1 | Integer | - | 0x5 | RunParam_Projection Width1 |
| RejectDist1 | Integer | - | 5 | RunParam_Distance to remove1 |
| RejectDist2 | Integer | - | 5 | RunParam_Distance to remove2 |
| RejectNum1 | Integer | - | 0x0 | RunParam_Number of Points to remove1 |
| RejectNum2 | Integer | - | 0 | RunParam_Number of Points to remove2 |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| CoarseDetectFlag2 | Boolean | 0 | False | RunParam_Init Locating2 |
| DistLimitEnable | Boolean | 0 | False | Distance Check |
| Inter1XLimitEnable | Boolean | 0 | False | Intersection 1X Check |
| Inter1YLimitEnable | Boolean | 0 | False | Intersection 1Y Check |
| Inter2XLimitEnable | Boolean | 0 | False | Intersection 2X Check |
| Inter2YLimitEnable | Boolean | 0 | False | Intersection 2Y Check |
| ProjXLimitEnable | Boolean | 0 | False | Foot Point X Check |
| ProjYLimitEnable | Boolean | 0 | False | Foot Point Y Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |
| InputWay2 | RadioSelecter | - | 0 | Input Mode |
| SourceSelect | RadioSelecter | - | 1 | Source_selection |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| Angle | ButtonSelecter | - | - | Angle |
| AngleExtend | ButtonSelecter | - | - | AngleRange |
| CenterPointX | ButtonSelecter | - | - | Circle Center X |
| CenterPointY | ButtonSelecter | - | - | Circle Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| InnerRadius | ButtonSelecter | - | - | InnerRadius |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | CorCalibMatrix |
| Radius | ButtonSelecter | - | - | radius |
| StartAngle | ButtonSelecter | - | - | StartAngle |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSL2LMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperNum1 | Integer | - | 0x6 | RunParam_Caliper Number1 |
| CaliperNum2 | Integer | - | 0x6 | RunParam_Caliper Number2 |
| EdgeThreshold1 | Integer | - | 5 | RunParam_Contrast Threshold1 |
| EdgeThreshold2 | Integer | - | 5 | RunParam_Contrast Threshold2 |
| KernelSize1 | Integer | - | 1 | RunParam_Filter Size1 |
| KernelSize2 | Integer | - | 1 | RunParam_Filter Size2 |
| RegionWidth1 | Integer | - | 0x5 | RunParam_Projection Width1 |
| RegionWidth2 | Integer | - | 0x5 | RunParam_Projection Width2 |
| RejectDist1 | Integer | - | 5 | RunParam_Distance to remove1 |
| RejectDist2 | Integer | - | 5 | RunParam_Distance to remove2 |
| RejectNum1 | Integer | - | 0x0 | RunParam_Number of Points to remove1 |
| RejectNum2 | Integer | - | 0x0 | RunParam_Number of Points to remove2 |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| DirectionDistLimitEnable | Boolean | 0 | False | Direction Distance Check |
| DistLimitEnable | Boolean | 0 | False | Distance Check |
| InterXLimitEnable | Boolean | 0 | False | Intersection X Check |
| InterYLimitEnable | Boolean | 0 | False | Intersection Y Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |
| SourceSelect | RadioSelecter | - | 1 | Source_selection |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| Angle | ButtonSelecter | - | - | Angle |
| Angle2 | ButtonSelecter | - | - | Angle |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPoint2 | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointX2 | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| EndPointY2 | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| LINE2 | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | CorCalibMatrix |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPoint2 | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointX2 | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |
| StartPointY2 | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSLineAlignModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputWay | RadioSelecter3 | - | 0 | Input Mode |

### IMVSLineEdgeInspModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperWidth | Integer | - | 5 | CaliperWidth |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| LineCaliperNum | Integer | - | 20 | Caliper Number |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinDis | Integer | - | 5 | RunParam_RoughMinDis |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| StandardInput | Boolean | 0 | False | 标准输入 |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSLineEdgePairInspModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleTol | Integer | - | 50 | Angle Tolerance |
| AngleTol | Integer | - | 50 | Angle Tolerance |
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperDistTraj | Integer | - | 0x5 | Caliper Spacing |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperHeight | Integer | - | 50 | CaliperHeight |
| CaliperWidth | Integer | - | 5 | CaliperWidth |
| EdgeStrength | Integer | - | 0x19 | EdgeThreshold |
| FitRejectDist | Integer | - | 20 | Threshold to Remove |
| FitRejectNum | Integer | - | 0 | Number of Points to remove |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| IdeaWidth | Integer | - | 40 | Ideal Width |
| IdeaWidth | Integer | - | 40 | Ideal Width |
| LineCaliperNum | Integer | - | 20 | Caliper Number |
| MottleGrayThresh | Integer | - | 25 | MottleGrayThreshold |
| MottleTotalLenThresh | Integer | - | 5 | MottleTotalLenThreshold |
| RoughMinArea | Integer | - | 5 | RunParam_RoughMinArea |
| RoughMinSize | Integer | - | 5 | RunParam_RoughMinSize |
| ThreadNum | Integer | - | 1 | 线程配置 |
| TrackDistTol | Integer | - | 0 | RunParam_TrackDistTol |
| UnevenContrast | Integer | - | - | 对比度 |
| UnevenTotalLenThres | Integer | - | - | 累计不均长度阈值 |
| AreaEnable | Boolean | - | False | Defect Area Enable |
| GrayStepEnable | Boolean | - | False | 灰度突变检测 |
| InspVision | Boolean | - | False | 效率优化 |
| OnlyNGEnable | Boolean | - | True | 只输出缺陷 |
| SizeEnable | Boolean | - | False | Defect Size Enable |
| StandardInput | Boolean | 0 | False | 标准输入 |
| UnevenEnable | Boolean | - | False | 亮度不均检测 |
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPoint2 | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointX2 | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| EndPointY2 | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| LINE2 | ButtonSelecter | - | - | select Line |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPoint2 | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointX2 | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |
| StartPointY2 | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSLineFindGroupModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| EdgeStrength | Integer | - | 5 | EdgeThreshold |
| KernelSize | Integer | - | 1 | KernelSize |
| MaxIters | Integer | - | 20 | Max Iteration Times |
| NumLimitHigh | Integer | - | 10 | RunParam_Fit Points Upper Limit |
| NumLimitLow | Integer | - | 0 | Fit Points Lower Limit |
| RegionWidth | Integer | - | 0x5 | Projection Width |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0x0 | Number of Points to remove |
| RejectNum | Integer | - | 0 | Number of Points to remove |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| NumLimitEnable | Boolean | 0 | False | Fit Points Check |
| ScoreLimitEnable | Boolean | 0 | False | Fit Error Check |

### IMVSLineFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| EdgeStrength | Integer | - | 15 | EdgeThreshold |
| FitPointsLimitHigh | Integer | - | 200 | Fit Error Upper Limit |
| FitPointsLimitLow | Integer | - | 2 | Fit Points Lower Limit |
| KernelSize | Integer | - | 2 | KernelSize |
| RegionWidth | Integer | - | 0x5 | Projection Width |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0x0 | Number of Points to remove |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| AngleNormalization | Boolean | 0 | False | AngleNormalization |
| FitPointsLimitEnable | Boolean | 0 | False | Fit Points Check |
| LineAngleEnable | Boolean | 0 | False | LineAngleEnable |
| MedianVerticalLineEnable | Boolean | 0 | True | RunParam_MedianVerticalLineEnable |
| ParallelLinesEnable | Boolean | 0 | True | RunParam_ParallelLinesEnable |
| RevertFindOrient | Boolean | 0 | False | RevertFindOrient |
| ScoreLimitEnable | Boolean | - | False | Fit Error Check |

### IMVSLineFitModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| MaxIters | Integer | - | 20 | Max Iteration Times |
| NumLimitHigh | Integer | - | 10 | RunParam_Fit Points Upper Limit |
| NumLimitLow | Integer | - | 0 | Fit Points Lower Limit |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0 | Number of Points to remove |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| LineAngleEnable | Boolean | 0 | False | LineAngleEnable |
| NumLimitEnable | Boolean | 0 | False | Fit Points Check |
| ScoreLimitEnable | Boolean | 0 | False | Fit Error Check |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| FittingPoints | ButtonSelecter | - | - | Point |
| FittingPointsX | ButtonSelecter | - | - | PointX |
| FittingPointsY | ButtonSelecter | - | - | pointy |
| LinePointNum | ButtonSelecter | - | - | Fit Point |

### IMVSMachineLearningClassifierModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| SvmEsp | Integer | - | 0x3E8 | RunParam_SvmEsp |
| SvmMaxIter | Integer | - | 0x3E8 | RunParam_SvmMaxIter |
| EdgeFeature | Boolean | 1204 | - | RunParam_EdgeFeature |
| GlcmFeature | Boolean | 1203 | - | RunParam_GlcmFeature |
| GrayAnisotropyFeature | Boolean | 1305 | - | RunParam_GrayAnisotropyFeature |
| GrayDeviationFeature | Boolean | 1303 | - | RunParam_GrayDeviationFeature |
| GrayEntropyFeature | Boolean | 1304 | - | RunParam_GrayEntropyFeature |
| GrayFeature | Boolean | 1102 | - | RunParam_GrayFeature |
| GrayHis | Boolean | 1308 | - | RunParam_GrayHis |
| GrayMeanFeature | Boolean | 1302 | - | RunParam_GrayMeanFeature |
| GrayProjHorFeature | Boolean | 1306 | - | RunParam_GrayProjHorFeature |
| GrayProjVertFeature | Boolean | 1307 | - | RunParam_GrayProjVertFeature |
| GrayRangeFeature | Boolean | 1301 | - | RunParam_GrayRangeFeature |
| HogFeature | Boolean | 1201 | - | RunParam_HogFeature |
| LabelNameLimitEnable | Boolean | 0 | False | LabelName Check |
| LbpFeature | Boolean | 1202 | - | RunParam_LbpFeature |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| PolarFeature | Boolean | 1205 | - | RunParam_PolarFeature |
| SaveModelDataEnable | Boolean | 0 | False | RunParam_SaveModelDataEnable |
| TextureFeature | Boolean | 1101 | - | RunParam_TextureFeature |
| LabelNameLimit | String | - | - | LabelName |

### IMVSMapCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| GrayContrast | Integer | - | 15 | RunParam_Grayscale Contrast |
| GrayContrast2 | Integer | - | 15 | RunParam_Grayscale Contrast |
| SubPixelWindowSize | Integer | - | 7 | 设置窗口大小 |
| SubPixelWindowSize2 | Integer | - | 7 | 设置窗口大小 |
| WeightFactor | Integer | - | 20 | RunParam_Weighting Coefficient |
| RefreshFileEnable | Boolean | - | False | RefreshFileEnable |
| TeachEnable | Boolean | - | False | TeachEnable |
| CalibPointInput | RadioSelecter | - | 0 | Physical Input |
| PhyPoint | ButtonSelecter | - | - | WorldPointLst |
| PhyPointX | ButtonSelecter | - | - | Physical Coordinate X |
| PhyPointY | ButtonSelecter | - | - | Physical Coordinate Y |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| TeachFlagInput | ButtonSelecter | - | - | TriggerString |
| Trigger | ButtonSelecter | - | - | InputString |
| WorldRotateAngle | ButtonSelecter | - | - | RunParam_WorldRotateAngle |
| TeachFlag | String | - | - | External Triggered Character |

### IMVSMarkFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleEnd | Integer | - | 90 | Angle End |
| AngleStart | Integer | - | -90 | Angle Start |
| MatchExtentRate | Integer | - | 0 | Extension Threshold |
| MatchThresholdHigh | Integer | - | 40 | EdgeThreshold |
| MaxMatchNum | Integer | - | 0x1 | RunParam_Max Number to find |
| MaxOverlap | Integer | - | 0x32 | Overlap Threshold |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| TimeOut | Integer | - | 0x0 | RunParam_Overtime Control |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| BoxPointXLimitEnable | Boolean | 0 | False | Central Point X Check |
| BoxPointYLimitEnable | Boolean | 0 | False | Central Point Y Check |
| MatchPointXLimitEnable | Boolean | 0 | False | Match Point X Check |
| MatchPointYLimitEnable | Boolean | 0 | False | Match Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |
| OutLineEnable | Boolean | 0 | True | RunParam_Contour Enabled |
| ScaleXLimitEnable | Boolean | 0 | False | X Scale Check |
| ScaleYLimitEnable | Boolean | 0 | False | Y Scale Check |
| ScoreLimitEnable | Boolean | 0 | False | Score Check |
| SpotterFlag | Boolean | 0 | False | Mottle Considered |

### IMVSMarkInspModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AreaThresh | Integer | - | 12 | Area Threshold |
| BlockNumX | Integer | - | 1 | Blocks in Height |
| BlockNumY | Integer | - | 1 | Blocks in Width |
| CorreScore | Integer | - | 90 | Correlation Score Threshold |
| ExactThreshold | Integer | - | 30 | EdgeThreshold |
| ExactThreshold | Integer | - | 30 | EdgeThreshold |
| GrayThresh | Integer | - | 128 | Char Sgt Threshold |
| HeightIncVal | Integer | - | 5 | Height Distance |
| MarkAreaMin | Integer | - | 5 | Char Sgt Area |
| MarkHeighthMax | Integer | - | 150 | Character Max Height |
| MarkHeighthMin | Integer | - | 15 | Character Min Height |
| MarkWidthMax | Integer | - | 100 | Character Max Width |
| MarkWidthMin | Integer | - | 10 | Character Min Width |
| MatchAngleEnd | Integer | - | 180 | Angle End |
| MatchAngleEnd | Integer | - | 180 | Angle End |
| MatchAngleStart | Integer | - | -180 | Angle Start |
| MatchAngleStart | Integer | - | -180 | Angle Start |
| MatchMarkAngleEnd | Integer | - | 10 | Angle End |
| MatchMarkAngleEnd | Integer | - | 10 | Angle End |
| MatchMarkAngleStart | Integer | - | -10 | Angle Start |
| MatchMarkAngleStart | Integer | - | -10 | Angle Start |
| MatchThreshold | Integer | - | 0 | EdgeThreshold |
| MatchToleranceX | Integer | - | 10 | Width Tolerance |
| MatchToleranceX | Integer | - | 10 | Width Tolerance |
| MatchToleranceY | Integer | - | 10 | Height Tolerance |
| ModelThreshold | Integer | - | 0x0 | Model Low Threshold |
| ToleranceValue | Integer | - | 2 | Tolerance Value |
| WidthIncVal | Integer | - | 5 | Width Distance |
| BinaryImageShow | Boolean | 0 | False | Display Binary Pic |
| MarkMergeFlag | Boolean | 0 | False | Mark Is Merge |
| MatchCorrectFlag | Boolean | 0 | False | Match Correct Flag |
| MatchMarkRoughFlag | Boolean | 0 | False | Roughness Enable |
| MatchRoughFlag | Boolean | 0 | False | Roughness Enable |
| ToleranceFlag | Boolean | 0 | False | Tolerance Flag |

### IMVSMarkInspModuVA

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BinarizeWinSize | Integer | - | 0xF | Binarize Win Size |
| BlobMinArea | Integer | - | 0xC | Area Threshold |
| BrightThreshold | Integer | - | 0x14 | Bright Threshold |
| DarkThreshold | Integer | - | 0x14 | Dark Threshold |
| EdgeThreshold | Integer | - | 20 | Model Low Threshold |
| EdgeTolerance | Integer | - | 0x0 | Edge Tolerance |
| ExactMatchAngleEnd | Integer | - | 180 | Angle End |
| ExactMatchAngleEnd | Integer | - | 180 | Angle End |
| ExactMatchAngleStart | Integer | - | -180 | Angle Start |
| ExactMatchAngleStart | Integer | - | -180 | Angle Start |
| ExactMatchMatchThresholdHigh | Integer | - | 30 | EdgeThreshold |
| ExactMatchMatchThresholdHigh | Integer | - | 30 | EdgeThreshold |
| HardThreshold | Integer | - | 0x80 | Binarize Threshold |
| MinCharArea | Integer | - | 0xA | Min Char Area |
| MinCharWidth | Integer | - | 0xA | Min Char Width |
| RoughMatchAngleEnd | Integer | - | 180 | Angle End |
| RoughMatchAngleEnd | Integer | - | 180 | Angle End |
| RoughMatchAngleStart | Integer | - | -180 | Angle Start |
| RoughMatchAngleStart | Integer | - | -180 | Angle Start |
| RoughMatchMatchThresholdHigh | Integer | - | 40 | EdgeThreshold |
| BinaryImageShow | Boolean | 0 | False | Display Binary Pic |
| ExactMatchCorrectFlag | Boolean | 0 | True | Match Correct Flag |
| ExactMatchCorrectFlag | Boolean | 0 | True | Match Correct Flag |
| RunAngle | ButtonSelecter | - | - | RunAngle |
| RunPointX | ButtonSelecter | - | - | RunPointX |
| RunPointY | ButtonSelecter | - | - | RunPointY |
| RunScaleX | ButtonSelecter | - | - | RunScaleX |
| RunScaleY | ButtonSelecter | - | - | RunScaleY |

### IMVSMaskGenerationModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputImgFillInRoi | Boolean | 0 | False | InputImgFillInRoi |
| UseInputImgAsMask | Boolean | 0 | False | UseInputImgAsMask |
| OriginPoint | ButtonSelecter | - | - | 多边形点订阅 |

### IMVSMatrixCircleFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CCDCircleThresh | Integer | - | 0xa | RunParam_Locating Sensitivity |
| CCDSampleScale | Integer | - | 0x8 | Subsampling Coefficient |
| EdgeThresh | Integer | - | 0xf | EdgeThreshold |
| EdgeWidth | Integer | - | 0x2 | KernelSize |
| FitPointsLimitHigh | Integer | - | 200 | Fit Error Upper Limit |
| FitPointsLimitLow | Integer | - | 3 | Fit Points Lower Limit |
| OutputCircleNumLimitHigh | Integer | - | 25 | Find Circle Num Upper Limit |
| OutputCircleNumLimitLow | Integer | - | 1 | Find Circle Num Lower Limit |
| ProLength | Integer | - | 0x5 | Projection Width |
| RadNum | Integer | - | 0x1e | Caliper Number |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0 | Number of Points to remove |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| CoarseDetectFlag | Boolean | 0 | False | Init Locating |
| FitErrorLimitEnable | Boolean | 0 | False | Fit Error Check |
| FitPointsLimitEnable | Boolean | 0 | False | Fit Points Check |
| OutputCircleNumEnable | Boolean | 0 | False | Find Circle Num Check |
| OutputCoutourPoint | Boolean | - | False | RunParam_OutputCoutourPoint |
| RadiusLimitEnable | Boolean | 0 | False | Radius Check |

### IMVSMedianLineFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputWay | RadioSelecter3 | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| Angle | ButtonSelecter | - | - | Angle |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPoint2 | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointX2 | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| EndPointY2 | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| LINE2 | ButtonSelecter | - | - | select Line |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPoint2 | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointX2 | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |
| StartPointY2 | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSMultiImageFusionModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Brightness | Integer | - | 128 | BackBrightness |
| ContrastCoef | Integer | - | 100 | ContrastCoef |
| DirEnhanceLevel | Integer | - | 1 | DirEnhanceLevel |
| HalationRemoveLevel | Integer | - | 0 | HalationRemoveLevel |
| KernelSize | Integer | - | 0x2 | KernelSize |
| EnhanceEnable | Boolean | 0 | False | EnhanceEnable |

### IMVSMultiLabelFilterModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ClassIndexs | ButtonSelecter | - | - | ClassIndex |
| ClassNums | ButtonSelecter | - | - | ClassNum |

### IMVSMultiLineFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| EdgeAngleTolerance | Integer | 0 | 15 | RunParam_Edge Angle Tolerance |
| EdgeDistTolerance | Integer | 0 | 1 | RunParam_Edge Dist Tolerance |
| EdgePointsNumLimitHigh | Integer | - | 200 | Edge Points Num Higher Limit |
| EdgePointsNumLimitLow | Integer | - | 2 | Edge Points Num Lower Limit |
| EdgesNumMax | Integer | - | 5000 | RunParam_Edge Num Max |
| EdgeThreshold | Integer | 0 | 5 | RunParam_AbsContrast Threshold |
| GradientFieldSize | Integer | 0 | 2 | RunParam_Gradient Field Size |
| LineCoverage | Integer | 0 | 50 | RunParam_Line Coverage |
| LineMaxNum | Integer | 0 | 2 | RunParam_Line Max Num |
| LineNumLimitHigh | Integer | - | 200 | Line Num Higher Limit |
| LineNumLimitLow | Integer | - | 1 | Line Num Lower Limit |
| LineRotationTolerance | Integer | 0 | 10 | RunParam_Line Rotation Tolerance |
| NormalContrast | Integer | 0 | 0 | RunParam_RelContrast Threshold |
| ProjectionLength | Integer | 0 | 10 | Projection Length |
| EdgePointsNumLimitEnable | Boolean | 0 | False | Edge Points Num Check |
| LineNumLimitEnable | Boolean | 0 | False | Line Num Check |

### IMVSMultiPointAlignModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputWay | RadioSelecter | - | 0 | Input Mode |

### IMVSNImageCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CalibPointTotalNum | Integer | - | 9 | TransNum |
| ChangeDirectionMoveTime | Integer | - | 3 | RunParam_Commutation Number |
| GrayContrast | Integer | - | 15 | RunParam_Grayscale Contrast |
| RotPointTotalNum | Integer | - | 3 | RotNum |
| SubPixelWindowSize | Integer | - | 7 | 设置窗口大小 |
| CareraMove | Boolean | - | False | CareraMove |
| HomoFixEnable | Boolean | 0 | False | RunParam_HomoFixEnable |
| RefreshFileEnable | Boolean | - | False | RefreshFileEnable |
| CalibPointInput | RadioSelecter | - | 0 | Calibration Points Input |
| InputMode | RadioSelecter | - | 0 | Input Mode |
| Image Point | ButtonSelecter | - | - | Image Point |
| MovePhysicalPointX | ButtonSelecter | - | - | Physical Coordinate X |
| MovePhysicalPointY | ButtonSelecter | - | - | Physical Coordinate Y |
| PhyPoint | ButtonSelecter | - | - | WorldPointLst |
| Physical Point | ButtonSelecter | - | - | WorldPointLst |
| PhysicalPointX | ButtonSelecter | - | - | Physical Coordinate X |
| PhysicalPointY | ButtonSelecter | - | - | Physical Coordinate Y |
| PicPointX | ButtonSelecter | - | - | ImagePointX |
| PicPointY | ButtonSelecter | - | - | ImagePointY |
| RotateAngle | ButtonSelecter | - | - | RotateAngle |
| Clear | Command | - | - | Btn_Clear Image |

### IMVSNPointCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CalibOrigin | Integer | - | 4 | Calibration Origin |
| CalibPointTotalNum | Integer | - | 9 | TransNum |
| ChangeDirectionMoveTime | Integer | - | 3 | RunParam_Commutation Number |
| DistThreshold | Integer | - | 30 | Dis Thre |
| SampleRatio | Integer | - | 60 | Sampling Rate |
| WeightFactor | Integer | - | 20 | RunParam_Weighting Coefficient |
| RefreshFileEnable | Boolean | - | False | RefreshFileEnable |
| TeachEnable | Boolean | - | False | TeachEnable |
| UseRelativeCoordinates | Boolean | - | True | UseRelativeCoordinates |
| CalibPointInput | RadioSelecter | - | 0 | Calibration Points Input |
| ImageRotateAngle | ButtonSelecter | - | - | Image Angle |
| PhyPoint | ButtonSelecter | - | - | WorldPointLst |
| PhyPointX | ButtonSelecter | - | - | Physical Coordinate X |
| PhyPointY | ButtonSelecter | - | - | Physical Coordinate Y |
| PicPoint | ButtonSelecter | - | - | Image Point |
| PicPointX | ButtonSelecter | - | - | ImagePointX |
| PicPointY | ButtonSelecter | - | - | ImagePointY |
| TeachFlagInput | ButtonSelecter | - | - | TriggerString |
| Trigger | ButtonSelecter | - | - | InputString |
| WorldRotateAngle | ButtonSelecter | - | - | RunParam_WorldRotateAngle |
| TeachFlag | String | - | - | External Triggered Character |
| Clear | Command | - | - | ClearPoint |

### IMVSOcrDlModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| FontFilterNum | Integer | - | 4 | Identify Character Quantity |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| TextLineNum | Integer | - | 0x5 | RunParam_TextLineNum |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| CharBoxEnable | Boolean | 0 | False | CharBoxEnable |
| FontFilterEnable | Boolean | - | False | Character Check Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| FontFilterInfo | String | - | 0 | Character Filtration Info. |
| UserString | String | - | 0 | UDC |

### IMVSOcrDlModuC

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BatchProcessingLevel | Integer | - | 4 | BatchProcessingLevel_RunParam |
| FontFilterNum | Integer | - | 4 | Identify Character Quantity |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 0 | Number Lower Limit |
| TextLineNum | Integer | - | 0x5 | RunParam_TextLineNum |
| BatchProcessEnable | Boolean | 0 | False | Batch Process Enable |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| CharBoxEnable | Boolean | 0 | False | CharBoxEnable |
| FontFilterEnable | Boolean | - | False | Character Check Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| FontFilterInfo | String | - | 0 | Character Filtration Info. |
| UserString | String | - | 0 | UDC |

### IMVSOcrModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AcceptThreshold | Integer | - | 0x32 | Accept Threshold |
| BinaryCoef | Integer | - | 50 | Binary Ratio |
| FontFilterNum | Integer | - | 4 | Identify Character Quantity |
| MainLineDistThresh | Integer | - | 0 | Dis Thre |
| MaxCharArea | Integer | - | 50000 | Max. Fragment Size |
| MaxCharHeight | Integer | - | 128 | Character Max Height |
| MaxCharWidth | Integer | - | 128 | Character Max Width |
| MaxLengthWidthRatio | Integer | - | 150 | RunParam_Max Aspect Ratio |
| MaxStrokeWidth | Integer | - | 32 | Max Stroke Width |
| MinCharArea | Integer | - | 15 | Min. Fragment Size |
| MinCharHeight | Integer | - | 8 | Character Min Height |
| MinCharWidth | Integer | - | 4 | Character Min Width |
| MinInterCharGap | Integer | - | 2 | RunParam_Min Char Gap |
| MinInterTextGap | Integer | - | 3 | RunParam_Min Text Gap |
| MinStrokeWidth | Integer | - | 2 | Min Stroke Width |
| NumLimitHigh | Integer | - | 99999 | Number Upper Limit |
| NumLimitLow | Integer | - | 1 | Number Lower Limit |
| OrientHalfRange | Integer | - | 0 | Main Direction Range |
| SlantHalfRange | Integer | - | 0 | Tilt Range |
| BigAlphabetVerify | Boolean | 0 | False | Uppercase Set |
| FontFilterEnable | Boolean | - | False | Character Filtration Enable |
| NumLimitEnable | Boolean | 0 | False | Number Check |
| NumVerifyEnable | Boolean | 0 | False | Number Set |
| SmallAlphabetVerify | Boolean | 0 | False | Lowercase Set |
| SpecialCharVerify | Boolean | 0 | False | Special Character Set |
| UserStringVerify | Boolean | 0 | False | UDC Verification |
| VerifyEnable | Boolean | 0 | False | Character Verification |
| FontFilterInfo | String | - | - | Character Filtration Info. |
| UserString | String | - | 0 | UDC |

### IMVSP2CMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| DistCenterLimitEnable | Boolean | 0 | False | Center Distance Check |
| DistClosestLimitEnable | Boolean | 0 | False | Closest Distance Check |
| DistFarthestLimitEnable | Boolean | 0 | False | Furthest Distance Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay2 | RadioSelecter | - | 0 | Input Mode |
| AngleExtend | ButtonSelecter | - | - | AngleRange |
| CenterPointX | ButtonSelecter | - | - | Circle Center X |
| CenterPointY | ButtonSelecter | - | - | Circle Center Y |
| Circle | ButtonSelecter | - | - | Circle |
| InnerRadius | ButtonSelecter | - | - | InnerRadius |
| OriginPoint | ButtonSelecter | - | - | Point |
| OriginPoint | ButtonSelecter | - | - | CorCalibMatrix |
| OriginPointX | ButtonSelecter | - | - | PointX |
| OriginPointY | ButtonSelecter | - | - | pointy |
| Radius | ButtonSelecter | - | - | radius |
| StartAngle | ButtonSelecter | - | - | StartAngle |

### IMVSP2LMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| DirectionDistLimitEnable | Boolean | 0 | False | Direction Distance Check |
| DistMaxLimitEnable | Boolean | 0 | False | Furthest Distance Check |
| DistMinLimitEnable | Boolean | 0 | False | Closest Distance Check |
| DistPerpendLimitEnable | Boolean | 0 | False | Vertical Distance Check |
| ProjXLimitEnable | Boolean | 0 | False | Foot Point X Check |
| ProjYLimitEnable | Boolean | 0 | False | Foot Point Y Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| Angle | ButtonSelecter | - | - | Angle |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | Point |
| OriginPoint | ButtonSelecter | - | - | CorCalibMatrix |
| PointX | ButtonSelecter | - | - | PointX |
| PointY | ButtonSelecter | - | - | pointy |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSP2PMeasureModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| DistLimitEnable | Boolean | 0 | False | Distance Check |
| MidXLimitEnable | Boolean | 0 | False | Midpoint X Check |
| MidYLimitEnable | Boolean | 0 | False | Midpoint Y Check |
| ToPhysicalValueEnable | Boolean | 0 | True | ToPhysicalValueEnable |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay1 | RadioSelecter | - | 0 | Input Mode |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | EndX |
| EndPointY | ButtonSelecter | - | - | EndY |
| OriginPoint | ButtonSelecter | - | - | Startpoint |
| OriginPoint | ButtonSelecter | - | - | CorCalibMatrix |
| OriginPointX | ButtonSelecter | - | - | StartX |
| OriginPointY | ButtonSelecter | - | - | StartY |

### IMVSPairLineModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleTol | Integer | - | 1 | RunParam_Max_Angle_Diff |
| CaliperNum | Integer | - | 20 | Caliper Number |
| EdgeStrength | Integer | - | 0xf | EdgeThreshold |
| IdeaWidth | Integer | - | 0xa | RunParam_Ideal_Space |
| KernelSize | Integer | - | 0x2 | KernelSize |
| ProjectLen | Integer | - | 0x5 | Projection Width |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0x0 | Number of Points to remove |
| Angle0LimitEnable | Boolean | 0 | False | Line0Angle |
| Angle1LimitEnable | Boolean | 0 | False | Line1Angle |
| LineWidthLimitEnable | Boolean | 0 | False | RunParam_Line Pair Width |

### IMVSParallelCalculateModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| DistMaxLimitEnable | Boolean | 0 | False | Furthest Distance Check |
| DistMinLimitEnable | Boolean | 0 | False | Closest Distance Check |
| DistPerpendLimitEnable | Boolean | 0 | False | Vertical Distance Check |
| ProjXLimitEnable | Boolean | 0 | False | Foot Point X Check |
| ProjYLimitEnable | Boolean | 0 | False | Foot Point Y Check |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | Point |
| PointX | ButtonSelecter | - | - | PointX |
| PointY | ButtonSelecter | - | - | pointy |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSPeakFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ContrastTH | Integer | - | 0x1E | EdgeThreshold |
| HalfKernelSize | Integer | - | 0x1 | KernelSize |
| NumLimitHigh | Integer | - | 99999 | Quantity Upper Limit |
| NumLimitLow | Integer | - | 0 | Quantity Lower Limit |
| ScanWidth | Integer | - | 0x1 | Scan Width |
| EdgePointXLimitEnable | Boolean | 0 | False | Edge Point X Check |
| EdgePointYLimitEnable | Boolean | 0 | False | Edge Point Y Check |
| NumLimitEnable | Boolean | 0 | False | Quantity Check |

### IMVSPixelCountModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CountLimitHigh | Integer | - | 999999999 | Quantity Upper Limit |
| CountLimitLow | Integer | - | 0 | Quantity Lower Limit |
| HighThresh | Integer | - | 0xFF | High Threshold |
| LowThresh | Integer | - | 0x0 | Low Threshold |
| BinaryEnable | Boolean | 0 | False | OutImageComb |
| CountLimitEnable | Boolean | 0 | False | Quantity Check |
| RatioLimitEnable | Boolean | 0 | False | Ratio Check |

### IMVSPixelCountModuVA

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CountLimitHigh | Integer | - | 999999999 | RunParam_Quantity Upper Limit |
| CountLimitLow | Integer | - | 0 | RunParam_Quantity Lower Limit |
| CountLimitEnable | Boolean | 0 | False | Quantity Check |
| RatioLimitEnable | Boolean | 0 | False | Ratio Check |

### IMVSPolarUnwarpModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RoiSelect | RadioSelecter | - | 0 | ROI Creation |
| ROIAngleRang | ButtonSelecter | - | - | AngleRange |
| ROIBeginAngle | ButtonSelecter | - | - | Angle Start |
| ROICenterX | ButtonSelecter | - | - | Circular Annulus Center X |
| ROICenterY | ButtonSelecter | - | - | Circular Annulus Center Y |
| ROIInnerRadius | ButtonSelecter | - | - | InnerRadius |
| ROIOutsideRadius | ButtonSelecter | - | - | OuterRadius |

### IMVSQuadrangleFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperNum0 | Integer | - | 20 | RunParam_Caliper Number1 |
| CaliperNum1 | Integer | - | 20 | RunParam_Caliper Number2 |
| CaliperNum2 | Integer | - | 20 | RunParam_Caliper Number3 |
| CaliperNum3 | Integer | - | 20 | RunParam_Caliper Number4 |
| EdgeThreshold0 | Integer | - | 15 | RunParam_Contrast Threshold1 |
| EdgeThreshold1 | Integer | - | 15 | RunParam_Contrast Threshold2 |
| EdgeThreshold2 | Integer | - | 15 | RunParam_Contrast Threshold3 |
| EdgeThreshold3 | Integer | - | 15 | RunParam_Contrast Threshold4 |
| KernelSize0 | Integer | - | 2 | RunParam_Filter Size1 |
| KernelSize1 | Integer | - | 2 | RunParam_Filter Size2 |
| KernelSize2 | Integer | - | 2 | RunParam_Filter Kernel Half-Width3 |
| KernelSize3 | Integer | - | 2 | RunParam_Filter Kernel Half-Width4 |
| RegionWidth0 | Integer | - | 0x5 | RunParam_Projection Width1 |
| RegionWidth1 | Integer | - | 0x5 | RunParam_Projection Width2 |
| RegionWidth2 | Integer | - | 0x5 | RunParam_Projection Width3 |
| RegionWidth3 | Integer | - | 0x5 | RunParam_Projection Width4 |
| RejectDist0 | Integer | - | 5 | RunParam_Distance to remove1 |
| RejectDist1 | Integer | - | 5 | RunParam_Distance to remove2 |
| RejectDist2 | Integer | - | 5 | RunParam_Distance to remove3 |
| RejectDist3 | Integer | - | 5 | RunParam_Distance to remove4 |
| RejectNum0 | Integer | - | 0x0 | RunParam_Number of Points to remove1 |
| RejectNum1 | Integer | - | 0x0 | RunParam_Number of Points to remove2 |
| RejectNum2 | Integer | - | 0x0 | RunParam_Number of Points to remove3 |
| RejectNum3 | Integer | - | 0x0 | RunParam_Number of Points to remove4 |
| AngleLimitFirstEnable | Boolean | 0 | False | Line 1 Angle Check |
| AngleLimitFourthEnable | Boolean | 0 | False | Line 4 Angle Check |
| AngleLimitSecondEnable | Boolean | 0 | False | Line 2 Angle Check |
| AngleLimitThirdEnable | Boolean | 0 | False | Line 3 Angle Check |
| CentralPointXLimitEnable | Boolean | 0 | False | Central Point X Check |
| CentralPointYLimitEnable | Boolean | 0 | False | Central Point Y Check |
| InheritWay | RadioSelecter | - | 0 | Inheritance Mode |
| Region0 | ButtonSelecter | - | - | RunParam_Region1 |
| Region1 | ButtonSelecter | - | - | RunParam_Region2 |
| Region2 | ButtonSelecter | - | - | RunParam_Region3 |
| Region3 | ButtonSelecter | - | - | RunParam_Region4 |
| ROI1Angle | ButtonSelecter | - | - | Roi1Angle |
| ROI1CenterX | ButtonSelecter | - | - | Roi1CenterX |
| ROI1CenterY | ButtonSelecter | - | - | Roi1CenterY |
| ROI1Height | ButtonSelecter | - | - | Roi1Height |
| ROI1Width | ButtonSelecter | - | - | Roi1Width |
| ROI2Angle | ButtonSelecter | - | - | Roi2Angle |
| ROI2CenterX | ButtonSelecter | - | - | Roi2CenterX |
| ROI2CenterY | ButtonSelecter | - | - | Roi2CenterY |
| ROI2Height | ButtonSelecter | - | - | Roi2Height |
| ROI2Width | ButtonSelecter | - | - | Roi2Width |
| ROI3Angle | ButtonSelecter | - | - | ROI3 Angle |
| ROI3CenterX | ButtonSelecter | - | - | ROI3 Center Point X |
| ROI3CenterY | ButtonSelecter | - | - | ROI3 Center Point Y |
| ROI3Height | ButtonSelecter | - | - | ROI3 Height |
| ROI3Width | ButtonSelecter | - | - | ROI3 Width |
| ROIAngle | ButtonSelecter | - | - | ROI0 Angle |
| ROICenterX | ButtonSelecter | - | - | ROI0 Center Point X |
| ROICenterY | ButtonSelecter | - | - | ROI0 Center Point Y |
| ROIHeight | ButtonSelecter | - | - | ROI0 Height |
| ROIWidth | ButtonSelecter | - | - | ROI0 Width |

### IMVSRectFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CaliperNum | Integer | - | 30 | Caliper Number |
| EdgeStrength | Integer | - | 0x5 | EdgeThreshold |
| IdeaHeight | Integer | - | 0xa | Ideal Height |
| IdeaWidth | Integer | - | 0xa | Ideal Width |
| KernelSize | Integer | - | 0x1 | KernelSize |
| ProjectLen | Integer | - | 0x5 | Projection Width |
| RejectDist | Integer | - | 5 | Distance to remove |
| RejectNum | Integer | - | 0x0 | Number of Points to remove |
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| CenterXLimitEnable | Boolean | 0 | False | Center X Check |
| CenterYLimitEnable | Boolean | 0 | False | Center Y Check |
| RectHeightLimitEnable | Boolean | 0 | False | RunParam_Height Check |
| RectWidthLimitEnable | Boolean | 0 | False | Width Check |

### IMVSRegionCopyModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ExtFillVal | Integer | - | 255 | Lang_FillValueOutside |
| FillVal | Integer | - | 255 | Lang_FillValueInside |

### IMVSRotateCalculateModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputType | RadioSelecter | - | 0 | LabelValueType |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | Point |
| PointX | ButtonSelecter | - | - | PointX |
| PointY | ButtonSelecter | - | - | pointy |
| RotateAngle | ButtonSelecter | - | - | RotateAngle |
| RotateCenter | ButtonSelecter | - | - | Point |
| RotatePointX | ButtonSelecter | - | - | PointX |
| RotatePointY | ButtonSelecter | - | - | pointy |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSScaleTransformModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CorrectInfo | ButtonSelecter | - | - | PixelEquivalent_Correct Info |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| TransferParam | ButtonSelecter | - | - | ImageDist |

### IMVSShadeCorrectModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Gain | Integer | - | 0x0 | Tab_Gain |
| Noise | Integer | - | 0x0 | Noise |
| Offset | Integer | - | 0x80 | RunParam_Compensation |
| Ratio | Integer | - | 0x1 | KernelSize |

### IMVSSinglePointAlignModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputWay | RadioSelecter | - | 0 | Input Mode |

### IMVSStringLocationModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| EdgeStrength | Integer | - | 15 | RunParam_EdgeStrength |
| IdeaWidthFront | Integer | - | 250 | RunParam_IdeaWidthFront |

### IMVSSurfaceDefectFilterModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| dist | Integer | - | - | Dist |
| kerHeight | Integer | - | - | Filter Kernel Height |
| kerNum | Integer | - | - | RunParam_KerNum |
| kerWidth | Integer | - | - | Filter Kernel Width |
| lambd | Integer | - | - | 波长 |
| method | Integer | - | - | RunParam_Method |
| offset | Integer | - | - | RunParam_Offset |
| respondThre | Integer | - | - | RunParam_RespondThre |
| sigma | Integer | - | - | LumStd |
| step | Integer | - | - | RunParam_Step |
| threH | Integer | - | - | RunParam_ThreH |
| threV | Integer | - | - | RunParam_ThreV |
| window | Integer | - | - | 设置窗口大小 |

### IMVSTargetTrackModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CountNumLimitHigh | Integer | - | 99999 | RunParam_Count Num Upper Limit |
| CountNumLimitLow | Integer | - | 0 | RunParam_Count Num Lower Limit |
| FrameNum | Integer | - | 0 | RunParam_Lose Frame |
| MaxProcNum | Integer | - | 200 | RunParam_Max ProcNum |
| ObjNumLimitHigh | Integer | - | 99999 | RunParam_Obj Num Upper Limit |
| ObjNumLimitLow | Integer | - | 0 | RunParam_Obj Num Lower Limit |
| SingleCountLimitHigh | Integer | - | 99999 | RunParam_Single Count Upper Limit |
| SingleCountLimitLow | Integer | - | 0 | RunParam_Single Count Lower Limit |
| TrackOverlap | Integer | - | 30 | track overlap |
| CountNumLimitEnable | Boolean | 0 | False | Count Num Check |
| ObjNumLimitEnable | Boolean | 0 | False | Obj Num Check |
| SingleCountLimitEnable | Boolean | 0 | False | Single Count Check |
| InputBoxSelecter | ButtonSelecter | - | - | Input Box |

### IMVSVerticalLineFindModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AngleLimitEnable | Boolean | 0 | False | Angle Check |
| DistMaxLimitEnable | Boolean | 0 | False | Furthest Distance Check |
| DistMinLimitEnable | Boolean | 0 | False | Closest Distance Check |
| DistPerpendLimitEnable | Boolean | 0 | False | Vertical Distance Check |
| ProjXLimitEnable | Boolean | 0 | False | Foot Point X Check |
| ProjYLimitEnable | Boolean | 0 | False | Foot Point Y Check |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| Type | RadioSelecter | - | 0 | TypeSelect |
| InputWay2 | RadioSelecter3 | - | 0 | Input Mode |
| EndPoint | ButtonSelecter | - | - | Endpoint |
| EndPointX | ButtonSelecter | - | - | Endpoint X Coordinate |
| EndPointY | ButtonSelecter | - | - | Endpoint Y Coordinate |
| LINE | ButtonSelecter | - | - | select Line |
| OriginPoint | ButtonSelecter | - | - | Point |
| PointX | ButtonSelecter | - | - | PointX |
| PointY | ButtonSelecter | - | - | pointy |
| StartPoint | ButtonSelecter | - | - | Startpoint |
| StartPointX | ButtonSelecter | - | - | Startpoint X Coordinate |
| StartPointY | ButtonSelecter | - | - | Startpoint Y Coordinate |

### IMVSWinBinaryComDefectDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BlobAreaLimitHigh | Integer | - | 999999999 | Blob Area Upper Limit |
| BlobAreaLimitLow | Integer | - | 10 | Blob Area Lower Limit |
| BlobLongAxisLimitHigh | Integer | - | 999999999 | Blob LongAxis Upper Limit |
| BlobLongAxisLimitLow | Integer | - | 10 | Blob LongAxis Lower Limit |
| BlobPerimeterLimitHigh | Integer | - | 999999999 | Blob Perimeter Upper Limit |
| BlobPerimeterLimitLow | Integer | - | 10 | Blob Perimeter Lower Limit |
| BlobRectRectHeightHigh | Integer | - | 200 | Blob RectHeight Upper Limit |
| BlobRectRectHeightLow | Integer | - | 100 | Blob RectHeight Lower Limit |
| BlobRectWidthLimitHigh | Integer | - | 200 | Blob RectWidth Upper Limit |
| BlobRectWidthLimitLow | Integer | - | 100 | Blob RectWidth Lower Limit |
| BlobShortAxisLimitHigh | Integer | - | 999999999 | Blob ShortAxis Upper Limit |
| BlobShortAxisLimitLow | Integer | - | 1 | Blob ShortAxis Lower Limit |
| ContrastThreshhold | Integer | - | 15 | RunParam_ContrastThreshhold |
| MaxFindNum | Integer | - | 100 | RunParam_MaxFindNum |
| MinHoleArea | Integer | - | 0 | RunParam_MinHoleArea |
| SampleRate | Integer | - | 100 | RunParam_SampleRate |
| WindowsHeight | Integer | - | 7 | RunParam_WindowsHeight |
| WindowsWidth | Integer | - | 7 | RunParam_WindowsWidth |
| BinaryImageEnable | Boolean | 0 | False | RunParam_BinaryImageEnable |
| BlobAreaLimitEnable | Boolean | 0 | True | Blob Area Check |
| BlobAxisRatioLimitEnable | Boolean | 0 | False | Blob AxisRatio Check |
| BlobBoxAngleLimitEnable | Boolean | 0 | False | Blob BoxAngle Check |
| BlobCentroidBiasLimitEnable | Boolean | 0 | False | Blob CentroidBias Check |
| BlobCircularityLimitEnable | Boolean | 0 | False | Blob Circularity Check |
| BlobLongAxisLimitEnable | Boolean | 0 | False | Blob LongAxis Check |
| BlobPerimeterLimitEnable | Boolean | 0 | False | Blob Perimeter Check |
| BlobRectangularityLimitEnable | Boolean | 0 | False | Blob Rectangularity Check |
| BlobRectHeightLimitEnable | Boolean | 0 | False | Blob RectHeight Check |
| BlobRectWidthLimitEnable | Boolean | 0 | False | Blob RectWidth Check |
| BlobShortAxisLimitEnable | Boolean | 0 | False | Blob ShortAxis Check |
| EnableContourInfoFlag | Boolean | 0 | True | RunParam_EnableContourInfoFlag |
| EnableGrayInfoFlag | Boolean | 0 | True | RunParam_EnableGrayInfoFlag |
| EnableHistInfo | Boolean | 0 | True | RunParam_EnableHistInfo |
| GrayImageEnable | Boolean | 0 | False | RunParam_GrayImageEnable |
| InputMaskEnable | Boolean | 0 | False | Input Mask Enable |
| UseFirstROIRunParamEnable | Boolean | 0 | True | RunParam_UnifiedParameters |
| RoiSelect | RadioSelecter | - | 0 | ROI Creation |
| InheritWay | RadioSelecter3 | - | 0 | Inheritance Mode |
| Region | ButtonSelecter | - | - | Region |
| ROIAngle | ButtonSelecter | - | - | roiangle |
| ROICenterX | ButtonSelecter | - | - | roicenterx |
| ROICenterY | ButtonSelecter | - | - | roicentery |
| ROIHeight | ButtonSelecter | - | - | roiheight |
| ROIWidth | ButtonSelecter | - | - | roiwidth |

### IfBranchModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RangeConFFields | ButtonSelecter_IfBranch | - | - | Data Set Field List |

### IfModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| IgnoreSubErrorEnable | Boolean | 0 | False | IgnoreSubErrorEnable |
| RangeConFFields | ButtonSelecter_RangeConF | - | - | Data Set Field List |

### ImageAcquisitionModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ImageCount | Integer | 0 | 4 | Image Count |
| Interval | Integer | 0 | 0 | RunParam_Acquisition Rate |
| SolSaveImageData | Boolean | 0 | False | RunParam_Save Image |

### ImageBufferModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| BufferCount | ButtonSelecter | - | - | RunParam_BufferCount |
| CacheEnable | ButtonSelecter | - | - | CacheEnable |

### ImageCollectDalsaModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ImageCacheNum | Integer | 0 | 100 | 缓存张数 |
| OpenCamera | Boolean | 0 | False | Tab_Camera Connect |
| OutMono8 | Boolean | 0 | False | RunParam_OutMono8 |

### ImageCollectIKModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| OpenCamera | Boolean | 0 | False | Tab_Camera Connect |
| OutMono8 | Boolean | 0 | False | RunParam_OutMono8 |

### ImageCollectINSCISModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| OpenCamera | Boolean | 0 | False | Tab_Camera Connect |
| OutMono8 | Boolean | 0 | False | RunParam_OutMono8 |

### ImageCollectLambervModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SoftTriggerWaitTime | Integer | 0 | 2 | RunParam_SoftTriggerWaitTime |

### ImageCollectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CameraType | String | - | - | - |

### ImageSourceModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InitialSN | Integer | 0 | 1 | RunParam_SNCode |
| Interval | Integer | 0 | 0 | RunParam_Acquisition Rate |
| LightBrightness | Integer | 0 | 0 | RunParam_Light Brightness |
| LightChannel | Integer | 0 | 1 | RunParam_Light Channel |
| LightTriggerTime | Integer | 0 | 500 | RunParam_Trigger Time |
| PathCache | Integer | 0 | 0 | RunParam_PathCache |
| StitchHeight | Integer | 0 | 2000 | RunParam_StitchHeight |
| StitchStartHeight | Integer | 0 | 0 | RunParam_StitchStartHeight |
| AutoPlay | Boolean | 0 | True | RunParam_Auto Switch |
| AutoStop | Boolean | 0 | True | RunParam_Auto Stop |
| ClearTrigger | Boolean | 0 | False | RunParam_ClearTrigger |
| IsSubscribeFolderMode | Boolean | - | False | Subscribe Folder Mode |
| OutMono8 | Boolean | 0 | True | RunParam_OutMono8 |
| RefreshImage | Boolean | 0 | True | RunParam_Refresh image in folder |
| ShowImageName | Boolean | 0 | True | RunParam_Show Image Name |
| StitchEnable | Boolean | 0 | True | RunParam_StitchEnable |
| TriggerProcessRun | Boolean | 0 | False | RunParam_Trigger process run |
| TriggerStringEnable | Boolean | 0 | False | 字符触发过滤 |
| UsePinFlag | Boolean | 0 | False | UsePinFlag |
| ClearTriggerCondition | ButtonSelecter | - | - | SaveTriggerName |
| ExposureTimeInput | ButtonSelecter | - | - | 控制曝光 |
| GainInput | ButtonSelecter | - | - | 控制增益 |
| TriggerFilter | ButtonSelecter | - | - | TriggerString |
| TriggerString | ButtonSelecter | - | - | InputString |
| CurrentImagePath | ButtonSelecter_ImageList | - | - | Image List |

### ImageSwitchModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| InputNum | Integer | - | 0x1 | 输入条件 |

### LightModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Channel1Brightness | Integer | 0 | 0 | Channel1Brightness |
| Channel1DurationTime | Integer | 0 | 0 | Duration(ms) |
| Channel2Brightness | Integer | 0 | 0 | Channel2Brightness |
| Channel2DurationTime | Integer | 0 | 0 | Duration(ms) |
| Channel3Brightness | Integer | 0 | 0 | Channel3Brightness |
| Channel3DurationTime | Integer | 0 | 0 | Duration(ms) |
| Channel4Brightness | Integer | 0 | 0 | Channel4Brightness |
| Channel4DurationTime | Integer | 0 | 0 | Duration(ms) |
| Channel5Brightness | Integer | 0 | 0 | Channel5Brightness |
| Channel6Brightness | Integer | 0 | 0 | Channel6Brightness |
| TriggerTime | Integer | 0 | 0 | RunParam_Trigger Time |
| Channel1Enable | Boolean | 0 | False | Channel1Enable |
| Channel2Enable | Boolean | 0 | False | Channel2Enable |
| Channel3Enable | Boolean | 0 | False | Channel3Enable |
| Channel4Enable | Boolean | 0 | False | Channel4Enable |
| Channel5Enable | Boolean | 0 | False | Channel5Enable |
| Channel6Enable | Boolean | 0 | False | Channel6Enable |
| InputType | RadioSelecter | - | 1 | RunParam_Input Type |
| Channel1BrightnessSub | ButtonSelecter | - | - | Channel1Brightness |
| Channel2BrightnessSub | ButtonSelecter | - | - | Channel2Brightness |
| Channel3BrightnessSub | ButtonSelecter | - | - | Channel3Brightness |
| Channel4BrightnessSub | ButtonSelecter | - | - | Channel4Brightness |
| Channel5BrightnessSub | ButtonSelecter | - | - | Channel5Brightness |
| Channel6BrightnessSub | ButtonSelecter | - | - | Channel6Brightness |
| InputString | ButtonSelecter | - | - | TriggerString |

### MultiCamerasImageSourceModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AcquisitionTimeout | Integer | 0 | 1 | RunParam_AcquisitionTimeout |

### MultiLightCameraModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ConditionalTriggerNumber | Integer | - | 1 | Tab_ConditionalTriggerNumber |
| ConditionalTriggerTimeOut | Integer | - | 0 | Tab_ConditionalTriggerTimeout |
| MultiLightNum | Integer | - | 1 | 拆图数 |
| AutoConnect | Boolean | 0 | False | RunParam_AutoReconnect |
| CloseCache | Boolean | 0 | False | CloseCache |

### ParamSetModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ModuleIDs | ButtonSelecter | - | - | 模块ID |
| ParamNames | ButtonSelecter | - | - | 参数名 |
| ParamNums | ButtonSelecter | - | - | 模块参数个数 |
| ParamValues | ButtonSelecter | - | - | 参数值 |

### PointSetMODU_STD

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| LoopEnabled | Boolean | 0 | False | Loop Enable |

### PolePositionJudgementModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| curAtDetecSwitchs | ButtonSelecter | - | - | AT检测开关 |
| curAtToRefers | ButtonSelecter | - | - | AT到基准 |
| curBladeToReferXs | ButtonSelecter | - | - | 压刀到基准X |
| curBladeToReferYs | ButtonSelecter | - | - | 压刀到基准Y |
| curFrontAtWidths | ButtonSelecter | - | - | 正面AT宽 |
| curPoleToReferXs | ButtonSelecter | - | - | 极片到基准X |
| curPoleToReferYs | ButtonSelecter | - | - | 极片到基准Y |
| curPoleToSepXs | ButtonSelecter | - | - | 极片到隔膜X |
| curPoleToSepYs | ButtonSelecter | - | - | 极片到隔膜Y |
| curReverseAtWidths | ButtonSelecter | - | - | 反面AT宽 |
| curSepToReferXs | ButtonSelecter | - | - | 隔膜到基准X |
| curSepToReferYs | ButtonSelecter | - | - | 隔膜到基准Y |
| Polaritys | ButtonSelecter | - | - | 极性 |
| PolePieceSNs | ButtonSelecter | - | - | 极片SN |
| poleToSepIsStandXs | ButtonSelecter | - | - | 极片到隔膜X是否赋标准值 |
| virCompSwitchs | ButtonSelecter | - | - | 虚拟补偿开关 |

### PolePositionMeasureModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CurATEnable | Integer | - | - | 当前AT使能 |
| CurPoleSN | Integer | - | - | 当前极片SN |
| DefaultMeasureValue | Integer | - | - | 测量项默认值 |
| NowPolarity | Integer | - | 0 | 当前极性 |
| WarningCountLayers | Integer | - | - | 预警片数 |
| IsAfterWarnClearData | Boolean | 0 | False | 报警后重置数据 |
| IsAvgWarningEnable | Boolean | 0 | False | 均值预警使能 |
| MeasureNums | ButtonSelecter | - | - | 测量个数 |

### PoseEstimation ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| Mark_CurRX | ButtonSelecter | - | - | Mark_CurRX |
| Mark_CurRY | ButtonSelecter | - | - | Mark_CurRY |
| Mark_CurRZ | ButtonSelecter | - | - | Mark_CurRZ |
| Mark_CurX | ButtonSelecter | - | - | Mark_CurX |
| Mark_CurY | ButtonSelecter | - | - | Mark_CurY |
| Mark_CurZ | ButtonSelecter | - | - | Mark_CurZ |
| MarkRX | ButtonSelecter | - | - | MarkRX |
| MarkRY | ButtonSelecter | - | - | MarkRY |
| MarkRZ | ButtonSelecter | - | - | MarkRZ |
| MarkX | ButtonSelecter | - | - | MarkX |
| MarkY | ButtonSelecter | - | - | MarkY |
| MarkZ | ButtonSelecter | - | - | MarkZ |
| ObjRX | ButtonSelecter | - | - | ObjRX |
| ObjRY | ButtonSelecter | - | - | ObjRY |
| ObjRZ | ButtonSelecter | - | - | ObjRZ |
| ObjX | ButtonSelecter | - | - | ObjX |
| ObjY | ButtonSelecter | - | - | ObjY |
| ObjZ | ButtonSelecter | - | - | ObjZ |

### ProMeasureModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| NowPolarity | Integer | - | 0 | 当前极性 |
| WarningCountLayers | Integer | - | 50 | 预警片数 |
| AfterWarnClearData | Boolean | 0 | False | 报警后重置数据 |
| AvgWarningEnable | Boolean | 0 | False | 均值预警使能 |
| MeasureNums | ButtonSelecter | - | - | 测量个数 |

### PyShellModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ShellContent | ButtonSelecter_PyShell | - | - | RunParam_Shell Module |

### ReadCalibFileModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SaveCalibDataEnable | Boolean | 0 | - | RunParam_SaveCalibDataEnable |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| SnapImagePointX | ButtonSelecter | - | - | X |
| SnapImagePointY | ButtonSelecter | - | - | Y |
| SnapImageR | ButtonSelecter | - | - | R |
| SnapWorldPointX | ButtonSelecter | - | - | X |
| SnapWorldPointY | ButtonSelecter | - | - | Y |
| SnapWorldR | ButtonSelecter | - | - | R |
| TeachWorldPointX | ButtonSelecter | - | - | X |
| TeachWorldPointY | ButtonSelecter | - | - | Y |
| TeachWorldR | ButtonSelecter | - | - | R |

### ReadDatasModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RowNum | Integer | - | 1 | Row Number Acquisition |
| HexReceive | Boolean | - | False | RunParam_Hex Receive |

### RectAnalysis ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| AXs | ButtonSelecter | - | - | AX |
| AYs | ButtonSelecter | - | - | AY |
| BXs | ButtonSelecter | - | - | BX |
| BYs | ButtonSelecter | - | - | BY |
| CXs | ButtonSelecter | - | - | CX |
| CYs | ButtonSelecter | - | - | CY |
| DXs | ButtonSelecter | - | - | DX |
| DYs | ButtonSelecter | - | - | DY |
| EOutputFlags | ButtonSelecter | - | - | EOutputFlag |

### RectChunk ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CurRoiAngles | ButtonSelecter | - | - | 现区域角度 |
| CurRoiCenterXs | ButtonSelecter | - | - | 现区域X坐标 |
| CurRoiCenterYs | ButtonSelecter | - | - | 现区域Y坐标 |
| CurRoiHeights | ButtonSelecter | - | - | 现区域高 |
| CurRoiWidths | ButtonSelecter | - | - | 现区域宽 |
| ObjRoiAngles | ButtonSelecter | - | - | 目标缺陷角度 |
| ObjRoiCenterXs | ButtonSelecter | - | - | 目标缺陷X坐标 |
| ObjRoiCenterYs | ButtonSelecter | - | - | 目标缺陷Y坐标 |
| ObjRoiHeights | ButtonSelecter | - | - | 目标缺陷高 |
| ObjRoiNums | ButtonSelecter | - | - | 目标缺陷数量 |
| ObjRoiWidths | ButtonSelecter | - | - | 目标缺陷宽 |

### RectifyCameraSelect ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| 辅相机Xs | ButtonSelecter | - | - | 辅相机X |
| 辅相机Ys | ButtonSelecter | - | - | 辅相机Y |
| 相机选择s | ButtonSelecter | - | - | 相机选择 |
| 主相机Xs | ButtonSelecter | - | - | 主相机X |
| 主相机Ys | ButtonSelecter | - | - | 主相机Y |

### ResultCache ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| MaxCacheNum | Integer | - | - | 最大缓存数量 |
| Results | ButtonSelecter | - | - | 结果 |
| SNs | ButtonSelecter | - | - | SN |
| StationNames | ButtonSelecter | - | - | 工位名称 |

### ResultExtraction ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ModuleIDs | ButtonSelecter | - | - | 模块ID |
| SNs | ButtonSelecter | - | - | SN |
| StationNames | ButtonSelecter | - | - | 工位名称 |

### RotateCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RevOutputFlag | Boolean | - | False | RevOutputFlag |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| ImagePoints | ButtonSelecter | - | - | Image Point |
| ImagePointXs | ButtonSelecter | - | - | ImagePointX |
| ImagePointYs | ButtonSelecter | - | - | ImagePointY |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| RotNums | ButtonSelecter | - | - | RotNum |
| WorldRotateAngles | ButtonSelecter | - | - | Physical rotation angle |

### RotateCalibModuEx ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RevOutputFlag | Boolean | - | False | RevOutputFlag |
| InputWay | RadioSelecter | - | 0 | Input Mode |
| ImagePoints | ButtonSelecter | - | - | 图像点 |
| ImagePointXs | ButtonSelecter | - | - | 图像坐标X |
| ImagePointYs | ButtonSelecter | - | - | 图像坐标Y |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| RotNums | ButtonSelecter | - | - | 旋转次数 |
| WorldRotateAngles | ButtonSelecter | - | - | 物理旋转角度 |

### SSIMDetectModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| StepLength | Integer | - | - | 滑动窗口步长 |
| DetectRect | ButtonSelecter | - | - | 建模区域 |
| RefreshSignal | ButtonSelecter | - | - | 刷新信号 |

### SaveImage

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| DiskFreespace | Integer | - | 0x200 | RunParam_DiskFreespace |
| FontSizeRate | Integer | - | 0x1 | RunParam_FontSizeRate |
| ImageCompressionRation | Integer | - | 0x5F | Compression Quality |
| ImageMemoryDay | Integer | - | 0x1E | RunParam_Max Save Day |
| LineWidthRate | Integer | - | 0x1 | RunParam_LineWidthRate |
| OriginImgCache | Integer | - | 0x0A | RunParam_OriginImgCache |
| RenderImgCache | Integer | - | 0x0A | RunParam_RenderImgCache |
| ServerPort | Integer | - | 21 | RunParam_ServerPort |
| StorageInterval | Integer | - | 0x5 | RunParam_StorageInterval |
| DebugInfoSave | Boolean | 0 | False | DebugInfoSave |
| FTPEnable | Boolean | 0 | False | RunParam_FTPEnable |
| GenerateDir | Boolean | 0 | False | RunParam_Generate Dir |
| ImageSaveTrigger | Boolean | 0 | False | Save Trigger |
| OriginImgEnable | Boolean | 0 | False | RunParam_OriginImgEnable |
| OutputEnable | Boolean | 0 | True | RunParam_OutputEnable |
| RenderImgEnable | Boolean | 0 | True | RunParam_RenderImgEnable |
| SaveImageEnable | Boolean | 0 | False | RunParam_SaveImageEnable |
| SynchronousStorage | Boolean | 0 | False | RunParam_SynchronousStorage |
| DebugInfo | ButtonSelecter | - | - | DebugInfo |
| ImageSaveTriggerCondition | ButtonSelecter | - | - | SaveTriggerName |
| PositionX | ButtonSelecter | - | - | 位置X |
| PositionY | ButtonSelecter | - | - | 位置Y |
| TextInput | ButtonSelecter | - | - | RunParam_Content |
| DisplayInfo | String | - | - | DisplayInfo |
| FTPPath | String | - | /Image | FTPPath |
| InputListInfo | String | - | - | InputListInfo |
| SetSaveStatus | String | - | - | SetSaveStatus |
| UserName | String | - | - | RunParam_UserName |

### SaveTextModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| FileCount | Integer | - | 100 | File Save Number |
| FileLen | Integer | - | 1024 | Document Size(K) |
| MaxDayCount | Integer | - | 30 | File Save Days |
| AsynSave | Boolean | 0 | False | Save Text By Asynchronous Method |
| RealTimeSave | Boolean | 0 | False | RunParam_Real-Time Save Trigger |
| SaveByDateTrigger | Boolean | 0 | False | Save By Date Trigger |
| SaveColumnNames | Boolean | 0 | True | SaveColumnNames |
| SaveTrigger | Boolean | 0 | False | Save Trigger |
| SaveTriggerCondition | ButtonSelecter | - | - | SaveTriggerName |
| TextInput | ButtonSelecter | - | - | Input Text |
| TimeStamp | String | - | yyyy/MM/dd HH:mm:ss :  | Timestamp Setting |

### SendDatasModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| EndEnable | Boolean | 0 | False | End Char |
| IgnoreDuration | Boolean | 0 | False | RunParam_IgnoreDuration |
| IgnoreErroneousDataEnable | Boolean | 0 | False | RunParam_IgnoreErroneousDataEnable |
| SplitEnable | Boolean | 0 | False | RunParam_Split Symbol |
| InputString_Comm | ButtonSelecter | - | - | SendData |

### ShellModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| ShellContent | ButtonSelecter_Shell | - | - | ShellModule |

### SinglePointGrabModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SnapPointRotateEnable | Boolean | 0 | False | RunParam_SnapPointRotateEnable |
| CalibLoadType | RadioSelecter | - | 0 | CalibLoadType |
| InputMode | RadioSelecter | - | 0 | Input Mode |
| CalibMatrix | ButtonSelecter | - | - | RunParam_CalibMatrix |
| ImagePoint | ButtonSelecter | - | - | Point |
| ImagePointA | ButtonSelecter | - | - | Angle |
| ImagePointX | ButtonSelecter | - | - | Trans Coordinate X |
| ImagePointY | ButtonSelecter | - | - | Trans Coordinate Y |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| SnapPointDeltaAngle | ButtonSelecter | - | - | RunParam_SnapPointDeltaAngle |
| TeachPoint | ButtonSelecter | - | - | Point |
| TeachPointA | ButtonSelecter | - | - | Angle |
| TeachPointX | ButtonSelecter | - | - | Trans Coordinate X |
| TeachPointY | ButtonSelecter | - | - | Trans Coordinate Y |
| TeachSnapPoint | ButtonSelecter | - | - | Point |
| TeachSnapPointA | ButtonSelecter | - | - | Angle |
| TeachSnapPointX | ButtonSelecter | - | - | Trans Coordinate X |
| TeachSnapPointY | ButtonSelecter | - | - | Trans Coordinate Y |

### SinglePointMapAlignModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| CalibLoadType | RadioSelecter | - | 0 | CalibLoadType |
| InputMode | RadioSelecter | - | 0 | Input Mode |
| MapCalibMatrix | ButtonSelecter | - | - | RunParam_MapCalibMatrix |
| NPointCalibMatrix | ButtonSelecter | - | - | RunParam_NPointCalibMatrix |
| ObjImagePoint | ButtonSelecter | - | - | Point |
| ObjImagePointA | ButtonSelecter | - | - | Angle |
| ObjImagePointX | ButtonSelecter | - | - | Trans Coordinate X |
| ObjImagePointY | ButtonSelecter | - | - | Trans Coordinate Y |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| TarImageLineE | ButtonSelecter | - | - | Point |
| TarImageLineEX | ButtonSelecter | - | - | Trans Coordinate X |
| TarImageLineEY | ButtonSelecter | - | - | Trans Coordinate Y |
| TarImageLineS | ButtonSelecter | - | - | Point |
| TarImageLineSX | ButtonSelecter | - | - | Trans Coordinate X |
| TarImageLineSY | ButtonSelecter | - | - | Trans Coordinate Y |
| TarImagePoint | ButtonSelecter | - | - | Point |
| TarImagePointX | ButtonSelecter | - | - | Trans Coordinate X |
| TarImagePointY | ButtonSelecter | - | - | Trans Coordinate Y |
| TeachPoint | ButtonSelecter | - | - | Point |
| TeachPointA | ButtonSelecter | - | - | Angle |
| TeachPointX | ButtonSelecter | - | - | Trans Coordinate X |
| TeachPointY | ButtonSelecter | - | - | Trans Coordinate Y |

### SinglePointRectifyModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SnapPointRotateEnable | Boolean | 0 | False | RunParam_SnapPointRotateEnable |
| CalibLoadType | RadioSelecter | - | 0 | CalibLoadType |
| InputMode | RadioSelecter | - | 0 | Input Mode |
| CalibMatrix | ButtonSelecter | - | - | RunParam_CalibMatrix |
| ImagePoint | ButtonSelecter | - | - | Point |
| ImagePointA | ButtonSelecter | - | - | Angle |
| ImagePointX | ButtonSelecter | - | - | Trans Coordinate X |
| ImagePointY | ButtonSelecter | - | - | Trans Coordinate Y |
| RefreshSignal | ButtonSelecter | - | - | Refresh Signal |
| SnapPointDeltaAngle | ButtonSelecter | - | - | RunParam_SnapPointDeltaAngle |
| TeachPoint | ButtonSelecter | - | - | Point |
| TeachPointA | ButtonSelecter | - | - | Angle |
| TeachPointX | ButtonSelecter | - | - | Trans Coordinate X |
| TeachPointY | ButtonSelecter | - | - | Trans Coordinate Y |

### StringCompareModule

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| TextInput | ButtonSelecter | - | - | Input Text |
| StringCompareFields | ButtonSelecter_StringComp | - | - | Data Set Field List |

### TimeDelaySetModule ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| SetTimeMin | Integer | - | 0x0 | 分 |
| SetTimeMs | Integer | - | 0x0 | 毫秒 |
| SetTimeSec | Integer | - | 0x0 | 秒 |

### TranslationCalibModu

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| RotPointTotalNum | Integer | - | 0 | RotNum |
| RefreshFileEnable | Boolean | - | True | RefreshFileEnable |
| TeachEnable | Boolean | - | False | TeachEnable |
| UnionCalibEnable | Boolean | - | False | UnionCalibEnable |
| CalibPointInput | RadioSelecter | - | 0 | Calibration Points Input |
| ImageRotateAngle | ButtonSelecter | - | - | Image Angle |
| PhyPoint | ButtonSelecter | - | - | WorldPointLst |
| PhyPointX | ButtonSelecter | - | - | Physical Coordinate X |
| PhyPointY | ButtonSelecter | - | - | Physical Coordinate Y |
| PicPoint | ButtonSelecter | - | - | Image Point |
| PicPointX | ButtonSelecter | - | - | ImagePointX |
| PicPointY | ButtonSelecter | - | - | ImagePointY |
| TeachFlag | ButtonSelecter | - | - | TriggerString |
| Trigger | ButtonSelecter | - | - | InputString |
| WorldRotateAngle | ButtonSelecter | - | - | RunParam_WorldRotateAngle |
| Clear | Command | - | - | ClearPoint |

### WindowThresholdModu ⚠️ 未在 module-index.md 收录

| 参数名 | 类型 | algoIdx | 默认值 | displayName |
|--------|------|---------|--------|-------------|
| thresholdValue | Integer | - | - | 对比度 |
| windowHeight | Integer | - | - | 窗口高度 |
| windowWidth | Integer | - | - | 窗口宽度 |
