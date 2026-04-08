#!/bin/bash
if pgrep -x hyprsunset > /dev/null; then
    pkill hyprsunset
    notify-send "hyprsunset" "Blue light filter OFF" --icon=display
else
    hyprsunset -t 4500 &
    notify-send "hyprsunset" "Blue light filter ON (4500K)" --icon=display
fi
