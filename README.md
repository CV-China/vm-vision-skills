# VM Vision Skills

VisionMaster机器视觉全能工具包 —— 海康机器人 VisionMaster 用户的瑞士军刀。

## 技能架构

```
vm-vision-skills
├── vm-script-tutor              # 脚本编程
├── vm-algorithm-module-builder  # 算法模块构建
├── vm-sol-format                # 方案格式化 ◄──────────┐
├── vm-sol-structure             # 方案结构解析 ◄────────┤
├── 2d-vision-guidance-expert    # 2D 视觉定位引导 ★ ───┘
└── vm-comprehensive-optimizer   # 全方位性能优化总控台 ★
    ├── vm-execution-time-analyzer  # 耗时分析
    ├── vm-script-protection        # 脚本防护优化
    ├── vtune-analyzer              # VTune 性能分析 (CPU)
    └── perfview-analyzer           # PerfView 内存分析
```

> - **★ 总控台**：`vm-comprehensive-optimizer` 按需组合四个子技能，输出含交叉关联分析和优先级排序的综合优化报告
> - **★ 定位引导**：`2d-vision-guidance-expert` 在分析 .sol 方案时，自动调用 `vm-sol-format` 和 `vm-sol-structure` 进行方案解析

### 技能详情

| 技能名称 | 功能描述 |
|---------|---------|
| `vm-script-tutor` | VM 2D C# 脚本编程辅助，提供可直接使用的脚本代码 |
| `vm-algorithm-module-builder` | VM 算法模块构建与部署，支持模块校验和一键部署 |
| **`2d-vision-guidance-expert`** | **2D 机器视觉定位引导专家**（标定+生产计算） |
| ↳ `vm-sol-format` | VM 方案 .sol 文件格式化 |
| ↳ `vm-sol-structure` | VM 方案 .sol 文件结构解析 |
| **`vm-comprehensive-optimizer`** | **全方位性能优化总控台**，多维联动分析 |
| ↳ `vm-execution-time-analyzer` | VM 方案耗时分析，定位性能瓶颈 |
| ↳ `vm-script-protection` | 脚本防护优化，异常处理 + 代码防护 |
| ↳ `vtune-analyzer` | Intel VTune CPU 热点分析 |
| ↳ `perfview-analyzer` | PerfView + xperf 非托管内存分析 |

## 一键安装

在 Claude Code 中运行以下命令：

```bash
/plugin install github:CV-China/vm-vision-skills
```

或者手动安装：

```bash
# 克隆到插件目录
git clone https://github.com/CV-China/vm-vision-skills.git

# Claude Code 会自动发现 skills/ 目录下的所有技能
```

## 触发关键词

安装后，Claude Code 会自动加载全部 10 个技能。以下是各技能的触发关键词：

### vm-script-tutor（脚本编程）
`VM脚本` `编写脚本` `C#脚本` `脚本开发` `脚本编写` `自定义脚本` `UserScript` `模块参数` `全局变量` `图像处理脚本` `VM编程` `脚本代码` `脚本示例`

### vm-algorithm-module-builder（算法模块构建）
`构建模块` `算法模块` `部署模块` `封装模块` `脚本封装` `算法封装` `自定义模块` `模块工程` `模块XML` `AlgorithmModule` `Process函数` `SetParam` `GetParam` `脚本转模块` `C#转C++模块` `集成OpenCV` `集成HALCON` `第三方库封装` `模块校验` `模块打包`

### 2d-vision-guidance-expert（2D视觉定位引导）★
`2D视觉` `定位引导` `标定` `抓取纠偏` `对位` `视觉定位` `九点标定` `十二点标定` `N点标定` `映射标定` `旋转中心` `分离轴` `上下对位` `双相机定位` `拍照位` `旋转定位` `精度` `重复性` `偏差` `定位误差` `误差排查` `定位不准` `精度不够` `视觉引导` `机械手引导` `CheckList`

> 自动联动 `vm-sol-format` + `vm-sol-structure` 解析方案

### vm-sol-format（方案格式化）
`sol格式化` `sol文件` `方案文件` `二进制格式` `ModuleFrame` `UiParamData` `GlobalScript` `解析sol` `修改sol` `重建sol` `对比sol` `sol对比` `提取脚本` `提取参数`

### vm-sol-structure（方案结构解析）
`sol结构` `方案结构` `方案拓扑` `模块连接` `参数订阅` `数据流` `执行流程` `Group嵌套` `VmServer` `模块类型` `Type枚举` `模块GUID` `方案配置`

### vm-comprehensive-optimizer（全方位性能优化总控台）★
`全面优化` `性能诊断` `多维分析` `综合评估` `性能调优` `全方位优化` `整体优化` `全部查一遍` `彻底排查` `全面体检` `方案跑得好慢` `为什么老是卡` `内存爆了` `CPU飙高` `哪里最慢` `能不能再快点` `越跑越慢` `方案性能不行` `帮我找出瓶颈` `哪里最耗资源`

> 按需调度下面四个子技能，输出交叉关联分析报告

### vm-execution-time-analyzer（耗时分析）
`耗时分析` `执行时间` `性能瓶颈` `哪个模块慢` `流程耗时` `模块耗时` `方案时序` `时间线` `耗时统计` `慢在哪` `跑得慢`

### vm-script-protection（脚本防护优化）
`脚本防护` `脚本优化` `try-catch` `异常保护` `脚本保护` `防崩溃` `防闪退` `防除零` `除零保护` `数组越界` `空指针` `null检查` `内存泄漏` `静态集合` `防死循环` `死循环检测` `脚本健壮性` `脚本性能` `循环拼接` `重复LINQ` `ShellModule` `给脚本加保护` `异常处理`

### vtune-analyzer（VTune性能分析）
`VTune` `CPU热点` `CPU分析` `性能分析` `热点分析` `VTune内存` `hotspots` `内存带宽` `profile进程` `性能采样` `CPU采样` `微架构分析`

### perfview-analyzer（PerfView内存分析）
`PerfView` `内存分析` `非托管内存` `ETW` `内存泄漏` `内存占用` `内存增长` `内存热点` `哪个模块占内存` `托管堆` `GC分析` `VirtAlloc` `xperf` `perfview analyze` `PerfView profile` `native memory`

## 依赖要求

- **vm-script-protection**: 需要 .NET Framework 4.6.1+ Runtime，CLI 工具已打包在 `tools/` 目录中
- **vtune-analyzer**: 需要安装 Intel VTune Profiler
- **perfview-analyzer**: 需要安装 PerfView 和 Windows Performance Toolkit (xperf)
- 部分技能涉及 Windows 专属工具，建议在 Windows 环境下使用

## 维护指南

详见 [DEPLOY.md](DEPLOY.md) —— 包含首次部署、技能更新同步、版本管理的完整步骤。

## License

MIT License - 详见 [LICENSE](LICENSE)
