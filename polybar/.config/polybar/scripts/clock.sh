#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable Clock Pill (Click to Toggle Minimal <-> Full Date)
# =============================================================================

STATE_FILE="/tmp/bar_clock_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi
    pkill -RTMIN+9 waybar 2>/dev/null || true
    exit 0
fi

if [ -f "$STATE_FILE" ]; then
    date "+󰃭 %a, %d %b %Y  •  󰥔 %H:%M:%S"
else
    date "+󰥔 %H:%M"
fi
