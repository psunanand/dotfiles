-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Set terminal mode to its usual behavior
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  desc = 'Enter insert mode when openning a terminal with no linenumber',
  group = vim.api.nvim_create_augroup('terminal-settings', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.cmd 'startinsert'
  end,
})

-- [[ Basic User Commands ]]
-- See `:help lua-guide-commmands`

-- Set the current directory of the current window to be the working directory
vim.api.nvim_create_user_command('Cwd', 'lcd %:p:h', { desc = 'Set the current working directory' })

-- vim: ts=2 sts=2 sw=2 et
