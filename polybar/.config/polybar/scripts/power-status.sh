#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Power / Battery Pill
# =============================================================================

STATE_FILE="/tmp/bar_power_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi
    pkill -RTMIN+11 waybar 2>/dev/null || true
    exit 0
fi

ac=$(cat /sys/class/power_supply/AC0/online 2>/dev/null || echo "1")
cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "")

if [ -n "$cap" ]; then
    if [ -f "$STATE_FILE" ]; then
        status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "AC")
        echo "󰁹 ${cap}% (${status})"
    else
        echo "󰁹 ${cap}%"
    fi
else
    if [ "$ac" = "1" ]; then
        if [ -f "$STATE_FILE" ]; then
            echo "󰚥 AC Plugged"
        else
            echo "󰚥"
        fi
    else
        echo "󰁹 Bat"
    fi
fi
