# 版本升级（VM430 → VM431+）

本 skill **只支持 VM431+**。VM430 模块迁移到 VM431+ 有若干强制改动。

## 强制改动

### 1. 图像输出接口：用 AllocateSharedMemory + OutputImageByName_*R

VM430：直接 malloc/new 内存作为图像 buffer。
VM431+：必须用 `AllocateSharedMemory(m_nModuleId, nLen, ...)` 申请共享内存。

```cpp
// VM430（不再支持）
char* pBuf = (char*)malloc(nLen);
// ... 填充 ...
VM_M_SetImageEx(hOutput, ..., pBuf, ...);
free(pBuf);

// VM431+
char* pSharedName = NULL;
AllocateSharedMemory(m_nModuleId, nLen, (char**)(&pImage.data), &pSharedName);
// ... 填充 pImage.data[0] ...
VmModule_OutputImageByName_8u_C1R(hOutput, 1, "OutImage", ..., &pImage, 0, pSharedName);
// 不需要手动 free，共享内存由 VM 平台管理
```

### 2. 多图像输入：用 VmModule_GetInputImageByName

VM430：单一图像入口 `modu_input->pImageInObj`。
VM431+：第二张及之后用 `VmModule_GetInputImageByName(hInput, "InImage2", "InImage2Width", "InImage2Height", "InImage2PixelFormat", &pImage2, &status2, szShared2)`。

> 注:`VmModule_GetInputImageEx` 真实签名是 `(hInput, &image, iImageDataLen, &imageStatus[, strSharedMemName])`,**没有**图像名参数,只能用于主输入图像;额外命名图像必须用 `VmModule_GetInputImageByName`。

### 3. 必须缓存 moduleId

VM431+ 的 `AllocateSharedMemory` 第一个参数是 moduleId，必须在 Init 阶段缓存：

```cpp
int CAlgorithmModule::Init()
{
    VM_M_GetModuleId(m_hModule, &m_nModuleId);
    return IMVS_EC_OK;
}
```

`m_nModuleId` 在 `.h` 中声明：
```cpp
private:
    int m_nModuleId = 0;
```

### 4. ModuleRuntimeInfo 必须设置

VM430 可选；VM431+ 必须每次 Process 末尾调用：
```cpp
MODULE_RUNTIME_INFO struRunInfo = { 0 };
struRunInfo.fAlgorithmTime = MyMilliseconds() - fStart;
VM_M_SetModuleRuntimeInfo(m_hModule, &struRunInfo);
```

不调用则 VM 平台无法统计该模块耗时，性能监控失效。

### 5. 类继承

VM430：
```cpp
class CAlgorithmModule : public CVmAlgModuleBase
```

VM431+：
```cpp
class CAlgorithmModule : public CVmAlgModuleBase, public CModuleSharedMemoryBase
```

`CModuleSharedMemoryBase` 提供 `AllocateSharedMemory` 等接口。

## 不变的部分

- `Process` 函数签名不变
- `GetParam` / `SetParam` 接口不变
- XML 配置不变（Combination / Filter / Integer / Float 等节点）
- 错误码不变（IMVS_EC_*）

## 检查清单

迁移完成后核查：
- [ ] `class CAlgorithmModule` 是否多继承 `CModuleSharedMemoryBase`
- [ ] Init 中是否有 `VM_M_GetModuleId`
- [ ] Process 中所有图像输出是否走 `AllocateSharedMemory` + `OutputImageByName_*R`
- [ ] Process 末尾是否有 `VM_M_SetModuleRuntimeInfo`
- [ ] 没有 `malloc` / `new` 用于图像 buffer 的残留
