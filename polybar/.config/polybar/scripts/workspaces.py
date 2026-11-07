#!/usr/bin/env python3
# =============================================================================
# Dynamic i3 Workspaces with Live Application Logos per Session (Polybar)
# Subscribes to i3 IPC workspace + window events for 0ms real-time updates
# =============================================================================

import json
import subprocess
import sys
import time

IGNORE_CLASSES = {"nm-applet", "torray-hub.py", "rofi", "dunst"}


def get_app_icon_and_color(win_class, win_instance, win_title):
    c = (win_class or "").lower()
    i = (win_instance or "").lower()
    t = (win_title or "").lower()
    key = f"{c} {i}"

    if "code" in key or "vscodium" in key:
        return ("󰨞", "#89b4fa")  # VS Code (Blue)
    if "firefox" in key or "navigator" in key:
        return ("󰈹", "#fab387")  # Firefox (Peach)
    if any(b in key for b in ("chrome", "chromium", "brave")):
        return ("", "#f9e2af")  # Browser (Yellow)
    if any(term in key for term in ("wezterm", "kitty", "alacritty", "xterm", "uxterm", "foot")):
        if "btop" in t or "htop" in t:
            return ("󰻠", "#74c7ec")  # System Monitor
        if "nvim" in t or "vim" in t:
            return ("", "#a6e3a1")  # Neovim
        return ("󰆍", "#a6e3a1")  # Terminal (Green)
    if any(fm in key for fm in ("thunar", "nautilus", "pcmanfm", "dolphin", "nemo")):
        return ("󰉋", "#f9e2af")  # File Manager (Yellow)
    if any(m in key for m in ("spotify", "mpv", "vlc", "audacious")):
        return ("󰎆", "#94e2d5")  # Media (Teal)
    if any(ch in key for ch in ("discord", "vesktop", "telegram", "slack")):
        return ("󰙯", "#cba6f7")  # Chat (Mauve)
    if any(im in key for im in ("gimp", "inkscape", "feh", "flameshot", "swappy")):
        return ("󰋩", "#f5c2e7")  # Image/Design (Pink)
    return ("󰣆", "#cdd6f4")


def collect_workspace_windows(tree):
    ws_windows = {}

    def walk(node, current_ws=None):
        ntype = node.get("type")
        if ntype == "workspace":
            current_ws = node.get("name")
            if current_ws and current_ws != "__i3_scratch":
                ws_windows.setdefault(current_ws, [])

        if current_ws and current_ws != "__i3_scratch" and node.get("window"):
            props = node.get("window_properties", {})
            wclass = props.get("class") or ""
            winst = props.get("instance") or ""
            wtitle = node.get("name") or props.get("title") or ""
            if wclass.lower() not in IGNORE_CLASSES and winst.lower() not in IGNORE_CLASSES:
                ws_windows.setdefault(current_ws, []).append((wclass, winst, wtitle))

        for child in node.get("nodes", []) + node.get("floating_nodes", []):
            walk(child, current_ws)

    walk(tree)
    return ws_windows


def render_workspaces():
    try:
        ws_raw = subprocess.check_output(["i3-msg", "-t", "get_workspaces"], stderr=subprocess.DEVNULL)
        tree_raw = subprocess.check_output(["i3-msg", "-t", "get_tree"], stderr=subprocess.DEVNULL)
        workspaces = json.loads(ws_raw.decode("utf-8"))
        tree = json.loads(tree_raw.decode("utf-8"))
    except Exception:
        return ""

    ws_windows = collect_workspace_windows(tree)
    parts = []

    for ws in workspaces:
        name = ws.get("name", "1")
        focused = ws.get("focused", False)
        urgent = ws.get("urgent", False)
        windows = ws_windows.get(name, [])

        icons_active = []
        icons_inactive = []
        for wclass, winst, wtitle in windows[:4]:
            icon, color = get_app_icon_and_color(wclass, winst, wtitle)
            icons_active.append(f"{icon}")
            icons_inactive.append(f"%{{F{color}}}{icon}%{{F-}}")

        if len(windows) > 4:
            icons_active.append("+")
            icons_inactive.append("+")

        cmd_click = f"i3-msg -q workspace '{name}'"
        if focused:
            icon_str = ("  " + "  ".join(icons_active) + "  ") if icons_active else " "
            pill = f"%{{B#89b4fa}}%{{F#11111b}} {name}{icon_str}%{{B-}}%{{F-}}"
        elif urgent:
            icon_str = ("  " + "  ".join(icons_active) + "  ") if icons_active else " "
            pill = f"%{{B#f38ba8}}%{{F#11111b}} {name}{icon_str}%{{B-}}%{{F-}}"
        else:
            icon_str = ("  " + "  ".join(icons_inactive) + "  ") if icons_inactive else " "
            pill = f"%{{B#1e1e2e}}%{{F#a6adc8}} {name}{icon_str}%{{B-}}%{{F-}}"

        parts.append(
            f"%{{A1:{cmd_click}:}}%{{A4:i3-msg -q workspace prev:}}%{{A5:i3-msg -q workspace next:}}{pill}%{{A}}%{{A}}%{{A}}"
        )

    return "%{B#11111b} %{B-}".join(parts)


def main():
    if "--once" in sys.argv:
        print(render_workspaces(), flush=True)
        return

    print(render_workspaces(), flush=True)
    while True:
        try:
            proc = subprocess.Popen(
                ["i3-msg", "-t", "subscribe", "-m", '["workspace", "window"]'],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
            )
            for _line in proc.stdout:
                print(render_workspaces(), flush=True)
        except Exception:
            time.sleep(0.5)


if __name__ == "__main__":
    main()
