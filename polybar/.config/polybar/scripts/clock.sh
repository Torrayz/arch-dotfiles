#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Clock Pill (Mutual-Exclusion Accordion)
# =============================================================================

STATE_FILE="/tmp/bar_clock_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        rm -f /tmp/bar_sysinfo_expanded /tmp/bar_net_expanded /tmp/bar_power_expanded
        touch "$STATE_FILE"
    fi
    pkill -RTMIN+9 waybar 2>/dev/null || true
    exit 0
fi

if [ -f "$STATE_FILE" ]; then
    date "+󰃭  %a, %d %b %Y   •   󰥔  %H:%M:%S"
else
    date "+󰥔  %H:%M"
fi
