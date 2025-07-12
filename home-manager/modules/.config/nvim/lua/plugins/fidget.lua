-- UI for Neovim notifications
return {
  'j-hui/fidget.nvim',
  opts = {
    notification = {
      override_vim_notify = true,
      view = {
        -- display notifications from top to bottom
        stack_upwards = false,
      },
    },
  },
}
