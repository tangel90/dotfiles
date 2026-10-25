#!/bin/sh
# UserPromptSubmit hook: hand this session what the user ran in a pane coupled
# to it with hcouple (scripts/.local/bin/hcouple), then clear the log. Plain
# stdout from this hook is added to the prompt as context.

dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hcouple
sid=$(sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' | head -n1)
log=$dir/$sid.log
[ -n "$sid" ] && [ -s "$log" ] || exit 0

# Take the log over first, so commands finishing meanwhile start a new one.
mv "$log" "$log.reading" 2>/dev/null || exit 0
echo "Commands the user ran in their coupled shell pane since your last turn (hcouple):"
echo
cat "$log.reading"
rm -f "$log.reading"
