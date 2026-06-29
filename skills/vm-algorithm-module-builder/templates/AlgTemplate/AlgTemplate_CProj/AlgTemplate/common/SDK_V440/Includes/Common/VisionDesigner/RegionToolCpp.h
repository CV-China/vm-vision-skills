/***************************************************************************************************
* File：RegionToolCpp.h
* Note：Region工具接口类.
***************************************************************************************************/
#ifndef _REGIONTOOL_CPP_H_
#define _REGIONTOOL_CPP_H_

#include "MVDImageCpp.h"
#include "MVDShapeCpp.h"
#include "MVDRegionCpp.h"
#include "MVD_AlgoParamDefine.h"
#include "MVDCore.h"

namespace VisionDesigner
{
    // 转换为点集类型
    enum EncodePointSetType
    {
        EncodePointSetEdge  =   0, // 边缘点
        EncodePointSetFont  =   1, // 前景点
    };

    // 孔洞填充类型
    enum HoleFillType
    {
        HoleFillNone  =   0, // 填充所有孔洞
        HoleFillArea  =   1, // 根据面积填充
    };

    //形态学图形类型
    enum MorphShapeType
    {
        MorphKernelShapeRect     = 0, // 矩形
        MorphKernelShapeEllipse  = 1, // 椭圆
    };

    // 连通类型
    enum ConnectivityType
    {
        Connectivity4  =  4,  // 4连通
        Connectivity8  =  8,  // 8连通
    };

    // 特征使能类型
    enum SelectShapeEnableFlag
    {
        FeatureShapeEnableArea                = 0x00000001,  // 面积 
        FeatureShapeEnableRect                = 0x00000002,  // 最小外接正矩形（包围盒）
        FeatureShapeEnableCentroid            = 0x00000004,  // 质心（一阶矩）
        FeatureShapeEnablePerimeter           = 0x00000008,  // 周长（与连通性设置有关）
        FeatureShapeEnableBox                 = 0x00000010,  // 最小外接矩形
        FeatureShapeEnableRectangularity      = 0x00000020,  // 矩形度（面积/最小外接矩形面积）
        FeatureShapeEnableCentroidBoxBias     = 0x00000040,  // 质心与最小外接矩形中心的偏移距离
        FeatureShapeEnableCircle              = 0x00000080,  // 最小外接圆
        FeatureShapeEnableCircularity         = 0x00000100,  // 圆形度（近似为面积/最小外接矩形面积）
        FeatureShapeEnableCentroidCircleBias  = 0x00000200,  // 质心与最小外接圆中心的偏移距离
        FeatureShapeEnableInnerCircle 		  = 0x00000400,  // 最大内接圆
    };

    // 排序类型
    enum SelectShapeSortType
    {
        SelectShapeSortNone             = 0x00000000,  // 不排序，排序类型数量无效
        SelectShapeSortArea             = 0x00000100,  // 面积
        SelectShapeSortRectX            = 0x00000201,  // 包围盒左上角横坐标
        SelectShapeSortRextY            = 0x00000202,  // 包围盒左上角纵坐标
        SelectShapeSortCentroidX        = 0x00000300,  // 质心横坐标
        SelectShapeSortCentroidY        = 0x00000301,  // 质心横坐标
        SelectShapeSortPerimeter        = 0x00000400,  // 周长
        SelectShapeSortBoxShortAxis     = 0x00000500,  // 最小外接矩形短轴长度
        SelectShapeSortBoxLongAxis      = 0x00000501,  // 最小外接矩形长轴长度
        SelectShapeSortBoxAxisRatio     = 0x00000502,  // 最小外接矩形轴比
        SelectShapeSortBoxAngle         = 0x00000503,  // 最小外接矩形角度
        SelectShapeSortRectangularity   = 0x00000600,  // 矩形度
        SelectShapeSortCircleRadius     = 0x00000800,  // 外接圆半径
        SelectShapeSortCirCularity      = 0x00000900,  // 圆形度
    };

    // 排序方式
    enum SelectShapeSortOrder
    {
        SelectShapeSortAscend  = 0,   // 升序
        SelectShapeSortDescend = 1,   // 降序
    };

