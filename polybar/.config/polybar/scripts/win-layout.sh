#!/usr/bin/env bash
# =============================================================================
# Smart Window Size & Maximize Controller (S / M / L / Full Navbar / Maks)
# - Super + F (toggle-max): Full layar di bawah Navbar (Navbar & Tab Browser tetap aman!)
# - Super + Shift + F (true-fullscreen): Full layar versi Maks (Sembunyikan Navbar)
# - Super + Z (cycle): Putar ukuran S -> M -> L -> Full
# =============================================================================

STATE_FILE="/tmp/bar_win_size_mode"

run_wm() {
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        swaymsg "$@" >/dev/null 2>&1
    else
        i3-msg "$@" >/dev/null 2>&1
    fi
}

get_win_info() {
    i3-msg -t get_tree 2>/dev/null | python3 -c '
import sys, json
tree = json.load(sys.stdin)
def walk(n, ws_nodes=None):
    if n.get("type") == "workspace":
        ws_nodes = n.get("nodes", [])
    if n.get("focused"):
        fl = n.get("floating", "auto_off")
        fs = n.get("fullscreen_mode", 0)
        r = n.get("rect", {})
        w = r.get("width", 0)
        h = r.get("height", 0)
        tiled_cnt = len(ws_nodes) if ws_nodes is not None else 1
        print(f"{fl}|{fs}|{w}|{h}|{tiled_cnt}")
        return True
    for c in n.get("nodes", []) + n.get("floating_nodes", []):
        if walk(c, ws_nodes): return True
walk(tree)
' 2>/dev/null
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
    toggle-max)
        # Super + F: Full di bawah Navbar (Navbar tetap terlihat & Browser tidak F11!)
        info=$(get_win_info)
        IFS='|' read -r fl fs w h tiled_cnt <<< "$info"
        cur_mode=$(cat "$STATE_FILE" 2>/dev/null || echo "Full")

        # 1. Jika sedang terjebak di Fullscreen Maks (tanpa navbar), kembalikan navbar dulu
        if [ "${fs:-0}" = "1" ]; then
            echo "Full" > "$STATE_FILE"
            run_wm "fullscreen disable, sticky disable, floating disable"
            notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: Full (Navbar Aktif)" "Kembali dari Fullscreen Maks"
            exit 0
        fi

        # 2. Jika sedang mengambang kecil/sedang/besar (S / M / L / PiP) -> Perbesar jadi Full di bawah Navbar!
        if [[ "$fl" == *"on"* ]] && [ "$cur_mode" != "Full" ]; then
            echo "Full" > "$STATE_FILE"
            if [ "${tiled_cnt:-1}" -gt 0 ]; then
                # Jika ada jendela lain di workspace, buat penuh menutupi di bawah navbar
                run_wm "fullscreen disable, sticky disable, floating enable, resize set 1356 723, move position 5 40"
            else
                run_wm "fullscreen disable, sticky disable, floating disable"
            fi
            notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: Full (Navbar Aktif)" "Penuh di bawah navbar (Super+Shift+F untuk Full Tanpa Navbar)"
            exit 0
        fi

        # 3. Jika sedang mengambang Full di atas jendela lain -> kembalikan ke susunan Tiling
        if [[ "$fl" == *"on"* ]] && [ "$cur_mode" = "Full" ]; then
            echo "Full" > "$STATE_FILE"
            run_wm "fullscreen disable, sticky disable, floating disable"
            notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰤼 Mode Tiling" "Kembali ke susunan bagi layar"
            exit 0
        fi

        # 4. Jika sedang Tiling bersama jendela lain -> Maksimalkan penuh di bawah Navbar!
        if [ "${tiled_cnt:-1}" -gt 1 ]; then
            echo "Full" > "$STATE_FILE"
            run_wm "fullscreen disable, sticky disable, floating enable, resize set 1356 723, move position 5 40"
            notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: Full (Navbar Aktif)" "Menutupi jendela lain tanpa menghilangkan Navbar"
        else
            # Jika hanya 1 jendela & sudah Full di bawah Navbar -> Toggle ke ukuran M (Sedang) agar berasa efek Restore-nya!
            "$0" medium
        fi
        ;;
    true-fullscreen)
        # Super + Shift + F: Full Layar Versi Maks (Menyembunyikan Navbar / Mode Bioskop)
        info=$(get_win_info)
        IFS='|' read -r fl fs w h tiled_cnt <<< "$info"
        if [ "${fs:-0}" = "1" ]; then
            echo "Full" > "$STATE_FILE"
            run_wm "fullscreen disable"
            notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Keluar Fullscreen Maks" "Navbar ditampilkan kembali"
        else
            echo "Maks" > "$STATE_FILE"
            run_wm "fullscreen enable"
            notify-send -h string:x-canonical-private-synchronous:osd -t 1400 "󰊓 Fullscreen Versi Maks" "Navbar disembunyikan (Tekan Super+F atau Super+Shift+F untuk kembali)"
        fi
        ;;
    toggle-float)
        info=$(get_win_info)
        IFS='|' read -r fl fs w h tiled_cnt <<< "$info"
        if [[ "$fl" == *"on"* ]]; then
            "$0" tile
        else
            "$0" medium
        fi
        ;;
    small)
        echo "S" > "$STATE_FILE"
        run_wm "fullscreen disable, sticky disable, floating enable, resize set 580 370, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: S (Compact)" "580x370 Mengambang di Tengah"
        ;;
    medium)
        echo "M" > "$STATE_FILE"
        run_wm "fullscreen disable, sticky disable, floating enable, resize set 900 540, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: M (Sedang)" "900x540 Mengambang di Tengah"
        ;;
    large)
        echo "L" > "$STATE_FILE"
        run_wm "fullscreen disable, sticky disable, floating enable, resize set 1220 680, move position center"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: L (Besar)" "1220x680 Mengambang di Tengah"
        ;;
    pip)
        echo "PiP" > "$STATE_FILE"
        run_wm "fullscreen disable, floating enable, sticky enable, resize set 460 280, move position 890 470"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1500 "󰹙 Mode PiP (Selalu di Atas)" "Mengambang di pojok kanan bawah di semua workspace"
        ;;
    tile)
        echo "Full" > "$STATE_FILE"
        run_wm "fullscreen disable, sticky disable, floating disable"
        notify-send -h string:x-canonical-private-synchronous:osd -t 1200 "󰊓 Ukuran Aplikasi: Full (Tiling)" "Susunan rapi penuh di bawah Navbar"
        ;;
    grow-both)
        run_wm "resize grow width 60 px or 6 ppt, resize grow height 40 px or 6 ppt"
        ;;
    shrink-both)
        run_wm "resize shrink width 60 px or 6 ppt, resize shrink height 40 px or 6 ppt"
        ;;
    menu)
        options=(
            "󰊓  Ukuran Full — Penuh di Bawah Navbar             [Super+F]"
            "󰊓  Ukuran S — Compact Mengambang (580x370)         [Super+Alt+1]"
            "󰊓  Ukuran M — Sedang Mengambang (900x540)          [Super+Alt+2]"
            "󰊓  Ukuran L — Besar Mengambang (1220x680)          [Super+Alt+3]"
            "󰹙  Mode PiP — Selalu di Atas Pojok Kanan Bawah     [Super+Alt+4]"
            "󰤼  Susunan Tiling — Bagi Layar Otomatis            [Super+Alt+0]"
            "󰊓  Fullscreen Versi Maks — Sembunyikan Navbar      [Super+Shift+F]"
        )
        chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "󰊓 Ukuran Aplikasi" -theme ~/.config/rofi/keybinds.rasi)
        case "$chosen" in
            *"Ukuran Full"*)           "$0" toggle-max ;;
            *"Ukuran S"*)              "$0" small ;;
            *"Ukuran M"*)              "$0" medium ;;
            *"Ukuran L"*)              "$0" large ;;
            *"Mode PiP"*)              "$0" pip ;;
            *"Susunan Tiling"*)        "$0" tile ;;
            *"Fullscreen Versi Maks"*) "$0" true-fullscreen ;;
        esac
        ;;
esac
