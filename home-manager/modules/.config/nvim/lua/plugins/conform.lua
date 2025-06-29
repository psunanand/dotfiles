-- Autoformat by filetype
return {
  {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format({ async = true }, function(err, is_edited)
            if not err and is_edited then
              vim.notify('Code formatted', vim.log.levels.INFO, { title = 'Conform' })
            end
          end)
        end,
        mode = { 'n', 'v' },
        desc = 'Format Buffer',
      },
    },
    opts = {
      format_on_save = function(bufnr)
        local disable_filetypes = {}
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      default_format_opts = {
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        zsh = { 'shfmt' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
        nix = { 'nixfmt' },
        ['_'] = { 'trim_whitespace', 'trim_newlines' },
      },
    },
  },
}
