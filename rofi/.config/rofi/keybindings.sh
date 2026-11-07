#!/usr/bin/env bash
# =============================================================================
# Interactive Keybindings Search & Launcher (Rofi) — Torray Custom Arch Setup
# =============================================================================

entries=(
  "󰣇  Super + N                 │ Buka Torray Hub Plugin (Slider Audio/Layar, Musik, Wallpaper)"
  "󰎆  Super + P                 │ Buka Plugin Music Player & Live Spectrum Visualizer"
  "󰸉  Super + Shift + W         │ Buka Studio Wallpaper Visual (Pilih Gambar & Preview)"
  "󰍉  Super + Space             │ Cari & Buka Aplikasi (Spotlight Search)"
  "󰆍  Super + T / Super + Enter │ Buka Terminal WezTerm (Ada Tombol [+] & [x] Tab)"
  "󰌌  Super + / atau Super + ?  │ Buka Pencarian Keybindings Ini (atau Super+Ctrl+K)"
  "󰨞  Super + C                 │ Buka Code Editor (VS Code)"
  "󰉋  Super + E                 │ Buka File Manager (Thunar)"
  "󰈹  Super + B                 │ Buka Browser (Firefox)"
  "󰅌  Super + V                 │ Buka Visual Clipboard History (Teks & Screenshot seperti Windows)"
  "󰊓  Super + Z                 │ Ubah Ukuran Aplikasi Aktif: S (Compact) -> M -> L -> Full"
  "󰻠  Super + M / Ctrl+Alt+Del  │ Buka System Monitor & Process List (btop)"
  "󰅖  Super + Q                 │ Tutup Jendela / Aplikasi Aktif"
  "󰊓  Super + F                 │ Layar Penuh (Fullscreen Toggle)"
  "󰖲  Super + Shift + Space / T │ Mengambang di Atas Aplikasi Lain (Toggle Float Tengah)"
  "󰖲  Super + Ctrl + Space      │ Menu Pilihan Ukuran Otomatis (Mini, Sedang, Besar, PiP, Tiling)"
  "󰩨  Super + Ctrl + Shift +  │ Atur Ukuran Lebar & Tinggi Aplikasi (Bisa juga Super+Ctrl+Panah)"
  "󰊓  Super + [=] atau [-]      │ Perbesar / Perkecil Ukuran Aplikasi Sekaligus"
  "󰘕  Super + Alt + 1 / 2 / 3   │ Otomatis Ubah Ukuran: [1] Kecil  [2] Sedang  [3] Besar"
  "󰹙  Super + Alt + 4 / 0       │ [4] Mode Selalu di Atas (PiP Pojok)   [0] Kembali ke Tiling"
  "󰓩  Super + W                 │ Mode Tabbed / Group Jendela"
  "󰤼  Super + R                 │ Ubah Arah Split Jendela (Horizontal / Vertikal)"
  "󰁍  Super + Panah / H,J,K,L   │ Pindah Fokus Antar Jendela"
  "󰁍  Super + Shift + Panah     │ Geser Posisi Jendela (Saat Mengambang / Tiling)"
  "󰎤  Super + 1 .. 9, 0         │ Pindah ke Workspace 1 - 10"
  "󰎧  Super + Shift + 1 .. 9, 0 │ Pindahkan Aplikasi + Kamera Geser ke Workspace 1 - 10"
  "󰹑  F10 / Print / Super+Alt+S │ Screenshot Area Pilih & Edit"
  "󰗊  Super + G                 │ Terjemahkan Teks yang Diblok ke Bahasa Indonesia"
  "󰗊  Super + Shift + G         │ Terjemahkan Teks yang Diblok ke Bahasa Inggris"
  "󰌾  Super + Alt + L / Ctrl+L  │ Kunci Layar (Lock Screen)"
  "󰐥  Super + Shift + E         │ Power Menu (Lock, Suspend, Logout, Restart, Shutdown)"
  "─────────────────────────────┼────────────────────────────────────────────────────"
  "󰓩  Ctrl + T (di Terminal)    │ Tambah Tab Terminal Baru (atau klik tombol [+] di atas)"
  "󰅙  Ctrl + W (di Terminal)    │ Tutup Tab Terminal Aktif (atau klik tombol [x] di tab)"
  "󰒭  Ctrl + Tab (di Terminal)  │ Pindah ke Tab Terminal Berikutnya"
  "󰤼  Ctrl + Shift + D / E      │ Split Layar Terminal Kanan-Kiri / Atas-Bawah"
  "ccf Ctrl + [+] / [-]          │ Perbesar / Perkecil Ukuran Font Terminal"
  "  ff / top / lg / vs / v    │ Perintah Cepat Zsh: Fastfetch, btop, Lazygit, VSCode, Neovim"
)

chosen="$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -p "󰌌 Cari Keybinding" -theme ~/.config/rofi/keybinds.rasi)"

case "$chosen" in
  *"Super + N"*)
    ~/.config/polybar/scripts/torray-hub.py --dash &
    ;;
  *"Super + P"*)
    ~/.config/polybar/scripts/torray-hub.py --music &
    ;;
  *"Super + Shift + W"*)
    ~/.config/polybar/scripts/torray-hub.py --wall &
    ;;
  *"Super + V"*)
    ~/.config/polybar/scripts/torray-clip.py --popup &
    ;;
  *"Super + Z"*)
    ~/.config/polybar/scripts/win-layout.sh cycle &
    ;;
  *"Super + Space"*)
    rofi -show drun -show-icons
    ;;
  *"Super + T"*)
    wezterm start
    ;;
  *"Super + C"*)
    code
    ;;
  *"Super + E"*)
    thunar
    ;;
  *"Super + B"*)
    firefox
    ;;
  *"Super + M"*)
    wezterm start -- btop
    ;;
  *"Super + Shift + E"*)
    ~/.config/rofi/powermenu.sh
    ;;
esac
