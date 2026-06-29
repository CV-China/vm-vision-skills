"""
HTML 报告生成器。

生成固定格式的 VisionMaster 方案耗时分析报表（自包含 HTML），包含两大板块：
1. 整体方案耗时评估（流程级/模块级汇总表 + 文字评估）
2. 耗时分析图谱（ECharts 交互图表：柱状图/折线图/饼图 + 模块筛选）
"""

import json
import os
from datetime import datetime, timedelta
from typing import List

from time_analyzer import (
    TimeStatistics, ProcedureSummary, OverallEvaluation, analyze,
    format_evaluation_text,
)
from log_parser import (
    parse_log_files, load_module_names, find_latest_timestamp,
    separate_modules_and_procedures
)


# ---------------------------------------------------------------------------
# 数据序列化为 JSON（嵌入 HTML）
# ---------------------------------------------------------------------------

def _stat_to_dict(s: TimeStatistics) -> dict:
    return {
        "module_id": s.module_id,
        "procedure_id": s.procedure_id,
        "module_name": s.module_name,
        "internal_name": s.internal_name,
        "count": s.count,
        "avg_ms": s.avg_ms,
        "max_ms": s.max_ms,
        "max_timestamp": s.max_timestamp,
        "min_ms": s.min_ms,
        "std_ms": s.std_ms,
        "p50": s.p50,
        "p75": s.p75,
        "p95": s.p95,
        "p99": s.p99,
        "total_ms": s.total_ms,
        "range_ms": s.range_ms,
        "over_two_times_count": s.over_two_times_count,
        "cv": s.cv,
        "volatility_level": s.volatility_level,
        "proportion_in_procedure": s.proportion_in_procedure,
        "vci": s.vci,
        "volatility_impact": s.volatility_impact,
        "time_series": s.time_series,
        "time_labels": s.time_labels,
        "top10_values": s.top10_values,
        "top10_timestamps": s.top10_timestamps,
    }


def _proc_summary_to_dict(p: ProcedureSummary) -> dict:
    return {
        "procedure_id": p.procedure_id,
        "module_count": p.module_count,
        "total_executions": p.total_executions,
        "avg_ms": p.avg_ms,
        "max_ms": p.max_ms,
        "min_ms": p.min_ms,
        "p95": p.p95,
        "cv": p.cv,
        "volatility_level": p.volatility_level,
        "proportion_pct": p.proportion_pct,
        "vci": p.vci,
        "volatility_impact": p.volatility_impact,
        "high_impact_modules": p.high_impact_modules,
        "worst_runs": p.worst_runs,
        "max_timestamp": p.max_timestamp,
        "modules": [_stat_to_dict(m) for m in p.modules],
    }


def _eval_to_dict(e: OverallEvaluation) -> dict:
    return {
        "total_modules": e.total_modules,
        "total_procedures": e.total_procedures,
        "total_executions": e.total_executions,
        "total_time_ms": e.total_time_ms,
        "bottleneck_module": e.bottleneck_module,
        "bottleneck_procedure": e.bottleneck_procedure,
        "high_volatility_modules": e.high_volatility_modules,
        "high_impact_modules": e.high_impact_modules,
        "summary_text": e.summary_text,
    }


# ---------------------------------------------------------------------------
# 流程明细数据 JSON 构建（供前端动态表格使用）
# ---------------------------------------------------------------------------

