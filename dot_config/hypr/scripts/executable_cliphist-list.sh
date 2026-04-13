#!/bin/bash
# List clipboard history kèm timestamp (hybrid: relative < 24h, absolute >= 24h)
ts_log="$HOME/.cache/cliphist/timestamps.log"
now=$(date +%s)

declare -A ts
if [[ -f "$ts_log" ]]; then
    while IFS='|' read -r id t; do ts[$id]=$t; done < "$ts_log"
fi

format_time() {
    local t=$1
    local diff=$(( now - t ))
    if   (( diff < 60 ));    then echo "vừa xong"
    elif (( diff < 3600 ));  then echo "$((diff/60)) phút trước"
    elif (( diff < 86400 )); then echo "$((diff/3600)) giờ trước"
    else date -d "@$t" "+%Y-%m-%d %H:%M"
    fi
}

cliphist list | while IFS=$'\t' read -r id content; do
    t=${ts[$id]:-}
    if [[ -n "$t" ]]; then
        label=$(format_time "$t")
    else
        label="—"
    fi
    printf '%s\t[%-20s] %s\n' "$id" "$label" "$content"
done
