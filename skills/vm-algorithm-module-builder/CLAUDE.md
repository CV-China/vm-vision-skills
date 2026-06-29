# CLAUDE.md — 激活提示(本文件仅 Claude Code 读取；CodeX/Trae/Copilot CLI/Gemini CLI 等环境只读 SKILL.md)

> ⚠️ **本文件不是规则源头**。所有硬约束(编译/运行铁律、反模式、改名清单、ROI/拷贝策略、XML schema 等)都在 [SKILL.md](SKILL.md) 的 §必须遵守(A-P 共 16 节)。
>
> 本文件存在仅因为 Claude Code 会自动读 `CLAUDE.md`。为避免多文件不同步，**规则一律放 SKILL.md**，本文件只做激活提醒 + 快速索引。其他编程工具（CodeX、Trae、Copilot CLI、Gemini CLI）只读 `SKILL.md` 即拥有全部规则。

## 激活检查清单

每次本 skill 被触发(检测到模块开发/算法封装/脚本转模块/Process 函数等关键词),**先完成以下三项再回答用户**:

1. **Read [SKILL.md](SKILL.md) §必须遵守 完整 A-P 节** —— 这是唯一权威规则源
2. **Read [SKILL.md](SKILL.md) §澄清清单** —— 决定接下来的提问顺序
3. **TodoWrite 创建任务列表** —— 至少含:开发模式判断、三方库确认、基本参数确认、运行参数确认、plan-before-code、落盘、自检、**模块语言资源**、**编译**、**收尾清理**

## 编译检查

落盘自检通过后按 SKILL.md §可选编译 执行:先检测 VS2017+(4 种方法回退),找不到则显式告知用户跳过,找到则按 Cs→Cpp 序编译 Release 配置。**编译前须确认 SDK lib 完整性，若 §落盘流程 已记录 lib 不完整警告，必须先告知用户手动补齐 lib 后再编译。**

## 关键警示(完整内容看 SKILL.md)

- ❌ 用户一说"做个二值化模块"就立即 Write → §A 铁律 1
- ❌ 用户列了 2 个运行参数,你"觉得加个使能更完善"生成 3 个 → §A 铁律 4 + §P 反模式
- ❌ 编造 `VM_M_GetImageInfo` / `IMVS_EC_NOMEM` 等接口 → §C
- ❌ 重载基类虚函数 `ResetDefaultParam` / `GenerateMaskImage` → §D
- ❌ 把阈值/使能/类型当基本参数放 `<模块名>.xml` → §E
- ❌ 无图像模块忘写 3 参数 Process（纯虚函数 `=0` 必须实现）→ §F
- ❌ 用户没说 ROI 但 Process 调了 `GenerateMaskImage` → §H
- ❌ 修改 SKILL.md 等大文件不用 Edit 直接上 Python 脚本 → **先用 Edit**；只能用 Python 时：① `find()` 后必须检查 `-1` ② 改前 `cp file file.bak` ③ 改后验证行数 ± 预期值
- ❌ 用 Write 工具重写 `.xaml`/`.csproj` → §N
- ❌ VM4.4 环境用 V430 SDK 或反之 → 步骤 0.6 检测到 VM 版本后必须设置 `$sdkVersion`（"V430"/"V440"），落盘流程 Step 1b 激活对应 SDK：V440 时用 `common/SDK_V440/` 替换 `common/SDK/`，V430 时保持默认不操作
- ❌ 逐个检查特定 lib 名称 → 改为确认 SDK lib 数量达标：SDK 目录须非空且 `SDK/Libraries/x64/` 下至少含 4 个 .lib（V430）/ `SDK_V440/Libraries/x64/` 下至少含 6 个 .lib（V440）；详细计数由 check_module 脚本校验
- ❌ ButtonSelecter 不包 `<Category Name="Class Inputs"><Items>` → algorithm-tab.xml.md
- ❌ 运行参数已提供中文却写英文 DisplayName/Description → check_module 第 18 项拦截
- ❌ 几何输出参数只加叶子 Filter Lang 资源漏 Combination/子 Combination → language-resources.md §几何输出参数的完整资源映射

## 部署固化

编译成功后，**不要**手写 xcopy 命令。使用内置脚本：
```bash
powershell -NoProfile -File "<skill 目录>/deploy_module.ps1" -SourceDir "<outputDir>\<模块名>\<模块名>" -VmRoot "$vmRoot" -Toolbox "$toolbox" -ModuleName "<模块名>"
```
该脚本自动部署 runtime + dev 双路径，并逐文件比对时间戳确认覆盖成功。

## 落盘前后必跑(**两步,缺一不可**)

```bash
# 1) 落盘前:验证 skill 模板本身完整(lib + 头文件 + 白名单)
bash <skill 目录>/check_module.sh --pre <skill 目录>/templates/AlgTemplate/

# 2) 落盘后:验证生成物(22 项结构检查,含 SDK 符号白名单反向校验 + bat CRLF 检查 + ToolItemInfo.xml 格式检查 + DisplayName≠Name 检查 + Display.xml 根节点)
bash <skill 目录>/check_module.sh <outputDir>/<模块名>/ "用户列出的运行参数英文名空格分隔"
```

**Windows 无 bash 时改用 PowerShell 镜像**:
```powershell
pwsh -File <skill 目录>/check_module.ps1 -Pre <skill 目录>\templates\AlgTemplate\
pwsh -File <skill 目录>/check_module.ps1 <outputDir>\<模块名>\ -UserParams "p1 p2"
```

任一 FAIL 必须修复。**白名单校验**(§3.5)能拦截所有编造的 `VM_M_*` / `IMVS_EC_*` / `HKA_*` 符号 —— 若误报真接口,运行 `bash references/regen-sdk-whitelist.sh` 重生白名单。

**自检通过后进入编译阶段**(详见 [SKILL.md](SKILL.md) §可选编译):先检测 VS2017+(vswhere → VSINSTALLDIR → PATH → 硬编码路径 4 级回退),找到则按 Cs→Cpp 序 `MSBuild /p:Configuration=Release`,未找到则显式告知用户无法编译并跳过。
