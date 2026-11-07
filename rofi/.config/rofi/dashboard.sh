#!/usr/bin/env bash
# =============================================================================
# Torray Dash — Interactive Quick Control Center (DankLinux Style Popup)
# =============================================================================

vol=$(pamixer --get-volume 2>/dev/null || echo "0")
mute=$(pamixer --get-mute 2>/dev/null || echo "false")
[ "$mute" = "true" ] && vol_label="Muted" || vol_label="${vol}%"

bright=$(brightnessctl -m 2>/dev/null | cut -d, -f4 || echo "100%")
ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2)
[ -z "$ssid" ] && ssid="Offline"
bat=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "100")

options=(
  "󰍉  Cari Aplikasi (Spotlight)"
  "󰤨  Wi-Fi: ${ssid}"
  "󰕾  Audio: ${vol_label} (Klik: Mixer)"
  "󰃠  Layar: ${bright} (Klik: Ubah Kecerahan)"
  "󰸉  Ganti Gaya Wallpaper Desktop"
  "󰂯  Bluetooth Manager"
  "󰹑  Ambil Screenshot Area"
  "󰌌  Cari Keybindings & Shortcut"
  "󰻠  System Monitor (btop) • Bat ${bat}%"
  "󰐥  Power Menu"
)

chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "󰣇 Torray Dash" -theme ~/.config/rofi/dashboard.rasi)

case "$chosen" in
  *"Cari Aplikasi"*)
    rofi -show drun -show-icons
    ;;
  *"Wi-Fi:"*)
    ~/.config/rofi/wifi.sh
    ;;
  *"Audio:"*)
    pavucontrol
    ;;
  *"Layar:"*)
    ~/.config/polybar/scripts/hw-action.sh bright-cycle
    ;;
  *"Ganti Gaya Wallpaper"*)
    ~/.config/polybar/scripts/wallpaper-cycle.sh
    ;;
  *"Bluetooth"*)
    blueman-manager
    ;;
  *"Screenshot"*)
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
      grim -g "$(slurp)" - | swappy -f -
    else
      flameshot gui
    fi
    ;;
  *"Keybindings"*)
    ~/.config/rofi/keybindings.sh
    ;;
  *"System Monitor"*)
    wezterm start -- btop
    ;;
  *"Power Menu"*)
    ~/.config/rofi/powermenu.sh
    ;;
esac
