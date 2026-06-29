# VM 环境检测（步骤 0.6 参考资料）

> 本文件是 SKILL.md 步骤 0.6 的详细参考，供 agent 在执行 VM 版本检测时查阅。

## 1. VM 安装检测（四级降级策略）

VM 在安装时向 .NET Assembly 注册表写入以下键：

```
注册表路径: HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\AssemblyFoldersEx\VisionMaster
值: CurrentVersion   REG_SZ   4.4.0          ← VM 版本号
值: (默认)            REG_SZ   C:\...\VisionMaster4.4.0\...  ← 安装路径
```

检测时按以下优先级依次尝试，任一级成功即停止：

### ① 首选：PowerShell 脚本

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill 目录>/detect_vm.ps1"
```

输出示例:
```
FOUND:C:\Program Files\VisionMaster4.4.0\Development\V4.x\ComControls\Assembly
VM_ROOT:C:\Program Files\VisionMaster4.4.0
VM_MAJOR_MINOR:4.4
VM_FULL:VisionMaster4.4.0
```

> **失败原因**：PowerShell 不可用 / 执行策略拦截 / Bash 工具安全分类器临时不可用。失败时自动降级到 ②。

### ② fallback：reg query 直接读注册表

`reg.exe` 是 Windows 自带命令行工具，Git Bash 可直接调用，**不需要 PowerShell**：

```bash
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\AssemblyFoldersEx\VisionMaster" 2>/dev/null
```

输出示例：
```
CurrentVersion    REG_SZ    4.4.0
(默认)    REG_SZ    C:\Program Files\VisionMaster4.4.0\Development\V4.x\ComControls\Assembly
```

从输出中提取：
- **版本号**：`grep CurrentVersion | awk '{print $NF}'` → `4.4.0`，去除补丁号即得 `$vmMajorMinor = "4.4"`
- **VM_ROOT**：`grep -v CurrentVersion | sed 's/.*REG_SZ[[:space:]]*//'` 得到路径，再向上截取到 `VisionMaster*` 目录

> **失败原因**：注册表键不存在（VM 未安装）。失败时自动降级到 ③。

### ③ 兜底：环境变量 + 文件系统

```bash
# 环境变量（VM SDK 安装时设置）
echo $MVDALGO_DEV_ENV
# 例: C:\Program Files\VisionMaster4.4.0\MVDAlgorithmSDK

