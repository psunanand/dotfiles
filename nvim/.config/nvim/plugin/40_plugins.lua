local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Undotree
later(function()
	vim.cmd.packadd("nvim.undotree")
end)

-- Picker
later(function()
	add({ "https://github.com/ibhagwan/fzf-lua" })

	local fd_opts = "--color=never --type f --no-ignore --hidden --follow --exclude .git"
	local rg_opts =
		"--column --line-number --no-heading --color=always --smart-case --hidden --no-ignore --follow -g '!.git'"

	require("fzf-lua").setup({
		winopts = {
			height = 0.40,
			width = 1.00,
			row = 1.00,
			col = 0.00,
			border = "none",
			preview = {
				layout = "flex",
				flip_columns = 120,
				scrollbar = false,
			},
		},
		files = {
			fd_opts = fd_opts,
		},
		grep = {
			rg_opts = rg_opts,
		},
	})
end)

-- == Tree-sitter
now_if_args(function()
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

	add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	})

	local languages = {
		"lua",
		"javascript",
		"vimdoc",
		"markdown",
		"python",
		"html",
	}
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- == LSP
now_if_args(function()
	add({
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/mason-org/mason-lspconfig.nvim",
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	})
	require("mason").setup()
	require("mason-lspconfig").setup()
	require("mason-tool-installer").setup({
		ensure_installed = {
			"bashls",
			"shfmt",
			"lua_ls",
			"stylua",
		},
		auto_update = false,
		run_on_start = true,
	})
end)

-- == Formatting
later(function()
	add({ "https://github.com/stevearc/conform.nvim" })
	require("conform").setup({
		default_format_opts = {
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			python = { "ruff" },
			["_"] = { "trim_whitespace", "trim_newlines" },
		},
		format_on_save = {
			lsp_format = "fallback",
			timeout_ms = 500,
		},
	})
end)

-- == Snippets
later(function()
	add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

-- == Colorscheme
Config.now(function()
	add({
		"https://github.com/sainnhe/everforest",
	})
	vim.g.everforest_background = "dark"
	vim.g.everforest_enable_italic = true
	vim.cmd("colorscheme everforest")
end)

-- == Preview
later(function()
	add({ "https://github.com/OXY2DEV/markview.nvim" })
end)

-- == Tmux
now_if_args(function()
	add({
		"https://github.com/christoomey/vim-tmux-navigator",
	})
end)

-- == AI cursortab
later(function()
	Config.new_autocmd("PackChanged", nil, function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "cursortab.nvim" and (kind == "install" or kind == "update") then
			vim.system({ "go", "build" }, { cwd = ev.data.path .. "/server" }):wait()
		end
	end, nil)
	add({ "https://github.com/cursortab/cursortab.nvim" })
	require("cursortab").setup({
		provider = {
			type = "zeta-2",
			url = "http://127.0.0.1:8000",
		},
	})
end)
