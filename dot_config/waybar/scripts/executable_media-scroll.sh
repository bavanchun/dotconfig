#!/bin/bash
# Media player widget for Waybar
# - Animated equalizer bars when playing
# - Scrolling title · artist
# - Position / length display

SCROLL_FILE="/tmp/waybar-media-scroll-pos"
MAX_DISPLAY=22
SCROLL_SPEED=1

FRAMES=("▁▃▅▇" "▃▅▇▅" "▅▇▅▃" "▇▅▃▁" "▅▃▁▃")
PAUSE_ICON="⏸ "

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
    rm -f "$SCROLL_FILE"
    echo ""
    exit 0
fi

TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null | sed 's/"/\\"/g')
ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null | sed 's/"/\\"/g')
POSITION=$(playerctl --player="$PLAYER" metadata --format "{{duration(position)}}" 2>/dev/null)
LENGTH=$(playerctl --player="$PLAYER" metadata --format "{{duration(mpris:length)}}" 2>/dev/null)

[[ -z "$TITLE" ]] && TITLE="Unknown"

FULL_TEXT="$TITLE"
[[ -n "$ARTIST" ]] && FULL_TEXT="$TITLE · $ARTIST"
TEXT_LEN=${#FULL_TEXT}

if [[ $TEXT_LEN -le $MAX_DISPLAY ]]; then
    DISPLAY_TEXT="$FULL_TEXT"
    rm -f "$SCROLL_FILE"
else
    POS=$(cat "$SCROLL_FILE" 2>/dev/null || echo 0)
    PADDED="$FULL_TEXT   $FULL_TEXT   "
    DISPLAY_TEXT="${PADDED:$POS:$MAX_DISPLAY}"
    NEXT_POS=$(( (POS + SCROLL_SPEED) % (TEXT_LEN + 3) ))
    echo "$NEXT_POS" > "$SCROLL_FILE"
fi

TIME_STR=""
[[ -n "$POSITION" && -n "$LENGTH" ]] && TIME_STR=" $POSITION/$LENGTH"

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

printf '{"text": "%s %s%s", "class": "%s", "tooltip": "%s"}\n' \
    "$ICON" "$DISPLAY_TEXT" "$TIME_STR" "$CSS_CLASS" "$TOOLTIP"
