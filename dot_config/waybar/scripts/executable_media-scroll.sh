#!/bin/bash
# Media player widget for Waybar
# - Animated equalizer bars when playing
# - Compact title · artist label
# - Position / length display in the tooltip

MAX_DISPLAY=14

FRAMES=("▁▃▅▇" "▃▅▇▅" "▅▇▅▃" "▇▅▃▁" "▅▃▁▃")
PAUSE_ICON="⏸ "

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

# Find best player: Playing > Paused > skip
PLAYER=""; STATUS=""
for p in $(playerctl -l 2>/dev/null); do
    s=$(playerctl --player="$p" status 2>/dev/null)
    if [[ "$s" == "Playing" ]]; then
        PLAYER="$p"; STATUS="Playing"; break
    elif [[ "$s" == "Paused" && -z "$PLAYER" ]]; then
        PLAYER="$p"; STATUS="Paused"
    fi
done

if [[ -z "$PLAYER" ]]; then
    echo ""
    exit 0
fi

TITLE=$(clean_field "$(playerctl --player="$PLAYER" metadata title 2>/dev/null)")
ARTIST=$(clean_field "$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)")
POSITION=$(playerctl --player="$PLAYER" metadata --format "{{duration(position)}}" 2>/dev/null)
LENGTH=$(playerctl --player="$PLAYER" metadata --format "{{duration(mpris:length)}}" 2>/dev/null)

[[ -z "$TITLE" ]] && TITLE="Unknown"

FULL_TEXT="$TITLE"
[[ -n "$ARTIST" ]] && FULL_TEXT="$TITLE · $ARTIST"
DISPLAY_TEXT=$(truncate_words "$FULL_TEXT")

if [[ "$STATUS" == "Playing" ]]; then
    FRAME_IDX=$(( $(date +%s) % ${#FRAMES[@]} ))
    ICON="${FRAMES[$FRAME_IDX]}"
    CSS_CLASS="playing"
else
    ICON="$PAUSE_ICON"
    CSS_CLASS="paused"
fi

TOOLTIP="$TITLE"
[[ -n "$ARTIST" ]] && TOOLTIP="$TITLE\n$ARTIST"
[[ -n "$POSITION" && -n "$LENGTH" ]] && TOOLTIP="$TOOLTIP\n$POSITION / $LENGTH"

jq -cn \
    --arg text "$ICON $DISPLAY_TEXT" \
    --arg class "$CSS_CLASS" \
    --arg tooltip "$TOOLTIP" \
    '{text:$text, class:$class, tooltip:$tooltip}'
