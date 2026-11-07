# 󰣇 Torray Arch Dotfiles — Catppuccin Mocha (i3/Polybar & Sway/Waybar)

Konfigurasi **Arch Linux** ringan, *smooth*, dan siap *programming* dengan palet **Catppuccin Mocha**, dikalibrasi presisi untuk resolusi layar **`1366x768`** dengan *zero-fork* *scripts* dan *native GTK3 plugins*.

---

## ✨ Fitur Utama

1. **Proportional Inset-Pill Navbar (`Polybar` & `Waybar`)**:
   - **Workspace Live App Logos (`workspaces.py`)**: Menampilkan logo aplikasi aktif (`󰆍` WezTerm, `󰨞` VS Code, `󰈹` Firefox, `󰉋` Thunar, `` Neovim, `󰻠` btop) secara *real-time* (Event-driven i3 IPC, `0.0% CPU`).
   - **Tengah Navbar (`[  Hub ]` & Musik Dinamis)**:
     - Animasi *equalizer* lagu (`󰎆 ▂▅▇▃ Judul`) otomatis muncul di tengah **hanya saat musik sedang diputar (`Playing`)**.
     - Klik kiri pada animasi musik atau `[  Hub ]` membuka **Torray Hub** tepat di tengah bawah navbar.
   - **Indikator Ukuran Jendela Global (`[ 󰊓 Full / S / M / L ]`)**: Ubah ukuran aplikasi aktif dengan sekali klik atau `Super + Z`.

2. **Native GTK3 Control Center — `Torray Hub v2` (`torray-hub.py`)**:
   - **4 Tab Lengkap**:
     - `󰒓 Kontrol`: Live Telemetry (CPU/RAM/Suhu/Disk), Slider Audio & Kecerahan Layar, *Smart Toggles* (`Anti-Sleep`, `Fokus DND`, `Eye Care`), dan *Quick Launchers*.
     - `󰎆 Musik`: Live 28-Bar Cairo Audio Spectrum Visualizer dengan 3 tema warna (`🌈 Cyber`, `🟣 Mauve`, `🟢 Matrix`) & kontrol MPRIS.
     - `󰸉 Tema`: Studio Wallpaper Visual, pengatur *Window Gaps* (`0px / 4px / 10px`), dan preset ukuran aplikasi (`S / M / L / PiP / Full`).
     - `󰨞 Dev`: *Active Localhost Port Killer* (satu klik *kill* port Node/Python/Go yang nyangkut), *Screen Color Picker* (HEX ke clipboard), dan *Lazygit*.
   - Mendukung tombol pengubah ukuran **`[ 󰊓 S / M / L ]`** di pojok kanan atas.

3. **Visual Clipboard Manager ala Windows 11 — `Torray Clip` (`Super + V`)**:
   - Menyimpan riwayat **Teks** maupun **Screenshot / Gambar** lengkap dengan *thumbnail* visual (`~/.cache/torray-clip`).
   - Fitur *Search* instan, *Pin* (`󰐃`), *Auto-Paste* (`󰅌 Tempel`), dan tombol ukuran **`[ 󰊓 S / M / L ]`**.

4. **Terminal `WezTerm` dengan GUI Tab Berwarna**:
   - Mendukung *Kitty Graphics Protocol* (menampilkan logo PNG `~/logo.png` di `fastfetch`).
   - Setiap tab memiliki *badge* warna-warni Catppuccin berbeda + ikon proses aktif, tombol **`[ + ]` Hijau Emerald**, dan tombol **`[ x ]` Merah Coral**.

5. **Custom Catppuccin `Thunar` File Manager**:
   - Tema gelap *Catppuccin Mocha* (`gtk.css`), *zoom* kompak, *bookmarks* developer, dan menu *Klik Kanan* khusus (`Buka Terminal di Sini`, `Buka di VS Code`, `Salin Path`).

---

## ⌨️ Pintasan Keyboard Utama (Keybindings)

| Pintasan | Fungsi |
| :--- | :--- |
| **`Super + N`** | Buka **Torray Hub** (Tab Kontrol) di tengah |
| **`Super + P`** | Buka **Torray Hub** (Tab Musik & Visualizer) |
| **`Super + Shift + W`** | Buka **Torray Hub** (Tab Studio Wallpaper & Tema) |
| **`Super + V`** | Buka **Visual Clipboard History** (Teks & Screenshot) |
| **`Super + T`** / **`Super + Enter`** | Buka Terminal **WezTerm** |
| **`Super + C`** | Buka **VS Code** |
| **`Super + E`** | Buka File Manager **Thunar** |
| **`Super + B`** | Buka Browser **Firefox** |
| **`Super + Space`** | Buka **Rofi Application Launcher** |
| **`Super + /`** / **`Super + Ctrl + K`** | Buka Daftar Pencarian **Keybindings** |
| **`Super + F`** | **Ukuran Full di Bawah Navbar** (Navbar & Tab Browser tetap aman) |
| **`Super + Shift + F`** | **Fullscreen Versi Maks** (Sembunyikan Navbar / Mode Bioskop) |
| **`Super + Z`** | Putar ukuran aplikasi aktif: **`S` → `M` → `L` → `Full`** |
| **`Super + Shift + Space`** | Toggle aplikasi **Mengambang di Tengah** (`900x540`) |
| **`Super + Alt + 1 / 2 / 3 / 4 / 0`** | Preset Ukuran: `[1]` S, `[2]` M, `[3]` L, `[4]` PiP Pojok, `[0]` Tiling |
| **`Super + Ctrl + Shift + Panah`** | Ubah ukuran lebar/tinggi aplikasi secara manual |
| **`Super + =` / `Super + -`** | Perbesar / perkecil lebar & tinggi sekaligus |
| **`Super + 1..9, 0`** | Pindah ke Workspace `1 - 10` |
| **`Super + Shift + 1..9, 0`** | Pindahkan aplikasi ke Workspace `1 - 10` + kamera ikut berpindah |
| **`Super + Q`** | Tutup jendela aplikasi aktif |

---

## 🚀 Instalasi Cepat (GNU Stow)

```bash
git clone https://github.com/Torrayz/arch-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```
