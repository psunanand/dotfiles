-- Colorscheme that reduces eye fatigue
return {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    compile = true,
    undercurl = true,
    dimInactive = true,
    terminalColors = true,
    theme = 'dragon',
    background = {
      dark = 'dragon',
      light = 'lotus',
    },
  },
  config = function(_, opts)
    require('kanagawa').setup(opts)
    vim.cmd('colorscheme kanagawa')
  end,
  build = function()
    vim.cmd('KanagawaCompile')
  end,
}
