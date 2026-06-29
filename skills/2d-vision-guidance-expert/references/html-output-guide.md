# HTML输出规范指南

所有方案/诊断统一输出为独立 HTML 文件，内嵌 CSS，无需外部依赖，浏览器直接打开即可查看彩色卡片和可视化流程图。

---

## 使用方式

**不要重新生成 HTML 骨架和 CSS。** 每次输出前，直接读取对应模板文件，将 `{{占位符}}` 替换为本次内容后写出文件即可：

- 方案设计 → 读取 `${SKILL_DIR}/assets/template-solution.html`
- 问题诊断 → 读取 `${SKILL_DIR}/assets/template-diagnosis.html`

---

## 方案设计模板占位符（template-solution.html）

| 占位符 | 填写内容 | 示例 |
|--------|---------|------|
| `{{TITLE}}` | 场景名称，5~15字，用于 `<title>` 和 `<h1>` | `四相机同侧标定板对角纠偏-XYR旋转` |
| `{{DATETIME}}` | 生成时间，格式 `YYYY-MM-DD HH:mm` | `2026-05-25 10:00` |
| `{{META_COMMENT}}` | HTML注释块，含原始问题和关键参数（见下方格式） | — |
| `{{SCENE_DESC}}` | 场景分析一句话描述 | `四台相机静止安装，分别拍摄大物料四个角……` |
| `{{PARAMS_TABLE}}` | 关键参数表格的 `<tr>` 行，每行格式：`<tr><td>参数名</td><td>值</td></tr>` | — |
| `{{FLOW_NODES}}` | 定位方案思路的流程节点 HTML（`fb` 类节点 + `fa` 箭头），展示方案设计者的思考路径，每步概括"做什么+为什么" | — |
| `{{FLOW_TIP}}` | 思路图下方的绿色 `tip` 提示块；无需提示时填空字符串 | `<div class="tip">💡 …</div>` |
| `{{VM_FLOW}}` | VM视觉流程图内容：包含标定流程和生产流程两部分，每部分用 `<h3>` 标题 + SVG绝对定位流程图表示（见下方VM流程图规范） | — |
| `{{OPS_CONTENT}}` | 操作要点卡片内容：三色阶段块（`phase pc/pt/pp`）+ 步骤列表 | — |
| `{{WARNINGS}}` | 注意事项：1~3个 `warn` 块 | `<div class="warn">⚠️ …</div>` |
| `{{REF_DOCS}}` | 参考文档列表的 `<li>` 行（只写文件名，不带目录路径） | `<li>双相机定位引导应用案例.md</li>` |

**`{{META_COMMENT}}` 格式**：
```
<!-- 元信息
生成时间：YYYY-MM-DD HH:mm
模式：方案设计
用户原始问题：{完整复述}
关键参数：
  相机数量：…
  应用类型：…
  机构类型：…
  旋转需求：…
  标定条件：…
-->
```

---

## 问题诊断模板占位符（template-diagnosis.html）

> **模板布局已固化**：卡片顺序、标题文字（无 emoji）、排查路径四节点、摘要四行、排查清单三级 phase 块、CSS 均为固定结构，**不要改动这些骨架**。每次诊断只替换下表占位符里的可变内容。固化样本参考：`samples/诊断_十二点标定后角度越大偏差越大_含一致性验证.html`。

| 占位符 | 填写内容 |
|--------|---------|
| `{{TITLE}}` | 问题标题，5~15字（同时用于 `<title>` 和 `<h1>`，不加 emoji） |
| `{{DATETIME}}` | 生成时间，格式 `YYYY-MM-DD HH:mm` |
| `{{META_COMMENT}}` | HTML注释块（同上，模式改为"问题诊断"） |
| `{{DIAG_CONCLUSION}}` | 一句话诊断结论（模板已套 `<strong>` 加粗，只填纯文本） |
| `{{DIAG_DESC}}` | 诊断结论的补充说明段落（2~3句，解释为什么） |
| `{{SYM_PHENOMENON}}` | 摘要表"问题现象"行的值 |
| `{{SYM_ERRORDATA}}` | 摘要表"误差数据"行的值（具体数值） |
| `{{SYM_CONFIG}}` | 摘要表"系统配置"行的值（相机/机构/标定方式） |
| `{{SYM_CAUSE}}` | 摘要表"初步原因"行的值 |
| `{{CHECK_TIP}}` | 排查路径下方提示块（绿色 `tip` 或橙色 `warn`）；无需时填空字符串 |
| `{{CALIB_REPORT}}` | 标定文件分析卡片（有标定文件时填，无则填空字符串）；固定内部结构见下方"标定分析卡片固化结构" |
| `{{CHECK_NOW}}` | "立即检查（5分钟）"的 `<li>…</li>` 条目（直接放在已固化的 `<ul class="cl">` 内） |
| `{{CHECK_SHORT}}` | "短期排查（当天）"的 `<li>…</li>` 条目 |
| `{{CHECK_DEEP}}` | "深度排查（需规划）"的 `<li>…</li>` 条目 |
| `{{SOLUTION_STEPS}}` | 解决方案编号步骤，每步格式：`<li><span class="sn">N</span>步骤内容</li>` |
| `{{VERIFY_TIP}}` | 验证方法绿色 `tip` 块 |
| `{{REF_DOCS}}` | 参考文档列表的 `<li>` 行 |

