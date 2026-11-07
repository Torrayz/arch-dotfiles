#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Wi-Fi Pill (Instant <5ms query + Mutual Exclusion)
# =============================================================================

STATE_FILE="/tmp/bar_net_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        rm -f /tmp/bar_sysinfo_expanded /tmp/bar_clock_expanded /tmp/bar_power_expanded
        touch "$STATE_FILE"
    fi
    pkill -RTMIN+10 waybar 2>/dev/null || true
    exit 0
fi

ssid=$(nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$1=="wifi" && $2=="connected" {print $3; exit}')

if [ -z "$ssid" ]; then
    echo "󰤭 "
    exit 0
fi

if [ -f "$STATE_FILE" ]; then
    ip=$(ip -4 -br addr show wlp3s0 2>/dev/null | awk '{print $3}' | cut -d/ -f1)
    echo "󰤨  ${ssid} (${ip:-OK})"
else
    echo "󰤨 "
fi
