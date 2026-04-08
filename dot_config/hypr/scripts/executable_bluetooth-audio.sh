#!/bin/bash
# Tự động switch output sang bluetooth khi connect

pactl subscribe | grep --line-buffered "new.*sink" | while read -r line; do
    sleep 2  # Chờ audio profile load xong
    BT_SINK=$(pactl list sinks short | grep bluez | head -1 | awk '{print $2}')
    if [[ -n "$BT_SINK" ]]; then
        pactl set-default-sink "$BT_SINK"
    fi
done
