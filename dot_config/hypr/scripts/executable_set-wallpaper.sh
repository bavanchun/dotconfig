#!/bin/bash
# set-wallpaper.sh — set wallpaper with transition via awww, then regenerate matugen colors
# Usage: set-wallpaper.sh /path/to/image.jpg [transition-type]
#
# Transition types: simple, fade, grow, outer, center, wipe, wave, left, right, top, bottom, random
# Default: grow (from center) — most visually satisfying

WALLPAPER="$1"

if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    notify-send -u critical "Wallpaper" "File not found: $WALLPAPER"
    exit 1
fi

# Cycle through transitions in order
TRANSITIONS=(fade grow outer center wipe wave left right top bottom)
INDEX_FILE="$HOME/.config/wallpaper-transition-index"
INDEX=$(cat "$INDEX_FILE" 2>/dev/null || echo "0")
INDEX=$(( INDEX % ${#TRANSITIONS[@]} ))
TRANSITION="${TRANSITIONS[$INDEX]}"
echo $(( (INDEX + 1) % ${#TRANSITIONS[@]} )) > "$INDEX_FILE"

# 1. Set wallpaper with transition
awww img "$WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-pos center \
    --transition-duration 1.5 \
    --transition-fps 60 \
    --transition-bezier 0.25,0.1,0.25,1

# 2. Persist state
echo "$WALLPAPER" > "$HOME/.config/wallpaper-current"

# 3. Regenerate màu từ seed cố định (giữ identity xanh mộc #38A159)
MODE=$(cat "$HOME/.config/theme-mode" 2>/dev/null || echo "dark")
matugen color hex "#38A159" -m "$MODE"

# 4. Reload UI
pkill -SIGUSR2 waybar
swaync-client --reload-css

# 5. Notify
notify-send "Wallpaper" "$(basename "$WALLPAPER")  [${TRANSITION}]" --icon="preferences-desktop-wallpaper"
