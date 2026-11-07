#!/usr/bin/env bash
# =============================================================================
# Live Navbar Music & Animated Visualizer Pill (MPRIS / playerctl + Torray Hub)
# =============================================================================

FRAME_FILE="/tmp/bar_media_frame"

case "${1:-}" in
    --play-pause)
        status=$(playerctl status 2>/dev/null || echo "")
        if [ -n "$status" ]; then
            playerctl play-pause 2>/dev/null
        else
            ~/.config/polybar/scripts/torray-hub.py --music &
        fi
        exit 0
        ;;
    --next)
        playerctl next 2>/dev/null || true
        exit 0
        ;;
    --prev)
        playerctl previous 2>/dev/null || true
        exit 0
        ;;
    --hub)
        ~/.config/polybar/scripts/torray-hub.py --music &
        exit 0
        ;;
esac

status=$(playerctl status 2>/dev/null || echo "")

if [ "$status" = "Playing" ]; then
    frames=("▂▄▆█" "▄▆█▃" "▆█▄▂" "▃▇▄" "▅▃▆█" "▃▆▄▂")
    idx=0
    [ -f "$FRAME_FILE" ] && idx=$(cat "$FRAME_FILE" 2>/dev/null || echo 0)
    idx=$(( (idx + 1) % ${#frames[@]} ))
    echo "$idx" > "$FRAME_FILE"
    eq="${frames[$idx]}"

    title=$(playerctl metadata xesam:title 2>/dev/null || echo "Playing")
    # Keep title compact so it never collides on 1366x768
    if [ "${#title}" -gt 18 ]; then
        title="${title:0:17}…"
    fi
    echo "󰎆 ${eq} ${title}"
elif [ "$status" = "Paused" ]; then
    title=$(playerctl metadata xesam:title 2>/dev/null || echo "Paused")
    if [ "${#title}" -gt 14 ]; then
        title="${title:0:13}…"
    fi
    echo "󰏤 ${title}"
else
    echo "󰎆 Musik"
fi
