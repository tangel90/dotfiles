#!/bin/sh
# last-tab: on tab.focused, remember each workspace's current and previous
# tab (tab ids are "<workspace>:<tab>"); the focus action jumps back to the
# previous one, whose own tab.focused event then swaps the pair.
state=${HERDR_PLUGIN_STATE_DIR:?}
herdr=${HERDR_BIN_PATH:-herdr}

if [ "${HERDR_PLUGIN_EVENT:-}" = tab.focused ]; then
    tab=$(printf '%s' "${HERDR_PLUGIN_EVENT_JSON:-}" | grep -o '"tab_id" *: *"[^"]*"' | head -n 1 | sed 's/.*"\([^"]*\)"$/\1/')
    [ -n "$tab" ] || exit 0
    ws=${tab%%:*}
    cur=$(cat "$state/$ws.cur" 2>/dev/null)
    [ "$cur" = "$tab" ] && exit 0
    [ -n "$cur" ] && printf '%s\n' "$cur" >"$state/$ws.prev"
    printf '%s\n' "$tab" >"$state/$ws.cur"
    exit 0
fi

ws=${HERDR_TAB_ID:+${HERDR_TAB_ID%%:*}}
ws=${ws:-${HERDR_WORKSPACE_ID:-}}
prev=$(cat "$state/$ws.prev" 2>/dev/null)
[ -n "$prev" ] && exec "$herdr" tab focus "$prev"
