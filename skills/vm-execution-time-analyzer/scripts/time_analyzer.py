"""
耗时统计分析器。

对标 LogTimeAnalyzer C# 代码的 CalculateStatistics 逻辑：
- 排除前 N 次运行
- 计算 Min/Max/Avg/Std/P50/P75/P95/P99
- 计算极差（Max-Min）、超2倍均值次数
- 基于变异系数(CV)的波动评级

生成评估结论：流程级汇总 + 模块级明细 + 整体耗时评估
"""

import math
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, field
from log_parser import ModuleTimeRaw


@dataclass
class TimeStatistics:
    """耗时统计结果（对标 C# ModuleTimeInfo）"""
    module_id: int = 0
    procedure_id: int = 0
    module_name: str = ""
    count: int = 0
    avg_ms: float = 0.0
    max_ms: float = 0.0
    min_ms: float = 0.0
    std_ms: float = 0.0
    p50: float = 0.0
    p75: float = 0.0
    p95: float = 0.0
    p99: float = 0.0
    total_ms: float = 0.0
    range_ms: float = 0.0          # 极差 (Max-Min)
    over_two_times_count: int = 0  # 超2倍均值次数
    cv: float = 0.0                # 变异系数 (Std/Avg)
    volatility_level: str = ""     # 波动等级: 🟢低 / 🟡中 / 🔴高
    proportion_in_procedure: float = 0.0  # 模块耗时占所在流程总模块耗时的比例 (0~1)
    vci: float = 0.0               # 波动贡献指数 = CV × 流程占比，衡量该模块对整体稳定性的影响程度
    volatility_impact: str = ""    # 波动影响评级: 🟢低影响 / 🟡中影响 / 🔴高影响
    internal_name: str = ""        # 日志中的英文内部类名（如 IMVSHPFeatureMatchModu）
    max_record_line: str = ""      # 最大耗时对应的日志行
    max_timestamp: str = ""        # 最大耗时的发生时刻 (HH:MM:SS.fff)
    time_series: List[float] = field(default_factory=list)  # 时间序列（采样后）
    time_labels: List[str] = field(default_factory=list)    # 横坐标时间标签（HH:MM:SS）
    top10_values: List[float] = field(default_factory=list)      # 耗时最大的前10次值（降序）
    top10_timestamps: List[str] = field(default_factory=list)    # 对应的完整时间戳字符串


@dataclass
class ProcedureSummary:
    """流程级汇总"""
    procedure_id: int = 0
    module_count: int = 0
    total_executions: int = 0
    avg_ms: float = 0.0
    max_ms: float = 0.0
    min_ms: float = 0.0
    p95: float = 0.0
    cv: float = 0.0
    volatility_level: str = ""
    modules: List[TimeStatistics] = field(default_factory=list)
    proportion_pct: float = 0.0    # 占总耗时百分比
    vci: float = 0.0               # 流程级波动贡献指数 = CV × 流程占比
    volatility_impact: str = ""    # 流程级波动影响评级（流程间VCI百分位排序）
    high_impact_modules: List[dict] = field(default_factory=list)  # 该流程内高波动影响模块（[{module_id, module_name}]，module_name为英文内部名）
    worst_runs: List[dict] = field(default_factory=list)  # 耗时最大的前5次运行详情
    max_timestamp: str = ""        # 最大耗时的发生时刻 (HH:MM:SS.fff)


@dataclass
class OverallEvaluation:
    """整体方案耗时评估"""
    total_modules: int = 0
    total_procedures: int = 0
    total_executions: int = 0
    total_time_ms: float = 0.0
    bottleneck_module: str = ""    # 耗时瓶颈模块
    bottleneck_procedure: int = 0  # 耗时瓶颈流程
    high_volatility_modules: List[str] = field(default_factory=list)  # 高CV模块（CV>50%）
    high_impact_modules: List[str] = field(default_factory=list)      # 高波动影响模块（VCI流程内排序前5%，综合CV×占比）
    summary_text: str = ""         # 自然语言评估结论


