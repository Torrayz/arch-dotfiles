#!/usr/bin/env python3
# =============================================================================
# Torray Clip — Windows 11 Style Visual Clipboard Manager (Super + V)
# Features:
#   - Captures both Copied Text AND Screenshots / Images (with visual thumbnails)
#   - Event-driven GTK3 Clipboard Watcher Daemon (--daemon)
#   - Interactive Floating Popup UI (--popup) with Search, Pin, Delete, Auto-Paste
#   - Includes [󰊓 S / M / L] Dynamic Size Switcher in Header Bar
# =============================================================================

import hashlib
import json
import os
import signal
import subprocess
import sys
import time

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk, Pango

CACHE_DIR = os.path.expanduser("~/.cache/torray-clip")
HISTORY_FILE = os.path.join(CACHE_DIR, "history.json")
POPUP_PID_FILE = "/tmp/torray_clip_popup.pid"
DAEMON_PID_FILE = "/tmp/torray_clip_daemon.pid"
SIZE_STATE = "/tmp/torray_clip_size"
MAX_ITEMS = 35

CSS = b"""
window {
    background-color: rgba(24, 24, 37, 0.90);
    color: #cdd6f4;
    border: 1.5px solid #cba6f7;
    border-radius: 10px;
    font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
    font-size: 8pt;
}
button {
    background-image: none;
    background-color: rgba(49, 50, 68, 0.88);
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 6px;
    padding: 2px 6px;
    box-shadow: none;
    text-shadow: none;
    min-height: 0;
    min-width: 0;
}
button:hover {
    background-image: none;
    background-color: #cba6f7;
    color: #11111b;
    border-color: #cba6f7;
}
.header-bar {
    background-color: rgba(17, 17, 27, 0.92);
    padding: 5px 8px;
    border-bottom: 1px solid #313244;
}
.title-label {
    color: #cba6f7;
    font-weight: bold;
    font-size: 8.5pt;
}
.search-entry {
    background-image: none;
    background-color: rgba(30, 30, 46, 0.85);
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 6px;
    padding: 3px 8px;
    min-height: 22px;
    font-size: 8pt;
}
.search-entry:focus {
    border-color: #cba6f7;
}
.clip-card {
    background-color: rgba(30, 30, 46, 0.88);
    border: 1px solid #313244;
    border-radius: 8px;
    padding: 6px 8px;
}
.clip-card-pinned {
    background-color: rgba(30, 30, 46, 0.88);
    border: 1.5px solid #f9e2af;
    border-radius: 8px;
    padding: 6px 8px;
}
.meta-label {
    color: #89b4fa;
    font-size: 7.2pt;
    font-weight: 600;
}
.snippet-label {
    color: #cdd6f4;
    font-size: 8pt;
}
.paste-btn {
    background-image: none;
    background-color: #89b4fa;
    color: #11111b;
    border: none;
    border-radius: 5px;
    padding: 2px 8px;
    font-weight: bold;
    font-size: 7.5pt;
}
.paste-btn:hover {
    background-color: #cba6f7;
    color: #11111b;
}
.pin-on {
    background-image: none;
    background-color: #f9e2af;
    color: #11111b;
    border: none;
    border-radius: 5px;
    padding: 2px 6px;
    font-weight: bold;
}
.del-btn {
    background-image: none;
    background-color: #f38ba8;
    color: #11111b;
    border: none;
    border-radius: 5px;
    padding: 2px 6px;
    font-weight: bold;
}
"""


def ensure_cache():
    os.makedirs(CACHE_DIR, exist_ok=True)
    if not os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE, "w") as f:
            json.dump([], f)


