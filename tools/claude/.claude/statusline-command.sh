#!/usr/bin/env bash
# Claude Code status line — rose-pine flavoured

input=$(cat)

# Rose Pine main palette (ANSI 24-bit)
pine="\033[38;2;49;116;143m"      # #31748f
foam="\033[38;2;156;207;216m"     # #9ccfd8
iris="\033[38;2;196;167;231m"     # #c4a7e7
gold="\033[38;2;246;193;119m"     # #f6c177
rose="\033[38;2;235;188;186m"     # #ebbcba
love="\033[38;2;235;111;146m"     # #eb6f92
subtle="\033[38;2;153;156;186m"   # #999cba
text="\033[38;2;224;222;244m"     # #e0def4
muted="\033[38;2;106;110;111m"    # #6a6e6f
reset="\033[0m"

# ── directory ────────────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
# shorten: replace $HOME with ~, then keep last 2 components
cwd="${cwd/#$HOME/~}"
short_pwd=$(echo "$cwd" | awk -F'/' '{
    n=NF
    if (n<=2) { print $0 }
    else { print $(n-1)"/"$n }
}')

# ── git ───────────────────────────────────────────────────────────────────────
git_cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
git_info=""
if [ -n "$git_cwd" ] && git -C "$git_cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$git_cwd" symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$git_cwd" rev-parse --short HEAD 2>/dev/null | sed 's/^/@/')
    dirty=""
    git -C "$git_cwd" diff --quiet 2>/dev/null && git -C "$git_cwd" diff --cached --quiet 2>/dev/null \
        || dirty="*"
    # untracked
    [ -z "$dirty" ] && [ -n "$(git -C "$git_cwd" ls-files --others --exclude-standard 2>/dev/null | head -1)" ] \
        && dirty="*"
    ahead=0; behind=0
    ab=$(git -C "$git_cwd" rev-list --count --left-right '@{upstream}...HEAD' 2>/dev/null) \
        && behind=${ab%%	*} ahead=${ab##*	}
    arrows=""
    [ "$behind" -gt 0 ] && arrows="${arrows}⇣"
    [ "$ahead"  -gt 0 ] && arrows="${arrows}⇡"
    if [ -n "$dirty" ]; then
        git_info="$(printf "${subtle}${branch}${gold}${dirty}${reset}")"
    else
        git_info="$(printf "${subtle}${branch}${reset}")"
    fi
    [ -n "$arrows" ] && git_info="${git_info}$(printf "${foam}:${arrows}${reset}")"
fi

# ── model ─────────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // ""')

# ── context bar ───────────────────────────────────────────────────────────────
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
make_bar() {
    local pct="$1"
    local width=10
    local pct_int=$(printf "%.0f" "$pct" 2>/dev/null || echo 0)
    local filled=$(( pct_int * width / 100 ))
    [ "$filled" -gt "$width" ] && filled=$width
    local empty=$(( width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    echo "$bar"
}

# ── 5-hour session limit ──────────────────────────────────────────────────────
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# derive elapsed time: 5h window = 18000s; elapsed = 18000 - seconds_until_reset
five_elapsed=""
if [ -n "$five_resets" ]; then
    now=$(date +%s)
    seconds_until=$(( five_resets - now ))
    [ "$seconds_until" -lt 0 ] && seconds_until=0
    elapsed_s=$(( 18000 - seconds_until ))
    [ "$elapsed_s" -lt 0 ] && elapsed_s=0
    elapsed_h=$(( elapsed_s / 3600 ))
    elapsed_m=$(( (elapsed_s % 3600) / 60 ))
    five_elapsed=$(printf "%dh%02dm" "$elapsed_h" "$elapsed_m")
fi

# ── 7-day weekly limit ────────────────────────────────────────────────────────
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# derive elapsed days: 7d window = 604800s; elapsed = 604800 - seconds_until_reset
week_elapsed_days=""
if [ -n "$week_resets" ]; then
    now=$(date +%s)
    seconds_until=$(( week_resets - now ))
    [ "$seconds_until" -lt 0 ] && seconds_until=0
    elapsed_s=$(( 604800 - seconds_until ))
    [ "$elapsed_s" -lt 0 ] && elapsed_s=0
    week_elapsed_days=$(( elapsed_s / 86400 ))
fi

# ── pick bar color based on percentage ───────────────────────────────────────
bar_color() {
    local pct="$1"
    local int_pct=$(printf "%.0f" "$pct" 2>/dev/null || echo 0)
    if   [ "$int_pct" -ge 85 ]; then echo "$love"
    elif [ "$int_pct" -ge 60 ]; then echo "$gold"
    else                              echo "$pine"
    fi
}

# ── assemble ──────────────────────────────────────────────────────────────────
parts=()

# directory
parts+=("$(printf "${pine}${short_pwd}${reset}")")

# git branch + status
if [ -n "$git_info" ]; then
    parts+=("$git_info")
fi

# model (line 1 terminus — no embedded newline; newline inserted at join time)
if [ -n "$model" ]; then
    parts+=("$(printf "${muted}${model}${reset}")")
fi

# line-2 parts
line2=()

# context
if [ -n "$ctx_used" ]; then
    bar=$(make_bar "$ctx_used")
    color=$(bar_color "$ctx_used")
    pct_int=$(printf "%.0f" "$ctx_used")
    line2+=("$(printf "${subtle}ctx ${color}${bar}${subtle} ${pct_int}%%${reset}")")
fi

# 5-hour session limit + elapsed timer
if [ -n "$five_pct" ]; then
    bar=$(make_bar "$five_pct")
    color=$(bar_color "$five_pct")
    pct_int=$(printf "%.0f" "$five_pct")
    if [ -n "$five_elapsed" ]; then
        line2+=("$(printf "${subtle}5h ${color}${bar}${subtle} ${pct_int}%% ${muted}(${five_elapsed})${reset}")")
    else
        line2+=("$(printf "${subtle}5h ${color}${bar}${subtle} ${pct_int}%%${reset}")")
    fi
fi

# weekly limit + elapsed days
if [ -n "$week_pct" ]; then
    bar=$(make_bar "$week_pct")
    color=$(bar_color "$week_pct")
    pct_int=$(printf "%.0f" "$week_pct")
    if [ -n "$week_elapsed_days" ]; then
        line2+=("$(printf "${subtle}7d ${color}${bar}${subtle} ${pct_int}%% ${muted}(day ${week_elapsed_days})${reset}")")
    else
        line2+=("$(printf "${subtle}7d ${color}${bar}${subtle} ${pct_int}%%${reset}")")
    fi
fi

# join helper: joins an array with sep into a variable
join_parts() {
    local _sep="$1"; shift
    local _result=""
    for _part in "$@"; do
        if [ -z "$_result" ]; then
            _result="$_part"
        else
            _result="${_result}${_sep}${_part}"
        fi
    done
    printf '%s' "$_result"
}

sep="$(printf "${muted} | ${reset}")"
line1=$(join_parts "$sep" "${parts[@]}")
line2_str=$(join_parts "$sep" "${line2[@]}")

if [ -n "$line2_str" ]; then
    printf "\n%b\n%b\n\n" "$line1" "$line2_str"
else
    printf "\n%b\n\n" "$line1"
fi
