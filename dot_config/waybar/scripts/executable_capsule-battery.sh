#!/bin/bash

set -euo pipefail

mode="${1:-icon}"
battery_dir="/sys/class/power_supply/BAT0"
ac_online_file="/sys/class/power_supply/AC/online"

if [[ ! -d "$battery_dir" ]]; then
    if [[ "$mode" == "text" ]]; then
        jq -cn --arg text "" '{text:$text}'
    else
        jq -cn --arg text "󰂑" '{text:$text}'
    fi
    exit 0
fi

capacity="$(cat "$battery_dir/capacity" 2>/dev/null || printf '0')"
status="$(cat "$battery_dir/status" 2>/dev/null || printf 'Unknown')"
ac_online="$(cat "$ac_online_file" 2>/dev/null || printf '0')"
capacity="${capacity//[^0-9]/}"
ac_online="${ac_online//[^0-9]/}"
[[ -z "$capacity" ]] && capacity=0
[[ -z "$ac_online" ]] && ac_online=0

class="normal"
if (( capacity <= 15 )); then
    class="critical"
elif (( capacity <= 30 )); then
    class="warning"
fi

if [[ "$status" == "Charging" ]]; then
    icon="󰂄"
    class="$class charging"
elif [[ "$status" == "Full" ]]; then
    icon="󰁹"
    class="$class plugged"
elif (( ac_online == 1 )) || [[ "$status" == "Not charging" ]]; then
    icon="󰚥"
    class="$class plugged"
else
    icons=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
    index=$(( capacity / 10 ))
    (( index < 0 )) && index=0
    (( index > 9 )) && index=9
    icon="${icons[$index]}"
fi

if [[ "$mode" == "text" ]]; then
    jq -cn --arg text "${capacity}%" --arg class "$class" '{text:$text, class:$class}'
else
    jq -cn --arg text "$icon" --arg class "$class" '{text:$text, class:$class}'
fi
