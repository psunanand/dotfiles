local capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.config('*', {
  capabilities = capabilities,
  root_markers = { '.git' },
})

vim.diagnostic.config({
  virtual_lines = { current_line = true },
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
      [vim.diagnostic.severity.WARN] = 'WarningMsg',
    },
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),

  callback = function(event)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- defaults:
    -- https://neovim.io/doc/user/news-0.11.html#_defaults

    map('n', 'grd', require('fzf-lua').lsp_definitions, 'Go to Definition')
    map('n', 'grt', require('fzf-lua').lsp_typedefs, 'Go to Type Definition')
    map('n', 'gre', vim.diagnostic.setqflist, 'List diagnostics in qfix')
    map('n', 'grE', vim.diagnostic.open_float, 'Open diagnostics float')
    map('n', 'grD', require('fzf-lua').lsp_declarations, 'Go to Declaration')
    map('n', 'grr', require('fzf-lua').lsp_references, 'Go to References')
    map('n', 'grn', vim.lsp.buf.rename, 'Go to References')
    map('n', 'gri', require('fzf-lua').lsp_implementations, 'Go to Implementations')
    map('n', 'g0', require('fzf-lua').lsp_document_symbols, 'Document Symbols')
    map('n', 'gW', require('fzf-lua').lsp_live_workspace_symbols, 'Workspace Symbols')
    map('n', 'grh', vim.lsp.buf.signature_help, 'Signature Documentation')
    map({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, 'Code Action')

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client then
      if client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

        -- When cursor stops moving: Highlights all instances of the symbol under the cursor
        -- When cursor moves: Clears the highlighting
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        -- When LSP detaches: Clears the highlighting
        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
          end,
        })
      end

      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('n', 'grH', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, 'Toggle Inlay Hints')
      end
    end
  end,
})

if not vim.g.mason_enabled then
  vim.lsp.enable({
    'lua_ls',
    'bashls',
    'nixd',
  })
end
