-- Basic Keymaps
-- See `:help vim.keymap.set()` and `:h Select-mode-mapping` for details

-- Clear highlight on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Shortcut to exit the buildin terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode to move, but allow them to resize window instead
vim.keymap.set('n', '<left>', ':vertical resize -10<CR>')
vim.keymap.set('n', '<right>', ':vertical resize +10<CR>')
vim.keymap.set('n', '<up>', ':resize resize -10<CR>')
vim.keymap.set('n', '<down>', ':resize resize +10<CR>')

-- Macro shortcuts
vim.keymap.set('n', 'Q', '@@', { desc = 'Store previous macro in Q' })
vim.keymap.set(
  'x',
  'Q',
  ":'<,'> :normal @@<CR>",
  { desc = 'Repeat the previous macro with Q in visual selected lines' }
)
vim.keymap.set('x', '.', ':normal .<CR>', { desc = 'Repeat the last motion with . on visual selected lines' })

-- Keep at center of the window when scrolling window, and searching
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', '*', '*zzzv')
vim.keymap.set('n', '#', '#zzzv')

-- Move visually selected lines around
vim.keymap.set('v', 'J', "move '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', 'J', "move '>-2<CR>gv=gv", { silent = true })

-- Visually select last yanked or changed text
vim.keymap.set('n', 'gV', '`[v`]', { silent = true })

-- Paste over highlighted text without yanking
vim.keymap.set('v', 'p', '"_dp')
vim.keymap.set('v', 'P', '"_dP')
