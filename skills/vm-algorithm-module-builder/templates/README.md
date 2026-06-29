# AlgTemplate 模板说明

本目录应放置**模块敏捷封装工具**导出的 `AlgTemplate` 工程作为生成基础。

## 来源

模块敏捷封装工具 v2.0+ 自带 AlgTemplate：
```
模块敏捷封装工具\bin\Debug\AlgTemplate\
```

或直接从 VM 安装目录的 SDK 子目录获取（路径以用户实际安装为准）。

## 复制规则

复制时**剔除**以下子目录/文件以减小体积：

```
.vs/        ← VS 缓存
x64/        ← 编译产出
obj/        ← obj 中间文件
bin/        ← 部分位置的部署产出
*.sdf       ← VS IntelliSense 数据库
*.suo       ← VS 用户设置
*.user      ← VS 用户级 vcxproj 配置
.git/       ← 如有
```

**保留**：
```
common/                       ← VM400 SDK 头文件 + 静态库（必需）
AlgTemplate_CProj/AlgTemplate/AlgTemplate/
    AlgorithmModule.cpp       ← 模板代码（生成时复制改名）
    AlgorithmModule.h
    AlgorithmModule.def
    dllmain.cpp
    AlgTemplate.vcxproj
    *.filters
AlgTemplate_CsProj/AlgTemplateCs/
    AlgTemplateControl/        ← Cs 控件层模板
        AlgTemplate.cs
        AlgTemplateParam.cs
        AlgTemplateResult.cs
        *.csproj
AlgTemplate/                   ← XML 模板目录
    AlgTemplate.xml
    AlgTemplateAlgorithmTab.xml
    AlgTemplateAlgorithm.xml
    AlgTemplateDisplay.xml
    ToolItemInfo.xml
    *.png
AlgTemplate.sln
CopyBuildCFile.bat            ← 编译产出复制脚本
```

## skill 使用时的复制流程

由于 AlgTemplate ~5MB（剔除编译产出后约 2MB common/ + 模板源码），不预先存入 skill。

skill 在生成时按下面顺序：

1. **检查** `C:\Users\<user>\.claude\skills\vm-algorithm-module-builder\templates\AlgTemplate\` 是否存在
2. **不存在** → 提示用户：「请提供 AlgTemplate 模板路径（来自模块敏捷封装工具）」
3. **存在** → 复制 → 改名（"AlgTemplate" → 用户指定模块名）→ 修改内容

## 改名步骤（生成时）

1. **目录名重命名**：
   - `AlgTemplate/` → `<模块名>/`
   - `AlgTemplate_CProj/AlgTemplate/AlgTemplate/` → `<模块名>_CProj/<模块名>/<模块名>/`
   - `AlgTemplate_CsProj/AlgTemplateCs/AlgTemplateControl/` → `<模块名>_CsProj/<模块名>Cs/<模块名>Control/`

2. **文件名重命名**：
   - `AlgTemplate.xml` → `<模块名>.xml`
   - `AlgTemplateAlgorithmTab.xml` → `<模块名>AlgorithmTab.xml`
   - `AlgTemplateAlgorithm.xml` → `<模块名>Algorithm.xml`
   - `AlgTemplateDisplay.xml` → `<模块名>Display.xml`
   - `AlgTemplate.vcxproj` → `<模块名>.vcxproj`
   - `AlgTemplate.sln` → `<模块名>.sln`
   - Cs 工程同理

3. **内容替换**（在所有文本文件内）：
   - `AlgTemplate` → `<模块名>`
   - `ALGTEMPLATE` → `<模块名 大写>`（如宏 `ALGTEMPLATE_API`）

4. **删除**模板自带的 `ShowMessageBox` / 占位 OutputDebugString 等违规接口

5. **按 §澄清结果**插入用户的基本参数 XML 节点、运行参数控件、Process 实现

## 注意

**未经用户提供模板路径前，不要自己生成 vcxproj 内容**——这些文件含大量平台工具集、Windows SDK 版本等设置，错配会导致编译失败。模板来源可靠（来自官方工具），是基础保证。
