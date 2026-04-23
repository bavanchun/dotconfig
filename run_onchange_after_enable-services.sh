#!/usr/bin/env bash
# services version: 1
set -euo pipefail

system_services=(
  NetworkManager.service
  bluetooth.service
  power-profiles-daemon.service
)

for svc in "${system_services[@]}"; do
  if systemctl list-unit-files "$svc" &>/dev/null; then
    sudo systemctl enable --now "$svc" || echo "Warning: failed to enable $svc"
  fi
done


echo "Services enabled. (zsh default shell is handled by dotconfig-term repo)"
