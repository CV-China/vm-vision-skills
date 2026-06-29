# 部署与更新指南

## 一、首次部署到 GitHub

### 前提条件

- 安装 [Git](https://git-scm.com/)
- 拥有 [GitHub](https://github.com/) 账号

### 步骤

#### 1. 在 GitHub 创建仓库

1. 打开 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `vm-vision-skills`
   - **Description**: `VisionMaster 机器视觉全能工具包 — Claude Code 插件，包含 10 个 VM 技能`
   - **Public**（公开仓库）
   - ⚠️ **不要**勾选 "Add a README file"（已有）
   - ⚠️ **不要**勾选 ".gitignore"（已有）
   - ⚠️ **不要**勾选 "Add a license"（已有）
3. 点击 **Create repository**

#### 2. 推送代码

```bash
cd c:/Users/zhusong6/vm-vision-skills-plugin

# 首次提交
git commit -m "feat: VisionMaster机器视觉全能工具包 v1.0.0

包含 10 大技能：
- vm-script-tutor（脚本编程）
- vm-algorithm-module-builder（算法模块构建）
- 2d-vision-guidance-expert（2D视觉定位引导，联动 sol-format/sol-structure）
- vm-comprehensive-optimizer（全方位性能优化总控台）
  - vm-execution-time-analyzer（耗时分析）
  - vm-script-protection（脚本防护优化）
  - vtune-analyzer（VTune CPU分析）
  - perfview-analyzer（PerfView 内存分析）

Co-Authored-By: Claude <noreply@anthropic.com>"

# 关联远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/CV-China/vm-vision-skills.git

# 推送
git push -u origin main
```

#### 3. 验证

推送完成后，访问 `https://github.com/CV-China/vm-vision-skills`，确认所有文件已上传。

---

## 二、用户安装（首次）

### 方式 A：一键安装（推荐）

在 Claude Code 中运行：

```
/plugin install github:CV-China/vm-vision-skills
```

Claude Code 会自动克隆仓库、注册技能，安装完成后即可使用。

### 方式 B：手动安装

```bash
# 克隆到 Claude Code 插件市场目录
git clone https://github.com/CV-China/vm-vision-skills.git \
  "$HOME/.claude/plugins/marketplaces/vm-vision-skills"

# 重启 Claude Code 或重新加载技能
```

### 安装后验证

在 Claude Code 中输入以下内容测试技能是否加载：

- `帮我写一个 VM C# 脚本` → 应触发 `vm-script-tutor`
- `帮我分析 VM 方案的性能瓶颈` → 应触发 `vm-comprehensive-optimizer`
- `帮我做九点标定` → 应触发 `2d-vision-guidance-expert`

> 💡 也可输入 `/status` 查看已安装的插件列表

---

## 三、技能更新后同步到 GitHub（维护者操作）

当你在本地 `~/.claude/skills/` 下修改了某个技能后，需要将变更同步到插件仓库：

### 标准流程

```bash
# 1. 将修改后的技能复制到插件目录
cp -r ~/.claude/skills/<skill-name>/* \
      c:/Users/zhusong6/vm-vision-skills-plugin/skills/<skill-name>/

# 2. 查看变更
cd c:/Users/zhusong6/vm-vision-skills-plugin
git status
git diff

# 3. 提交
git add skills/<skill-name>/
git commit -m "feat(<skill-name>): 描述本次变更内容"

# 4. 推送
git push
```

### 示例

```bash
# 例如：更新了 vm-script-tutor 技能
cp -r ~/.claude/skills/vm-script-tutor/* \
      c:/Users/zhusong6/vm-vision-skills-plugin/skills/vm-script-tutor/

cd c:/Users/zhusong6/vm-vision-skills-plugin
git add skills/vm-script-tutor/
git commit -m "feat(vm-script-tutor): 新增脚本模板，优化错误提示"
git push
```

### 新增技能

```bash
# 1. 复制新技能
cp -r ~/.claude/skills/<new-skill> \
      c:/Users/zhusong6/vm-vision-skills-plugin/skills/<new-skill>/

# 2. 更新 README.md 和 plugin.json（添加新技能的描述和触发词）

# 3. 提交
cd c:/Users/zhusong6/vm-vision-skills-plugin
git add skills/<new-skill>/ README.md .claude-plugin/plugin.json
git commit -m "feat: 新增 <new-skill> 技能"
git push
```

### 删除技能

```bash
cd c:/Users/zhusong6/vm-vision-skills-plugin
git rm -r skills/<old-skill>/
# 同时更新 README.md 和 plugin.json
git commit -m "feat: 移除 <old-skill> 技能"
git push
```

### 版本号管理（可选）

如果要标记正式版本：

```bash
# 打标签
git tag v1.1.0
git push origin v1.1.0
```

用户可以通过指定版本安装：`/plugin install github:CV-China/vm-vision-skills@v1.1.0`

---

## 四、用户更新（已有安装）

### 方式 A：自动检查更新

Claude Code 会定期检查已安装插件的更新。当检测到新版本时，会自动提示。

### 方式 B：手动强制更新

在 Claude Code 中：

```
/plugin update vm-vision-skills
```

或重新安装（会覆盖）：

```
/plugin install github:CV-China/vm-vision-skills
```

### 方式 C：Git 手动拉取

```bash
# 找到插件安装路径（通常在 ~/.claude/plugins/marketplaces/ 下）
cd ~/.claude/plugins/marketplaces/vm-vision-skills

# 拉取最新代码
git pull

# 重启 Claude Code
```

---

## 附录：目录结构参考

```
vm-vision-skills-plugin/         ← Git 仓库根目录
├── .claude-plugin/
│   └── plugin.json              ← 插件清单（必选）
├── skills/                      ← 技能目录（必选）
│   ├── <skill-1>/
│   │   ├── SKILL.md             ← 技能定义（必选）
│   │   ├── references/          ← 参考文档（可选）
│   │   ├── scripts/             ← 辅助脚本（可选）
│   │   ├── templates/           ← 模板文件（可选）
│   │   ├── tools/               ← 工具依赖（可选）
│   │   └── assets/              ← 静态资源（可选）
│   └── <skill-2>/
├── README.md                    ← 项目说明
├── LICENSE                      ← 开源协议
└── .gitignore                   ← Git 忽略规则
```
