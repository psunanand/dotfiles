-- Interacting with databases in Neovim
--
-- See `https://www.youtube.com/watch?v=ALGBuFLzDSA`

return {
  'tpope/vim-dadbod',
  'kristijanhusak/vim-dadbod-completion',
  'kristijanhusak/vim-dadbod-ui',

  dependencies = {
    'hrsh7th/nvim-cmp',
  },
  config = function()
    local cmp = require 'cmp'
    cmp.setup.filetype({ 'sql' }, {
      sources = {
        { name = 'vim-dadbod-completion' },
        { name = 'buffer' },
      },
    })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
