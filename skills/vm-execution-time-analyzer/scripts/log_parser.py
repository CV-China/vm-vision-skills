"""
ModuleFrame 日志解析引擎。

对标 LogTimeAnalyzer C# 代码的 MainWindow 解析逻辑：
- 模块耗时行：包含 [Module ...] 的行，正则提取 Procedure/Module/Type/Time
- 流程耗时行：包含 status=free 的行，正则提取 id/time/executeCount

产出按 module_key 和 procedure_id 分组的原始时间序列数据。
"""

import re
import os
import glob
import json
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from typing import Dict, List, Tuple

# 日志时间戳格式
DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S.%f"

# 快速时间戳提取正则（只提取时间戳，不做完整匹配，用于快速扫描日志时间范围）
TIMESTAMP_PATTERN = re.compile(r"(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})")

# 模块耗时正则（对标 C# ModuleTimePattern）
# 示例: 2026-06-17 10:24:15.270 ERROR [51100] [CModuleNode::DoWork@204] ##[Procedure 10001][Module 14]##[IMVSHPFeatureMatchModu]  status=0(Ok)  module time=230.086ms  process time=230.085ms  algorithm time=175.654ms
MODULE_TIME_PATTERN = re.compile(
    r"(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})"
    r".*?\[Procedure\s+(\d+)\]"
    r"\[Module\s+(\d+)\]"
    r"##\[(\w+)\]"
    r".*?module time=(\d+\.\d+)ms"
)

# 流程耗时正则（对标 C# ProcedureTimePattern）
# 示例: 2026-06-17 10:24:15.277 ERROR [50100] [CProcedure::ReportProcedureStatus@623] Report procedure status  id=10001  status=free  time=246.459  stopAction=0  executeCount=1
PROCEDURE_TIME_PATTERN = re.compile(
    r"(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})"
    r".*?id=(\d+)"
    r".*?time=(\d+\.\d+)"
    r".*?executeCount=(\d+)"
    r"(?:,.*)?$"
)

# 流程 BUSY（开始）行正则 — 用于确定每次流程执行的开始时间戳
# 示例: 2026-06-17 10:45:02.018 INFO  [2904] [CProcedure::ReportProcedureStatus@628] Report procedure status, id=10000, status=busy, time=0.000, stopAction=0, executeCount=11572, cache=0, status=1, triggerCmd=
PROCEDURE_BUSY_PATTERN = re.compile(
    r"(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})"
    r".*?id=(\d+)"
    r".*?status=busy"
    r".*?executeCount=(\d+)"
)

# 流程 Run 开始标记 — 精确标记每次流程执行的起点
# 示例: 2026-06-17 10:24:13.386 INFO  [2904] [CProcedure::DoWork@358] [Run][Begin] Procedure[10000],Continuously[1]
PROCEDURE_RUN_BEGIN_PATTERN = re.compile(
    r"(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})"
    r".*?\[Run\]\[Begin\]\s+Procedure\[(\d+)\]"
)

# 流程 Run 结束标记 — 精确标记每次流程执行的终点
# 示例: 2026-06-17 10:50:44.528 INFO  [2904] [CProcedure::DoWork@525] [Run][End] Procedure[10000]
PROCEDURE_RUN_END_PATTERN = re.compile(
    r"(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})"
    r".*?\[Run\]\[End\]\s+Procedure\[(\d+)\]"
)


