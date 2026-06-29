# Generate 命令 — 从 HTML 视觉流程图生成 sol 方案

`generate` 命令把 `2d-vision-guidance-expert` 输出的 HTML 方案文档转成一个可被 VisionMaster 打开的 `.sol` 文件。

## 用法

```
VMSolutionParser.Cli.exe generate -f input.html [-o output.sol]
    [--base base.sol]          # 默认 templates/Template_moduel.sol
    [--templates dir]          # 默认探测 exe/templates、exe/../templates、cwd/templates
    [-p password]
```
> `-o` 可选，省略时自动用输入 HTML 的文件名（去掉扩展名）+.sol 作为输出名。例如 `-f 方案.html` → `方案.sol`。

执行后产出：
- `output.sol`：新方案

## 设计原则

generate 不再"挑一个已有方案再删模块"，而是从空模板从零拼装：

1. **基底是 templates/Template_moduel.sol**：内容上只有 1 个空 Procedure 和 1 个 Solution，没有全局相机/通信/变量/Binding，开销最小、无残留
2. **第 1 个 HTML 流程 → 基底 Procedure 重命名**：基底已有的空流程（id=10000）被改名成 HTML 第 1 个 `<h3>` 标题
3. **第 2..N 个 HTML 流程 → addProcedure**：在 ProcedureBase 和 ProcedureInsideModules 中追加一条 `<Procedure>`，并复制基底空流程的 raw 字节作为 procedure-NNNN-data
4. **HTML 节点 → addModule**：按节点中文标签在词表中查到对应 VM 模块类，再到 `templates/` 各文件夹找模板模块，复制 RawFrameData
5. **HTML 边 → setConnection**：在 `<ModuleCommonConnect>` 中写入 Front + Following 双向条目
6. **垂直布局**：每个流程内节点按 HTML `top` 升序排，X 固定、Y 步进；VM 自动把连线渲染成"下沿→上沿"

## 默认基底

| 情况 | 基底 |
|------|------|
| 1+ 个 HTML 流程 | `templates/Template_moduel.sol` |

用 `--base` 可覆盖（必须是能被 VM 4.4 打开的 sol；至少含 1 个 Procedure）。

## 内置词表（中文标签 → VM 模块类，首选模板）

| HTML 标签 | VM 模块类 | 首选模板模块 |
|----------|----------|----|
| 图像源 | ImageSourceModule | 单点抓取生产流程.图像源1 |
| 轮廓匹配 / 轮廓匹配(粗定位) | IMVSContourMatchModu | 单点抓取标定流程.轮廓匹配1 |
| 高精度匹配 | IMVSHPFeatureMatchModu | 单点抓取标定流程.高精度匹配1 |
| 位置修正 | IMVSFixtureModu | 单点抓取生产流程.位置修正1 |
| 圆查找 / 圆查找(精定位) | IMVSCircleFindModu | 单点抓取生产流程.圆查找1 |
| 直线查找 | IMVSLineFindModu | 单点抓取生产流程.直线查找 |
| 平移旋转标定 | TranslationCalibModu | 单点抓取标定流程.平移旋转标定1 |
| 单点抓取 | SinglePointGrabModu | 单点抓取生产流程.单点抓取1 |
| 单点纠偏 | SinglePointRectifyModu | 单点纠偏生产流程.单点纠偏1 |
| 单点映射对位 | SinglePointMapAlignModu | 上相机生产流程.单点映射对位1 |
| 格式化 | FormatModule | 单点抓取生产流程.格式化1 |
| 发送数据 | SendDatasModule | 单点抓取生产流程.发送数据1 |
| 接收数据 | ReadDatasModule | 单点抓取标定流程.接收数据1 |
| 旋转计算 | IMVSRotateCalculateModu | 下相机生产流程.旋转计算1 |
| 变量计算 | CalculatorModule | 下相机生产流程.变量计算1 |
| 协议解析 | DataAnalysisModule | 单点抓取标定流程.协议解析1 |

## 模板查找优先级

每个 HTML 节点解析后，按以下顺序查模板：

1. **首选模板**（上表）—— 命中即用
2. **跨文件夹回退**：如果首选模板缺失，遍历 `templates/` 下所有 sol，找同 Class 的模块（TypeId==0）；顺序：
   单点抓取流程 → 单点纠偏流程 → 单点映射对位流程 → 各自基准对位流程 → 双相机纠偏流程
3. **仍未命中**：把节点写入 `output.sol.generate.json.ignoredNodes`，跳过（提示而不失败）

## 词表扩展：`templates/index.json`

放在 `templates/index.json` 即可覆盖/扩展内置词表（不存在时跳过）：

```json
{
  "baseSolution": "Template_moduel.sol",
  "modules": {
    "中文标签": {
      "class": "VM 模块类名",
      "from": "相对 templates/ 的 sol 路径",
      "module": "模板模块 FullPath",
      "aliases": ["别名1", "别名2"]
    }
  }
}
```

## HTML 结构假设（与 vm_flow_builder.py 对齐）

- 每个 `<h3>` 标题下紧跟流程图容器
- 节点 = `<div style="position:absolute; left:Xpx; top:Ypx; width:Wpx; ...">中文标签</div>`
- 边 = SVG `<line x1 y1 x2 y2>` 或 `<polyline points="x1,y1 x2,y2 ...">`
- 边端点几何匹配到节点边框（容差 12 px）

## 局限

1. **不复制订阅**：新模块只复制 RawFrameData，不复制 VmServer.xml 中的 `<Subscribe>`。VM 打开能成功，但新模块的输入参数（如图像源的相机绑定、发送数据的通信通道）需要打开 VM 后手动绑定，或 generate 后再走 `modify -c changes.json` 用 setSubscription 补齐。
2. **未知中文标签自动忽略**：会在终端输出的 ignoredNodes 警告中列出对应节点。若希望失败而非跳过，可在 changes JSON 里手工补齐 addModule。
3. **基底是空模板，无全局相机/通信**：图像源、发送数据等模块没有可绑定对象，需在 VM 中手动添加全局资源后再绑定。

## 验证清单

generate 后建议运行：

```
# 1. 结构 round-trip：再 parse 看是否解析无错
tools/VMSolutionParser.Cli.exe parse -f output.sol -o /tmp/check.json

# 2. 模块列表对照：新增模块都在
tools/VMSolutionParser.Cli.exe inspect --list -f output.sol

# 3. 与基底 diff
tools/VMSolutionParser.Cli.exe compare -f1 templates/Template_moduel.sol -f2 output.sol --verbose

# 4. 用 VM 4.4 打开 output.sol — 最终验收
```
