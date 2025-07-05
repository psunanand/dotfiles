-- Neovim File explorer
return {
  'stevearc/oil.nvim',
  lazy = false,
  keys = { { '-', '<cmd>Oil --float<cr>', mode = 'n', desc = 'Open Oil Explorer from parent directory' } },
  config = function()
    require('oil').setup({
      view_options = {
        show_hidden = true,
      },
      default_file_explorer = true,
      use_default_keymaps = false,
      -- See :help oil-actions for a list of available actions
      keymaps = {
        ['g?'] = { 'actions.show_help', mode = 'n' },
        ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
        ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-s>'] = { 'actions.select', opts = { horizontal = true } },
        ['<C-t>'] = { 'actions.select', opts = { tab = true } },
        ['h'] = { 'actions.parent', mode = 'n' },
        ['l'] = { 'actions.select' },
        ['='] = 'actions.refresh',
        ['q'] = { 'actions.close', mode = 'n' },
        ['gd'] = {
          desc = 'Toggle file detail view',
          callback = function()
            detail = not detail
            if detail then
              require('oil').set_columns({ 'icon', 'permissions', 'size', 'mtime' })
            else
              require('oil').set_columns({ 'icon' })
            end
          end,
        },
      },
    })
  end,
}
