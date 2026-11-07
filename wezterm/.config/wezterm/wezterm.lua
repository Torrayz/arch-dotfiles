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

-- GUI Tab Bar Kompak di Atas dengan Tombol [+] Hijau & [x] Merah + Varian Warna per Tab
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

-- Warna Varian Tab Bar:
-- * fg_color (#f38ba8 Merah Coral) otomatis memberi warna Merah pada ikon silang [x] di tiap tab!
-- * new_tab (#a6e3a1 Hijau Emerald) memberi warna Hijau menyala pada tombol tambah [+]!
config.colors = {
  tab_bar = {
    background = "#11111b",
    active_tab = {
      bg_color = "#313244",
      fg_color = "#f38ba8",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#181825",
      fg_color = "#f38ba8",
    },
    inactive_tab_hover = {
      bg_color = "#313244",
      fg_color = "#f38ba8",
    },
    new_tab = {
      bg_color = "#a6e3a1",
      fg_color = "#11111b",
      intensity = "Bold",
    },
    new_tab_hover = {
      bg_color = "#94e2d5",
      fg_color = "#11111b",
      intensity = "Bold",
    },
  },
}

-- Palet Warna-Warni Catppuccin untuk Badge Tiap Tab Terminal
local tab_accents = {
  "#cba6f7", -- Tab 1: Mauve (Ungu)
  "#89b4fa", -- Tab 2: Blue (Biru)
  "#fab387", -- Tab 3: Peach (Oranye)
  "#a6e3a1", -- Tab 4: Green (Hijau)
  "#f5c2e7", -- Tab 5: Pink (Merah Muda)
  "#f9e2af", -- Tab 6: Yellow (Kuning)
  "#94e2d5", -- Tab 7: Teal (Toska)
}

local function get_proc_icon(title)
  local t = string.lower(title or "")
  if string.find(t, "nvim") or string.find(t, "vim") then
    return " "
  elseif string.find(t, "node") or string.find(t, "npm") or string.find(t, "bun") then
    return "󰎙 "
  elseif string.find(t, "python") then
    return "󰌠 "
  elseif string.find(t, "git") or string.find(t, "lazygit") then
    return "󰊢 "
  elseif string.find(t, "btop") or string.find(t, "htop") then
    return "󰻠 "
  else
    return "󰆍 "
  end
end

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
  local idx = (tab.tab_index % #tab_accents) + 1
  local accent = tab_accents[idx]
  local title = tab.active_pane.title or "zsh"
  local icon = get_proc_icon(title)

  if #title > 18 then
    title = string.sub(title, 1, 17) .. "…"
  end

  if tab.is_active then
    return {
      { Background = { Color = accent } },
      { Foreground = { Color = "#d20f39" } },
      { Text = "" },
      { Foreground = { Color = "#11111b" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. tostring(tab.tab_index + 1) .. " " .. icon .. title .. " " },
    }
  else
    local bg = hover and "#313244" or "#1e1e2e"
    return {
      { Background = { Color = bg } },
      { Foreground = { Color = "#f38ba8" } },
      { Text = " " },
      { Foreground = { Color = accent } },
      { Attribute = { Intensity = "Bold" } },
      { Text = tostring(tab.tab_index + 1) .. " " .. icon },
      { Foreground = { Color = "#cdd6f4" } },
      { Text = title .. " " },
    }
  end
end)

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
