#!/bin/bash
CHEATSHEET="$HOME/.config/hypr/cheatsheet.md"

kitty --class cheatsheet --title "Cheatsheet" -e bash -c \
    "glow --style dark --no-pager '$CHEATSHEET' | fzf --ansi --no-sort --reverse \
        --prompt '  Search: ' --header 'Press ESC or q to close' \
        --bind 'esc:abort,q:abort'"