    // 特征筛选阈值
    enum SelectShapeThreshold
    {
        SelectShapeThresholdArea              = 0,  // 面积 ，范围：int[0-99999]
        SelectShapeThresholdRectWidth         = 1,  // 外接矩形宽，范围：int[0-65535]
        SelectShapeThresholdRectHeight        = 2,  // 外接矩形高，范围：int[0-65535]
        SelectShapeThresholdPerimeter         = 3,  // 周长，范围：int[0-99999]
        SelectShapeThresholdBoxShortAxis      = 4,  // 短轴，范围：int[0-65535]
        SelectShapeThresholdBoxLongAxis       = 5,  // 长轴，范围：int[0-65535]
        SelectShapeThresholdBoxAxisRatio      = 6,  // 外接矩形轴比，范围：float[0-1.0]
        SelectShapeThresholdBoxAngle          = 7,  // 外接矩形角度，范围：float[-90-90]
        SelectShapeThresholdRectAngularity    = 8,  // 矩形度，范围：float[0-1.0]
        SelectShapeThresholdCenteroidBoxBias  = 9,  // 质心到外接矩形中心距离，范围：float[0-65535]
        SelectShapeThresholdCircleRadius      = 10, // 外接圆半径，范围：int[0-46340]
        SelectShapeThresholdCircularity       = 11, // 圆形度，范围：float[0,1.0]
        SelectShapeThresholdCentroidCircle   = 12, // 质心到外接圆中心，范围：int[0-65535]
    };

    class IRegionTool
    {
    protected:
        explicit IRegionTool() {}
        virtual ~IRegionTool() {}

    public:
        /**
         * @brief 从图像生成Region
         * @param pInput  [IN] 输入图像
         * @param pRoi    [IN] ROI范围（仅支持0度矩形）,可为NULL，表示整个图像
         * @param pOutput [OUT] 输出Region
         * @par 权限
         * @note 仅支持灰度图
         * 读写
         */
        virtual void GenRegionFromImg(IN IMvdImage* pInput,IN IMvdRectangleF* pRoi,OUT IMvdRegion* pOutput) = 0;

