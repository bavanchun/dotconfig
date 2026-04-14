#!/bin/bash
set -euo pipefail

CONFIG_NAME="vchun"
CONFIG_PATH="$HOME/.config/quickshell/$CONFIG_NAME"
LOG_FILE="/tmp/quickshell-${CONFIG_NAME}.log"
SEED_COLOR="#c73e64"

ensure_generated_theme() {
    local mode

    if [[ -f "$CONFIG_PATH/theme/Generated.qml" ]]; then
        return
    fi

    mode="$(cat "$HOME/.config/theme-mode" 2>/dev/null || echo dark)"
    matugen color hex "$SEED_COLOR" -m "$mode" >/dev/null 2>&1 || true
}

usage() {
    printf 'Usage: %s {start|stop|restart|status|foreground|logs}\n' "$0"
}

start_shell() {
    pkill -f "waybar-monitor.sh" 2>/dev/null || true
    pkill -x waybar 2>/dev/null || true
    quickshell kill -c codex-safe 2>/dev/null || true
    ensure_generated_theme
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
        ensure_generated_theme
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
