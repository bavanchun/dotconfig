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

# Switch default shell to zsh if not already
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
  echo "Switching default shell to zsh..."
  chsh -s /usr/bin/zsh "$USER" || echo "Warning: chsh failed (may need sudo)"
fi

echo "Services enabled."
