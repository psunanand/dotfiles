-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlight on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode to move, but allow them to resize window instead
vim.keymap.set('n', '<left>', ':vertical resize -10<CR>')
vim.keymap.set('n', '<right>', ':vertical resize +10<CR>')
vim.keymap.set('n', '<up>', ':resize resize -10<CR>')
vim.keymap.set('n', '<down>', ':resize resize +10<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Macro shortcuts
vim.keymap.set('n', 'Q', '@@', { desc = 'Store previous macro in Q' })
vim.keymap.set('x', 'Q', ":'<,'> :normal @@<CR>", { desc = 'Repeat the previous macro with Q in [V]isual selected lines' })
vim.keymap.set('x', '.', ':normal .<CR>', { desc = 'Repeat the last motion with . on [V]isual selected lines' })

-- TIP: Keep at center of the window when scrolling window, and searching
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', '*', '*zzzv')
vim.keymap.set('n', '#', '#zzzv')

-- Move visually selected lines around
vim.keymap.set('v', 'J', "move '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', 'J', "move '>-2<CR>gv=gv", { silent = true })

-- vim: ts=2 sts=2 sw=2 et
--
