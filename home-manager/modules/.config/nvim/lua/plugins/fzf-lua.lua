-- Improved Fzf
return {
  'ibhagwan/fzf-lua',
  keys = {
    {
      '<leader>sf',
      function()
        require('fzf-lua').files()
      end,
      mode = 'n',
      desc = 'Search Files',
    },
    {
      '<leader>sh',
      function()
        require('fzf-lua').helptags()
      end,
      mode = 'n',
      desc = 'Search Help',
    },
    {
      '<leader>sg',
      function()
        require('fzf-lua').live_grep()
      end,
      mode = 'n',
      desc = 'Search by Grep',
    },
    {
      '<leader>sg',
      function()
        require('fzf-lua').grep_visual()
      end,
      mode = 'x',
      desc = 'Search by Grep',
    },
    {
      '<leader>sn',
      function()
        require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })
      end,
      mode = 'n',
      desc = 'Search Neovim Configurations',
    },
    {
      '<leader>sk',
      function()
        require('fzf-lua').keymaps()
      end,
      mode = 'n',
      desc = 'Search Keymaps',
    },
    {
      '<leader>sd',
      function()
        require('fzf-lua').diagnostics_document()
      end,
      mode = 'n',
      desc = 'Search Diagnostics',
    },
    {
      '<leader>sb',
      function()
        require('fzf-lua').builtin()
      end,
      mode = 'n',
      desc = 'Search Fzf-lua Builtin',
    },
    {
      '<leader>sw',
      function()
        require('fzf-lua').grep_cword()
      end,
      mode = 'n',
      desc = 'Search `word` under cursor',
    },
    {
      '<leader>sW',
      function()
        require('fzf-lua').grep_cWord()
      end,
      mode = 'n',
      desc = 'Search `WORD` under cursor',
    },
    {
      '<leader>sr',
      function()
        require('fzf-lua').resume()
      end,
      mode = 'n',
      desc = 'Resume Search',
    },
    {
      '<leader><leader>',
      function()
        require('fzf-lua').buffers()
      end,
      mode = 'n',
      desc = 'Search Buffers',
    },
    {
      '<leader>/',
      function()
        require('fzf-lua').lgrep_curbuf()
      end,
      mode = 'n',
      desc = 'Search by Grep in current buffer',
    },
  },
  opts = {},
}

-- vim: ts=2 sts=2 sw=2 et
