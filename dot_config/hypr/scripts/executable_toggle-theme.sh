#!/bin/bash
STATE_FILE="$HOME/.config/theme-mode"
SEED_COLOR="#c73e64"

# Read current mode (default: dark)
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "dark")

# Toggle
[[ "$CURRENT" == "dark" ]] && NEW="light" || NEW="dark"

# Persist state
echo "$NEW" > "$STATE_FILE"

# 1. Matugen → regenerate all color templates (hyprland, hyprlock, fuzzel, gtk3, gtk4)
WALLPAPER=$(cat "$HOME/.config/wallpaper-current" 2>/dev/null)
if [[ -f "$WALLPAPER" ]]; then
    matugen image "$WALLPAPER" -m "$NEW" \
        --prefer saturation \
        --type scheme-vibrant \
        --contrast 0.3
else
    matugen color hex "$SEED_COLOR" -m "$NEW"
fi

# 2. GTK theme + color-scheme
if [[ "$NEW" == "light" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
else
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
fi

# 3. Swap CSS/theme symlinks
ln -sf "$HOME/.config/waybar/style-${NEW}.css" "$HOME/.config/waybar/style.css"
ln -sf "$HOME/.config/swaync/style-${NEW}.css" "$HOME/.config/swaync/style.css"
ln -sf "$HOME/.config/alacritty/theme-${NEW}.toml" "$HOME/.config/alacritty/theme.toml"

# 4. Reload everything
hyprctl reload
bash ~/.config/hypr/scripts/waybar-monitor.sh restart
swaync-client --reload-css

# 5. Notify
ICON="weather-clear-night"
[[ "$NEW" == "light" ]] && ICON="weather-clear"
notify-send "Theme" "Switched to ${NEW} mode" --icon="$ICON"
