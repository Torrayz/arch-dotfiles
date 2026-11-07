#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Wi-Fi Pill (Click to Toggle Icon <-> SSID + IP)
# =============================================================================

STATE_FILE="/tmp/bar_net_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi
    pkill -RTMIN+10 waybar 2>/dev/null || true
    exit 0
fi

ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2)

if [ -z "$ssid" ]; then
    echo "󰤭"
    exit 0
fi

if [ -f "$STATE_FILE" ]; then
    ip=$(ip -4 -br addr show wlp3s0 2>/dev/null | awk '{print $3}' | cut -d/ -f1)
    echo "󰤨 ${ssid} (${ip:-connected})"
else
    echo "󰤨"
fi
