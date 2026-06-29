#ifdef EXAMPLEMODULE_EXPORTS
#define LINEMODULE_API __declspec(dllexport)
#else
#define LINEMODULE_API __declspec(dllimport)
#endif
#include "VmModuleBase.h"
#include "VmAlgModuBase.h"
#include "ErrorCodeDefine.h"
#include "VmModuleSharedMemoryBase.h"

#include <sstream>
#include <iomanip>

#define  M_PI 3.14159265358979323846
#define  MVD_CHAR_LABEL_MAX_NUM (1024)
#define GET_VARIABLE_NAME(var) #var

struct RoiboxData {
    float CenterX;
    float CenterY;
    float Width;
    float Height;
    float Angle;
    RoiboxData(float x = 0, float y = 0, float w = 0, float h = 0, float a = 0) :CenterX(x), CenterY(y), Width(w), Height(h), Angle(a) {}
};

struct PointData {
    float X;
    float Y;
    PointData(float x = 0, float y = 0) :X(x), Y(y) {}
};

struct LineData {
    PointData StartPoint;
    PointData EndPoint;
    LineData() : StartPoint(), EndPoint() {}
};

double MyMilliseconds()
{
#ifdef WIN32
    LARGE_INTEGER ticks;
    QueryPerformanceCounter(&ticks);
    LARGE_INTEGER resolution;
    QueryPerformanceFrequency(&resolution);
    double dticks = (double)ticks.QuadPart;
    double dresolution = (double)resolution.QuadPart;
    return dticks / dresolution * 1000.0;
#else
    return 0.0;
#endif
}

// This class is exported from the LineModule.dll
class LINEMODULE_API CAlgorithmModule : public CVmAlgModuleBase, public CModuleSharedMemoryBase
{
public:
	// 构造
	explicit CAlgorithmModule();
	
	// 析构
	virtual ~CAlgorithmModule();

public:

	// 初始化
	int Init();

	// 版本1：进行算法
	int Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input);
    // 版本2：不带 modu_input 参数（当 selectedInputImage 为 false 时生成）
    int Process(IN void* hInput, IN void* hOutput);
	// 获取算法参数
	int GetParam(IN const char* szParamName, OUT char* pBuff, IN int nBuffSize, OUT int* pDataLen);

	// 设置算法参数
	int SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen);

    // 辅助函数定义START
    // 辅助函数定义END

public:
	//void* m_hModule;   // 模块句柄 - 4.3 在基类中定义了


private:
    // 算法参数（运行参数）声明START
    // 算法参数（运行参数）声明END

};


/////////////////////////////模块须导出的接口（实现开始）//////////////////////////////////////////
#ifdef __cplusplus
extern "C"
{
#endif
    
    // 采用__stdcall调用约定，且须在.def文件中增加接口描述。
	LINEMODULE_API CAbstractUserModule* __stdcall CreateModule(void* hModule);
	LINEMODULE_API void __stdcall DestroyModule(void* hModule, CAbstractUserModule* pUserModule);

#ifdef __cplusplus
};
#endif
/////////////////////////////模块须导出的接口（实现结束）//////////////////////////////////////////
