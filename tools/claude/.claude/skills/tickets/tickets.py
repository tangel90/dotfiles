#!/usr/bin/env python3
"""Query a project's ticket files (tickets/<PREFIX>-NNN-<slug>.md). Read-only, stdlib only.

  tickets.py open     [--owner NAME] [--status S] [--area A] [--oneline]
  tickets.py frontier [--area A]          ready-for-agent, unclaimed, every blocker done
  tickets.py triage                       needs-triage, needs-info, files with a bad/missing Status
  tickets.py show ID                      print one ticket (ID: RDS-7, RDS-007, 7 or JIRA-RDS-1234)
  tickets.py next-id [--prefix P]         next free id, e.g. RDS-012
  tickets.py check                        format problems (missing fields, unknown blockers, ...)

Finds the tickets/ folder by walking up from the current directory (or --dir).
"""
import argparse
import re
import sys
from pathlib import Path

STATUSES = ["needs-triage", "needs-info", "ready-for-agent", "ready-for-human", "in-progress", "review", "wontfix", "done"]
CLOSED = {"wontfix", "done"}
CATEGORIES = {"bug", "enhancement"}
FIELDS = ["Status", "Category", "Owner", "Area", "Blocked by", "Branch", "PR", "Intent"]
# local: RDS-007-slug.md; Jira mirror: JIRA-<jira key>-slug.md, e.g. JIRA-RDS-1234-slug.md
NAME_RE = re.compile(r"^((?:JIRA-)?[A-Z][A-Z0-9]*)-(\d+)-[a-z0-9-]+\.md$")
ID_RE = re.compile(r"^((?:JIRA-)?[A-Z][A-Z0-9]*)-0*(\d+)$")
NONE = {"", "-", "none"}


def find_dir(start):
    for d in [start, *start.parents]:
        if (d / "tickets").is_dir():
            return d / "tickets"
    sys.exit(f"no tickets/ folder at or above {start}")


def norm_id(s, prefix=None):
    s = s.strip().strip("[]")
    m = ID_RE.match(s.upper())
    if m:
        return f"{m.group(1)}-{int(m.group(2))}"
    if s.isdigit() and prefix:
        return f"{prefix}-{int(s)}"
    return None


def parse(path):
    m = NAME_RE.match(path.name)
    t = {"path": path, "file_ok": bool(m), "fields": {}, "title": path.stem}
    t["id"] = f"{m.group(1)}-{int(m.group(2))}" if m else path.stem
    t["label"] = f"{m.group(1)}-{m.group(2)}" if m else path.stem
    lines = path.read_text(encoding="utf-8").splitlines()
    for line in lines:
        if line.startswith("## "):
            break  # header ends at the first section
        if line.startswith("# ") and t["title"] == path.stem:
            t["title"] = re.sub(r"^#\s+(?:JIRA-)?[A-Z0-9]+-\d+:\s*", "", line).strip()
            continue
        fm = re.match(r"^\**([A-Za-z ]+?)\**:\**\s*(.*)$", line)
        if fm and fm.group(1) in FIELDS:
            t["fields"][fm.group(1)] = fm.group(2).strip()
    f = t["fields"]
    t["status"] = f.get("Status", "").lower()
    t["owner"] = "" if f.get("Owner", "").lower() in NONE else f.get("Owner", "").lstrip("@")
    t["area"] = f.get("Area", "")
    raw = f.get("Blocked by", "")
    t["blockers"] = [] if raw.lower() in NONE else [b.strip() for b in re.split(r"[,;]", raw) if b.strip()]
    return t


def load(d):
    return [parse(p) for p in sorted(d.glob("*.md"))]


def blocking(t, by_id, prefix):
    """Blockers not yet done. Free text (e.g. 'TST exists') and wontfix blockers keep blocking until edited out."""
    out = []
    for b in t["blockers"]:
        bid = norm_id(b, prefix)
        other = by_id.get(bid) if bid else None
        if other is None or other["status"] != "done":
            out.append(b)
    return out


