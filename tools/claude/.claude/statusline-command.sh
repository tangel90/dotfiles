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

# ── 7-day weekly limit ────────────────────────────────────────────────────────
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

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

# model
if [ -n "$model" ]; then
    parts+=("$(printf "${muted}${model}${reset}")")
fi

# context
if [ -n "$ctx_used" ]; then
    bar=$(make_bar "$ctx_used")
    color=$(bar_color "$ctx_used")
    pct_int=$(printf "%.0f" "$ctx_used")
    parts+=("$(printf "${subtle}ctx ${color}${bar}${subtle} ${pct_int}%%${reset}")")
fi

# 5-hour session limit
if [ -n "$five_pct" ]; then
    bar=$(make_bar "$five_pct")
    color=$(bar_color "$five_pct")
    pct_int=$(printf "%.0f" "$five_pct")
    parts+=("$(printf "${subtle}5h ${color}${bar}${subtle} ${pct_int}%%${reset}")")
fi

# weekly limit
if [ -n "$week_pct" ]; then
    bar=$(make_bar "$week_pct")
    color=$(bar_color "$week_pct")
    pct_int=$(printf "%.0f" "$week_pct")
    parts+=("$(printf "${subtle}7d ${color}${bar}${subtle} ${pct_int}%%${reset}")")
fi

# join with rose-pine field separator style
sep="$(printf "${muted} | ${reset}")"
result=""
for part in "${parts[@]}"; do
    if [ -z "$result" ]; then
        result="$part"
    else
        result="${result}${sep}${part}"
    fi
done

printf "\n%b\n\n" "$result"
