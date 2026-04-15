#!/bin/bash

set -euo pipefail

INSTANCE="media-panel"
APP_DIR="$HOME/.config/ags/media"
LOG_FILE="/tmp/ags-media-panel.log"
COMMAND="${1:-toggle}"

if ! ags list 2>/dev/null | grep -q "^${INSTANCE}$"; then
    setsid -f ags run -d "$APP_DIR" --log-file "$LOG_FILE"
    sleep 0.4
fi

ags request -i "$INSTANCE" "$COMMAND"
