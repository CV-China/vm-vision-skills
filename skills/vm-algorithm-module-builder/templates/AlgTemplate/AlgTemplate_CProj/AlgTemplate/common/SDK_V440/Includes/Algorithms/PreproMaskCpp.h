/***************************************************************************************************
* File：PreproMaskCpp.h
* Note：掩膜算子接口类.
***************************************************************************************************/
#ifndef _PREPRO_MASK_CPP_H_
#define _PREPRO_MASK_CPP_H_

#include <string>
#include "MVDImageCpp.h"
#include "MVDShapeCpp.h"
#include "MVD_AlgoParamDefine.h"

namespace VisionDesigner
{
	namespace PreproMask
    {
		typedef _MVD_REGION_TYPE__  MVD_REGION_TYPE;
        ///工具类，封装了掩膜预处理的分析过程，内嵌相关类。
        class IPreproMaskTool
        {
        protected:
            ///< Constructor and Destructor
            explicit IPreproMaskTool() {}
            virtual ~IPreproMaskTool() {}
             
        public:
            /**
             * @brief 获取输入图像，默认值NULL
             * @par 权限
             * 读写
             */
            virtual IMvdImage* GetInputImage() = 0;
            /**
             * @brief 设置输入图像
             * @param pInputImage [IN] 输入图像
             * @par 权限
             * 读写
             */
            virtual void SetInputImage(IMvdImage *pInputImage) = 0;
            /**
             * @brief 获取结果图像，默认值NULL
             * @par 权限
             * 只读
             */
            virtual IMvdImage* GetOutputImage() = 0;
            /**
             * @brief 执行算子处理
             * @return 无，出错时抛出异常
             */
            virtual void Run() = 0;

            /**
             * @brief 添加单个区域
             * @param pRegion [IN] 拟增加的区域范围图形
             * @param bRegionInterest [IN] 该区域的保留\屏蔽属性；设true时为感兴趣区域，否则为屏蔽区域
             * @return 无，出错时抛出异常
             * @note 仅支持矩形、圆、扇环和多边形
             */
             virtual void AddRegion(IMvdShape* pRegion, bool bRegionInterest) = 0;
            /**
             * @brief 获取已添加区域数量
             * @return 区域图形数量；出错时抛出异常
             */
            virtual unsigned int GetNumOfRegions() = 0;
            /**
             * @brief 根据索引查询已添加区域图形信息
             * @param nIndex [IN] 图形索引，范围[0, NumOfRegions)
             * @param ppRegion [IN][OUT] 该区域图形信息
             * @param pRegionInterest [IN][OUT] 该区域的保留\屏蔽属性
             * @return 无，出错时抛出异常
             * @note ppRegion指向内部该图形实例，内部buffer
             */
            virtual void GetRegionAt(unsigned int nIndex, IMvdShape** ppRegion, bool* pRegionInterest) = 0;
            /**
             * @brief 根据索引更新已添加区域图形信息
             * @param nIndex [IN] 图形索引，范围[0, NumOfRegions)
             * @param pRegion [IN] 拟更新为的区域图形信息
             * @param bRegionInterest [IN] 该区域的保留\屏蔽属性；设true时为感兴趣区域，否则为屏蔽区域
             * @return 无，出错时抛出异常
             * @note 支持修改图形类型
             */
            virtual void UpdateRegionAt(unsigned int nIndex, IMvdShape* pRegion, bool bRegionInterest) = 0;
            /**
             * @brief 根据索引移除已添加区域图形
             * @param nIndex [IN] 图形索引，范围[0, NumOfRegions)
             * @return 无，出错时抛出异常
             */
            virtual void RemoveRegionAt(unsigned int nIndex) = 0;
            /**
             * @brief 清理所有已添加区域
             * @return 无，出错时抛出异常
             */
            virtual void ClearRegions() = 0;
            /**
            * @brief 获取掩膜图像，默认值NULL
            * @par 权限
            * 读写
            */
            virtual IMvdImage* GetMaskImage() = 0;
            /**
            * @brief 设置掩膜图像，如果设置有效值，将在此基础上叠加图形计算输出图像
            * @param pMaskImage [IN] 掩膜图像
            * @par 权限
            * 读写
            */
            virtual void SetMaskImage(IMvdImage *pMaskImage) = 0;
             /**
             * @brief 释放结果缓存，在此操作之后不能再次调用该对象获取结果信息
             * @param 无
             * @return 无，出错时抛出异常
             * @par 注解
             * 无
             *
             */
            /* note: Release result cache to save memory, after this operation you should not use this object to obtain results again */
            virtual void Clear() = 0;

