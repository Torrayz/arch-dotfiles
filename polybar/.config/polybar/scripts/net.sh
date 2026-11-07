#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Wi-Fi Pill (Zero-Fork Sysfs Check when Collapsed)
# =============================================================================

STATE_FILE="/tmp/bar_net_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        rm -f /tmp/bar_sysinfo_expanded /tmp/bar_clock_expanded /tmp/bar_power_expanded
        : > "$STATE_FILE"
    fi
    pkill -RTMIN+10 waybar 2>/dev/null || true
    exit 0
fi

oper="down"
for iface in /sys/class/net/wl*/operstate; do
    if [ -r "$iface" ]; then
        read -r oper < "$iface"
        break
    fi
done

if [ "$oper" != "up" ]; then
    printf '󰤭 \n'
    exit 0
fi

if [ -f "$STATE_FILE" ]; then
    ssid=$(nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$1=="wifi" && $2=="connected" {print $3; exit}')
    ip=$(ip -4 -br addr show up 2>/dev/null | awk '/^wl/ {split($3,a,"/"); print a[1]; exit}')
    printf '󰤨  %s (%s)\n' "${ssid:-Wi-Fi}" "${ip:-OK}"
else
    printf '󰤨 \n'
fi