def compute_statistics(raw: ModuleTimeRaw,
                       exclude_first_n: int = 0) -> TimeStatistics:
    """
    对单个模块/流程的原始数据计算统计指标。
    对标 C# CalculateStatistics + CalculatePercentiles。

    Args:
        raw: 原始数据
        exclude_first_n: 排除前N次运行（对标 EnableExcludeFirstNRuns）
    """
    if not raw.records:
        return TimeStatistics(
            module_id=raw.module_id,
            procedure_id=raw.procedure_id,
            module_name=raw.module_name,
        )

    # 按时间排序
    sorted_records = sorted(raw.records, key=lambda r: r.timestamp)

    # 排除前 N 次（VM 启动预热）
    if exclude_first_n > 0 and len(sorted_records) > exclude_first_n:
        sorted_records = sorted_records[exclude_first_n:]

    times = [r.value_ms for r in sorted_records]
    n = len(times)
    if n == 0:
        return TimeStatistics(
            module_id=raw.module_id,
            procedure_id=raw.procedure_id,
            module_name=raw.module_name,
        )

    sorted_times = sorted(times)

    # 基础统计
    min_val = round(sorted_times[0], 3)
    max_val = round(sorted_times[-1], 3)
    avg_val = round(sum(times) / n, 3)
    total_val = round(sum(times), 1)

    # 标准差
    if n > 1:
        variance = sum((t - avg_val) ** 2 for t in times) / n
        std_val = round(math.sqrt(variance), 3)
    else:
        std_val = 0.0

    # 百分位计算（对标 C# CalculatePercentiles）
    def percentile(sorted_data: List[float], p: float) -> float:
        """计算百分位，使用 ceiling 索引（对标 C# 逻辑）"""
        if not sorted_data:
            return 0.0
        idx = int(math.ceil(p * (len(sorted_data) - 1)))
        idx = max(0, min(len(sorted_data) - 1, idx))
        return round(sorted_data[idx], 3)

    p50 = percentile(sorted_times, 0.50)
    p75 = percentile(sorted_times, 0.75)
    p95 = percentile(sorted_times, 0.95)
    p99 = percentile(sorted_times, 0.99)

    # 极差（对标 C# Variance = Max - Min）
    range_val = round(max_val - min_val, 3)

    # 超2倍均值次数
    threshold = avg_val * 2
    over_count = sum(1 for t in sorted_times if t > threshold)

    # 变异系数 CV = Std / Avg
    cv_val = round(std_val / avg_val, 4) if avg_val > 0 else 0.0

    # 波动评级
    if cv_val > 0.50:
        vol = "🔴高"
    elif cv_val >= 0.20:
        vol = "🟡中"
    else:
        vol = "🟢低"

    # 最大耗时日志行
    max_line = ""
    max_ts = ""
    for r in sorted_records:
        if r.value_ms == max_val:
            max_line = r.raw_line.strip()
            max_ts = r.timestamp.strftime("%H:%M:%S.%f")[:-3]  # 截断到毫秒
            break

    # 耗时最大的前5次（用于流程拓展图的"最慢五次"视图）
    worst5 = sorted(sorted_records, key=lambda r: r.value_ms, reverse=True)[:5]
    top10_values_list = [round(r.value_ms, 3) for r in worst5]
    top10_timestamps_list = [r.timestamp.strftime("%Y-%m-%d %H:%M:%S.%f") for r in worst5]

    # 时间序列采样（按时间顺序保留最多 MAX_SERIES_POINTS 个点，用于前端曲线图）
    MAX_SERIES_POINTS = 500
    series = times  # times 已按时间排序
    labels = [r.timestamp.strftime("%H:%M:%S") for r in sorted_records]
    if len(series) > MAX_SERIES_POINTS:
        step = len(series) / MAX_SERIES_POINTS
        sampled = []
        sampled_labels = []
        for i in range(MAX_SERIES_POINTS):
            idx = int(i * step)
            if idx < len(series):
                sampled.append(round(series[idx], 3))
                sampled_labels.append(labels[idx])
        series = sampled
        labels = sampled_labels

    return TimeStatistics(
        module_id=raw.module_id,
        procedure_id=raw.procedure_id,
        module_name=raw.module_name,
        count=n,
        avg_ms=avg_val,
        max_ms=max_val,
        min_ms=min_val,
        std_ms=std_val,
        p50=p50,
        p75=p75,
        p95=p95,
        p99=p99,
        total_ms=total_val,
        range_ms=range_val,
        over_two_times_count=over_count,
        cv=cv_val,
        volatility_level=vol,
        internal_name=raw.internal_name,
        max_record_line=max_line,
        max_timestamp=max_ts,
        time_series=series,
        time_labels=labels,
        top10_values=top10_values_list,
        top10_timestamps=top10_timestamps_list,
    )


