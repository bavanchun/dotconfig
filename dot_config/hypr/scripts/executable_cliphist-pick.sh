#!/bin/bash
# Orchestrate: list → rofi → decode → paste
# Rofi 2.x: hiển thị phần trước \t, trả về toàn bộ dòng khi chọn
picked=$(bash ~/.config/hypr/scripts/cliphist-list.sh | rofi -dmenu -p "Clipboard")
[[ -z "$picked" ]] && exit 0

# ID nằm SAU tab cuối (hidden value của rofi)
id=$(printf '%s' "$picked" | awk -F'\t' '{print $NF}')
cliphist list | grep -P "^${id}\t" | cliphist decode | wl-copy