			/**
             * @brief 添加单个区域
             * @param pRegion [IN] 拟增加的区域范围图形
             * @param bRegionInterest [IN] 该区域的保留\屏蔽\增强属性;设MVD_REGION_TYPE_ROI时为感兴趣区域，MVD_REGION_TYPE_MASK为屏蔽区域，MVD_REGION_TYPE_ENHANCE为增强区域
             * @return 无，出错时抛出异常
             * @par 注解
             * 仅支持矩形、圆、扇环和多边形
             */
             virtual void AddRegionEx(IMvdShape* pRegion, MVD_REGION_TYPE emRegionType) = 0;

            /**
             * @brief 根据索引查询已添加区域图形信息
             * @param nIndex [IN] 图形索引，范围[0, NumOfRegions)
             * @param ppRegion [IN][OUT] 该区域图形信息
             * @param pRegionInterest [IN][OUT] 该区域的保留\屏蔽\增强属性
             * @return 无，出错时抛出异常
             * @par 注解
             * ppRegion指向内部该图形实例,内部buffer
             */

            virtual void GetRegionExAt(unsigned int nIndex, IMvdShape** ppRegion, MVD_REGION_TYPE* emRegionType) = 0;
            /**
             * @brief 根据索引更新已添加区域图形信息
             * @param nIndex [IN] 图形索引，范围[0, NumOfRegions)
             * @param pRegion [IN] 拟更新为的区域图形信息
             * @param bRegionInterest [IN] 该区域的保留\屏蔽\增强属性;设MVD_REGION_TYPE_ROI时为感兴趣区域，MVD_REGION_TYPE_MASK为屏蔽区域，MVD_REGION_TYPE_ENHANCE为增强区域
             * @return 无，出错时抛出异常
             * @par 注解
             * 支持修改图形类型
             */
            virtual void UpdateRegionExAt(unsigned int nIndex, IMvdShape* pRegion, MVD_REGION_TYPE emRegionType) = 0;
            /**
             * @brief 设置输入图像尺寸
             * @param nWidth [IN] 输入图像宽
             * @param nHeight [IN] 输入图像高
             * @par 权限
             * 读写
             */
            virtual void SetInputImageSize(unsigned int nWidth,unsigned int nHeight) = 0;
            /**
             * @brief 获取输入图像宽，默认0
             * @par 权限
             * 读写
             */
            virtual unsigned int GetInputImageWidth() = 0;
            /**
             * @brief 获取输入图像高，默认0
             * @par 权限
             * 读写
             */
            virtual unsigned int GetInputImageHeight() = 0;
			 /**
             * @brief 获取ROI颜色状态
             */
			virtual bool  GetColorStatus()=0;
			 /**
             * @brief 设置ROI颜色状态
			 * @param bStatus [IN] ROI颜色状态 ，根据RoiInnerStatus，设置false为ROI内是255，外部是0，设置true为ROI内是0，外部是255，默认为false
             */
			virtual void  SetColorStatus(bool bStatus)=0;
			 /**
             * @brief 获取是否使用输入图数据
             */
			virtual bool  GetUseInputImage()=0;
			 /**
             * @brief 设置是否使用输入图数据
			 * @param 设置false为不使用，设置true为使用，默认为false
             */
			virtual void  SetUseInputImage(bool bStatus)=0;
			 /**
             * @brief 设置ROI内外状态
			 * @param 设置false为外，true为内，默认为内
             */
            virtual void SetRoiInnerStatus(bool bStatus) = 0;
             /**
             * @brief 获取ROI内外状态
			 * @param 
             */
            virtual bool GetRoiInnerStatus() = 0;
        private:
            IPreproMaskTool(IPreproMaskTool&);
            IPreproMaskTool& operator=(IPreproMaskTool&);
        };
    }
}
 
 
/*  Note:Interfaces to export.  */
#ifdef __cplusplus
extern "C" {
#endif

	///创建掩膜预处理算子工具实例
    MVD_CPP_API int __stdcall CreatePreproMaskToolInstance(VisionDesigner::PreproMask::IPreproMaskTool** ppToolInstance);
	///销毁掩膜预处理算子工具实例
    MVD_CPP_API int __stdcall DestroyPreproMaskToolInstance(VisionDesigner::PreproMask::IPreproMaskTool* pToolInstance);

#ifdef __cplusplus
}
#endif 
 
 
#endif    ///< _PREPRO_MASK_CPP_H_
