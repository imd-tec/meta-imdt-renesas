#!/usr/bin/env python3
"""Read LAVA results CSV from stdin, exit 1 if any test case failed."""
import sys
import csv

reader = csv.DictReader(sys.stdin)
rows = [r for r in reader if r.get('suite') != 'lava']
failures = [r for r in rows if r.get('result', '').lower() not in ('pass', 'skip')]
for f in failures:
    print(f"  FAIL: {f.get('suite', '?')}/{f.get('name', '?')} -> {f.get('result', '?')}")
if failures:
    print(f"{len(failures)} test(s) failed")
    sys.exit(1)
print(f"All {len(rows)} test(s) passed")
