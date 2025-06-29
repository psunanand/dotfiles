-- Setting options
-- Check `:help option-list`

local g = vim.g
local opt = vim.opt

-- Allow to disable Mason if we manage LSP, Debug, linting/formatting tools by ourselves
g.mason_enabled = false

-- Set <space> as the leader key
g.mapleader = ' '

-- Set <space> as the local leader key
g.maplocalleader = ' '

-- Make line numbers default
opt.number = true

-- Add relative line numbers
opt.relativenumber = true

-- Enable mouse mode to resize splits
opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- Don't wrap the lines longer than the width of the window
opt.wrap = false

-- Always show signcolumn
opt.signcolumn = 'yes'

-- Set highlight on search
opt.hlsearch = true

-- Sync clipboard between OS and Neovim.
opt.clipboard = 'unnamedplus'

-- Enable break indent
opt.breakindent = true

-- Copy indent from current line when starting a new line
opt.autoindent = true

-- Save undo history
opt.undofile = true

-- Don't use swapfile
opt.swapfile = false

-- Case-insensitive search
opt.ignorecase = true

-- UNLESS \C or one or more capital letters in the search term
opt.smartcase = true

-- Do smart auto indent when starting a new line
opt.smartindent = true

-- Convert `tab` to `space`
opt.expandtab = true

-- Number of spaces to indent with `<<` and `>>`
opt.shiftwidth = 4

-- Number of spaces shown per `tab`
opt.tabstop = 4

-- Number of spaces to indent when pressing `tab`
opt.softtabstop = 4

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Decrease update time from 4k milliseconds
opt.updatetime = 250

-- Set terminal to true color
opt.termguicolors = true

-- Vertical-split on the right
opt.splitright = true

-- Horizontal-split below the current window
opt.splitbelow = true

-- Preview substitutions live
opt.inccommand = 'split'

-- Show which line the cursor is on
opt.cursorline = true

-- # of screen lines to keep above and below the cursor. 999 = cursorline is always in the middle
opt.scrolloff = 999

-- Allow positioning the cursor when there is no actual character in visual block mode
opt.virtualedit = 'block'

-- Set how neovim will display certain whitespace characters in the editor.
-- See `:help 'list'` and `:help 'listchars'`
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Solid border style of floating windows
opt.winborder = 'rounded'
