# Arch Linux Dotfiles — Catppuccin Mocha (Torray Edition)

Dotfiles ringan, smooth, dan dioptimalkan untuk programming di Arch Linux (**Sway + Waybar** & **i3 + Polybar**), diselaraskan dengan keybindings dari `Torrayz/dotfilesku`.

## Fitur Utama
* **Terminal dengan GUI Tab Bar (`WezTerm`)**: Memiliki tombol **`[+]`** di bagian atas untuk menambah tab baru dan tombol **`[x]`** di setiap tab untuk menutupnya menggunakan mouse (seperti Windows Terminal / CMD), ditambah dukungan penuh gambar PNG di terminal.
* **Custom Logo & Fastfetch (`~/logo.png`)**: Emblem custom `>_ TORRAY // ARCH` bertema Catppuccin Mocha yang otomatis tampil dengan layout box saat membuka terminal.
* **Zsh + Starship Capsule Powerline**: Prompt modern dua baris dengan indikator OS, user, folder, Git branch/status, versi runtime (Node/Python/Rust/Go), serta jam.
* **Spotlight App Search (`Super + Space`)**: Pencarian aplikasi cepat dengan ikon besar (2 kolom) via Rofi + tombol **`󰣇 Cari`** langsung di Navbar.
* **Interactive Keybindings Search (`Super + ?` / `Super + K`)**: Fitur pencarian seluruh shortcut keyboard via Rofi + tombol **`󰌌 Keys`** langsung di Navbar.

## Daftar Shortcut (Sway & i3 — Synced dengan `Torrayz/dotfilesku`)

| Shortcut | Fungsi |
| :--- | :--- |
| **`Super + Space`** (atau `Super + D`) | **Cari & Buka Aplikasi (Spotlight Search)** |
| **`Super + T`** / **`Super + Enter`** | **Buka Terminal (`WezTerm` — dengan Tab `[+]` & `[x]`)** |
| **`Super + Shift + Enter`** | Buka Terminal alternatif (`Kitty`) |
| **`Super + ?`** (`Super+Shift+/`) / **`Super + K`** | **Cari Keybindings (Cheat-Sheet Interaktif)** |
| **`Super + C`** | Buka Code Editor (`VS Code`) |
| **`Super + E`** | Buka File Manager (`Thunar`) |
| **`Super + B`** | Buka Browser (`Firefox`) |
| **`Super + V`** | Riwayat Clipboard (`Cliphist` + `Rofi`) |
| **`Super + M`** / **`Ctrl + Alt + Del`** | Buka System Monitor & Process List (`btop`) |
| **`Super + Q`** | Tutup jendela aktif |
| **`Super + F`** | Mode Fullscreen |
| **`Super + Shift + T`** | Toggle Floating / Tiling window |
| **`Super + W`** | Toggle Tabbed / Group window |
| **`Super + R`** | Toggle arah Split (Horizontal / Vertikal) |
| **`Super + Ctrl + Panah`** | **Resize ukuran jendela langsung** (tanpa masuk mode resize) |
| **`Super + Panah`** / **`H, J, K, L`** | Pindah fokus jendela |
| **`Super + Shift + Panah`** / **`H, J, K, L`** | Pindahkan posisi jendela |
| **`Super + 1..9, 0`** | Pindah ke Workspace 1 - 10 |
| **`Super + Shift + 1..9, 0`** | Pindahkan jendela ke Workspace 1 - 10 |
| **`F10`** / **`Print`** / **`Super + Alt + S`** | Screenshot area pilih & edit |
| **`Super + G`** | **Terjemahkan teks yang diblok ke Bahasa Indonesia** |
| **`Super + Shift + G`** | **Terjemahkan teks yang diblok ke Bahasa Inggris** |
| **`Super + Alt + L`** / **`Super + Ctrl + L`** | Kunci layar (`swaylock` / `i3lock`) |
| **`Super + Shift + E`** / **`Super + Ctrl + Q`** | Buka Power Menu (Lock, Suspend, Logout, Restart, Shutdown) |

## Shortcut di Dalam Terminal (`WezTerm`)
* **Klik tombol `[+]` di bar atas** atau tekan **`Ctrl + T`** → Tambah Tab Terminal baru
* **Klik tombol `[x]` di tab** atau tekan **`Ctrl + W`** → Tutup Tab Terminal
* **`Ctrl + Tab`** / **`Alt + 1..5`** → Pindah antar Tab Terminal
* **`Ctrl + Shift + D`** → Split layar terminal kanan-kiri
* **`Ctrl + Shift + E`** → Split layar terminal atas-bawah
* **`Ctrl + [+]` / `[-]`** → Perbesar / perkecil ukuran font terminal
