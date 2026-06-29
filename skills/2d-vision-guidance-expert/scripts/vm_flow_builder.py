"""
VM视觉流程图 HTML 构建工具库

公共 API：
  - 配置驱动一键生成（推荐，无需临时脚本）：
      build_solution_from_config(config_dict)  -> (html_path, sol_path)
      CLI: python vm_flow_builder.py config.json

  - 高层预制流程（需要自定义 HTML 卡片内容时使用）：
      single_cam_calib_flow(flow_id, calib_module, has_comm, has_angle)
      single_cam_prod_flow(flow_id, calc_module, has_angle)
      dual_cam_mapping_calib_flow(flow_id)
      dual_cam_prod_flow(flow_id, calc_module)
      dual_cam_separate_calib_prod_flow(flow_id, calc_module, transform_label, transform_small)
      dual_cam_separate_baseline_prod_flow(flow_id)
      dual_cam_same_side_twelve_point_prod_flow(flow_id, calc_module)

  - 低层声明式组合（用于新场景，禁止再手写 SVG 坐标）：
      column(cx, labels, *, branches, ends, gaps, smalls, widths)  -> Column
      connect(from_node, to_node, *, id_, via_y, arrow)            -> str
      assemble(flow_id, *parts, extra_lines)                       -> str

  - HTML 写出：
      build_solution_html(filename, title, ..., export_dir)

规则：调用方禁止手写 <svg>/<polyline>/<line>/style="left:...px" 等绝对坐标。
若现有预制流程无法覆盖新场景，向本模块新增一个预制函数（用 column+connect+assemble 组合），再调用。
"""

import os
import subprocess
import inspect

SKILL_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATE = os.path.join(SKILL_DIR, 'assets', 'template-solution.html')

# ── 布局常量 ──────────────────────────────────────────────────────────────
NODE_W = 140                       # 标准节点宽度
NODE_H = 28                        # 标准节点高度
ROW_STEP = 70                      # 同列相邻节点 top-to-top 距离
ROW_GAP = ROW_STEP - NODE_H        # = 42, 节点之间的实际间隙
ARROW_GAP = 2                      # 线段终点距下一节点 top 的预留（给箭头留位置）
PAD_TOP = 30                       # 画布顶部留白（第一行 top 默认值）
PAD_BOTTOM = 30                    # 画布底部留白
PAD_X = 30                         # 画布左右留白
BRANCH_DX = 170                    # 分支节点相对主节点的水平偏移
MERGE_LANE_OFFSET = 25             # 跨列合并线水平段距目标节点 top 的距离
ARROW_COLOR = '#6E5BC7'


def _resolve_export_dir():
    """找到调用栈中第一个不在 skill 目录内的脚本，取其所在目录的 export/ 子目录。"""
    for frame_info in inspect.stack():
        caller = frame_info.filename
        if caller and os.path.abspath(SKILL_DIR) not in os.path.abspath(caller):
            return os.path.join(os.path.dirname(os.path.abspath(caller)), 'export')
    return os.path.join(os.getcwd(), 'export')


# ── 节点样式 / 连线原语（私有）───────────────────────────────────────────

def _node_style(end=False, multi=False, h=NODE_H):
    if end:
        bg, br, fg, fw = '#4A3FB5', '#4A3FB5', '#fff', '600'
    else:
        bg, br, fg, fw = '#ECE9F7', '#6E5BC7', '#3A2B7C', 'normal'
    if multi:
        return (f'position:absolute;height:{h}px;line-height:1.35;'
                f'background:{bg};border:1.5px solid {br};color:{fg};'
                f'border-radius:8px;text-align:center;font-size:12px;font-weight:{fw};'
                f'padding:4px 6px;box-sizing:border-box;')
    return (f'position:absolute;height:{NODE_H}px;line-height:{NODE_H}px;'
            f'background:{bg};border:1.5px solid {br};color:{fg};'
            f'border-radius:8px;text-align:center;font-size:13px;font-weight:{fw};'
            f'box-sizing:border-box;')


def _arrow_marker(id_):
    return (f'<marker id="{id_}" viewBox="0 0 10 10" refX="8" refY="5" '
            f'markerWidth="7" markerHeight="7" orient="auto">'
            f'<path d="M0,0 L10,5 L0,10 z" fill="{ARROW_COLOR}"/></marker>')


