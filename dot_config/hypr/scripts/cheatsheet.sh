#!/bin/bash
CHEATSHEET="$HOME/.config/hypr/cheatsheet.md"

kitty --class cheatsheet --title "Cheatsheet" -e glow --style dark --pager "$CHEATSHEET"