def _build_proc_view_data_json(
    procedure_summaries: List[ProcedureSummary],
) -> str:
    """构建各流程模块耗时明细 JSON 数据，供前端视图切换按钮和动态表格使用。"""
    proc_view_data = {}

    for ps in procedure_summaries:
        pid = str(ps.procedure_id)
        if not ps or not ps.modules:
            continue

        mod_info = {str(m.module_id): m for m in ps.modules}

        # "avg" 视图：所有模块按平均耗时降序
        sorted_avg = sorted(ps.modules, key=lambda m: m.avg_ms, reverse=True)
        proc_view_data[pid] = {}
        proc_view_data[pid]["avg"] = []
        for m in sorted_avg:
            proc_view_data[pid]["avg"].append({
                "module_id": m.module_id,
                "module_name": m.module_name,
                "internal_name": m.internal_name,
                "time_ms": m.avg_ms,
                "max_ms": m.max_ms,
                "max_timestamp": m.max_timestamp,
                "cv": round(m.cv * 100, 1),
                "vci": round(m.vci * 100, 1),
                "volatility_impact": m.volatility_impact,
                "proportion_pct": round(m.proportion_in_procedure * 100, 1),
            })

        # "worstN" 视图：每次最慢运行的各模块耗时
        if ps.worst_runs:
            for wi, run in enumerate(ps.worst_runs):
                mode_key = f"worst{wi}"
                module_times = run.get("module_times", {})
                proc_view_data[pid][mode_key] = []
                run_total = run.get("total_ms", 0)
                for mod_id_str, mod_time in sorted(
                    module_times.items(), key=lambda x: x[1], reverse=True
                ):
                    m = mod_info.get(mod_id_str)
                    mod_name = m.module_name if m else f"模块{mod_id_str}"
                    mod_module_id = m.module_id if m else 0
                    proportion = round(mod_time / run_total * 100, 1) if run_total > 0 else 0.0
                    proc_view_data[pid][mode_key].append({
                        "module_id": mod_module_id,
                        "module_name": mod_name,
                        "time_ms": mod_time,
                        "proportion_pct": proportion,
                    })

    # 构建视图元数据
    views_meta = {}
    all_avg_modules = []
    for ps in procedure_summaries:
        pid = str(ps.procedure_id)
        ps_views = [{"mode": "avg", "label": "平均耗时"}]
        if ps.worst_runs:
            for wi, run in enumerate(ps.worst_runs):
                ts_short = run.get("timestamp_short", "")
                total = run.get("total_ms", 0)
                ps_views.append({
                    "mode": f"worst{wi}",
                    "label": f"最慢第{wi+1}次 ({ts_short} | {total}ms)",
                })
        views_meta[pid] = ps_views

        # 全部模块聚合数据
        for m in ps.modules:
            all_avg_modules.append({
                "module_id": m.module_id,
                "module_name": m.module_name,
                "internal_name": m.internal_name,
                "procedure_id": m.procedure_id,
                "procedure_name": f"流程{pid}",
                "time_ms": m.avg_ms,
                "max_ms": m.max_ms,
                "max_timestamp": m.max_timestamp,
                "cv": round(m.cv * 100, 1),
                "vci": round(m.vci * 100, 1),
                "volatility_impact": m.volatility_impact,
                "proportion_pct": round(m.proportion_in_procedure * 100, 1),
            })

    all_avg_modules.sort(key=lambda m: m["time_ms"], reverse=True)
    proc_view_data["__views__"] = views_meta
    proc_view_data["__all__"] = {"avg": all_avg_modules}

    return json.dumps(proc_view_data, ensure_ascii=False)


# ---------------------------------------------------------------------------
# HTML 报告组装
# ---------------------------------------------------------------------------

def load_template() -> str:
    """加载 HTML 模板"""
    template_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        "templates", "report_template.html"
    )
    if os.path.exists(template_path):
        with open(template_path, "r", encoding="utf-8") as f:
            return f.read()
    # 后备：内联模板
    return _FALLBACK_TEMPLATE


