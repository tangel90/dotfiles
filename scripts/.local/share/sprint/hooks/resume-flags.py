#!/usr/bin/env python3
"""SessionStart hook for sprint agents (roles/lead.json and worker.json).

After a herdr server or machine restart, herdr resumes each agent with a bare
`claude --resume <sid>`, which drops the flags sprint started it with
(--settings, --plugin-dir, --append-system-prompt-file, --add-dir, --model):
workers lose ticket access and their denies, leads their rules and hooks
(2026-11-20). This reports a resume command with those flags to herdr, as
hooks/dclaude-resume.sh does for dclaude: from herdr's own source
(herdr:claude) and after its report, hence the wait and the later seq.

The flags come from the running Claude's command line (the nearest ancestor
process whose arguments name claude), minus the session-picking ones.
"""
import json
import os
import subprocess
import sys
import time

DROP_WITH_VALUE = {"--resume", "-r", "--session-id"}
DROP = {"--continue", "-c", "--fork-session"}


def claude_args():
    pid = os.getppid()
    for _ in range(8):
        try:
            argv = open(f"/proc/{pid}/cmdline", "rb").read().split(b"\0")
            argv = [a.decode() for a in argv if a]
            stat = open(f"/proc/{pid}/stat").read()
        except OSError:
            return None
        for i, a in enumerate(argv[:3]):
            base = os.path.basename(a)
            if base == "claude" or "/claude/versions/" in a or (base == "cli.js" and "claude" in a):
                return argv[i + 1:]
        pid = int(stat.rsplit(")", 1)[1].split()[1])
        if pid <= 1:
            return None
    return None


def main():
    if os.environ.get("HERDR_ENV") != "1" or not os.environ.get("HERDR_PANE_ID") or os.environ.get("DCLAUDE") == "1":
        return
    sid = json.load(sys.stdin).get("session_id")
    args = claude_args()
    if not sid or args is None:
        return
    keep, skip = [], False
    for a in args:
        if skip:
            skip = False
        elif a in DROP_WITH_VALUE:
            skip = True
        elif a in DROP or a.split("=", 1)[0] in DROP_WITH_VALUE:
            pass
        else:
            keep.append(a)
    time.sleep(1)
    subprocess.run(["herdr", "pane", "report-agent-session", os.environ["HERDR_PANE_ID"],
                    "--source", "herdr:claude", "--agent", "claude", "--seq", str(time.time_ns()),
                    "--agent-session-id", sid, "--", "claude", *keep, "--resume", sid],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)


if __name__ == "__main__":
    main()
