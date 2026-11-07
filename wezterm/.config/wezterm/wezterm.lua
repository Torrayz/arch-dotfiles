local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Palette Catppuccin Mocha
config.color_scheme = "Catppuccin Mocha"

-- Font & Ukuran yang Nyaman untuk Coding
config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font", weight = "Medium" },
  "Noto Sans Mono",
  "Noto Color Emoji",
})
config.font_size = 11.5
config.line_height = 1.15

-- Aktifkan Kitty Graphics Protocol agar Fastfetch bisa menampilkan gambar PNG (~/logo.png)
config.enable_kitty_graphics = true
config.enable_wayland = true
config.front_end = "OpenGL"

-- GUI Tab Bar di Atas dengan Tombol [+] Tambah Tab & [x] Tutup Tab seperti Windows Terminal / CMD
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.show_close_tab_button_in_tabs = true
config.tab_bar_at_bottom = false

config.window_frame = {
  font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
  font_size = 10.5,
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

-- Tampilan Window & Cursor
config.window_background_opacity = 0.96
config.window_padding = {
  left = 14,
  right = 14,
  top = 12,
  bottom = 10,
}
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 550
config.scrollback_lines = 10000
config.window_close_confirmation = "NeverPrompt"

-- Shortcut Keyboard di dalam Terminal
config.keys = {
  -- Tab Baru & Tutup Tab (mirip browser / CMD modern)
  { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },

  -- Pindah antar Tab
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "1", mods = "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "ALT", action = act.ActivateTab(2) },
  { key = "4", mods = "ALT", action = act.ActivateTab(3) },
  { key = "5", mods = "ALT", action = act.ActivateTab(4) },

  -- Split Layar di dalam Terminal
  { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Copy & Paste mudah
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- Zoom ukuran font
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
}

return config
