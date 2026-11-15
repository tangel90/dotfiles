#!/bin/sh
# SessionStart hook: give a herdr agent its name back after a restart.
#
# ha names an agent twice: the herdr agent name (what `herdr agent prompt`,
# ht's ctrl-s and the sidebar use) and the pane label. Claude Code's /restart
# and updates restart the process in the same pane; herdr then registers a new
# agent session without the name, while the pane keeps its label. This copies
# the label back as the agent name, once herdr has picked the session up.

[ "${HERDR_ENV:-}" = 1 ] && [ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v herdr >/dev/null && command -v jq >/dev/null || exit 0

label=$(herdr pane get "$HERDR_PANE_ID" 2>/dev/null | jq -r '.result.pane.label // empty')
# Only labels that are valid agent names (ha's rule): lowercase, digits, dashes.
printf '%s' "$label" | grep -Eq '^[a-z0-9][a-z0-9-]*$' || exit 0

# herdr detects the new session a moment after start; wait up to ~15 s.
i=0
while [ $i -lt 15 ]; do
    name=$(herdr agent list 2>/dev/null | jq -r --arg p "$HERDR_PANE_ID" \
        '[.result.agents[] | select(.pane_id == $p)][0] | if . == null then "MISSING" else (.name // "") end')
    case $name in
        MISSING) ;;                      # not detected yet
        "") herdr agent rename "$HERDR_PANE_ID" "$label" >/dev/null 2>&1; exit 0 ;;
        *) exit 0 ;;                     # already named
    esac
    sleep 1; i=$((i + 1))
done
exit 0
