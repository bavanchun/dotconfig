#!/bin/bash

APP_DIR="$HOME/.config/ags"
LOG_FILE="/tmp/control-center.log"

wrapper_pid="$(pgrep -f "^ags run ${APP_DIR}$" | head -n1)"
gjs_pid="$(busctl --user list 2>/dev/null | awk '/io\.Astal\.control-center/ {print $2; exit}')"

if [[ -n "$wrapper_pid" || -n "$gjs_pid" ]]; then
    [[ -n "$wrapper_pid" ]] && kill "$wrapper_pid" 2>/dev/null
    [[ -n "$gjs_pid" ]] && kill "$gjs_pid" 2>/dev/null
    exit 0
fi

nohup ags run "$APP_DIR" >"$LOG_FILE" 2>&1 &
