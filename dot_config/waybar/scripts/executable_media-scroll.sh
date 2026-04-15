#!/bin/bash

set -euo pipefail

MEDIA_CTL="$HOME/.config/hypr/scripts/ags-media.sh"
MAX_DISPLAY=22
PLAYING_ICON="󰎆"
PAUSED_ICON="󰏤"
IDLE_ICON="󰝚"

clean_field() {
    printf '%s' "$1" |
        sed -E \
            -e 's/[[:space:]]+[-–—][[:space:]]+(YouTube|Google Chrome|Chromium|Mozilla Firefox)$//' \
            -e 's/[[:space:]]*\([^)]*(Official Video|Official Audio|Lyrics?)[^)]*\)//Ig' \
            -e 's/[[:space:]]+/ /g' \
            -e 's/^[[:space:]]+|[[:space:]]+$//g'
}

truncate_words() {
    local text="$1"
    local cut

    if (( ${#text} <= MAX_DISPLAY )); then
        printf '%s' "$text"
        return
    fi

    cut="${text:0:$((MAX_DISPLAY - 1))}"
    cut="${cut% *}"
    [[ -z "$cut" ]] && cut="${text:0:$((MAX_DISPLAY - 1))}"
    cut="$(printf '%s' "$cut" | sed -E 's/[[:space:][:punct:]]+$//')"
    printf '%s…' "$cut"
}

format_time() {
    local seconds="${1:-0}"
    local total
    total="$(printf '%.0f' "$seconds" 2>/dev/null || printf '0')"
    (( total < 0 )) && total=0

    local h=$(( total / 3600 ))
    local m=$(( (total % 3600) / 60 ))
    local s=$(( total % 60 ))

    if (( h > 0 )); then
        printf '%d:%02d:%02d' "$h" "$m" "$s"
    else
        printf '%d:%02d' "$m" "$s"
    fi
}

status_json="$("$MEDIA_CTL" status 2>/dev/null || true)"

if [[ -z "$status_json" ]] || ! jq -e '.hasPlayer' >/dev/null 2>&1 <<<"$status_json"; then
    jq -cn --arg text "$IDLE_ICON Media" --arg class "idle" --arg tooltip "No active player" \
        '{text:$text, class:$class, tooltip:$tooltip}'
    exit 0
fi

has_player="$(jq -r '.hasPlayer' <<<"$status_json")"
if [[ "$has_player" != "true" ]]; then
    jq -cn --arg text "$IDLE_ICON Media" --arg class "idle" --arg tooltip "No active player" \
        '{text:$text, class:$class, tooltip:$tooltip}'
    exit 0
fi

title="$(clean_field "$(jq -r '.title // ""' <<<"$status_json")")"
artist="$(clean_field "$(jq -r '.artist // ""' <<<"$status_json")")"
album="$(clean_field "$(jq -r '.album // ""' <<<"$status_json")")"
identity="$(clean_field "$(jq -r '.identity // ""' <<<"$status_json")")"
players_count="$(jq -r '.playersCount // 0' <<<"$status_json")"
is_playing="$(jq -r '.isPlaying' <<<"$status_json")"
position="$(jq -r '.position // 0' <<<"$status_json")"
length="$(jq -r '.length // 0' <<<"$status_json")"

[[ -z "$title" ]] && title="Unknown track"

if [[ -n "$artist" ]]; then
    full_text="$title · $artist"
else
    full_text="$title"
fi

display_text="$(truncate_words "$full_text")"
position_text="$(format_time "$position")"
length_text="$(format_time "$length")"

if [[ "$is_playing" == "true" ]]; then
    icon="$PLAYING_ICON"
    css_class="playing"
    state_label="Playing"
else
    icon="$PAUSED_ICON"
    css_class="paused"
    state_label="Paused"
fi

if (( players_count > 1 )); then
    css_class="$css_class multi-player"
fi

tooltip="$title"
[[ -n "$artist" ]] && tooltip="$tooltip\n$artist"
[[ -n "$album" ]] && tooltip="$tooltip\n$album"
[[ -n "$identity" ]] && tooltip="$tooltip\nPlayer: $identity"
[[ -n "$length_text" && "$length_text" != "0:00" ]] && tooltip="$tooltip\n$position_text / $length_text"
if (( players_count > 1 )); then
    tooltip="$tooltip\n$players_count players available"
fi
tooltip="$tooltip\nLeft click: open panel"
tooltip="$tooltip\nMiddle click: switch player"
tooltip="$tooltip\nRight click: play / pause"

jq -cn \
    --arg text "$icon $display_text" \
    --arg class "$css_class" \
    --arg alt "$state_label" \
    --arg tooltip "$tooltip" \
    '{text:$text, class:$class, alt:$alt, tooltip:$tooltip}'