def filter_low_time(stats_list: List[TimeStatistics],
                    avg_threshold: float = 0.1,
                    max_threshold: float = 1.0) -> List[TimeStatistics]:
    """过滤耗时极小的数据（对标 C# ProcessAnalysisResults）"""
    return [
        s for s in stats_list
        if not (s.avg_ms < avg_threshold and s.max_ms < max_threshold)
    ]


def analyze(raw_data: Dict[str, ModuleTimeRaw],
            exclude_first_n: int = 5,
            procedure_busy_map: Dict[int, Dict[int, datetime]] = None,
            run_windows: Dict[int, List[dict]] = None
            ) -> Dict:
    """
    完整的耗时分析入口。

    Args:
        raw_data: 解析后的原始数据 {key: ModuleTimeRaw}
        exclude_first_n: 排除前 N 次运行（预热）
        procedure_busy_map: 流程 BUSY 时间戳映射 {procedure_id: {executeCount: busy_timestamp}}
        run_windows: 流程 Run Begin/End 精确窗口 {procedure_id: [{begin, end, run_index}]}

    返回:
        {
            "modules": List[TimeStatistics],      # 模块级统计
            "procedures": List[TimeStatistics],    # 流程级统计
            "procedure_summaries": List[ProcedureSummary],  # 流程汇总
            "evaluation": OverallEvaluation,       # 整体评估
        }
    """
    # 分离模块和流程数据
    modules_raw = {}
    procedures_raw = {}
    for key, raw in raw_data.items():
        if raw.module_id >= 10000:
            procedures_raw[key] = raw
        else:
            modules_raw[key] = raw

    # 计算统计（排除前 exclude_first_n 次运行）
    module_stats = [
        compute_statistics(raw, exclude_first_n)
        for raw in modules_raw.values()
    ]
    procedure_stats = [
        compute_statistics(raw, exclude_first_n)
        for raw in procedures_raw.values()
    ]

    # 过滤低耗时数据
    module_stats = filter_low_time(module_stats)
    procedure_stats = filter_low_time(procedure_stats)

    # 按平均耗时降序排列
    module_stats.sort(key=lambda x: x.avg_ms, reverse=True)
    procedure_stats.sort(key=lambda x: x.avg_ms, reverse=True)

    # 构建流程汇总
    total_all_time = sum(s.total_ms for s in procedure_stats)
    procedure_summaries = []

    for proc_stat in procedure_stats:
        # 找到属于该流程的模块
        proc_modules = [
            m for m in module_stats
            if m.procedure_id == proc_stat.procedure_id
        ]
        proc_modules.sort(key=lambda x: x.avg_ms, reverse=True)

        # 流程内模块总耗时
        proc_module_total = sum(m.total_ms for m in proc_modules)

        proc_summary = ProcedureSummary(
            procedure_id=proc_stat.procedure_id,
            module_count=len(proc_modules),
            total_executions=proc_stat.count,
            avg_ms=proc_stat.avg_ms,
            max_ms=proc_stat.max_ms,
            min_ms=proc_stat.min_ms,
            p95=proc_stat.p95,
            cv=proc_stat.cv,
            volatility_level=proc_stat.volatility_level,
            modules=proc_modules,
            proportion_pct=round(
                proc_stat.total_ms / total_all_time * 100, 1
            ) if total_all_time > 0 else 0.0,
            max_timestamp=proc_stat.max_timestamp,
        )
        procedure_summaries.append(proc_summary)

    procedure_summaries.sort(key=lambda x: x.procedure_id)

    # ── 计算波动贡献指数 (VCI = CV × 流程占比) ──
    # VCI 衡量模块耗时波动对整个方案/流程稳定性的实际影响程度。
    # 单纯看 CV 不够——一个 CV 很高但耗时占比极小的模块，对整体稳定性影响有限。
    # 综合 CV 和占比才能找出真正导致整体方案忽快忽慢的"元凶"。
    #
    # 波动影响评级采用流程内百分位排序（动态阈值），而非固定阈值：
    # - 流程内模块数差异大时，固定阈值（如 >15%=高影响）在小流程中过严、大流程中过松
    # - 改用排序后：前5%为高影响（头号嫌疑）、5%~20%为中影响（需关注）、其余为低影响
    # - 这样无论流程有多少模块，每个流程都能公平区分出影响最大的那几个
    for proc_summary in procedure_summaries:
        proc_total_module_time = sum(
            m.total_ms for m in proc_summary.modules
        )
        for m in proc_summary.modules:
            if proc_total_module_time > 0:
                m.proportion_in_procedure = round(
                    m.total_ms / proc_total_module_time, 4
                )
            else:
                m.proportion_in_procedure = 0.0
            # VCI = CV × 流程占比 (两者皆为0~1比例)
            m.vci = round(m.cv * m.proportion_in_procedure, 4)

        # ── 流程内百分位排序分配波动影响评级 ──
        sorted_mods = sorted(
            proc_summary.modules,
            key=lambda m: m.vci, reverse=True
        )
        n = len(sorted_mods)
        if n > 0:
            # 前5% = 🔴高影响（至少1个，前提是该模块 VCI>0）
            top5_count = max(1, math.ceil(n * 0.05))
            # 5%~20% = 🟡中影响
            top20_count = max(top5_count + 1, math.ceil(n * 0.20))
        else:
            top5_count = 0
            top20_count = 0

        high_impact = []
        for i, m in enumerate(sorted_mods):
            if i < top5_count and m.vci > 0:
                m.volatility_impact = "🔴高影响"
                high_impact.append({"module_id": m.module_id, "module_name": m.internal_name})
            elif i < top20_count and m.vci > 0:
                m.volatility_impact = "🟡中影响"
            else:
                m.volatility_impact = "🟢低影响"
        proc_summary.high_impact_modules = high_impact

    # ── 计算流程级波动贡献指数 (VCI) ──
    # 每个流程也有自己的波动影响评级，用于在"流程级耗时汇总"表中展示。
    # 流程 VCI = 流程自身的 CV × 流程耗时占总耗时的比例。
    # 在所有流程之间进行同样的百分位排序，得出各流程的波动影响评级。
    for proc_summary in procedure_summaries:
        proc_summary.vci = round(
            proc_summary.cv * (proc_summary.proportion_pct / 100.0), 4
        )

    # 跨流程百分位排序分配波动影响评级
    sorted_procs = sorted(
        procedure_summaries,
        key=lambda p: p.vci, reverse=True
    )
    pn = len(sorted_procs)
    if pn > 0:
        proc_top5 = max(1, math.ceil(pn * 0.05))
        proc_top20 = max(proc_top5 + 1, math.ceil(pn * 0.20))
    else:
        proc_top5 = 0
        proc_top20 = 0

    for i, p in enumerate(sorted_procs):
        if i < proc_top5 and p.vci > 0:
            p.volatility_impact = "🔴高影响"
        elif i < proc_top20 and p.vci > 0:
            p.volatility_impact = "🟡中影响"
        else:
            p.volatility_impact = "🟢低影响"

    # ── 构建每个流程耗时最大五次的详情 ──
    for proc_summary in procedure_summaries:
        pid = proc_summary.procedure_id
        proc_key = f"{pid}_{pid}"
        proc_raw = raw_data.get(proc_key)
        if not proc_raw or not proc_raw.records:
            continue

        # 按时间排序，排除前 N 次预热
        proc_records = sorted(proc_raw.records, key=lambda r: r.timestamp)
        if exclude_first_n > 0 and len(proc_records) > exclude_first_n:
            proc_records = proc_records[exclude_first_n:]

        # 耗时最大的前5次
        worst5 = sorted(proc_records, key=lambda r: r.value_ms, reverse=True)[:5]

        # 获取该流程的 BUSY 时间戳映射
        pid_busy = procedure_busy_map.get(pid, {}) if procedure_busy_map else {}

        worst_runs = []
        for wr in worst5:
            free_ts = wr.timestamp
            exec_count = wr.execute_count

            # ── 确定本次执行的精确时间窗口 ──
            # 优先使用 [Run][Begin] ~ [Run][End] 标记精确界定流程执行边界。
            # executeCount 从1开始，run_windows 索引从0开始。
            # 窗口 = [Run][Begin] ~ [Run][End] + 缓冲（兜底捕获异步延迟落盘的模块日志）。
            # 非末次运行额外叠加下一次 [Run][Begin] + 5s 兜底，避免跨运行串扰。
            window_start = None
            window_end = None

            if run_windows and exec_count:
                rw_list = run_windows.get(pid, [])
                rw_idx = exec_count - 1  # executeCount 是 1-based
                if 0 <= rw_idx < len(rw_list):
                    rw = rw_list[rw_idx]
                    window_start = rw["begin"]
                    # 默认用 [Run][End] + 120s 兜底捕获异步延迟日志
                    window_end = rw["end"] + timedelta(seconds=120)
                    # 非末次运行：额外取下一次 [Run][Begin] + 5s 兜底，避免异步
                    # 日志跨运行串扰的同时仍能捕获本次运行最后落盘的模块记录
                    if rw_idx + 1 < len(rw_list):
                        next_begin_bound = rw_list[rw_idx + 1]["begin"] + timedelta(seconds=5)
                        if next_begin_bound < window_end:
                            window_end = next_begin_bound

            if window_start is None:
                # 降级1：BUSY→FREE 窗口 + 5s 缓冲
                busy_ts = pid_busy.get(exec_count) if exec_count and pid_busy else None
                if busy_ts:
                    window_start = busy_ts
                    window_end = free_ts + timedelta(seconds=5)
                else:
                    # 降级2：以 FREE 时间戳为基准，前120s后5s窗口
                    # （兼容无 BUSY/无 Run 标记的旧日志，120s 足够覆盖超长流程）
                    window_start = free_ts - timedelta(seconds=120)
                    window_end = free_ts + timedelta(seconds=5)

            module_times = {}
            for mod in proc_summary.modules:
                mod_key = f"{pid}_{mod.module_id}"
                mod_raw = raw_data.get(mod_key)
                if not mod_raw or not mod_raw.records:
                    continue
                # 取窗口内该模块所有有效记录，按 execute_count 去重后累加
                # （同一 execute_count 可能因异步写入出现重复，取第一次值；累加不同 execute_count 以正确反映循环内多次调用的真实耗时）
                seen_counts = set()
                total_val = 0.0
                for r in mod_raw.records:
                    if r.timestamp < window_start or r.timestamp > window_end:
                        continue
                    if r.execute_count not in seen_counts:
                        seen_counts.add(r.execute_count)
                        total_val += r.value_ms
                if seen_counts:
                    module_times[str(mod.module_id)] = round(total_val, 3)

            worst_runs.append({
                "timestamp": free_ts.strftime("%Y-%m-%d %H:%M:%S.%f"),
                "timestamp_short": free_ts.strftime("%H:%M:%S"),
                "total_ms": round(wr.value_ms, 3),
                "module_times": module_times,
            })

        proc_summary.worst_runs = worst_runs

    # 生成整体评估
    evaluation = _generate_evaluation(
        module_stats, procedure_stats, procedure_summaries
    )

    return {
        "modules": module_stats,
        "procedures": procedure_stats,
        "procedure_summaries": procedure_summaries,
        "evaluation": evaluation,
    }


