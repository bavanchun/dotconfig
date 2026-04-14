#!/bin/bash
CHEATSHEET="$HOME/.config/hypr/cheatsheet.md"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# If not running inside a terminal, relaunch self inside kitty
if [ ! -t 1 ]; then
    kitty --class cheatsheet --title "Cheatsheet" -e "$0"
    exit
fi

glow --style dark --no-pager "$CHEATSHEET" \
    | python3 "$SCRIPT_DIR/strip_osc.py" \
    | fzf --ansi --no-sort --reverse \
        --prompt "  Search: " \
        --header "Press ESC or q to close" \
        --bind "esc:abort,q:abort"
