#!/usr/bin/env python3
# =============================================================================
# Torray Hub — Custom Native GTK3 Desktop Plugin (Catppuccin Mocha)
# Features:
#   1. Live Cairo Audio Visualizer + Fast Media Controls (MPRIS / playerctl)
#   2. Visual Wallpaper Studio with Live Image Thumbnails + Custom File Picker
#   3. Real-Time Smooth Sliders (Volume & Brightness) + System Gauges
# =============================================================================

import glob
import math
import os
import random
import shutil
import signal
import subprocess
import sys

import cairo
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk, Pango

PID_FILE = "/tmp/torray_hub.pid"
WALL_DIRS = [
    os.path.expanduser("~/.config/sway/wallpapers"),
    os.path.expanduser("~/Pictures/Wallpapers"),
]
CURRENT_WALL_LINK = os.path.expanduser("~/.config/sway/wallpaper.png")

CSS = b"""
window {
    background-color: #181825;
    color: #cdd6f4;
    border: 2px solid #cba6f7;
    border-radius: 12px;
    font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
    font-size: 9.5pt;
}
button {
    background-image: none;
    background-color: #313244;
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 8px;
    box-shadow: none;
    text-shadow: none;
}
.header-bar {
    background-color: #11111b;
    padding: 8px 12px;
    border-bottom: 1px solid #313244;
}
.title-label {
    color: #cba6f7;
    font-weight: bold;
    font-size: 10.5pt;
}
.tab-btn {
    background-image: none;
    background-color: #1e1e2e;
    color: #a6adc8;
    border: 1px solid #313244;
    border-radius: 8px;
    padding: 4px 10px;
    font-weight: 600;
}
.tab-btn:hover {
    background-image: none;
    background-color: #313244;
    color: #cdd6f4;
}
.tab-btn-active {
    background-image: none;
    background-color: #cba6f7;
    color: #11111b;
    border: 1px solid #cba6f7;
    border-radius: 8px;
    padding: 4px 10px;
    font-weight: bold;
}
.card {
    background-color: #1e1e2e;
    border: 1px solid #313244;
    border-radius: 10px;
    padding: 10px;
}
.section-title {
    color: #89b4fa;
    font-weight: bold;
    font-size: 9pt;
}
.song-title {
    color: #cdd6f4;
    font-weight: bold;
    font-size: 10pt;
}
.song-artist {
    color: #a6adc8;
    font-size: 8.5pt;
}
.action-btn {
    background-image: none;
    background-color: #313244;
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 8px;
    padding: 6px 10px;
    font-weight: 600;
}
.action-btn:hover {
    background-image: none;
    background-color: #cba6f7;
    color: #11111b;
    border-color: #cba6f7;
}
.media-btn {
    background-image: none;
    background-color: #313244;
    color: #cdd6f4;
    border-radius: 99px;
    padding: 6px 14px;
    font-size: 11pt;
}
.media-btn-play {
    background-image: none;
    background-color: #cba6f7;
    color: #11111b;
    border-radius: 99px;
    padding: 6px 18px;
    font-size: 11pt;
    font-weight: bold;
}
.media-btn:hover, .media-btn-play:hover {
    background-image: none;
    background-color: #89b4fa;
    color: #11111b;
}
.wall-btn {
    background-image: none;
    background-color: #181825;
    border: 2px solid #313244;
    border-radius: 8px;
    padding: 3px;
}
.wall-btn:hover {
    background-image: none;
    border-color: #cba6f7;
    background-color: #313244;
}
.close-btn {
    background-image: none;
    background-color: #f38ba8;
    color: #11111b;
    border-radius: 8px;
    padding: 2px 8px;
    font-weight: bold;
}
scale trough {
    background-color: #313244;
    border-radius: 6px;
    min-height: 8px;
}
scale highlight {
    background-color: #cba6f7;
    border-radius: 6px;
}
scale slider {
    background-color: #cdd6f4;
    border-radius: 99px;
    min-width: 14px;
    min-height: 14px;
}
progressbar trough {
    background-color: #313244;
    border-radius: 6px;
    min-height: 8px;
}
progressbar progress {
    background-color: #89b4fa;
    border-radius: 6px;
}
"""


def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL).decode("utf-8").strip()
    except Exception:
        return ""


