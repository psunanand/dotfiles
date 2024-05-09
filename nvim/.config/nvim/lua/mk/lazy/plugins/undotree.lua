-- Visualize the undo history and make it easy to browse and switch between different undo branches

return {
  'mbbill/undotree',

  vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle),
}

-- vim: ts=2 sts=2 sw=2 et