def load_history():
    ensure_cache()
    try:
        with open(HISTORY_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return []


def save_history(items):
    ensure_cache()
    # Keep pinned first, then newest, up to MAX_ITEMS
    pinned = [x for x in items if x.get("pinned")]
    unpinned = [x for x in items if not x.get("pinned")]
    final = (pinned + unpinned)[:MAX_ITEMS]

    # Clean up orphan image files
    kept_imgs = {x.get("path") for x in final if x.get("type") == "image"}
    for fname in os.listdir(CACHE_DIR):
        if fname.startswith("img_") and fname.endswith(".png"):
            fpath = os.path.join(CACHE_DIR, fname)
            if fpath not in kept_imgs:
                try:
                    os.remove(fpath)
                except Exception:
                    pass

    with open(HISTORY_FILE, "w") as f:
        json.dump(final, f, indent=2)


# =============================================================================
# Background Clipboard Watcher Daemon
# =============================================================================
class ClipboardDaemon:
    def __init__(self):
        ensure_cache()
        self.clip = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
        self.last_hash = ""
        self.clip.connect("owner-change", self.on_owner_change)

    def on_owner_change(self, _clipboard, _event):
        GLib.timeout_add(120, self.check_clipboard)

    def check_clipboard(self):
        now_str = time.strftime("%H:%M:%S")
        # 1. Check if an image/screenshot is in clipboard
        if self.clip.wait_is_image_available():
            pix = self.clip.wait_for_image()
            if pix is not None:
                ok, buf = pix.save_to_bufferv("png", [], [])
                if ok and buf:
                    h = hashlib.sha1(buf).hexdigest()[:12]
                    if h != self.last_hash:
                        self.last_hash = h
                        img_path = os.path.join(CACHE_DIR, f"img_{int(time.time()*1000)}_{h[:6]}.png")
                        with open(img_path, "wb") as f:
                            f.write(buf)
                        w, ht = pix.get_width(), pix.get_height()
                        items = load_history()
                        items = [x for x in items if x.get("hash") != h]
                        items.insert(0, {
                            "id": h,
                            "hash": h,
                            "type": "image",
                            "path": img_path,
                            "res": f"{w}x{ht}",
                            "time": now_str,
                            "pinned": False,
                        })
                        save_history(items)
            return False

        # 2. Check if text is in clipboard
        if self.clip.wait_is_text_available():
            txt = self.clip.wait_for_text()
            if txt and txt.strip():
                h = hashlib.sha1(txt.encode("utf-8", errors="ignore")).hexdigest()[:12]
                if h != self.last_hash:
                    self.last_hash = h
                    items = load_history()
                    was_pinned = any(x.get("hash") == h and x.get("pinned") for x in items)
                    items = [x for x in items if x.get("hash") != h]
                    items.insert(0, {
                        "id": h,
                        "hash": h,
                        "type": "text",
                        "text": txt[:4000],
                        "chars": len(txt),
                        "time": now_str,
                        "pinned": was_pinned,
                    })
                    save_history(items)
        return False


# =============================================================================
# Interactive Super + V Popup Window
# =============================================================================
class ClipboardPopup(Gtk.Window):
    SIZES = [
        (350, 330, "S"),
        (460, 430, "M"),
        (580, 520, "L"),
    ]

    def __init__(self):
        super().__init__(title="Torray Clipboard")
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

        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)
        self.set_app_paintable(True)

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.connect("key-press-event", self.on_key_press)
        self.connect("destroy", self.cleanup_and_quit)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(root)

        # Header Bar
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        header.get_style_context().add_class("header-bar")
        root.pack_start(header, False, False, 0)

        title = Gtk.Label(label="󰅌 Clipboard (Super+V)")
        title.get_style_context().add_class("title-label")
        header.pack_start(title, False, False, 2)

        close_b = Gtk.Button(label="✕")
        close_b.get_style_context().add_class("del-btn")
        close_b.connect("clicked", self.cleanup_and_quit)
        header.pack_end(close_b, False, False, 0)

        self.size_btn = Gtk.Button(label=f"󰊓 {self.SIZES[self.size_idx][2]}")
        self.size_btn.connect("clicked", self.cycle_size)
        header.pack_end(self.size_btn, False, False, 0)

        clear_b = Gtk.Button(label="󰃢 Bersihkan")
        clear_b.connect("clicked", self.clear_unpinned)
        header.pack_end(clear_b, False, False, 0)

        # Search Box
        s_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        s_box.set_margin_start(8)
        s_box.set_margin_end(8)
        self.search_entry = Gtk.Entry()
        self.search_entry.set_placeholder_text("󰍉 Cari teks atau ketik 'image' untuk screenshot...")
        self.search_entry.get_style_context().add_class("search-entry")
        self.search_entry.connect("changed", lambda _e: self.populate_list())
        s_box.pack_start(self.search_entry, True, True, 0)
        root.pack_start(s_box, False, False, 0)

        # Scrollable List of Cards
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_margin_start(8)
        scroll.set_margin_end(8)
        scroll.set_margin_bottom(8)
        self.list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        scroll.add(self.list_box)
        root.pack_start(scroll, True, True, 0)

        self.populate_list()

    def cycle_size(self, _btn):
        self.size_idx = (self.size_idx + 1) % len(self.SIZES)
        w, h, tag = self.SIZES[self.size_idx]
        try:
            with open(SIZE_STATE, "w") as f:
                f.write(str(self.size_idx))
        except Exception:
            pass
        self.size_btn.set_label(f"󰊓 {tag}")
        self.resize(w, h)
        self.move((1366 - w) // 2, (768 - h) // 2)
        self.populate_list()

    def populate_list(self):
        for child in self.list_box.get_children():
            self.list_box.remove(child)

        query = self.search_entry.get_text().strip().lower()
        items = load_history()

        filtered = []
        for item in items:
            if not query:
                filtered.append(item)
            elif item.get("type") == "image" and ("img" in query or "image" in query or "foto" in query or "screen" in query):
                filtered.append(item)
            elif item.get("type") == "text" and query in item.get("text", "").lower():
                filtered.append(item)

        if not filtered:
            empty = Gtk.Label(label="Belum ada riwayat salinan (Ctrl+C atau Screenshot untuk menyimpan).")
            empty.get_style_context().add_class("meta-label")
            self.list_box.pack_start(empty, False, False, 20)
            self.list_box.show_all()
            return

        thumb_w = 210 + self.size_idx * 70
        thumb_h = 90 + self.size_idx * 30

        for item in filtered:
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            card.get_style_context().add_class("clip-card-pinned" if item.get("pinned") else "clip-card")

            # Top Row: Type badge + Timestamp + Buttons (Paste, Pin, Delete)
            top = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
            is_img = item.get("type") == "image"
            pin_prefix = "󰐃 Pinned • " if item.get("pinned") else ""
            if is_img:
                badge_txt = f"{pin_prefix}󰋩 Gambar/Screenshot ({item.get('res', '')}) • {item.get('time', '')}"
            else:
                badge_txt = f"{pin_prefix}󰅍 Teks ({item.get('chars', 0)} chr) • {item.get('time', '')}"

            meta = Gtk.Label(label=badge_txt)
            meta.get_style_context().add_class("meta-label")
            meta.set_xalign(0)
            top.pack_start(meta, True, True, 0)

            del_b = Gtk.Button(label="✕")
            del_b.get_style_context().add_class("del-btn")
            del_b.connect("clicked", self.delete_item, item.get("id"))
            top.pack_end(del_b, False, False, 0)

            pin_b = Gtk.Button(label="󰐃")
            if item.get("pinned"):
                pin_b.get_style_context().add_class("pin-on")
            pin_b.connect("clicked", self.toggle_pin, item.get("id"))
            top.pack_end(pin_b, False, False, 0)

            use_b = Gtk.Button(label="󰅌 Tempel" if not is_img else "󰅌 Salin Gambar")
            use_b.get_style_context().add_class("paste-btn")
            use_b.connect("clicked", self.activate_item, item)
            top.pack_end(use_b, False, False, 0)

            card.pack_start(top, False, False, 0)

            # Content Preview (Visual Thumbnail for Image OR Snippet for Text)
            if is_img and os.path.exists(item.get("path", "")):
                try:
                    pix = GdkPixbuf.Pixbuf.new_from_file_at_scale(item["path"], thumb_w, thumb_h, True)
                    img = Gtk.Image.new_from_pixbuf(pix)
                    img.set_halign(Gtk.Align.START)
                    card.pack_start(img, False, False, 2)
                except Exception:
                    pass
            else:
                raw_lines = [ln.strip() for ln in item.get("text", "").splitlines() if ln.strip()][:3]
                preview_txt = "\n".join(raw_lines)
                if len(preview_txt) > 140:
                    preview_txt = preview_txt[:138] + "…"
                lbl = Gtk.Label(label=preview_txt)
                lbl.get_style_context().add_class("snippet-label")
                lbl.set_xalign(0)
                lbl.set_line_wrap(True)
                lbl.set_max_width_chars(42 + self.size_idx * 12)
                lbl.set_ellipsize(Pango.EllipsizeMode.END)
                card.pack_start(lbl, False, False, 2)

            self.list_box.pack_start(card, False, False, 0)

        self.list_box.show_all()

    def activate_item(self, _btn, item):
        if item.get("type") == "image" and os.path.exists(item.get("path", "")):
            path = item["path"]
            subprocess.Popen(f"xclip -selection clipboard -t image/png -i '{path}'", shell=True)
            subprocess.Popen(["notify-send", "-t", "1500", "󰋩 Gambar Disalin", "Siap ditempel (Ctrl+V)"])
            self.cleanup_and_quit()
        else:
            txt = item.get("text", "")
            p = subprocess.Popen(["xclip", "-selection", "clipboard"], stdin=subprocess.PIPE)
            p.communicate(input=txt.encode("utf-8"))
            self.hide()
            while Gtk.events_pending():
                Gtk.main_iteration()
            subprocess.Popen("sleep 0.12 && xdotool key --clearmodifiers ctrl+v", shell=True)
            self.cleanup_and_quit()

    def toggle_pin(self, _btn, item_id):
        items = load_history()
        for x in items:
            if x.get("id") == item_id:
                x["pinned"] = not x.get("pinned", False)
        save_history(items)
        self.populate_list()

    def delete_item(self, _btn, item_id):
        items = [x for x in load_history() if x.get("id") != item_id]
        save_history(items)
        self.populate_list()

    def clear_unpinned(self, _btn):
        items = [x for x in load_history() if x.get("pinned")]
        save_history(items)
        self.populate_list()

    def on_key_press(self, _widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.cleanup_and_quit()

    def cleanup_and_quit(self, *_args):
        if os.path.exists(POPUP_PID_FILE):
            try:
                os.remove(POPUP_PID_FILE)
            except Exception:
                pass
        Gtk.main_quit()


def main():
    if "--daemon" in sys.argv:
        if os.path.exists(DAEMON_PID_FILE):
            try:
                with open(DAEMON_PID_FILE) as f:
                    old = int(f.read().strip())
                os.kill(old, signal.SIGTERM)
            except Exception:
                pass
        with open(DAEMON_PID_FILE, "w") as f:
            f.write(str(os.getpid()))
        _daemon = ClipboardDaemon()
        Gtk.main()
        return

    # Default / --popup mode (toggle behavior)
    if os.path.exists(POPUP_PID_FILE):
        try:
            with open(POPUP_PID_FILE) as f:
                old = int(f.read().strip())
            os.kill(old, 0)
            os.kill(old, signal.SIGTERM)
            try:
                os.remove(POPUP_PID_FILE)
            except Exception:
                pass
            sys.exit(0)
        except (ProcessLookupError, OSError):
            try:
                os.remove(POPUP_PID_FILE)
            except Exception:
                pass
        except Exception:
            try:
                os.remove(POPUP_PID_FILE)
            except Exception:
                pass

    with open(POPUP_PID_FILE, "w") as f:
        f.write(str(os.getpid()))

    win = ClipboardPopup()
    win.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
