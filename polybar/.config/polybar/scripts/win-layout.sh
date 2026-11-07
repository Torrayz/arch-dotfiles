#!/usr/bin/env bash
# =============================================================================
# Smart Window Size & Floating Controller (i3 & Sway)
# Controls active application size presets, floating-on-top, and sticky PiP
# =============================================================================

run_wm() {
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        swaymsg "$@" >/dev/null 2>&1
    else
        i3-msg "$@" >/dev/null 2>&1
    fi
}

case "${1:-}" in
    toggle-float)
        # Check if currently floating in i3/sway
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
            run_wm "sticky disable, floating disable"
            notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰖲 Mode Tiling" "Aplikasi kembali ke susunan otomatis"
        else
            run_wm "floating enable, resize set 900 540, move position center"
            notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰖲 Mengambang di Atas" "Ukuran: 900x540 (Super+Ctrl+Shift+Panah untuk ubah ukuran)"
        fi
        ;;
    small)
        run_wm "sticky disable, floating enable, resize set 560 360, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰖲 Mengambang Compact" "Ukuran aplikasi: 560x360 (Tengah)"
        ;;
    medium)
        run_wm "sticky disable, floating enable, resize set 880 530, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰖲 Mengambang Sedang" "Ukuran aplikasi: 880x530 (Tengah)"
        ;;
    large)
        run_wm "sticky disable, floating enable, resize set 1200 670, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰖲 Mengambang Besar" "Ukuran aplikasi: 1200x670 (Tengah)"
        ;;
    pip)
        run_wm "floating enable, sticky enable, resize set 460 280, move position 890 470"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1500 "󰹙 Selalu di Atas (PiP)" "Mengambang di pojok kanan bawah di semua workspace"
        ;;
    tile)
        run_wm "sticky disable, floating disable"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰤼 Mode Tiling" "Aplikasi diratakan kembali"
        ;;
    grow-both)
        run_wm "resize grow width 60 px or 6 ppt, resize grow height 40 px or 6 ppt"
        ;;
    shrink-both)
        run_wm "resize shrink width 60 px or 6 ppt, resize shrink height 40 px or 6 ppt"
        ;;
    menu)
        options=(
            "󰖲  Mengambang Sedang (880x530 di Tengah)         [Super+Shift+Space]"
            "󰊓  Mengambang Besar (1200x670 Hampir Penuh)       [Super+Alt+3]"
            "󰘕  Mengambang Compact / Kecil (560x360)           [Super+Alt+1]"
            "󰹙  Selalu di Atas / PiP Pojok Kanan Bawah         [Super+Alt+4]"
            "󰤼  Kembalikan ke Tiling Otomatis (Rapi Penuh)     [Super+Alt+0]"
        )
        chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "󰖲 Ukuran & Mode Jendela" -theme ~/.config/rofi/keybinds.rasi)
        case "$chosen" in
            *"Mengambang Sedang"*) "$0" medium ;;
            *"Mengambang Besar"*)  "$0" large ;;
            *"Mengambang Compact"*) "$0" small ;;
            *"Selalu di Atas"*)    "$0" pip ;;
            *"Tiling Otomatis"*)   "$0" tile ;;
        esac
        ;;
esac