def generate_report(
    log_dir: str,
    output_path: str,
    exclude_first_n: int = 5,
    name_map: dict = None,
    time_range: str = "all",
) -> bool:
    """
    完整的报告生成流程。

    1. 解析 ModuleFrame 日志获取耗时原始数据
    2. 统计分析
    3. 生成 HTML 报表

    Args:
        time_range: 分析时间段 (1h/3h/1d/1w/all)

    Returns: 成功 True / 失败 False
    """
    print("=" * 60)
    print("VisionMaster 耗时分析 - 开始")
    print("=" * 60)

    # Step 0: 确定时间范围（非 all 时需要先扫描最新时间戳）
    time_filter = None
    if time_range != "all":
        range_map = {"1h": 1, "3h": 3, "1d": 24, "1w": 168}
        hours = range_map.get(time_range)
        if hours:
            print(f"\n[0/3] 扫描日志时间范围（时间段=近{hours}小时）...")
            latest_ts = find_latest_timestamp(log_dir)
            cutoff_ts = latest_ts - timedelta(hours=hours)
            time_filter = (cutoff_ts, latest_ts)
            print(f"  日志最新时间: {latest_ts.strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"  筛选起始时间: {cutoff_ts.strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"  筛选时间段: 近{hours}小时")
    else:
        print(f"\n[0/3] 分析时间段: 全部（不筛选）")

    # Step 1: 解析日志
    print(f"\n[1/3] 解析日志目录: {log_dir}")
    if name_map is None:
        name_map = load_module_names()
    raw_data, busy_map, run_windows = parse_log_files(log_dir, name_map, time_filter=time_filter)
    modules_raw, procedures_raw = separate_modules_and_procedures(raw_data)
    print(f"  解析到 {len(modules_raw)} 个模块, {len(procedures_raw)} 个流程")

    # 打印解析到的模块信息
    for _, raw in sorted(raw_data.items()):
        name = raw.module_name
        cnt = raw.count
        pid = raw.procedure_id
        if raw.module_id < 10000:
            tag = "模块"
        else:
            tag = "流程"
        print(f"    [{tag}] 流程{pid} {name} (ID={raw.module_id}): {cnt}条记录")

    if not raw_data:
        print("错误: 未解析到任何耗时数据！请检查日志文件路径。")
        return False

    # Step 2: 统计分析
    print(f"\n[2/3] 计算耗时统计...")
    analysis = analyze(raw_data, exclude_first_n=exclude_first_n,
                       procedure_busy_map=busy_map,
                       run_windows=run_windows)

    evaluation: OverallEvaluation = analysis["evaluation"]
    procedure_summaries: List[ProcedureSummary] = analysis["procedure_summaries"]
    module_stats: List[TimeStatistics] = analysis["modules"]
    procedure_stats: List[TimeStatistics] = analysis["procedures"]

    print(f"  模块统计: {len(module_stats)} 项")
    print(f"  流程统计: {len(procedure_stats)} 项")

    # 输出纯文本评估结论
    print()
    try:
        print(format_evaluation_text(evaluation))
    except UnicodeEncodeError:
        print(format_evaluation_text(evaluation).encode('gbk', errors='replace').decode('gbk'))
    print()

    # Step 3: 生成 HTML
    print(f"\n[3/3] 生成 HTML 报告...")

    # 构建流程明细数据 JSON（供前端动态表格）
    proc_view_data_json = _build_proc_view_data_json(procedure_summaries)

    # 构建图表数据 JSON
    chart_data = {
        "modules": [_stat_to_dict(m) for m in module_stats],
        "procedures": [_stat_to_dict(p) for p in procedure_stats],
        "procedure_summaries": [_proc_summary_to_dict(p) for p in procedure_summaries],
        "evaluation": _eval_to_dict(evaluation),
    }

    # 构建表格 HTML
    tables_html = _build_tables_html(evaluation, procedure_summaries)
    tables_html += _build_collapsible_module_tables(module_stats, procedure_summaries)

    # 构建各流程的模块耗时明细折叠表 + 导航栏
    proc_nav_html = _build_proc_detail_tables(procedure_summaries)
    tables_html += proc_nav_html

    # 加载模板并替换占位符
    template = load_template()
    report_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    html = template
    html = html.replace("{{REPORT_TIME}}", report_time)
    html = html.replace("{{EVALUATION_TABLES}}", tables_html)
    html = html.replace("{{CHART_DATA}}", json.dumps(chart_data, ensure_ascii=False))
    html = html.replace("{{PROC_VIEW_DATA}}", proc_view_data_json)

    # 写入输出文件
    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html)

    print(f"\n报告已生成: {output_path}")
    print(f"文件大小: {os.path.getsize(output_path) / 1024:.1f} KB")
    print("=" * 60)
    return True


# ---------------------------------------------------------------------------
# 表格 HTML 构建
# ---------------------------------------------------------------------------

