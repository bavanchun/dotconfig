#!/bin/bash

SCRIPT_PID_FILE="/tmp/waybar-monitor-script.pid"
WAYBAR_PID_FILE="/tmp/waybar-monitor.pid"
LOG_FILE="/tmp/waybar-monitor.log"
WAYBAR_CONFIG_RENDERED="/tmp/waybar-current.jsonc"
FORCE_RESTART="${1:-}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

get_primary_output() {
    local monitors
    monitors="$(hyprctl monitors 2>/dev/null)"

    if [[ -z "$monitors" ]]; then
        echo "eDP-1"
        return
    fi

    if grep -q "^Monitor DP-2 " <<< "$monitors"; then
        echo "DP-2"
    elif grep -q "^Monitor DP-1 " <<< "$monitors"; then
        echo "DP-1"
    elif grep -q "^Monitor eDP-1 " <<< "$monitors"; then
        echo "eDP-1"
    else
        awk '/^Monitor / { print $2; exit }' <<< "$monitors"
    fi
}

render_config() {
    local source_config="$1"
    local output_name="$2"

    sed -E "0,/\"output\": *\"[^\"]+\"/s//\"output\": \"${output_name}\"/" \
        "$source_config" > "$WAYBAR_CONFIG_RENDERED"
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
    local output_name
    local config_path
    old_waybar_pid="$(cat "$WAYBAR_PID_FILE" 2>/dev/null)"
    output_name="$(get_primary_output)"
    config_path="$HOME/.config/waybar/config-laptop.jsonc"

    if [[ -n "$old_waybar_pid" ]] && kill -0 "$old_waybar_pid" 2>/dev/null; then
        log "Killing old waybar PID $old_waybar_pid"
    fi

    pkill -x waybar 2>/dev/null
    sleep 1

    render_config "$config_path" "$output_name"
    log "Launching waybar on output $output_name with config $config_path"
    waybar --config "$WAYBAR_CONFIG_RENDERED" --style "$HOME/.config/waybar/style.css" &

    echo $! > "$WAYBAR_PID_FILE"
    log "Launched waybar (PID $!)"
}

last_output=""
log "Starting waybar monitor"
launch_waybar
last_output="$(get_primary_output)"

while sleep 3; do
    waybar_pid="$(cat "$WAYBAR_PID_FILE" 2>/dev/null)"
    current_output="$(get_primary_output)"

    if [[ "$current_output" != "$last_output" ]]; then
        log "Monitor changed: $last_output -> $current_output"
        launch_waybar
        last_output="$current_output"
        continue
    fi

    if [[ -z "$waybar_pid" ]] || ! kill -0 "$waybar_pid" 2>/dev/null; then
        log "Waybar (PID ${waybar_pid:-unknown}) died, restarting"
        launch_waybar
        last_output="$current_output"
    fi
done
