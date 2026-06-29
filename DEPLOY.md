# 部署与更新指南

## 一、首次部署到GitHub

### 前提条件

- 安装 [Git](https://git-scm.com/)
- 拥有 [GitHub](https://github.com/) 账号

### 步骤

#### 1. 在GitHub创建仓库

1. 打开https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `vm-vision-skills`
   - **Description**: `VisionMaster机器视觉全能工具包 — Claude Code插件，包含10个VM技能`
   - **Public**（公开仓库）
   - ⚠️ **不要**勾选 "Add a README file"（已有）
   - ⚠️ **不要**勾选 ".gitignore"（已有）
   - ⚠️ **不要**勾选 "Add a license"（已有）
3. 点击 **Create repository**

#### 2. 推送代码

```bash
cd c:/Users/zhusong6/vm-vision-skills-plugin

# 首次提交
git commit -m "feat: VisionMaster机器视觉全能工具包v1.0.0

包含10大技能：
- vm-script-tutor（脚本编程）
- vm-algorithm-module-builder（算法模块构建）
- 2d-vision-guidance-expert（2D视觉定位引导，联动sol-format/sol-structure）
- vm-comprehensive-optimizer（全方位性能优化总控台）
  - vm-execution-time-analyzer（耗时分析）
  - vm-script-protection（脚本防护优化）
  - vtune-analyzer（VTune CPU分析）
  - perfview-analyzer（PerfView内存分析）

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

```bash
# 1. 进入 Claude Code skills 目录
cd %USERPROFILE%\.claude\skills

# 2. 克隆仓库
git clone https://github.com/CV-China/vm-vision-skills.git

# 3. 重启 Claude Code 即可生效
```

> 💡 直接在 skills 目录下 clone，Claude Code 启动时自动递归扫描所有 `SKILL.md`，无需额外复制。
>
> ⚠️ **为何不用 `/plugin install`？**  
> Claude Code 2.1.195 在 Windows 上执行 `/plugin marketplace add` 时存在 rename 竞态 Bug：  
> 大仓库（本仓库 400+ 文件）clone 后 rename 临时目录时触发 `EPERM: operation not permitted`。  
> 这是 Claude Code 内部 Node.js `fs.rename()` 在 Windows 上的已知问题（文件数多时 Defender/Git 锁未释放），  
> 非本仓库配置问题。等待 Claude Code 修复此 Bug 后可恢复插件市场安装方式。

### 安装后验证

在Claude Code中输入以下内容测试技能是否加载：

- `帮我写一个VM C# 脚本` → 应触发 `vm-script-tutor`
- `帮我分析VM方案的性能瓶颈` → 应触发 `vm-comprehensive-optimizer`
- `帮我做九点标定` → 应触发 `2d-vision-guidance-expert`

> 💡 也可输入 `/status` 查看已安装的插件列表

---

## 三、技能更新后同步到GitHub（维护者操作）

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
# 例如：更新了vm-script-tutor技能
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

# 2. 更新README.md和plugin.json（添加新技能的描述和触发词）

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
# 同时更新README.md和plugin.json
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

---

## 四、用户更新（已有安装）

```bash
# 1. 进入仓库目录，拉取最新代码
cd %USERPROFILE%\.claude\skills\vm-vision-skills
git pull

# 2. 重启 Claude Code
```

---

## 附录：目录结构参考

```
vm-vision-skills-plugin/         ← Git仓库根目录
├── .claude-plugin/
│   ├── plugin.json              ← 插件清单（必选）
│   └── marketplace.json         ← 市场清单（必选）
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
└── .gitignore                   ← Git忽略规则
```
