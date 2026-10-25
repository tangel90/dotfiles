#!/bin/sh
# SessionStart hook, dclaude only: tell herdr to resume this pane with
# `dclaude --resume <id>` after a server restart.
#
# herdr's own hook (herdr-agent-state.sh) reports just the session id, and
# herdr then resumes with host `claude --resume <id>`, which can't find a
# session kept in the container's state. A report with a resume command
# overrides that; it must come from the source holding the pane, herdr's
# herdr:claude, and after its report, hence the short wait and the later seq.

[ "${DCLAUDE:-}" = 1 ] && [ "${HERDR_ENV:-}" = 1 ] && [ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v herdr >/dev/null && command -v python3 >/dev/null || exit 0

sid=$(python3 -c 'import json, sys; print(json.load(sys.stdin).get("session_id") or "")' 2>/dev/null) || exit 0
[ -n "$sid" ] || exit 0

sleep 1
herdr pane report-agent-session "$HERDR_PANE_ID" \
    --source herdr:claude --agent claude \
    --seq "$(date +%s%N)" --agent-session-id "$sid" \
    -- dclaude --resume "$sid" >/dev/null 2>&1 || true
