#!/bin/bash

CHOICE=$(printf '%s\n' \
    "WezTerm    default terminal" \
    "Kitty      fast and feature-rich" \
    "Alacritty  minimal and lightweight" \
    | timeout 5 fuzzel --dmenu \
        --config ~/.config/fuzzel/terminal-picker.ini \
        --prompt "terminal  " \
        --placeholder "Select a terminal [5s default: WezTerm]" \
        --mesg "Pick the terminal to launch with SUPER+T" \
        --select "WezTerm")
EXIT=$?

if [ "$EXIT" -eq 124 ]; then
    exec wezterm
fi

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    WezTerm*)   exec wezterm ;;
    Alacritty*) exec alacritty ;;
    Kitty*)     exec kitty ;;
esac
