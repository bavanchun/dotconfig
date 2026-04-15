#!/bin/bash

NETWORK="󰖩  Network"
BLUETOOTH="󰂯  Bluetooth"
POWER_PROFILE="󰓅  Power Profile"
INPUT="󰌌  Input Method"
NIGHT_LIGHT="󰖔  Night Light"
SYSTEM="󰻠  System Monitor"

CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n" \
    "$NETWORK" \
    "$BLUETOOTH" \
    "$POWER_PROFILE" \
    "$INPUT" \
    "$NIGHT_LIGHT" \
    "$SYSTEM" | fuzzel --dmenu --prompt "Control: " --width 24 --lines 6)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *"Network"*) nm-connection-editor ;;
    *"Bluetooth"*) blueman-manager ;;
    *"Power Profile"*) bash "$HOME/.config/waybar/scripts/power-profile-menu.sh" ;;
    *"Input Method"*) fcitx5-remote -t ;;
    *"Night Light"*) bash "$HOME/.config/hypr/scripts/toggle-hyprsunset.sh" ;;
    *"System Monitor"*) sh -c 'resources || missioncenter || gnome-system-monitor || plasma-systemmonitor || true' ;;
esac
