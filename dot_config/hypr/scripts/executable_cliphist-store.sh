#!/bin/bash
# Wrapper: cliphist store + ghi timestamp vào log
ts_log="$HOME/.cache/cliphist/timestamps.log"
mkdir -p "$(dirname "$ts_log")"

content=$(cat)
printf '%s' "$content" | cliphist store

new_id=$(cliphist list | head -n1 | cut -f1)
[[ -n "$new_id" ]] && echo "${new_id}|$(date +%s)" >> "$ts_log"
