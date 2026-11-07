#!/usr/bin/env bash
# =============================================================================
# Live Navbar Music & Animated Visualizer Pill (MPRIS / playerctl + Torray Hub)
# - Only appears in the center navbar when music is actively Playing!
# - Left-clicking opens Torray Hub (Music Tab) centered below the navbar!
# =============================================================================

FRAME_FILE="/tmp/bar_media_frame"

case "${1:-}" in
    --hub)
        ~/.config/polybar/scripts/torray-hub.py --music &
        exit 0
        ;;
    --play-pause)
        playerctl play-pause 2>/dev/null || true
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
esac

status=$(playerctl status 2>/dev/null || echo "")

# Only display the moving music equalizer when music is actively Playing!
if [ "$status" = "Playing" ]; then
    frames=("▂▄▆█" "▄▆█▃" "▆█▄▂" "▃▇▄" "▅▃▆█" "▃▆▄▂")
    idx=0
    [ -f "$FRAME_FILE" ] && idx=$(cat "$FRAME_FILE" 2>/dev/null || echo 0)
    idx=$(( (idx + 1) % ${#frames[@]} ))
    echo "$idx" > "$FRAME_FILE"
    eq="${frames[$idx]}"

    title=$(playerctl metadata xesam:title 2>/dev/null || echo "Playing")
    if [ "${#title}" -gt 16 ]; then
        title="${title:0:15}…"
    fi
    echo "󰎆 ${eq} ${title}"
else
    echo ""
fi
