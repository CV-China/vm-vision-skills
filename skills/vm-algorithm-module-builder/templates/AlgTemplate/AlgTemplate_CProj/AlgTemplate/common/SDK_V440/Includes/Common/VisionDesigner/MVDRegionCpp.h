/***************************************************************************************************
* File：MVDRegionCpp.h
* Note：IRegion和IRegionArry接口类.
***************************************************************************************************/
#ifndef _REGION_CPP_H_
#define _REGION_CPP_H_

#include "MVDImageCpp.h"
#include "MVDShapeCpp.h"
#include "MVDCore.h"

namespace VisionDesigner
{
    class IMvdRegion
    {
    protected:
        virtual ~IMvdRegion() {}

    public:
         /**
         * @brief 克隆
         * @return 新Region对象
         */
        virtual IMvdRegion* Clone() = 0;
        /**
         * @brief 是否为空
         * @return 是否为空
         */
        virtual bool IsEmpty() = 0;
         /**
         * @brief 获取总外接正矩形
         * @return 外接正矩形
         */
        virtual MVD_RECT_F GetAllBoundingRect() = 0;
        /**
         * @brief 获取当前Region总面积
         * @return 面积
         */
        virtual float GetAllArea() = 0;
        /**
         * @brief 获取Region数量
         * @return Region数量
         */
        virtual int GetRegionNum() = 0;
        /**
         * @brief 获取单个Region
         * @param nIndex [IN] Region索引
         * @return 无，出错时抛出异常
         * @note nIndex从0开始计数
         */
        virtual void GetRegion(IN unsigned int nIndex,OUT IMvdRegion* pRegion) = 0;
        /**
         * @brief 添加Region
         * @param pInput [IN] 输入Region
         * @return 无，出错时抛出异常,仅支持pInput单个Region更新
         */
        virtual void AddRegion(IN IMvdRegion* pInput) = 0;
        /**
         * @brief 更新Region
         * @param nIndex [IN] Region索引
         * @param pInput [IN] 输入Region
         * @return 无，出错时抛出异常
         * @note nIndex从0开始计数,仅支持pInput单个Region更新
         */
        virtual void UpdateRegion(IN unsigned int nIndex,IN IMvdRegion* pInput) = 0;
        /**
         * @brief 移除Region
         * @param nIndex [IN] Region索引
         * @return 无，出错时抛出异常
         * @note nIndex从0开始计数
         */
        virtual void RemoveRegion(IN unsigned int nIndex) = 0;
        /**
         * @brief 清空Region
         * @return 无，出错时抛出异常
         */
        virtual void Clear() = 0;
    };

    class IMvdRegionFeatures
    {
    protected:
        explicit IMvdRegionFeatures() {}
        virtual ~IMvdRegionFeatures() {}
    public:
        /**
         * @brief 特征数量
         * @return 特征数量
         */
        virtual int GetFeatureNum() = 0;
        /**
         * @brief 面积信息
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual float GetArea(IN unsigned int nIndex) = 0;
        /**
         * @brief 最小外接正矩形
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual IMvdRectangleF* GetBoundingRect(IN unsigned int nIndex) = 0;
        /**
         * @brief 质心
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual MVD_POINT_F GetCentroid(IN unsigned int nIndex) = 0;
        /**
         * @brief 周长
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual float GetPerimeter(IN unsigned int nIndex) = 0 ;
        /**
         * @brief 最小外接矩形
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual IMvdRectangleF* GetMinAreaBoundingRect(IN unsigned int nIndex) = 0;
        /**
         * @brief 矩形度
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual float GetRectangularity(IN unsigned int nIndex) = 0;
        /**
         * @brief 质心与最小外接矩形中心的偏移距离
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual float GetCentroidBoxBias(IN unsigned int nIndex) = 0;
        /**
         * @brief 最大内接圆
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual IMvdCircleF* GetInnerCircle(IN unsigned int nIndex) = 0;
        /**
         * @brief 圆形度
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual float GetCircularity(IN unsigned int nIndex) = 0 ;
        /**
         * @brief 质心与最小外接圆中心的偏移距离
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual float GetCentroidCircleBias(IN unsigned int nIndex) = 0;
        /**
         * @brief 最小外接圆
         * @return 无，出错时抛出异常
         * @note 使用RegionFeatures使能计算对应特征后才可获取
         */
        virtual IMvdCircleF* GetOuterCircle(IN unsigned int nIndex) = 0;
    };

    // 轮廓
    class IMvdRegionContours
    {
    protected:
        explicit IMvdRegionContours() {}
        virtual ~IMvdRegionContours() {}
    public:
        /**
         * @brief 获取轮廓数量
         * @return 无，出错时抛出异常
         */
        virtual int GetContorNum() = 0;
        /**
         * @brief 获取单个轮廓
         * @return 无，出错时抛出异常
         */
        virtual IMvdPointSetF* GetContour(IN unsigned int nIndex) = 0;
    };
}

/*  Note:Interfaces to export.  */
#ifdef __cplusplus
extern "C" {
#endif

    MVD_CPP_API int __stdcall CreateRegionInstance(VisionDesigner::IMvdRegion** ppToolInstance);
    MVD_CPP_API int __stdcall DestroyRegionInstance(VisionDesigner::IMvdRegion* pToolInstance);


    MVD_CPP_API int __stdcall CreateRegionContoursInstance(VisionDesigner::IMvdRegionContours** ppToolInstance);
    MVD_CPP_API int __stdcall DestroyRegionContoursInstance(VisionDesigner::IMvdRegionContours* pToolInstance);

    MVD_CPP_API int __stdcall CreateRegionFeaturesInstance(VisionDesigner::IMvdRegionFeatures** ppToolInstance);
    MVD_CPP_API int __stdcall DestroyRegionFeaturesInstance(VisionDesigner::IMvdRegionFeatures* pToolInstance);

#ifdef __cplusplus
}
#endif 
 
#endif    ///< _REGION_CPP_H_