def _build_tables_html(
    evaluation: OverallEvaluation,
    procedure_summaries: List[ProcedureSummary],
) -> str:
    """构建报告中的表格 HTML 片段"""

    # --- 整体评估结论 ---
    parts = ['<div class="eval-summary">']
    parts.append(f'<h3>📊 整体评估结论</h3>')
    parts.append(f'<div class="eval-text">{evaluation.summary_text}</div>')
    parts.append('<div class="eval-stats">')
    parts.append(f'<span>总模块数: <strong>{evaluation.total_modules}</strong></span>')
    parts.append(f'<span>总流程数: <strong>{evaluation.total_procedures}</strong></span>')
    parts.append(f'<span>总执行次数: <strong>{evaluation.total_executions}</strong></span>')
    parts.append('</div>')
    parts.append('</div>')

    # --- 流程级汇总表 ---
    parts.append('<h3>📋 流程级耗时汇总</h3>')
    parts.append('<p style="color:var(--muted);font-size:0.85em;margin-bottom:6px;">'
                 '鼠标悬停列表头可查看各指标含义</p>')
    parts.append('<div class="table-wrap"><table>')
    parts.append(
        '<thead><tr>'
        '<th>流程ID</th>'
        '<th title="该流程包含的算法模块数量">模块数</th>'
        '<th title="日志中记录的有效运行次数（排除预热后的值）">执行次数</th>'
        '<th title="所有运行耗时的算术平均值，代表典型运行速度">平均(ms)</th>'
        '<th title="所有运行中耗时最慢的一次（第二行为发生时刻 HH:MM:SS）">最大(ms)</th>'
        '<th title="所有运行中耗时最快的一次">最小(ms)</th>'
        '<th title="该流程耗时占全部流程总耗时的百分比">占比</th>'
        '<th title="该流程内高波动影响模块（流程内VCI排序前5%）">高影响模块</th>'
        '</tr></thead><tbody>'
    )
    for p in procedure_summaries:
        impact_parts = []
        for mod in p.high_impact_modules[:3]:
            impact_parts.append(f'{mod["module_id"]}:{mod["module_name"]}')
        impact_mods_str = "、".join(impact_parts) if impact_parts else "—"
        parts.append(
            f'<tr>'
            f'<td>流程{p.procedure_id}</td>'
            f'<td>{p.module_count}</td>'
            f'<td>{p.total_executions}</td>'
            f'<td>{p.avg_ms}</td>'
            f'<td>{p.max_ms}<br><span style="font-size:0.78em;color:var(--muted);">{p.max_timestamp}</span></td>'
            f'<td>{p.min_ms}</td>'
            f'<td>{p.proportion_pct}%</td>'
            f'<td style="font-size:0.83em;">{impact_mods_str}</td>'
            f'</tr>'
        )
    parts.append('</tbody></table></div>')

    return "\n".join(parts)


# ---------------------------------------------------------------------------
# 模块级明细表
# ---------------------------------------------------------------------------

