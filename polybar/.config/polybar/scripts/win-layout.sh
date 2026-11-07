#!/usr/bin/env bash
# =============================================================================
# Smart Window Size & Floating Controller (S / M / L / PiP / Tiling)
# Applies the S/M/L concept to ANY active application via Navbar or Super+Z!
# =============================================================================

STATE_FILE="/tmp/bar_win_size_mode"

run_wm() {
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        swaymsg "$@" >/dev/null 2>&1
    else
        i3-msg "$@" >/dev/null 2>&1
    fi
}

case "${1:-}" in
    status)
        mode=$(cat "$STATE_FILE" 2>/dev/null || echo "Full")
        echo "󰊓 ${mode}"
        ;;
    cycle)
        cur=$(cat "$STATE_FILE" 2>/dev/null || echo "Full")
        case "$cur" in
            Full) "$0" small ;;
            S)    "$0" medium ;;
            M)    "$0" large ;;
            L)    "$0" tile ;;
            *)    "$0" small ;;
        esac
        ;;
    toggle-float)
        is_float=$(i3-msg -t get_tree 2>/dev/null | python3 -c '
import sys, json
def find_focused(n):
    if n.get("focused"):
        print(n.get("floating", ""))
        return True
    for c in n.get("nodes", []) + n.get("floating_nodes", []):
        if find_focused(c): return True
find_focused(json.load(sys.stdin))
' 2>/dev/null)
        if [[ "$is_float" == *"on"* ]]; then
            "$0" tile
        else
            "$0" medium
        fi
        ;;
    small)
        echo "S" > "$STATE_FILE"
        run_wm "sticky disable, floating enable, resize set 580 370, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: S (Compact)" "580x370 Mengambang di Tengah"
        ;;
    medium)
        echo "M" > "$STATE_FILE"
        run_wm "sticky disable, floating enable, resize set 900 540, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: M (Sedang)" "900x540 Mengambang di Tengah"
        ;;
    large)
        echo "L" > "$STATE_FILE"
        run_wm "sticky disable, floating enable, resize set 1220 680, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: L (Besar)" "1220x680 Mengambang di Tengah"
        ;;
    pip)
        echo "PiP" > "$STATE_FILE"
        run_wm "floating enable, sticky enable, resize set 460 280, move position 890 470"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1500 "󰹙 Mode PiP (Selalu di Atas)" "Mengambang di pojok kanan bawah di semua workspace"
        ;;
    tile)
        echo "Full" > "$STATE_FILE"
        run_wm "sticky disable, floating disable"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: Full (Tiling)" "Susunan rapi penuh otomatis"
        ;;
    grow-both)
        run_wm "resize grow width 60 px or 6 ppt, resize grow height 40 px or 6 ppt"
        ;;
    shrink-both)
        run_wm "resize shrink width 60 px or 6 ppt, resize shrink height 40 px or 6 ppt"
        ;;
    menu)
        options=(
            "󰊓  Ukuran S — Compact Mengambang (580x370)       [Super+Alt+1]"
            "󰊓  Ukuran M — Sedang Mengambang (900x540)        [Super+Alt+2]"
            "󰊓  Ukuran L — Besar Mengambang (1220x680)        [Super+Alt+3]"
            "󰹙  Mode PiP — Selalu di Atas Pojok Kanan Bawah   [Super+Alt+4]"
            "󰤼  Ukuran Full — Kembali ke Tiling Rapi Penuh    [Super+Alt+0]"
        )
        chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "󰊓 Ukuran Aplikasi (S/M/L)" -theme ~/.config/rofi/keybinds.rasi)
        case "$chosen" in
            *"Ukuran S"*)    "$0" small ;;
            *"Ukuran M"*)    "$0" medium ;;
            *"Ukuran L"*)    "$0" large ;;
            *"Mode PiP"*)    "$0" pip ;;
            *"Ukuran Full"*) "$0" tile ;;
        esac
        ;;
esac