         /**
         * @brief 从图像生成Region
         * @param pInput        [IN] 输入图像
         * @param pRoi          [IN] ROI范围（仅支持0度矩形）,可为NULL，表示整个图像
         * @param pMaskRegion   [IN] Region范围,可为NULL，不使用MaskRegion
         * @param nLowThr       [IN] 低阈值，范围:[0-255]
         * @param nHighThr      [IN] 高阈值，范围:[0-255]
         * @param pOutput       [OUT] 输出Region
         * @par 权限
         * @note 仅支持灰度图
         * 读写
         */
        virtual void GenRegionFromImg(IN IMvdImage* pInput,IN IMvdRectangleF* pRoi,IN  IMvdRegion* pMaskRegion,IN int nLowThr,int nHighThr,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 图形数组生成Region
         * @param pInputShapeList   [IN] 输入图形列表
         * @param nShapeNums        [IN] 图形数量
         * @param pOutput           [OUT] 输出Region
         * @par 权限
         * @note 仅支持矩形、圆、多边形
         * 读写
         */
        virtual void GenRegionFromShape(IN IMvdShape** pInputShapeList,IN unsigned int nShapeNum,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 图形生成Region
         * @param pInputShape   [IN] 输入图形
         * @param pOutput       [OUT] 输出Region
         * @par 权限
         * @note 仅支持矩形、圆、多边形
         * 读写
         */
        virtual void GenRegionFromShape(IN IMvdShape* pInputShape,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief Region转换为图像
         * @param pInput          [IN]  输入Region
         * @param pRoi            [IN]  ROI区域（仅支持0度矩形），可为NULL
         * @param nFrontGray      [IN]  前景值，范围:[0-255]
         * @param nBackGroundGray [IN]  背景值，范围:[0-255]
         * @param pOutImg         [OUT] 输出图像
         * @par 权限
         * 读写
         */
        virtual void RegionToBin(IN IMvdRegion* pInput,IN IMvdRectangleF* pRoi,IN int nFrontGray,IN int nBackGroundGray,OUT IMvdImage* pOutImg) = 0;

        /**
         * @brief Region转换为图像
         * @param pInput            [IN]  输入Region
         * @param nWidth            [IN]  设置图像宽
         * @param nHeight           [IN]  设置图像高
         * @param nFrontGray        [IN]  前景值，范围:[0-255]
         * @param nBackGroundGray   [IN]  背景值，范围:[0-255]
         * @param pOutImg           [OUT] 输出图像
         * @par 权限
         * 读写
         */
        virtual void RegionToBin(IN IMvdRegion* pInput,IN int nWidth,IN int nHeight,IN int nFrontGray,IN int nBackGroundGray,OUT IMvdImage* pOutImg) = 0;

        /**
         * @brief 获取Region点集
         * @param pInput        [IN] 输入Region
         * @param ePointType    [IN] 输出点集类型
         * @param pOutPointSet  [OUT] 点集
         * @note 仅支持Region个数为1
         * @par 权限
         * 读写
         */
        virtual void GetRegionPoints(IN IMvdRegion* pInput,IN EncodePointSetType ePointType,OUT IMvdPointSetF* pOutPointSet) = 0;

        /**
         * @brief 连通域分割
         * @param pInput        [IN] 输入Region
         * @param ePointType    [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Connection(IN IMvdRegion* pInput,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 孔洞填充
         * @param pInput            [IN] 输入Region
         * @param eType             [IN] 填充类型
         * @param nFillAreaLow      [IN] 填充低阈值(按面积填充时有效,范围:[1-2147483647])
         * @param nFilleAreaHigh    [IN] 填充高阈值(按面积填充时有效,范围:[1-2147483647])
         * @param ePointType        [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void FillUp(IN IMvdRegion* pInput,IN HoleFillType eType,IN int nFillAreaLow,IN int nFilleAreaHigh,OUT IMvdRegion* pOutput) = 0;
        
        /**
         * @brief 轮廓提取
         * @param pInput        [IN]  输入Region
         * @param ePointType    [OUT] 输出Region
         * @par 权限
         * @note 仅支持Region个数为1
         * 读写
         */
        virtual void GetRegionContour(IN IMvdRegion* pInput,OUT IMvdRegionContours* pOutContours) = 0;
        

        /**
         * @brief 设置特征筛选(SelectShape)特征阈值
         * @param eType     [IN] 特征类型
         * @param fLowThre  [IN] 低阈值
         * @param fHighThre [IN] 高阈值
         * @par 权限
         * @note 设置SelectShape特征筛选阈值，设置后当前Tool有效
         * 读写
         */
        virtual void SetSelectShapeThreshold(IN SelectShapeThreshold eType,IN float fLowThre,IN float fHighThre) = 0;

        /**
         * @brief 特征筛选
         * @param pInput    [IN] 输入Region
         * @param features  [IN] 特征使能，来自SelectShapeEnableFlag异或
         * @param eSortType [IN] 排序方式
         * @param eOrder    [IN] 排序类型，排序开启时有效
         * @param nSortNums [IN] 排序数量，排序开启时有效，范围:[1-100]
         * @param pOutput   [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void SelectShape(IN IMvdRegion* pInput,IN int features,IN SelectShapeSortType eSortType,IN SelectShapeSortOrder eOrder,IN int nSortNums,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 特征计算
         * @param pInput    [IN] 输入Region
         * @param features  [IN] 特征使能，来自SelectShapeEnableFlag异或
         * @note pFeatures仅支持获取当前使能特征
         * @par 权限
         * 读写
         */
        virtual void RegionFeatures(IN IMvdRegion* pInput,IN int features,OUT IMvdRegionFeatures* pFeatures) = 0;

        /**
         * @brief 交集
         * @param pInput  [IN] 输入Region
         * @param pOutput [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Intersection(IN IMvdRegion* pInput,OUT IMvdRegion* pOutput) = 0;
        
        /**
         * @brief 交集
         * @param pInput1   [IN] 输入Region
         * @param pInput2  [IN] 输入Region
         * @param pOutput  [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Intersection(IN IMvdRegion* pInput1,IN IMvdRegion* pInput2,OUT IMvdRegion* pOutput) = 0;
        

        /**
         * @brief 并集
         * @param pInput   [IN] 输入Region
         * @param pOutput  [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Union(IN IMvdRegion* pInput,OUT IMvdRegion* pOutput) = 0;
        /**
         * @brief 并集
         * @param pInput    [IN] 输入Region
         * @param pInput    [IN] 输入Region
         * @param pOutput   [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Union(IN IMvdRegion* pInput1,IN  IMvdRegion* pInput2,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 补集
         * @param pInput  [IN] 输入Region
         * @param pRoi    [IN] ROI范围（仅支持0度矩形）
         * @param pOutput [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Complement(IN IMvdRegion* pInput,IN  IMvdRectangleF* pRoi,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 差集
         * @param pInput1  [IN] 输入Region
         * @param pInput2  [IN] 输入Region
         * @param pOutput  [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Difference(IN IMvdRegion* pInput1,IN IMvdRegion* pInput2,OUT IMvdRegion* pOutput) = 0;
        
        
        /**
         * @brief 裁剪
         * @param pInput  [IN] 输入Region
         * @param pRoi    [IN] 裁剪ROI范围（仅支持0度矩形）
         * @param pOutput [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Clip(IN IMvdRegion* pInput,IN IMvdRectangleF* pRoi,OUT IMvdRegion* pOutput) = 0;

        /** 
         * @brief 膨胀
         * @param pInput   [IN] 输入Region
         * @param eType    [IN] 形态学图形类型
         * @param nWidth   [IN] 形态学核宽，范围:[1-101]
         * @param nHeight  [IN] 形态学核高，范围:[1-101]
         * @param nIter    [IN] 迭代次数，范围:[1-10]
         * @param pOutput  [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Dilation(IN IMvdRegion* pInput,IN MorphShapeType eType,IN int nWidth,IN int nHeight,IN int nIter,OUT IMvdRegion* pOutput) = 0;


        /** 
         * @brief 腐蚀
         * @param pInput   [IN] 输入Region
         * @param eType    [IN] 形态学图形类型
         * @param nWidth   [IN] 形态学核宽，范围:[1-101]
         * @param nHeight  [IN] 形态学核高，范围:[1-101]
         * @param nIter    [IN] 迭代次数，范围:[1-10]
         * @param pOutput  [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Erosion(IN IMvdRegion* pInput,IN MorphShapeType eType,IN int nWidth,IN int nHeight,IN int nIter,OUT IMvdRegion* pOutput) = 0;
 
        /**
         * @brief 开
         * @param pInput   [IN] 输入Region
         * @param eType    [IN] 形态学图形类型
         * @param nWidth   [IN] 形态学核宽，范围:[1-101]
         * @param nHeight  [IN] 形态学核高，范围:[1-101]
         * @param nIter    [IN] 迭代次数，范围:[1-10]
         * @param pOutput  [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Opening(IN IMvdRegion* pInput,IN MorphShapeType eType,IN int nWidth,IN int nHeight,IN int nIter,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 闭
         * @param pInput   [IN] 输入Region
         * @param eType    [IN] 形态学图形类型
         * @param nWidth   [IN] 形态学核宽，范围:[1-101]
         * @param nHeight  [IN] 形态学核高，范围:[1-101]
         * @param nIter    [IN] 迭代次数，范围:[1-10]
         * @param pOutput  [OUT] 输出Region
         * @par 权限
         * 读写
         */
        virtual void Closing(IN IMvdRegion* pInput,IN MorphShapeType eType,IN int nWidth,IN int nHeight,IN int nIter,OUT IMvdRegion* pOutput) = 0;

        /**
         * @brief 设置连通域类型
         * @param eType   [IN] 连通域类型
         * @par 权限
         * @note 设置后当前Tool有效
         * 读写
         */
        virtual void SetConnectivityType(IN ConnectivityType eType) = 0;
    };
}

/*  Note:Interfaces to export.  */
#ifdef __cplusplus
extern "C" {
#endif

    MVD_CPP_API int __stdcall CreateRegionToolInstance(VisionDesigner::IRegionTool** ppToolInstance);
    MVD_CPP_API int __stdcall DestroyRegionToolInstance(VisionDesigner::IRegionTool* pToolInstance);

#ifdef __cplusplus
}
#endif 
 
#endif    ///< _REGIONTOOL_CPP_H_