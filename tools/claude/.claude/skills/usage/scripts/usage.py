#!/usr/bin/env python3
"""Token usage per Claude project folder, from the session transcripts.

usage.py [PATH] [--days N] [--all]

PATH (default: the current directory) selects every transcript folder whose
working directory is PATH or below it, worktrees and sandboxes included; --all
takes every folder. Reads ~/.claude/projects and dclaude's state. Prints, per
folder: sessions, model calls, output, cache writes and reads, the average
context per call, and each folder's share of the cost (weighted with the
models' relative list prices; use ccusage for dollar amounts).
"""
import argparse, collections, glob, json, os, re, time

ROOTS = [os.path.expanduser("~/.claude/projects"),
         os.path.expanduser("~/.local/share/dclaude/claude/projects")]
# relative weights per million tokens: input, output, cache write, cache read
WEIGHT = {"opus": (5, 25, 6.25, 0.5), "sonnet": (3, 15, 3.75, 0.3), "haiku": (1, 5, 1.25, 0.1)}


def mangle(path):
    return re.sub(r"[^A-Za-z0-9]", "-", path)


def family(model):
    for f in WEIGHT:
        if f in model:
            return f
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path", nargs="?", default=os.getcwd())
    ap.add_argument("--days", type=float, default=None)
    ap.add_argument("--all", action="store_true")
    a = ap.parse_args()
    prefix = mangle(os.path.abspath(a.path))
    since = time.time() - a.days * 86400 if a.days else 0
    rows = collections.defaultdict(lambda: collections.Counter())
    models = collections.defaultdict(collections.Counter)
    for root in ROOTS:
        if not os.path.isdir(root):
            continue
        for d in os.listdir(root):
            if not a.all and not (d == prefix or d.startswith(prefix + "-")):
                continue
            key = ("dclaude:" if "dclaude" in root else "") + d
            for f in glob.glob(f"{root}/{d}/**/*.jsonl", recursive=True):
                if os.path.getmtime(f) < since:
                    continue
                seen, used = set(), False
                for line in open(f, errors="ignore"):
                    try:
                        m = json.loads(line)
                    except ValueError:
                        continue
                    msg = m.get("message") or {}
                    u = msg.get("usage")
                    if not u or msg.get("id") in seen:
                        continue
                    seen.add(msg.get("id"))
                    used = True
                    c = rows[key]
                    i, o = u.get("input_tokens", 0), u.get("output_tokens", 0)
                    cw, cr = u.get("cache_creation_input_tokens", 0), u.get("cache_read_input_tokens", 0)
                    c["calls"] += 1; c["in"] += i; c["out"] += o; c["cw"] += cw; c["cr"] += cr
                    fam = family(msg.get("model", ""))
                    if fam:
                        w = WEIGHT[fam]
                        cost = (i * w[0] + o * w[1] + cw * w[2] + cr * w[3]) / 1e6
                        c["cost"] += cost
                        models[fam]["cost"] += cost
                        models[fam]["calls"] += 1
                if used:
                    rows[key]["sessions"] += 1
    if not rows:
        print(f"no transcripts for {a.path}")
        return
    total = sum(c["cost"] for c in rows.values()) or 1
    print(f"{'folder':60} {'sess':>4} {'calls':>5} {'out k':>6} {'cwr k':>6} {'crd k':>7} {'ctx/call k':>10} {'share':>6}")
    for d, c in sorted(rows.items(), key=lambda x: -x[1]["cost"]):
        ctx = (c["cr"] + c["cw"] + c["in"]) / max(c["calls"], 1) / 1e3
        print(f"{d[-60:]:60} {c['sessions']:4} {c['calls']:5} {c['out']/1e3:6.0f} {c['cw']/1e3:6.0f} "
              f"{c['cr']/1e3:7.0f} {ctx:10.0f} {100*c['cost']/total:5.0f}%")
    print("models: " + ", ".join(f"{f} {100*m['cost']/total:.0f}% ({m['calls']} calls)" for f, m in
                                 sorted(models.items(), key=lambda x: -x[1]["cost"])))


if __name__ == "__main__":
    main()
