/***************************************************************************************************
* File:  MVDShapeCpp.h
* Note:  Interface definition of shape module.
*
* Version：4.2.0
* Date:  2021-01
****************************************************************************************************/
 
#ifndef _MVD_SHAPE_CPP_H_
#define _MVD_SHAPE_CPP_H_
 
#include "MVD_Export.h"
#include "MVD_ShapeParamDefine.h"
#include "MVD_ErrorDefine.h"
 
 
namespace VisionDesigner
{
    /* 图形基类，接口作用;e.g.各Tool支持不定的ROI类型 */
    class IMvdShape
    {
    //Constructor and Destructor
    protected:
        /*  note: Constructs a new instance of this class.  */
        explicit IMvdShape() {}
        /*  note: Constructs a new instance of this class as a deep copy of the given instance.  */
        virtual ~IMvdShape() {}
         
    public:
        virtual IMvdShape& operator=(const IMvdShape& refShape) { return *this;}
        virtual bool operator==(IMvdShape const& refShape) { return false; }
         
        //properties
    public:
		/**
		 * @brief 获取图形的类型
		 * @return 返回图形的类型
		 * @par 权限
		 * 只读
		 */
        /* Get current shape type. */
        virtual MVD_SHAPE_TYPE GetShapeType() const =0;
		/**
		 * @brief 获取图形的名字
		 * @return 返回图形的名字
		 * @par 权限
		 * 读写
		 * @note 若未命名形状，则返回UntitledName。
		 */
		/* note: Get name of this shape. Return "UntitledName" if you have not specified the name. */
        virtual const char* GetShapeName() const = 0;
		/**
		 * @brief 设置图形的名字
		 * @param pcName [IN] 图形的名字
		 * @par 权限
		 * 读写
		 * @note 若未命名形状，则返回UntitledName。
		 */
	    /* note: Set name of this shape. */
        virtual void SetShapeName(const char pcName[64]) = 0;
        /**
		 * @brief 获取图形边框宽度
		 * @return 返回图形边框宽度
		 * @par 权限
		 * 读写
		 */
        /* note: Get border width of this shape. */
		virtual unsigned int GetBorderWidth() const = 0;

		/**
		 * @brief 设置图形边框宽度
		 * @param nBorderWdith [IN] 边框宽度
		 * @par 权限
		 * 读写
		 */
        /* note: Set border width of this shape. */
		virtual void SetBorderWidth(unsigned int nBorderWdith) = 0;

		/**
		 * @brief 获取图形边框类型
		 * @return 返回图形边框类型
		 * @par 权限
		 * 读写
		 */
        /* note: Get border style of this shape. */
		virtual MVD_DASH_STYLE GetBorderStyle() const = 0;

		/**
		 * @brief 设置图形边框类型
		 * @param enBorderStyle [IN] 边框类型
		 * @par 权限
		 * 读写
		 */
        /* note: Set border style of this shape. */
		virtual void SetBorderStyle(MVD_DASH_STYLE enBorderStyle) = 0;

		/**
		 * @brief 获取图形边框颜色
		 * @return 返回图形边框颜色
		 * @par 权限
		 * 读写
		 */
        /* note: Get border color of this shape. */
		virtual MVD_COLOR GetBorderColor() const = 0;

		/**
		 * @brief 设置图形边框颜色
		 * @param enColor [IN] 边框颜色
		 * @par 权限
		 * 读写
		 */
        /* note: Set border color of this shape. */
		virtual void SetBorderColor(MVD_COLOR enColor) = 0;
		/**
		 * @brief 获取图形填充色
		 * @return 返回图形填充颜色
		 * @par 权限
		 * 读写
		 */
        /* note: Get the fill color of this shape. Whether to implement depends on the specific shape type. Not supported for non-closed shapes. */
        virtual MVD_COLOR GetFillColor() const;
		/**
		 * @brief 设置图形填充色
		 * @param enFillColor [IN] 填充颜色
		 * @par 权限
		 * 读写
		 */
        /* note: Set the fill color of this shape. Whether to implement depends on the specific shape type. Not supported for non-closed shapes. */
        virtual void SetFillColor(MVD_COLOR enFillColor);
        
        /**
		 * @brief 判断图形基本参数是否有效
		 * @par 权限
		 * 读写
		 */
		virtual bool IsValid() const = 0;

    };
    /* 图形基类扩展接口，接口作用;e.g.各Tool支持不定的ROI类型 */
    class IMvdShapeEx
    {
        //Constructor and Destructor
    protected:
        /*  note: Constructs a new instance of this class.  */
        explicit IMvdShapeEx() {}
        /*  note: Constructs a new instance of this class as a deep copy of the given instance.  */
        virtual ~IMvdShapeEx() {}
         
    public:
        virtual IMvdShapeEx& operator=(const IMvdShapeEx& refShape) { return *this;}
        virtual bool operator==(IMvdShapeEx const& refShape) { return false; }
         
        //properties
    public:
		/**
		* @brief 获取点到图形之间的距离
		* @param stPoint [IN] 点信息
		* @return 返回点到图形之间的距离
		* 读写
		* @note 目前仅支持线段和圆形
		*/
        /* note: Get the distance from the given point to this shape,only support line segment and circle. */
        virtual float Measure(MVD_POINT_F stPoint);
		/**
		* @brief 获取图形之间的距离
		* @param pstShape [IN] 图形实例
		* @return 返回图形之间的距离
		* @par 权限
		* 读写
		* @note 目前仅支持线段和圆形
		*/
        /* note: Get the distance from the given shape to this shape,only support line segment and circle. */
        virtual float Measure(IMvdShape* pstShape);
		/**
		* @brief 获取图形的外接矩形
		* @return 返回图形的外接矩形
		* @par 权限
		* 读写
		* @note 不支持文本图形
		*/
        /* note: Get the bounding rectangle of the given shape,text is not supported. */
        virtual MVD_RECT_F GetBoundingRect()const;
         
    };
    /* Class that represents a line segment. */
    class IMvdLineSegmentF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdLineSegmentF() {}
        explicit IMvdLineSegmentF(MVD_POINT_F stStartPoint, MVD_POINT_F stEndPoint) {}
        virtual ~IMvdLineSegmentF() {}

