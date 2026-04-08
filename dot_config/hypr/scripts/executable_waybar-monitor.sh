#!/bin/bash

SCRIPT_PID_FILE="/tmp/waybar-monitor-script.pid"
WAYBAR_PID_FILE="/tmp/waybar-monitor.pid"
LOG_FILE="/tmp/waybar-monitor.log"
FORCE_RESTART="${1:-}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

if [[ -f "$SCRIPT_PID_FILE" ]]; then
    old_pid="$(cat "$SCRIPT_PID_FILE" 2>/dev/null)"
    if [[ "$FORCE_RESTART" == "restart" ]]; then
        if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
            log "Force restart: killing old monitor PID $old_pid"
            kill "$old_pid" 2>/dev/null
            sleep 1
        fi
        rm -f "$SCRIPT_PID_FILE"
    elif [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
        exit 0
    else
        log "Stale script PID file (PID $old_pid dead), cleaning up"
        rm -f "$SCRIPT_PID_FILE"
    fi
fi

echo $$ > "$SCRIPT_PID_FILE"
trap 'rm -f "$SCRIPT_PID_FILE"; log "Monitor script exiting (PID $$)"' EXIT

log "Monitor script started (PID $$)"


launch_waybar() {
    local old_waybar_pid
    old_waybar_pid="$(cat "$WAYBAR_PID_FILE" 2>/dev/null)"

    if [[ -n "$old_waybar_pid" ]] && kill -0 "$old_waybar_pid" 2>/dev/null; then
        log "Killing old waybar PID $old_waybar_pid"
    fi

    pkill -x waybar 2>/dev/null
    sleep 1

    waybar --config "$HOME/.config/waybar/config-laptop.jsonc" --style "$HOME/.config/waybar/style.css" &

    echo $! > "$WAYBAR_PID_FILE"
    log "Launched waybar (PID $!)"
}

log "Starting waybar (laptop-only mode)"
launch_waybar

while sleep 3; do
    waybar_pid="$(cat "$WAYBAR_PID_FILE" 2>/dev/null)"
    if [[ -z "$waybar_pid" ]] || ! kill -0 "$waybar_pid" 2>/dev/null; then
        log "Waybar (PID ${waybar_pid:-unknown}) died, restarting"
        launch_waybar
    fi
done
