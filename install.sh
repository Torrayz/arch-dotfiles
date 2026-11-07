#!/usr/bin/env bash
# =============================================================================
# Automated Installer for Torray Arch Dotfiles (Catppuccin Mocha)
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "󰣇 Memastikan izin eksekusi script..."
chmod +x polybar/.config/polybar/launch.sh \
         polybar/.config/polybar/scripts/*.sh \
         polybar/.config/polybar/scripts/*.py \
         rofi/.config/rofi/*.sh

echo "󰣇 Memasang symlink konfigurasi dengan GNU Stow..."
PACKAGES=(
  alacritty btop dunst fastfetch foot gtk i3 kitty mako
  nvim picom polybar rofi starship sway thunar tmux vscode
  waybar wezterm zsh
)

for pkg in "${PACKAGES[@]}"; do
  if [ -d "$pkg" ]; then
    stow --restow --target="$HOME" "$pkg"
  fi
done

echo "✅ Selesai! Tekan Super+Shift+R (i3) atau Super+Shift+C (Sway) untuk memuat ulang."
