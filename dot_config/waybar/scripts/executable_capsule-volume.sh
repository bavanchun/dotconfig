#!/bin/bash

set -euo pipefail

mode="${1:-icon}"
output="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || printf '')"

if [[ -z "$output" ]]; then
    jq -cn --arg text "󰖁" '{text:$text}'
    exit 0
fi

volume="$(awk '{print $2}' <<<"$output")"
muted="false"
[[ "$output" == *"[MUTED]"* ]] && muted="true"

percent="$(awk -v v="${volume:-0}" 'BEGIN { printf "%d", (v * 100) + 0.5 }')"
class="normal"

if [[ "$muted" == "true" ]]; then
    icon="󰝟"
    class="muted"
elif (( percent <= 33 )); then
    icon="󰕿"
elif (( percent <= 66 )); then
    icon="󰖀"
else
    icon="󰕾"
fi

if [[ "$mode" == "text" ]]; then
    jq -cn --arg text "${percent}%" --arg class "$class" '{text:$text, class:$class}'
else
    jq -cn --arg text "$icon" --arg class "$class" '{text:$text, class:$class}'
fi
