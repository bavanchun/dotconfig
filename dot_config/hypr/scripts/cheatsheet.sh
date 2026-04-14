#!/bin/bash
CHEATSHEET="$HOME/.config/hypr/cheatsheet.md"

# If not running inside a terminal, relaunch self inside kitty
if [ ! -t 1 ]; then
    kitty --class cheatsheet --title "Cheatsheet" -e "$0"
    exit
fi

bat --style=plain --language=md --color=always --paging=never "$CHEATSHEET" \
    | fzf --ansi --no-sort --reverse \
        --prompt "  Search: " \
        --header "Press ESC or q to close" \
        --bind "esc:abort,q:abort"