def _generate_evaluation(
    module_stats: List[TimeStatistics],
    procedure_stats: List[TimeStatistics],
    procedure_summaries: List[ProcedureSummary],
) -> OverallEvaluation:
    """生成结构化整体评估结论 HTML"""
    total_time = sum(p.total_ms for p in procedure_stats)
    total_exec = max((p.count for p in procedure_stats), default=0)

    # 瓶颈流程
    bottleneck_proc = procedure_summaries[0] if procedure_summaries else None

    # 瓶颈模块（全方案最高耗时模块）
    bottleneck_mod = module_stats[0] if module_stats else None

    # 高波动模块（纯CV>50%，仅作参考）
    high_vol = [
        m.module_name for m in module_stats
        if m.volatility_level == "🔴高" and m.count > 10
    ]

    # 高波动影响模块（VCI流程内排序前5%，综合CV×耗时占比）
    high_impact_mods = sorted(
        [m for m in module_stats if m.volatility_impact == "🔴高影响" and m.count > 10],
        key=lambda x: x.vci, reverse=True
    )
    high_impact_names = [m.module_name for m in high_impact_mods]

    # ── 构建结构化 HTML 摘要 ──
    lines = []

    # ═══ 1. 耗时波动影响最大的流程 ═══
    top_vci_proc = None
    if procedure_summaries:
        proc_by_vci = sorted(procedure_summaries, key=lambda p: p.vci, reverse=True)
        top_vci_proc = proc_by_vci[0]

    if top_vci_proc and top_vci_proc.vci > 0:
        lines.append('<div style="margin-bottom:16px;">')
        lines.append('<strong style="font-size:1.05em;color:var(--primary);">'
                     '1. 耗时波动影响最大的流程</strong><br>')
        lines.append(
            f'<span style="font-size:1.1em;">流程<strong>{top_vci_proc.procedure_id}</strong>'
            f'（{top_vci_proc.volatility_impact}），'
            f'平均耗时 <strong style="color:var(--danger);">{top_vci_proc.avg_ms}ms</strong>，'
            f'最大耗时 <strong>{top_vci_proc.max_ms}ms</strong>，'
            f'最小耗时 <strong>{top_vci_proc.min_ms}ms</strong>'
            f'（共{top_vci_proc.module_count}个模块，执行{top_vci_proc.total_executions}次）</span>'
        )
        lines.append('</div>')

        # ═══ 2. 该流程内波动影响最大的模块 ═══
        proc_modules = top_vci_proc.modules
        if proc_modules:
            top_vci_mod = sorted(proc_modules, key=lambda m: m.vci, reverse=True)[0]
            if top_vci_mod.vci > 0:
                lines.append('<div style="margin-bottom:16px;">')
                lines.append('<strong style="font-size:1.05em;color:var(--primary);">'
                             '2. 流程内波动影响最大的模块</strong><br>')
                lines.append(
                    f'<span style="font-size:1.1em;">'
                    f'流程<strong>{top_vci_proc.procedure_id}</strong> · '
                    f'模块ID:<strong>{top_vci_mod.module_id}</strong> '
                    f'「<strong>{top_vci_mod.module_name}</strong>」'
                    f'（{top_vci_mod.volatility_impact}），'
                    f'平均耗时 <strong style="color:var(--danger);">{top_vci_mod.avg_ms}ms</strong>，'
                    f'最大耗时 <strong>{top_vci_mod.max_ms}ms</strong>，'
                    f'最小耗时 <strong>{top_vci_mod.min_ms}ms</strong>'
                    f'</span>'
                )
                lines.append('</div>')

        # ═══ 3. 最慢前五次中最拖累流程的模块 ═══
        worst_runs = top_vci_proc.worst_runs
        if worst_runs and proc_modules:
            # 对每个模块，计算其最慢运行中的耗时与平均耗时的最大偏差
            # 找到偏差最大的模块，即为波动最大拖累
            mod_deviation = {}  # module_name -> {max_gap, worst_time, avg, run_index}
            for mod in proc_modules:
                mod_key = str(mod.module_id)
                max_gap = -1
                worst_time = 0
                worst_run_idx = -1
                for ri, run in enumerate(worst_runs):
                    mt = run.get("module_times", {}).get(mod_key)
                    if mt is not None:
                        gap = mt - mod.avg_ms
                        if gap > max_gap:
                            max_gap = gap
                            worst_time = mt
                            worst_run_idx = ri
                if max_gap > 0:
                    mod_deviation[mod_key] = {
                        "module": mod,
                        "max_gap": max_gap,
                        "worst_time": worst_time,
                        "worst_run_idx": worst_run_idx,
                    }

            if mod_deviation:
                # 按最大偏差降序，取最大的那个模块
                sorted_dev = sorted(
                    mod_deviation.items(),
                    key=lambda kv: kv[1]["max_gap"], reverse=True
                )
                worst_offender_name, worst_data = sorted_dev[0]
                worst_mod = worst_data["module"]
                lines.append('<div style="margin-bottom:16px;">')
                lines.append('<strong style="font-size:1.05em;color:var(--primary);">'
                             '3. 最慢前五次中波动拖累最大的模块</strong><br>')
                exceed = round(worst_data["worst_time"] - worst_mod.avg_ms, 3)
                lines.append(
                    f'<span style="font-size:1.1em;">'
                    f'流程<strong>{top_vci_proc.procedure_id}</strong> · '
                    f'模块ID:<strong>{worst_mod.module_id}</strong> '
                    f'「<strong>{worst_mod.module_name}</strong>」，'
                    f'最慢一次耗时 <strong style="color:var(--danger);">'
                    f'{worst_data["worst_time"]}ms</strong>'
                    f'（超出均值 {exceed}ms），'
                    f'平均耗时 <strong>{worst_mod.avg_ms}ms</strong>'
                    f'</span>'
                )
                lines.append('</div>')

    summary_text = "\n".join(lines)

    return OverallEvaluation(
        total_modules=len(module_stats),
        total_procedures=len(procedure_stats),
        total_executions=total_exec,
        total_time_ms=round(total_time, 1),
        bottleneck_module=bottleneck_mod.module_name if bottleneck_mod else "",
        bottleneck_procedure=bottleneck_proc.procedure_id if bottleneck_proc else 0,
        high_volatility_modules=high_vol,
        high_impact_modules=high_impact_names,
        summary_text=summary_text,
    )


def format_evaluation_text(evaluation: OverallEvaluation) -> str:
    """将评估结论转为纯文本，用于控制台输出"""
    import re

    def strip_html(text: str) -> str:
        """移除 HTML 标签，保留文本内容"""
        text = re.sub(r'<br\s*/?>', '\n', text)
        text = re.sub(r'<[^>]+>', '', text)
        return text.strip()

    plain = strip_html(evaluation.summary_text)

    lines = []
    lines.append("=" * 56)
    lines.append("  [整体评估结论]")
    lines.append("=" * 56)
    lines.append("")
    lines.append(plain)
    lines.append("")
    lines.append("-" * 56)
    lines.append(f"  总模块数: {evaluation.total_modules}"
                 f"  |  总流程数: {evaluation.total_procedures}"
                 f"  |  总执行次数: {evaluation.total_executions}")
    lines.append("=" * 56)
    return "\n".join(lines)
