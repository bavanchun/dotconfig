#!/bin/bash
# wallpaper-picker.sh — pick a wallpaper via fuzzel dmenu, then apply it
# Bound to SUPER + W

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Build list: "basename\x00path" so we display name but pass full path
SELECTION=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | while read -r f; do
    echo "$(basename "$f")"
done | fuzzel --dmenu --prompt "Wallpaper: ")

[[ -z "$SELECTION" ]] && exit 0

WALLPAPER="$WALLPAPER_DIR/$SELECTION"

if [[ ! -f "$WALLPAPER" ]]; then
    notify-send -u critical "Wallpaper" "File not found: $WALLPAPER"
    exit 1
fi

bash "$HOME/.config/hypr/scripts/set-wallpaper.sh" "$WALLPAPER"
