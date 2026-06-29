"""
标定文件分析工具库（calib_analyzer）

解析 VisionMaster 生成的 N点标定/平移旋转标定 XML 文件（calib.xml），
对标定数据进行 12 项检测，输出结构化分析报告。

用法：
    # 从文件路径解析
    from calib_analyzer import analyze_calib_file, analyze_calib_content
    report = analyze_calib_file('calib.xml')

    # 或从对话框复制的 xml 字符串内容解析
    report = analyze_calib_content(xml_string)

    for item in report['items']:
        print(f"{item['seq']}. {item['name']}: {'PASS' if item['pass'] else 'FAIL'}")

12 项检测项（已去掉标定状态和标定误差状态）：
  1. 平移像素精度           TransError 直接读取
  2. 旋转像素精度           RotError 直接读取
  3. 平移像素步长极差       前9点相邻像素距离的极差
  4. 平移物理角度极差       前9点物理角度极差
  5. 平移图像角度极差       前9点R值极差
  6. 物理平移精度           前9点相邻物理点距离极差
  7. 物理旋转精度           后3点两两物理角度差与图像角度差的绝对差
  8. 角度旋转一致性         RotDirectionState（XML值与计算值对比，运动相机取反）
  9. 坐标系左右手一致性     IsRightCoorA（XML值与计算值对比）
  10. 平移像素最大误差       用前9点拟合不带透视的仿射矩阵，仅对这9个平移点求重投影误差的最大值
  11. 物理XY轴夹角           从校准矩阵反三角函数计算
  12. 旋转中心像素偏差度      后三点拟合 vs RotCenterImagePoint
"""

import math
import xml.etree.ElementTree as ET


# ── 标准红线 ───────────────────────────────────────────────────────
STANDARDS = {
    1:  {"name": "平移像素精度",        "standard": "< 1像素",          "standard_val": 1.0,     "unit": "像素", "fix": "检查机构平移精度及图像特征点提取精度"},
    2:  {"name": "旋转像素精度",        "standard": "< 0.5像素",        "standard_val": 0.5,     "unit": "像素", "fix": "检查机构旋转精度及图像角度提取精度"},
    3:  {"name": "平移像素步长极差",    "standard": "< 1像素",          "standard_val": 1.0,     "unit": "像素", "fix": "检查机构平移精度及图像特征点提取精度"},
    4:  {"name": "平移物理角度极差",    "standard": "< 0.01度",         "standard_val": 0.01,    "unit": "度",   "fix": "检查机构平移时是否发生旋转"},
    5:  {"name": "平移图像角度极差",    "standard": "< 0.01度",         "standard_val": 0.01,    "unit": "度",   "fix": "检查机构平移时是否发生旋转"},
    6:  {"name": "物理平移精度",        "standard": "< 0.02mm",         "standard_val": 0.02,    "unit": "mm",   "fix": "检查机构重复定位精度"},
    7:  {"name": "物理旋转精度",        "standard": "< 0.05度",         "standard_val": 0.05,    "unit": "度",   "fix": "检查机构旋转精度及图像角度提取精度"},
    8:  {"name": "角度旋转一致性",      "standard": "1或-1",            "standard_val": None,    "unit": "",     "fix": "若为-1可点击修正按钮自动修正"},
    9:  {"name": "坐标系左右手一致性",  "standard": "1或-1",            "standard_val": None,    "unit": "",     "fix": "若为-1可点击修正按钮自动修正"},
    10: {"name": "平移像素最大误差",    "standard": "< 1像素",          "standard_val": 1.0,     "unit": "像素", "fix": "检查机构平移精度及图像特征点提取精度"},
    11: {"name": "物理XY轴夹角",        "standard": "89.8°-90.2°",      "standard_val": (89.8, 90.2), "unit": "度", "fix": "检查XY轴垂直及图像畸变"},
    12: {"name": "旋转中心像素偏差度",  "standard": "< 1像素",          "standard_val": 1.0,     "unit": "像素", "fix": "检查机构旋转精度及图像角度提取精度"},
}


# ── 辅助函数 ───────────────────────────────────────────────────────

def _parse_float(val_str):
    try:
        return float(val_str)
    except (TypeError, ValueError):
        return 0.0


def _distance(x1, y1, x2, y2):
    return math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)


