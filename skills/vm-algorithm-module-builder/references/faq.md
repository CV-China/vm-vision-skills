# 常见问题（FAQ）

## Q1. 编译报错 "无法解析的外部符号 VmModule_OutputImageByName_8u_C1R"

`.vcxproj` 没链接到 `common/VM400/lib/Win64/VmModule_IO.lib`。检查：
```xml
<AdditionalLibraryDirectories>$(SolutionDir)common\VM400\lib\Win64;...</AdditionalLibraryDirectories>
<AdditionalDependencies>VmModule_IO.lib;...</AdditionalDependencies>
```

## Q2. 编译报错 "AllocateSharedMemory 是私有成员"

`class CAlgorithmModule` 没继承 `CModuleSharedMemoryBase`。检查：
```cpp
class CAlgorithmModule : public CVmAlgModuleBase, public CModuleSharedMemoryBase
```

## Q3. 模块在 VM 工具箱里看不到

- 部署路径错：必须放在 `VisionMaster4.X.0\Applications\Module(sp)\x64\<工具箱>\<模块名>\`
- `ToolItemInfo.xml` 缺失或字段错（根节点应为 `<ToolBoxItemData>`，检查 `<name>/<priority>/<toolTip>`）
- 修改后未重启 VM

## Q4. 模块加载但运行就闪退

- Process 内有未捕获异常 → 加 `try/catch(...)`
- 图像 buffer 越界写 → 检查 height*width 与实际 nLen 一致
- 中文路径用了 fopen 但没转 ANSI → 见 [encoding.md](encoding.md)
- 第三方 dll 缺失（OpenCV/HALCON dll）→ 复制到模块目录或加 PATH

## Q5. 中文显示乱码

- **修改 C++ 源码前**：先用 `file` 检测编码。若已为 UTF-8 / UTF-8 with BOM → 以 UTF-8 编码修改；否则以 **GB2312**（ANSI）编码修改（模板 cpp/h 默认为 GB2312，改成 UTF-8 with BOM 会导致已有中文注释乱码）
- **中文注释策略**：推荐只用英文注释（Write/Edit 工具按 UTF-8 写入会与 GB2312 冲突）；若用户明确要求中文注释，用 Python 按 `encoding='gb2312'` 写入
- **u8 前缀规则**：GB2312 源文件中**仅**传入 VM SDK 接口的中文参数名/值（如 `VM_M_GetFloat(hInput, u8"阈值", ...)`）需要加 `u8`（VM 内部以 UTF-8 存储参数名，u8 强制 MSVC 按 UTF-8 编译该字面量）；纯本地字符串/注释/日志不加 `u8`（详见 SKILL.md §J）
- XML 文件是 UTF-8 编码 → 中文直接写，不需要特殊处理

## Q6. 运行参数在 UI 上能改，但算法用的还是默认值

- C++ `SetParam` 内没赋值给成员变量 → 检查 `m_nThresholdValue = ...` 是否漏
- 成员变量名拼错 → 与 Get/Set 用的变量不一致
- 多线程问题：Process 在另一线程，与 UI 线程修改成员变量冲突 → 加 `std::atomic` 或锁（罕见）

## Q7. 多图像输出，只有第一张能显示

- 没用独立 `pSharedName` → 每张图必须 `AllocateSharedMemory` 各申请一份
- `Display.xml` 漏了对应 `<Object>` 节点
- `Mapping=` 中字段名写错

## Q8. ModuStatus 一直是 0（NG）

- 成功路径里漏了 `VM_M_SetInt(hOutput, "ModuStatus", 0, 1);`
- catch 块进了 → 检查异常原因
- Process 返回了非 IMVS_EC_OK

## Q9. ShowMessageBox 模板里有，能保留吗？

**不能**。算法 DLL 中**禁止**任何弹窗（包括 MessageBox / AfxMessageBox）。改为 MLOG_ERROR/MLOG_WARN。见 [log.md](log.md)。

## Q10. 我需要 3D 模块（点云、深度图等）

本 skill **不支持 3D**。3D 模块基本接口不同（涉及 `PointCloudData` / `DepthImage`），需另用 3D 模板工程。本 skill 拒绝生成 3D 代码。

## Q11. 我有 OpenCV 但只想用其中几个函数

仍按 [third-party-libs.md](third-party-libs.md) 配置完整 OpenCV 路径。不存在"半配置"——要么完整链接，要么完全屏蔽。

## Q12. 模块运行很慢，能用 OpenMP 吗？

可以，但需用户明确要求（默认不加，避免编译依赖）。开启方式：
```xml
<OpenMPSupport>true</OpenMPSupport>
```
在 `.vcxproj` 的 `<ClCompile>` 内。代码中加 `#pragma omp parallel for`。
