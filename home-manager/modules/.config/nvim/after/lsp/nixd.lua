-- Make Lua LSP supports Neovim
-- Source:
-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/nixd.lua
return {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = {
    'flake.nix',
    '.git',
  },
}
