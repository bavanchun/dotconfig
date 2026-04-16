#!/bin/bash

set -euo pipefail

mode="${1:-icon}"
output="$(brightnessctl -m 2>/dev/null || printf '')"

if [[ -z "$output" ]]; then
    jq -cn --arg text "󰃞" '{text:$text}'
    exit 0
fi

IFS=',' read -r _ _ current percent_raw max <<<"$output"
current="${current//[^0-9]/}"
percent="${percent_raw//[^0-9]/}"
max="${max//[^0-9]/}"
[[ -z "$current" ]] && current=0
[[ -z "$percent" ]] && percent=0
[[ -z "$max" || "$max" == "0" ]] && max=1

if (( percent <= 10 )); then
    icon="󰋙"
elif (( percent <= 40 )); then
    icon="󰃞"
elif (( percent <= 70 )); then
    icon="󰃟"
else
    icon="󰃠"
fi

if [[ "$mode" == "text" ]]; then
    jq -cn --arg text "${percent}%" '{text:$text}'
else
    jq -cn --arg text "$icon" '{text:$text}'
fi
