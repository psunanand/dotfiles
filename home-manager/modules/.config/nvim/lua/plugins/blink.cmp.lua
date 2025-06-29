-- Completion support for LSPs, cmdline, signature help and snippets with fuzzy matcher
return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  -- useful snippet source
  dependencies = {
    'rafamadriz/friendly-snippets',
    'mgalliou/blink-cmp-tmux',
  },
  version = '*',
  build = 'nix run .#build-plugin',

  opts = {
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'default' },

    appearance = {
      nerd_font_variant = 'mono',
    },

    completion = {
      menu = {
        draw = {
          treesitter = { 'lsp' },
        },
      },
      documentation = { auto_show = true },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'tmux' },
      providers = {
        tmux = {
          module = 'blink-cmp-tmux',
          name = 'tmux',
          opts = {
            all_panes = true,
            capture_history = false,
            triggered_only = false,
          },
        },
      },
    },

    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
  },
  opts_extend = { 'sources.default' },
  config = function(_, opts)
    require('blink.cmp').setup(opts)

    -- default LSP configuration for all clients
    vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities(nil, true) })
  end,
}