def _build_collapsible_module_tables(
    module_stats: List[TimeStatistics],
    procedure_summaries: List[ProcedureSummary],
) -> str:
    """生成模块级明细表：流程筛选下拉框 + 单表格"""
    parts = ['<h3>🔧 模块级耗时明细</h3>']

    # 流程选择栏
    parts.append('<div class="proc-filter-bar">')
    parts.append(
        '<label for="moduleProcSelect" style="font-weight:600;margin-right:8px;">'
        '📋 流程筛选：</label>'
    )
    parts.append('<select id="moduleProcSelect" class="proc-select">')
    parts.append('<option value="all" selected>全部流程</option>')
    for proc in procedure_summaries:
        pid = proc.procedure_id
        vol_label = proc.volatility_impact or proc.volatility_level
        parts.append(
            f'<option value="{pid}">'
            f'流程{pid}（{proc.module_count}个模块 | '
            f'平均{proc.avg_ms}ms | 占比{proc.proportion_pct}% | {vol_label}）'
            f'</option>'
        )
    parts.append('</select>')
    parts.append(
        '<span id="moduleProcInfo" style="margin-left:12px;font-size:0.85em;color:var(--muted);">'
        f'共 {len(module_stats)} 个模块（{len(procedure_summaries)} 个流程）'
        '</span>'
    )
    parts.append('</div>')

    # 单表格
    parts.append('<div class="table-wrap"><table id="moduleDetailTable">')
    parts.append(
        '<thead><tr>'
        '<th>流程ID</th>'
        '<th title="模块在方案中的唯一编号">模块ID</th>'
        '<th>模块名称</th>'
        '<th title="有效运行次数（总运行次数−排除的前N次预热运行）">执行次数</th>'
        '<th title="所有运行耗时的算术平均值，代表典型运行速度">平均(ms)</th>'
        '<th title="所有运行中耗时最长的一次及其发生时刻">最大(ms)<br>发生时刻</th>'
        '<th title="所有运行中耗时最短的一次">最小(ms)</th>'
        '<th title="最大值−最小值，反映最优和最差情况的差距">极差</th>'
        '<th title="该模块耗时占所在流程全部模块总耗时的百分比">流程占比</th>'
        '</tr></thead><tbody>'
    )

    all_modules_sorted = sorted(module_stats, key=lambda x: x.avg_ms, reverse=True)

    for m in all_modules_sorted:
        pid = m.procedure_id
        parts.append(
            f'<tr data-proc="{pid}">'
            f'<td>{pid}</td>'
            f'<td>{m.module_id}</td>'
            f'<td>{m.module_name}</td>'
            f'<td>{m.count}</td>'
            f'<td>{m.avg_ms}</td><td>{m.max_ms}<br><span style="font-size:0.78em;color:var(--muted);">{m.max_timestamp}</span></td><td>{m.min_ms}</td>'
            f'<td>{m.range_ms}</td>'
            f'<td>{round(m.proportion_in_procedure * 100, 1)}%</td>'
            f'</tr>'
        )

    parts.append('</tbody></table></div>')
    return "\n".join(parts)


# ---------------------------------------------------------------------------
# 各流程模块耗时明细表（带 Tab 切换和视图切换）
# ---------------------------------------------------------------------------

def _build_proc_nav_bar(procedure_summaries: List[ProcedureSummary]) -> str:
    """生成流程 Tab 栏 + 共享视图切换按钮栏"""
    if not procedure_summaries:
        return ""

    parts = []
    parts.append('<div id="procNavBar" style="margin:16px 0;">')

    # Tab 栏
    parts.append('<div class="proc-tab-bar" id="procTabBar">')
    for i, p in enumerate(procedure_summaries):
        pid = p.procedure_id
        tab_label = f'流程{pid}'
        if p:
            tab_label += f' | Avg:{p.avg_ms}ms | {p.volatility_impact}'
        active_class = " active" if i == 0 else ""
        parts.append(
            f'<button class="proc-tab{active_class}" data-proc="{pid}">'
            f'{tab_label}</button>'
        )
    parts.append('</div>')

    # 共享视图切换按钮栏
    parts.append(
        '<div class="proc-switch-bar" id="sharedViewSwitchBar" data-proc="">'
        '<span style="font-weight:700;color:var(--primary);font-size:0.88em;'
        'margin-right:6px;">🔍 耗时标注：</span>'
        '</div>'
    )
    parts.append('</div>')
    return "\n".join(parts)


