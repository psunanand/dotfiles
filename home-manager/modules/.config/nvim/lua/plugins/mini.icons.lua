-- Collection of nerd font icons
return 
  { 
    'echasnovski/mini.icons',
    lazy = false,

    -- to avoid conflicts if other plugins still depend on nvim-tree/nvim-web-devicons
    init = function()
        package.preload["nvim-web-devicons"] = function()
            require("mini.icons").mock_nvim_web_devicons()
            return package.loaded["nvim-web-devicons"]
        end
    end,
}

-- vim: ts=2 sts=2 sw=2 et


