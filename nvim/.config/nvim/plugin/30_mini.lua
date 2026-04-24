-- See `:h mini.nvim-general-principles` for general principles of "mini"

-- Guidline to load `modules`
-- - 1st Step -> enable all the needed modules with `now()`
-- - 2nd Step -> the rest is delayed with `later()`

local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- == Step 1

-- Icon provider
now(function()
	-- Set up to not prefer extension-based icon for some extensions
	local ext3_blocklist = { scm = true, txt = true, yml = true }
	local ext4_blocklist = { json = true, yaml = true }
	require("mini.icons").setup({
		use_file_extension = function(ext, _)
			return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
		end,
	})
	later(MiniIcons.mock_nvim_web_devicons)
	later(MiniIcons.tweak_lsp_kind)
end)

-- Notifications provider
now(function()
	require("mini.notify").setup()
end)

-- Statusline
now(function()
	require("mini.statusline").setup({})
end)

-- Tabline
now(function()
	require("mini.tabline").setup({
		format = function(buf_id, label)
			local suffix = vim.bo[buf_id].modified and "+ " or ""
			return MiniTabline.default_format(buf_id, label) .. suffix
		end,
	})
end)

-- Autocompletion
now_if_args(function()
	local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 }, filtersort = "fuzzy" }
	local process_items = function(items, base)
		return MiniCompletion.default_process_items(items, base, process_items_opts)
	end

	require("mini.completion").setup({
		lsp_completion = {
			source_func = "omnifunc",
			auto_setup = false,
			process_items = process_items,
		},
	})
	local on_attach = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
	end
	Config.new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")

	vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

-- File explorer
now_if_args(function()
	require("mini.files").setup({ windows = { preview = true } })
	local add_marks = function()
		MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
		local vimpack_plugins = vim.fn.stdpath("data") .. "/site/pack/core/opt"
		MiniFiles.set_bookmark("p", vimpack_plugins, { desc = "Plugins" })
		MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
	end
	Config.new_autocmd("User", "MiniFilesExplorerOpen", add_marks, "Add bookmarks")
end)

-- Miscellaneous small but useful functions
now_if_args(function()
	require("mini.misc").setup()
	MiniMisc.setup_auto_root()
	MiniMisc.setup_restore_cursor()
	MiniMisc.setup_termbg_sync()
end)

-- == Step two

later(function()
	require("mini.extra").setup()
end)

-- Extend text object
later(function()
	local ai = require("mini.ai")
	ai.setup({
		custom_textobjects = {
			-- around/inside whole *b*uffer
			B = MiniExtra.gen_ai_spec.buffer(),
			-- `aF`/`iF` mean around/inside function
			F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		},
		search_method = "cover_or_next",
	})
end)

-- Align text
later(function()
	require("mini.align").setup()
end)

-- Vim unimpaired
later(function()
	require("mini.bracketed").setup()
end)

-- Buffer handling
later(function()
	require("mini.bufremove").setup()
end)

-- Key clues
later(function()
	local miniclue = require("mini.clue")
	miniclue.setup({
		clues = {
			-- This is defined in 'plugin/20_keymaps.lua' with Leader group descriptions
			Config.leader_group_clues,
			miniclue.gen_clues.builtin_completion(),
			miniclue.gen_clues.g(),
			miniclue.gen_clues.marks(),
			miniclue.gen_clues.registers(),
			miniclue.gen_clues.square_brackets(),
			miniclue.gen_clues.windows({ submode_resize = true }),
			miniclue.gen_clues.z(),
		},
		-- Common keys to trigger clue window
		triggers = {
			{ mode = { "n", "x" }, keys = "<Leader>" }, -- Leader triggers
			{ mode = "n", keys = "\\" }, -- mini.basics
			{ mode = { "n", "x" }, keys = "[" }, -- mini.bracketed
			{ mode = { "n", "x" }, keys = "]" },
			{ mode = "i", keys = "<C-x>" }, -- Built-in completion
			{ mode = { "n", "x" }, keys = "g" }, -- `g` key
			{ mode = { "n", "x" }, keys = "'" }, -- Marks
			{ mode = { "n", "x" }, keys = "`" },
			{ mode = { "n", "x" }, keys = '"' }, -- Registers
			{ mode = { "i", "c" }, keys = "<C-r>" },
			{ mode = "n", keys = "<C-w>" }, -- Window commands
			{ mode = { "n", "x" }, keys = "s" }, -- `s` key (mini.surround, etc.)
			{ mode = { "n", "x" }, keys = "z" }, -- `z` key
		},
	})
end)

-- Command line tweaks
later(function()
	require("mini.cmdline").setup()
end)

-- Comment
later(function()
	require("mini.comment").setup()
end)

-- Diff hunk
later(function()
	require("mini.diff").setup()
end)

-- Git
later(function()
	require("mini.git").setup()
end)

-- Highlight patterns in text
later(function()
	local hipatterns = require("mini.hipatterns")
	local hi_words = MiniExtra.gen_highlighter.words
	hipatterns.setup({
		highlighters = {
			fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

-- Indentscope
later(function()
	require("mini.indentscope").setup()
end)

-- Special key mappings. Provides helpers to map:
later(function()
	require("mini.keymap").setup()
	MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next" })
	MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })
	MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
	MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })
end)

-- Window with text overview
later(function()
	local map = require("mini.map")
	map.setup({
		-- Use Braille dots to encode text
		symbols = { encode = map.gen_encode_symbols.dot("4x2") },
		-- Show built-in search matches, 'mini.diff' hunks, and diagnostic entries
		integrations = {
			map.gen_integration.builtin_search(),
			map.gen_integration.diff(),
			map.gen_integration.diagnostic(),
		},
	})

	for _, key in ipairs({ "n", "N", "*", "#" }) do
		local rhs = key .. "zv" .. "<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
		vim.keymap.set("n", key, rhs)
	end
end)

-- Autopairs
later(function()
	require("mini.pairs").setup({ modes = { insert = true, terminal = false, command = false } })
end)

-- Snippet
later(function()
	-- Define language patterns to work better with 'friendly-snippets'
	local latex_patterns = { "latex/**/*.json", "**/latex.json" }
	local lang_patterns = {
		tex = latex_patterns,
		plaintex = latex_patterns,
		markdown_inline = { "markdown.json" },
	}

	local snippets = require("mini.snippets")
	local config_path = vim.fn.stdpath("config")
	snippets.setup({
		snippets = {
			snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
			snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
		},
	})
	MiniSnippets.start_lsp_server()
end)

-- Surround
later(function()
	require("mini.surround").setup()
end)
