# VM 模块类名-中文名索引

从 VisionMaster 4.4.0 `Module(sp)/x64/` 目录和 Help HTML 提取。共 179 个模块。

## 字段说明

- **类名**：VmServer.xml `ModuleBase/Name`，即模块目录名，sol 解析时直接可见
- **中文名**：VM 界面工具箱中的模块显示名称
- **分类**：VM 工具箱中的分类目录
- **Help GUID**：ToolItemInfo.xml 中的 `<helpUrl>`，对应帮助文档 HTML 文件名（`{VM}\Applications\Help\CH\{helpUrl}.html`）。需要从 VM 安装目录提取填充。


## 索引生成方法

使用 `scripts/generate_index.js` 脚本从 VM 安装目录自动生成：

```bash
# 1. 先检测 VM 安装路径（自动搜索 PATH、ProgramFiles、注册表）
node "<skill_dir>/scripts/generate_index.js" --detect

# 2. 确认路径后生成索引（--vm-path 可省略，脚本会尝试自动检测）
node "<skill_dir>/scripts/generate_index.js"   --cache "$LOCALAPPDATA/vm_module_cache/index.json"
```

### VM 路径检测方式

脚本自动检测 VM 安装路径，优先级如下：

1. **`--vm-path` 显式指定** — 优先使用命令行参数
2. **注册表** — 查询 `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\` 下所有 `VisionMaster*` 子键的 `InstallPath`
3. **PATH 环境变量** — 扫描 PATH 中包含 `VisionMaster` 的路径
4. **ProgramFiles** — 遍历 `%ProgramFiles%\VisionMaster*` 目录

无需手动指定 `--vm-path`，脚本会自动从注册表找到已安装的 VM 路径。

### 缓存路径

所有缓存统一存放在 `$LOCALAPPDATA/vm_module_cache/`：

| 缓存内容 | 路径 |
|----------|------|
| 模块索引 | `$LOCALAPPDATA/vm_module_cache/index.json` |
| SDK CHM 解压 | `$LOCALAPPDATA/vm_module_cache/vm_net_chm/` |

### 中文名提取

`generate_index.js` 自动从帮助 HTML 的 `<title>` 标签提取模块中文名。帮助文档路径：`{VM}\Applications\Help\CH\{helpUrl}.html`。

> 注意：本表 Help GUID 基于 VM 4.4.0 安装环境提取，已全部填充。如使用不同 VM 版本，可在对应环境下重新运行上述脚本更新。

## 模块索引

| 类名 | 中文名 | 分类 | Help GUID |
|------|--------|------|-----------|
| AndModule | 逻辑 | Logic | GUID-FD7E10DA-87D6-4CD5-AB9C-485E3A63B785 |
| BranchModule_STD | 分支模块 | Logic | GUID-2CAA7CA7-2CEC-412C-AB2D-D6DB2352F480 |
| BranchStringCpm | 分支字符 | Logic | GUID-5A2F2C77-4C57-459E-9E29-C9C7A98F3578 |
| CalculatorModule | 变量计算 | Calculation | GUID-3DF795D9-922C-4B24-B468-0B531ABB5C55 |
| CalibBoardCalib | 标定板标定 | Calibration | GUID-8D5DB57F-7824-4612-8504-2A681B317B1B |
| CalibTransformation | 标定转换 | Calculation | GUID-CE5BEEFF-1840-4BD4-8123-FD1D4835F14F |
| CameraIOOutput | 相机IO通信 | Communication | GUID-802798BF-D673-4B4F-A19C-3497A37DB695 |
| CoordinateModule | 坐标系 | Calibration | GUID-92E4FAD2-A19B-4F3D-8360-94A5088D8ED4 |
| CoordinateTransform | 坐标转换 | Calculation | GUID-579A0B6D-7A7D-455C-BA3D-36D9133666FA |
| DataAnalysisModule | 协议解析 | Communication | GUID-731B483B-162F-4647-8543-585D230AD5D3 |
| DataAssembleModule | 协议组装 | Communication | GUID-66B5B269-CB63-4B17-B2DC-B94698683D0C |
| DataClassificationModule | 数据分类 | Logic | GUID-46D7BFDD-A4AA-4BC9-9E03-3AE9A80AF3CF |
| DataFilterModule | 数据筛选 | Logic | GUID-C3774ACD-18F3-44B2-B76F-A33F1A92F29A |
| DataQueueModule | 数据队列 | Global | GUID-BD8E6447-37AE-461E-98DC-918DCA837A7F |
| DataRecordModule | 数据记录 | Logic | GUID-F68D2915-4630-4829-8996-F0B206188342 |
| DataSetModule | 数据集合 | Logic | GUID-79125701-03C3-4CBD-A7BB-4785A855C1B0 |
| DataSortModule | 数据排序 | Logic | GUID-AA0605C1-79EA-4DD2-84DC-B977EE930F2D |
| FormatModule | 格式化 | Logic | GUID-ACB5F857-FFA1-47AC-86EA-DB379B3C694C |
| GeometryCreate | 几何创建 | ImageGeneration | GUID-640D4DD5-D4E6-43CD-BA46-3A2ECAF023C1 |
| GlobalCameraModule | 全局相机 | Global | GUID-6459C855-C134-4DF0-A790-49AC73DBB525 |
| GlobalCommunication | 通信示例 | Global | GUID-385BAEB8-FDA2-464A-B2B6-B8A5538646F5 |
| GlobalTriggerModule | 全局触发 | Global | GUID-6469C64B-3991-4921-97AE-D66CBAF1FDA9 |
| GlobalVariableModule | 全局/局部变量 | Global | GUID-B4B85EF2-F06E-4904-A2D5-5E2830D90A1B |
| GraphicsSetModule | 图形收集 | Logic | GUID-9045EAB1-11E4-4875-9F86-E27F710F2B0B |
| IfBranchModule | 条件分支 | Logic | GUID-5281887C-3F02-41B5-8FBB-3B91AFC7EB6A |
| IfModule | 条件检测 | Logic | GUID-B494824F-2CCB-4338-B68E-332A26EDDB93 |
| Image Buffer | 缓存图像 | Collection | GUID-51ED7561-7277-4D14-958A-86CCFAAB7995 |
| ImageAcquisitionModule | 多图采集 | Collection | GUID-64805238-C122-44F3-9F93-A5DFBBD7DF7E |
| ImageSourceModule | 图像源 | Collection | GUID-8D7949F0-EB91-4794-BD3C-D4182726D931 |
| IMVS2dArrayCorrectModu | 二维阵列 | SplitCombination | GUID-140703C9-5906-4AA9-98C2-22E4D1161C3D |
| IMVS2dBcrModu | 二维码识别 | Recognition | GUID-8663EFF6-1EF6-4ECE-A56B-059BB3C71AFE |
| IMVSAffineTransformModu | 仿射变换 | ImageProcessing | GUID-D920C1E1-C9C2-4F1C-9EB6-55218D27430E |
| IMVSAngleBisectorFindModu | 角平分线查找 | Location | GUID-BF4029D6-5171-4BCF-BFCC-7BD3007C92BA |
| IMVSBcrModu | 条码识别 | Recognition | GUID-D87F7EEE-00FD-4746-9CE1-96379FFD04BF |
| IMVSBinaryModu | 图像二值化 | ImageProcessing | GUID-DBCA7DED-F21F-44EB-BA0A-1D61CB7CDE45 |
| IMVSBlobFindLabelsModu | Blob标签分析 | Location | GUID-30825B06-0A29-4B5D-B8D7-C4D873A04BA0 |
| IMVSBlobFindModu | Blob分析 | Location | GUID-F5B9D37D-90C6-45DE-8880-DADBE017C0CC |
| IMVSBlobFindMultiModu | Blob分析 | Location | GUID-F5B9D37D-90C6-45DE-8880-DADBE017C0CC |
| IMVSBoxFilterModule | Box过滤 | SplitCombination | GUID-3CB3ACB0-C44A-490D-8F15-7B3E72CCBBC8 |
| IMVSBoxMergeModu | Box融合 | SplitCombination | GUID-67BAB956-79EC-4B8E-83DA-36C31957686F |
| IMVSBoxOverlapCalculationModu | Box重叠率计算 | SplitCombination | GUID-853E533B-BEDF-4DD9-AF0A-3CB9FEA1E758 |
| IMVSC2CMeasureModu | 圆圆测量 | Measurement | GUID-B405EF10-8757-408F-AF44-EC96C69FC259 |
| IMVSCaliperCornerModu | 边缘交点 | Location | GUID-AC7C61F6-98CD-4372-95AF-88D2FACE1E33 |
| IMVSCaliperEdgeModu | 边缘查找 | Location | GUID-B27DE7AB-9A3A-4122-83BE-C29C10519C0F |
| IMVSCaliperModu | 卡尺工具 | Location | GUID-59D1E6A2-C5BF-49AE-8F36-6B5A90A23F1A |
| IMVSCameraMapModu | 相机映射 | Calibration | GUID-CC3DB2DB-FC0B-4410-A58B-DDAC72E2360B |
| IMVSCircleEdgeInspModu | 圆弧边缘缺陷检测 | DefectDetection | GUID-DB197B8C-60C1-4D7E-8BA6-C7D7A5419C21 |
| IMVSCircleEdgePairInspModu | 圆弧对缺陷检测 | DefectDetection | GUID-E04064AD-DBA2-4F7E-86C1-D82B9E6416A2 |
| IMVSCircleFindModu | 圆查找 | Location | GUID-775E02DE-C1C8-4FF3-89D2-ED39C20D5F43 |
| IMVSCircleFitModu | 圆拟合 | ImageGeneration | GUID-D2906374-C408-4ED7-A2C2-4848CF3B74D6 |
| IMVSCnnCharDetectModu | DL字符定位 | Recognition | GUID-3F24C68B-6BF7-4497-A951-8CA9A9F3599C |
| IMVSCnnCharDetectModuC | DL字符定位 | Recognition | GUID-3F24C68B-6BF7-4497-A951-8CA9A9F3599C |
| IMVSCnnClassifyModu | DL分类 | DeepLearning | GUID-0334A6EB-8878-4085-92D3-2E5CA61A6345 |
| IMVSCnnClassifyModuC | DL分类 | DeepLearning | GUID-0334A6EB-8878-4085-92D3-2E5CA61A6345 |
| IMVSCnnCodeRecgModu | DL读码 | Recognition | GUID-232166CF-FEC1-4600-8273-A3C44100C061 |
| IMVSCnnCodeRecgModuC | DL读码 | Recognition | GUID-232166CF-FEC1-4600-8273-A3C44100C061 |
| IMVSCnnDetectModu | DL目标检测 | DeepLearning | GUID-985E5FE9-B7CB-4DEA-8799-925505DC05AF |
| IMVSCnnDetectModuC | DL目标检测 | DeepLearning | GUID-985E5FE9-B7CB-4DEA-8799-925505DC05AF |
| IMVSCnnFastFlawModu | DL（快速）图像分割 | DeepLearning | GUID-AB3C1742-114E-4EA0-9EA1-9EE145EAB6E8 |
| IMVSCnnFlawAndBlobModu | DL（快速）图像分割 | DeepLearning | GUID-AB3C1742-114E-4EA0-9EA1-9EE145EAB6E8 |
| IMVSCnnFlawAndBlobModuC | DL（快速）图像分割 | DeepLearning | GUID-AB3C1742-114E-4EA0-9EA1-9EE145EAB6E8 |
| IMVSCnnFlawModu | DL（快速）图像分割 | DeepLearning | GUID-AB3C1742-114E-4EA0-9EA1-9EE145EAB6E8 |
| IMVSCnnFlawModuC | DL（快速）图像分割 | DeepLearning | GUID-AB3C1742-114E-4EA0-9EA1-9EE145EAB6E8 |
| IMVSCnnInspectModu | DL异常检测 | DeepLearning | GUID-B068070F-13AA-4D31-9576-BA83BFF07971 |
| IMVSCnnInspectModuC | DL异常检测 | DeepLearning | GUID-B068070F-13AA-4D31-9576-BA83BFF07971 |
| IMVSCnnInstanceSegmentModu | DL实例分割 | DeepLearning | GUID-0BAA3E3E-F308-4BF3-B9BB-BD80D50193CA |
| IMVSCnnInstanceSegmentModuC | DL实例分割 | DeepLearning | GUID-0BAA3E3E-F308-4BF3-B9BB-BD80D50193CA |
| IMVSCnnRegisterClassifyModu | 注册分类 | RegisterLearning | GUID-2070CC8B-2D16-495F-9953-70BE1EE265D8 |
| IMVSCnnRegisterClassifyModuC | 注册分类 | RegisterLearning | GUID-2070CC8B-2D16-495F-9953-70BE1EE265D8 |
| IMVSCnnRetrievalModu | DL图像检索 | DeepLearning | GUID-24D1B4FF-2529-49A2-BA32-B1CB5E19DA99 |
| IMVSCnnRetrievalModuC | DL图像检索 | DeepLearning | GUID-24D1B4FF-2529-49A2-BA32-B1CB5E19DA99 |
| IMVSCnnSingleCharDetectModu | DL单字符检测 | Recognition | GUID-0BD3BF2C-55FB-4FFB-A3AC-080AE91C0BFD |
| IMVSCnnSingleCharDetectModuC | DL单字符检测 | Recognition | GUID-0BD3BF2C-55FB-4FFB-A3AC-080AE91C0BFD |
| IMVSColorExtractModu | 颜色抽取 | ColorProcessing | GUID-C0B99F55-AEA1-47A2-8A8E-FCAEA4F4D8D9 |
| IMVSColorImageGenerationModu | 彩图生成 | ColorProcessing | GUID-DB8D7B96-7F61-4AF1-BB02-C07FEEF15006 |
| IMVSColorMeasureModu | 颜色测量 | ColorProcessing | GUID-F3570586-BF14-4F23-84B1-724F64AB0C75 |
| IMVSColorRecognitionModu | 颜色识别 | ColorProcessing | GUID-A198B132-97D6-47B7-BC26-26905DC505B2 |
| IMVSColorSegmentModu | 颜色分割 | ColorProcessing | GUID-B32A03FC-D428-4277-A80F-F78C36ACBC80 |
| IMVSColorTransformModu | 颜色转换 | ColorProcessing | GUID-4E31F1F1-DC1D-485F-BB8A-A1D8659FD887 |
| IMVSContourMatchModu | 模板匹配 | Location | GUID-3EEB6D91-78DA-40BF-AC7B-537FEBB00FFC |
| IMVSDivideImageModu | 划片拆分 | SplitCombination | GUID-01A37414-3B5F-4C2B-86EF-5BF1689E104D |
| IMVSDynamicMarkInspModu | 字符缺陷检测 | DefectDetection | GUID-E7B8456D-50E6-412E-B0DD-92FAD7CFB01D |
| IMVSEdgeFlawInspModu | 边缘模型缺陷检测 | DefectDetection | GUID-57AF3E61-48C9-46D4-B1AD-7514A85D11E3 |
| IMVSEdgeInspGroupModu | 边缘组合缺陷检测 | DefectDetection | GUID-AB6F2BE6-C866-42D6-88FC-467C1727FB0B |
| IMVSEdgePairFlawInspModu | 边缘对模型缺陷检测 | DefectDetection | GUID-2088B523-C714-4C44-8028-2DFDEB80EF64 |
| IMVSEdgePairInspGroupModu | 边缘对组合缺陷检测 | DefectDetection | GUID-9F0B5316-302A-458B-833F-33611E2A8F96 |
| IMVSEdgePairPosTrendAnalyModu | 边缘对位置趋势分析 | DefectDetection | GUID-DE66F05A-3DB8-4BB6-9E10-A731F76D1AFB |
| IMVSEdgePosTrendAnalyModu | 边缘位置趋势分析 | DefectDetection | GUID-D4EF98A4-3663-4FD5-9A25-6EBA822EB9EB |
| IMVSEdgeWidthFindModu | 间距检测 | Measurement | GUID-717CEBA0-B391-4733-9EDD-CF49CDE19A63 |
| IMVSEllipseFindModu | 椭圆查找 | Location | GUID-5E9EBB80-156D-4570-A2B9-B595D7F23748 |
| IMVSEllipseFitModu | 椭圆拟合 | ImageGeneration | GUID-9231C445-0536-4EC9-8DD8-B6A72033BC9B |
| IMVSFastFeatureMatchModu | 模板匹配 | Location | GUID-3EEB6D91-78DA-40BF-AC7B-537FEBB00FFC |
| IMVSFixtureModu | 位置修正 | Location | GUID-6DF4A29F-1B7F-4910-8AF0-9C93C18F9985 |
| IMVSFrameMeanModu | 帧平均 | ImageProcessing | GUID-3A646FBA-2A8E-43B8-8FE4-37EE0B28F7DA |
| IMVSGeometricTransformModu | 几何变换 | ImageProcessing | GUID-A7C9FF45-7DEC-4ACC-9BF9-E7A6DE44914F |
| IMVSGluePathConductModu | 路径提取 | Location | GUID-363ABF24-48B6-4D8E-A996-CF63867C4187 |
| IMVSGrayMatchModuVA | 模板匹配 | Location | GUID-3EEB6D91-78DA-40BF-AC7B-537FEBB00FFC |
| IMVSHistToolModu | 直方图工具 | Measurement | GUID-BE952939-4965-43CA-AB2D-FF0B610A9904 |
| IMVSHPFeatureMatchModu | 模板匹配 | Location | GUID-3EEB6D91-78DA-40BF-AC7B-537FEBB00FFC |
| IMVSImageCalibModu | 畸变标定 | Calibration | GUID-B1F339C2-C5A1-4456-B032-42A98E983A37 |
| IMVSImageCombineProcessModu | 图像组合 | ImageProcessing | GUID-5E58EFE8-C00C-4627-B72C-8CBF15B3AD6A |
| IMVSImageCorrectCalibModu | 畸变校正 | ImageProcessing | GUID-A1D40754-355B-4E96-A87D-15738C80AB43 |
| IMVSImageCorrectManualModu | 图像矫正 | ImageProcessing | GUID-C98C44BE-2DB4-498B-8568-5FAC094D0DAB |
| IMVSImageEnhanceModu | 图像增强 | ImageProcessing | GUID-A7167DA4-4180-4C28-99A6-C49B348FE5C5 |
| IMVSImageFilterModu | 图像滤波 | ImageProcessing | GUID-D7D5B570-FC6A-4694-B39B-46C5EA4531C9 |
| IMVSImageFixtureModu | 图像修正 | ImageProcessing | GUID-550C41E6-EC6A-4779-8F6E-2613AED7F58E |
| IMVSImageMathModu | 图像运算 | ImageProcessing | GUID-B6C0B945-4D0D-4F6F-B3E8-30008651C53C |
| IMVSImageMorphModu | 形态学处理 | ImageProcessing | GUID-40515844-A143-4A39-A671-B12A9FF42A24 |
| IMVSImageNormlizeModu | 图像归一化 | ImageProcessing | GUID-DD61A79B-AA36-4128-B32A-DF5FE614DC64 |
| IMVSImageResizeModu | 图像缩放 | ImageProcessing | GUID-B1F70312-3DE0-4944-9754-2168267AD601 |
| IMVSImageSharpnessModu | 清晰度评估 | ImageProcessing | GUID-E4011A8D-934D-4542-B255-DDA0130FBF68 |
| IMVSImgStitchCalibModu | 图像拼接 | ImageProcessing | GUID-D96178C8-D22A-4D27-BF76-781A0C6F6806 |
| IMVSInspectModu | 异常检测 | DefectDetection | GUID-41082619-9A45-4610-9FCB-295EA8C28EED |
| IMVSIntensityMeasureModu | 亮度测量 | Measurement | GUID-40C9A7E5-78C7-450A-B575-B172295D5A1F |
| IMVSInverseAffineTransformModu | 逆仿射变换 | ImageProcessing | GUID-93B178E3-8386-4C46-B675-1AA24A2435A7 |
| IMVSL2CMeasureModu | 线圆测量 | Measurement | GUID-D1E73475-679F-4019-B38E-35F59B422EA7 |
| IMVSL2LMeasureModu | 线线测量 | Measurement | GUID-B65A34E9-AFE3-404F-8CAF-189DD94871B5 |
| IMVSLineAlignModu | 线对位 | Calculation | GUID-FDB35A90-E2C7-408C-930A-04D860F5DEAA |
| IMVSLineEdgeInspModu | 直线边缘缺陷检测 | DefectDetection | GUID-5A6EF92F-F858-4134-A567-68D77CFB8465 |
| IMVSLineEdgePairInspModu | 直线对缺陷检测 | DefectDetection | GUID-F9F0D400-554B-4392-A9CD-71161AE8A5F3 |
| IMVSLineFindGroupModu | 直线查找组合 | Location | GUID-FCCB00B1-EA59-49D6-9797-C0602109604B |
| IMVSLineFindModu | 直线查找 | Location | GUID-0D7A8AEC-9900-4AEE-84F6-BEE9AA78B187 |
| IMVSLineFitModu | 直线拟合 | ImageGeneration | GUID-A1C670FC-95ED-4BA7-A305-A5A85CABA804 |
| IMVSMachineLearningClassifierModu | ML分类 | Recognition | GUID-6F82D168-AFBC-4BC0-93E3-F146C117C320 |
| IMVSMapCalibModu | 映射标定 | Calibration | GUID-852DC137-2B13-4973-AD35-A28B2628470F |
| IMVSMarkFindModu | 图形定位 | Location | GUID-6AE4A6CD-6535-4C6D-B83D-D6CC66A89612 |
| IMVSMarkInspModuVA | 字符缺陷检测 | DefectDetection | GUID-E7B8456D-50E6-412E-B0DD-92FAD7CFB01D |
| IMVSMatrixCircleFindModu | 阵列圆查找 | Location | GUID-EFAA43D6-6369-4A65-A8F2-6C5223439C26 |
| IMVSMedianLineFindModu | 中线查找 | Location | GUID-C638DC95-E3E9-433B-A5BC-A8E2C463C9E8 |
| IMVSMultiImageFusionModu | 多图融合 | ImageProcessing | GUID-0C25D7F2-C78E-4A29-81DB-9F94E927E901 |
| IMVSMultiLabelFilterModu | 多标签筛选 | SplitCombination | GUID-2DFB7F80-1E6E-4466-9757-D963044BC119 |
| IMVSMultiLineFindModu | 多直线查找 | Location | GUID-0DFF1C34-A12B-4F39-A44E-A2E8135E0481 |
| IMVSMultiPointAlignModu | 点集对位 | Calculation | GUID-B915DB40-0CD2-4041-B3FD-4BCF06DF24B7 |
| IMVSNImageCalibModu | N图像标定 | Calibration | GUID-E09E33AF-4E9C-409A-8845-2C4863297332 |
| IMVSNPointCalibModu | N点标定 | Calibration | GUID-E02DEF21-AC77-4183-B15E-021A8CED94E9 |
| IMVSOcrDlModu | DL字符识别 | Recognition | GUID-F7DDBD81-2EB6-49C9-B0FB-26951DCB5E6C |
| IMVSOcrDlModuC | DL字符识别 | Recognition | GUID-F7DDBD81-2EB6-49C9-B0FB-26951DCB5E6C |
| IMVSOcrModu | 字符识别 | Recognition | GUID-E962E212-2FE7-4653-B7EC-34FBF687654A |
| IMVSP2CMeasureModu | 点圆测量 | Measurement | GUID-DDF022A5-05E4-417E-92FB-ED344DEA5779 |
| IMVSP2LMeasureModu | 点线测量 | Measurement | GUID-B45E20E4-EB8B-4040-93B4-43F83E12A386 |
| IMVSP2PMeasureModu | 点点测量 | Measurement | GUID-352A1EEE-F832-4B5E-8129-8E0F914694B3 |
| IMVSPairLineModu | 平行线查找 | Location | GUID-83B53671-DDCD-4CDF-A36D-DB1C157BDA5C |
| IMVSParallelCalculateModu | 平行线计算 | Location | GUID-71C547CA-CFAF-4405-AB7E-DBB0A3F25DAB |
| IMVSPeakFindModu | 顶点检测 | Location | GUID-60A3CFEF-3545-4F1C-B496-85F3FB7FA2D1 |
| IMVSPixelCountModu | 像素统计 | Measurement | GUID-60D8AD05-7006-44E3-B7B3-8D8AAF9EC3B6 |
| IMVSPixelCountModuVA | 像素统计 | Measurement | GUID-60D8AD05-7006-44E3-B7B3-8D8AAF9EC3B6 |
| IMVSPolarUnwarpModu | 圆环展开 | ImageProcessing | GUID-83F9B723-A625-4C9C-BE94-680128929A37 |
| IMVSQuadrangleFindModu | 四边形查找 | Location | GUID-B64DDF22-DF2B-45E0-B2C0-2C28396586D0 |
| IMVSRectFindModu | 矩形检测 | Location | GUID-6319AFC5-24E9-432F-B7A2-F15ED2A53EA1 |
| IMVSRegionCopyModu | 拷贝填充 | ImageProcessing | GUID-5D5F78A0-A275-4C2C-AD6D-45E65AC8ECB2 |
| IMVSRotateCalculateModu | 旋转计算 | Calculation | GUID-445A8E5B-F2C6-406E-AB19-E7C3F95C5854 |
| IMVSScaleTransformModu | 单位转换 | Calculation | GUID-6C4E0C0E-03E6-4811-B1C4-27DA6AC470B6 |
| IMVSShadeCorrectModu | 阴影校正 | ImageProcessing | GUID-C00A3C02-8891-45C5-9DC2-E338668F23AD |
| IMVSSinglePointAlignModu | 单点对位 | Calculation | GUID-8D5DF72C-7CAA-4F7A-9D83-AED1EEE8AD5B |
| IMVSSurfaceDefectFilterModu | 表面缺陷滤波 | DefectDetection | GUID-2F7D68CD-FFFE-4231-87DD-28A80C73051E |
| IMVSTargetTrackModu | 目标跟踪 | Location | GUID-8D08962E-FDF9-4772-BE1C-2EDA87D83182 |
| IMVSVerticalLineFindModu | 垂线查找 | Location | GUID-EDDA0508-4293-4175-BAAA-4184220E13B9 |
| Lang_ComprehensiveConfig | 综合配置 | Global | GUID-753B4DE6-06B7-4623-841F-635DDBCB1916 |
| Lang_ControllerSet | 控制器管理 | Global | GUID-E2148FEE-37B1-45AF-B35D-668F6F01D0F8 |
| Light | 光源 | Collection | GUID-CE1B641E-3A80-48A5-AE14-671A2FBE3FCC |
| MultiCamerasImageSourceModule | 多图采集 | Collection | GUID-64805238-C122-44F3-9F93-A5DFBBD7DF7E |
| MultiLightCameraModule | 全局相机 | Global | GUID-6459C855-C134-4DF0-A790-49AC73DBB525 |
| PointSetMODU_STD | 点集 | Logic | GUID-437B7269-2439-4982-BB59-9BB433F87F4E |
| PyShellModule | Python脚本 | Logic | GUID-E1BCE97A-3ADB-445D-8AB7-162C0DBCF6ED |
| ReadCalibFileModu | 标定加载 | Calibration | GUID-7D1B323E-54E4-45E3-9453-C942AA0C9095 |
| ReadDatasModule | 接收数据 | Communication | GUID-EACA6806-F479-4939-A576-11EB3B0DECD4 |
| RotateCalibModu | 旋转标定 | Calibration | GUID-7BDADB33-D129-4ED4-8ADF-BD7A26E93B5C |
| SaveImage | 输出图像 | Collection | GUID-FFC33EA2-AEF9-4FDC-B240-DB74DE0010F7 |
| SaveTextModule | 文本保存 | Logic | GUID-933448AC-A693-4A0A-9238-E95A02C16C02 |
| SendDatasModule | 发送数据 | Communication | GUID-878938B0-1B91-4290-A81A-A3AD89BD5FBC |
| ShellModule | 脚本 | Logic | GUID-7C5BAFEF-24AB-4ACC-8A9C-64C29BD414FA |
| SinglePointGrabModu | 单点抓取 | Calculation | GUID-82E4A1A6-2331-4AF3-89EF-5981C7D0FBD8 |
| SinglePointMapAlignModu | 单点映射对位 | Calculation | GUID-6DBC256A-8DFF-4B77-85AD-F71F7873EBB4 |
| SinglePointRectifyModu | 单点纠偏 | Calculation | GUID-7A3742E9-2D93-4577-AB78-3F4F1DD37585 |
| StringCompareModule | 字符比较 | Logic | GUID-F45A21AB-6E19-47C9-B730-1C1940ABAB0A |
| TimeStatisticModule | 耗时统计 | Logic | GUID-5C37CBE8-CEE3-48E4-9685-557733404E9E |
| TranslationCalibModu | 平移旋转标定 | Calibration | GUID-543D47A9-74D6-432B-8D14-2CF6EB12FAED |
| TriggerModule | 触发模块 | Logic | GUID-70FFC413-A34C-47BB-8F53-C8328D0D2DE6 |

## 注意事项

- 中文名来源为 Help HTML `<meta name="DC.Title">`，与 VM 界面工具箱显示名称一致
- `DisplayName`（VmServer.xml）是用户自定义的实例名（如"脚本1"、"直线查找2"），不是模块类型名
- 同名中文模块（如 4 个"模板匹配"、4 个"DL（快速）图像分割"）通过类名区分
- `IMVSGrayMatchModuVA` 和 `IMVSMarkInspModuVA` 的 VA 后缀表示 Vision Assistant 版本算法
- `*C` 后缀（如 `IMVSCnnClassifyModuC`）表示 CPU 版本（不带 C 为 GPU 版本）
- **UserTools 分类**：非 VM 部门开发的第三方自定义模块，部分模块没有中文名，界面直接使用类名作为显示名称，不遵循标准模块的命名规范
