#!/bin/bash

LOCK="󰌾  Lock"
SLEEP="󰒲  Sleep"
RESTART="󰑓  Restart"
SHUTDOWN="󰐥  Shutdown"

CHOICE=$(printf "$LOCK\n$SLEEP\n$RESTART\n$SHUTDOWN" | fuzzel --dmenu --prompt "Power: " --width 16 --lines 4)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *"Lock"*)     hyprlock ;;
    *"Sleep"*)    systemctl suspend ;;
    *"Restart"*)  systemctl reboot ;;
    *"Shutdown"*) systemctl poweroff ;;
esac