def _ln(x1, y1, x2, y2, id_, arrow=True):
    me = f' marker-end="url(#{id_})"' if arrow else ''
    return (f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="{ARROW_COLOR}" stroke-width="1.5"{me}/>')


def _poly(pts, id_, arrow=True):
    me = f' marker-end="url(#{id_})"' if arrow else ''
    return (f'<polyline points="{pts}" stroke="{ARROW_COLOR}" stroke-width="1.5" '
            f'fill="none"{me}/>')


# ── 节点 / 列（公共 API）─────────────────────────────────────────────────

class Node:
    """单个流程图节点。

    cx     : 中心 x 坐标
    top    : 顶部 y 坐标
    label  : 节点标签（主文本）
    kind   : 'normal' | 'end'（end 用深色填充）
    small  : 多行附加说明（设了之后节点高度自适应）
    width  : 节点宽度，默认 NODE_W=140
    """

    def __init__(self, cx, top, label, kind='normal', small=None, width=NODE_W):
        self.cx = int(cx)
        self.top = int(top)
        self.w = int(width)
        self.label = label
        self.kind = kind
        self.small = small
        if small:
            n_lines = 1 + len([l for l in small.split('\n') if l.strip()])
            self.h = max(NODE_H, n_lines * 18 + 12)
        else:
            self.h = NODE_H

    @property
    def left(self):
        return self.cx - self.w // 2

    @property
    def right(self):
        return self.cx + self.w // 2

    @property
    def bottom(self):
        return self.top + self.h

    def render(self):
        end = (self.kind == 'end')
        if self.small:
            style = _node_style(end=end, multi=True, h=self.h)
            small_html = '<br/>'.join(self.small.split('\n'))
            inner = (f'<div style="font-weight:600;">{self.label}</div>'
                     f'<div style="font-size:11px;opacity:0.85;">{small_html}</div>')
        else:
            style = _node_style(end=end)
            inner = self.label
        return (f'<div style="{style}left:{self.left}px;top:{self.top}px;'
                f'width:{self.w}px;">{inner}</div>')


class Column:
    """一列竖向排列的节点（主节点链 + 可选右侧分支节点）。"""

    def __init__(self, cx, nodes, branches):
        self.cx = cx
        self.nodes = nodes              # list[Node]，主链
        self.branches = branches        # dict[int_row → Node]

    def find(self, label):
        for n in self.nodes:
            if n.label == label:
                return n
        for n in self.branches.values():
            if n.label == label:
                return n
        raise KeyError(f'Column has no node labeled {label!r}')

    @property
    def all_nodes(self):
        return list(self.nodes) + list(self.branches.values())

    @property
    def first(self):
        return self.nodes[0]

    @property
    def last(self):
        return self.nodes[-1]

    def render_lines(self, id_):
        """生成本列内部所有连线 SVG（主竖向线 + 分支 fork/merge）。"""
        out = []
        # 主竖向流程：每对相邻主节点之间画一条带箭头的直线
        for i in range(len(self.nodes) - 1):
            a, b = self.nodes[i], self.nodes[i + 1]
            out.append(_ln(a.cx, a.bottom, b.cx, b.top - ARROW_GAP, id_))
        # 分支处理
        for i, branch in self.branches.items():
            parent = self.nodes[i]
            # fork：从上一行 bottom 分叉到分支节点 top
            if i > 0:
                src = self.nodes[i - 1]
                fork_y = (src.bottom + parent.top) // 2
                out.append(_poly(
                    f'{src.cx},{src.bottom} {src.cx},{fork_y} '
                    f'{branch.cx},{fork_y} {branch.cx},{branch.top - ARROW_GAP}',
                    id_))
            # merge：分支节点汇回主列
            if i < len(self.nodes) - 1:
                # 非末行：从分支 bottom 出发 → 折回主列 → 连到下一行节点 top
                # 参考 下相机标定流程.html: 280,268→280,285→120,285→120,308
                nxt = self.nodes[i + 1]
                lane_y = nxt.top - MERGE_LANE_OFFSET
                out.append(_poly(
                    f'{branch.cx},{branch.bottom} {branch.cx},{lane_y} '
                    f'{parent.cx},{lane_y} {parent.cx},{nxt.top - ARROW_GAP}',
                    id_, arrow=False))
            else:
                # 末行：从分支 top 出发 → 向下 → 向左回到主列 cx
                # 参考 单点映射对位生产流程.html: 300,240→300,280→100,280→100,290
                lane_y = branch.top + 40
                end_y = lane_y + 10
                out.append(_poly(
                    f'{branch.cx},{branch.top} {branch.cx},{lane_y} '
                    f'{parent.cx},{lane_y} {parent.cx},{end_y}',
                    id_, arrow=False))
        return ''.join(out)


def column(cx, labels, *, top_start=PAD_TOP, branches=None, ends=None,
           gaps=None, widths=None, smalls=None):
    """构造一列竖向节点。

    cx          : 列中心 x 坐标
    labels      : list[str]，节点标签（自上而下）
    top_start   : 第一个节点的 top（默认 PAD_TOP=30）
    branches    : dict[int → str | dict]
                  {3: '直线查找(角度查找)'} 在第 3 行右侧加分支节点
                  {3: {'label': '...', 'dx': 200}} 自定义水平偏移
    ends        : set[int]，哪些行用深色终止样式
    gaps        : dict[int → int]，在第 i 行之后插入 n 个额外 ROW_STEP 的空行（用于跨列对齐）
    widths      : dict[int → int]，覆盖默认 NODE_W
    smalls      : dict[int → str]，多行附加文本（节点高度自适应）
    """
    branches = branches or {}
    ends = ends or set()
    gaps = gaps or {}
    widths = widths or {}
    smalls = smalls or {}

    nodes = []
    y = top_start
    for i, label in enumerate(labels):
        node = Node(cx, y, label,
                    kind='end' if i in ends else 'normal',
                    small=smalls.get(i),
                    width=widths.get(i, NODE_W))
        nodes.append(node)
        y = node.bottom + ROW_GAP + gaps.get(i, 0) * ROW_STEP

    branch_nodes = {}
    for i, spec in branches.items():
        if i == 0:
            raise ValueError('branch at row 0 not supported')
        if isinstance(spec, str):
            b_label, b_dx = spec, BRANCH_DX
        else:
            b_label = spec['label']
            b_dx = spec.get('dx', BRANCH_DX)
        parent = nodes[i]
        branch_nodes[i] = Node(parent.cx + b_dx, parent.top, b_label)

    return Column(cx, nodes, branch_nodes)


def connect(from_node, to_node, *, id_, via_y=None, arrow=True, hidden=False):
    """生成跨列/跨节点的 L 形连线（先竖直→水平→竖直）。

    from_node, to_node : Node
    via_y              : 水平段所在的 y 坐标；默认 to_node.top - MERGE_LANE_OFFSET，
                         并自动 clamp 到 ≥ from_node.bottom + 5
    arrow              : 是否在终点画箭头（多线汇合时只让其中一条带箭头，避免叠加）
    hidden             : 透明不可见，仅供 HtmlFlowParser 解析用
    """
    if via_y is None:
        via_y = max(to_node.top - MERGE_LANE_OFFSET, from_node.bottom + 5)
    pts = (f'{from_node.cx},{from_node.bottom} {from_node.cx},{via_y} '
           f'{to_node.cx},{via_y} {to_node.cx},{to_node.top - ARROW_GAP}')
    line = _poly(pts, id_, arrow=arrow)
    if hidden:
        line = line.replace(f'stroke="{ARROW_COLOR}"', 'stroke="transparent"')
    return line


def assemble(flow_id, *parts, extra_lines=None):
    """组装 Column / Node / 自定义连线 为最终 <div><svg/><nodes/></div>。

    parts       : Column 或 Node 实例
    extra_lines : list[str]，由 connect() 生成的跨列连线 SVG 字符串

    画布宽高根据所有节点的 right/bottom 自动计算（加上 PAD_X/PAD_BOTTOM 留白）。
    """
    all_nodes = []
    all_lines = []
    for p in parts:
        if isinstance(p, Column):
            all_nodes.extend(p.all_nodes)
            all_lines.append(p.render_lines(flow_id))
        elif isinstance(p, Node):
            all_nodes.append(p)
        else:
            raise TypeError(f'assemble parts must be Column or Node, got {type(p).__name__}')
    if extra_lines:
        all_lines.extend(extra_lines)
    if not all_nodes:
        raise ValueError('assemble: no nodes provided')

    canvas_w = max(n.right for n in all_nodes) + PAD_X
    canvas_h = max(n.bottom for n in all_nodes) + PAD_BOTTOM

    nodes_html = ''.join(n.render() for n in all_nodes)
    lines_html = ''.join(all_lines)
    svg = (f'<svg width="{canvas_w}" height="{canvas_h}" '
           f'style="position:absolute;top:0;left:0;pointer-events:none;">'
           f'<defs>{_arrow_marker(flow_id)}</defs>{lines_html}</svg>')
    return (f'<div style="position:relative;width:{canvas_w}px;height:{canvas_h}px;'
            f'margin-bottom:16px;">{svg}{nodes_html}</div>')


# ── 高层预制流程 ──────────────────────────────────────────────────────────

def single_cam_calib_flow(flow_id, calib_module='平移旋转标定', has_comm=True,
                          has_angle=True):
    """单相机标定流程（九点/十二点）。

    calib_module : 标定模块名称
    has_comm     : 是否包含右侧 接收数据→协议解析 通信列
    has_angle    : 是否包含 直线查找(角度查找) 分支（无旋转场景可省略）
    """
    main = column(
        cx=120,
        labels=['图像源', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', calib_module, '格式化', '发送数据'],
        branches={3: '直线查找(角度查找)'} if has_angle else {},
        ends={6},
    )
    parts = [main]
    extras = []
    if has_comm:
        comm = column(cx=400, labels=['接收数据', '协议解析'])
        parts.append(comm)
        extras.append(connect(comm.last, main.find(calib_module),
                              id_=flow_id, arrow=False))
    return assemble(flow_id, *parts, extra_lines=extras)


def single_cam_prod_flow(flow_id, calc_module='单点抓取', has_angle=True):
    """单相机生产流程（单点抓取/单点纠偏）。

    has_angle : 是否包含 直线查找(角度查找) 分支（无旋转场景可省略）
    """
    main = column(
        cx=120,
        labels=['图像源', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', calc_module, '格式化', '发送数据'],
        branches={3: '直线查找(角度查找)'} if has_angle else {},
        ends={6},
    )
    return assemble(flow_id, main)


def dual_cam_mapping_calib_flow(flow_id):
    """上下相机映射标定流程（上相机带缓存图像）。"""
    down = column(
        cx=120,
        labels=['图像源(下相机)', '轮廓匹配(粗定位)', '位置修正', '四边形查找'],
        gaps={0: 1},  # 下相机无 "缓存图像"，留一行空位与上相机对齐
    )
    up = column(
        cx=400,
        labels=['图像源(上相机)', '缓存图像', '轮廓匹配(粗定位)', '位置修正', '四边形查找'],
    )
    bottom_cx = (down.cx + up.cx) // 2
    bottom_top = max(down.last.bottom, up.last.bottom) + ROW_GAP + 30
    bottom = column(
        cx=bottom_cx,
        labels=['相机映射', '格式化', '发送数据'],
        top_start=bottom_top,
        ends={2},
    )
    extras = [
        connect(down.last, bottom.first, id_=flow_id),
        connect(up.last, bottom.first, id_=flow_id, arrow=False),
    ]
    return assemble(flow_id, down, up, bottom, extra_lines=extras)


def dual_cam_prod_flow(flow_id, calc_module='单点映射对位'):
    """双相机生产流程：两列精定位 → 计算模块 → 格式化 → 发送数据。"""
    down = column(
        cx=120,
        labels=['图像源(下相机)', '轮廓匹配(粗定位)', '位置修正', '圆查找(精定位)'],
        branches={3: '直线查找(角度查找)'},
    )
    up = column(
        cx=520,
        labels=['图像源(上相机)', '轮廓匹配(粗定位)', '位置修正', '圆查找(精定位)'],
        branches={3: '直线查找(角度查找)'},
    )
    bottom_cx = (down.cx + up.cx) // 2
    bottom_top = max(down.last.bottom, up.last.bottom) + ROW_GAP + 30
    bottom = column(
        cx=bottom_cx,
        labels=[calc_module, '格式化', '发送数据'],
        top_start=bottom_top,
        ends={2},
    )
    extras = [
        connect(down.last, bottom.first, id_=flow_id),
        connect(up.last, bottom.first, id_=flow_id, arrow=False),
        # 末行分支→合并列（透明不可见，仅供 HtmlFlowParser 解析）
        connect(down.branches[3], bottom.first, id_=flow_id, hidden=True),
        connect(up.branches[3], bottom.first, id_=flow_id, hidden=True),
    ]
    return assemble(flow_id, down, up, bottom, extra_lines=extras)


def single_cam_plate_calib_flow(flow_id, camera_label='主相机'):
    """单相机标定板标定流程：图像源 → 标定板标定 → 格式化 → 发送数据。

    用于同侧双相机有大标定板场景，各相机分别做标定板标定统一到标定板坐标系。
    """
    col = column(
        cx=120,
        labels=[f'图像源({camera_label})', '标定板标定', '格式化', '发送数据'],
        ends={3},
    )
    return assemble(flow_id, col)


def dual_cam_separate_calib_prod_flow(flow_id, calc_module='单点纠偏',
                                       transform_label='坐标转换模块',
                                       transform_small='上目标→机构坐标→补偿→下相机像素'):
    """上下相机各自十二点标定 + 坐标转换 + 单点纠偏 的生产流程（无标定板对位场景）。

    标定阶段两相机各自调用 single_cam_calib_flow；本函数仅生成生产流程。
    """
    down = column(
        cx=120,
        labels=['图像源(下相机)', '轮廓匹配(粗定位)', '位置修正', '圆查找(精定位)'],
        branches={3: '直线查找(角度查找)'},
    )
    up = column(
        cx=520,
        labels=['图像源(上相机)', '轮廓匹配(粗定位)', '位置修正', '圆查找(精定位)'],
        branches={3: '直线查找(角度查找)'},
    )
    bottom_cx = (down.cx + up.cx) // 2
    bottom_top = max(down.last.bottom, up.last.bottom) + ROW_GAP + 40
    bottom = column(
        cx=bottom_cx,
        labels=[transform_label, calc_module, '格式化', '发送数据'],
        top_start=bottom_top,
        widths={0: 220},
        smalls={0: transform_small},
        ends={3},
    )
    extras = [
        connect(down.last, bottom.first, id_=flow_id),
        connect(up.last, bottom.first, id_=flow_id, arrow=False),
        # 末行分支→合并列（透明不可见，仅供 HtmlFlowParser 解析）
        connect(down.branches[3], bottom.first, id_=flow_id, hidden=True),
        connect(up.branches[3], bottom.first, id_=flow_id, hidden=True),
    ]
    return assemble(flow_id, down, up, bottom, extra_lines=extras)


def dual_cam_separate_baseline_prod_flow(flow_id):
    """上下相机各自基准对位生产流程（无标定板，各自基准方式）。

    下相机列：特征提取 → 单点纠偏 → 旋转计算 → 变量计算
    上相机列：仅特征提取（不做偏差计算）
    合并列：单点抓取 → 格式化 → 发送数据

    对应 assets/4.对应VM流程/各自基准对位流程/各自基准对位生产流程.html
    标定阶段两相机各自调用 single_cam_calib_flow。
    """
    down = column(
        cx=100,
        labels=['图像源(下相机)', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', '单点纠偏', '旋转计算', '变量计算'],
        branches={3: '直线查找(角度查找)'},
    )
    up = column(
        cx=460,
        labels=['图像源(上相机)', '轮廓匹配(粗定位)', '位置修正', '圆查找(精定位)'],
        branches={3: '直线查找(角度查找)'},
    )
    # 合并列与上相机列同 cx，位于其下方
    bottom_top = max(down.last.bottom, up.last.bottom) + ROW_GAP + 50
    bottom = column(
        cx=460,
        labels=['单点抓取', '格式化', '发送数据'],
        top_start=bottom_top,
        ends={2},
    )
    extras = [
        connect(down.last, bottom.first, id_=flow_id),
        connect(up.last, bottom.first, id_=flow_id, arrow=False),
    ]
    return assemble(flow_id, down, up, bottom, extra_lines=extras)


def dual_cam_same_side_twelve_point_prod_flow(flow_id, calc_module='单点抓取',
                                               main_transform='标定转换(主→机构)',
                                               aux_transform='标定转换(辅→机构)',
                                               merge_transform='标定转换(机构→主相机)'):
    """双相机同侧生产流程（支持无标定板双十二点 / 有大标定板两种变体）。

    主相机列：特征提取 → main_transform
    辅相机列：特征提取 → aux_transform
    合并列：点点测量 → merge_transform → calc_module → 格式化 → 发送数据

    无标定板变体（默认）：
      main_transform='标定转换(主→机构)', aux_transform='标定转换(辅→机构)',
      merge_transform='标定转换(机构→主相机)'
    有大标定板变体：
      main_transform='标定转换(主→标定板)', aux_transform='标定转换(辅→标定板)',
      merge_transform='标定转换(标定板→主相机)'

    对应 assets/2.生产计算原理/双相机定位引导应用案例.md §2.2 偏差计算方案
    及 assets/4.对应VM流程/双相机纠偏流程/双相机纠偏生产流程.html。
    """
    main = column(
        cx=120,
        labels=['图像源(主相机)', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', main_transform],
        branches={3: '直线查找(角度查找)'},
    )
    aux = column(
        cx=520,
        labels=['图像源(辅相机)', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', aux_transform],
        branches={3: '直线查找(角度查找)'},
    )
    bottom_cx = (main.cx + aux.cx) // 2
    bottom_top = max(main.last.bottom, aux.last.bottom) + ROW_GAP + 40
    bottom = column(
        cx=bottom_cx,
        labels=['点点测量', merge_transform, calc_module, '格式化', '发送数据'],
        top_start=bottom_top,
        ends={4},
    )
    extras = [
        connect(main.last, bottom.first, id_=flow_id),
        connect(aux.last, bottom.first, id_=flow_id, arrow=False),
    ]
    return assemble(flow_id, main, aux, bottom, extra_lines=extras)


def tri_cam_same_side_prod_flow(flow_id, calc_module='单点抓取',
                                 cam1_label='主相机', cam2_label='辅相机1', cam3_label='辅相机2',
                                 cam1_transform='标定转换(主→标定板)',
                                 cam2_transform='标定转换(辅1→标定板)',
                                 cam3_transform='标定转换(辅2→标定板)',
                                 merge_transform='标定转换(标定板→主相机)'):
    """三相机同侧生产流程（有大标定板场景，支持三相机以上扩展为参数化调用）。

    3 列并行特征提取 → 1 列合并（点点测量 → 标定转换 → calc_module → 格式化 → 发送数据）。

    对应 assets/2.生产计算原理/双相机定位引导应用案例.md §2.2 偏差计算方案 的三相机扩展版。
    与 dual_cam_same_side_twelve_point_prod_flow 的区别：列数（3 vs 2）。
    """
    cam1 = column(
        cx=80,
        labels=[f'图像源({cam1_label})', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', cam1_transform],
        branches={3: '直线查找(角度查找)'},
    )
    cam2 = column(
        cx=330,
        labels=[f'图像源({cam2_label})', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', cam2_transform],
        branches={3: '直线查找(角度查找)'},
    )
    cam3 = column(
        cx=580,
        labels=[f'图像源({cam3_label})', '轮廓匹配(粗定位)', '位置修正',
                '圆查找(精定位)', cam3_transform],
        branches={3: '直线查找(角度查找)'},
    )
    bottom_cx = 330
    bottom_top = max(cam1.last.bottom, cam2.last.bottom, cam3.last.bottom) + ROW_GAP + 40
    bottom = column(
        cx=bottom_cx,
        labels=['点点测量', merge_transform, calc_module, '格式化', '发送数据'],
        top_start=bottom_top,
        ends={4},
    )
    extras = [
        connect(cam1.last, bottom.first, id_=flow_id),
        connect(cam2.last, bottom.first, id_=flow_id),
        connect(cam3.last, bottom.first, id_=flow_id, arrow=False),
    ]
    return assemble(flow_id, cam1, cam2, cam3, bottom, extra_lines=extras)


# ── HTML 写出 ─────────────────────────────────────────────────────────────

def _read_css():
    with open(TEMPLATE, encoding='utf-8') as f:
        tmpl = f.read()
    return tmpl.split('<style>')[1].split('</style>')[0]


def build_solution_html(filename, title, datetime_str, meta_comment,
                        scene_desc, params_table_rows,
                        flow_nodes_html, flow_tip_html,
                        vm_flow_html, ops_content_html,
                        warnings_html, ref_docs_html,
                        export_dir=None, auto_generate_sol=True):
    """生成完整方案 HTML 并写出到 export_dir。返回 (html_path, sol_path)。

    export_dir       默认自动推断为调用脚本所在目录的 export/ 子目录。
    auto_generate_sol 是否自动调用 VMSolutionParser.Cli.exe 生成 .sol 方案（默认 True）。
                      CLI 不可用时自动跳过，不影响 HTML 写出。
    """
    if export_dir is None:
        export_dir = _resolve_export_dir()
    os.makedirs(export_dir, exist_ok=True)

    css = _read_css()
    out_path = os.path.join(export_dir, filename)

    html = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>{title} — 定位方案</title>
<style>{css}</style>
</head>
<body>

{meta_comment}

<div class="header">
  <h1>🎯 {title}</h1>
  <div class="sub">生成时间：{datetime_str} &nbsp;·&nbsp; 方案设计 &nbsp;·&nbsp; 定位引导</div>
</div>

<div class="card">
  <h2>📋 场景分析</h2>
  <p>{scene_desc}</p>
  <table>
    <tr><th>关键参数</th><th>确认值</th></tr>
    {params_table_rows}
  </table>
</div>

<div class="card">
  <h2>🗺️ 定位方案思路</h2>
  <div class="flow">
    {flow_nodes_html}
  </div>
  {flow_tip_html}
</div>

<div class="card">
  <h2>🔧 VM视觉流程图</h2>
  {vm_flow_html}
</div>

<div class="card">
  <h2>⚙️ 操作要点</h2>
  {ops_content_html}
</div>

<div class="card">
  <h2>⚠️ 注意事项</h2>
  {warnings_html}
</div>

<div class="card">
  <h2>📚 参考文档</h2>
  <ul class="rl">
    {ref_docs_html}
  </ul>
</div>

</body>
</html>'''

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(html)
    print(f'HTML 写出完成：{out_path}  ({os.path.getsize(out_path)} bytes)')

    sol_path = None
    if auto_generate_sol:
        sol_path, ok, _msg = generate_sol_from_html(out_path)
        if ok:
            pass  # CLI 已自动生成 generate.json 在同目录

    return out_path, sol_path


# ── sol 自动生成 ──────────────────────────────────────────────────────────

def _find_cli():
    """查找 VMSolutionParser.Cli.exe。

    优先从 vm-sol-format skill 的 tools/ 目录查找（与当前 skill 并列）。
    返回 (exe_path, templates_dir) 或 (None, None)。
    """
    skills_root = os.path.dirname(SKILL_DIR)
    cli = os.path.join(skills_root, 'vm-sol-format', 'tools', 'VMSolutionParser.Cli.exe')
    if os.path.isfile(cli):
        templates = os.path.join(skills_root, 'vm-sol-format', 'templates')
        return cli, templates
    return None, None


def generate_sol_from_html(html_path, cli_exe=None, templates_dir=None, base_sol=None):
    """从 HTML 方案文件生成 .sol 方案文件（调用 VMSolutionParser.Cli.exe）。

    参数：
        html_path    : HTML 方案文件路径
        cli_exe      : CLI 可执行文件路径（None 则自动查找）
        templates_dir: 模板目录（None 则自动查找）
        base_sol     : 基底 sol 文件（None 则使用 Template_moduel.sol）

    返回：(sol_path, success, message)
        sol_path : 生成的 .sol 文件路径（失败时为 None）
        success  : True/False
        message  : 描述信息
    """
    # 推导 .sol 输出路径（与 HTML 同名，.sol 扩展名）
    base, _ = os.path.splitext(html_path)
    sol_path = base + '.sol'

    # 自动查找 CLI
    if cli_exe is None or templates_dir is None:
        auto_cli, auto_tmpl = _find_cli()
        if cli_exe is None:
            cli_exe = auto_cli
        if templates_dir is None:
            templates_dir = auto_tmpl

    if cli_exe is None or not os.path.isfile(cli_exe):
        msg = ('[WARN] 未找到 VMSolutionParser.Cli.exe，跳过 .sol 生成。\n'
               '   请确保 vm-sol-format skill 已安装到相邻目录。')
        print(msg)
        return None, False, msg

    cmd = [cli_exe, 'generate', '-f', html_path, '-o', sol_path]
    if base_sol:
        cmd.extend(['--base', base_sol])
    if templates_dir:
        cmd.extend(['--templates', templates_dir])

    try:
        result = subprocess.run(cmd, capture_output=True, timeout=60)
        stdout = result.stdout.decode('utf-8', errors='replace') if result.stdout else ''
        stderr = result.stderr.decode('utf-8', errors='replace') if result.stderr else ''
        if result.returncode == 0:
            # 打印 CLI 的 stderr 警告（含 ignoredNodes 等关键提示）
            if stderr.strip():
                print(stderr.strip())
            # 检查 sol 是否实际写出
            if os.path.isfile(sol_path):
                size_kb = os.path.getsize(sol_path) / 1024
                msg = f'[OK] .sol 方案已生成：{sol_path}  ({size_kb:.1f} KB)'
                print(msg)
                return sol_path, True, msg
            else:
                msg = f'[WARN] CLI 返回成功但未找到输出文件：{sol_path}'
                print(msg)
                return None, False, msg
        else:
            msg = (f'[WARN] .sol 生成失败（exit={result.returncode}）：\n'
                   f'STDERR: {stderr.strip()[-500:]}\n'
                   f'STDOUT: {stdout.strip()[-500:]}')
            print(msg)
            return None, False, msg
    except FileNotFoundError:
        msg = f'[WARN] 无法执行 CLI：{cli_exe}'
        print(msg)
        return None, False, msg
    except subprocess.TimeoutExpired:
        msg = '[WARN] .sol 生成超时（>60s），已跳过'
        print(msg)
        return None, False, msg


# ── 配置驱动方案生成（一键替代临时脚本）──────────────────────────────────

# 支持的 VM 流程类型 → 预制函数 映射表
_FLOW_BUILDERS = {
    'single_cam_calib': lambda cfg, fid: single_cam_calib_flow(
        fid,
        calib_module=cfg.get('calib_module', '平移旋转标定'),
        has_comm=cfg.get('has_comm', True),
        has_angle=cfg.get('has_angle', True)),
    'single_cam_prod': lambda cfg, fid: single_cam_prod_flow(
        fid,
        calc_module=cfg.get('calc_module', '单点抓取'),
        has_angle=cfg.get('has_angle', True)),
    'single_cam_plate_calib': lambda cfg, fid: single_cam_plate_calib_flow(
        fid, camera_label=cfg.get('camera_label', '主相机')),
    'dual_cam_mapping_calib': lambda cfg, fid: dual_cam_mapping_calib_flow(fid),
    'dual_cam_prod': lambda cfg, fid: dual_cam_prod_flow(
        fid, calc_module=cfg.get('calc_module', '单点映射对位')),
    'dual_cam_separate_calib_prod': lambda cfg, fid: dual_cam_separate_calib_prod_flow(
        fid,
        calc_module=cfg.get('calc_module', '单点纠偏'),
        transform_label=cfg.get('transform_label', '坐标转换模块'),
        transform_small=cfg.get('transform_small', '')),
    'dual_cam_separate_baseline_prod': lambda cfg, fid: dual_cam_separate_baseline_prod_flow(fid),
    'dual_cam_same_side_twelve_point_prod': lambda cfg, fid: dual_cam_same_side_twelve_point_prod_flow(
        fid,
        calc_module=cfg.get('calc_module', '单点抓取'),
        main_transform=cfg.get('main_transform', '标定转换(主→机构)'),
        aux_transform=cfg.get('aux_transform', '标定转换(辅→机构)'),
        merge_transform=cfg.get('merge_transform', '标定转换(机构→主相机)')),
    'tri_cam_same_side_prod': lambda cfg, fid: tri_cam_same_side_prod_flow(
        fid,
        calc_module=cfg.get('calc_module', '单点抓取'),
        cam1_label=cfg.get('cam1_label', '主相机'),
        cam2_label=cfg.get('cam2_label', '辅相机1'),
        cam3_label=cfg.get('cam3_label', '辅相机2'),
        cam1_transform=cfg.get('cam1_transform', '标定转换(主→标定板)'),
        cam2_transform=cfg.get('cam2_transform', '标定转换(辅1→标定板)'),
        cam3_transform=cfg.get('cam3_transform', '标定转换(辅2→标定板)'),
        merge_transform=cfg.get('merge_transform', '标定转换(标定板→主相机)')),
}

_FLOW_TITLE_DEFAULTS = {
    'calib': '标定流程', 'calib_main': '主相机标定流程',
    'calib_aux': '辅相机标定流程', 'prod': '生产流程',
}


def build_solution_from_config(config):
    """从结构化配置 dict 生成完整方案 HTML + .sol。一键替代临时脚本。

    配置 schema（标记 `可选` 的字段可省略）：:

      {
        "filename":      "20260624-1037_方案_xxx.html",
        "title":         "单相机运动抓取-偏心旋转",
        "datetime":      "2026-06-24 10:37",
        "meta": {
          "user_question": "用户原始问题",
          "params": {"相机数量": "单相机", ...}
        },
        "scene": {
          "desc":   "一句话场景描述",
          "params": [["参数名", "参数值"], ...]
        },
        "approach": {
          "nodes": [
            {"label": "十二点标定", "small": "9平移+3旋转", "color": "b"},
            ...  // color: b(蓝)/g(绿)/o(橙)/r(红), small 可选
          ],
          "tip": "方案要点提示（可选）"
        },
        "vm_flows": {
          "calib": {"type": "single_cam_calib", "calib_module": "...",
                     "has_comm": true, "has_angle": true},
          "prod":  {"type": "single_cam_prod", "calc_module": "...",
                     "has_angle": true}
        },
        "ops": {
          "calib": {"title": "...", "steps": [{"title":"...","detail":"..."}]},
          "teaching": {"title": "...", "steps": [...]},          // 可选
          "production": {"title": "...", "steps": [...]}
        },
        "warnings": ["警告文字（支持 HTML）", ...],
        "refs": [{"title": "文档名"}, ...],
        "export_dir": "E:/...（可选，默认自动推断）",
        "auto_generate_sol": true  // 可选，默认 true
      }

    返回 (html_path, sol_path)。
    """
    # ── 1. 元信息注释 ──
    meta = config.get('meta', {})
    meta_lines = [
        '<!-- 元信息',
        f'生成时间：{config["datetime"]}',
        '模式：方案设计',
    ]
    if meta.get('user_question'):
        meta_lines.append(f'用户原始问题：{meta["user_question"]}')
    if meta.get('params'):
        meta_lines.append('关键参数：')
        for k, v in meta['params'].items():
            meta_lines.append(f'  {k}：{v}')
    meta_lines.append('-->')
    meta_comment = '\n'.join(meta_lines)

    # ── 2. 场景分析 ──
    scene = config['scene']
    params_rows = '\n    '.join(
        f'<tr><td>{k}</td><td>{v}</td></tr>'
        for k, v in scene['params']
    )

    # ── 3. 定位方案思路 ──
    approach = config.get('approach', {})
    flow_parts = []
    for i, node in enumerate(approach.get('nodes', [])):
        if i > 0:
            flow_parts.append('<div class="fa">→</div>')
        color = node.get('color', 'b')
        inner = node['label']
        if node.get('small'):
            inner += f'<br><small>{node["small"]}</small>'
        flow_parts.append(f'<div class="fb fb-{color}">{inner}</div>')
    flow_nodes_html = '\n    '.join(flow_parts)

    tip_text = approach.get('tip', '')
    flow_tip_html = f'<div class="tip">\n  {tip_text}\n</div>' if tip_text else ''

    # ── 4. VM 视觉流程图 ──
    vm_flows = config.get('vm_flows', {})
    vm_parts = []
    for flow_key, flow_cfg in vm_flows.items():
        section_title = flow_cfg.get('title', _FLOW_TITLE_DEFAULTS.get(flow_key, flow_key))
        vm_parts.append(f'<h3>{section_title}</h3>')

        flow_type = flow_cfg['type']
        flow_id = flow_cfg.get('flow_id', flow_key)
        builder = _FLOW_BUILDERS.get(flow_type)
        if builder is None:
            raise ValueError(
                f'Unknown flow type: {flow_type!r}. '
                f'Supported: {", ".join(sorted(_FLOW_BUILDERS))}')
        vm_parts.append(builder(flow_cfg, flow_id))
    vm_flow_html = '\n'.join(vm_parts)

    # ── 5. 操作要点 ──
    ops = config.get('ops', {})
    ops_parts = []
    phase_meta = [
        ('calib',      'pc',  'sn'),     # blue
        ('teaching',   'pt',  'sn-g'),   # green
        ('production', 'pp',  'sn-o'),   # orange
    ]
    for phase_key, phase_class, sn_class in phase_meta:
        if phase_key not in ops:
            continue
        phase = ops[phase_key]
        ops_parts.append(f'<div class="phase {phase_class}">')
        ops_parts.append(f'<div class="ph">{phase["title"]}</div>')
        ops_parts.append('<ul class="steps">')
        for idx, step in enumerate(phase.get('steps', []), 1):
            title = step.get('title', '')
            detail = step.get('detail', '')
            content = f'<b>{title}</b><br>{detail}' if detail else f'<b>{title}</b>'
            ops_parts.append(
                f'<li><span class="{sn_class}">{idx}</span>'
                f'<div>{content}</div></li>')
        ops_parts.append('</ul></div>')
    ops_content_html = '\n'.join(ops_parts)

    # ── 6. 注意事项 ──
    warnings = config.get('warnings', [])
    warnings_html = '\n'.join(f'<div class="warn">{w}</div>' for w in warnings) if warnings else ''

    # ── 7. 参考文档 ──
    refs = config.get('refs', [])
    ref_items = []
    for ref in refs:
        title = ref['title'] if isinstance(ref, dict) else ref
        ref_items.append(f'<li>{title}</li>')
    ref_docs_html = '\n    '.join(ref_items)

    # ── 8. 写出 HTML + .sol ──
    return build_solution_html(
        filename=config['filename'],
        title=config['title'],
        datetime_str=config['datetime'],
        meta_comment=meta_comment,
        scene_desc=scene['desc'],
        params_table_rows=params_rows,
        flow_nodes_html=flow_nodes_html,
        flow_tip_html=flow_tip_html,
        vm_flow_html=vm_flow_html,
        ops_content_html=ops_content_html,
        warnings_html=warnings_html,
        ref_docs_html=ref_docs_html,
        export_dir=config.get('export_dir'),
        auto_generate_sol=config.get('auto_generate_sol', True),
    )


if __name__ == '__main__':
    import sys, json
    if len(sys.argv) >= 2:
        config_path = sys.argv[1]
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        html_path, sol_path = build_solution_from_config(config)
        print(f'[OK] 方案生成完成：{html_path}')
        if sol_path:
            print(f'[OK] .sol 方案：{sol_path}')
    else:
        print('用法: python vm_flow_builder.py <config.json>')
        print(f'SKILL_DIR = {SKILL_DIR}')
        print(f'TEMPLATE  = {TEMPLATE}')
