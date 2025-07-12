if not vim.g.mason_enabled then
  vim.lsp.enable({
    'lua_ls',
    'bashls',
    'nixd',
  })
end

local capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.config('*', {
  capabilities = capabilities,
  root_markers = { '.git' },
})

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  update_in_insert = false,
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
    map('n', 'grn', vim.lsp.buf.rename, 'Rename')
    map('n', 'gri', require('fzf-lua').lsp_implementations, 'Go to Implementations')
    map('n', 'g0', require('fzf-lua').lsp_document_symbols, 'Document Symbols')
    map('n', 'gW', require('fzf-lua').lsp_live_workspace_symbols, 'Workspace Symbols')
    map('n', 'grh', vim.lsp.buf.signature_help, 'Signature Documentation')
    map({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, 'Code Action')

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client then
      if client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

        -- Highlight all instances of the symbol under the cursor when the cursor stops
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })
        -- Clear the the highlight when the cursor moves
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        -- Clear the highlight after LSP detaches
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

local function lsp_restart()
  local bufnr = vim.api.nvim_get_current_buf()
  local attached_clients = vim.lsp.get_clients({ bufnr = bufnr })
  vim.lsp.stop_client(attached_clients)
  vim.defer_fn(vim.cmd.edit, 10)
end

vim.api.nvim_create_user_command('LspRestart', lsp_restart, { desc = 'Restart LSP' })

local function lsp_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local attached_clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #attached_clients == 0 then
    vim.notify('No LSP clients attached', vim.log.levels.WARN)
    return
  end

  vim.notify('[LSP Status] for buffer ID ' .. bufnr .. ':', vim.log.levels.INFO)

  for i, attached_client in ipairs(attached_clients) do
    vim.notify(
      string.format('- Client %d: %s (ID: %d)', i, attached_client.name, attached_client.id),
      vim.log.levels.INFO
    )
    vim.notify('- Root Directory: ' .. (attached_client.config.root_dir or 'N/A'), vim.log.levels.INFO)
    vim.notify('- Filetype: ' .. table.concat(attached_client.config.filetypes or {}, ', '), vim.log.levels.INFO)

    local attached_capabilities = attached_client.server_capabilities
    local server_capabilities = {}
    if attached_capabilities ~= nil then
      if attached_capabilities.completionProvider then
        table.insert(server_capabilities, 'completion')
      end
      if attached_capabilities.hoverProvider then
        table.insert(server_capabilities, 'hover')
      end
      if attached_capabilities.signatureHelpProvider then
        table.insert(server_capabilities, 'signature help')
      end
      if attached_capabilities.definitionProvider then
        table.insert(server_capabilities, 'definition')
      end
      if attached_capabilities.referencesProvider then
        table.insert(server_capabilities, 'references')
      end
      if attached_capabilities.renameProvider then
        table.insert(server_capabilities, 'rename')
      end
      if attached_capabilities.codeActionProvider then
        table.insert(server_capabilities, 'code_action')
      end
      if attached_capabilities.documentFormattingProvider then
        table.insert(server_capabilities, 'formatting')
      end
    end

    vim.notify('- Capabilities: ' .. table.concat(server_capabilities, ', '), vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command('LspStatus', lsp_status, { desc = 'Show LSP status' })
