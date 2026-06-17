#!/usr/bin/env bash
# Claude Code status line.
# Reads the status JSON from stdin and prints a single coloured line:
#   <branch>  <model>  <effort>  ctx <ctx%>  5h <5h%>  7d <7d%>

input=$(cat)

# --- ANSI colours -----------------------------------------------------------
RESET=$'\033[0m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'

# Pick a colour for a usage percentage: green < 50, yellow 50-79, red >= 80.
pct_colour() {
    local pct="${1%.*}"   # strip any decimals
    [ -z "$pct" ] && { printf '%s' "$DIM"; return; }
    if [ "$pct" -ge 80 ]; then
        printf '%s' "$RED"
    elif [ "$pct" -ge 50 ]; then
        printf '%s' "$YELLOW"
    else
        printf '%s' "$GREEN"
    fi
}

# --- Fields from the JSON payload -------------------------------------------
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')
ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five_h=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- Git branch (not in the JSON, so shell out) -----------------------------
branch=""
if [ -n "$cwd" ]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [ -n "$branch" ] && [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
        branch="${branch}*"
    fi
fi

# --- Assemble the segments --------------------------------------------------
segments=()

[ -n "$branch" ] && segments+=("${MAGENTA} ${branch}${RESET}")
[ -n "$model" ]  && segments+=("${CYAN}${model}${RESET}")
[ -n "$effort" ] && segments+=("${DIM}${effort}${RESET}")

if [ -n "$ctx" ]; then
    segments+=("$(pct_colour "$ctx")ctx ${ctx%.*}%${RESET}")
fi

# rate_limits only exist for Claude.ai Pro/Max subscribers; skip silently otherwise.
if [ -n "$five_h" ]; then
    segments+=("$(pct_colour "$five_h")5h ${five_h%.*}%${RESET}")
fi
if [ -n "$seven_d" ]; then
    segments+=("$(pct_colour "$seven_d")7d ${seven_d%.*}%${RESET}")
fi

# Join with a dim divider between segments.
sep="  ${DIM}│${RESET}  "
line=""
for seg in "${segments[@]}"; do
    if [ -z "$line" ]; then
        line="$seg"
    else
        line="${line}${sep}${seg}"
    fi
done

printf '%s' "$line"
