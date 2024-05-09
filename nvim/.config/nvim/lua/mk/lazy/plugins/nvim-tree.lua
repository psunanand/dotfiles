-- File Explorer Tree

return {
  'nvim-tree/nvim-tree.lua',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    -- disable netrw at the start
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require('nvim-tree').setup {
      view = {
        width = 35,
        relativenumber = true,
      },
      renderer = {
        indent_markers = { enable = true },
        highlight_git = true,
        icons = {
          show = {
            git = true,
          },
        },
      },
      git = {
        enable = true,
        ignore = false,
      },
    }
  end,

  vim.keymap.set('n', '<leader>t', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer [T]ree' }),
}

-- vim: ts=2 sts=2 sw=2 et
