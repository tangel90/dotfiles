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
blue="\033[94m"                   # terminal palette bright blue, as Claude's dark-ansi theme uses
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

# ── context ───────────────────────────────────────────────────────────────────
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ── 5-hour session limit ──────────────────────────────────────────────────────
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# time left until the 5h window resets
five_left=""
if [ -n "$five_resets" ]; then
    now=$(date +%s)
    seconds_until=$(( five_resets - now ))
    [ "$seconds_until" -lt 0 ] && seconds_until=0
    five_left=$(printf "↻%dh%02dm" "$(( seconds_until / 3600 ))" "$(( (seconds_until % 3600) / 60 ))")
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

# Cache the limits for hlimits (herdr's tab bar), which has no other source.
limits=$(echo "$input" | jq -c '.rate_limits // empty')
if [ -n "$limits" ]; then
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/claude-limits.json"
    mkdir -p "${cache%/*}"
    echo "$limits" >"$cache.$$" && mv -f "$cache.$$" "$cache"
fi

# Report context use and model to herdr's agent sidebar ($ctx and $model in
# ui.sidebar.agents), only when they change: the status line refreshes far
# more often than that.
if [ -n "$ctx_used$model" ] && [ "${HERDR_ENV:-}" = 1 ] && [ -n "${HERDR_PANE_ID:-}" ] && command -v herdr >/dev/null; then
    # Zero-padded ("07%"), so herdr's text rules can band by leading digits.
    ctx_val=${ctx_used:+$(printf "%02.0f" "$ctx_used")%}
    meta_last="${XDG_RUNTIME_DIR:-/tmp}/claude-ctx-${HERDR_PANE_ID//[^A-Za-z0-9]/_}"
    if [ "$(cat "$meta_last" 2>/dev/null)" != "$ctx_val|$model" ]; then
        herdr pane report-metadata "$HERDR_PANE_ID" --source claude-statusline \
            --token "ctx=$ctx_val" --token "model=$model" >/dev/null 2>&1 \
            && echo "$ctx_val|$model" >"$meta_last"
    fi
fi

# ── prompt cache ──────────────────────────────────────────────────────────────
# The API has no TTL readout, so estimate it: each request refreshes the cache
# for its TTL (1h normally, 5m in usage overage), as recorded in the
# transcript's last request. Shown as the clock time it goes cold; after that
# the next prompt re-reads the whole context uncached. The status line only
# redraws on activity, so an idle session keeps showing the deadline.
cache_part=""
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -f "$transcript" ]; then
    last=$(tail -n 300 "$transcript" | jq -r 'select(.type == "assistant" and .message.usage != null)
        | "\(.timestamp) \(.message.usage.cache_creation.ephemeral_5m_input_tokens // 0) \(.message.usage.cache_creation.ephemeral_1h_input_tokens // 0)"' 2>/dev/null | tail -n 1)
    if [ -n "$last" ]; then
        read -r ts c5 c1 <<<"$last"
        ttl=3600
        [ "$c5" -gt 0 ] && [ "$c1" -eq 0 ] && ttl=300
        if t=$(date -d "$ts" +%s 2>/dev/null); then
            expires=$(( t + ttl ))
            if [ "$expires" -gt "$(date +%s)" ]; then
                cache_part=$(printf "${subtle}cache ${foam}%s${reset}" "$(date -d "@$expires" +%H:%M)")
                [ "$ttl" = 300 ] && cache_part="${cache_part}$(printf "${muted} (5m)${reset}")"
            else
                cache_part=$(printf "${subtle}cache ${love}cold${reset}")
            fi
        fi
    fi
fi

# Inside herdr the tab bar (hlimits) and the agent sidebar ($ctx) show the
# rest, so print only the model and the cache and keep the reporting above.
if [ "${HERDR_ENV:-}" = 1 ]; then
    herdr_line=""
    [ -n "$model" ] && herdr_line=$(printf "${muted}%s${reset}" "$model")
    if [ -n "$cache_part" ]; then
        herdr_line="${herdr_line:+$herdr_line$(printf "${muted} | ${reset}")}$cache_part"
    fi
    [ -n "$herdr_line" ] && printf "%b\n" "$herdr_line"
    exit 0
fi

# ── pick color based on percentage ───────────────────────────────────────────
bar_color() {
    local pct="$1"
    local int_pct=$(printf "%.0f" "$pct" 2>/dev/null || echo 0)
    if   [ "$int_pct" -ge 85 ]; then echo "$love"
    elif [ "$int_pct" -ge 60 ]; then echo "$gold"
    else                              echo "$blue"
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
    color=$(bar_color "$ctx_used")
    pct_int=$(printf "%.0f" "$ctx_used")
    line2+=("$(printf "${subtle}ctx ${color}${pct_int}%%${reset}")")
fi

# 5-hour session limit + elapsed timer
if [ -n "$five_pct" ]; then
    color=$(bar_color "$five_pct")
    pct_int=$(printf "%.0f" "$five_pct")
    if [ -n "$five_left" ]; then
        line2+=("$(printf "${subtle}5h ${color}${pct_int}%% ${muted}(${five_left})${reset}")")
    else
        line2+=("$(printf "${subtle}5h ${color}${pct_int}%%${reset}")")
    fi
fi

# weekly limit + elapsed days
if [ -n "$week_pct" ]; then
    color=$(bar_color "$week_pct")
    pct_int=$(printf "%.0f" "$week_pct")
    if [ -n "$week_elapsed_days" ]; then
        line2+=("$(printf "${subtle}7d ${color}${pct_int}%% ${muted}(day ${week_elapsed_days})${reset}")")
    else
        line2+=("$(printf "${subtle}7d ${color}${pct_int}%%${reset}")")
    fi
fi

[ -n "$cache_part" ] && line2+=("$cache_part")

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
