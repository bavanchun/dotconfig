#!/bin/bash
CHEATSHEET="$HOME/.config/hypr/cheatsheet.md"

if command -v glow &>/dev/null; then
    kitty --class cheatsheet --title "Cheatsheet" -e glow --pager "$CHEATSHEET"
else
    kitty --class cheatsheet --title "Cheatsheet" -e bat --style=plain --language=md --paging=always "$CHEATSHEET"
fi