# 文件系统（常见安装目录）
ls -d "C:/Program Files/VisionMaster"* "D:/Program Files/VisionMaster"* "E:/VisionMaster"* 2>/dev/null
```

从 `MVDALGO_DEV_ENV` 或目录名中提取版本号（正则 `VisionMaster(\d+)\.(\d+)`）。

> **失败原因**：VM 未安装或安装在非标准路径。失败时自动降级到 ④。

### ④ 最终：询问用户

以上三级均失败时，显式告知用户无法自动检测，请手动告知目标 VM 版本。用户也无法确认 → 默认 V430（`SDK/`）。

## 3. 版本校验（检测成功后）

无论通过哪一级检测获得 `$vmRoot` 与 `$vmFullVersion`，均提取 `$vmMajorMinor`（主.次版本号，如 `4.4`）。提取方式：
- ① PowerShell：脚本已直接输出 `VM_MAJOR_MINOR`
- ② reg query：从 `CurrentVersion` 值提取（如 `4.4.0` → 主.次=`4.4`）
- ③ 环境变量/文件系统：从目录名 `VisionMaster4.4.0` 中用正则 `VisionMaster(\d+)\.(\d+)` 提取

> **版本比较原则**: VM 的 SDK 接口在同一主.次版本号下保持兼容(如 VM4.3.0、VM4.3.1、VM4.3.2 同为 4.3 系列),仅主.次版本号变化(如 4.3→4.4)才可能有差异。因此版本比较**只看主.次版本号,忽略补丁号**。

## 4. 版本匹配判断

将 `$vmMajorMinor`(主.次版本号)与 skill 模板基准 `4.3`(对应 VM431)对比:

| 情形 | 判定 | 处理 | SDK 版本 |
|---|---|---|---|
| `$vmMajorMinor` = `4.3`(如 VisionMaster4.3.0 / 4.3.1 / 4.3.2) | ✅ 匹配模板基准(VM43x 系列) | 静默通过,记录 `$vmRoot` 路径 | **SDK_V430** |
| `$vmMajorMinor` = `4.4`(如 VisionMaster4.4.0 / 4.4.1) | ✅ 匹配模板 V440 SDK | 静默通过,记录 `$vmRoot` 路径 | **SDK_V440** |
| `$vmMajorMinor` > `4.4`(如 `4.5` = VM45x 系列) | ⚠️ 高于模板版本 | **显式告知用户**当前 VM 版本,询问是否继续 | 默认 SDK_V440（用户可指定） |
| `$vmMajorMinor` < `4.3`(如 `4.2` = VM42x 系列) | ❌ 不确定兼容性 | **显式告知用户**版本低于模板基准,询问是否继续 | SDK_V430（用户可指定） |
| 无法从路径提取版本号 | ⚠️ 未知 | 告知用户"检测到 VM 安装但无法识别版本",继续流程 | 询问用户目标 VM 版本 |

**高于模板版本时的告知模板**(agent 必须逐字输出):

> ⚠️ **VisionMaster 版本不匹配**
>
> - 当前电脑 VM 版本: **VisionMaster X.X.X**(主.次版本 `X.X`)
> - Skill 模板基准版本: **VM431**(主.次版本 `4.3`)
>
> 不同主.次版本间的 SDK 接口可能存在差异(同一主.次版本下的补丁号差异如 4.3.0↔4.3.1 可视为兼容)。Skill 已内置 VM4.3 和 VM4.4 两套 SDK 文件：
> - `common/SDK/` — 适配 VM4.3.x 系列（**注意**：V430 SDK 直接位于 `SDK/`，没有独立的 `SDK_V430/` 子目录）
> - `common/SDK_V440/` — 适配 VM4.4.x 系列
>
> 当前检测到的 VM 版本为 X.X，将自动选择 **SDK_V4XX**。
>
> 是否仍继续生成? (是/否)

用户确认"否" → 终止。确认"是" → 继续,记录 `$vmRoot` 用于后续自动部署。

## 5. SDK 版本选择机制

### 5.1 选择规则

| 检测到的 VM 主.次版本 | 选择的 SDK | 目录路径 | 说明 |
|---|---|---|---|
| `4.3` | `V430` | `common/SDK/` | 默认模板 SDK |
| `4.4` | `V440` | `common/SDK_V440/` | VM4.4 SDK（新增 MVDRegionCpp 和 MVDRenderControl 等接口） |
| `> 4.4` 或 `< 4.3` | 询问用户 | 按最接近版本 | 用户确认后选择 |
| 未知 | 询问用户 | 用户指定 | 用户指定目标 VM 版本后选择 |

> **SDK 版本命名速查**：`$sdkVersion` = `"V430"` 或 `"V440"`（步骤 0.6 设置）。`"V430"` → 目录为 `common/SDK/`（默认，无需额外操作）；`"V440"` → 目录为 `common/SDK_V440/`（落盘 Step 1b 执行替换激活）。文档中 `V430`/`SDK_V430`/`V4.3` 均指同一概念，物理目录统一为 `common/SDK/`。

### 5.2 模板目录结构

```
common/
  SDK/              ← 默认 SDK（V4.3），vcxproj 始终引用此路径
    Includes/...
    Libraries/...
  SDK_V440/         ← VM4.4 SDK
    Includes/...    ← 新增 MVDRegionCpp.h、RegionToolCpp.h
    Libraries/...   ← 新增 MVDRegionCpp.lib、MVDRenderControl.lib
```

> ⚠️ V4.3 SDK 位于 `common/SDK/`，没有独立的 `SDK_V430/` 目录。文档中 `V430` 即指 `SDK/`（默认版本）。

### 5.3 生成时的 SDK 激活

在落盘流程 Step 1（复制模板到输出目录）之后、Step 3（改名）之前执行：

```bash
# 根据 VM 版本选择 SDK
if [ "$SDK_VERSION" = "V440" ]; then
  # 替换默认 SDK/ 为 V440 版本
  rm -rf "$OUT/common/SDK"
  cp -r "$OUT/common/SDK_V440" "$OUT/common/SDK"
fi
# SDK_V430 是默认值，无需额外操作（SDK/ 已包含 V430 文件）
```

### 5.4 V440 SDK 新增文件清单

相比 V430，V440 SDK 新增：

**头文件**（`common/SDK_V440/Includes/Common/VisionDesigner/`）：
- `MVDRegionCpp.h` — Region 工具 C++ 接口
- `RegionToolCpp.h` — RegionTool 接口

**库文件**（`common/SDK_V440/Libraries/x64/Common/`）：
- `MVDRegionCpp.lib` — Region 工具链接库
- `MVDRenderControl.lib` — 渲染控件链接库
