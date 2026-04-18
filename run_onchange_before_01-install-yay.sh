#!/usr/bin/env bash
# Install yay AUR helper if not present
set -euo pipefail

if command -v yay >/dev/null 2>&1; then
  exit 0
fi

echo "Installing yay..."
sudo pacman -S --needed --noconfirm base-devel git
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay"
( cd "$tmp/yay" && makepkg -si --noconfirm )
echo "yay installed."
