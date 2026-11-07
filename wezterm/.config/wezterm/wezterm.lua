local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Palette Catppuccin Mocha
config.color_scheme = "Catppuccin Mocha"

-- Font Ukuran Rapi & Pas untuk Layar 1366x768
config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font", weight = "Regular" },
  "Noto Sans Mono",
  "Noto Color Emoji",
})
config.font_size = 9.0
config.line_height = 1.05

-- Aktifkan Kitty Graphics Protocol agar Fastfetch menampilkan gambar PNG (~/logo.png)
config.enable_kitty_graphics = true
config.enable_wayland = true
config.front_end = "OpenGL"

-- GUI Tab Bar Kompak di Atas dengan Tombol [+] Tambah Tab & [x] Tutup Tab
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.show_close_tab_button_in_tabs = true
config.tab_bar_at_bottom = false

config.window_frame = {
  font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
  font_size = 8.5,
  active_titlebar_bg = "#11111b",
  inactive_titlebar_bg = "#11111b",
}

config.colors = {
  tab_bar = {
    background = "#11111b",
    active_tab = {
      bg_color = "#cba6f7",
      fg_color = "#11111b",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#a6adc8",
    },
    inactive_tab_hover = {
      bg_color = "#313244",
      fg_color = "#cdd6f4",
    },
    new_tab = {
      bg_color = "#313244",
      fg_color = "#cba6f7",
    },
    new_tab_hover = {
      bg_color = "#cba6f7",
      fg_color = "#11111b",
      intensity = "Bold",
    },
  },
}

-- Tampilan Window & Cursor Kompak
config.window_background_opacity = 0.96
config.window_padding = {
  left = 8,
  right = 8,
  top = 6,
  bottom = 6,
}
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 550
config.scrollback_lines = 10000
config.window_close_confirmation = "NeverPrompt"

-- Shortcut Keyboard di dalam Terminal
config.keys = {
  { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },

  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "1", mods = "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "ALT", action = act.ActivateTab(2) },
  { key = "4", mods = "ALT", action = act.ActivateTab(3) },
  { key = "5", mods = "ALT", action = act.ActivateTab(4) },

  { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
}

return config
