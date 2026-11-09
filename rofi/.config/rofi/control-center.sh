#!/usr/bin/env bash

set -u

menu() {
    printf '%s\n' "$@" | rofi -dmenu -i -p "󰒓 Control Center" -theme ~/.config/rofi/dashboard.rasi
}

wifi_state=$(nmcli radio wifi 2>/dev/null || printf 'unknown')
wifi_name=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1 == "yes" {print substr($0, 5); exit}')
bluetooth_state=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2; exit}')
brightness=$(brightnessctl -m 2>/dev/null | cut -d, -f4 || printf '?')
volume=$(pamixer --get-volume 2>/dev/null || printf '?')
muted=$(pamixer --get-mute 2>/dev/null || printf 'false')
notifications=$(dunstctl is-paused 2>/dev/null || printf 'false')

[[ -n "$wifi_name" ]] || wifi_name="Not connected"
[[ -n "$bluetooth_state" ]] || bluetooth_state="unknown"

if [[ "$muted" == true ]]; then
    audio_label="Muted"
else
    audio_label="${volume}%"
fi

if [[ "$notifications" == true ]]; then
    notification_label="Paused"
else
    notification_label="On"
fi

choice=$(menu \
    "󰤨  Wi-Fi ${wifi_state}: ${wifi_name}" \
    "󰂯  Bluetooth: ${bluetooth_state}" \
    "󰕾  Audio: ${audio_label}" \
    "󰃠  Brightness: ${brightness}" \
    "󰂚  Notifications: ${notification_label}" \
    "󰂜  Notification history" \
    "󰌾  Lock screen") || exit 0

case "$choice" in
    "󰤨"*)
        if [[ "$wifi_state" == enabled ]]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
            setsid -f ~/.config/rofi/wifi.sh >/dev/null 2>&1
        fi
        ;;
    "󰂯"*)
        if [[ "$bluetooth_state" == yes ]]; then
            bluetoothctl power off
        else
            bluetoothctl power on
            setsid -f blueman-manager >/dev/null 2>&1
        fi
        ;;
    "󰕾"*)
        audio_choice=$(menu \
            "󰕾  Volume +5%" \
            "󰕾  Volume -5%" \
            "󰝟  Toggle mute" \
            "󰓃  Open audio mixer") || exit 0
        case "$audio_choice" in
            "󰕾  Volume +5%") pamixer -i 5 ;;
            "󰕾  Volume -5%") pamixer -d 5 ;;
            "󰝟"*) pamixer -t ;;
            "󰓃"*) setsid -f pavucontrol >/dev/null 2>&1 ;;
        esac
        ;;
    "󰃠"*)
        brightness_choice=$(menu \
            "󰃠  Brightness +5%" \
            "󰃠  Brightness -5%" \
            "󰃠  Brightness 25%" \
            "󰃠  Brightness 50%" \
            "󰃠  Brightness 75%" \
            "󰃠  Brightness 100%") || exit 0
        case "$brightness_choice" in
            *"+5%") brightnessctl -q set +5% ;;
            *"-5%") brightnessctl -q set 5%- ;;
            *"25%") brightnessctl -q set 25% ;;
            *"50%") brightnessctl -q set 50% ;;
            *"75%") brightnessctl -q set 75% ;;
            *"100%") brightnessctl -q set 100% ;;
        esac
        ;;
    "󰂚"*)
        dunstctl set-paused toggle
        ;;
    "󰂜"*)
        history=$(dunstctl history 2>/dev/null | python -c '
import json, sys
try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, TypeError):
    data = []
for item in data:
    summary = item.get("summary", "")
    body = item.get("body", "").replace("\n", " ")
    print(f"{summary}: {body}" if body else summary)
' 2>/dev/null)
        if [[ -n "$history" ]]; then
            selected=$(printf '%s\n' "$history" | rofi -dmenu -i -p "󰂜 Notification history" -theme ~/.config/rofi/dashboard.rasi) || exit 0
            [[ -n "$selected" ]] && dunstctl history-pop >/dev/null 2>&1
        else
            notify-send "Notification history" "No saved notifications."
        fi
        ;;
    "󰌾"*)
        exec ~/.config/i3/lockscreen.sh
        ;;
esac