def apply_wallpaper(path):
    if not os.path.exists(path):
        return
    try:
        if os.path.abspath(path) != os.path.abspath(CURRENT_WALL_LINK):
            shutil.copyfile(path, CURRENT_WALL_LINK)
    except Exception:
        pass
    if os.environ.get("WAYLAND_DISPLAY"):
        subprocess.Popen(["swaymsg", "output", "*", "bg", path, "fill"])
    else:
        subprocess.Popen(["feh", "--bg-fill", path])
    subprocess.Popen([
        "notify-send",
        "-h", "string:x-canonical-private-synchronous:osd",
        "-t", "1800",
        "󰸉 Wallpaper Terpasang",
        os.path.basename(path),
    ])


class TorrayHub(Gtk.Window):
    def __init__(self, start_tab="dash"):
        super().__init__(title="Torray Hub")
        self.set_default_size(430, 420)
        self.set_resizable(False)
        self.set_decorated(False)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_position(Gtk.WindowPosition.CENTER)

        # Apply CSS
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.connect("key-press-event", self.on_key_press)
        self.connect("destroy", self.cleanup_and_quit)

        self.is_playing = False
        self.bars = [0.15] * 24
        self.phase = 0.0

        root_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(root_box)

        # Header Navigation Bar
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        header.get_style_context().add_class("header-bar")
        root_box.pack_start(header, False, False, 0)

        brand = Gtk.Label(label="󰣇 Torray Hub")
        brand.get_style_context().add_class("title-label")
        header.pack_start(brand, False, False, 4)

        self.tab_btns = {}
        for tab_id, label in [("dash", "󰒓 Kontrol"), ("music", "󰎆 Musik"), ("wall", "󰸉 Wallpaper")]:
            b = Gtk.Button(label=label)
            b.connect("clicked", lambda _w, t=tab_id: self.switch_tab(t))
            header.pack_start(b, False, False, 0)
            self.tab_btns[tab_id] = b

        close_btn = Gtk.Button(label="✕")
        close_btn.get_style_context().add_class("close-btn")
        close_btn.connect("clicked", self.cleanup_and_quit)
        header.pack_end(close_btn, False, False, 0)

        # Stack for Tabs
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self.stack.set_transition_duration(180)
        root_box.pack_start(self.stack, True, True, 0)

        self.build_dash_tab()
        self.build_music_tab()
        self.build_wall_tab()

        self.switch_tab(start_tab)

        # Timers
        GLib.timeout_add(60, self.animate_visualizer)
        GLib.timeout_add(1200, self.refresh_status)
        self.refresh_status()

    def switch_tab(self, tab_id):
        if tab_id not in self.tab_btns:
            tab_id = "dash"
        self.stack.set_visible_child_name(tab_id)
        for tid, btn in self.tab_btns.items():
            ctx = btn.get_style_context()
            ctx.remove_class("tab-btn")
            ctx.remove_class("tab-btn-active")
            ctx.add_class("tab-btn-active" if tid == tab_id else "tab-btn")

    # -------------------------------------------------------------------------
    # TAB 1: Quick Control Center & Interactive Sliders
    # -------------------------------------------------------------------------
    def build_dash_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        box.set_margin_top(10)
        box.set_margin_bottom(10)
        box.set_margin_start(12)
        box.set_margin_end(12)

        # Sliders Card (Volume & Brightness)
        s_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        s_card.get_style_context().add_class("card")

        # Volume Slider
        vol_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        vol_lbl = Gtk.Label(label="󰕾 Audio")
        vol_lbl.set_width_chars(9)
        vol_lbl.set_xalign(0)
        self.vol_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 2)
        self.vol_scale.set_draw_value(True)
        self.vol_scale.set_value_pos(Gtk.PositionType.RIGHT)
        try:
            v = int(run_cmd("pamixer --get-volume") or "70")
        except ValueError:
            v = 70
        self.vol_scale.set_value(v)
        self.vol_scale.connect("value-changed", self.on_vol_changed)
        vol_row.pack_start(vol_lbl, False, False, 0)
        vol_row.pack_start(self.vol_scale, True, True, 0)
        s_card.pack_start(vol_row, False, False, 0)

        # Brightness Slider
        br_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        br_lbl = Gtk.Label(label="󰃠 Layar")
        br_lbl.set_width_chars(9)
        br_lbl.set_xalign(0)
        self.br_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 5, 100, 5)
        self.br_scale.set_draw_value(True)
        self.br_scale.set_value_pos(Gtk.PositionType.RIGHT)
        try:
            b_val = int(run_cmd("brightnessctl -m | cut -d, -f4 | tr -d '%'") or "80")
        except ValueError:
            b_val = 80
        self.br_scale.set_value(b_val)
        self.br_scale.connect("value-changed", self.on_br_changed)
        br_row.pack_start(br_lbl, False, False, 0)
        br_row.pack_start(self.br_scale, True, True, 0)
        s_card.pack_start(br_row, False, False, 0)

        box.pack_start(s_card, False, False, 0)

        # Mini Now Playing + Visualizer Card inside Dash
        m_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        m_card.get_style_context().add_class("card")
        m_top = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.dash_song_lbl = Gtk.Label(label="󰎆 Tidak ada musik diputar")
        self.dash_song_lbl.set_ellipsize(Pango.EllipsizeMode.END)
        self.dash_song_lbl.set_max_width_chars(28)
        self.dash_song_lbl.set_xalign(0)
        self.dash_song_lbl.get_style_context().add_class("song-title")
        m_top.pack_start(self.dash_song_lbl, True, True, 0)

        for icon, cmd in [("󰒮", "playerctl previous"), ("󰐎", "playerctl play-pause"), ("󰒭", "playerctl next")]:
            mb = Gtk.Button(label=icon)
            mb.get_style_context().add_class("action-btn")
            mb.connect("clicked", lambda _w, c=cmd: subprocess.Popen(c, shell=True))
            m_top.pack_end(mb, False, False, 0)
        m_card.pack_start(m_top, False, False, 0)

        self.mini_vis = Gtk.DrawingArea()
        self.mini_vis.set_size_request(-1, 36)
        self.mini_vis.connect("draw", self.draw_visualizer)
        m_card.pack_start(self.mini_vis, False, False, 0)
        box.pack_start(m_card, False, False, 0)

        # Quick Actions Grid (2x3)
        grid = Gtk.Grid()
        grid.set_column_spacing(8)
        grid.set_row_spacing(8)
        grid.set_column_homogeneous(True)

        actions = [
            ("󰍉 Cari Aplikasi", lambda: self.launch_and_close("rofi -show drun -show-icons")),
            ("󰤨 Wi-Fi Menu", lambda: self.launch_and_close("~/.config/rofi/wifi.sh")),
            ("󰸉 Ganti Wallpaper", lambda: self.switch_tab("wall")),
            ("󰌌 Keybindings", lambda: self.launch_and_close("~/.config/rofi/keybindings.sh")),
            ("󰹑 Screenshot", lambda: self.launch_and_close("flameshot gui")),
            ("󰻠 Monitor (btop)", lambda: self.launch_and_close("wezterm start -- btop")),
        ]
        for idx, (label, fn) in enumerate(actions):
            btn = Gtk.Button(label=label)
            btn.get_style_context().add_class("action-btn")
            btn.connect("clicked", lambda _w, f=fn: f())
            grid.attach(btn, idx % 2, idx // 2, 1, 1)

        box.pack_start(grid, True, True, 0)
        self.stack.add_named(box, "dash")

    # -------------------------------------------------------------------------
    # TAB 2: Music Player & Live Cairo Spectrum Visualizer
    # -------------------------------------------------------------------------
    def build_music_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(12)
        box.set_margin_bottom(12)
        box.set_margin_start(12)
        box.set_margin_end(12)

        info_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        info_card.get_style_context().add_class("card")

        self.music_title = Gtk.Label(label="Belum Ada Lagu Diputar")
        self.music_title.get_style_context().add_class("song-title")
        self.music_title.set_ellipsize(Pango.EllipsizeMode.END)
        self.music_title.set_max_width_chars(38)

        self.music_artist = Gtk.Label(label="Putar lagu di YouTube / Browser / Spotify / MPV")
        self.music_artist.get_style_context().add_class("song-artist")
        self.music_artist.set_ellipsize(Pango.EllipsizeMode.END)

        info_card.pack_start(self.music_title, False, False, 2)
        info_card.pack_start(self.music_artist, False, False, 2)
        box.pack_start(info_card, False, False, 0)

        # Large Visualizer Canvas
        vis_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        vis_card.get_style_context().add_class("card")
        self.big_vis = Gtk.DrawingArea()
        self.big_vis.set_size_request(-1, 130)
        self.big_vis.connect("draw", self.draw_visualizer)
        vis_card.pack_start(self.big_vis, True, True, 0)
        box.pack_start(vis_card, True, True, 0)

        # Transport Controls
        ctrl_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=14)
        ctrl_box.set_halign(Gtk.Align.CENTER)

        prev_b = Gtk.Button(label="󰒮  Prev")
        prev_b.get_style_context().add_class("media-btn")
        prev_b.connect("clicked", lambda _w: subprocess.Popen("playerctl previous", shell=True))

        self.play_b = Gtk.Button(label="󰐎  Play / Pause")
        self.play_b.get_style_context().add_class("media-btn-play")
        self.play_b.connect("clicked", lambda _w: subprocess.Popen("playerctl play-pause", shell=True))

        next_b = Gtk.Button(label="Next  󰒭")
        next_b.get_style_context().add_class("media-btn")
        next_b.connect("clicked", lambda _w: subprocess.Popen("playerctl next", shell=True))

        ctrl_box.pack_start(prev_b, False, False, 0)
        ctrl_box.pack_start(self.play_b, False, False, 0)
        ctrl_box.pack_start(next_b, False, False, 0)
        box.pack_start(ctrl_box, False, False, 4)

        self.stack.add_named(box, "music")

    # -------------------------------------------------------------------------
    # TAB 3: Visual Wallpaper Studio Plugin (Thumbnail Previews + File Picker)
    # -------------------------------------------------------------------------
    def build_wall_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        box.set_margin_top(10)
        box.set_margin_bottom(10)
        box.set_margin_start(12)
        box.set_margin_end(12)

        top_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        lbl = Gtk.Label(label="Klik gambar untuk ganti wallpaper langsung:")
        lbl.get_style_context().add_class("song-artist")
        top_bar.pack_start(lbl, False, False, 0)

        pick_btn = Gtk.Button(label="󰉋 Pilih File...")
        pick_btn.get_style_context().add_class("action-btn")
        pick_btn.connect("clicked", self.on_pick_custom_wall)
        top_bar.pack_end(pick_btn, False, False, 0)
        box.pack_start(top_bar, False, False, 0)

        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.wall_grid = Gtk.Grid()
        self.wall_grid.set_column_spacing(8)
        self.wall_grid.set_row_spacing(8)
        self.wall_grid.set_column_homogeneous(True)
        scroll.add(self.wall_grid)
        box.pack_start(scroll, True, True, 0)

        self.populate_wallpapers()
        self.stack.add_named(box, "wall")

    def populate_wallpapers(self):
        for child in self.wall_grid.get_children():
            self.wall_grid.remove(child)

        files = []
        seen = set()
        for d in WALL_DIRS:
            if os.path.isdir(d):
                for ext in ("*.png", "*.jpg", "*.jpeg", "*.webp"):
                    for f in sorted(glob.glob(os.path.join(d, ext))):
                        base = os.path.basename(f)
                        if base not in seen:
                            seen.add(base)
                            files.append(f)

        for idx, fpath in enumerate(files[:12]):
            try:
                pix = GdkPixbuf.Pixbuf.new_from_file_at_scale(fpath, 180, 96, False)
                img = Gtk.Image.new_from_pixbuf(pix)
                btn = Gtk.Button()
                btn.get_style_context().add_class("wall-btn")
                vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
                vbox.pack_start(img, False, False, 0)
                name_lbl = Gtk.Label(label=os.path.splitext(os.path.basename(fpath))[0][:20])
                name_lbl.get_style_context().add_class("song-artist")
                vbox.pack_start(name_lbl, False, False, 0)
                btn.add(vbox)
                btn.connect("clicked", lambda _w, p=fpath: apply_wallpaper(p))
                self.wall_grid.attach(btn, idx % 2, idx // 2, 1, 1)
            except Exception:
                continue
        self.wall_grid.show_all()

    def on_pick_custom_wall(self, _btn):
        dlg = Gtk.FileChooserDialog(
            title="Pilih Gambar Wallpaper",
            parent=self,
            action=Gtk.FileChooserAction.OPEN,
        )
        dlg.add_buttons(
            Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.STOCK_OPEN, Gtk.ResponseType.OK,
        )
        flt = Gtk.FileFilter()
        flt.set_name("Gambar (PNG / JPG / WEBP)")
        for pat in ("*.png", "*.jpg", "*.jpeg", "*.webp"):
            flt.add_pattern(pat)
        dlg.add_filter(flt)

        if dlg.run() == Gtk.ResponseType.OK:
            chosen = dlg.get_filename()
            if chosen:
                os.makedirs(WALL_DIRS[1], exist_ok=True)
                dest = os.path.join(WALL_DIRS[1], os.path.basename(chosen))
                if os.path.abspath(chosen) != os.path.abspath(dest):
                    shutil.copyfile(chosen, dest)
                apply_wallpaper(dest)
                self.populate_wallpapers()
        dlg.destroy()

    # -------------------------------------------------------------------------
    # Cairo Animated Audio Spectrum Visualizer
    # -------------------------------------------------------------------------
    def animate_visualizer(self):
        self.phase += 0.24
        for i in range(len(self.bars)):
            if self.is_playing:
                target = (
                    0.35
                    + 0.30 * math.sin(self.phase + i * 0.55)
                    + 0.25 * math.cos(self.phase * 1.7 - i * 0.3)
                    + random.uniform(-0.08, 0.12)
                )
                target = max(0.10, min(0.96, target))
            else:
                target = 0.12 + 0.05 * math.sin(self.phase * 0.5 + i * 0.4)
            self.bars[i] += (target - self.bars[i]) * 0.45

        self.mini_vis.queue_draw()
        self.big_vis.queue_draw()
        return True

    def draw_visualizer(self, widget, cr):
        w = widget.get_allocated_width()
        h = widget.get_allocated_height()
        n = len(self.bars)
        gap = 4
        bar_w = max(4, (w - (n - 1) * gap) / n)

        grad = cairo.LinearGradient(0, h, w, 0)
        grad.add_color_stop_rgba(0.0, 0.796, 0.651, 0.969, 0.95)  # Mauve
        grad.add_color_stop_rgba(0.5, 0.537, 0.706, 0.980, 0.95)  # Blue
        grad.add_color_stop_rgba(1.0, 0.580, 0.886, 0.835, 0.95)  # Teal
        cr.set_source(grad)

        for i, val in enumerate(self.bars):
            bh = max(4, val * (h - 6))
            x = i * (bar_w + gap)
            y = h - bh
            r = min(bar_w / 2, 4)
            cr.new_sub_path()
            cr.arc(x + bar_w - r, y + r, r, -math.pi / 2, 0)
            cr.arc(x + bar_w - r, y + bh - r, r, 0, math.pi / 2)
            cr.arc(x + r, y + bh - r, r, math.pi / 2, math.pi)
            cr.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2)
            cr.close_path()
            cr.fill()
        return False

    def refresh_status(self):
        status = run_cmd("playerctl status")
        self.is_playing = status == "Playing"
        if status in ("Playing", "Paused"):
            title = run_cmd("playerctl metadata xesam:title") or "Media Stream"
            artist = run_cmd("playerctl metadata xesam:artist") or status
            icon = "󰎆" if self.is_playing else "󰏤"
            self.dash_song_lbl.set_text(f"{icon}  {title} — {artist}")
            self.music_title.set_text(title)
            self.music_artist.set_text(f"{artist}  •  ({status})")
        else:
            self.dash_song_lbl.set_text("󰎆  Belum ada musik / video diputar")
            self.music_title.set_text("Belum Ada Musik Diputar")
            self.music_artist.set_text("Buka YouTube / Spotify / MPV untuk mulai")
        return True

    def on_vol_changed(self, scale):
        val = int(scale.get_value())
        subprocess.Popen(f"pamixer --set-volume {val}", shell=True)

    def on_br_changed(self, scale):
        val = int(scale.get_value())
        subprocess.Popen(f"brightnessctl -q set {val}%", shell=True)

    def launch_and_close(self, cmd):
        subprocess.Popen(cmd, shell=True)
        self.cleanup_and_quit()

    def on_key_press(self, _widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.cleanup_and_quit()

    def cleanup_and_quit(self, *_args):
        if os.path.exists(PID_FILE):
            try:
                os.remove(PID_FILE)
            except Exception:
                pass
        Gtk.main_quit()


def main():
    tab = "dash"
    if len(sys.argv) > 1:
        arg = sys.argv[1].lstrip("-")
        if arg in ("dash", "music", "wall"):
            tab = arg

    # Toggle behavior: if already running, close existing instance and exit
    if os.path.exists(PID_FILE):
        try:
            with open(PID_FILE, "r") as f:
                old_pid = int(f.read().strip())
            os.kill(old_pid, signal.SIGTERM)
            os.remove(PID_FILE)
            sys.exit(0)
        except Exception:
            try:
                os.remove(PID_FILE)
            except Exception:
                pass

    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

    win = TorrayHub(start_tab=tab)
    win.show_all()
    win.switch_tab(tab)
    Gtk.main()


if __name__ == "__main__":
    main()
