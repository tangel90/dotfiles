#!/usr/bin/env python3
"""Context hook for sprint leads (wired in roles/lead.json, leads only).

lead.md asks the lead to hand off at about 50% context, but the lead can't
see its context. This hook can:

  prompt      UserPromptSubmit: at 50% or more, add a reminder to the prompt.
  stop        Stop: same threshold; blocks the stop once so the lead does the
              handoff before going idle (worker replies don't fire
              UserPromptSubmit, so a lead can grow past 50% between prompts).
  precompact  PreCompact (auto only): steers the compaction summary so it
              keeps what the handoff needs and opens with the order to
              write it. Not a block, see main().

One reminder per 10-point step (50, 60, 70 ...), shared by prompt and stop.
Context comes from the status line's cache (~/.cache/claude-ctx/<session>,
"<percent> <window size>"), else from the transcript's last usage.
"""
import json
import os
import sys
from pathlib import Path

THRESHOLD = int(os.environ.get("SPRINT_LEAD_HANDOFF_PCT", "50"))
CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "claude-ctx"
STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "sprint" / "ctx-remind"
HANDOFF = ("do the handoff now (lead.md, 'Your context'): ingest what you know into docs/wiki/, "
           "update docs/handoff.md, then ask the human for a fresh session.")


def from_transcript(path):
    """Percent from the last assistant usage; the window size isn't recorded."""
    try:
        lines = Path(path).read_text().splitlines()[-400:]
    except OSError:
        return None
    for line in reversed(lines):
        try:
            usage = json.loads(line).get("message", {}).get("usage")
        except (ValueError, AttributeError):
            continue
        if usage:
            used = sum(usage.get(k) or 0 for k in ("input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"))
            window = 200_000 if used < 200_000 else 1_000_000
            return 100 * used / window
    return None


def context_pct(data):
    try:
        return float((CACHE / data["session_id"]).read_text().split()[0])
    except (OSError, ValueError, IndexError, KeyError):
        return from_transcript(data.get("transcript_path", ""))


def state(sid):
    try:
        return json.loads((STATE / sid).read_text())
    except (OSError, ValueError):
        return {}


def save(sid, st):
    STATE.mkdir(parents=True, exist_ok=True)
    (STATE / sid).write_text(json.dumps(st))


def new_step(data):
    """The 10-point step reached, if not reminded yet; else None."""
    pct = context_pct(data)
    if pct is None or pct < THRESHOLD:
        return None, pct
    step = THRESHOLD + int((pct - THRESHOLD) // 10) * 10
    st = state(data["session_id"])
    if st.get("step", 0) >= step:
        return None, pct
    st["step"] = step
    save(data["session_id"], st)
    return step, pct


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "prompt"
    data = json.load(sys.stdin)
    sid = data.get("session_id")
    if not sid:
        return
    if mode == "prompt":
        step, pct = new_step(data)
        if step:
            print(json.dumps({"hookSpecificOutput": {"hookEventName": "UserPromptSubmit",
                              "additionalContext": f"Context at {pct:.0f}%: {HANDOFF}"}}))
    elif mode == "stop":
        if data.get("stop_hook_active"):
            return
        step, pct = new_step(data)
        if step:
            print(json.dumps({"decision": "block", "reason": f"Context at {pct:.0f}%: {HANDOFF}"}))
    elif mode == "precompact":
        # Not blocked: a blocked auto-compact that a context-limit error
        # triggered fails the request, and the lead never sees why. Instead
        # the summary keeps what the handoff needs and opens with the order.
        if data.get("trigger") == "auto":
            print("This lead missed its context handoff. Begin the summary with this line, verbatim: "
                  "'FIRST, before anything else: auto-compaction ran before the handoff; write docs/handoff.md "
                  "and ingest into docs/wiki/ from this summary now, then tell the human.' Keep every open "
                  "ticket and its state, decisions the human made with their dates, worker assignments, "
                  "open threads and pitfalls in full.")


if __name__ == "__main__":
    main()
