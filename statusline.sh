#!/bin/bash
# Claude Code Status Line Extension
# Shows: model, current directory, and context usage

input=$(cat)

# Extract fields
MODEL=$(echo "$input" | jq -r '.model.display_name // "—"')
MODEL_ID=$(echo "$input" | jq -r '.model.id // ""')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "—"')
BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
# Total tokens in the current context = input + cache_creation + cache_read
INPUT_TOKENS=$(echo "$input" | jq -r '
  (.context_window.current_usage.input_tokens // 0) +
  (.context_window.current_usage.cache_creation_input_tokens // 0) +
  (.context_window.current_usage.cache_read_input_tokens // 0)
')
WINDOW_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Colors
RESET='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'

# Color the percentage based on usage
if [ "$PCT" -lt 50 ]; then
  PCT_COLOR=$GREEN
elif [ "$PCT" -lt 80 ]; then
  PCT_COLOR=$YELLOW
else
  PCT_COLOR=$RED
fi

# Build a small progress bar (10 chars wide)
BAR_WIDTH=10
FILLED=$(( PCT * BAR_WIDTH / 100 ))
EMPTY=$(( BAR_WIDTH - FILLED ))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

# Shorten the directory: show last 2 path components
DIR_SHORT=$(echo "$CWD" | awk -F/ '{if(NF>2) print $(NF-1)"/"$NF; else print $0}')

# Format input tokens (compact: e.g. 45.2k)
if [ "$INPUT_TOKENS" != "0" ] && [ "$INPUT_TOKENS" != "null" ]; then
  if [ "$INPUT_TOKENS" -ge 1000 ]; then
    TOKEN_FMT=$(awk "BEGIN{printf \"%.1fk\", $INPUT_TOKENS/1000}")
  else
    TOKEN_FMT="${INPUT_TOKENS}"
  fi
  TOKEN_STR=" ${DIM}(${TOKEN_FMT} tokens)${RESET}"
else
  TOKEN_STR=""
fi

# Output
# Build branch segment
if [ -n "$BRANCH" ]; then
  BRANCH_STR=" ${DIM}│${RESET} ${YELLOW}${BRANCH}${RESET}"
else
  BRANCH_STR=""
fi

echo -e "${BOLD}${CYAN}${MODEL}${RESET} ${DIM}│${RESET} ${DIR_SHORT}${BRANCH_STR} ${DIM}│${RESET} ${PCT_COLOR}${BAR} ${PCT}%${RESET}${TOKEN_STR}"