def load_module_names(reference_path: str = None) -> Dict[str, str]:
    """加载模块类名→中文名映射表"""
    if reference_path is None:
        reference_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            "references", "module_names.json"
        )
    if os.path.exists(reference_path):
        with open(reference_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def resolve_module_name(internal_name: str, name_map: Dict[str, str]) -> str:
    """将内部模块类名解析为中文显示名（对标 TryFindModuleNameResource）"""
    return name_map.get(internal_name, internal_name)


class TimeRecord:
    """单条耗时记录"""

    __slots__ = ("timestamp", "value_ms", "raw_line", "execute_count")

    def __init__(self, timestamp: datetime, value_ms: float, raw_line: str = "",
                 execute_count: int = 0):
        self.timestamp = timestamp
        self.value_ms = value_ms
        self.raw_line = raw_line
        self.execute_count = execute_count


class ModuleTimeRaw:
    """模块/流程的原始耗时数据集合"""

    def __init__(self, module_id: int, procedure_id: int = 0,
                 module_name: str = "", internal_name: str = ""):
        self.module_id = module_id
        self.procedure_id = procedure_id
        self.module_name = module_name
        self.internal_name = internal_name  # 日志中的英文内部类名（如 IMVSHPFeatureMatchModu）
        self.records: List[TimeRecord] = []
        self.max_record: TimeRecord = None

    def add(self, timestamp: datetime, value_ms: float, raw_line: str,
            execute_count: int = 0, internal_name: str = ""):
        record = TimeRecord(timestamp, value_ms, raw_line, execute_count)
        self.records.append(record)
        if self.max_record is None or value_ms > self.max_record.value_ms:
            self.max_record = record
        # 保留英文内部名（首次设置后不再覆盖，保持一致性）
        if internal_name and not self.internal_name:
            self.internal_name = internal_name

    def merge(self, other: "ModuleTimeRaw"):
        """合并另一个 ModuleTimeRaw 的数据（多文件合并）"""
        self.records.extend(other.records)
        if other.max_record and (self.max_record is None or
                                 other.max_record.value_ms > self.max_record.value_ms):
            self.max_record = other.max_record
        # 同步 internal_name（取优先的非空值）
        if other.internal_name and not self.internal_name:
            self.internal_name = other.internal_name

    @property
    def time_values(self) -> List[float]:
        return [r.value_ms for r in self.records]

    @property
    def count(self) -> int:
        return len(self.records)


def _make_key(module_id: int, procedure_id: int) -> str:
    """为模块创建唯一键（模块ID + 流程ID）"""
    return f"{procedure_id}_{module_id}"


def parse_single_file(filepath: str, name_map: Dict[str, str],
                      time_filter: Tuple[datetime, datetime] = None
                      ) -> Tuple[Dict[str, ModuleTimeRaw], Dict[int, Dict[int, datetime]],
                                 Dict[int, List[datetime]], Dict[int, List[datetime]]]:
    """
    解析单个日志文件，返回本地字典 + BUSY时间戳映射 + Run Begin/End 标记。

    返回: (local_dict, busy_map, run_begins, run_ends)
        - local_dict: {key: ModuleTimeRaw}
        - busy_map: {procedure_id: {executeCount: busy_timestamp}}
        - run_begins: {procedure_id: [begin_datetime, ...]}
        - run_ends: {procedure_id: [end_datetime, ...]}
    """
    local_dict: Dict[str, ModuleTimeRaw] = {}
    busy_map: Dict[int, Dict[int, datetime]] = {}
    run_begins: Dict[int, List[datetime]] = defaultdict(list)
    run_ends: Dict[int, List[datetime]] = defaultdict(list)

    if not os.path.exists(filepath):
        return local_dict, busy_map, run_begins, run_ends

    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            # 快速预过滤（对标 C# line.Contains("[Module ")）
            if "[Module " in line:
                m = MODULE_TIME_PATTERN.search(line)
                if m:
                    _handle_module_match(m, line, local_dict, name_map, time_filter)
            elif "status=free" in line:
                m = PROCEDURE_TIME_PATTERN.search(line)
                if m:
                    _handle_procedure_match(m, line, local_dict, name_map, time_filter)
            elif "status=busy" in line:
                m = PROCEDURE_BUSY_PATTERN.search(line)
                if m:
                    _handle_procedure_busy_match(m, line, busy_map, time_filter)
            elif "[Run][Begin]" in line:
                m = PROCEDURE_RUN_BEGIN_PATTERN.search(line)
                if m:
                    _handle_run_begin_match(m, line, run_begins, time_filter)
            elif "[Run][End]" in line:
                m = PROCEDURE_RUN_END_PATTERN.search(line)
                if m:
                    _handle_run_end_match(m, line, run_ends, time_filter)

    return local_dict, busy_map, run_begins, run_ends


def _handle_module_match(match: re.Match, line: str,
                         local_dict: Dict[str, ModuleTimeRaw],
                         name_map: Dict[str, str],
                         time_filter: Tuple[datetime, datetime]):
    """处理模块耗时匹配（对标 ParseModuleTimeLog）"""
    try:
        timestamp_str = match.group(1)
        procedure_id = int(match.group(2))
        module_id = int(match.group(3))
        internal_name = match.group(4)
        time_ms = float(match.group(5))

        dt = datetime.strptime(timestamp_str, DATETIME_FORMAT)
    except (ValueError, IndexError):
        return

    # 时间过滤（对标 C# EnableFilterTime 逻辑）
    if time_filter and not (time_filter[0] <= dt <= time_filter[1]):
        return

    key = _make_key(module_id, procedure_id)
    if key not in local_dict:
        display_name = resolve_module_name(internal_name, name_map) if name_map else internal_name
        local_dict[key] = ModuleTimeRaw(module_id, procedure_id, display_name)

    local_dict[key].add(dt, time_ms, line, internal_name=internal_name)


def _handle_procedure_match(match: re.Match, line: str,
                            local_dict: Dict[str, ModuleTimeRaw],
                            name_map: Dict[str, str],
                            time_filter: Tuple[datetime, datetime]):
    """处理流程耗时匹配（对标 ParseProcedureTimeLog）"""
    try:
        timestamp_str = match.group(1)
        procedure_id = int(match.group(2))
        time_ms = float(match.group(3))
        execute_count = int(match.group(4))

        dt = datetime.strptime(timestamp_str, DATETIME_FORMAT)
    except (ValueError, IndexError):
        return

    if time_filter and not (time_filter[0] <= dt <= time_filter[1]):
        return

    # 流程数据用 procedure_id 作为 module_id（对标 C# 逻辑）
    key = _make_key(procedure_id, procedure_id)
    if key not in local_dict:
        display_name = resolve_module_name("流程", name_map)
        local_dict[key] = ModuleTimeRaw(procedure_id, procedure_id, display_name)

    local_dict[key].add(dt, time_ms, line, execute_count=execute_count)


def _handle_procedure_busy_match(match: re.Match, line: str,
                                  busy_map: Dict[int, Dict[int, datetime]],
                                  time_filter: Tuple[datetime, datetime]):
    """处理流程 BUSY（开始）行，记录每次流程执行的开始时间戳。

    busy_map 结构: {procedure_id: {executeCount: busy_timestamp}}
    """
    try:
        timestamp_str = match.group(1)
        procedure_id = int(match.group(2))
        execute_count = int(match.group(3))

        dt = datetime.strptime(timestamp_str, DATETIME_FORMAT)
    except (ValueError, IndexError):
        return

    if time_filter and not (time_filter[0] <= dt <= time_filter[1]):
        return

    if procedure_id not in busy_map:
        busy_map[procedure_id] = {}
    # 同一 executeCount 可能多次出现（多文件合并），保留最早的时间戳
    if execute_count not in busy_map[procedure_id]:
        busy_map[procedure_id][execute_count] = dt


def _handle_run_begin_match(match: re.Match, line: str,
                             run_begins: Dict[int, List[datetime]],
                             time_filter: Tuple[datetime, datetime]):
    """处理 [Run][Begin] Procedure[N] 标记"""
    try:
        timestamp_str = match.group(1)
        procedure_id = int(match.group(2))
        dt = datetime.strptime(timestamp_str, DATETIME_FORMAT)
    except (ValueError, IndexError):
        return

    if time_filter and not (time_filter[0] <= dt <= time_filter[1]):
        return

    run_begins[procedure_id].append(dt)


def _handle_run_end_match(match: re.Match, line: str,
                           run_ends: Dict[int, List[datetime]],
                           time_filter: Tuple[datetime, datetime]):
    """处理 [Run][End] Procedure[N] 标记"""
    try:
        timestamp_str = match.group(1)
        procedure_id = int(match.group(2))
        dt = datetime.strptime(timestamp_str, DATETIME_FORMAT)
    except (ValueError, IndexError):
        return

    if time_filter and not (time_filter[0] <= dt <= time_filter[1]):
        return

    run_ends[procedure_id].append(dt)


def parse_log_files(log_dir: str, name_map: Dict[str, str] = None,
                    time_filter: Tuple[datetime, datetime] = None,
                    max_workers: int = 4) -> Tuple[Dict[str, ModuleTimeRaw],
                                                    Dict[int, Dict[int, datetime]],
                                                    Dict[int, List[dict]]]:
    """
    解析日志目录下的所有 ModuleFrame*.log 文件。
    使用多线程并发处理（对标 C# Parallel.ForEach）。

    返回: (合并后的 {key: ModuleTimeRaw},
           {procedure_id: {executeCount: busy_timestamp}},
           {procedure_id: [{begin, end, procedure_id, run_index}, ...]})
    """
    if name_map is None:
        name_map = load_module_names()

    # 查找所有 ModuleFrame*.log 文件
    patterns = [
        os.path.join(log_dir, "ModuleFrame*.log"),
        os.path.join(log_dir, "ModuleFrame*.log.*"),
    ]
    log_files = []
    for pattern in patterns:
        log_files.extend(glob.glob(pattern))
    # 去重排序
    log_files = sorted(set(log_files))

    if not log_files:
        # 也尝试直接读取 ModuleFrame.log
        default_log = os.path.join(log_dir, "ModuleFrame.log")
        if os.path.isfile(default_log):
            log_files = [default_log]

    merged: Dict[str, ModuleTimeRaw] = {}
    merged_busy: Dict[int, Dict[int, datetime]] = {}
    all_begins: Dict[int, List[datetime]] = defaultdict(list)
    all_ends: Dict[int, List[datetime]] = defaultdict(list)

    # 单线程处理（保持顺序，便于调试）或小文件直接用单线程
    if len(log_files) <= 1:
        for fp in log_files:
            local, busy, begins, ends = parse_single_file(fp, name_map, time_filter)
            _merge_into(local, merged)
            _merge_busy_map(busy, merged_busy)
            _merge_run_markers(begins, all_begins)
            _merge_run_markers(ends, all_ends)
    else:
        with ThreadPoolExecutor(max_workers=min(max_workers, len(log_files))) as executor:
            futures = {
                executor.submit(parse_single_file, fp, name_map, time_filter): fp
                for fp in log_files
            }
            for future in as_completed(futures):
                try:
                    local, busy, begins, ends = future.result()
                    _merge_into(local, merged)
                    _merge_busy_map(busy, merged_busy)
                    _merge_run_markers(begins, all_begins)
                    _merge_run_markers(ends, all_ends)
                except Exception as e:
                    fp = futures[future]
                    print(f"解析文件出错 {fp}: {e}")

    # 构建 run_windows: 将 Begin/End 按时间排序后配对
    run_windows = _build_run_windows(all_begins, all_ends)

    return merged, merged_busy, run_windows


def _merge_into(local: Dict[str, ModuleTimeRaw],
                merged: Dict[str, ModuleTimeRaw]):
    # ⚠️ 滚动日志重叠窗口：若 ModuleFrame.log 轮转后与 ModuleFrame.1.log 有重叠记录，
    # extend() 会重复添加导致计数膨胀。建议按 (timestamp, execute_count) 去重。
    """将本地字典合并到全局字典（对标 MergeAnalysisResults）"""
    for key, raw in local.items():
        if key in merged:
            merged[key].merge(raw)
        else:
            merged[key] = raw


def _merge_busy_map(local: Dict[int, Dict[int, datetime]],
                    merged: Dict[int, Dict[int, datetime]]):
    """将本地 BUSY 映射合并到全局 BUSY 映射"""
    for proc_id, exec_map in local.items():
        if proc_id not in merged:
            merged[proc_id] = {}
        for exec_count, busy_ts in exec_map.items():
            # 保留最早的时间戳（同一 executeCount 可能跨文件出现）
            if exec_count not in merged[proc_id]:
                merged[proc_id][exec_count] = busy_ts


def _merge_run_markers(local: Dict[int, List[datetime]],
                        merged: Dict[int, List[datetime]]):
    """将本地的 Run Begin/End 时间戳合并到全局"""
    for proc_id, ts_list in local.items():
        merged[proc_id].extend(ts_list)


def _build_run_windows(all_begins: Dict[int, List[datetime]],
                       all_ends: Dict[int, List[datetime]]
                       ) -> Dict[int, List[dict]]:
    """
    将同一流程的 Begin/End 时间戳按时间排序后配对，构建运行窗口。

    每个窗口精确标记一次流程执行的起止范围，用于将模块耗时记录
    归属到正确的执行次数中。

    Returns:
        {procedure_id: [{begin, end, procedure_id, run_index}, ...]}
        run_index 为 0-based 的执行序号（对应 executeCount - 1）
    """
    run_windows: Dict[int, List[dict]] = {}
    all_proc_ids = set(list(all_begins.keys()) + list(all_ends.keys()))
    for pid in all_proc_ids:
        begins = sorted(all_begins.get(pid, []))
        ends = sorted(all_ends.get(pid, []))
        # Begin 和 End 按时间顺序一一配对
        windows = []
        for i in range(min(len(begins), len(ends))):
            windows.append({
                "begin": begins[i],
                "end": ends[i],
                "procedure_id": pid,
                "run_index": i,
            })
        if windows:
            run_windows[pid] = windows
    return run_windows


def separate_modules_and_procedures(
    raw_data: Dict[str, ModuleTimeRaw]
) -> Tuple[Dict[str, ModuleTimeRaw], Dict[str, ModuleTimeRaw]]:
    """
    将原始数据分离为模块数据和流程数据。

    流程数据: module_id >= 10000（对标 C# ProcessAnalysisResults 逻辑）
    模块数据: module_id < 10000
    """
    modules = {}
    procedures = {}
    for key, raw in raw_data.items():
        if raw.module_id >= 10000:
            procedures[key] = raw
        else:
            modules[key] = raw
    return modules, procedures


def find_latest_timestamp(log_dir: str) -> datetime:
    """
    快速扫描日志目录下所有日志文件，找到最新（最大）的时间戳。
    只做轻量级时间戳提取，不做完整的模块/流程匹配。
    用于在正式解析前确定日志的时间范围，以便按时间段过滤。

    Returns:
        最新时间戳；如果未找到任何时间戳，返回当前时间。
    """
    import glob as glob_mod
    patterns = [
        os.path.join(log_dir, "ModuleFrame*.log"),
        os.path.join(log_dir, "ModuleFrame*.log.*"),
    ]
    log_files = []
    for pattern in patterns:
        log_files.extend(glob_mod.glob(pattern))
    log_files = sorted(set(log_files))

    if not log_files:
        default_log = os.path.join(log_dir, "ModuleFrame.log")
        if os.path.isfile(default_log):
            log_files = [default_log]

    latest = None
    # 倒序读文件末尾更高效（大文件场景），这里逐行扫描保证可靠性
    for fp in log_files:
        try:
            with open(fp, "r", encoding="utf-8", errors="replace") as f:
                for line in f:
                    m = TIMESTAMP_PATTERN.search(line)
                    if m:
                        try:
                            dt = datetime.strptime(m.group(1), DATETIME_FORMAT)
                            if latest is None or dt > latest:
                                latest = dt
                        except ValueError:
                            continue
        except OSError:
            continue

    return latest or datetime.now()
