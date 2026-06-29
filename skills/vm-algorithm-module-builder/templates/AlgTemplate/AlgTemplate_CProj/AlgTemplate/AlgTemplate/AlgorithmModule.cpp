#include "stdafx.h"
#include "AlgorithmModule.h"
#include <stdlib.h>
#include <fstream>
#include "ErrorCodeDefine.h"
#include "iMVS-6000PixelFormatDefine.h"

// 辅助函数START
// 辅助函数END

CAlgorithmModule::CAlgorithmModule()
{
	// 算法参数（运行参数）初始化START
	// 算法参数（运行参数）初始化END
}

CAlgorithmModule::~CAlgorithmModule()
{

}

int CAlgorithmModule::Init()
{

	int nRet = VM_M_GetModuleId(m_hModule, &m_nModuleId);
	if (IMVS_EC_OK != nRet)
	{
		m_nModuleId = -1;
		return nRet;
	}

	nRet = ResetDefaultParam();
	if (nRet != IMVS_EC_OK)
	{
		MLOG_ERROR(m_nModuleId, "Call ResetDefaultParam failed.");
	}

	return nRet;
}

int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput, IN MVDSDK_BASE_MODU_INPUT* modu_input)
{
	//算法处理逻辑1
	return IMVS_EC_OK;
}

int CAlgorithmModule::Process(IN void* hInput, IN void* hOutput)
{
	//算法处理逻辑2
	return IMVS_EC_OK;
}


int CAlgorithmModule::GetParam(IN const char* szParamName, OUT char* pBuff, IN int nBuffSize, OUT int* pDataLen)
{
	int nRet = IMVS_EC_OK;
	if (szParamName == NULL || strlen(szParamName) == 0 || pBuff == NULL || nBuffSize <= 0 || pDataLen == NULL)
	{
		return IMVS_EC_PARAM;
	}
	// 算法参数（运行参数）输出到界面START
	// 算法参数（运行参数）输出到界面END	
	else
	{
		return CVmAlgModuleBase::GetParam(szParamName, pBuff, nBuffSize, pDataLen);
	}
	
	return nRet;
}

int CAlgorithmModule::SetParam(IN const char* szParamName, IN const char* pData, IN int nDataLen)
{
	int nRet = IMVS_EC_OK;
	if (szParamName == NULL || strlen(szParamName) == 0 || pData == NULL || nDataLen == 0)
	{
		return IMVS_EC_PARAM;
	}
	// 算法参数（运行参数）输出到底层START
	// 算法参数（运行参数）输出到底层END
	else
	{
		return CVmAlgModuleBase::SetParam(szParamName, pData, nDataLen);
	}

	return nRet;
}


/////////////////////////////模块须导出的接口（实现开始）//////////////////////////////////////////

LINEMODULE_API CAbstractUserModule* __stdcall CreateModule(void* hModule)
{
	assert(hModule != NULL);
   

	// 创建用户模块，并记录实例。
	CAlgorithmModule* pUserModule = new(nothrow) CAlgorithmModule;

	if (pUserModule == NULL)
	{
		return NULL;
	}

	pUserModule->m_hModule = hModule;

	int nRet = pUserModule->Init();
	if (IMVS_EC_OK != nRet)
	{
		delete pUserModule;
		return NULL;
	}

	OutputDebugStringA("###Call CreateModule");

	return pUserModule;
}


LINEMODULE_API void __stdcall DestroyModule(void* hModule, CAbstractUserModule* pUserModule)
{
	assert(hModule != NULL);
	OutputDebugStringA("###Call DestroyModule");

	if (pUserModule != NULL)
	{
		delete pUserModule;
	}
}
/////////////////////////////模块须导出的接口（实现结束）//////////////////////////////////////////
