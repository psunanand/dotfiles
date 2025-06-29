-- comprehensive built-in textobjects
-- extension to nvim-treesitter-textobject
return {
  'echasnovski/mini.ai',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    local spec_treesitter = require('mini.ai').gen_spec.treesitter
    require('mini.ai').setup({
      n_lines = 100,
      custom_textobjects = {
        F = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
        o = spec_treesitter({
          a = { '@conditional.outer', '@loop.outer' },
          i = { '@conditional.inner', '@loop.inner' },
        }),
        c = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
      },
    })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
