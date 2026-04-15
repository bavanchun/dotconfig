#!/bin/bash

CLIENTS=""
for _ in 1 2 3; do
    CLIENTS=$(hyprctl clients 2>/dev/null)
    [[ "$CLIENTS" == *"focusHistoryID:"* ]] && break
    sleep 0.05
done

if [[ -z "$CLIENTS" || "$CLIENTS" != *"focusHistoryID:"* ]]; then
    jq -cn '{text:"󰇄 Desktop", class:"empty", tooltip:"Desktop"}'
    exit 0
fi

IFS=$'\034' read -r CLASS TITLE < <(
    awk '
        /^Window / {
            class = ""
            title = ""
            next
        }
        /^[[:space:]]*class:/ {
            sub(/^[[:space:]]*class:[[:space:]]*/, "")
            class = $0
            next
        }
        /^[[:space:]]*title:/ {
            sub(/^[[:space:]]*title:[[:space:]]*/, "")
            title = $0
            next
        }
        /^[[:space:]]*focusHistoryID:/ {
            sub(/^[[:space:]]*focusHistoryID:[[:space:]]*/, "")
            if ($0 == "0") {
                printf "%s\034%s\n", class, title
                exit
            }
        }
    ' <<< "$CLIENTS"
)

if [[ -z "$CLASS" && -z "$TITLE" ]]; then
    jq -cn '{text:"󰇄 Desktop", class:"empty", tooltip:"Desktop"}'
    exit 0
fi

CSS_CLASS=$(printf '%s' "${CLASS:-window}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/^-+|-+$//g')
[[ -z "$CSS_CLASS" ]] && CSS_CLASS="window"

clean_title() {
    printf '%s' "$1" |
        sed -E \
            -e 's/[[:space:]]+[-–—][[:space:]]+(YouTube|Google Chrome|Chromium|Mozilla Firefox)$//' \
            -e 's/[[:space:]]*\([^)]*(Official Video|Official Audio|Lyrics?)[^)]*\)//Ig' \
            -e 's/[[:space:]]+/ /g' \
            -e 's/^[[:space:]]+|[[:space:]]+$//g'
}

case "${CLASS,,}" in
    google-chrome|chrome|chromium|brave-browser)
        ICON="󰊭"; APP="Chrome" ;;
    firefox|firefoxdeveloperedition)
        ICON="󰈹"; APP="Firefox" ;;
    kitty|alacritty|foot|wezterm|org.wezfurlong.wezterm)
        ICON="󰆍"; APP="Terminal" ;;
    code|code-url-handler|codium|vscodium)
        ICON="󰨞"; APP="Code" ;;
    obsidian)
        ICON="󰠮"; APP="Obsidian" ;;
    org.gnome.nautilus|nautilus|thunar)
        ICON="󰉋"; APP="Files" ;;
    telegram-desktop|telegram)
        ICON="󰔁"; APP="Telegram" ;;
    discord|vesktop)
        ICON="󰙯"; APP="Discord" ;;
    spotify)
        ICON="󰓇"; APP="Spotify" ;;
    mpv|vlc)
        ICON="󰕼"; APP="Media" ;;
    *)
        ICON="󰣆"
        APP=$(clean_title "${CLASS:-$TITLE}")
        [[ -z "$APP" || "$APP" == "null" ]] && APP="Window"
        APP="${APP:0:16}"
        ;;
esac

TOOLTIP=$(clean_title "$TITLE")
[[ -z "$TOOLTIP" || "$TOOLTIP" == "null" ]] && TOOLTIP="$APP"

jq -cn \
    --arg text "$ICON $APP" \
    --arg class "$CSS_CLASS" \
    --arg tooltip "$TOOLTIP" \
    '{text:$text, class:$class, tooltip:$tooltip}'