def line(t, by_id, prefix):
    bl = blocking(t, by_id, prefix)
    extra = []
    if t["owner"]:
        extra.append(f"@{t['owner']}")
    if t["area"]:
        extra.append(t["area"])
    if bl:
        extra.append("blocked by " + ", ".join(bl))
    return f"{t["label"]:<14} {t['status'] or '?':<16} {t['title']}" + (f"  ({'; '.join(extra)})" if extra else "")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dir", type=Path, help="hub folder or its tickets/ folder (default: walk up from cwd)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    o = sub.add_parser("open")
    o.add_argument("--owner")
    o.add_argument("--status")
    o.add_argument("--area")
    o.add_argument("--oneline", action="store_true", help="id, owner, title only (for sprint/rds status)")
    fr = sub.add_parser("frontier")
    fr.add_argument("--area")
    sub.add_parser("triage")
    sh = sub.add_parser("show")
    sh.add_argument("id")
    ni = sub.add_parser("next-id")
    ni.add_argument("--prefix")
    sub.add_parser("check")
    a = ap.parse_args()

    d = a.dir.resolve() if a.dir else find_dir(Path.cwd().resolve())
    if d.name != "tickets":
        d = d / "tickets"
    if not d.is_dir():
        sys.exit(f"no folder {d}")
    ts = load(d)
    by_id = {t["id"]: t for t in ts}
    local = [t for t in ts if t["file_ok"] and not t["id"].startswith("JIRA-")]
    prefixes = sorted({t["id"].split("-")[0] for t in local})
    prefix = prefixes[0] if len(prefixes) == 1 else None

    def num(t):
        try:
            return (t["id"].startswith("JIRA-"), int(t["id"].rsplit("-", 1)[1]))
        except (IndexError, ValueError):
            return (True, 10**9)

    ts.sort(key=num)

    if a.cmd == "open":
        sel = [t for t in ts if t["status"] not in CLOSED]
        if a.owner:
            sel = [t for t in sel if t["owner"].lower() == a.owner.lstrip("@").lower()]
        if a.status:
            sel = [t for t in sel if t["status"] == a.status]
        if a.area:
            sel = [t for t in sel if t["area"] == a.area]
        for t in sel:
            if a.oneline:
                print(f"{t['label']} @{t['owner'] or '-'} {t['title']}")
            else:
                print(line(t, by_id, prefix))
    elif a.cmd == "frontier":
        for t in ts:
            if t["status"] == "ready-for-agent" and not t["owner"] and not blocking(t, by_id, prefix):
                if not a.area or t["area"] == a.area:
                    print(line(t, by_id, prefix))
    elif a.cmd == "triage":
        for t in ts:
            if t["status"] in ("needs-triage", "needs-info") or t["status"] not in STATUSES:
                print(line(t, by_id, prefix))
    elif a.cmd == "show":
        tid = norm_id(a.id, prefix)
        t = by_id.get(tid)
        if not t:
            sys.exit(f"no ticket {a.id}")
        print(t["path"])
        print(t["path"].read_text(encoding="utf-8"), end="")
    elif a.cmd == "next-id":
        p = (a.prefix or prefix or "").upper()
        if not p:
            sys.exit("no tickets yet (or several prefixes): pass --prefix, e.g. --prefix RDS")
        n = max([num(t)[1] for t in local if t["id"].startswith(p + "-")] or [0]) + 1
        print(f"{p}-{n:03d}")
    elif a.cmd == "check":
        bad = 0
        seen = {}
        for t in ts:
            probs = []
            if not t["file_ok"]:
                probs.append("file name is not <PREFIX>-NNN-<slug>.md or JIRA-<KEY>-<N>-<slug>.md")
            if t["id"] in seen:
                probs.append(f"duplicate id with {seen[t['id']].name}")
            seen[t["id"]] = t["path"]
            if t["status"] not in STATUSES:
                probs.append(f"Status '{t['fields'].get('Status', '')}' not one of {', '.join(STATUSES)}")
            cat = t["fields"].get("Category")
            if cat is not None and cat.lower() not in CATEGORIES:
                probs.append("Category not bug|enhancement")
            if "Owner" not in t["fields"]:
                probs.append("no Owner: line")
            for b in t["blockers"]:
                bid = norm_id(b, prefix)
                if bid and bid not in by_id and (bid.startswith("JIRA-") or bid.split("-")[0] in prefixes):
                    probs.append(f"blocker {b} has no ticket file")
            if t["status"] == "ready-for-agent" and "## Brief" not in t["path"].read_text(encoding="utf-8"):
                probs.append("ready-for-agent without a ## Brief section")
            for p in probs:
                print(f"{t['path'].name}: {p}")
                bad += 1
        sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
