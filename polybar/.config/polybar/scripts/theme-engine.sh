#!/usr/bin/env bash
# =============================================================================
# Torray Global Desktop Theme Engine (Polybar + i3/Sway + GTK Hub + Wallpaper)
# Themes: mocha | tokyo | sakura | emerald | cosmos | crimson
# =============================================================================

THEME="${1:-mocha}"
WALL_DIR="$HOME/.config/sway/wallpapers"
POLYBAR_CFG="$HOME/.config/polybar/config.ini"
ROFI_CFG="$HOME/.config/rofi/config.rasi"
I3_CFG="$HOME/.config/i3/config"
THEME_STATE="/tmp/torray_theme.json"

case "$THEME" in
    tokyo)
        NAME="Tokyo Cyber"
        ACCENT="#7aa2f7"
        SECOND="#2ac3de"
        CRUST="#0f111a"
        BASE="#1a1b26"
        WALL="11-tokyo-city-harbor.jpg"
        ;;
    sakura)
        NAME="Sakura Sunset"
        ACCENT="#f5c2e7"
        SECOND="#fab387"
        CRUST="#16111b"
        BASE="#231b2a"
        WALL="04-sakura-torii-gate.jpg"
        ;;
    emerald)
        NAME="Emerald Matrix"
        ACCENT="#a6e3a1"
        SECOND="#94e2d5"
        CRUST="#0d1512"
        BASE="#16241f"
        WALL="10-emerald-forest.jpg"
        ;;
    cosmos)
        NAME="Cosmos Gold"
        ACCENT="#fab387"
        SECOND="#f9e2af"
        CRUST="#14110f"
        BASE="#221d1a"
        WALL="02-black-hole-cosmos.jpg"
        ;;
    crimson)
        NAME="Crimson Abyss"
        ACCENT="#f38ba8"
        SECOND="#eba0ac"
        CRUST="#160f13"
        BASE="#24181f"
        WALL="08-hollow-knight.jpg"
        ;;
    mocha|*)
        THEME="mocha"
        NAME="Catppuccin Mocha"
        ACCENT="#cba6f7"
        SECOND="#89b4fa"
        CRUST="#11111b"
        BASE="#1e1e2e"
        WALL="01-japan-neon-alley.jpg"
        ;;
esac

# 1. Save active theme state for Torray Hub, Torray Clip & Workspaces
printf '{"id":"%s","name":"%s","accent":"%s","second":"%s","crust":"%s","base":"%s","wall":"%s"}\n' \
    "$THEME" "$NAME" "$ACCENT" "$SECOND" "$CRUST" "$BASE" "$WALL" > "$THEME_STATE"

# 2. Apply matching HD Wallpaper
if [ -f "$WALL_DIR/$WALL" ]; then
    cp -f "$WALL_DIR/$WALL" "$HOME/.config/sway/wallpaper.png" 2>/dev/null || true
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        swaymsg output "*" bg "$WALL_DIR/$WALL" fill >/dev/null 2>&1 || true
    else
        DISPLAY="${DISPLAY:-:0}" feh --bg-fill "$WALL_DIR/$WALL" >/dev/null 2>&1 || true
    fi
fi

# 3. Update Polybar [colors] & trigger instant live reload
if [ -f "$POLYBAR_CFG" ]; then
    CRUST_POLY="#cc${CRUST#\#}"
    BASE_POLY="#e6${BASE#\#}"
    sed -i \
        -e "s/^crust    = .*/crust    = ${CRUST_POLY}/" \
        -e "s/^base     = .*/base     = ${BASE_POLY}/" \
        -e "s/^mauve    = .*/mauve    = ${ACCENT}/" \
        -e "s/^blue     = .*/blue     = ${SECOND}/" \
        "$POLYBAR_CFG"
    polybar-msg cmd restart >/dev/null 2>&1 || true
fi

# 4. Update Rofi border & accent color
if [ -f "$ROFI_CFG" ]; then
    sed -i "s/accent: *#[0-9a-fA-F]\{6\};/accent: ${ACCENT};/g" "$ROFI_CFG" 2>/dev/null || true
fi

# 5. Update i3 focused window border color
if [ -f "$I3_CFG" ]; then
    sed -i "s/^set \$mauve .*/set \$mauve     ${ACCENT}/" "$I3_CFG" 2>/dev/null || true
    sed -i "s/^set \$crust .*/set \$crust     ${CRUST}/" "$I3_CFG" 2>/dev/null || true
    DISPLAY="${DISPLAY:-:0}" i3-msg reload >/dev/null 2>&1 || true
fi

notify-send -h string:x-canonical-private-synchronous:theme -t 1800 "󰸌 Tema Desktop Aktif" "${NAME} (${ACCENT})" 2>/dev/null || true
