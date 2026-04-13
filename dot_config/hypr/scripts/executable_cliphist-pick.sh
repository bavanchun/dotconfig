#!/bin/bash
# Orchestrate: list → rofi → decode → paste
picked=$(bash ~/.config/hypr/scripts/cliphist-list.sh | rofi -dmenu -p "Clipboard")
[[ -z "$picked" ]] && exit 0
id=$(echo "$picked" | cut -f1)
cliphist list | grep -P "^${id}\t" | cliphist decode | wl-copy
