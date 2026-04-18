#!/bin/bash

WEZTERM="  WezTerm"
ALACRITTY="  Alacritty"
KITTY="  Kitty"

CHOICE=$(printf "$WEZTERM\n$ALACRITTY\n$KITTY" \
    | timeout 5 fuzzel --dmenu \
        --prompt "Terminal [5s → wezterm]: " \
        --width 32 --lines 3)
EXIT=$?

if [ "$EXIT" -eq 124 ]; then
    exec wezterm
fi

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *"WezTerm"*)   exec wezterm ;;
    *"Alacritty"*) exec alacritty ;;
    *"Kitty"*)     exec kitty ;;
esac
