#!/bin/bash
set -euo pipefail

CONFIG_NAME="vchun"
CONFIG_PATH="$HOME/.config/quickshell/$CONFIG_NAME"
LOG_FILE="/tmp/quickshell-${CONFIG_NAME}.log"

usage() {
    printf 'Usage: %s {start|stop|restart|status|foreground|logs}\n' "$0"
}

start_shell() {
    pkill -f "waybar-monitor.sh" 2>/dev/null || true
    pkill -x waybar 2>/dev/null || true
    quickshell kill -c codex-safe 2>/dev/null || true
    quickshell -c "$CONFIG_NAME" --no-duplicate --daemonize >"$LOG_FILE" 2>&1
}

case "${1:-start}" in
    start)
        start_shell
        ;;
    stop)
        quickshell kill -c "$CONFIG_NAME" 2>/dev/null || true
        ;;
    restart)
        quickshell kill -c "$CONFIG_NAME" 2>/dev/null || true
        sleep 1
        start_shell
        ;;
    status)
        quickshell list -c "$CONFIG_NAME"
        ;;
    foreground)
        exec quickshell -p "$CONFIG_PATH" --no-duplicate --log-times
        ;;
    logs)
        quickshell log -c "$CONFIG_NAME" --no-color 2>/dev/null || true
        [[ -f "$LOG_FILE" ]] && tail -n 80 "$LOG_FILE"
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