> **固定结构（禁止改动）**：
> - **排查路径四节点**：`机构及成像 → 标定过程 → 示教过程 → 生产过程`，节点配色和箭头已写死在模板里。
> - **摘要表四行**：问题现象 / 误差数据 / 系统配置 / 初步原因，行标题已写死，只填值。
> - **排查清单三级 phase 块**：立即检查（`phase pt`）/ 短期排查（`phase pc`）/ 深度排查（`phase pp`），块标题和 `<ul class="cl">` 已写死，只填 `<li>` 条目。

### 标定分析卡片固化结构（{{CALIB_REPORT}} 填写规则）

仅当客户提供标定文件、调用 `scripts/calib_analyzer.py` 得到 12 项结果时填入；否则 `{{CALIB_REPORT}}` 替换为空字符串。卡片结构固定如下，按 `analyze_calib_*()` 返回的 12 项顺序逐行生成，判定列用 `<td class="pass">PASS</td>` 或 `<td class="fail">FAIL</td>`：

```html
<div class="card">
  <h2>标定文件分析报告</h2>
  <p style="font-size:13px;margin:0 0 10px;color:#666;">文件来源：…导出（创建时间） | 像素当量约 X mm/像素 | 12项检测中 <span class="fail">N项未通过</span></p>
  <table>
    <tr><th>#</th><th>检测项</th><th>实测值</th><th>标准</th><th>判定</th><th>排查方向</th></tr>
    <!-- 12 行：每行 <td>seq</td><td>name</td><td>display</td><td>standard</td><td class="pass/fail">PASS/FAIL</td><td>fix</td> -->
  </table>
  <div class="warn"><strong>关键发现</strong>：…用一句通俗的话点出最关键的未通过项及其与现象的因果关系。</div>
</div>
```

---

## CSS 类速查

生成 `{{OPS_CONTENT}}`、`{{FLOW_NODES}}` 等动态块时参考：

| 用途 | 类名组合 |
|------|---------|
| 蓝色流程节点（标定/采集相关） | `fb fb-b` |
| 绿色流程节点（示教/完成状态） | `fb fb-g` |
| 橙色流程节点（生产计算步骤） | `fb fb-o` |
| 红色流程节点（输出/结果） | `fb fb-r` |
| 流程箭头 | `<span class="fa">→</span>` |
| 蓝色标定阶段块 | `phase pc` |
| 绿色示教阶段块 | `phase pt` |
| 橙色生产阶段块 | `phase pp` |
| 蓝色编号步骤圆圈 | `sn` |
| 绿色编号步骤圆圈 | `sn sn-g` |
| 橙色编号步骤圆圈 | `sn sn-o` |
| 可勾选排查项列表 | `cl` |
| 橙色警告块 | `warn` |
| 绿色提示块 | `tip` |
| 文档列表 | `rl` |

---

## VM视觉流程图规范（{{VM_FLOW}} 填写规则）

> **铁律：所有 VM 流程图必须通过 `${SKILL_DIR}/scripts/vm_flow_builder.py` 生成，禁止在临时脚本中手写 `<svg>` / `<polyline>` / `<line>` / `style="left:...px"` 等绝对坐标。** 一旦绕开脚本手写 SVG，节点中心 x、行间距、画布尺寸、合并线 via_y 都会算错，必出现"连线错位、节点重复、文本溢出"等故障。

### {{VM_FLOW}} 整体结构

由若干 `<h3>` 标题 + 流程图组成，每个流程图由一个 `vm_flow_builder` 函数返回：

```html
<h3>标定流程</h3>
{{ vb.single_cam_calib_flow('arr-calib', '平移旋转标定') 的返回值 }}
<h3>生产流程</h3>
{{ vb.single_cam_prod_flow('arr-prod', '单点纠偏') 的返回值 }}
```

每个流程图自带一个唯一的 `flow_id`（作为 SVG marker id），在同一页面内的多个流程图必须传不同的 `flow_id`，否则箭头互相覆盖。

### 推荐：直接用预制函数

| 函数 | 适用场景 |
|------|---------|
| `single_cam_calib_flow(flow_id, calib_module='平移旋转标定', has_comm=True)` | 单相机九点/十二点标定（含通信列） |
| `single_cam_prod_flow(flow_id, calc_module='单点抓取')` | 单相机抓取/纠偏生产流程 |
| `dual_cam_mapping_calib_flow(flow_id)` | 上下相机映射标定（上相机带缓存图像） |
| `dual_cam_prod_flow(flow_id, calc_module='单点映射对位')` | **仅限单点映射对位场景**（该模块内部接受双路输入）；其它"两列特征→计算模块"的双相机场景不要直接套用 |
| `dual_cam_separate_calib_prod_flow(flow_id, calc_module, transform_label, transform_small)` | 上下相机各自十二点标定 + 坐标转换 + 单点纠偏（无标定板对位） |
| `dual_cam_separate_baseline_prod_flow(flow_id)` | 上下相机各自基准对位生产流程：下相机纠偏+旋转计算+变量计算，上相机仅特征提取，合并单点抓取（参考 assets/4.对应VM流程/各自基准对位流程/） |
| `dual_cam_same_side_twelve_point_prod_flow(flow_id)` | 双相机同侧双十二点抓取/纠偏生产流程：主辅各拍对角→标定转换至机构→点点测量求中点→标定转换回主相机像素→单点抓取（参考 assets/4.对应VM流程/双相机纠偏流程/双相机纠偏生产流程.html） |