def _angle_from_vector(dx, dy):
    """
    向量与最近坐标轴的偏差角度（度），范围 [0, 90)
    网格标定中所有移动应沿 X 或 Y 轴，本函数返回与最近轴线的偏离角度。
    """
    if abs(dx) < 1e-12 and abs(dy) < 1e-12:
        return 0.0
    if abs(dy) > abs(dx):
        rad = math.atan2(dx, dy)
    else:
        rad = math.atan2(dy, dx)
    deg = abs(math.degrees(rad))
    if deg > 90:
        deg = 180 - deg
    return deg


def _solve_3x3(A, b):
    """求解 3x3 线性方程组 A·x = b，用克拉默法则。返回 [x0, x1, x2] 或 None。"""
    def det3(m):
        return (m[0][0]*(m[1][1]*m[2][2] - m[1][2]*m[2][1])
                - m[0][1]*(m[1][0]*m[2][2] - m[1][2]*m[2][0])
                + m[0][2]*(m[1][0]*m[2][1] - m[1][1]*m[2][0]))
    D = det3(A)
    if abs(D) < 1e-18:
        return None
    out = []
    for col in range(3):
        Ai = [row[:] for row in A]
        for r in range(3):
            Ai[r][col] = b[r]
        out.append(det3(Ai) / D)
    return out


def _fit_affine(img_pts, world_pts):
    """
    用最小二乘法拟合 2D 仿射矩阵（6参数，不带透视）：
        X = a*x + b*y + c
        Y = d*x + e*y + f
    img_pts/world_pts 为 [(x,y,r), ...]
    返回 (a, b, c, d, e, f) 或 None。
    """
    n = len(img_pts)
    if n < 3:
        return None
    sxx = syy = sxy = sx = sy = 0.0
    sxX = syX = sX = 0.0
    sxY = syY = sY = 0.0
    for i in range(n):
        xi, yi = img_pts[i][0], img_pts[i][1]
        Xi, Yi = world_pts[i][0], world_pts[i][1]
        sxx += xi*xi
        syy += yi*yi
        sxy += xi*yi
        sx += xi
        sy += yi
        sxX += xi*Xi
        syX += yi*Xi
        sX += Xi
        sxY += xi*Yi
        syY += yi*Yi
        sY += Yi

    A = [[sxx, sxy, sx],
         [sxy, syy, sy],
         [sx,  sy,  float(n)]]

    abc = _solve_3x3(A, [sxX, syX, sX])
    def_ = _solve_3x3(A, [sxY, syY, sY])
    if abc is None or def_ is None:
        return None
    return (abc[0], abc[1], abc[2], def_[0], def_[1], def_[2])


def _make_item(seq, value):
    """根据序号和数值构造单条检测结果 dict"""
    std = STANDARDS[seq]

    # 格式化显示值
    if isinstance(value, str):
        display = value
    elif seq in (8, 9):
        display = str(int(value))
    elif seq == 11:
        display = f"{value:.2f}{chr(176)}"
    else:
        display = f"{value}" if isinstance(value, str) else f"{value:.6f}"
    if std["unit"] and seq != 11:
        display += std["unit"]

    # 判定
    if seq in (8, 9):
        passed = value == 1 or value == -1
    elif seq == 11:
        lo, hi = std["standard_val"]
        passed = lo <= value <= hi
    else:
        passed = value < std["standard_val"]

    return {
        "seq": seq,
        "name": std["name"],
        "value_raw": value,
        "display": display,
        "standard": std["standard"],
        "pass": passed,
        "fix": std["fix"],
    }


# ── 公共入口 ───────────────────────────────────────────────────────

def analyze_calib_file(xml_path: str, camera_mount: str = 'stationary') -> dict:
    """从文件路径解析标定 XML 文件。

    Args:
        xml_path: 标定 XML 文件路径
        camera_mount: 相机安装方式，'stationary' 静止(眼在手外) / 'moving' 运动(眼在手上)
    """
    tree = ET.parse(xml_path)
    return _analyze(tree.getroot(), camera_mount=camera_mount)


def analyze_calib_content(xml_content: str, camera_mount: str = 'stationary') -> dict:
    """从字符串内容解析标定 XML（适用于客户从对话框复制内容）。

    Args:
        xml_content: XML 字符串内容
        camera_mount: 相机安装方式，'stationary' 静止(眼在手外) / 'moving' 运动(眼在手上)
    """
    root = ET.fromstring(xml_content)
    return _analyze(root, camera_mount=camera_mount)


# ── 核心解析 ───────────────────────────────────────────────────────

