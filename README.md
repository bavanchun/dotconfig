# dotconfig

> Hyprland-based Arch Linux dotfiles — managed by [chezmoi](https://www.chezmoi.io/), themed with Material You from wallpaper, zero-touch bootstrap.

```
┌─────────────────────────────────────────────────────┐
│  Compositor  : Hyprland (+ hyprexpo)                │
│  Bar         : Waybar                               │
│  Launcher    : Rofi · Fuzzel                        │
│  Notify      : SwayNC                               │
│  Terminal    : WezTerm · Kitty · Alacritty          │
│  Shell       : Zsh + Zinit + Starship               │
│  Lock/Idle   : Hyprlock · Hypridle                  │
│  Wallpaper   : awww (với transition)                │
│  Theming     : Matugen (Material You từ wallpaper)  │
│  Editor      : Neovim (LazyVim)                     │
└─────────────────────────────────────────────────────┘
```

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Key Bindings](#key-bindings)
- [Scripts](#scripts)
- [Theming](#theming)
- [Per-machine Configuration](#per-machine-configuration)
- [Repository Structure](#repository-structure)
- [Daily Workflow](#daily-workflow)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)

---

## Features

- **Zero-touch bootstrap** — chạy 1 lệnh trên máy Arch mới là setup xong toàn bộ
- **Auto package installation** — khai báo packages trong `.chezmoidata/packages.yaml`, chezmoi tự cài qua pacman + yay
- **Per-machine configs** — `machine` variable auto-detect từ hostname, monitor config riêng cho từng máy
- **Material You theming** — seed color `#c73e64`, matugen regenerate toàn bộ màu từ wallpaper
- **Dark/Light toggle** — `SUPER+F10` đổi theme toàn hệ thống (GTK + waybar + swaync + alacritty + matugen)
- **Smart pickers** — Terminal picker (`SUPER+T`), Editor picker, Wallpaper picker với fuzzel UI
- **Zero hardcode** — không có path/hostname/username cụ thể trong configs portable
- **Clipboard manager** — cliphist tự lưu history, `SUPER+SHIFT+V` để dán từ history
- **Fingerprint unlock** — hyprlock tích hợp fprintd

---

## Quick Start

### Setup trên máy Arch mới

Yêu cầu: Arch Linux đã cài, user đã tạo, sudo đã setup, mạng đã thông.

```bash
# 1. Đặt hostname có nghĩa (quan trọng — machine config dựa vào hostname)
hostnamectl set-hostname <tên-máy>

# 2. Cài chezmoi + git (chỉ 2 packages này cần cài thủ công)
sudo pacman -S --needed chezmoi git

# 3. Init và apply — tự động cài mọi thứ
chezmoi init --apply git@github.com:bavanchun/dotconfig.git
```

Bước 3 sẽ tự động:

| Bước | Thực hiện |
|------|-----------|
| 1 | Render `~/.config/chezmoi/chezmoi.toml` với `machine = hostname` |
| 2 | Cài `yay` (AUR helper) từ source nếu chưa có |
| 3 | Cài **~50 pacman + ~10 AUR packages** từ `.chezmoidata/packages.yaml` |
| 4 | Apply tất cả configs vào `~/.config/` |
| 5 | Enable systemd: `NetworkManager`, `bluetooth`, `power-profiles-daemon` |
| 6 | Đổi default shell sang `zsh` |
| 7 | Tạo fallback monitor config nếu chưa có `monitors-<hostname>.conf` |

### Hậu install

```bash
# Copy avatar + wallpapers
cp /path/to/avatar.jpg ~/Pictures/avatar-hyprlock.jpg
mkdir -p ~/Pictures/Wallpapers
cp /path/to/wallpapers/*.jpg ~/Pictures/Wallpapers/

# Logout và chọn Hyprland trong display manager
```

---

## Architecture

### Bootstrap flow

```
chezmoi init --apply
        │
        ├─► [.chezmoi.toml.tmpl] → render → ~/.config/chezmoi/chezmoi.toml
        │                                    (machine = hostname)
        │
        ├─► run_onchange_before_01-install-yay.sh
        │       └─► clone yay-bin → makepkg -si
        │
        ├─► run_onchange_before_02-install-packages.sh.tmpl
        │       └─► pacman -S + yay -S từ .chezmoidata/packages.yaml
        │
        ├─► Apply dotfiles (dot_config/** → ~/.config/**)
        │       ├─► Render templates (hyprland.conf.tmpl, hyprlock.conf.tmpl, ...)
        │       └─► Create symlinks (theme dark/light)
        │
        ├─► run_onchange_after_enable-services.sh
        │       ├─► systemctl enable NetworkManager bluetooth power-profiles-daemon
        │       └─► chsh -s /usr/bin/zsh
        │
        └─► run_onchange_after_ensure-monitor-fallback.sh.tmpl
                └─► create monitors-<hostname>.conf nếu chưa có
```

### Theming pipeline

```
User đổi wallpaper (SUPER+W)
        │
        ├─► awww img <wallpaper> --transition ...
        │
        └─► matugen image <wallpaper> -m dark/light
                ├─► ~/.config/hypr/hyprland/colors.conf
                ├─► ~/.config/hypr/hyprlock/colors.conf
                ├─► ~/.config/waybar/colors.css
                ├─► ~/.config/fuzzel/fuzzel_theme.ini
                ├─► ~/.config/gtk-3.0/gtk.css
                ├─► ~/.config/gtk-4.0/gtk.css
                └─► KDE material-you-colors
        │
        ├─► pkill -SIGUSR2 waybar        # reload waybar
        └─► swaync-client --reload-css   # reload notifications
```

---

## Key Bindings

`$mainMod` = `SUPER` (Windows key)

### Window management

| Binding | Action |
|---------|--------|
| `SUPER + Q` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + P` | Pseudo tile (dwindle) |
| `SUPER + \` | Toggle split (dwindle) |
| `SUPER + H/J/K/L` | Focus left/down/up/right |
| `SUPER + SHIFT + H/J/K/L` | Swap window |
| `SUPER + CTRL + H/J/K/L` | Resize |
| `SUPER + Mouse drag` | Move window |
| `SUPER + RMB drag` | Resize window |

### Workspaces

| Binding | Action |
|---------|--------|
| `SUPER + 1-9,0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-9,0` | Move window to workspace |
| `SUPER + S` | Toggle scratchpad |

### Apps & Pickers

| Binding | Action |
|---------|--------|
| `SUPER + T` | Terminal picker (WezTerm/Kitty/Alacritty với 5s countdown) |
| `SUPER + E` | File manager (Nautilus) |
| `SUPER + SPACE` | App launcher (Rofi) |
| `SUPER + W` | Wallpaper picker |
| `SUPER + N` | Notification panel (SwayNC) |
| `SUPER + F1` | Keybinding cheatsheet |
| `ALT + SPACE` | Toggle fcitx5 (input method) |

### Theming

| Binding | Action |
|---------|--------|
| `SUPER + F10` | Toggle dark/light theme |
| `SUPER + F9` | Toggle hyprsunset (night light) |

### Screenshots

| Binding | Action |
|---------|--------|
| `Print` · `CTRL + SHIFT + 4` | Flameshot (region, annotated) |
| `CTRL + SHIFT + 3` | hyprshot region → file |
| `CTRL + SHIFT + 2` | hyprshot window → clipboard |
| `SUPER + PRINT` | hyprshot fullscreen → file |
| `CTRL + SHIFT + S` | hyprshot region → swappy (annotate) |
| `CTRL + SHIFT + X` | grim+slurp → file + copy path |

### Clipboard & session

| Binding | Action |
|---------|--------|
| `SUPER + SHIFT + V` | Clipboard history picker (cliphist) |
| `SUPER + SHIFT + Q` | wlogout menu |
| `SUPER + SHIFT + M` | Exit Hyprland |
| `SUPER + Delete` | Lock screen (hyprlock) |

### Hardware keys

Volume, brightness, media keys đều được bind qua `XF86*` → `wpctl` / `brightnessctl` / `playerctl`.

---

## Scripts

Tất cả trong `~/.config/hypr/scripts/`:

| Script | Mô tả |
|--------|-------|
| `terminal-picker.sh` | Fuzzel UI chọn terminal (5s countdown, default WezTerm) |
| `editor-picker.sh` | Fuzzel UI chọn editor (VS Code, Cursor, Zed, Nvim, Helix) |
| `wallpaper-picker.sh` | Fuzzel UI chọn wallpaper từ `~/Pictures/Wallpapers/` |
| `set-wallpaper.sh` | Set wallpaper + transition + regenerate matugen colors |
| `restore-wallpaper.sh` | Restore wallpaper gần nhất khi login |
| `toggle-theme.sh` | Đổi dark/light, sync GTK + waybar + swaync + alacritty + matugen |
| `toggle-hyprsunset.sh` | Bật/tắt night light (hyprsunset) |
| `cheatsheet.sh` | Hiển thị keybinding cheatsheet (kitty + bat + fzf) |
| `cliphist-store.sh` | Background watcher lưu clipboard history |
| `cliphist-pick.sh` | Fuzzel picker cho clipboard history |
| `cliphist-list.sh` | Format clipboard history cho picker |
| `waybar-monitor.sh` | Auto-restart waybar khi crash |
| `ags-media.sh` | Start/stop AGS media panel |
| `bluetooth-audio.sh` | Auto-connect Bluetooth audio on startup |

---

## Theming

- **Seed color**: `#c73e64`
- **Mode toggle**: `SUPER+F10`
- **State file**: `~/.config/theme-mode` (`dark` | `light`)
- **GTK**: `adw-gtk3-dark` / `adw-gtk3`
- **Symlinks** (quản lý bởi chezmoi templates + `run_after_apply-theme.sh`):
  - `waybar/style.css` → `style-{dark,light}.css`
  - `swaync/style.css` → `style-{dark,light}.css` (Catppuccin Mocha / Latte)
  - `alacritty/theme.toml` → `theme-{dark,light}.toml`
- **Matugen configs**: `dot_config/matugen/templates/` generate ra Hyprland, Waybar, Fuzzel, GTK, KDE colors

### Đổi wallpaper

```bash
# Qua keybind
SUPER + W

# Hoặc trực tiếp
bash ~/.config/hypr/scripts/set-wallpaper.sh /path/to/new.jpg
```

Script tự regenerate toàn bộ màu theo Material You từ wallpaper mới.

---

## Per-machine Configuration

### Machine detection

`machine` variable = hostname, set tự động bởi `.chezmoi.toml.tmpl`:

```toml
[data]
  machine = {{ .chezmoi.hostname | quote }}
```

### Monitor config

Mỗi máy có file monitor riêng, **không** track bởi chezmoi (mỗi hardware khác nhau):

```
~/.config/hypr/monitors-<hostname>.conf
```

- Nếu đã có file per-hostname trong source: `dot_config/hypr/monitors-<hostname>.conf` → chezmoi sync
- Nếu chưa có: `run_onchange_after_ensure-monitor-fallback.sh` tự tạo fallback `monitor = , preferred, auto, 1`
- Dùng `nwg-displays` hoặc edit thủ công để setup chính xác theo hardware

### Ví dụ: thêm máy `workstation`

```bash
# Trên máy mới có hostname "workstation"
hostnamectl set-hostname workstation
chezmoi init --apply git@github.com:bavanchun/dotconfig.git

# Fallback monitor config được tạo. Sửa theo hardware:
nwg-displays   # hoặc vim ~/.config/hypr/monitors-workstation.conf

# Nếu muốn commit config riêng cho máy này vào repo:
chezmoi cd
cp ~/.config/hypr/monitors-workstation.conf dot_config/hypr/
git add dot_config/hypr/monitors-workstation.conf
git commit -m "add: monitor config for workstation"
git push
```

---

## Repository Structure

```
~/.local/share/chezmoi/
├── README.md                                        ← bạn đang đọc
├── .chezmoi.toml.tmpl                               ← auto-render chezmoi config (machine = hostname)
├── .chezmoiignore                                   ← exclude patterns
├── .chezmoidata/
│   └── packages.yaml                                ← pacman + AUR package list
├── run_onchange_before_01-install-yay.sh            ← install yay AUR helper
├── run_onchange_before_02-install-packages.sh.tmpl  ← install all packages
├── run_onchange_after_enable-services.sh            ← enable systemd + set zsh
├── run_onchange_after_ensure-monitor-fallback.sh.tmpl
├── run_after_apply-theme.sh                         ← theme symlinks refresh
├── dot_zshrc                                        ← zsh config (zinit + starship + nvm + brew)
└── dot_config/
    ├── hypr/
    │   ├── hyprland.conf.tmpl                       ← TEMPLATE (edit .tmpl, không re-add)
    │   ├── hyprlock.conf.tmpl                       ← TEMPLATE (dùng $HOME via chezmoi)
    │   ├── hypridle.conf
    │   ├── hyprpaper.conf
    │   ├── monitors-<hostname>.conf                 ← per-machine, không track chung
    │   └── scripts/                                 ← custom scripts
    ├── waybar/
    │   ├── config.jsonc                             ← main waybar config
    │   ├── style-dark.css · style-light.css         ← symlinked → style.css
    │   └── scripts/                                 ← waybar module scripts
    ├── matugen/
    │   ├── config.toml                              ← template mappings
    │   └── templates/                               ← templates cho hypr/waybar/gtk/kde
    ├── alacritty/
    │   ├── theme-dark.toml · theme-light.toml       ← symlinked → theme.toml
    │   └── alacritty.toml
    ├── rofi/ · fuzzel/ · swaync/ · wlogout/         ← menu/notify tools
    ├── kitty/ · wezterm/                            ← alt terminals
    ├── ags/                                         ← AGS GTK4 shell (media panel)
    ├── quickshell/                                  ← Quickshell configs
    ├── nvim/                                        ← LazyVim setup
    ├── tmux/
    └── starship.toml
```

### File prefix convention (chezmoi)

| Prefix | Nghĩa |
|--------|-------|
| `dot_` | Đổi thành `.` khi apply (`dot_config/` → `.config/`) |
| `executable_` | Set execute bit khi apply |
| `symlink_` | Tạo symlink (nội dung file = target path) |
| `*.tmpl` | Go template, render trước khi apply |
| `run_once_*` | Chạy 1 lần duy nhất |
| `run_onchange_*` | Chạy lại khi content thay đổi (hash-based) |
| `run_before_*` / `run_after_*` | Chạy trước/sau khi apply files |

---

## Daily Workflow

**Quy tắc vàng**: KHÔNG edit trực tiếp `~/.config/<app>/...`, LUÔN edit trong chezmoi source.

### Sửa một config

```bash
# 1. Edit trong source
vim ~/.local/share/chezmoi/dot_config/waybar/config.jsonc

# 2. Apply sang ~/.config/
chezmoi apply

# 3. Reload app nếu cần
# waybar: pkill -SIGUSR2 waybar
# hyprland: hyprctl reload

# 4. Commit + push
chezmoi cd
git add .
git commit -m "feat(waybar): mô tả thay đổi"
git push
```

### Sửa template (`.tmpl`)

**Không** dùng `chezmoi re-add` cho file `.tmpl` — nó sẽ ghi đè template bằng rendered output. Luôn edit `.tmpl` thủ công.

### Sửa theme (dark/light)

Toggle runtime: `SUPER+F10`.

Đổi seed color: edit `dot_config/matugen/config.toml` hoặc dùng matugen hex mode.

### Thêm/bỏ package

```bash
vim ~/.local/share/chezmoi/.chezmoidata/packages.yaml
chezmoi apply   # sẽ re-run install script vì hash đã đổi
chezmoi cd
git add .chezmoidata/packages.yaml
git commit -m "feat: add/remove <package>"
git push
```

---

## Customization

### Đổi seed color

```toml
# dot_config/matugen/config.toml (nếu cấu hình ở đó)
# hoặc chạy trực tiếp:
matugen color hex "#yourhex" -m dark
```

Chạy lại `set-wallpaper.sh` hoặc `toggle-theme.sh` để reload.

### Đổi default terminal

Sửa `$terminal` trong `dot_config/hypr/hyprland.conf.tmpl`:

```
$terminal = wezterm   # hoặc kitty, alacritty
```

### Đổi default app launcher

```
$menu = rofi -show drun   # hoặc fuzzel
```

### Thêm keybinding

Edit `dot_config/hypr/hyprland.conf.tmpl`, section `bind = ...`, rồi `chezmoi apply && hyprctl reload`.

### Per-host override

Dùng chezmoi conditional trong `.tmpl` files:

```
{{ if eq .machine "laptop" }}
# laptop-specific
{{ else if eq .machine "workstation" }}
# workstation-specific
{{ end }}
```

---

## Troubleshooting

### `chezmoi apply` báo "config file template has changed"

Chạy `chezmoi init` không kèm URL để regenerate `~/.config/chezmoi/chezmoi.toml` từ template mới.

### Waybar không hiện sau khi apply

```bash
pkill waybar
bash ~/.config/hypr/scripts/waybar-monitor.sh restart
```

### Theme không sync sau toggle

```bash
# Regenerate symlinks thủ công
bash ~/.local/share/chezmoi/run_after_apply-theme.sh

# Hoặc refresh waybar/swaync
pkill -SIGUSR2 waybar
swaync-client --reload-css
```

### Matugen colors file không generate

```bash
# Đảm bảo wallpaper đã set
matugen image ~/.config/wallpaper-current -m dark
```

### `chezmoi apply` fail vì sudo cần TTY

Bootstrap scripts (`run_onchange_before_*`) cần sudo. Chạy từ terminal thực (có TTY) hoặc pre-cache sudo:

```bash
sudo -v && chezmoi apply
```

### Monitor config không khớp

```bash
# Regenerate bằng nwg-displays
nwg-displays

# Hoặc edit trực tiếp
vim ~/.config/hypr/monitors-$(hostname).conf
hyprctl reload
```

### Hyprland config reload failed

```bash
# Check syntax
hyprctl reload

# Full restart nếu sửa permission/ecosystem blocks
hyprctl dispatch exit
# (logout/login)
```

---

## Credits

- [Hyprland](https://hyprland.org/) — dynamic tiling Wayland compositor
- [chezmoi](https://www.chezmoi.io/) — dotfiles manager
- [matugen](https://github.com/InioX/matugen) — Material You color generation
- [Waybar](https://github.com/Alexays/Waybar) — customizable Wayland bar
- [end-4 illogical-impulse](https://github.com/end-4/dots-hyprland) — inspiration cho AGS widgets
- [Catppuccin](https://github.com/catppuccin) — swaync theme

---

## License

Personal dotfiles — use at your own risk. Fork, copy, remix tự do.
