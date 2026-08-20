#!/usr/bin/env python3
"""Render a LAVA results CSV as a PR comment.

Uses csv.DictReader rather than splitting on commas: LAVA's metadata column is a
quoted dict that contains commas, which shifts every later column if split.
"""
import csv
import re
import sys
from collections import OrderedDict

ICON = {"pass": "✅", "skip": "⏭️", "fail": "❌"}


def main() -> int:
    csv_path, out_path, host, image, machine, jobs = sys.argv[1:7]

    rows = []
    try:
        with open(csv_path, newline="") as f:
            rows = [r for r in csv.DictReader(f) if r.get("suite") != "lava"]
    except FileNotFoundError:
        pass

    def result(row):
        return (row.get("result") or "").lower()

    passed = sum(1 for r in rows if result(r) == "pass")
    skipped = sum(1 for r in rows if result(r) == "skip")
    failed = len(rows) - passed - skipped

    # LAVA prefixes suites with their index; drop it for display but keep order.
    suites = OrderedDict()
    for r in rows:
        name = re.sub(r"^\d+_", "", r.get("suite", "unknown"))
        suites.setdefault(name, []).append(r)

    links = " · ".join(
        f"[job #{j}](http://{host}/scheduler/job/{j})" for j in jobs.split() if j
    )
    status = "✅" if rows and not failed else ("❌" if rows else "❓")

    out = [
        f"## {status} LAVA hardware tests — `{image}` on `{machine}`",
        "",
        links,
        "",
        f"**{passed} passed** · **{failed} failed**"
        + (f" · {skipped} skipped" if skipped else ""),
        "",
        "| Suite | Cases | Result |",
        "|-------|-------|--------|",
    ]
    for name, suite_rows in suites.items():
        bad = [r for r in suite_rows if result(r) not in ("pass", "skip")]
        icon = "❌" if bad else "✅"
        detail = f"{len(bad)} failed" if bad else "all passed"
        out.append(f"| {name} | {len(suite_rows)} | {icon} {detail} |")

    if not rows:
        out.append("| — | — | no results found |")

    if failed:
        out += ["", "### Failures", ""]
        for r in rows:
            if result(r) not in ("pass", "skip"):
                suite = re.sub(r"^\d+_", "", r.get("suite", ""))
                out.append(f"- `{suite}` / `{r.get('name')}` — {result(r)}")

    # Full list stays available without making the comment unreadable.
    out += ["", "<details><summary>All test cases</summary>", ""]
    for name, suite_rows in suites.items():
        out.append(f"**{name}**")
        for r in suite_rows:
            out.append(f"- {ICON.get(result(r), '❔')} `{r.get('name')}`")
        out.append("")
    out.append("</details>")

    with open(out_path, "w") as f:
        f.write("\n".join(out) + "\n")
    print(f"Wrote {out_path}: {len(rows)} cases, {failed} failed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
