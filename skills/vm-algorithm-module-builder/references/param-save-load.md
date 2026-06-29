# 参数持久化（SaveModuleData / LoadModuleData）

VM 工程文件保存时，会调用每个模块的 `SaveModuleData` 接口将运行参数写入工程；加载时调用 `LoadModuleData` 还原。**对于标准运行参数（在 AlgorithmTab.xml 中声明的 Integer/Float/...），VM 自动处理**，无需手写。

仅当需要保存 **非标准数据**（如训练好的模型 buffer、动态创建的查找表）时，才重写 SaveModuleData/LoadModuleData。

## 何时需要重写

- 模块运行后产生的中间状态需要持久化（如自学习的特征模板）
- OpenFile 加载的模型文件内容需要保存到工程，避免下次依赖外部文件
- 大量参数批量保存，不适合一个个走 AlgorithmTab.xml

## 接口签名（CVmAlgModuleBase 虚函数）

```cpp
// .h
class CAlgorithmModule : public CVmAlgModuleBase, public CModuleSharedMemoryBase
{
public:
    int SaveModuleData(OUT char* pData, IN int nDataLen, OUT int* pDataUsed) override;
    int LoadModuleData(IN const char* pData, IN int nDataLen) override;
};
```

## 简单示例

```cpp
int CAlgorithmModule::SaveModuleData(OUT char* pData, IN int nDataLen, OUT int* pDataUsed)
{
    if (pData == nullptr || pDataUsed == nullptr) return IMVS_EC_PARAM;

    // 简单二进制序列化：模型大小 + 模型字节
    int need = sizeof(int) + (int)m_modelBuffer.size();
    if (nDataLen < need) {
        *pDataUsed = need;
        return IMVS_EC_PARAM_BUF_LEN;  // 缓冲区不足的真实错码
    }

    int sz = (int)m_modelBuffer.size();
    memcpy_s(pData, sizeof(int), &sz, sizeof(int));
    if (sz > 0) {
        memcpy_s(pData + sizeof(int), nDataLen - sizeof(int),
                 m_modelBuffer.data(), sz);
    }
    *pDataUsed = need;
    return IMVS_EC_OK;
}

int CAlgorithmModule::LoadModuleData(IN const char* pData, IN int nDataLen)
{
    if (pData == nullptr || nDataLen < (int)sizeof(int))
        return IMVS_EC_PARAM;

    int sz = 0;
    memcpy_s(&sz, sizeof(int), pData, sizeof(int));
    if (sz < 0 || sizeof(int) + sz > (size_t)nDataLen)
        return IMVS_EC_PARAM;

    m_modelBuffer.assign(pData + sizeof(int), pData + sizeof(int) + sz);
    return IMVS_EC_OK;
}
```

## 注意

- pData 是字节流，不是结构化数据；自己定义二进制布局（含版本号字段方便升级）
- 不要在 SaveModuleData 内做耗时操作（VM 保存工程文件时阻塞）
- **运行参数已经在 AlgorithmTab.xml 中声明的，不要再重复存**，会冲突
