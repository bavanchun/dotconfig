#!/bin/bash
# Re-create theme symlinks after chezmoi apply so active theme is preserved
MODE=$(cat "$HOME/.config/theme-mode" 2>/dev/null || echo "dark")
ln -sf "$HOME/.config/waybar/style-${MODE}.css" "$HOME/.config/waybar/style.css"
ln -sf "$HOME/.config/swaync/style-${MODE}.css" "$HOME/.config/swaync/style.css"