def _analyze(root: ET.Element, camera_mount: str = 'stationary') -> dict:
    """解析标定 XML 根节点，对 14 项指标逐一检测。

    Args:
        root: XML 根节点
        camera_mount: 相机安装方式，'stationary' 静止(眼在手外) / 'moving' 运动(眼在手上)
    """

    calib_input = root.find(".//CalibInputParam")
    calib_output = root.find(".//CalibOutputParam")

    # ── 解析输入参数 ────────────────────────────────────────────
    def _get_calib_param(parent, name, dtype="float"):
        elem = parent.find(f".//CalibParam[@ParamName='{name}']")
        if elem is None:
            return None
        val = elem.findtext("ParamValue", "0")
        if dtype == "float":
            return _parse_float(val)
        elif dtype == "int":
            return int(_parse_float(val))
        return val

    def _get_point_list(parent, list_name):
        lst = parent.find(f".//CalibPointFListParam[@ParamName='{list_name}']")
        if lst is None:
            return []
        points = []
        for pt in lst.findall("PointF"):
            x = _parse_float(pt.findtext("X", "0"))
            y = _parse_float(pt.findtext("Y", "0"))
            r = _parse_float(pt.findtext("R", "0"))
            points.append((x, y, r))
        return points

    create_time = _get_calib_param(calib_input, "CreateCalibTime", "str")
    calib_type = _get_calib_param(calib_input, "CalibType", "str")
    trans_num = _get_calib_param(calib_input, "TransNum", "int")
    rot_num = _get_calib_param(calib_input, "RotNum", "int")
    trans_error = _get_calib_param(calib_input, "TransError", "float")
    rot_error = _get_calib_param(calib_input, "RotError", "float")
    pixel_precision = _get_calib_param(calib_input, "PixelPrecision", "float")
    pixel_precision_x = _get_calib_param(calib_input, "PixelPrecisionX", "float")
    pixel_precision_y = _get_calib_param(calib_input, "PixelPrecisionY", "float")

    img_points = _get_point_list(calib_input, "ImagePointLst")
    world_points = _get_point_list(calib_input, "WorldPointLst")
    trans_img = img_points[:9]
    rot_img = img_points[9:12]
    trans_world = world_points[:9]
    rot_world = world_points[9:12]

    # ── 解析输出参数 ────────────────────────────────────────────
    rot_center_img_x = _parse_float(calib_output.findtext(".//RotCenterImagePointX", "0"))
    rot_center_img_y = _parse_float(calib_output.findtext(".//RotCenterImagePointY", "0"))

    matrix_elem = calib_output.find(".//CalibFloatListParam[@ParamName='CalibMatrix']")
    matrix_vals = [_parse_float(v.text) for v in matrix_elem.findall("ParamValue")] if matrix_elem is not None else [0]*9
    m_a, m_b = matrix_vals[0], matrix_vals[1]
    m_d, m_e = matrix_vals[3], matrix_vals[4]

    # 读取 XML 中的旋转一致性和手性一致性值（用于与计算值对比）
    rot_direction_state_xml = _get_calib_param(calib_output, "RotDirectionState", "int")
    is_right_coor_a_xml = _get_calib_param(calib_output, "IsRightCoorA", "int")

    # ── 文件信息 ────────────────────────────────────────────────
    file_info = {
        "创建时间": create_time,
        "标定类型": calib_type,
        "平移点数": trans_num,
        "旋转点数": rot_num,
        "像素当量X(mm/像素)": round(pixel_precision_x, 6),
        "像素当量Y(mm/像素)": round(pixel_precision_y, 6),
        "像素当量均值(mm/像素)": round(pixel_precision, 6),
    }

    items = []

    # 第1项：平移像素精度
    items.append(_make_item(1, trans_error))

    # 第2项：旋转像素精度
    items.append(_make_item(2, rot_error))

    # 第3项：平移像素步长极差
    trans_step_pix = []
    for i in range(len(trans_img) - 1):
        dist = _distance(trans_img[i][0], trans_img[i][1],
                         trans_img[i+1][0], trans_img[i+1][1])
        trans_step_pix.append(dist)
    step_range_pix = max(trans_step_pix) - min(trans_step_pix) if trans_step_pix else 999
    items.append(_make_item(3, step_range_pix))

    # 第4项：平移物理角度极差
    trans_angles_phys = []
    for i in range(len(trans_world) - 1):
        ang = _angle_from_vector(
            trans_world[i+1][0] - trans_world[i][0],
            trans_world[i+1][1] - trans_world[i][1],
        )
        trans_angles_phys.append(ang)
    angle_range_phys = max(trans_angles_phys) - min(trans_angles_phys) if trans_angles_phys else 999
    items.append(_make_item(4, angle_range_phys))

    # 第5项：平移图像角度极差
    rot_vals_img = [pt[2] for pt in trans_img]
    rot_range_img = max(rot_vals_img) - min(rot_vals_img)
    items.append(_make_item(5, rot_range_img))

    # 第6项：物理平移精度（前9点相邻物理点距离极差）
    trans_step_phys = []
    for i in range(len(trans_world) - 1):
        dist = _distance(trans_world[i][0], trans_world[i][1],
                         trans_world[i+1][0], trans_world[i+1][1])
        trans_step_phys.append(dist)
    step_range_phys = max(trans_step_phys) - min(trans_step_phys) if trans_step_phys else 999
    items.append(_make_item(6, step_range_phys))

    # 第7项：物理旋转精度（后3点两两角度差对比）
    rot_diffs = []
    for i in range(3):
        for j in range(i+1, 3):
            phys_angle_diff = abs(rot_world[j][2] - rot_world[i][2])
            img_angle_diff = abs(rot_img[j][2] - rot_img[i][2])
            rot_diffs.append(abs(phys_angle_diff - img_angle_diff))
    phys_rot_accuracy = max(rot_diffs) if rot_diffs else 999
    items.append(_make_item(7, phys_rot_accuracy))

    # 第8项：角度旋转一致性
    # 从数据计算：判断图像后三点R值与物理后三点R值是否同增/同减
    img_r_trend = rot_img[2][2] - rot_img[0][2] if len(rot_img) >= 3 else 0
    world_r_trend = rot_world[2][2] - rot_world[0][2] if len(rot_world) >= 3 else 0
    rot_consistency_calc = 1 if img_r_trend * world_r_trend >= 0 else -1
    # 对于运动相机（眼在手上），图像旋转方向与物理旋转方向相反，计算值需取反
    rot_consistency_compare = rot_consistency_calc
    if camera_mount == 'moving':
        rot_consistency_compare = -rot_consistency_calc
    # 与 XML 中存储的值对比
    xml_rot = rot_direction_state_xml
    if xml_rot is not None and xml_rot != rot_consistency_compare:
        # 不一致：标志为 FAIL
        display_8 = f"XML={xml_rot} 数据={rot_consistency_calc} 不一致"
        if camera_mount == 'moving':
            display_8 += f" (运动相机取反后={rot_consistency_compare})"
        correct_val = rot_consistency_compare if camera_mount == 'moving' else rot_consistency_calc
        items.append({
            "seq": 8,
            "name": "角度旋转一致性",
            "value_raw": float(rot_consistency_calc),
            "display": display_8,
            "standard": "1或-1",
            "pass": False,
            "fix": f"XML存储值({xml_rot})与计算值({rot_consistency_compare})不一致，建议手动修正为{correct_val}",
            "correct_value": correct_val,
        })
    else:
        item = _make_item(8, float(rot_consistency_compare if xml_rot is not None else rot_consistency_calc))
        item["fix"] = "值与计算一致"
        items.append(item)

    # 第9项：坐标系左右手一致性——根据标定矩阵行列式判断
    # M0*M4 - M1*M3 > 0 → 1 (左手系)，否则 -1 (右手系)
    det = m_a * m_e - m_b * m_d
    hand_consistency_calc = 1 if det > 0 else -1
    # 与 XML 中存储的值对比
    xml_hand = is_right_coor_a_xml
    if xml_hand is not None and xml_hand != hand_consistency_calc:
        # 不一致：标志为 FAIL
        display_9 = f"XML={xml_hand} 数据={hand_consistency_calc} 不一致"
        items.append({
            "seq": 9,
            "name": "坐标系左右手一致性",
            "value_raw": float(hand_consistency_calc),
            "display": display_9,
            "standard": "1或-1",
            "pass": False,
            "fix": f"XML存储值({xml_hand})与计算值({hand_consistency_calc})不一致，建议手动修正为{hand_consistency_calc}",
            "correct_value": hand_consistency_calc,
        })
    else:
        item = _make_item(9, float(hand_consistency_calc))
        item["fix"] = "值与计算一致"
        items.append(item)

    # 第10项：平移像素最大误差
    # 用前9个平移点拟合不带透视的仿射矩阵（6参数），再仅对这9个平移点计算重投影误差，取最大值
    affine = _fit_affine(trans_img, trans_world)
    if affine is not None and pixel_precision > 0:
        a, b, c, d, e, f = affine
        trans_errors_pix = []
        for i in range(len(trans_img)):
            xi, yi = trans_img[i][0], trans_img[i][1]
            x_pred = a * xi + b * yi + c
            y_pred = d * xi + e * yi + f
            x_actual, y_actual = trans_world[i][0], trans_world[i][1]
            err_phys = _distance(x_pred, y_pred, x_actual, y_actual)
            err_pix = err_phys / pixel_precision
            trans_errors_pix.append(err_pix)
        max_trans_err_pix = max(trans_errors_pix) if trans_errors_pix else 999
    else:
        max_trans_err_pix = 999
    items.append(_make_item(10, max_trans_err_pix))

    # 第11项：物理XY轴夹角
    col1_len = math.sqrt(m_a*m_a + m_d*m_d)
    col2_len = math.sqrt(m_b*m_b + m_e*m_e)
    dot = m_a * m_b + m_d * m_e
    cos_theta = dot / (col1_len * col2_len) if (col1_len * col2_len) > 0 else 0
    cos_theta = max(-1.0, min(1.0, cos_theta))
    xy_angle = math.degrees(math.acos(cos_theta))
    items.append(_make_item(11, xy_angle))

    # 第12项：旋转中心像素偏差度（后三点垂直平分线法拟合）
    if len(rot_img) >= 3:
        x1, y1, _ = rot_img[0]
        x2, y2, _ = rot_img[1]
        x3, y3, _ = rot_img[2]

        mid_ab_x = (x1 + x2) / 2
        mid_ab_y = (y1 + y2) / 2
        dx_ab = x2 - x1
        dy_ab = y2 - y1

        mid_bc_x = (x2 + x3) / 2
        mid_bc_y = (y2 + y3) / 2
        dx_bc = x3 - x2
        dy_bc = y3 - y2

        if abs(dy_ab) < 1e-12 or abs(dy_bc) < 1e-12:
            rot_center_fit_x = mid_ab_x
            rot_center_fit_y = mid_bc_y
        else:
            k1 = -dx_ab / dy_ab
            k2 = -dx_bc / dy_bc
            if abs(k1 - k2) < 1e-12:
                rot_center_fit_x = mid_ab_x
                rot_center_fit_y = mid_ab_y
            else:
                rot_center_fit_x = (k1 * mid_ab_x - k2 * mid_bc_x + mid_bc_y - mid_ab_y) / (k1 - k2)
                rot_center_fit_y = k1 * (rot_center_fit_x - mid_ab_x) + mid_ab_y

        rc_deviation = _distance(rot_center_fit_x, rot_center_fit_y,
                                 rot_center_img_x, rot_center_img_y)
        items.append(_make_item(12, rc_deviation))
    else:
        items.append(_make_item(12, 999))

    # ── 汇总 ──────────────────────────────────────────────────
    pass_count = sum(1 for item in items if item["pass"] is True)
    fail_count = sum(1 for item in items if item["pass"] is False)
    na_count = sum(1 for item in items if item["pass"] is None)

    if fail_count == 0:
        overall = "标定质量良好"
    elif fail_count <= 2:
        overall = "标定质量一般，建议针对不合格项排查"
    else:
        overall = "标定质量差，建议重新标定"

    return {
        "file_info": file_info,
        "items": items,
        "summary": {
            "total": len(items),
            "pass": pass_count,
            "fail": fail_count,
            "na": na_count,
            "overall": overall,
        },
    }


# ── 命令行入口 ────────────────────────────────────────────────────

if __name__ == "__main__":
    import sys
    import json

    if len(sys.argv) < 2:
        print("用法: python calib_analyzer.py <calib.xml>")
        sys.exit(1)

    report = analyze_calib_file(sys.argv[1])

    print(f"文件信息: {json.dumps(report['file_info'], ensure_ascii=False, indent=2)}")
    print(f"\n检测结果 ({report['summary']['total']}项):")
    print(f"  通过: {report['summary']['pass']}  |  未通过: {report['summary']['fail']}  |  参考: {report['summary']['na']}")
    print(f"  总体评价: {report['summary']['overall']}\n")

    print(f"{'序号':<4} {'检测项':<18} {'实测值':<16} {'标准要求':<16} {'判定':<6} {'排查方向'}")
    print("-" * 80)
    for item in report["items"]:
        passed_str = "PASS" if item["pass"] is True else ("FAIL" if item["pass"] is False else "参考")
        print(f"{item['seq']:<4} {item['name']:<18} {item['display']:<16} {item['standard']:<16} {passed_str:<6} {item['fix']}")
