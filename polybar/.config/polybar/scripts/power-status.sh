#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Power / Battery Pill (Zero-Fork Pure Bash Builtins)
# =============================================================================

STATE_FILE="/tmp/bar_power_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        rm -f /tmp/bar_sysinfo_expanded /tmp/bar_clock_expanded /tmp/bar_net_expanded
        : > "$STATE_FILE"
    fi
    pkill -RTMIN+11 waybar 2>/dev/null || true
    exit 0
fi

ac="1"
[ -r /sys/class/power_supply/AC0/online ] && read -r ac < /sys/class/power_supply/AC0/online
cap=""
[ -r /sys/class/power_supply/BAT0/capacity ] && read -r cap < /sys/class/power_supply/BAT0/capacity

if [ -n "$cap" ]; then
    if [ -f "$STATE_FILE" ]; then
        status="AC"
        [ -r /sys/class/power_supply/BAT0/status ] && read -r status < /sys/class/power_supply/BAT0/status
        printf '󰁹  %s%% (%s)\n' "$cap" "$status"
    else
        printf '󰁹  %s%%\n' "$cap"
    fi
else
    if [ "$ac" = "1" ]; then
        if [ -f "$STATE_FILE" ]; then
            printf '󰚥  AC Mode\n'
        else
            printf '󰚥 \n'
        fi
    else
        printf '󰁹  Bat\n'
    fi
fi
