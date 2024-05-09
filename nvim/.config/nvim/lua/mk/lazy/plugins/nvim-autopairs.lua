-- Auto-pair multiple characters

return {
  'windwp/nvim-autopairs',
  event = { 'InsertEnter' },
  dependencies = {
    'hrsh7th/nvim-cmp',
  },
  config = function()
    local npairs = require 'nvim-autopairs'

    npairs.setup {
      check_ts = true,
      ts_config = {
        lua = { 'string' }, -- it will not add a pair on that
        javascript = { 'template_string' },
        java = false, -- don't check treesitter on java
      },
    }

    local cmp_npairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_npairs.on_confirm_done())
  end,
}

-- vim: ts=2 sts=2 sw=2 et
