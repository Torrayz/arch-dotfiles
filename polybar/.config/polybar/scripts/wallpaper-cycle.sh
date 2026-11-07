#!/usr/bin/env bash
# =============================================================================
# Cycle Custom Wallpapers (Sway & i3)
# =============================================================================

DIR="$HOME/.config/sway"
STATE="/tmp/torray_wall_idx"
walls=("$DIR/wallpaper.png" "$DIR/wallpaper-aurora.png" "$DIR/wallpaper-cyber.png")
names=("Minimal Dot Matrix" "Catppuccin Aurora Glow" "Dank Cyber Grid")

idx=0
[ -f "$STATE" ] && idx=$(cat "$STATE")
idx=$(( (idx + 1) % ${#walls[@]} ))
echo "$idx" > "$STATE"

target="${walls[$idx]}"
label="${names[$idx]}"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    swaymsg output "*" bg "$target" fill
else
    feh --bg-fill "$target"
fi

notify-send -h string:x-canonical-private-synchronous:osd -t 2000 "󰸉 Wallpaper Diganti" "Gaya: ${label}"
