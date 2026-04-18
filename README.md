# dotconfig

Hyprland dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Stack

| Layer | Tool |
|---|---|
| WM | Hyprland |
| Bar | Waybar |
| Launcher | Rofi, Fuzzel |
| Notifications | SwayNC |
| Terminal | WezTerm (cursor trail), Kitty, Alacritty |
| Shell | Zsh + Zinit + Starship |
| Theming | Matugen (Material You từ wallpaper) |
| Wallpaper | awww |
| Lock | Hyprlock |
| Logout | Wlogout |

## Setup trên máy Arch mới

**Yêu cầu trước:** Arch đã install, user đã tạo, sudo đã setup, mạng đã thông.

```bash
# 1. Đặt hostname có nghĩa — quan trọng, machine config dựa vào hostname
hostnamectl set-hostname <tên-máy>   # vd: laptop, desktop, workstation

# 2. Cài chezmoi và git
sudo pacman -S --needed chezmoi git

# 3. Init và apply (sẽ tự động cài yay + packages + enable services)
chezmoi init --apply git@github.com:bavanchun/dotconfig.git
```

`chezmoi init --apply` sẽ tự động:
- Cài `yay` (AUR helper) nếu chưa có
- Cài toàn bộ pacman + AUR packages cần thiết
- Enable systemd services: NetworkManager, bluetooth, power-profiles-daemon
- Đổi default shell sang zsh
- Tạo file monitor config fallback nếu chưa có per-machine config

```bash
# 4. Copy avatar và wallpapers
mkdir -p ~/Pictures/Wallpapers
cp /path/to/avatar.jpg ~/Pictures/avatar-hyprlock.jpg
cp /path/to/wallpapers/* ~/Pictures/Wallpapers/

# 5. (Tùy chọn) Tạo monitor config cho máy này
# File fallback đã có, nhưng nếu muốn setup chính xác:
# - Dùng nwg-displays hoặc sửa tay
cp ~/.config/hypr/monitors-$(hostname).conf ~/.config/hypr/monitors-$(hostname).conf.bak
# sửa theo hardware thực tế

# 6. Khởi động Hyprland
# (logout và login lại, chọn Hyprland trong display manager)
```

## Per-machine monitor config

Mỗi máy có file monitor config riêng: `~/.config/hypr/monitors-<hostname>.conf`

- File này KHÔNG được chezmoi track (mỗi máy có hardware khác nhau)
- Khi bootstrap trên máy mới, fallback `monitor = , preferred, auto, 1` được tạo tự động
- Chỉnh sửa file này trực tiếp theo hardware thực tế (không qua chezmoi)

## Theming

- Seed color: `#c73e64`
- Toggle dark/light: `Super+F10`
- Đổi wallpaper (tự động regenerate màu): `hyprctl dispatch exec "~/.config/hypr/scripts/wallpaper-picker.sh"`

## Thêm/bỏ packages

Sửa `.chezmoidata/packages.yaml`, rồi `chezmoi apply`. Script sẽ tự chạy lại khi file thay đổi.

## Thêm máy mới vào dotconfig

1. Đặt hostname trên máy mới
2. Tạo `dot_config/hypr/monitors-<hostname>.conf` nếu muốn monitor config riêng
3. Commit vào repo: `chezmoi cd && git add . && git commit -m "add: monitor config for <hostname>"`
