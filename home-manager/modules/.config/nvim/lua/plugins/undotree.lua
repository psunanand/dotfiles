-- Visualize undo history
return {
  'mbbill/undotree',
  keys = { { '<leader>uu', '<cmd>UndotreeToggle<cr>', mode = 'n', desc = 'Toggle Undotree' } },
}
