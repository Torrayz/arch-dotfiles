#!/usr/bin/env bash

lock="󰌾  Kunci Layar"
logout="󰍃  Logout"
suspend="󰤄  Suspend"
reboot="󰜉  Restart"
shutdown="󰐥  Matikan Laptop"

chosen="$(printf "%s\n%s\n%s\n%s\n%s\n" "$lock" "$suspend" "$logout" "$reboot" "$shutdown" | rofi -dmenu -i -p "󰐥 Power Menu")"

case "$chosen" in
    "$lock")
        if [ -n "$WAYLAND_DISPLAY" ]; then
            swaylock -f -c 1e1e2e
        else
            i3lock -c 1e1e2e
        fi
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$logout")
        if [ -n "$WAYLAND_DISPLAY" ]; then
            swaymsg exit
        else
            i3-msg exit
        fi
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac
