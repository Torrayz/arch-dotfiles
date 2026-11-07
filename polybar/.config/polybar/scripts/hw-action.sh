#!/usr/bin/env bash
# =============================================================================
# Interactive Brightness & Volume Actions with OSD Notification
# =============================================================================

case "${1:-}" in
    bright-cycle)
        cur=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        if [ "$cur" -lt 35 ]; then
            next=50
        elif [ "$cur" -lt 65 ]; then
            next=75
        elif [ "$cur" -lt 90 ]; then
            next=100
        else
            next=25
        fi
        brightnessctl -q set "${next}%"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1500 "󰃠 Brightness" "Kecerahan layar: ${next}%"
        ;;
    bright-up)
        brightnessctl -q set +5%
        cur=$(brightnessctl -m | cut -d, -f4)
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰃠 Brightness" "Kecerahan: ${cur}"
        ;;
    bright-down)
        brightnessctl -q set 5%-
        cur=$(brightnessctl -m | cut -d, -f4)
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰃠 Brightness" "Kecerahan: ${cur}"
        ;;
    vol-toggle)
        pamixer -t
        if [ "$(pamixer --get-mute)" = "true" ]; then
            notify-send -h string:x-canonical-private-synchronous:osd -t 1500 "󰝟 Audio Muted" "Suara dinonaktifkan"
        else
            vol=$(pamixer --get-volume)
            notify-send -h string:x-canonical-private-synchronous:osd -t 1500 "󰕾 Audio Active" "Volume: ${vol}%"
        fi
        ;;
    bat-info)
        status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
        cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
        notify-send -t 3500 "󰁹 Status Baterai (${cap}%)" "Mode: ${status}"
        ;;
esac