def _build_proc_detail_tables(
    procedure_summaries: List[ProcedureSummary],
) -> str:
    """生成各流程的模块耗时明细折叠表"""
    if not procedure_summaries:
        return ""

    parts = ['<h3>📋 各流程最慢前五次耗时明细</h3>']
    parts.append(
        '<p style="color:var(--muted);font-size:0.85em;margin-bottom:8px;">'
        '点击下方流程 Tab 和视图按钮切换对应流程与视图，'
        '表格自动同步更新。鼠标悬停列表头可查看各指标含义。</p>'
    )

    # 流程 Tab 栏 + 视图切换按钮
    parts.append(_build_proc_nav_bar(procedure_summaries))

    for i, p in enumerate(procedure_summaries):
        pid = p.procedure_id

        hidden_class = "" if i == 0 else " proc-detail-hidden"
        time_info = (
            f"｜ 平均耗时 {p.avg_ms}ms"
            f" ｜ CV {round(p.cv * 100, 1)}%"
            f" ｜ 波动影响 {p.volatility_impact}"
        )

        parts.append(
            f'<div class="proc-detail-section{hidden_class}" data-proc="{pid}"'
            f' id="procDetailSection-{pid}">'
            f'<div class="proc-detail-header" id="procDetailHeader-{pid}" '
            f'onclick="toggleProcDetail(\'{pid}\')" style="display:flex;align-items:center;'
            f'gap:8px;cursor:pointer;padding:8px 14px;background:var(--card);'
            f'border-radius:6px;border:1px solid var(--border);margin:8px 0 0;'
            f'transition:background .15s;"'
            f'onmouseover="this.style.background=\'#f0f2ff\'"'
            f'onmouseout="this.style.background=\'var(--card)\'">'
            f'<span id="procDetailArrow-{pid}" style="transition:transform .2s;font-size:0.85em;">▼</span>'
            f'<span style="font-weight:600;color:var(--primary);">'
            f'流程{pid} · 模块耗时明细</span>'
            f'<span style="font-size:0.82em;color:var(--muted);">{time_info}</span>'
            f'<span style="font-size:0.82em;color:var(--muted);" id="procDetailInfo-{pid}">'
            f'（当前流程 · 按平均耗时从大到小排序）点击折叠</span>'
            f'</div>'
            f'<div class="proc-detail-body" id="procDetailBody-{pid}" style="display:block;">'
            f'<div class="table-wrap" style="margin-top:6px;">'
            f'<table id="procDetailTable-{pid}">'
            f'<thead id="procDetailThead-{pid}"></thead><tbody></tbody>'
            f'</table></div></div>'
            f'</div>'
        )

    return "\n".join(parts)


# ---------------------------------------------------------------------------
# 后备 HTML 模板（当文件模板不可用时）
# ---------------------------------------------------------------------------

