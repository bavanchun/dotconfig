#!/bin/bash

playerctld daemon 2>/dev/null

playerctl -F metadata 2>/dev/null | while IFS= read -r _; do
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    status=$(playerctl status 2>/dev/null)
    player=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

    jq -cn \
        --arg text "$artist · $title" \
        --arg alt "$status" \
        --arg tooltip "$player: $artist – $title" \
        '{text: $text, alt: $alt, tooltip: $tooltip}'
done
