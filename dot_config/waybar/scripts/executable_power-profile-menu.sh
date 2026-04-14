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

# Set profile và xác định NEW cùng lúc
case "$CHOICE" in
    *"Performance"*) powerprofilesctl set performance ; NEW=performance ;;
    *"Balanced"*)    powerprofilesctl set balanced    ; NEW=balanced ;;
    *"Power Saver"*) powerprofilesctl set power-saver ; NEW=power-saver ;;
esac

# Xử lý brightness khi chuyển power-saver
# Dùng state file riêng (không dùng brightnessctl -s/-r vì hypridle đã dùng slot đó)
STATE_FILE="$HOME/.cache/power-profile-brightness"

get_brightness_pct() {
    brightnessctl -m | awk -F, '{print $4}' | tr -d '%'
}

if [ "$CURRENT" != "power-saver" ] && [ "$NEW" = "power-saver" ]; then
    # Vào power-saver: lưu brightness hiện tại rồi dim xuống 50%
    get_brightness_pct > "$STATE_FILE"
    brightnessctl set 50%
elif [ "$CURRENT" = "power-saver" ] && [ "$NEW" != "power-saver" ]; then
    # Thoát power-saver: khôi phục brightness cũ nếu có
    if [ -s "$STATE_FILE" ]; then
        brightnessctl set "$(cat "$STATE_FILE")%"
        rm -f "$STATE_FILE"
    fi
fi