_FALLBACK_TEMPLATE = r"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>耗时分析报告</title>
<script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Microsoft YaHei', sans-serif;
         font-size: 14px; color: #333; background: #f5f6fa; line-height: 1.6; }
  .container { max-width: 1400px; margin: 0 auto; padding: 20px; }
  h1 { font-size: 1.6em; border-bottom: 2px solid #1a237e; padding-bottom: 10px; margin-bottom: 10px; }
  h2 { font-size: 1.3em; margin: 24px 0 12px; border-bottom: 1px solid #ccc; padding-bottom: 6px; }
  h3 { font-size: 1.1em; margin: 16px 0 8px; }
  .meta { color: #888; font-size: 0.9em; margin-bottom: 20px; }
  .eval-summary { background: #fff; border-left: 4px solid #1a237e; padding: 16px 20px;
                  border-radius: 6px; margin: 16px 0; box-shadow: 0 1px 3px rgba(0,0,0,.1); }
  .eval-text { font-size: 1.05em; color: #333; margin-bottom: 12px; }
  .eval-stats { display: flex; flex-wrap: wrap; gap: 12px 24px; }
  .eval-stats span { font-size: 0.95em; }
  .eval-stats strong { color: #1a237e; }
  .warn { color: #d32f2f !important; }
  .table-wrap { overflow-x: auto; overflow-y: auto; max-height: 480px; margin: 12px 0; background: #fff; border-radius: 6px;
                box-shadow: 0 1px 3px rgba(0,0,0,.1); }
  table { border-collapse: collapse; width: 100%; min-width: 900px; }
  th, td { border: 1px solid #e0e0e0; padding: 6px 10px; text-align: center; font-size: 0.9em; }
  th { background: #e8eaf6; font-weight: 600; position: sticky; top: 0; }
  tr:hover { background: #f5f5ff; }
  .vol-high { color: #d32f2f; font-weight: bold; }
  .vol-mid { color: #ef6c00; font-weight: bold; }
  .chart-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin: 16px 0; }
  .chart-box { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,.1);
               padding: 12px; min-height: 400px; }
  .chart-box.full { grid-column: 1 / -1; min-height: 500px; }
  .module-tabs { display: flex; flex-wrap: wrap; gap: 6px; margin: 10px 0; }
  .module-tab { padding: 4px 12px; border: 1px solid #ccc; border-radius: 16px;
                cursor: pointer; font-size: 0.85em; background: #fff; transition: all .2s; }
  .module-tab:hover { border-color: #1a237e; color: #1a237e; }
  .module-tab.active { background: #1a237e; color: #fff; border-color: #1a237e; }
  .switch-bar { display: flex; gap: 8px; margin: 10px 0; }
  .switch-btn { padding: 6px 16px; border: 1px solid #ccc; border-radius: 4px;
                cursor: pointer; background: #fff; font-size: 0.9em; }
  .switch-btn.active { background: #1a237e; color: #fff; border-color: #1a237e; }
  @media (max-width: 900px) { .chart-row { grid-template-columns: 1fr; } }
</style>
</head>
<body>
<div class="container">
<h1>📊 方案耗时分析报告</h1>
<p class="meta">生成时间: {{REPORT_TIME}}</p>

<!-- ======== 1. 整体方案耗时评估 ======== -->
<h2>1. 整体方案耗时评估</h2>
{{EVALUATION_TABLES}}

<!-- ======== 2. 耗时分析图谱 ======== -->
<h2>2. 耗时分析图谱</h2>

<div class="switch-bar" id="pieSwitch">
  <button class="switch-btn active" data-mode="procedure">按流程占比</button>
  <button class="switch-btn" data-mode="module">按模块类型占比</button>
</div>
<div class="chart-row">
  <div class="chart-box" id="chartBar"></div>
  <div class="chart-box" id="chartPie"></div>
</div>

<div class="module-tabs" id="moduleTabs">
  <span style="line-height:32px;font-weight:600;margin-right:8px;">模块筛选:</span>
  <span class="module-tab active" data-mod="all">全部</span>
</div>
<div class="chart-row">
  <div class="chart-box full" id="chartLine"></div>
</div>

</div>

<script>
// ===== 图表数据 =====
var CHART_DATA = {{CHART_DATA}};

// ===== ECharts =====
var barChart = echarts.init(document.getElementById('chartBar'));
var pieChart = echarts.init(document.getElementById('chartPie'));
var lineChart = echarts.init(document.getElementById('chartLine'));

var allModules = CHART_DATA.modules;
var procedures = CHART_DATA.procedure_summaries;
var currentPieMode = 'procedure';
var currentModule = 'all';

function getFilteredModules() {
  if (currentModule === 'all') return allModules;
  return allModules.filter(function(m) {
    return m.module_name === currentModule || m.module_id.toString() === currentModule;
  });
}

function getModuleNames() {
  var names = [];
  var seen = {};
  allModules.forEach(function(m) {
    if (!seen[m.module_name]) {
      seen[m.module_name] = true;
      names.push({ name: m.module_name, id: m.module_id.toString() });
    }
  });
  return names;
}

// ---- 柱状图 ----
function renderBarChart() {
  var mods = getFilteredModules();
  var xData = mods.map(function(m) { return 'P' + m.procedure_id + '-' + m.module_name; });
  var maxData = mods.map(function(m) { return m.max_ms; });
  var avgData = mods.map(function(m) { return m.avg_ms; });
  var minData = mods.map(function(m) { return m.min_ms; });

  barChart.setOption({
    title: { text: '模块耗时分布 (Max/Avg/Min)', left: 'center', textStyle: { fontSize: 14 } },
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    legend: { data: ['Max', 'Avg', 'Min'], bottom: 0 },
    grid: { left: '10%', right: '5%', top: '15%', bottom: '12%' },
    xAxis: { type: 'category', data: xData, axisLabel: { rotate: 30, fontSize: 10 } },
    yAxis: { type: 'value', name: '耗时(ms)' },
    series: [
      { name: 'Max', type: 'bar', data: maxData, itemStyle: { color: '#e53935' } },
      { name: 'Avg', type: 'bar', data: avgData, itemStyle: { color: '#1e88e5' } },
      { name: 'Min', type: 'bar', data: minData, itemStyle: { color: '#43a047' } }
    ]
  });
}

// ---- 饼图 ----
function renderPieChart() {
  var pieData;
  if (currentPieMode === 'procedure') {
    pieData = procedures.map(function(p) {
      return { name: '流程' + p.procedure_id, value: p.avg_ms };
    });
  } else {
    var byName = {};
    allModules.forEach(function(m) {
      if (!byName[m.module_name]) byName[m.module_name] = 0;
      byName[m.module_name] += m.total_ms;
    });
    pieData = Object.keys(byName).map(function(k) {
      return { name: k, value: Math.round(byName[k] * 10) / 10 };
    });
    pieData.sort(function(a, b) { return b.value - a.value; });
  }

  pieChart.setOption({
    title: {
      text: currentPieMode === 'procedure' ? '按流程耗时占比' : '按模块类型耗时占比',
      left: 'center', textStyle: { fontSize: 14 }
    },
    tooltip: { trigger: 'item', formatter: '{b}: {c}ms ({d}%)' },
    legend: { type: 'scroll', bottom: 0, textStyle: { fontSize: 10 } },
    series: [{
      type: 'pie', radius: ['35%', '65%'], center: ['50%', '48%'],
      data: pieData,
      label: { formatter: '{b}\n{d}%', fontSize: 10 },
      emphasis: { label: { fontSize: 14, fontWeight: 'bold' } }
    }]
  });
}

// ---- 折线图 ----
function renderLineChart() {
  var mods = getFilteredModules();
  var series = [];

  mods.forEach(function(m) {
    var label = 'P' + m.procedure_id + '-' + m.module_name;
    series.push({
      name: label,
      type: 'bar',
      data: [
        { name: 'Avg(ms)', value: m.avg_ms },
        { name: 'P95(ms)', value: m.p95 },
        { name: 'Max(ms)', value: m.max_ms },
        { name: 'Std(ms)', value: m.std_ms },
        { name: 'CV(%)', value: Math.round(m.cv * 1000) / 10 }
      ],
      label: { show: true, position: 'top', fontSize: 9 }
    });
  });

  lineChart.setOption({
    title: { text: '模块耗时多维度对比', left: 'center', textStyle: { fontSize: 14 } },
    tooltip: { trigger: 'axis' },
    legend: { type: 'scroll', bottom: 0, textStyle: { fontSize: 9 } },
    grid: { left: '8%', right: '5%', top: '15%', bottom: '15%' },
    xAxis: {
      type: 'category',
      data: ['Avg(ms)', 'P95(ms)', 'Max(ms)', 'Std(ms)', 'CV(%)']
    },
    yAxis: { type: 'value', name: '数值' },
    series: series
  });
}

function renderAll() {
  renderBarChart();
  renderPieChart();
  renderLineChart();
}
renderAll();

// ---- 饼图切换 ----
document.getElementById('pieSwitch').addEventListener('click', function(e) {
  if (e.target.classList.contains('switch-btn')) {
    document.querySelectorAll('#pieSwitch .switch-btn').forEach(function(b) {
      b.classList.remove('active');
    });
    e.target.classList.add('active');
    currentPieMode = e.target.dataset.mode;
    renderPieChart();
  }
});

// ---- 模块标签切换 ----
document.getElementById('moduleTabs').addEventListener('click', function(e) {
  if (e.target.classList.contains('module-tab')) {
    document.querySelectorAll('#moduleTabs .module-tab').forEach(function(b) {
      b.classList.remove('active');
    });
    e.target.classList.add('active');
    currentModule = e.target.dataset.mod;
    renderBarChart();
    renderLineChart();
  }
});

// ---- 构建模块切换标签 ----
(function buildTabs() {
  var names = getModuleNames();
  var container = document.getElementById('moduleTabs');
  names.forEach(function(n) {
    var span = document.createElement('span');
    span.className = 'module-tab';
    span.dataset.mod = n.name;
    span.textContent = n.name;
    container.appendChild(span);
  });
})();

// ---- 响应式 ----
window.addEventListener('resize', function() {
  barChart.resize();
  pieChart.resize();
  lineChart.resize();
});
</script>
</body>
</html>"""