    public:
        virtual IMvdLineSegmentF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdLineSegmentF& operator=(const IMvdLineSegmentF& refLine) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdLineSegmentF const& refLine) { return false; }
         
    // Clone methods
    public:
        /**
         * @brief 克隆线段描述类对象
         * @param 无
         * @return 成功，返回线段描述类对象;失败，抛出异常。
         * @par 注解
         * 
         */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdLineSegmentF.Clone.*/
        virtual IMvdLineSegmentF* Clone() = 0;
         
    //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 读写
		*/
        /* Get current shape type. */
        MVD_SHAPE_TYPE GetShapeType() const { return MvdShapeLineSegment; }
		/**
		 * @brief 获取线段起点
		 * @return 返回线段起点
		 * @par 权限
		 * 读写
		 */
        /* note: Start point of this line. */
        virtual MVD_POINT_F GetStartPoint() const = 0;
		/**
		 * @brief 设置线段起点
		 * @param stStartPoint [IN] 线段起点
		 * @par 权限
		 * 读写
		 */
        virtual void SetStartPoint(MVD_POINT_F stStartPoint) = 0;
        /**
		 * @brief 获取线段终点
		 * @return 返回线段终点
		 * @par 权限
		 * 读写
		 */
		 /* note: End point of this line. */
		virtual MVD_POINT_F GetEndPoint() const = 0;

		/**
		 * @brief 设置线段终点
		 * @param stEndPoint [IN] 线段终点
		 * @par 权限
		 * 读写
		 */
		virtual void SetEndPoint(MVD_POINT_F stEndPoint) = 0;

		/**
		 * @brief 获取线段倾斜角度
		 * @return 返回线段倾斜角度
		 * @par 权限
		 * 只读
		 */
        /* note: Angle of this line((-180,180]). The Angle between the vector from the starting point to the end point and the positive X-axis. */
        virtual float GetAngle() = 0;
        /**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;

		 /**
		 * @brief 获取直线箭头类型
		 * @return 返回直线箭头类型
		 * @par 权限
		 * 读写
		 */
        virtual MVD_LINE_ARROW_TYPE GetLineArrowType() const = 0;

		/**
		 * @brief 设置直线箭头类型
		 * @param enArrowType [IN] 箭头类型
		 * @par 权限
		 * 读写
		 */
        virtual void SetLineArrowType(MVD_LINE_ARROW_TYPE enArrowType) = 0;

		/**
		 * @brief 设置是否显示贯穿线
		 * @param enThroughType [IN] 贯穿线类型
		 * @par 权限
		 * 读写
		 */
        virtual void SetLineThroughType(MVD_LINE_THROUGH_TYPE enThroughType) = 0;

		/**
		 * @brief 获取贯穿线类型
		 * @param enThroughType [IN] 贯穿线类型
		 * @par 权限
		 * 读写
		 */
        virtual MVD_LINE_THROUGH_TYPE GetLineThroughType() const = 0;
    };
     
    /* Class that represents a text. */
    class IMvdTextF : public IMvdShape,public IMvdShapeEx
    {
        //Constructor and Destructor
    protected:
        explicit IMvdTextF() {}
        explicit IMvdTextF(float fCenterX, float fCenterY,const char pcContent[MVD_TEXT_CONTENT_MAX_LEN]) {}
        virtual ~IMvdTextF() {}
         
    public:
        virtual IMvdTextF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdTextF& operator=(const IMvdTextF& refRect) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdTextF const& refRect) { return false; }
         
        // Clone methods
    public:
		/**
		* @brief 克隆文本描述类对象
		* @return 成功，返回文本描述类对象；失败，抛出异常。
		* @note 深拷贝一份当前类
		*/
        /* Returns a deep copy of this class instance. Derived classes that implement 
        Clone should override this method. Other clients who wish to clone this instance 
        should call IMvdTextF.Clone.*/
        virtual IMvdTextF* Clone() = 0;
         
        //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 读写
		*/
        /* Get current shape type. */
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeText;}
        /**
		* @brief 获取文本中心X坐标
		* @return 返回文本中心X坐标
		* @par 权限
		* 读写
		*/
		/* note: Center X coordinate of this text. */
		virtual float GetCenterX() const = 0;

		/**
		* @brief 设置文本中心X坐标
		* @param fCenterX [IN] 文本中心X坐标
		* @par 权限
		* 读写
		*/
		virtual void SetCenterX(float fCenterX) = 0;

		/**
		* @brief 获取文本中心Y坐标
		* @return 返回文本中心Y坐标
		* @par 权限
		* 读写
		*/
		/* note: Center Y coordinate of this text. */
		virtual float GetCenterY() const = 0;

		/**
		* @brief 设置文本中心Y坐标
		* @param fCenterY [IN] 文本中心Y坐标
		* @par 权限
		* 读写
		*/
		virtual void SetCenterY(float fCenterY) = 0;

		/**
		* @brief 获取字体宽度
		* @return 返回字体宽度
		* @par 权限
		* 读写
		*/
		/* note: Width of this text. */
		virtual unsigned int GetFontWidth() const = 0;

		/**
		* @brief 设置字体宽度
		* @param nWidth [IN] 字体宽度
		* @par 权限
		* 读写
		*/
		virtual void SetFontWidth(unsigned int nWidth) = 0;

		/**
		* @brief 获取字体类型
		* @param pcFaceName [OUT] 字体类型
		* @par 权限
		* 读写
		* @note 获取文本字体类型，如“Arial”，“宋体”等
		*/
		/* note: Face name of this text. */
		virtual void GetFontFaceName(char pcFaceName[MVD_TEXT_FONT_FACE_SIZE]) const = 0;

		/**
		* @brief 设置字体类型
		* @param pcFaceName [IN] 字体类型
		* @par 权限
		* 读写
		* @note 设置文本字体类型，如“Arial”，“宋体”等
		*/
		virtual void SetFontFaceName(const char pcFaceName[MVD_TEXT_FONT_FACE_SIZE]) = 0;

		/**
		* @brief 获取文本内容
		* @param pcContent [OUT] 文本内容
		* @par 权限
		* 读写
		*/
		virtual void GetContent(char pcContent[MVD_TEXT_CONTENT_MAX_LEN]) const = 0;

		/**
		* @brief 设置文本内容
		* @param pcContent [IN] 文本内容
		* @par 权限
		* 读写
		*/
		virtual void SetContent(const char pcContent[MVD_TEXT_CONTENT_MAX_LEN]) = 0;

		/**
		* @brief 获取文本角度，范围(-180,180]
		* @return 返回文本角度
		* @par 权限
		* 读写
		* @note 角度旋转顺时针为正，逆时针为负。
		*/
		/* note: Angle of this text((-180,180]). */
		virtual float GetAngle() = 0;

		/**
		* @brief 设置文本角度，范围(-180,180]
		* @param fAngle [IN] 文本角度，范围(-180,180]
		* @par 权限
		* 读写
		* @note 角度旋转顺时针为正，逆时针为负。
		*/
		virtual void SetAngle(float fAngle) = 0;

		/**
		* @brief 获取文本对齐方式
		* @return 返回文本对齐方式
		* @par 权限
		* 读写
		*/
		virtual MVD_TEXT_ALIGNMENT GetAlignment() = 0;

		/**
		* @brief 设置文本对齐方式
		* @param enAlignType [IN] 对齐方式
		* @par 权限
		* 读写
		*/
		virtual void SetAlignment(MVD_TEXT_ALIGNMENT enAlignType) = 0;

		/**
		* @brief 获取图形是否允许交互
		* @par 权限
		* 读写
		*/
		virtual bool GetInteraction() const= 0;

		/**
		* @brief 设置图形是否允许交互
		* @par 权限
		* 读写
		*/
		virtual void SetInteraction(bool bInteraction) = 0;

		/**
		* @brief 获取文本位置
		* @return 返回文本位置
		* @par 权限
		* 读写
		*/
		/* note: Position of this text. */
		virtual MVD_TEXT_POSITION GetPosition() const = 0;

		/**
		* @brief 设置文本位置
		* @param stPosition [IN] 文本角度
		* @par 权限
		* 读写
		*/
		virtual void SetPosition(MVD_TEXT_POSITION stPosition) = 0;
    };
    /* Class that represents a rectangle. */
    class IMvdRectangleF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdRectangleF() {}
        explicit IMvdRectangleF(float fCenterX, float fCenterY, float fWidth, float fHeight) {}
        virtual ~IMvdRectangleF() {}
         
    public:
        virtual IMvdRectangleF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdRectangleF& operator=(const IMvdRectangleF& refRect) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdRectangleF const& refRect) { return false; }
         
    // Clone methods
    public:
		/**
		 * @brief 克隆矩形描述类对象
		 * @return 成功，返回矩形描述类对象；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdRectangleF.Clone.*/
        virtual IMvdRectangleF* Clone() = 0;
         
    //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 读写
		*/
        /* Get current shape type. */
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeRectangle;}
        /**
		 * @brief 获取矩形中心X坐标
		 * @return 返回矩形中心X坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetCenterX() const = 0;

		 /**
		 * @brief 设置矩形中心X坐标
		 * @param fCenterX [IN] 矩形中心X坐标
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenterX(float fCenterX) = 0;

		 /**
		 * @brief 获取矩形中心Y坐标
		 * @return 返回矩形中心Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetCenterY() const = 0;

		 /**
		 * @brief 设置矩形中心Y坐标
		 * @param fCenterY [IN] 矩形中心Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenterY(float fCenterY) = 0;

		 /**
		 * @brief 获取矩形宽度
		 * @return 返回矩形宽度
		 * @par 权限
		 * 读写
		 */
		virtual float GetWidth() const = 0;

		 /**
		 * @brief 设置矩形宽度
		 * @param fWidth [IN] 矩形宽度
		 * @par 权限
		 * 读写
		 */
		virtual void SetWidth(float fWidth) = 0;

		 /**
		 * @brief 获取矩形高度
		 * @return 返回矩形高度
		 * @par 权限
		 * 读写
		 */
		virtual float GetHeight() const = 0;

		 /**
		 * @brief 设置矩形高度
		 * @param fHeight [IN] 矩形高度
		 * @par 权限
		 * 读写
		 */
		virtual void SetHeight(float fHeight) = 0;

		 /**
		 * @brief 获取矩形角度，范围(-180,180]
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
		virtual float GetAngle() = 0;

		 /**
		 * @brief 设置矩形角度，范围(-180,180]
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
		virtual void SetAngle(float fAngle) = 0;

		 /**
		 * @brief 获取矩形最小的X坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetMinimumX() = 0;

		 /**
		 * @brief 获取矩形最小的Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetMinimumY() = 0;

		 /**
		 * @brief 获取矩形左上角点的X坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetLeftTopX() = 0;

		 /**
		 * @brief 获取矩形左上角点的Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetLeftTopY() = 0;

		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;

		/**
		 * @brief 获取矩形箭头方向
		 * @return 返回矩形箭头方向
		 * @par 权限
		 * 读写
		 */
        virtual MVD_ARROW_DIRECTION GetArrowDirection() const = 0;

		/**
		 * @brief 设置矩形箭头方向
		 * @param enArrowType [IN] 矩形箭头方向
		 * @par 权限
		 * 读写
		 */
        virtual void SetArrowDirection(MVD_ARROW_DIRECTION enArrowType) = 0;
    };
     
    /* Class that represents a circle. */
    class IMvdCircleF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdCircleF() {}
        explicit IMvdCircleF(MVD_POINT_F stCenter, float fRadius) {}
        virtual ~IMvdCircleF() {}
         
    public:
        virtual IMvdCircleF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdCircleF& operator=(const IMvdCircleF& refCircle) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdCircleF const& refCircle) { return false; }
         
    // Clone methods
    public:
		/**
		 * @brief 克隆圆形描述类
		 * @return 成功，返回圆形描述类信息；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
         Clone should override this method. Other clients who wish to clone this instance 
         should call IMvdCircleF.Clone.*/
        virtual IMvdCircleF* Clone() = 0;
         
    //properties
    public:
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeCircle;}
        /**
		 * @brief 获取圆心
		 * @return 返回圆心
		 * @par 权限
		 * 读写
		 */
		virtual MVD_POINT_F GetCenter() const = 0;

		/**
		 * @brief 设置圆心
		 * @param stCenter [IN] 圆心
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenter(MVD_POINT_F stCenter) = 0;

		/**
		 * @brief 获取半径
		 * @return 返回半径
		 * @par 权限
		 * 读写
		 */
		virtual float GetRadius() const = 0;

		/**
		 * @brief 设置半径
		 * @param fRadius [IN] 半径
		 * @par 权限
		 * 读写
		 */
		virtual void SetRadius(float fRadius) = 0;

		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;
    };
     
    /* Class that represents a annular sector. */
    class IMvdAnnularSectorF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdAnnularSectorF() {}
        explicit IMvdAnnularSectorF(MVD_POINT_F stCenter, float fInnerRadius, float fOuterRadius, float fStartAngle, float fAngleRange) {}
        virtual ~IMvdAnnularSectorF() {}
         
    public:
        virtual IMvdAnnularSectorF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdAnnularSectorF& operator=(const IMvdAnnularSectorF& refAnnul) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdAnnularSectorF const& refAnnul) { return false; }
         
    //Clone methods
    public:
		/**
		 * @brief 克隆扇环描述类
		 * @return 成功，返回扇环描述类信息；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdAnnularSectorF.Clone.*/
        virtual IMvdAnnularSectorF* Clone() = 0;
         
    //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 读写
		*/
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeAnnularSector;}
         /**
		 * @brief 获取扇环中心
		 * @return 返回扇环中心
		 * @par 权限
		 * 读写
		 */
		virtual MVD_POINT_F GetCenter() const = 0;

		 /**
		 * @brief 设置扇环中心
		 * @param stCenter [IN] 扇环中心
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenter(MVD_POINT_F stCenter) = 0;

		 /**
		 * @brief 获取扇环内半径
		 * @return 返回扇环内半径
		 * @par 权限
		 * 读写
		 */
		virtual float GetInnerRadius() const = 0;

		 /**
		 * @brief 设置扇环内半径
		 * @param fInnerRadius [IN] 扇环内半径
		 * @par 权限
		 * 读写
		 */
		virtual void SetInnerRadius(float fInnerRadius) = 0;

		 /**
		 * @brief 获取扇环外半径
		 * @return 返回扇环外半径
		 * @par 权限
		 * 读写
		 */
		virtual float GetOuterRadius() const = 0;

		 /**
		 * @brief 设置扇环外半径
		 * @param fOuterRadius [IN] 扇环外半径
		 * @par 权限
		 * 读写
		 */
		virtual void SetOuterRadius(float fOuterRadius) = 0;

		 /**
		 * @brief 获取起始角度
		 * @return 返回起始角度
		 * @par 权限
		 * 读写
		 */
		virtual float GetStartAngle() const = 0;

		 /**
		 * @brief 设置起始角度
		 * @param fStartAngle [IN] 
		 * @par 权限
		 * 读写
		 */
		virtual void SetStartAngle(float fStartAngle) = 0;
		 /**
		 * @brief 获取角度范围
		 * @return 返回角度范围
		 * @par 权限
		 * 读写
		 */
		virtual float GetAngleRange() const = 0;

		 /**
		 * @brief 设置角度范围
		 * @param fAngleRange [IN] 
		 * @par 权限
		 * 读写
		 */
		virtual void SetAngleRange(float fAngleRange) = 0;

		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;

		/**
		 * @brief 设置内外径
         * @param fInnerRadius [IN] 扇环内半径
         * @param fOuterRadius [IN] 扇环外半径
		 * @par 权限
		 * 读写
		 */
		virtual void SetRadius(float fInnerRadius,float fOuterRadius) = 0;
    };
     
    /* Class that represents a parallelogram. */
    class IMvdParallelogramF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdParallelogramF() {}
        explicit IMvdParallelogramF(MVD_POINT_F stCenter, float fWSide, float fHSide, float fSkewAngle) {}
        virtual ~IMvdParallelogramF() {}
         
    public:
        virtual IMvdParallelogramF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdParallelogramF& operator=(const IMvdParallelogramF& refParal) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdParallelogramF const& refParal) { return false; }
         
    // Clone methods
    public:
		/**
		 * @brief 克隆平行四边形描述类
		 * @return 成功，返回平行四边形描述类信息；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdParallelogramF.Clone.*/
        virtual IMvdParallelogramF* Clone() = 0;
         
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 只读
		*/
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeParallelogram;}
         /**
		 * @brief 获取平行四边形中心
		 * @return 返回平行四边形中心
		 * @par 权限
		 * 读写
		 */
		virtual MVD_POINT_F GetCenter() const = 0;

		 /**
		 * @brief 设置平行四边形中心
		 * @param stCenter [IN] 平行四边形中心
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenter(MVD_POINT_F stCenter) = 0;

		 /**
		 * @brief 获取平行四边形宽的长度
		 * @return 返回平行四边形宽的长度
		 * @par 权限
		 * 读写
		 */
		virtual float GetWSide() const = 0;

		 /**
		 * @brief 设置平行四边形宽的长度
		 * @param fWSide [IN] 平行四边形宽的长度
		 * @par 权限
		 * 读写
		 */
		virtual void SetWSide(float fWSide) = 0;

		 /**
		 * @brief 获取平行四边形高的长度
		 * @return 返回平行四边形高的长度
		 * @par 权限
		 * 读写
		 */
		virtual float GetHSide() const = 0;

		 /**
		 * @brief 设置平行四边形高的长度
		 * @param fHSide [IN] 平行四边形高的长度
		 * @par 权限
		 * 读写
		 */
		virtual void SetHSide(float fHSide) = 0;

		 /**
		 * @brief 获取平行四边形相对于高方向的倾斜程度
		 * @return 返回平行四边形相对于高方向的倾斜程度
		 * @par 权限
		 * 读写
		 * @note 顺时针为正，逆时针为负，范围为[-90,90]
		 */
		virtual float GetSkewAngle() const = 0;

		/**
		 * @brief 设置平行四边形相对于高方向的倾斜程度
		 * @param fSkewAngle [IN] 平行四边形相对于高方向的倾斜程度
		 * @par 权限
		 * 读写
		 * @note 顺时针为正，逆时针为负，范围为[-90,90]
		 */
		virtual void SetSkewAngle(float fSkewAngle) = 0;

		/**
		 * @brief 获取角度，范围为(-180,180]
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
		virtual float GetAngle() = 0;

		/**
		 * @brief 设置角度，范围为(-180,180]
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
		virtual void SetAngle(float fAngle) = 0;

		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;
    };
     
    /* Class that represents a polygon consisting of multiple vertices. */
    class IMvdPolygonF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdPolygonF() {}
        virtual ~IMvdPolygonF() {}
         
    public:
        virtual IMvdPolygonF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdPolygonF& operator=(const IMvdPolygonF& refPoly) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdPolygonF const& refPoly) { return false; }
         
    public:
		/**
		 * @brief 克隆多边形描述类
		 * @return 成功，返回多边形描述类信息；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
        Clone should override this method. Other clients who wish to clone this instance 
        should call IMvdPolygonF.Clone.*/
        virtual IMvdPolygonF* Clone() = 0;
         
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 只读
		*/
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapePolygon;}
         /**
		 * @brief 获取多边形顶点数，上限为32个
		 * @return 返回多边形顶点数
		 * @par 权限
		 * 只读
		 */
		virtual unsigned int GetVertexNum() = 0;

		 /**
		 * @brief 添加顶点
		 * @param fX [IN] X坐标
		 * @param fY [IN] Y坐标
		 * @param nIndex [IN] 索引值，[0，VertexNum]
		 * @note 如果使用默认索引-1，则新顶点将添加到任何现有顶点的末端；否则，索引范围为[0，VertexNum]
		 */
		virtual void AddVertex(float fX, float fY, int nIndex = -1) = 0;

		 /**
		 * @brief 根据索引获取顶点坐标
		 * @param nIndex [IN] 索引值，[0，VertexNum）
		 * @param fX [OUT] X坐标
		 * @param fY [OUT] Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual void GetVertex(int nIndex, float& fX, float& fY ) = 0;

		 /**
		 * @brief 根据索引删除顶点
		 * @param nIndex [IN] 索引值，[0，VertexNum）
		 * @par 权限
		 * 读写
		 */
		virtual void RemoveVertex(int nIndex) = 0;

		 /**
		 * @brief 根据索引设置顶点坐标
		 * @param nIndex [IN] 索引值，[0，VertexNum）
		 * @param fX [IN] X坐标
		 * @param fY [IN] Y坐标
		 */
		virtual void SetVertex(int nIndex, float fX, float fY) = 0;

		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;

		/**
		* @brief 清除所有顶点
		* @par 权限
		* 读写
		*/
		virtual void ClearVertices() = 0;
         
    };
     
    /* Class that represents a set of multiple points. */
    class IMvdPointSetF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdPointSetF() {}
        virtual ~IMvdPointSetF() {}
         
    public:
        virtual IMvdPointSetF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdPointSetF& operator=(const IMvdPointSetF& refPtSet) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdPointSetF const& refPtSet) { return false; }
         
    public:
		/**
		 * @brief 克隆离散点集描述类
		 * @return 成功，返回离散点集描述类信息；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
        Clone should override this method. Other clients who wish to clone this instance 
        should call IMvdPointSetF.Clone.*/
        virtual IMvdPointSetF* Clone() = 0;
         
    //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 只读
		*/
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapePointSet;}
        /**
		 * @brief 获取点的数量
		 * @return 返回点的数量
		 * @par 权限
		 * 只读
		 */
		virtual unsigned int GetPointsNum() = 0;

		/**
		 * @brief 集合内添加点         
		 * @param fX [IN] X坐标
		 * @param fY [IN] Y坐标
		 * @param nIndex [IN] 索引值，[0,PointsNum）
		 * @note 如果使用默认索引-1，则新点将添加到现有点的末端；否则，索引设置范围为[0,PointsNum]
		 */
		virtual void AddPoint(float fX, float fY, int nIndex = -1) = 0;
		
		/**
		 * @brief 根据索引获取点坐标
		 * @param nIndex [IN] 索引值，[0,PointsNum）
		 * @param fX [OUT] X坐标
		 * @param fY [OUT] Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual void GetPoint(int nIndex, float& fX, float& fY ) = 0;

		/**
		 * @brief 根据索引从集合中移除点
		 * @param nIndex [IN] 索引值，[0,PointsNum）
		 */
		virtual void RemovePoint(int nIndex) = 0;

		/**
		 * @brief 根据索引设置点坐标
		 * @param nIndex [IN] 索引值，[0,PointsNum）
		 * @param fX [IN] X坐标
		 * @param fY [IN] Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual void SetPoint(int nIndex, float fX, float fY) = 0;

		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;

		/**
		* @brief 清除所有顶点
		* @par 权限
		* 读写
		*/
		virtual void ClearPoints() = 0;
    };
     
    /* Class that represents a polyline segment consisting of multiple turning points. */
    class IMvdPolylineSegmentF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdPolylineSegmentF() {}
        virtual ~IMvdPolylineSegmentF() {}
    public:
        virtual IMvdPolylineSegmentF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdPolylineSegmentF& operator=(const IMvdPolylineSegmentF& refPoly) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdPolylineSegmentF const& refPoly) { return false; }
         
    public:
		/**
		 * @brief 克隆折线段类实例
		 * @return 成功，返回折线段实例；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
        Clone should override this method. Other clients who wish to clone this instance 
        should call IMvdPolylineSegmentF.Clone.*/
        virtual IMvdPolylineSegmentF* Clone() = 0;
         
    //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 只读
		*/
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapePolylineSegment;}
         /**
		 * @brief 获取折线段顶点数
		 * @return 返回折线段顶点数
		 * @par 权限
		 * 只读
		 */
		virtual unsigned int GetVertexNum() = 0;

		/**
		 * @brief 添加顶点
		 * @param fX [IN] X坐标
		 * @param fY [IN] Y坐标
		 * @param nIndex [IN] 索引值，[0, VertexNum]
		 * @note 如果使用默认索引-1，则新顶点将添加到任何现有顶点的末端；否则按照索引插入，索引范围为[0,VertexNum]
		 */
		virtual void AddVertex(float fX, float fY, int nIndex = -1) = 0;

		 /**
		 * @brief 根据索引获取顶点的坐标
		 * @param nIndex [IN] 索引值，[0, VertexNum）
		 * @param fX [OUT] X坐标
		 * @param fY [OUT] Y坐标
		 */
		virtual void GetVertex(int nIndex, float& fX, float& fY ) = 0;

		 /**
		 * @brief 根据索引移除指定顶点
		 * @param nIndex [IN] 索引值，[0, VertexNum）
		 * @par 权限
		 * 读写
		 */
		virtual void RemoveVertex(int nIndex) = 0;

		 /**
		 * @brief 根据索引更新指定顶点的坐标
		 * @param nIndex [IN] 索引值，[0, VertexNum）
		 * @param fX [IN] X坐标
		 * @param fY [IN] Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual void SetVertex(int nIndex, float fX, float fY) = 0;

		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;

		/**
		* @brief 清除所有顶点
		* @par 权限
		* 读写
		*/
		virtual void ClearVertices() = 0;
    };

	    /* Class that represents a ellipse. */
    class IMvdEllipseF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdEllipseF() {}
        explicit IMvdEllipseF(MVD_POINT_F stCenter, float fMajorAxis,float fMinorAxis) {}
        virtual ~IMvdEllipseF() {}
         
    public:
        virtual IMvdEllipseF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdEllipseF& operator=(const IMvdEllipseF& refEllipse) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdEllipseF const& refEllipse) { return false; }
         
    // Clone methods
    public:
		/**
		 * @brief 克隆椭圆类实例
		 * @return 成功，返回椭圆实例；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdEllipseF.Clone.*/
        virtual IMvdEllipseF* Clone() = 0;
         
    //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 只读
		*/
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeEllipse;}
		 /**
		 * @brief 获取椭圆中心坐标
		 * @return 椭圆中心坐标
		 * @param nIndex [IN] 索引值，[0, VertexNum）
		 * @param fX [IN] X坐标
		 * @param fY [IN] Y坐标
		 * @par 权限
		 * 读写
		 */
        /* note: Center coordinate of this ellipse. */
        virtual MVD_POINT_F GetCenter() const = 0;
		 /**
		 * @brief 设置椭圆中心坐标
		 * @param stCenter [IN] 椭圆中心坐标
		 * @par 权限
		 * 读写
		 */
        virtual void SetCenter(MVD_POINT_F stCenter) = 0;
		 /**
		 * @brief 获取椭圆长轴
		 * @return 返回椭圆长轴
		 * @par 权限
		 * 读写
		 */
        virtual float GetMajorAxis() const = 0;
		 /**
		 * @brief 设置椭圆长轴
		 * @param fMajorAxis [IN] 椭圆长轴
		 * @par 权限
		 * 读写
		 */
        virtual void SetMajorAxis(float fMajorAxis) = 0;
		 /**
		 * @brief 获取椭圆短轴
		 * @return 返回椭圆短轴
		 * @par 权限
		 * 读写
		 */
        virtual float GetMinorAxis() const = 0;
		 /**
		 * @brief 设置椭圆短轴
		 * @param fMinorAxis [IN] 椭圆短轴
		 * @par 权限
		 * 读写
		 */
        virtual void SetMinorAxis(float fMinorAxis) = 0;
		 /**
		 * @brief 获取椭圆角度，范围(-180,180]
		 * @return 返回椭圆角度
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
        virtual float GetAngle() = 0;
		 /**
		 * @brief 设置椭圆角度
		 * @param fAngle [IN] 椭圆角度，范围(-180,180]
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
        virtual void SetAngle(float fAngle) = 0;       
		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
        virtual bool GetInteraction() = 0;
		/**
		 * @brief 设置图形是否允许交互
		 * @param bInteraction [IN] 是否允许交互
		 * @par 权限
		 * 读写
		 */
        virtual void SetInteraction(bool bInteraction) = 0;
    };

	    /* Class that represents a Line Caliper. */
    class IMvdLineCaliperF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdLineCaliperF() {}
        explicit IMvdLineCaliperF(MVD_POINT_F stStartPoint, MVD_POINT_F stEndPoint,float fCaliperWidth,float fCaliperHeight,int nCaliperCount) {}
        virtual ~IMvdLineCaliperF() {}

    public:
        virtual IMvdLineCaliperF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdLineCaliperF& operator=(const IMvdLineCaliperF& refLineCaliper) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdLineCaliperF const& refLineCaliper) { return false; }
         
    // Clone methods
    public:
		/**
		 * @brief 克隆直线卡尺描述类
		 * @return 成功，返回直线卡尺描述类信息；失败，抛出异常。
		 * @note 深拷贝一份当前类
		 */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdLineCaliperF.Clone.*/
        virtual IMvdLineCaliperF* Clone() = 0;
         
    //properties
    public:
		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 只读
		*/
        MVD_SHAPE_TYPE GetShapeType() const { return MvdShapeLineCaliper; }
		 /**
		 * @brief 获取直线卡尺起点
		 * @return 返回直线卡尺起点
		 * @par 权限
		 * 读写
		 */
        virtual MVD_POINT_F GetStartPoint() const = 0;
		/**
		 * @brief 设置直线卡尺起点
		 * @param stStartPoint [IN] 起点坐标
		 * @par 权限
		 * 读写
		 */
        virtual void SetStartPoint(MVD_POINT_F stStartPoint) = 0;
		 /**
		 * @brief 获取直线卡尺终点
		 * @return 返回直线卡尺终点
		 * @par 权限
		 * 读写
		 */
        virtual MVD_POINT_F GetEndPoint() const = 0;
		/**
		 * @brief 设置直线卡尺终点
		 * @param stEndPoint [IN] 终点坐标
		 * @par 权限
		 * 读写
		 */
        virtual void SetEndPoint(MVD_POINT_F stEndPoint) = 0;
        /**
		 * @brief 获取直线卡尺倾斜角度，范围(-180,180]
		 * @return 返回直线卡尺倾斜角度
		 * @par 权限
		 * 只读
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
		virtual float GetAngle() = 0;
		/**
		 * @brief 获取直线卡尺宽
		 * @return 返回直线卡尺宽
		 * @par 权限
		 * 读写
		 */
		virtual float GetCaliperWidth() const = 0;
		/**
		 * @brief 设置直线卡尺宽
		 * @param fWidth [IN] 直线卡尺宽
		 * @par 权限
		 * 读写
		 */
		virtual void SetCaliperWidth(float fWidth) = 0;
		/**
		 * @brief 获取直线卡尺高
		 * @return 返回直线卡尺高
		 * @par 权限
		 * 读写
		 */
		virtual float GetCaliperHeight() const = 0;
		/**
		 * @brief 设置直线卡尺高
		 * @param fHeight [IN] 直线卡尺高
		 * @par 权限
		 * 读写
		 */
		virtual void SetCaliperHeight(float fHeight) = 0;
		/**
		 * @brief 获取直线卡尺数量，范围(0,1000]
		 * @return 返回直线卡尺数量
		 * @par 权限
		 * 读写
		 */
		virtual int GetCaliperCount() const = 0;
		/**
		 * @brief 设置直线卡尺数量，范围(0,1000]
		 * @param nCount [IN] 直线卡尺数量
		 * @par 权限
		 * 读写
		 */
		virtual void SetCaliperCount(int nCount) = 0;
		/**
		 * @brief 获取卡尺中心点
		 * @param iIndex [IN] 卡尺索引
		 * @param stCenter [OUT] 卡尺中心点
		 * @par 权限
		 * 只读
		 */
		virtual void GetCaliperCenter(int iIndex, MVD_POINT_F &stCenter) const= 0;
		/**
		 * @brief 获取卡尺包围框中心X坐标
		 * @return 返回卡尺包围框中心X坐标
		 * @par 权限
		 * 只读
		 */
		virtual float GetBoundingBoxCenterX() const = 0;
		/**
		 * @brief 获取卡尺包围框中心Y坐标
		 * @return 返回卡尺包围框中心Y坐标
		 * @par 权限
		 * 只读
		 */
		virtual float GetBoundingBoxCenterY() const = 0;
		/**
		 * @brief 获取卡尺包围框宽
		 * @return 返回卡尺包围框宽
		 * @par 权限
		 * 只读
		 */
		virtual float GetBoundingBoxWidth() const = 0;
		/**
		 * @brief 获取卡尺包围框高
		 * @return 返回卡尺包围框高
		 * @par 权限
		 * 只读
		 */
		virtual float GetBoundingBoxHeight() const = 0;
		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @param bInteraction [IN] 是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;

		/**
		 * @brief 卡尺框是否渲染方向(带箭头)，与渲染控件配合使用
		 * @return 返回箭头方向
		 * 读写
		 */
		virtual MVD_ARROW_DIRECTION GetArrowDirection() const = 0;
		/**
		 * @brief 卡尺框是否渲染方向(带箭头)，与渲染控件配合使用
		 * @param enArrowDirection [IN] 箭头方向
		 * @par 权限
		 * 读写
		 */
		virtual void SetArrowDirection(MVD_ARROW_DIRECTION enArrowDirection) = 0;
    };

	/* Class that represents a sector caliper. */
    class IMvdSectorCaliperF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdSectorCaliperF() {}

        explicit IMvdSectorCaliperF(MVD_POINT_F stCenter, float fRadius, float fStartAngle, float fAngleRange,float fCaliperWidth,float fCaliperHeight,int nCaliperCount) {}
        virtual ~IMvdSectorCaliperF() {}
         
    public:
        virtual IMvdSectorCaliperF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdSectorCaliperF& operator=(const IMvdSectorCaliperF& refSectorCaliper) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdSectorCaliperF const& refSectorCaliper) { return false; }
         
    //Clone methods
    public:
        /**
         * @brief 克隆扇环卡尺描述类
         * @param 无
         * @return 成功，返回扇环卡尺描述类信息;失败，抛出异常。
         * @par 注解
         * 深拷贝一份当前类
         */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdSectorCaliperF.Clone.*/
        virtual IMvdSectorCaliperF* Clone() = 0;
         
    //properties
    public:
        /**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 读写
		*/
        /* Get current shape type. */
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeSectorCaliper;}
		 /**
		 * @brief 获取扇环卡尺中心
		 * @return 返回扇环卡尺中心
		 * @par 权限
		 * 读写
		 */
        virtual MVD_POINT_F GetCenter() const = 0;
		 /**
		 * @brief 设置扇环卡尺中心
		 * @param stCenter [IN] 扇环卡尺中心
		 * @par 权限
		 * 读写
		 */
        virtual void SetCenter(MVD_POINT_F stCenter) = 0;
		 /**
		 * @brief 获取扇环卡尺半径
		 * @return 返回扇环卡尺半径
		 * @par 权限
		 * 读写
		 */
        virtual float GetRadius() const = 0;
		 /**
		 * @brief 设置扇环卡尺半径
		 * @param fRadius [IN] 扇环卡尺半径
		 * @par 权限
		 * 读写
		 * @note 半径必须大于等于卡尺宽的一半。
		 */
        virtual void SetRadius(float fRadius) = 0;
		 /**
		 * @brief 获取起始角度，范围(-180,180] 
		 * @return 返回起始角度 
		 * @par 权限
		 * 读写
		 */
        virtual float GetStartAngle() const = 0;
		 /**
		 * @brief 设置起始角度
		 * @param fStartAngle [IN] 起始角度，(-180,180] 
		 * @par 权限
		 * 读写
		 */
        virtual void SetStartAngle(float fStartAngle) = 0;
		 /**
		 * @brief 获取角度范围，范围为(0,360]
		 * @return 返回角度范围
		 * @par 权限
		 * 读写
		 */
        virtual float GetAngleRange() const = 0;
		 /**
		 * @brief 设置角度范围
		 * @param fAngleRange [IN] 角度范围，(0,360]
		 * @par 权限
		 * 读写
		 */
        virtual void SetAngleRange(float fAngleRange) = 0;
		
		 /**
		 * @brief 获取卡尺框倾斜角度，范围为(-180,180]
		 * @param iIndex [IN] 卡尺框索引
		 * @return 返回卡尺框倾斜角度
		 * @par 权限
		 * 读写
		 */
        virtual float GetCaliperAngle(int iIndex) = 0;
		/**
		 * @brief 获取扇环卡尺宽
		 * @return 返回扇环卡尺宽
		 * @par 权限
		 * 读写
		 */
        virtual float GetCaliperWidth() const = 0;
		/**
		 * @brief 设置扇环卡尺宽
		 * @param fWidth [IN] 扇环卡尺宽
		 * @par 权限
		 * 读写
		 */
        virtual void SetCaliperWidth(float fWidth) = 0;
		/**
		 * @brief 获取扇环卡尺高
		 * @return 返回扇环卡尺高
		 * @par 权限
		 * 读写
		 */
        virtual float GetCaliperHeight() const = 0;
		/**
		 * @brief 设置扇环卡尺高
		 * @param fHeight [IN] 扇环卡尺高
		 * @par 权限
		 * 读写
		 */
        virtual void SetCaliperHeight(float fHeight) = 0;
		/**
		 * @brief 获取扇环卡尺数量，范围(0,1000]
		 * @return 返回扇环卡尺数量
		 * @par 权限
		 * 读写
		 */
        virtual int GetCaliperCount() const = 0;
		/**
		 * @brief 设置扇环卡尺数量，范围(0,1000]
		 * @param nCount [IN] 扇环卡尺数量
		 * @par 权限
		 * 读写
		 */
        virtual void SetCaliperCount(int nCount) = 0;
		/**
		 * @brief 获取卡尺中心点
		 * @param iIndex [IN] 卡尺索引
		 * @param stCenter [OUT] 卡尺中心点
		 * @par 权限
		 * 只读
		 */
        virtual void GetCaliperCenter(int iIndex, MVD_POINT_F &stCenter) = 0;
		
		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
        virtual bool GetInteraction() = 0;
		/**
		 * @brief 设置图形是否允许交互
		 * @param bInteraction [IN] 是否允许交互
		 * @par 权限
		 * 读写
		 */
        virtual void SetInteraction(bool bInteraction) = 0;

		/**
		 * @brief 卡尺框是否渲染方向(带箭头)，与渲染控件配合使用
		 * @return 返回箭头方向
		 * @par 权限
		 * 只读
		 */
		virtual MVD_SECTORCALIPER_ARROW_DIRECTION GetArrowDirection() const = 0;
		/**
		 * @brief 卡尺框是否渲染方向(带箭头)，与渲染控件配合使用
		 * @param enArrowDirection [IN] 箭头方向
		 * @par 权限
		 * 读写
		 */
		virtual void SetArrowDirection(MVD_SECTORCALIPER_ARROW_DIRECTION enArrowDirection) = 0;

    };

	class IMvdCrossF : public IMvdShape,public IMvdShapeEx
	{
	protected:
		explicit IMvdCrossF() {}
		virtual ~IMvdCrossF() {}

	public:
		virtual IMvdCrossF& operator=(const IMvdShape& refShape) { return *this; }
		virtual IMvdCrossF& operator=(const IMvdCrossF& refPtSet) { return *this; }
		virtual bool operator==(IMvdShape const& refShape) { return false; }
		virtual bool operator==(IMvdCrossF const& refPtSet) { return false; }

		// Clone methods
	public:
		/**
		* @brief 克隆十字图形描述类对象
		* @param 无
		* @return 成功，返回十字图形描述类对象;失败，抛出异常。
		* @par 注解
		* 
		*/
		virtual IMvdCrossF* Clone() = 0;
	public:

		/**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 只读
		*/
		MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeCross;}

        /**
		 * @brief 获取十字中心
		 * @return 返回十字中心
		 * @par 权限
		 * 读写
		 */
		virtual MVD_POINT_F GetCenter() const = 0;
        /**
		 * @brief 设置十字中心
		 * @param stCenter [IN] 十字中心
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenter(MVD_POINT_F stCenter) = 0;

        /**
		 * @brief 获取十字大小（单边长度）
		 * @return 返回十字大小
		 * @par 权限
		 * 读写
		 */
		virtual float GetCrossSize() const = 0;
		/**
		 * @brief 设置十字大小
		 * @param fSize [IN] 十字大小
		 * @par 权限
		 * 读写
		 */
		virtual void SetCrossSize(float fSize) = 0;

        /**
		 * @brief 获取十字角度（两边夹角）
		 * @return 返回十字角度
		 * @par 权限
		 * 读写
		 */
		virtual float GetCrossAngle() const = 0;
	
		/**
		 * @brief 设置十字角度
		 * @param fSize [IN] 十字角度
		 * @par 权限
		 * 读写
		 */
		virtual void SetCrossAngle(float fAngle)  = 0;
		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @param bInteraction [IN] 是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;
	};

	/*坐标系*/
     class IMvdCoordinateF : public IMvdShape,public IMvdShapeEx
    {
    //Constructor and Destructor
    protected:
        explicit IMvdCoordinateF() {}
        explicit IMvdCoordinateF(float fCenterX, float fCenterY, float fWidth, float fHeight) {}
        virtual ~IMvdCoordinateF() {}
         
    public:
        virtual IMvdCoordinateF& operator=(const IMvdShape& refShape) { return *this; }
        virtual IMvdCoordinateF& operator=(const IMvdCoordinateF& refCoordinate) { return *this; }
        virtual bool operator==(IMvdShape const& refShape) { return false; }
        virtual bool operator==(IMvdCoordinateF const& refCoordinate) { return false; }
         
    // Clone methods
    public:
        /**
         * @brief 克隆坐标系描述类对象
         * @param 无
         * @return 成功，返回矩形描述类对象;失败，抛出异常。
         * @par 注解
         * 
         */
        /* Returns a deep copy of this class instance. Derived classes that implement 
           Clone should override this method. Other clients who wish to clone this instance 
            should call IMvdCoordinateF.Clone.*/
        virtual IMvdCoordinateF* Clone() = 0;
         
    //properties
    public:
        /**
		* @brief 获取当前图形类型
		* @return 当前图形类型
		* @par 权限
		* 读写
		*/
        /* Get current shape type. */
        MVD_SHAPE_TYPE GetShapeType() const {return MvdShapeCoordinate;}
		 /**
		 * @brief 获取坐标系中心X坐标
		 * @return 返回坐标系中心X坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetCenterX() const = 0;
		 /**
		 * @brief 设置坐标系中心X坐标
		 * @param fCenterX [IN] 坐标系中心X坐标
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenterX(float fCenterX) = 0;
		 /**
		 * @brief 获取坐标系中心Y坐标
		 * @return 返回坐标系中心Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual float GetCenterY() const = 0;

		 /**
		 * @brief 设置坐标系中心Y坐标
		 * @param fCenterY [IN] 坐标系中心Y坐标
		 * @par 权限
		 * 读写
		 */
		virtual void SetCenterY(float fCenterY) = 0;
		 /**
		 * @brief 获取X轴长度
		 * @return 返回X轴长度
		 * @par 权限
		 * 读写
		 */
		virtual float GetLengthXAxis() const = 0;
		 /**
		 * @brief 设置X轴长度
		 * @param fLengthXAxis [IN] X轴长度
		 * @par 权限
		 * 读写
		 */
		virtual void SetLengthXAxis(float fLengthXAxis) = 0;
		 /**
		 * @brief 获取Y轴长度
		 * @return 返回Y轴长度
		 * @par 权限
		 * 读写
		 */
		virtual float GetLengthYAxis() const = 0;
		 /**
		 * @brief 设置Y轴长度
		 * @param fLengthYAxis [IN] Y轴长度
		 * @par 权限
		 * 读写
		 */
		virtual void SetLengthYAxis(float fLengthYAxis) = 0;

		 /**
		 * @brief 获取坐标系角度
		 * @return 返回坐标系角度
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
		virtual float GetAngle() = 0;
		 /**
		 * @brief 设置坐标系角度
		 * @param fAngle [IN] 角度，范围(-180,180]
		 * @par 权限
		 * 读写
		 * @note 角度旋转顺时针为正，逆时针为负。
		 */
		virtual void SetAngle(float fAngle) = 0;
			 
		 /**
		 * @brief 设置箭头大小
		 * @param fLength [IN] 设置箭头大小
		 * @par 权限
		 * 读写
		 */
		virtual void SetArrowLength(float flength) = 0;

		 /**
		 * @brief 获取箭头大小
		 * @return 返回箭头大小
		 * @par 权限
		 * 读写
		 */
		virtual float GetArrowLength() = 0;


		/**
		 * @brief 获取图形是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual bool GetInteraction() = 0;

		/**
		 * @brief 设置图形是否允许交互
		 * @param bInteraction [IN] 是否允许交互
		 * @par 权限
		 * 读写
		 */
		virtual void SetInteraction(bool bInteraction) = 0;
    };
}
  
