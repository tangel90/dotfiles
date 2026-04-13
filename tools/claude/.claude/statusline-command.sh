#!/usr/bin/env bash
# Claude Code status line — Rosé Pine styled
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
daily=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Rosé Pine (main) palette via ANSI 24-bit color
# thm_pine    #31748f  → directories
# thm_iris    #c4a7e7  → git branch
# thm_gold    #f6c177  → git dirty marker
# thm_foam    #9ccfd8  → model name
# thm_subtle  #999cba  → separators / labels
# thm_love    #eb6f92  → high-usage warning (>75%)
# thm_peach   #ffaa88  → mid-usage warning (>50%)
# thm_muted   #6a6e6f  → muted/dimmed values

pine=$'\033[38;2;49;116;143m'
iris=$'\033[38;2;196;167;231m'
gold=$'\033[38;2;246;193;119m'
foam=$'\033[38;2;156;207;216m'
subtle=$'\033[38;2;153;156;186m'
love=$'\033[38;2;235;111;146m'
peach=$'\033[38;2;255;170;136m'
muted=$'\033[38;2;106;110;111m'
reset=$'\033[0m'

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Git branch and dirty status
git_info=""
if git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null); then
  dirty=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null)
  if [ -n "$dirty" ]; then
    git_info="${iris} ${git_branch}${gold}*${reset}"
  else
    git_info="${iris} ${git_branch}${reset}"
  fi
fi

# Context usage — color shifts at thresholds
ctx_info=""
if [ -n "$used" ] && [ "$used" != "null" ]; then
  pct=$(printf '%.0f' "$used")
  if [ "$pct" -ge 75 ]; then
    ctx_color="$love"
  elif [ "$pct" -ge 50 ]; then
    ctx_color="$peach"
  else
    ctx_color="$muted"
  fi
  ctx_info="${subtle} | ${ctx_color}ctx:${pct}%${reset}"
fi

# 5-hour session rate limit usage
session_info=""
if [ -n "$session" ] && [ "$session" != "null" ]; then
  spct=$(printf '%.0f' "$session")
  if [ "$spct" -ge 75 ]; then
    session_color="$love"
  elif [ "$spct" -ge 50 ]; then
    session_color="$peach"
  else
    session_color="$muted"
  fi
  session_info="${subtle} | ${session_color}5h:${spct}%${reset}"
fi

# 7-day rate limit usage
daily_info=""
if [ -n "$daily" ] && [ "$daily" != "null" ]; then
  dpct=$(printf '%.0f' "$daily")
  if [ "$dpct" -ge 75 ]; then
    daily_color="$love"
  elif [ "$dpct" -ge 50 ]; then
    daily_color="$peach"
  else
    daily_color="$muted"
  fi
  daily_info="${subtle} | ${daily_color}7d:${dpct}%${reset}"
fi

# Assemble: dir  git  separator  model  ctx  session  daily
printf "${pine}%s${subtle}%s${subtle} | ${foam}%s${reset}%s%s%s\n\n" \
  "$short_cwd" \
  "$git_info" \
  "$model" \
  "$ctx_info" \
  "$daily_info" \
  "$session_info"
