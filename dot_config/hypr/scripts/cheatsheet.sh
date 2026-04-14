#!/bin/bash
CHEATSHEET="$HOME/.config/hypr/cheatsheet.md"

# If not running inside a terminal, relaunch self inside kitty
if [ ! -t 1 ]; then
    kitty --class cheatsheet --title "Cheatsheet" -e "$0"
    exit
fi

# Strip OSC escape sequences (terminal color init) that fzf can't handle,
# then pipe rendered markdown into fzf for fuzzy search
glow --style dark --no-pager "$CHEATSHEET" \
    | perl -pe 's/\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)//g' \
    | fzf --ansi --no-sort --reverse \
        --prompt "  Search: " \
        --header "Press ESC or q to close" \
        --bind "esc:abort,q:abort"
