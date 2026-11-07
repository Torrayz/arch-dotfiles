-- ============================================================================
-- Lightweight Neovim Config — Catppuccin Mocha Highlights & Sensible Defaults
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.scrolloff = 8
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true

-- Catppuccin Mocha base colors
vim.cmd("colorscheme habamax")
vim.api.nvim_set_hl(0, "Normal", { fg = "#cdd6f4", bg = "#1e1e2e" })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#cdd6f4", bg = "#181825" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#313244" })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#6c7086" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#cba6f7", bold = true })
vim.api.nvim_set_hl(0, "Visual", { bg = "#45475a" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#6c7086", italic = true })
