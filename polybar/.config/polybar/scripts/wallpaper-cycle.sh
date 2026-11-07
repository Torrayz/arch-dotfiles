#!/usr/bin/env bash
# =============================================================================
# Cycle Custom HD Wallpapers (Sway & i3) + Sync Default Wallpaper
# =============================================================================

DIR="$HOME/.config/sway/wallpapers"
STATE="/tmp/torray_wall_idx"
mapfile -t walls < <(find "$DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | sort)

if [ "${#walls[@]}" -eq 0 ]; then
    exit 0
fi

idx=0
[ -f "$STATE" ] && idx=$(<"$STATE")
idx=$(( (idx + 1) % ${#walls[@]} ))
printf '%s\n' "$idx" > "$STATE"

target="${walls[$idx]}"
fname="${target##*/}"
label="${fname%.*}"
cp -f "$target" "$HOME/.config/sway/wallpaper.png" 2>/dev/null || true

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    swaymsg output "*" bg "$target" fill
else
    DISPLAY="${DISPLAY:-:0}" feh --bg-fill "$target"
fi

notify-send -h string:x-canonical-private-synchronous:osd -t 1800 "󰸉 Wallpaper Diganti" "Tema: ${label}"
