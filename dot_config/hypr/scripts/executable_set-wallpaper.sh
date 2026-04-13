#!/bin/bash
# set-wallpaper.sh — preload wallpaper via hyprpaper IPC, regenerate matugen colors, reload UI
# Usage: set-wallpaper.sh /path/to/image.jpg

WALLPAPER="$1"

if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    notify-send -u critical "Wallpaper" "File not found: $WALLPAPER"
    exit 1
fi

# 1. Preload ảnh mới vào hyprpaper
hyprctl hyprpaper preload "$WALLPAPER"

# 2. Áp cho mọi monitor (dấu , không có tên = all monitors)
hyprctl hyprpaper wallpaper ",$WALLPAPER"

# 3. Unload tất cả ảnh cũ (ảnh hiện tại đã được preload ở bước 1, nên không bị xoá)
hyprctl hyprpaper unload all

# 4. Persist state
echo "$WALLPAPER" > "$HOME/.config/wallpaper-current"

# 5. Regenerate màu từ wallpaper (matugen image mode)
MODE=$(cat "$HOME/.config/theme-mode" 2>/dev/null || echo "dark")
matugen image "$WALLPAPER" -m "$MODE"

# 6. Reload UI
hyprctl reload
bash "$HOME/.config/hypr/scripts/waybar-monitor.sh" restart
swaync-client --reload-css

# 7. Notify
notify-send "Wallpaper" "$(basename "$WALLPAPER")" --icon="preferences-desktop-wallpaper"
