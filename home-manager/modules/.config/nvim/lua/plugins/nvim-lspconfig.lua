-- Handle LSP servers and their configs with Mason installer
-- if vim.g.mason_enabled = true
return {
  'mason-org/mason-lspconfig.nvim',
  enabled = vim.g.mason_enabled,
  opts = {},
  dependencies = {
    { 'mason-org/mason.nvim', opts = {}, enabled = vim.g.mason_enabled },
    { 'neovim/nvim-lspconfig', opts = {}, enabled = vim.g.mason_enabled },
  },
}
