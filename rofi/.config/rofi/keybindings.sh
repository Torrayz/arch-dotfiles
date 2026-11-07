#!/usr/bin/env bash
# =============================================================================
# Interactive Keybindings Search & Launcher (Rofi) — Torray Custom Arch Setup
# =============================================================================

entries=(
  "󰍉  Super + Space             │ Cari & Buka Aplikasi (Spotlight Search)"
  "󰆍  Super + T / Super + Enter │ Buka Terminal WezTerm (Ada Tombol [+] & [x] Tab)"
  "󰌌  Super + / atau Super + ?  │ Buka Pencarian Keybindings Ini (atau Super+Ctrl+K)"
  "󰨞  Super + C                 │ Buka Code Editor (VS Code)"
  "󰉋  Super + E                 │ Buka File Manager (Thunar)"
  "󰈹  Super + B                 │ Buka Browser (Firefox)"
  "󰅌  Super + V                 │ Riwayat Clipboard (Copy-Paste History)"
  "󰻠  Super + M / Ctrl+Alt+Del  │ Buka System Monitor & Process List (btop)"
  "󰅖  Super + Q                 │ Tutup Jendela / Aplikasi Aktif"
  "󰊓  Super + F                 │ Layar Penuh (Fullscreen Toggle)"
  "󰖲  Super + Shift + T         │ Ubah Jendela Jadi Mengambang (Floating Toggle)"
  "󰓩  Super + W                 │ Mode Tabbed / Group Jendela"
  "󰤼  Super + R                 │ Ubah Arah Split Jendela (Horizontal / Vertikal)"
  "󰩨  Super + Ctrl + Panah      │ Perbesar / Perkecil Ukuran Jendela Langsung"
  "󰁍  Super + Panah / H,J,K,L   │ Pindah Fokus Antar Jendela"
  "ccf Super + Shift + Panah     │ Pindahkan Posisi Jendela"
  "󰎤  Super + 1 .. 9, 0         │ Pindah ke Workspace 1 - 10"
  "󰎧  Super + Shift + 1 .. 9, 0 │ Pindahkan Jendela ke Workspace 1 - 10"
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