/*  note:Interfaces to export.  */
#ifdef __cplusplus
extern "C" {
#endif
     
    /* note: Create instance of IMvdLineSegmentF. */
    MVD_CPP_API int __stdcall CreateLineSegmentInstance(VisionDesigner::IMvdLineSegmentF** ppLineInstance, VisionDesigner::MVD_POINT_F stStartPoint, VisionDesigner::MVD_POINT_F stEndPoint);
    /* note: Destroy instance of IMvdLineSegmentF. */
    MVD_CPP_API int __stdcall DestroyLineSegmentInstance(VisionDesigner::IMvdLineSegmentF* pLineInstance);
     
    /* note: Create instance of IMvdRectangleF. */
    MVD_CPP_API int __stdcall CreateRectangleInstance(VisionDesigner::IMvdRectangleF** ppRectInstance, float fCenterX, float fCenterY, float fWidth, float fHeight);
    /* note: Destroy instance of IMvdRectangleF. */
    MVD_CPP_API int __stdcall DestroyRectangleInstance(VisionDesigner::IMvdRectangleF* pRectInstance);
     
    /* note: Create instance of IMvdCircleF. */
    MVD_CPP_API int __stdcall CreateCircleInstance(VisionDesigner::IMvdCircleF** ppCircleInstance, VisionDesigner::MVD_POINT_F stCenter, float fRadius);
    /* note: Destroy instance of IMvdCircleF. */
    MVD_CPP_API int __stdcall DestroyCircleInstance(VisionDesigner::IMvdCircleF* pCircleInstance);
     
    /* note: Create instance of IMvdAnnularSectorF. */
    MVD_CPP_API int __stdcall CreateAnnularSectorInstance(VisionDesigner::IMvdAnnularSectorF** ppAnnularSectorInstance, VisionDesigner::MVD_POINT_F stCenter, float fInnerRadius, float fOuterRadius, float fStartAngle, float fAngleRange);
    /* note: Destroy instance of IMvdAnnularSectorF. */
    MVD_CPP_API int __stdcall DestroyAnnularSectorInstance(VisionDesigner::IMvdAnnularSectorF* pAnnularSectorInstance);
     
    /* note: Create instance of IMvdParallelogramF. */
    MVD_CPP_API int __stdcall CreateParallelogramInstance(VisionDesigner::IMvdParallelogramF** ppParallelogramInstance, VisionDesigner::MVD_POINT_F stCenter, float fWSide, float fHSide, float fSkewAngle);
    /* note: Destroy instance of IMvdParallelogramF. */
    MVD_CPP_API int __stdcall DestroyParallelogramInstance(VisionDesigner::IMvdParallelogramF* pParallelogramInstance);
     
    /* note: Create instance of IMvdPolygonF. */
    MVD_CPP_API int __stdcall CreatePolygonInstance(VisionDesigner::IMvdPolygonF** ppPolygonInstance);
    /* note: Destroy instance of IMvdPolygonF. */
    MVD_CPP_API int __stdcall DestroyPolygonInstance(VisionDesigner::IMvdPolygonF* pPolygonInstance);
     
    /* note: Create instance of IMvdPointSetF. */
    MVD_CPP_API int __stdcall CreatePointSetInstance(VisionDesigner::IMvdPointSetF** ppPointSetInstance);
    /* note: Destroy instance of IMvdPointSetF. */
    MVD_CPP_API int __stdcall DestroyPointSetInstance(VisionDesigner::IMvdPointSetF* pPointSetInstance);
     
    /* note: Create instance of IMvdPolylineSegmentF. */
    MVD_CPP_API int __stdcall CreatePolylineSegmentInstance(VisionDesigner::IMvdPolylineSegmentF** ppPolylineInstance);
    /* note: Destroy instance of IMvdPolylineSegmentF. */
    MVD_CPP_API int __stdcall DestroyPolylineSegmentInstance(VisionDesigner::IMvdPolylineSegmentF* pPolylineInstance);
     
    /* note: Create instance of IMvdTextF. */
    MVD_CPP_API int __stdcall CreateTextInstance(VisionDesigner::IMvdTextF** ppTextInstance, float fCenterX, float fCenterY, const char pcContent[MVD_TEXT_CONTENT_MAX_LEN]);
    /* note: Destroy instance of IMvdTextF. */
    MVD_CPP_API int __stdcall DestroyTextInstance(VisionDesigner::IMvdTextF* pTextInstance);
     
    /* note: Create instance of IMvdTextF. */
    MVD_CPP_API int __stdcall CreateTextInstanceEx(VisionDesigner::IMvdTextF** ppTextInstance, float fX, float fY, VisionDesigner::MVD_TEXT_POSITION_TYPE enType, const char pcContent[MVD_TEXT_CONTENT_MAX_LEN]);
    /* note: Destroy instance of IMvdTextF. */
    MVD_CPP_API int __stdcall DestroyTextInstanceEx(VisionDesigner::IMvdTextF* pTextInstance);

  
	/* note: Create instance of IMvdEllipseF. */
	MVD_CPP_API int __stdcall CreateEllipseInstance(VisionDesigner::IMvdEllipseF** ppEllipseInstance, VisionDesigner::MVD_POINT_F stCenter, float fMajorAxis,float fMinorAxis);
	/* note: Destroy instance of IMvdEllipseF. */
	MVD_CPP_API int __stdcall DestroyEllipseInstance(VisionDesigner::IMvdEllipseF* pEllipseInstance);

	/* note: Create instance of IMvdLineCaliperF. */
	MVD_CPP_API int __stdcall CreateLineCaliperInstance(VisionDesigner::IMvdLineCaliperF** ppLineCaliperInstance);
	/* note: Destroy instance of IMvdLineCaliperF. */
	MVD_CPP_API int __stdcall DestroyLineCaliperInstance(VisionDesigner::IMvdLineCaliperF* pLineCaliperInstance);

	/* note: Create instance of IMvdSectorCaliperF. */
	MVD_CPP_API int __stdcall CreateSectorCaliperInstance(VisionDesigner::IMvdSectorCaliperF** ppSectorCaliperInstance);
	/* note: Destroy instance of IMvdSectorCaliperF. */
	MVD_CPP_API int __stdcall DestroySectorCaliperInstance(VisionDesigner::IMvdSectorCaliperF* pSectorCaliperInstance);

	/* note: Create instance of IMvdCrossF. */
	MVD_CPP_API int __stdcall CreateCrossInstance(VisionDesigner::IMvdCrossF** ppCrossInstance, VisionDesigner::MVD_POINT_F stCenter, float fCrossSize = 25, float fAngle = 0);
	/* note: Destroy instance of IMvdCrossF. */
	MVD_CPP_API int __stdcall DestroyCrossInstance(VisionDesigner::IMvdCrossF* pCrossInstance);
	
	MVD_CPP_API int __stdcall CreateCoordinateInstance(VisionDesigner::IMvdCoordinateF** ppInstance, float fCenterX, float fCenterY, float fLengthXAxis, float fLengthYAxis);

    MVD_CPP_API int __stdcall DestroyCoordinateInstance(VisionDesigner::IMvdCoordinateF* pInstance);
  
    /* note: Destroy instance of IMvdShape. */
    MVD_CPP_API int __stdcall DestroyShapeInstance(VisionDesigner::IMvdShape* pShapeInstance);
     
#ifdef __cplusplus
}
#endif 
 
 
#endif    ///<_MVD_SHAPE_CPP_H_
