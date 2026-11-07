#!/usr/bin/env bash
# =============================================================================
# Live Navbar Music & Animated Visualizer Pill (Ultra-Lightweight Single-Call)
# - Single playerctl query + pure bash builtins (zero cat/subshell forks)
# - Only appears in the center navbar when music is actively Playing
# =============================================================================

FRAME_FILE="/tmp/bar_media_frame"

case "${1:-}" in
    --hub)
        setsid -f ~/.config/polybar/scripts/torray-hub.py --music >/dev/null 2>&1
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

IFS='|' read -r status title < <(playerctl metadata --format '{{status}}|{{title}}' 2>/dev/null)

if [ "$status" = "Playing" ]; then
    frames=("▂▄▆█" "▄▆█▃" "▆█▄▂" "▃▇▄" "▅▃▆█" "▃▆▄▂")
    idx=0
    [ -r "$FRAME_FILE" ] && read -r idx < "$FRAME_FILE"
    idx=$(( (idx + 1) % ${#frames[@]} ))
    printf '%s\n' "$idx" > "$FRAME_FILE"
    eq="${frames[$idx]}"

    title="${title:-Playing}"
    if [ "${#title}" -gt 16 ]; then
        title="${title:0:15}…"
    fi
    printf '󰎆 %s %s\n' "$eq" "$title"
else
    printf '\n'
fi
