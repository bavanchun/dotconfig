#!/bin/bash
# restore-wallpaper.sh — apply saved wallpaper after hyprpaper daemon starts (called from exec-once)
# Does NOT re-run matugen to avoid slowing down boot (colors already generated from previous session)

STATE_FILE="$HOME/.config/wallpaper-current"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Wait for hyprpaper to be ready
for i in {1..20}; do
    if hyprctl hyprpaper listloaded &>/dev/null; then
        break
    fi
    sleep 0.2
done

# Read saved wallpaper, fallback to first image in Wallpapers dir
WALLPAPER=$(cat "$STATE_FILE" 2>/dev/null)
if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | head -1)
fi

if [[ -z "$WALLPAPER" ]]; then
    exit 0
fi

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
