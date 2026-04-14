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

# Set profile và xác định NEW cùng lúc, capture exit code trước khi assignment ghi đè $?
case "$CHOICE" in
    *"Performance"*) powerprofilesctl set performance; EC=$?; NEW=performance ;;
    *"Balanced"*)    powerprofilesctl set balanced;    EC=$?; NEW=balanced ;;
    *"Power Saver"*) powerprofilesctl set power-saver; EC=$?; NEW=power-saver ;;
esac

# Dừng nếu powerprofilesctl thất bại
[ "${EC:-1}" -ne 0 ] && exit 1

# Xử lý brightness khi chuyển power-saver
# Dùng state file riêng (không dùng brightnessctl -s/-r vì hypridle đã dùng slot đó)
STATE_FILE="$HOME/.cache/power-profile-brightness"

get_brightness_pct() {
    brightnessctl -m | awk -F, '{print $4}' | tr -d '%'
}

if [ "$CURRENT" != "power-saver" ] && [ "$NEW" = "power-saver" ]; then
    BRT=$(get_brightness_pct)
    # Chỉ dim nếu đang sáng hơn 50%, tránh tăng brightness khi đang dim sẵn
    if [ "$BRT" -gt 50 ]; then
        echo "$BRT" > "$STATE_FILE"
        brightnessctl set 50%
        notify-send -i battery-low "Power Saver" "Brightness dimmed to 50%" -t 3000
    fi
elif [ "$CURRENT" = "power-saver" ] && [ "$NEW" != "power-saver" ]; then
    # Thoát power-saver: khôi phục brightness cũ nếu có
    if [ -s "$STATE_FILE" ]; then
        SAVED=$(cat "$STATE_FILE")
        brightnessctl set "${SAVED}%"
        rm -f "$STATE_FILE"
        notify-send -i battery "Power Profile" "Brightness restored to ${SAVED}%" -t 3000
    fi
fi
