#!/bin/bash
# restore-wallpaper.sh — restore last-used wallpaper at startup (no matugen re-run, keep boot fast)
# Deliberately avoids `awww restore` (per-monitor cache) to ensure all monitors get the same wallpaper.

STATE_FILE="$HOME/.config/wallpaper-current"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Wait for awww daemon to be ready (timeout after 4s)
READY=0
for i in {1..20}; do
    if awww query >/dev/null 2>&1; then
        READY=1
        break
    fi
    sleep 0.2
done
[ "$READY" -eq 0 ] && exit 0

# Always use saved state so every monitor gets the same wallpaper
WALLPAPER=$(cat "$STATE_FILE" 2>/dev/null)
if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | head -1)
fi

[[ -z "$WALLPAPER" ]] && exit 0

# Apply to all monitors (no --outputs = all outputs by default)
awww img "$WALLPAPER" --transition-type none
