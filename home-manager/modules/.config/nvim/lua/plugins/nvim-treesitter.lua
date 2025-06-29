return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPre', 'BufNewFile' },
  lazy = false,
  config = function()
    require('nvim-treesitter.configs').setup({
      -- managed externally by nix (vimPlugins.nvim-treesitter.withAllGrammars)
      ensure_installed = 'all',
      ignore_install = {},
      auto_install = vim.g.mason_enabled,
      sync_install = false,
      highlight = {
        enable = true,
      },
      autopairs = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-Enter>',
          node_incremental = '<C-Enter>',
          scope_incremental = false,
          node_decremental = '<BackSpace>',
        },
      },
    })
  end,
}