> ⚠️ **单点抓取/单点纠偏 vs 单点映射对位的输入差异**（必须区分）：
> - **单点抓取 / 单点纠偏**：仅接受**单路像素坐标**输入。双相机场景下必须先在外部完成"特征统一到主相机坐标系"才能输入，流程图必须显式画出"标定转换+点点测量+标定转换"桥梁。
> - **单点映射对位**：模块内部直接接受双路输入（目标特征点+对象特征点），上下相机的特征可分别接入，两列可直接汇入计算模块。
>
> 双相机同侧抓取/纠偏场景如果错把 `dual_cam_prod_flow` 直接套用到单点抓取/单点纠偏，会导致流程图缺失中间桥梁——这是必须避免的错误。

调用示例：

```python
import sys
sys.path.insert(0, r'${SKILL_DIR}/scripts')
import vm_flow_builder as vb

vm_flow_html = (
    '<h3>标定流程</h3>' + vb.single_cam_calib_flow('arr-calib', '平移旋转标定') +
    '<h3>生产流程</h3>' + vb.single_cam_prod_flow('arr-prod', '单点纠偏')
)
```

### 新场景：用 column + connect + assemble 自定义

**新增预制函数前先判断"拓扑是否真的不同"：**
- 若新场景与上述某预制函数**图结构相同**（列数、合并方式、分支位置一致），仅节点标签 / 模块名不同 → **优先给现有函数加参数**（如 `calc_module` / `calib_module` / `transform_label`），禁止为纯标签差异新增函数。
- 只有图结构**真正不同**时，才**在 `vm_flow_builder.py` 中新增一个预制函数**（用 `column / connect / assemble` 组合），再调用——绝不在临时脚本中拼 SVG 字符串。
- 新增后若发现与已有函数骨架高度相似，应合并为一个参数化函数，而非保留多份近似重复。

```python
from vm_flow_builder import column, connect, assemble

def my_custom_flow(flow_id):
    # 一列竖向节点：第3行有分支节点、最后一行用深色终止样式
    main = column(
        cx=120,
        labels=['图像源', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', '单点抓取', '格式化', '发送数据'],
        branches={3: '直线查找(角度查找)'},
        ends={6},
    )
    # 右侧通信列
    comm = column(cx=400, labels=['接收数据', '协议解析'])
    # 跨列连线：协议解析 → 单点抓取（无箭头，避免与主列箭头重叠）
    extras = [connect(comm.last, main.find('单点抓取'), id_=flow_id, arrow=False)]
    # 自动算画布尺寸，组装成完整 <div><svg/><nodes/></div>
    return assemble(flow_id, main, comm, extra_lines=extras)
```

`column()` 关键参数：
- `cx`：列中心 x；`labels`：节点标签（自上而下）
- `branches={i: '分支标签'}`：在第 i 行右侧加分支节点，自动生成 fork+merge 折线
- `ends={i}`：哪些行用深色终止样式（一般是最后一行的"发送数据"）
- `gaps={i: n}`：在第 i 行之后留 n 个空行（用于跨列对齐，例如下相机列没有"缓存图像"时）
- `widths={i: w}` / `smalls={i: '附加说明'}`：宽节点 / 多行文本节点（高度自适应）

`connect(from_node, to_node, id_, via_y=None, arrow=True)`：跨列 L 形连线，`via_y` 默认 `to_node.top - 25`（多条线汇入同一节点会自动共享水平段）；汇入同一节点的多条线只让其中一条 `arrow=True`，其它 `arrow=False`。

`assemble(flow_id, *parts, extra_lines)`：把 `Column`/`Node` 组装成完整 HTML，画布宽高由所有节点 right/bottom 自动算出，保证"发送数据"完整可见。

### 允许使用的VM模块名称（严格按此列表，禁止自造模块名）

| 类别 | 模块名 |
|------|--------|
| 取图 | 图像源 |
| 通信 | 接收数据、协议解析、发送数据 |
| 粗定位 | 轮廓匹配(粗定位) |
| 修正 | 位置修正 |
| 精定位 | 圆查找(精定位)、直线查找(角度查找)、四边形查找 |
| 标定 | 平移旋转标定、映射标定、相机映射 |
| 生产计算 | 单点抓取、单点纠偏、单点映射对位 |
| 数据处理 | 旋转计算、变量计算 |
| 输出 | 格式化、发送数据 |

> 精定位节点根据实际特征选择：圆特征用"圆查找(精定位)"，需要角度用"直线查找(角度查找)"，两者都需要则用 `branches` 参数并排。
