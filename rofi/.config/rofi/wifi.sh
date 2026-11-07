#!/usr/bin/env bash
# =============================================================================
# Floating Wi-Fi Quick Menu (Rofi)
# =============================================================================

notify-send -t 1500 "󰤨 Wi-Fi" "Memindai jaringan Wi-Fi..."
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d" | awk '!seen[$0]++')

connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
    toggle="󰤭  Matikan Wi-Fi"
else
    toggle="󰤨  Nyalakan Wi-Fi"
fi

chosen_network=$(echo -e "$toggle\n$wifi_list" | rofi -dmenu -i -p "󰤨 Wi-Fi" -theme ~/.config/rofi/dashboard.rasi)
[ -z "$chosen_network" ] && exit 0

if [ "$chosen_network" = "󰤨  Nyalakan Wi-Fi" ]; then
    nmcli radio wifi on
    notify-send "󰤨 Wi-Fi" "Wi-Fi dinyalakan"
elif [ "$chosen_network" = "󰤭  Matikan Wi-Fi" ]; then
    nmcli radio wifi off
    notify-send "󰤭 Wi-Fi" "Wi-Fi dimatikan"
else
    read -r chosen_id <<< "${chosen_network:3}"
    if nmcli connection show | grep -q "$chosen_id"; then
        nmcli connection up id "$chosen_id" && notify-send "󰤨 Terhubung" "$chosen_id"
    else
        wifi_password=$(rofi -dmenu -p " Password $chosen_id" -theme ~/.config/rofi/dashboard.rasi)
        [ -n "$wifi_password" ] && nmcli device wifi connect "$chosen_id" password "$wifi_password" && notify-send "󰤨 Terhubung" "$chosen_id"
    fi
fi
