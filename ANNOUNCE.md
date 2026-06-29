**@所有人** VM Vision Skills 插件已上线，一键安装即可在 Claude Code 中使用 10 个机器视觉技能 🎉

**📦 一行命令安装：**
```
/plugin install github:CV-China/vm-vision-skills
```

**📋 包含技能：** 脚本编程 | 算法模块构建 | 方案格式化 | 方案结构解析 | 脚本防护优化 | 耗时分析 | VTune CPU分析 | PerfView 内存分析 | 全方位性能优化 | 2D视觉定位引导

---

**⚠️ 请先确认你是哪种情况：**

**情况一：从未安装过这些技能**
→ 直接运行上面那条命令即可。

**情况二：之前手动复制过技能文件到 `~/.claude/skills/` 目录**
→ 先清理旧文件，否则会冲突：
```bash
rm -rf ~/.claude/skills/vm-script-tutor
rm -rf ~/.claude/skills/vm-algorithm-module-builder
rm -rf ~/.claude/skills/vm-comprehensive-optimizer
rm -rf ~/.claude/skills/vm-execution-time-analyzer
rm -rf ~/.claude/skills/vm-script-protection
rm -rf ~/.claude/skills/vtune-analyzer
rm -rf ~/.claude/skills/vm-sol-format
rm -rf ~/.claude/skills/vm-sol-structure
rm -rf ~/.claude/skills/2d-vision-guidance-expert
rm -rf ~/.claude/skills/perfview-analyzer
```
然后运行安装命令。

---

**🔍 验证：** 输入 `帮我写一个VM C#脚本` 或 `帮我分析方案性能`，能正常触发即安装成功。

**🔄 后续更新：**
```
/plugin update vm-vision-skills
```

> 💡 安装后由 Claude Code 自动管理，不再需要手动复制文件。
