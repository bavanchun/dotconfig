#!/bin/bash
# restore-wallpaper.sh — restore last-used wallpaper at startup (no matugen re-run, keep boot fast)

STATE_FILE="$HOME/.config/wallpaper-current"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Wait for awww daemon to be ready
for i in {1..20}; do
    if awww query 2>/dev/null | grep -q "Name:"; then
        break
    fi
    sleep 0.2
done

# Try awww restore first (uses cache from last session)
if awww restore 2>/dev/null; then
    exit 0
fi

# Fallback: read saved state
WALLPAPER=$(cat "$STATE_FILE" 2>/dev/null)
if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | head -1)
fi

[[ -z "$WALLPAPER" ]] && exit 0

awww img "$WALLPAPER" --transition-type none
