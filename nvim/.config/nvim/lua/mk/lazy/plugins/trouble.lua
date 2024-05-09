-- Pretty list of showing diagnostics, references, telescope results,
-- quickfix and location lists to solve all the trouble your code is causing

return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    {
      '<leader>xx',
      function()
        require('trouble').toggle()
      end,
      mode = 'n',
      desc = 'Toggle trouble[X] list',
    },
    {
      '<leader>xw',
      function()
        require('trouble').toggle 'workspace_diagnostics'
      end,
      mode = 'n',
      desc = 'Open trouble[X] [W]orkspace',
    },
    {
      '<leader>xd',
      function()
        require('trouble').toggle 'document_diagnostics'
      end,
      mode = 'n',
      desc = 'Open trouble[X] [D]ocument',
    },
    {
      '<leader>xq',
      function()
        require('trouble').toggle 'quickfix'
      end,
      mode = 'n',
      desc = 'Open trouble[X] [Q]uickfix',
    },
    {
      '<leader>xl',
      function()
        require('trouble').toggle 'loclist'
      end,
      mode = 'n',
      desc = 'Open trouble[X] [L]ocation list',
    },
    {
      '<leader>xr',
      function()
        require('trouble').toggle 'lsp_references'
      end,
      mode = 'n',
      desc = 'Open trouble[X] LSP [R]eference',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
