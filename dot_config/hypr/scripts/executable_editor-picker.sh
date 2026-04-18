#!/bin/bash

ARGS=("$@")
[ ${#ARGS[@]} -eq 0 ] && ARGS=(".")

OPTIONS=""
add() {
    if command -v "$1" >/dev/null 2>&1; then
        OPTIONS+="$2"$'\n'
    fi
}

add code    "VS Code    GUI editor (Electron)"
add cursor  "Cursor     AI-powered fork of VS Code"
add zed     "Zed        GPU-accelerated Rust editor"
add nvim    "Neovim     modal TUI editor"
add hx      "Helix      modal TUI with built-in LSP"

OPTIONS="${OPTIONS%$'\n'}"

CHOICE=$(printf '%s' "$OPTIONS" \
    | timeout 5 fuzzel --dmenu \
        --config ~/.config/fuzzel/terminal-picker.ini \
        --prompt "editor  " \
        --placeholder "Select an editor [5s default: VS Code]" \
        --mesg "Open with: ${ARGS[*]}" \
        --select "VS Code")
EXIT=$?

if [ "$EXIT" -eq 124 ]; then
    exec code "${ARGS[@]}"
fi

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "VS Code"*) exec code "${ARGS[@]}" ;;
    Cursor*)    exec cursor "${ARGS[@]}" ;;
    Zed*)       exec zed "${ARGS[@]}" ;;
    Neovim*)    exec nvim "${ARGS[@]}" ;;
    Helix*)     exec hx "${ARGS[@]}" ;;
esac
