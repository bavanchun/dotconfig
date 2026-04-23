#!/usr/bin/env bash

repo_list=$(checkupdates 2>/dev/null)
aur_list=$(yay -Qua 2>/dev/null)

repo_count=0
aur_count=0
[ -n "$repo_list" ] && repo_count=$(printf '%s\n' "$repo_list" | wc -l)
[ -n "$aur_list" ] && aur_count=$(printf '%s\n' "$aur_list" | wc -l)
total=$((repo_count + aur_count))

if [ "$total" -eq 0 ]; then
    printf '{"text": "", "tooltip": "System is up to date ✓", "class": "updated"}\n'
    exit 0
fi

tooltip="<b>$total updates</b>  ($repo_count repo + $aur_count AUR)"
if [ -n "$repo_list" ]; then
    tooltip+=$'\n\n<b>Repo:</b>\n'
    tooltip+=$(printf '%s' "$repo_list" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
fi
if [ -n "$aur_list" ]; then
    tooltip+=$'\n\n<b>AUR:</b>\n'
    tooltip+=$(printf '%s' "$aur_list" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
fi

tooltip_escaped=$(printf '%s' "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g; s/"/\\"/g')
printf '{"text": "%s", "tooltip": "%s", "class": "updates-available"}\n' "$total" "$tooltip_escaped"
