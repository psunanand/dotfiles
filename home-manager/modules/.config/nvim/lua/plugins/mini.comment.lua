-- Comment lines
return {
  'echasnovski/mini.comment',
  event = 'VeryLazy',
  dependencies = {
    { 'JoosepAlviste/nvim-ts-context-commentstring', opts = {
      enable_autocmd = false,
    } },
  },
  opts = {
    options = {
      custom_commentstring = function()
        return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
      end,
    },
  },
}
