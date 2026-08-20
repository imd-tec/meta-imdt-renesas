#!/usr/bin/env python3
"""Convert a LAVA results CSV to JUnit XML for GitHub Actions test reporting."""

import csv
import re
import sys
from collections import defaultdict
from datetime import datetime, timezone
from xml.etree import ElementTree as ET

_EPOCH = datetime.min.replace(tzinfo=timezone.utc)


def suite_name(raw):
    """Strip the leading numeric prefix LAVA adds (e.g. '0_ostree-deploy' -> 'ostree-deploy')."""
    return re.sub(r'^\d+_', '', raw)


def parse_ts(ts_str):
    if not ts_str:
        return None
    try:
        return datetime.fromisoformat(ts_str)
    except (ValueError, TypeError):
        return None


def convert(csv_path, xml_path, job_id="unknown"):
    rows = []
    with open(csv_path, newline='') as f:
        for row in csv.DictReader(f):
            if row.get('suite', '') == 'lava':
                continue
            rows.append(row)

    # LAVA doesn't populate the duration column for inline test cases. Use the
    # logged timestamp delta between consecutive results as a timing proxy.
    rows.sort(key=lambda r: parse_ts(r.get('logged')) or _EPOCH)
    for i, row in enumerate(rows):
        if i == 0:
            row['_duration'] = 0.0
        else:
            prev_ts = parse_ts(rows[i - 1].get('logged'))
            curr_ts = parse_ts(row.get('logged'))
            if prev_ts and curr_ts:
                row['_duration'] = max(0.0, (curr_ts - prev_ts).total_seconds())
            else:
                row['_duration'] = 0.0

    suites = defaultdict(list)
    for row in rows:
        suites[row.get('suite', 'unknown')].append(row)

    testsuites = ET.Element('testsuites', name=f'LAVA job {job_id}')

    for suite_raw, cases in suites.items():
        name = suite_name(suite_raw)
        failures = sum(1 for c in cases if c.get('result', '').lower() not in ('pass', 'skip'))
        skipped = sum(1 for c in cases if c.get('result', '').lower() == 'skip')
        suite_time = f"{sum(c['_duration'] for c in cases):.3f}"

        ts = ET.SubElement(testsuites, 'testsuite',
                           name=name, tests=str(len(cases)),
                           failures=str(failures), skipped=str(skipped),
                           errors='0', time=suite_time)

        for case in cases:
            result = case.get('result', '').lower()
            tc_name = case.get('name', 'unknown')

            tc = ET.SubElement(ts, 'testcase',
                               name=tc_name, classname=name,
                               time=f"{case['_duration']:.3f}")

            if result == 'skip':
                ET.SubElement(tc, 'skipped')
            elif result != 'pass':
                f = ET.SubElement(tc, 'failure',
                                  message=f'{name}/{tc_name} -> {result.upper()}',
                                  type='TestFailure')
                f.text = f'LAVA job {job_id}: {suite_raw}/{tc_name} result: {result}'

    try:
        ET.indent(testsuites, space='  ')
    except AttributeError:
        pass  # Python < 3.9

    ET.ElementTree(testsuites).write(xml_path, encoding='unicode', xml_declaration=True)
    print(f'Wrote {xml_path}')


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(f'Usage: {sys.argv[0]} <input.csv> <output.xml> [job_id]', file=sys.stderr)
        sys.exit(1)
    convert(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else 'unknown')
