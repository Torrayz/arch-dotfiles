# Arch Linux Dotfiles — Catppuccin Mocha (Sway + Waybar & i3 + Polybar)

Dotfiles yang ringan, smooth, dan dioptimalkan untuk programming di Arch Linux (Wayland **Sway + Waybar** & X11 **i3 + Polybar**).

## Struktur Paket Dotfiles (GNU Stow)
Seluruh konfigurasi dikelola menggunakan `stow` dari direktori `~/dotfiles`:
```bash
cd ~/dotfiles
stow sway waybar rofi mako dunst alacritty foot zsh starship tmux vscode gtk btop fastfetch nvim i3 polybar picom
```

## Daftar Shortcut Utama (Sway & i3)

| Shortcut | Fungsi |
| :--- | :--- |
| `Super + Enter` | Buka Terminal utama (`Alacritty`) |
| `Super + Shift + Enter` | Buka Terminal Wayland ringan (`Foot`) |
| `Super + D` | Buka App Launcher (`Rofi`) |
| `Super + C` | Buka Code Editor (`VS Code`) |
| `Super + E` | Buka File Manager (`Thunar`) |
| `Super + B` | Buka Browser (`Firefox`) |
| `Super + V` | Riwayat Clipboard (`Cliphist` + `Rofi` di Sway) |
| `Print` / `Super + Shift + S` | Screenshot pilih area & edit (`Grim + Slurp + Swappy` / `Flameshot`) |
| `Super + Q` / `Super + Shift + Q` | Tutup jendela aktif |
| `Super + F` | Mode Fullscreen |
| `Super + Shift + Space` | Toggle Floating / Tiling window |
| `Super + H / J / K / L` | Pindah fokus jendela (atau tombol Panah) |
| `Super + Shift + H / J / K / L` | Pindahkan posisi jendela (atau `Super + Shift + Panah`) |
| `Super + 1..9, 0` | Pindah ke Workspace 1 - 10 |
| `Super + Shift + 1..9, 0` | Pindahkan jendela ke Workspace 1 - 10 |
| `Super + R` | Masuk ke mode Resize jendela (`Esc` / `Enter` untuk keluar) |
| `Super + Escape` | Kunci layar (`swaylock` / `i3lock`) |
| `Super + Shift + C` / `Super + Shift + R` | Reload konfigurasi WM |
| `Super + Shift + E` | Buka Power Menu (Lock, Suspend, Logout, Reboot, Shutdown) |

## Shortcut Terminal & Tmux
* **Alias Zsh**:
  * `c` → Buka VS Code di folder saat ini (`code .`)
  * `v` → Buka Neovim (`nvim`)
  * `lg` → Buka UI Git (`lazygit`)
  * `ll` / `lt` → Lihat daftar file & pohon direktori dengan ikon (`eza`)
  * `z <nama-folder>` → Lompat cepat ke direktori (`zoxide`)
  * `Ctrl + R` → Cari riwayat perintah dengan `fzf`
  * `Ctrl + T` → Cari file cepat dengan `fzf`
* **Tmux**:
  * `Ctrl+B` lalu `|` → Split layar kanan-kiri
  * `Ctrl+B` lalu `-` → Split layar atas-bawah
  * `Alt + H / J / K / L` → Pindah antar pane tanpa prefix
