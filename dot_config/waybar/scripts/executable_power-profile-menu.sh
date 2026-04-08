#!/bin/bash

CURRENT=$(powerprofilesctl get)

PERF="󰓅  Performance"
BAL="󰾅  Balanced"
SAVE="󰌪  Power Saver"

# Đánh dấu profile đang active
case "$CURRENT" in
    performance) OPTIONS="$PERF ✓\n$BAL\n$SAVE" ;;
    balanced)    OPTIONS="$PERF\n$BAL ✓\n$SAVE" ;;
    power-saver) OPTIONS="$PERF\n$BAL\n$SAVE ✓" ;;
esac

CHOICE=$(echo -e "$OPTIONS" | fuzzel --dmenu --prompt "Power Profile: " --width 20 --lines 3)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *"Performance"*) powerprofilesctl set performance ;;
    *"Balanced"*)    powerprofilesctl set balanced ;;
    *"Power Saver"*) powerprofilesctl set power-saver ;;
esac
