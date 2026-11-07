#!/usr/bin/env python3
# =============================================================================
# Torray Hub v2 — Ultra-Compact Native GTK3 Plugin (Calibrated for 1366x768)
# Tabs:
#   1. 󰒓 Kontrol : Live CPU/RAM/Temp/Disk + Audio/Brightness + Smart Toggles
#   2. 󰎆 Musik   : Live 28-Bar Cairo Visualizer (3 Themes) + MPRIS Controls
#   3. 󰸉 Tema    : Visual Wallpaper Studio + Live Window Gaps Tweaker
#   4. 󰨞 Dev     : Localhost Port Killer + Screen Color Picker + Dotfiles
# =============================================================================

import glob
import math
import os
import random
import re
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
SIZE_STATE = "/tmp/torray_hub_size"
NIGHT_STATE = "/tmp/torray_night_mode"
CAFFEINE_STATE = "/tmp/torray_caffeine_mode"
WALL_DIRS = [
    os.path.expanduser("~/.config/sway/wallpapers"),
    os.path.expanduser("~/Pictures/Wallpapers"),
]
CURRENT_WALL_LINK = os.path.expanduser("~/.config/sway/wallpaper.png")

CSS = b"""
window {
    background-color: #181825;
    color: #cdd6f4;
    border: 1.5px solid #cba6f7;
    border-radius: 10px;
    font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
    font-size: 8pt;
}
button {
    background-image: none;
    background-color: #313244;
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 6px;
    padding: 3px 6px;
    box-shadow: none;
    text-shadow: none;
    min-height: 0;
    min-width: 0;
}
.header-bar {
    background-color: #11111b;
    padding: 5px 8px;
    border-bottom: 1px solid #313244;
}
.title-label {
    color: #cba6f7;
    font-weight: bold;
    font-size: 8.5pt;
}
.tab-btn {
    background-image: none;
    background-color: #1e1e2e;
    color: #a6adc8;
    border: 1px solid #313244;
    border-radius: 6px;
    padding: 2px 7px;
    font-size: 7.8pt;
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
    border-radius: 6px;
    padding: 2px 7px;
    font-size: 7.8pt;
    font-weight: bold;
}
.card {
    background-color: #1e1e2e;
    border: 1px solid #313244;
    border-radius: 8px;
    padding: 6px 8px;
}
.telemetry-bar {
    background-color: #11111b;
    border: 1px solid #313244;
    border-radius: 6px;
    padding: 4px 8px;
    color: #89b4fa;
    font-weight: 600;
    font-size: 7.6pt;
}
.song-title {
    color: #cdd6f4;
    font-weight: bold;
    font-size: 8.5pt;
}
.song-artist {
    color: #a6adc8;
    font-size: 7.5pt;
}
.action-btn {
    background-image: none;
    background-color: #313244;
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 6px;
    padding: 4px 6px;
    font-size: 7.8pt;
    font-weight: 600;
}
.action-btn:hover {
    background-image: none;
    background-color: #cba6f7;
    color: #11111b;
    border-color: #cba6f7;
}
.toggle-on {
    background-image: none;
    background-color: #a6e3a1;
    color: #11111b;
    border: 1px solid #a6e3a1;
    border-radius: 6px;
    padding: 3px 6px;
    font-size: 7.6pt;
    font-weight: bold;
}
.toggle-off {
    background-image: none;
    background-color: #1e1e2e;
    color: #a6adc8;
    border: 1px solid #313244;
    border-radius: 6px;
    padding: 3px 6px;
    font-size: 7.6pt;
}
.media-btn {
    background-image: none;
    background-color: #313244;
    color: #cdd6f4;
    border-radius: 99px;
    padding: 4px 10px;
    font-size: 8.5pt;
}
.media-btn-play {
    background-image: none;
    background-color: #cba6f7;
    color: #11111b;
    border-radius: 99px;
    padding: 4px 14px;
    font-size: 8.5pt;
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
    border: 1.5px solid #313244;
    border-radius: 6px;
    padding: 2px;
}
.wall-btn:hover {
    background-image: none;
    border-color: #cba6f7;
    background-color: #313244;
}
.kill-btn {
    background-image: none;
    background-color: #f38ba8;
    color: #11111b;
    border: none;
    border-radius: 5px;
    padding: 1px 6px;
    font-size: 7.5pt;
    font-weight: bold;
}
.close-btn {
    background-image: none;
    background-color: #f38ba8;
    color: #11111b;
    border: none;
    border-radius: 5px;
    padding: 1px 6px;
    font-size: 8pt;
    font-weight: bold;
}
scale trough {
    background-color: #313244;
    border-radius: 4px;
    min-height: 5px;
}
scale highlight {
    background-color: #cba6f7;
    border-radius: 4px;
}
scale slider {
    background-color: #cdd6f4;
    border-radius: 99px;
    min-width: 10px;
    min-height: 10px;
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
        "-t", "1500",
        "󰸉 Wallpaper Terpasang",
        os.path.basename(path),
    ])


class TorrayHub(Gtk.Window):
    SIZES = [
        (385, 300, "S"),
        (490, 410, "M"),
        (620, 510, "L"),
    ]

    def __init__(self, start_tab="dash"):
        super().__init__(title="Torray Hub")
        self.size_idx = 0
        if os.path.exists(SIZE_STATE):
            try:
                with open(SIZE_STATE) as f:
                    self.size_idx = int(f.read().strip()) % len(self.SIZES)
            except Exception:
                self.size_idx = 0

        w, h, _ = self.SIZES[self.size_idx]
        self.set_default_size(w, h)
        self.set_resizable(True)
        self.set_decorated(False)
        self.set_keep_above(True)
        self.stick()
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_position(Gtk.WindowPosition.CENTER)

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.connect("key-press-event", self.on_key_press)
        self.connect("destroy", self.cleanup_and_quit)

        self.is_playing = False
        self.vis_theme = 0  # 0: Cyber, 1: Mauve, 2: Matrix
        self.bars = [0.15] * 28
        self.phase = 0.0
        self.wall_loaded = False

        root_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(root_box)

        # Compact Header Bar
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        header.get_style_context().add_class("header-bar")
        root_box.pack_start(header, False, False, 0)

        brand = Gtk.Label(label="󰣇 Hub")
        brand.get_style_context().add_class("title-label")
        header.pack_start(brand, False, False, 2)

        self.tab_btns = {}
        tabs = [
            ("dash", "󰒓 Kontrol"),
            ("music", "󰎆 Musik"),
            ("wall", "󰸉 Tema"),
            ("dev", "󰨞 Dev"),
        ]
        for tab_id, label in tabs:
            b = Gtk.Button(label=label)
            b.connect("clicked", lambda _w, t=tab_id: self.switch_tab(t))
            header.pack_start(b, False, False, 0)
            self.tab_btns[tab_id] = b

        close_btn = Gtk.Button(label="✕")
        close_btn.get_style_context().add_class("close-btn")
        close_btn.connect("clicked", self.cleanup_and_quit)
        header.pack_end(close_btn, False, False, 0)

        self.size_btn = Gtk.Button(label=f"󰊓 {self.SIZES[self.size_idx][2]}")
        self.size_btn.get_style_context().add_class("tab-btn")
        self.size_btn.set_tooltip_text("Ubah Ukuran Hub (Compact / Sedang / Besar) atau tekan Super+Ctrl+Shift+Panah")
        self.size_btn.connect("clicked", self.cycle_hub_size)
        header.pack_end(self.size_btn, False, False, 0)

        # Stack
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.NONE)
        self.stack.set_transition_duration(140)
        root_box.pack_start(self.stack, True, True, 0)

        self.build_dash_tab()
        self.build_music_tab()
        self.build_wall_tab()
        self.build_dev_tab()

        self.switch_tab(start_tab)

        GLib.timeout_add(60, self.animate_visualizer)
        GLib.timeout_add(1200, self.refresh_status)
        GLib.idle_add(self.refresh_status)

    def switch_tab(self, tab_id):
        if tab_id not in self.tab_btns:
            tab_id = "dash"
        self.stack.set_visible_child_name(tab_id)
        for tid, btn in self.tab_btns.items():
            ctx = btn.get_style_context()
            ctx.remove_class("tab-btn")
            ctx.remove_class("tab-btn-active")
            ctx.add_class("tab-btn-active" if tid == tab_id else "tab-btn")
        if tab_id == "dev":
            self.refresh_ports()
        elif tab_id == "wall" and not self.wall_loaded:
            self.wall_loaded = True
            self.populate_wallpapers()

    def cycle_hub_size(self, _btn):
        self.size_idx = (self.size_idx + 1) % len(self.SIZES)
        w, h, tag = self.SIZES[self.size_idx]
        try:
            with open(SIZE_STATE, "w") as f:
                f.write(str(self.size_idx))
        except Exception:
            pass
        self.size_btn.set_label(f"󰊓 {tag}")
        self.resize(w, h)
        if self.size_idx == 0:
            self.move((1366 - w) // 2, 36)
        else:
            self.move((1366 - w) // 2, (768 - h) // 2)

    # -------------------------------------------------------------------------
    # TAB 1: Compact Control Center, Live Telemetry & Smart Toggles
    # -------------------------------------------------------------------------
    def build_dash_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        box.set_margin_top(6)
        box.set_margin_bottom(6)
        box.set_margin_start(8)
        box.set_margin_end(8)

        # Live Telemetry Strip
        self.telem_lbl = Gtk.Label(label="󰻠 CPU --%   •   󰍛 RAM --   •   󰔏 --°C   •   󰋊 Disk --%")
        self.telem_lbl.get_style_context().add_class("telemetry-bar")
        box.pack_start(self.telem_lbl, False, False, 0)

        # Sliders Card
        s_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        s_card.get_style_context().add_class("card")

        # Audio Row
        vol_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        vol_lbl = Gtk.Label(label="󰕾 Audio")
        vol_lbl.set_width_chars(7)
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
        mute_b = Gtk.Button(label="󰝟")
        mute_b.get_style_context().add_class("action-btn")
        mute_b.connect("clicked", lambda _w: subprocess.Popen("pamixer -t", shell=True))
        vol_row.pack_start(vol_lbl, False, False, 0)
        vol_row.pack_start(self.vol_scale, True, True, 0)
        vol_row.pack_end(mute_b, False, False, 0)
        s_card.pack_start(vol_row, False, False, 0)

        # Brightness Row
        br_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        br_lbl = Gtk.Label(label="󰃠 Layar")
        br_lbl.set_width_chars(7)
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
        mix_b = Gtk.Button(label="󰓃")
        mix_b.get_style_context().add_class("action-btn")
        mix_b.connect("clicked", lambda _w: self.launch_and_close("pavucontrol"))
        br_row.pack_start(br_lbl, False, False, 0)
        br_row.pack_start(self.br_scale, True, True, 0)
        br_row.pack_end(mix_b, False, False, 0)
        s_card.pack_start(br_row, False, False, 0)

        box.pack_start(s_card, False, False, 0)

        # Smart Mode Toggles (Anti-Sleep, DND, Eye Care)
        t_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        t_row.set_homogeneous(True)

        self.btn_caffeine = Gtk.Button(label="󰅶 Anti-Sleep")
        self.btn_caffeine.connect("clicked", self.toggle_caffeine)
        t_row.pack_start(self.btn_caffeine, True, True, 0)

        self.btn_dnd = Gtk.Button(label="󰂛 Fokus DND")
        self.btn_dnd.connect("clicked", self.toggle_dnd)
        t_row.pack_start(self.btn_dnd, True, True, 0)

        self.btn_night = Gtk.Button(label="󰖔 Eye Care")
        self.btn_night.connect("clicked", self.toggle_night)
        t_row.pack_start(self.btn_night, True, True, 0)

        self.update_toggle_styles()
        box.pack_start(t_row, False, False, 0)

        # Compact Mini Media Bar
        m_card = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        m_card.get_style_context().add_class("card")
        self.dash_song_lbl = Gtk.Label(label="󰎆 Tidak ada musik")
        self.dash_song_lbl.set_ellipsize(Pango.EllipsizeMode.END)
        self.dash_song_lbl.set_max_width_chars(24)
        self.dash_song_lbl.set_xalign(0)
        self.dash_song_lbl.get_style_context().add_class("song-title")
        m_card.pack_start(self.dash_song_lbl, True, True, 0)

        for icon, cmd in [("󰒭", "playerctl next"), ("󰐎", "playerctl play-pause"), ("󰒮", "playerctl previous")]:
            mb = Gtk.Button(label=icon)
            mb.get_style_context().add_class("action-btn")
            mb.connect("clicked", lambda _w, c=cmd: subprocess.Popen(c, shell=True))
            m_card.pack_end(mb, False, False, 0)
        box.pack_start(m_card, False, False, 0)

        # Compact Quick Actions Grid (3x2)
        grid = Gtk.Grid()
        grid.set_column_spacing(5)
        grid.set_row_spacing(5)
        grid.set_column_homogeneous(True)

        actions = [
            ("󰍉 Aplikasi", lambda: self.launch_and_close("rofi -show drun -show-icons")),
            ("󰤨 Wi-Fi", lambda: self.launch_and_close("~/.config/rofi/wifi.sh")),
            ("󰉋 Thunar", lambda: self.launch_and_close("thunar")),
            ("󰂯 Bluetooth", lambda: self.launch_and_close("blueman-manager")),
            ("󰹑 Screenshot", lambda: self.launch_and_close("flameshot gui")),
            ("󰌌 Shortcut", lambda: self.launch_and_close("~/.config/rofi/keybindings.sh")),
        ]
        for idx, (label, fn) in enumerate(actions):
            btn = Gtk.Button(label=label)
            btn.get_style_context().add_class("action-btn")
            btn.connect("clicked", lambda _w, f=fn: f())
            grid.attach(btn, idx % 3, idx // 3, 1, 1)

        box.pack_start(grid, False, False, 0)
        self.stack.add_named(box, "dash")

    # -------------------------------------------------------------------------
    # TAB 2: Music Player & Multi-Theme Cairo Spectrum Visualizer
    # -------------------------------------------------------------------------
    def build_music_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        box.set_margin_top(6)
        box.set_margin_bottom(6)
        box.set_margin_start(8)
        box.set_margin_end(8)

        info_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        info_card.get_style_context().add_class("card")

        self.music_title = Gtk.Label(label="Belum Ada Lagu Diputar")
        self.music_title.get_style_context().add_class("song-title")
        self.music_title.set_ellipsize(Pango.EllipsizeMode.END)
        self.music_title.set_max_width_chars(34)

        self.music_artist = Gtk.Label(label="Putar lagu di YouTube / Spotify / MPV")
        self.music_artist.get_style_context().add_class("song-artist")
        self.music_artist.set_ellipsize(Pango.EllipsizeMode.END)

        info_card.pack_start(self.music_title, False, False, 0)
        info_card.pack_start(self.music_artist, False, False, 0)
        box.pack_start(info_card, False, False, 0)

        # Spectrum Visualizer Canvas
        vis_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        vis_card.get_style_context().add_class("card")
        self.big_vis = Gtk.DrawingArea()
        self.big_vis.set_size_request(-1, 105)
        self.big_vis.connect("draw", self.draw_visualizer)
        vis_card.pack_start(self.big_vis, True, True, 0)

        theme_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        theme_lbl = Gtk.Label(label="Gaya Visual:")
        theme_lbl.get_style_context().add_class("song-artist")
        theme_row.pack_start(theme_lbl, False, False, 0)
        for idx, tname in enumerate(["🌈 Cyber", "🟣 Mauve", "🟢 Matrix"]):
            tb = Gtk.Button(label=tname)
            tb.get_style_context().add_class("action-btn")
            tb.connect("clicked", lambda _w, i=idx: setattr(self, "vis_theme", i))
            theme_row.pack_end(tb, False, False, 0)
        vis_card.pack_start(theme_row, False, False, 0)
        box.pack_start(vis_card, True, True, 0)

        # Transport Controls
        ctrl_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        ctrl_box.set_halign(Gtk.Align.CENTER)

        for lbl, cmd, cls in [
            ("󰕿 -5%", "pamixer -d 5", "action-btn"),
            ("󰒮", "playerctl previous", "media-btn"),
            ("󰐎 Play/Pause", "playerctl play-pause", "media-btn-play"),
            ("󰒭", "playerctl next", "media-btn"),
            ("󰕾 +5%", "pamixer -i 5", "action-btn"),
        ]:
            b = Gtk.Button(label=lbl)
            b.get_style_context().add_class(cls)
            b.connect("clicked", lambda _w, c=cmd: subprocess.Popen(c, shell=True))
            ctrl_box.pack_start(b, False, False, 0)

        box.pack_start(ctrl_box, False, False, 0)
        self.stack.add_named(box, "music")

    # -------------------------------------------------------------------------
    # TAB 3: Wallpaper Studio + Live Window Gaps Tweaker
    # -------------------------------------------------------------------------
    def build_wall_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        box.set_margin_top(6)
        box.set_margin_bottom(6)
        box.set_margin_start(8)
        box.set_margin_end(8)

        # Top Tweaker Bar: Gaps + Random + File Picker
        top_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        gaps_lbl = Gtk.Label(label="Gaps:")
        gaps_lbl.get_style_context().add_class("song-artist")
        top_bar.pack_start(gaps_lbl, False, False, 0)

        for g_label, g_val in [("0px", 0), ("4px", 4), ("10px", 10)]:
            gb = Gtk.Button(label=g_label)
            gb.get_style_context().add_class("action-btn")
            gb.connect("clicked", lambda _w, v=g_val: subprocess.Popen(f"i3-msg 'gaps inner all set {v}'", shell=True))
            top_bar.pack_start(gb, False, False, 0)

        pick_btn = Gtk.Button(label="󰉋 File...")
        pick_btn.get_style_context().add_class("action-btn")
        pick_btn.connect("clicked", self.on_pick_custom_wall)
        top_bar.pack_end(pick_btn, False, False, 0)

        rnd_btn = Gtk.Button(label="󰒝 Acak")
        rnd_btn.get_style_context().add_class("action-btn")
        rnd_btn.connect("clicked", lambda _w: subprocess.Popen("~/.config/polybar/scripts/wallpaper-cycle.sh", shell=True))
        top_bar.pack_end(rnd_btn, False, False, 0)

        box.pack_start(top_bar, False, False, 0)

        # Window Floating & Size Presets Bar
        win_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        win_lbl = Gtk.Label(label="Mode App:")
        win_lbl.get_style_context().add_class("song-artist")
        win_bar.pack_start(win_lbl, False, False, 0)
        for w_label, w_arg in [("S", "small"), ("M", "medium"), ("L", "large"), ("PiP", "pip"), ("Full", "toggle-max")]:
            wb = Gtk.Button(label=w_label)
            wb.get_style_context().add_class("action-btn")
            wb.connect("clicked", lambda _w, a=w_arg: self.launch_and_close(f"~/.config/polybar/scripts/win-layout.sh {a}"))
            win_bar.pack_start(wb, True, True, 0)
        box.pack_start(win_bar, False, False, 0)

        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.wall_grid = Gtk.Grid()
        self.wall_grid.set_column_spacing(6)
        self.wall_grid.set_row_spacing(6)
        self.wall_grid.set_column_homogeneous(True)
        scroll.add(self.wall_grid)
        box.pack_start(scroll, True, True, 0)

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
                pix = GdkPixbuf.Pixbuf.new_from_file_at_scale(fpath, 142, 72, False)
                img = Gtk.Image.new_from_pixbuf(pix)
                btn = Gtk.Button()
                btn.get_style_context().add_class("wall-btn")
                vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
                vbox.pack_start(img, False, False, 0)
                name_lbl = Gtk.Label(label=os.path.splitext(os.path.basename(fpath))[0][:18])
                name_lbl.get_style_context().add_class("song-artist")
                vbox.pack_start(name_lbl, False, False, 0)
                btn.add(vbox)
                btn.connect("clicked", lambda _w, p=fpath: apply_wallpaper(p))
                self.wall_grid.attach(btn, idx % 2, idx // 2, 1, 1)
            except Exception:
                continue
        self.wall_grid.show_all()

    # -------------------------------------------------------------------------
    # TAB 4: Developer Toolkit & Localhost Port Killer
    # -------------------------------------------------------------------------
    def build_dev_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        box.set_margin_top(6)
        box.set_margin_bottom(6)
        box.set_margin_start(8)
        box.set_margin_end(8)

        # Quick Developer Tools Grid
        dev_grid = Gtk.Grid()
        dev_grid.set_column_spacing(5)
        dev_grid.set_row_spacing(5)
        dev_grid.set_column_homogeneous(True)

        dev_tools = [
            ("󰔊 Color Picker", self.pick_screen_color),
            ("󰨞 Dotfiles Code", lambda: self.launch_and_close("code ~/dotfiles")),
            ("󰊢 Lazygit", lambda: self.launch_and_close("wezterm start --cwd ~/dotfiles -- lazygit")),
            ("󰻠 btop Monitor", lambda: self.launch_and_close("wezterm start -- btop")),
        ]
        for idx, (lbl, fn) in enumerate(dev_tools):
            b = Gtk.Button(label=lbl)
            b.get_style_context().add_class("action-btn")
            b.connect("clicked", lambda _w, f=fn: f())
            dev_grid.attach(b, idx % 2, idx // 2, 1, 1)
        box.pack_start(dev_grid, False, False, 0)

        # Port Scanner Header
        p_head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        p_lbl = Gtk.Label(label="󰒋 Active Localhost Ports (Klik ✕ untuk Kill):")
        p_lbl.get_style_context().add_class("song-artist")
        p_head.pack_start(p_lbl, False, False, 0)

        ref_b = Gtk.Button(label="󰑐 Refresh")
        ref_b.get_style_context().add_class("action-btn")
        ref_b.connect("clicked", lambda _w: self.refresh_ports())
        p_head.pack_end(ref_b, False, False, 0)
        box.pack_start(p_head, False, False, 0)

        # Scrollable Port List
        p_scroll = Gtk.ScrolledWindow()
        p_scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.port_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        p_scroll.add(self.port_box)
        box.pack_start(p_scroll, True, True, 0)

        self.stack.add_named(box, "dev")

    def refresh_ports(self):
        for child in self.port_box.get_children():
            self.port_box.remove(child)

        out = run_cmd("ss -tulpn")
        entries = []
        seen_ports = set()
        for line in out.splitlines():
            if "LISTEN" not in line:
                continue
            parts = line.split()
            if len(parts) < 5:
                continue
            local_addr = parts[4]
            port = local_addr.rsplit(":", 1)[-1]
            if not port.isdigit() or port in seen_ports:
                continue
            m_proc = re.search(r'\("([^"]+)",pid=(\d+)', line)
            if m_proc:
                pname, pid = m_proc.group(1), m_proc.group(2)
                seen_ports.add(port)
                entries.append((port, pname, pid))

        if not entries:
            empty_lbl = Gtk.Label(label="Tidak ada dev server port yang aktif saat ini.")
            empty_lbl.get_style_context().add_class("song-artist")
            self.port_box.pack_start(empty_lbl, False, False, 8)
        else:
            for port, pname, pid in entries[:8]:
                row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
                row.get_style_context().add_class("card")
                lbl = Gtk.Label(label=f":{port}  •  {pname} (PID {pid})")
                lbl.set_xalign(0)
                row.pack_start(lbl, True, True, 0)
                kb = Gtk.Button(label="Kill ✕")
                kb.get_style_context().add_class("kill-btn")
                kb.connect("clicked", self.kill_port_pid, pid, port, pname)
                row.pack_end(kb, False, False, 0)
                self.port_box.pack_start(row, False, False, 0)

        self.port_box.show_all()

    def kill_port_pid(self, _btn, pid, port, pname):
        subprocess.call(f"kill -9 {pid}", shell=True)
        subprocess.Popen([
            "notify-send", "-t", "1800",
            "󰒋 Port Dihentikan",
            f"Port :{port} ({pname}) berhasil di-kill",
        ])
        self.refresh_ports()

    def pick_screen_color(self):
        self.hide()
        while Gtk.events_pending():
            Gtk.main_iteration()
        cmd = (
            "sleep 0.2 && "
            "hex=$(magick import -window root -depth 8 -crop 1x1+$(xdotool getmouselocation --shell | awk -F= '/X=/{x=$2}/Y=/{y=$2}END{print x\"+\"y}') txt:- | awk 'NR==2{print $3}') && "
            "printf '%s' \"$hex\" | xclip -selection clipboard && "
            "notify-send -t 2500 '󰔊 Warna Tersalin' \"Kode HEX: $hex (di posisi kursor)\""
        )
        subprocess.Popen(cmd, shell=True)
        self.cleanup_and_quit()

    # -------------------------------------------------------------------------
    # Smart Mode Toggles
    # -------------------------------------------------------------------------
    def toggle_caffeine(self, _btn):
        if os.path.exists(CAFFEINE_STATE):
            os.remove(CAFFEINE_STATE)
            subprocess.Popen("xset s on +dpms", shell=True)
            subprocess.Popen(["notify-send", "-t", "1500", "󰅶 Anti-Sleep Nonaktif", "Layar dapat tidur normal"])
        else:
            open(CAFFEINE_STATE, "w").close()
            subprocess.Popen("xset s off -dpms", shell=True)
            subprocess.Popen(["notify-send", "-t", "1500", "󰅶 Anti-Sleep Aktif", "Layar tidak akan mati otomatis"])
        self.update_toggle_styles()

    def toggle_dnd(self, _btn):
        subprocess.call("dunstctl set-paused toggle", shell=True)
        self.update_toggle_styles()

    def toggle_night(self, _btn):
        if os.path.exists(NIGHT_STATE):
            os.remove(NIGHT_STATE)
            subprocess.Popen("xrandr --output eDP-1 --gamma 1.0:1.0:1.0", shell=True)
        else:
            open(NIGHT_STATE, "w").close()
            subprocess.Popen("xrandr --output eDP-1 --gamma 1.0:0.88:0.76", shell=True)
        self.update_toggle_styles()

    def update_toggle_styles(self):
        states = [
            (self.btn_caffeine, os.path.exists(CAFFEINE_STATE)),
            (self.btn_dnd, run_cmd("dunstctl is-paused") == "true"),
            (self.btn_night, os.path.exists(NIGHT_STATE)),
        ]
        for btn, is_on in states:
            ctx = btn.get_style_context()
            ctx.remove_class("toggle-on")
            ctx.remove_class("toggle-off")
            ctx.add_class("toggle-on" if is_on else "toggle-off")

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
        self.phase += 0.25
        for i in range(len(self.bars)):
            if self.is_playing:
                target = (
                    0.35
                    + 0.30 * math.sin(self.phase + i * 0.5)
                    + 0.25 * math.cos(self.phase * 1.7 - i * 0.3)
                    + random.uniform(-0.08, 0.12)
                )
                target = max(0.10, min(0.95, target))
            else:
                target = 0.12 + 0.04 * math.sin(self.phase * 0.5 + i * 0.4)
            self.bars[i] += (target - self.bars[i]) * 0.45

        self.big_vis.queue_draw()
        return True

    def draw_visualizer(self, widget, cr):
        w = widget.get_allocated_width()
        h = widget.get_allocated_height()
        n = len(self.bars)
        gap = 3
        bar_w = max(3, (w - (n - 1) * gap) / n)

        grad = cairo.LinearGradient(0, h, w, 0)
        if self.vis_theme == 0:
            grad.add_color_stop_rgba(0.0, 0.796, 0.651, 0.969, 0.95)  # Mauve
            grad.add_color_stop_rgba(0.5, 0.537, 0.706, 0.980, 0.95)  # Blue
            grad.add_color_stop_rgba(1.0, 0.580, 0.886, 0.835, 0.95)  # Teal
        elif self.vis_theme == 1:
            grad.add_color_stop_rgba(0.0, 0.953, 0.545, 0.659, 0.95)  # Red/Pink
            grad.add_color_stop_rgba(1.0, 0.796, 0.651, 0.969, 0.95)  # Mauve
        else:
            grad.add_color_stop_rgba(0.0, 0.651, 0.890, 0.631, 0.95)  # Green
            grad.add_color_stop_rgba(1.0, 0.580, 0.886, 0.835, 0.95)  # Teal
        cr.set_source(grad)

        for i, val in enumerate(self.bars):
            bh = max(4, val * (h - 6))
            x = i * (bar_w + gap)
            y = h - bh
            r = min(bar_w / 2, 3)
            cr.new_sub_path()
            cr.arc(x + bar_w - r, y + r, r, -math.pi / 2, 0)
            cr.arc(x + bar_w - r, y + bh - r, r, 0, math.pi / 2)
            cr.arc(x + r, y + bh - r, r, math.pi / 2, math.pi)
            cr.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2)
            cr.close_path()
            cr.fill()
        return False

    def refresh_status(self):
        # Update Telemetry Strip
        mem = run_cmd("free -h | awk '/^Mem:/ {print $3}' | sed 's/i//g'") or "N/A"
        disk = run_cmd("df -h / | awk 'NR==2 {print $5}'") or "N/A"
        temp = "N/A"
        for tz in glob.glob("/sys/class/thermal/thermal_zone*/temp"):
            try:
                with open(tz) as f:
                    temp = f"{int(f.read().strip()) // 1000}°C"
                break
            except Exception:
                pass
        load = run_cmd("awk '{printf \"%.0f%%\", $1 * 25}' /proc/loadavg") or "0%"
        self.telem_lbl.set_text(f"󰻠 CPU {load}   •   󰍛 {mem}   •   󰔏 {temp}   •   󰋊 {disk}")

        # Update Media Status
        status = run_cmd("playerctl status")
        self.is_playing = status == "Playing"
        if status in ("Playing", "Paused"):
            title = run_cmd("playerctl metadata xesam:title") or "Media Stream"
            artist = run_cmd("playerctl metadata xesam:artist") or status
            icon = "󰎆" if self.is_playing else "󰏤"
            self.dash_song_lbl.set_text(f"{icon} {title}")
            self.music_title.set_text(title)
            self.music_artist.set_text(f"{artist}  •  ({status})")
        else:
            self.dash_song_lbl.set_text("󰎆 Belum ada musik diputar")
            self.music_title.set_text("Belum Ada Musik Diputar")
            self.music_artist.set_text("Putar lagu di YouTube / Spotify / MPV")
        return True

    def on_vol_changed(self, scale):
        val = int(scale.get_value())
        subprocess.Popen(f"pamixer --set-volume {val}", shell=True)

    def on_br_changed(self, scale):
        val = int(scale.get_value())
        subprocess.Popen(f"brightnessctl -q set {val}%", shell=True)

    def launch_and_close(self, cmd):
        subprocess.Popen(f"setsid -f {cmd} >/dev/null 2>&1", shell=True)
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
        if arg in ("dash", "music", "wall", "dev"):
            tab = arg

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
    w, h, _ = win.SIZES[win.size_idx]
    if win.size_idx == 0:
        win.move((1366 - w) // 2, 36)
    else:
        win.move((1366 - w) // 2, (768 - h) // 2)
    win.show_all()
    win.switch_tab(tab)
    win.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
    Gtk.main()


if __name__ == "__main__":
    main()
