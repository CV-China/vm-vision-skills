# 第三方库集成（OpenCV / HALCON / Eigen / 等）

## 强制询问

只要满足任一条件，**必须**先和用户确认：

- 用户脚本或需求中出现 `cv::` / `OpenCvSharp` / `cv2`
- 出现 `HOperatorSet` / `HImage` / `HObject` / `HalconDotNet`
- 出现 `Eigen::` / `pcl::` / `nvinfer1::` / `Ort::Session`
- 出现 `#include <opencv2/...>` / `#include "Halcon.h"` 等

## 5 项必问信息

向用户索取（缺一不可）：

1. **头文件目录**（如 `D:\opencv\build\include`）
2. **库目录**（如 `D:\opencv\build\x64\vc16\lib`）
3. **.lib 文件名**（如 `opencv_world460.lib` / `halcon.lib` / `halconcpp.lib`）
4. **运行时 dll 目录**（用户编译后需将 dll 复制到模块部署目录，或加入 PATH）
5. **库版本**（如 OpenCV 4.6.0 / HALCON 20.11 / 23.05；不同主版本 API 差异大）

## 用户回答的三种情况

### 情况 A：提供完整路径 → 修改 .vcxproj

在 `<模块名>.vcxproj` 中追加：

```xml
<ItemDefinitionGroup>
    <ClCompile>
        <AdditionalIncludeDirectories>
            $(SolutionDir)common\src;$(SolutionDir)common\VM400\include\VmModuleFrame;D:\opencv\build\include;%(AdditionalIncludeDirectories)
        </AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
        <AdditionalLibraryDirectories>
            $(SolutionDir)common\VM400\lib\Win64;D:\opencv\build\x64\vc16\lib;%(AdditionalLibraryDirectories)
        </AdditionalLibraryDirectories>
        <AdditionalDependencies>
            VmModule_IO.lib;opencv_world460.lib;%(AdditionalDependencies)
        </AdditionalDependencies>
    </Link>
</ItemDefinitionGroup>
```

**三方 dll 部署**：编译成功后的自动部署阶段会将运行时 dll 自动复制到 VM 的 `Applications\PublicFile\x64\`（目标已存在则跳过并告知用户，不覆盖）。若自动部署不可用（VM 未检测到 / 编译跳过），需手动将 dll 复制到该目录或加入系统 PATH。

### 情况 B：明确不要保留 → 屏蔽相关代码

把第三方库相关行注释，并写 MLOG_WARN：

```cpp
// === 用户未提供 OpenCV，屏蔽相关代码 ===
// cv::Mat src(pImage.height, pImage.width, CV_8UC1, pImage.data[0]);
// cv::Canny(src, dst, 100, 200);
MLOG_WARN(m_nModuleId, u8"OpenCV 功能已屏蔽，请联系开发者配置 OpenCV 路径后启用");
// 用纯 C 循环替代或直接 pass-through
```

不要保留 `#include <opencv2/...>` —— 否则编译失败。

### 情况 C：不能提供也不同意屏蔽 → 终止生成

回复用户：「该模块依赖 OpenCV/HALCON 等第三方库，必须提供库路径或同意屏蔽相关功能，否则无法生成可编译的代码。」**不要**强行猜测路径。

## OpenCV 集成要点

- `#include <opencv2/opencv.hpp>`，链接 `opencv_world460.lib`（版本号按实际替换）
- `HKA_IMAGE` 与 `cv::Mat` 互转详见 [../examples/05-opencv-canny.md](../examples/05-opencv-canny.md)
- 输入侧 `cv::Mat` 直接引用 MVDImage 内存（零拷贝）：`cv::Mat(h, w, CV_8UC1, pImageInObj->GetImageData(0)->pData)`
- 输出侧需要 `AllocateSharedMemory` + `memcpy_s` 将 `cv::Mat` 数据拷入共享内存
- `cv::Exception` **必须**在 `std::exception` 之前单独 catch（否则被 `std::exception` 吞掉，无法获取 OpenCV 错误码）

### HKA_IMAGE ↔ cv::Mat 互转模板

```cpp
// HKA_IMAGE → cv::Mat（不拷贝，共享数据；只读）
cv::Mat HkaToMat(const HKA_IMAGE& img)
{
    int type = (img.format == HKA_IMG_MONO_08) ? CV_8UC1 : CV_8UC3;
    return cv::Mat(img.height, img.width, type, img.data[0]);
}

// cv::Mat → HKA_IMAGE（深拷贝到共享内存；输出场景）
// 详见 ../examples/05-opencv-canny.md Process 代码第 4 段
```

## HALCON 集成要点

- `#include "HalconCpp.h"`，链接 `halconcpp.lib` 与 `halcon.lib`
- `HObject` / `HImage` 与 HKA_IMAGE 互转详见 [../examples/06-halcon-zoom.md](../examples/06-halcon-zoom.md)
- 浅拷贝用 `GenImage1Extern`（灰度）或 `GenImageInterleaved`（RGB 交错），零拷贝直接引用 MVDImage 内存；深拷贝用 `GenImage1`（灰度）或 `GenImage3`（RGB Planar）
- HALCON 的 `GenImage1Extern` 不拷贝数据；释放前确保 HKA 数据未被回收

## 编译期自检

生成 .vcxproj 后核查：

```bash
# 没有未配置的 include 残留
grep -E '#include\s+["<](opencv|Halcon|Eigen|pcl)' AlgorithmModule.cpp AlgorithmModule.h
# 上面 grep 应该返回空（情况 B）或仅返回已配置 .vcxproj 的（情况 A）
```

如果代码里有 `#include <opencv2/...>` 但 `.vcxproj` 没配头文件路径——编译必定失败。两者必须同步。

## 自动部署三方 DLL

### 触发条件

以下条件**全部满足**时，skill agent 在编译子步骤 5.3 自动部署三方 dll：

1. 步骤 2 用户提供了三方库"运行时 dll 目录"（第 ④ 项）
2. 编译全部成功（C# + C++）
3. 步骤 0.6 检测到 VM 安装（`$vmRoot` 已知）

### 部署逻辑

1. 从用户提供的 `.lib` 文件名推导对应 `.dll` 文件名（如 `opencv_world460.lib` → `opencv_world460.dll`）
2. 对每个 dll，检测 `$vmRoot\Applications\PublicFile\x64\<dll名>` 是否已存在
3. **已存在** → `Write-Output "⏭️ PublicFile\x64\ 已存在 xxx.dll，跳过（不覆盖）"`
4. **不存在** → `xcopy` 复制到目标目录（先捕获输出到变量再打印，与 deploy_module.ps1 同模式）
5. **复制失败**（权限不足等）→ 降级为手动提示，不阻塞流程

### 收尾输出行为

| 情形 | 输出 |
|---|---|
| 全部 dll 已存在 | 告知用户"PublicFile\x64\ 已有所需 dll，无需额外操作" |
| 部分/全部复制成功 | 列出已复制的 dll 清单 |
| 复制失败 | 提示用户以管理员身份手动复制哪些 dll 到 `PublicFile\x64\` |
| 自动部署不可用 | 在收尾输出的手动步骤中提示复制路径 |
