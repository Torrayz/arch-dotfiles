#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Clock Pill (Zero-Fork Bash Builtin printf strftime)
# =============================================================================

STATE_FILE="/tmp/bar_clock_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        rm -f /tmp/bar_sysinfo_expanded /tmp/bar_net_expanded /tmp/bar_power_expanded
        : > "$STATE_FILE"
    fi
    pkill -RTMIN+9 waybar 2>/dev/null || true
    exit 0
fi

if [ -f "$STATE_FILE" ]; then
    printf '󰃭  %(%a, %d %b %Y   •   󰥔  %H:%M:%S)T\n' -1
else
    printf '󰥔  %(%H:%M)T\n' -1
fi
