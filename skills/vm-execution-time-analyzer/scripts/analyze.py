#!/usr/bin/env python3
"""
VisionMaster 方案耗时分析 — 主入口。

用法:
    python analyze.py --log <日志目录> [--output <输出.html>] [--exclude-n <N>]

示例:
    python analyze.py --log ../../输入信息/ModuleProxy/

默认输出到桌面 耗时分析输出/ 文件夹。
"""

import argparse
import os
import sys
from datetime import datetime

# 确保 scripts 目录在 path 中
_script_dir = os.path.dirname(os.path.abspath(__file__))
if _script_dir not in sys.path:
    sys.path.insert(0, _script_dir)

from log_parser import load_module_names
from report_generator import generate_report


def main():
    parser = argparse.ArgumentParser(
        description="VisionMaster 方案耗时分析工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python analyze.py --log 输入信息/ModuleProxy/
  python analyze.py --log logs/ --exclude-n 10

默认输出到桌面 耗时分析输出/ 文件夹。
        """
    )
    parser.add_argument("--log", required=True, help="ModuleFrame 日志目录路径")
    parser.add_argument("--output", default=None, help="输出 HTML 报告路径 (默认: 桌面/耗时分析输出/耗时分析报告_<时间>.html)")
    parser.add_argument("--time-range", default="all",
                        choices=["1h", "3h", "1d", "1w", "all"],
                        help="分析时间段: 1h(近1小时) / 3h(近3小时) / 1d(近1天) / 1w(近1周) / all(全部, 默认)")
    parser.add_argument("--exclude-n", type=int, default=5,
                        help="排除前 N 次运行（VM 预热数据，默认: 5）")

    args = parser.parse_args()

    # 默认输出到桌面 耗时分析输出/ 文件夹
    if args.output is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_filename = f"耗时分析报告_{timestamp}.html"
        desktop = os.path.join(os.path.expanduser("~"), "Desktop")
        output_dir = os.path.join(desktop, "耗时分析输出")
        args.output = os.path.join(output_dir, output_filename)

    if not os.path.isdir(args.log):
        print(f"错误: 日志目录不存在: {args.log}")
        print("提示: 请确认 --log 参数指向包含 ModuleFrame*.log 的目录")
        sys.exit(1)

    # 加载模块名映射
    name_map = load_module_names()

    # 生成报告
    success = generate_report(
        log_dir=args.log,
        output_path=args.output,
        exclude_first_n=args.exclude_n,
        name_map=name_map,
        time_range=args.time_range,
    )

    if success:
        print("\n[OK] Report generated successfully!")
        abs_output = os.path.abspath(args.output)
        print(f"Output: {abs_output}")
        print("Open in browser to view.")
    else:
        print("\n[FAIL] Report generation failed. Check logs above.")
        sys.exit(1)


if __name__ == "__main__":
    main()
