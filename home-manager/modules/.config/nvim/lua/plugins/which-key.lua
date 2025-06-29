return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
    },

    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },

    spec = {
      -- { '<leader>s', group = '[S]earch' },
      -- { '<leader>t', group = '[T]oggle' },
      -- { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
