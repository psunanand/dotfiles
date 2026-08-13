-- hello
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear highlight" })
vim.keymap.set("n", "[p", '<Cmd>exe "iput! " . v:register<CR>', { desc = "Paste Above" })
vim.keymap.set("n", "]p", '<Cmd>exe "iput "  . v:register<CR>', { desc = "Paste Below" })
vim.keymap.set("x", "gp", '"+P', { desc = "Paste from system clipboard" })

-- Leader mappings follow <Leader><domain><action>. Suffix case identifies a
-- documented variant, not a universal scope rule; descriptions name scope and
-- modifiers explicitly.
Config.leader_group_clues = {
	{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
	{ mode = "n", keys = "<Leader>e", desc = "+Explore/Edit" },
	{ mode = "n", keys = "<Leader>f", desc = "+Find" },
	{ mode = "n", keys = "<Leader>g", desc = "+Git" },
	{ mode = "n", keys = "<Leader>l", desc = "+LSP" },
	{ mode = "n", keys = "<Leader>q", desc = "+Quickfix" },
	{ mode = "n", keys = "<Leader>t", desc = "+Terminal" },
	{ mode = "n", keys = "<Leader>u", desc = "+Undo" },
	{ mode = "n", keys = "<Leader>v", desc = "+Visits" },
	{ mode = "n", keys = "<Leader>w", desc = "+Window" },
	{ mode = "x", keys = "<Leader>g", desc = "+Git" },
	{ mode = "x", keys = "<Leader>l", desc = "+LSP" },
}

local nmap_leader = function(suffix, rhs, opts)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, opts)
end
local xmap_leader = function(suffix, rhs, opts)
	vim.keymap.set("x", "<Leader>" .. suffix, rhs, opts)
end

-- `b` -> Buffer
local new_scratch_buffer = function()
	vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader("ba", "<Cmd>b#<CR>", { desc = "Alternate buffer" })
nmap_leader("bd", "<Cmd>lua MiniBufremove.delete()<CR>", { desc = "Delete buffer" })
nmap_leader("bD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", { desc = "Delete buffer [force]" })
nmap_leader("bs", new_scratch_buffer, { desc = "Scratch buffer" })
nmap_leader("bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", { desc = "Wipe buffer" })
nmap_leader("bW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", { desc = "Wipe buffer [force]" })

-- `e`` -> Explore/Edit
local edit_plugin_file = function(filename)
	return string.format("<Cmd>edit %s/plugin/%s<CR>", vim.fn.stdpath("config"), filename)
end
local explore_at_file = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"
local explore_quickfix = function()
	vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end
local explore_locations = function()
	vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end

nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", { desc = "Explorer [cwd]" })
nmap_leader("ef", explore_at_file, { desc = "Explorer [file]" })
nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>", { desc = "Config: init" })
nmap_leader("ek", edit_plugin_file("20_keymaps.lua"), { desc = "Config: keymaps" })
nmap_leader("em", edit_plugin_file("30_mini.lua"), { desc = "Config: mini" })
nmap_leader("en", "<Cmd>lua MiniNotify.show_history()<CR>", { desc = "Notifications" })
nmap_leader("eo", edit_plugin_file("10_options.lua"), { desc = "Config: options" })
nmap_leader("ep", edit_plugin_file("40_plugins.lua"), { desc = "Config: plugins" })

-- `f` -> Find
nmap_leader("f/", "<Cmd>FzfLua search_history<CR>", { desc = '"/" history' })
nmap_leader("f:", "<Cmd>FzfLua command_history<CR>", { desc = '":" history' })
nmap_leader("fa", "<Cmd>FzfLua git_status<CR>", { desc = "Git status" })
nmap_leader("fm", "<Cmd>FzfLua git_hunks<CR>", { desc = "Git hunks [all]" })
nmap_leader("fA", '<Cmd>FzfLua git_hunks fzf_opts={["--query"]=[[\'^A ]]}<CR>', { desc = "Git hunks [added]" })
nmap_leader("fb", "<Cmd>FzfLua buffers<CR>", { desc = "Buffers" })
nmap_leader("fc", "<Cmd>FzfLua git_commits<CR>", { desc = "Commits [project]" })
nmap_leader("fC", "<Cmd>FzfLua git_bcommits<CR>", { desc = "Commits [buffer]" })
nmap_leader("fd", "<Cmd>FzfLua lsp_workspace_diagnostics<CR>", { desc = "Diagnostics [workspace]" })
nmap_leader("fD", "<Cmd>FzfLua lsp_document_diagnostics<CR>", { desc = "Diagnostics [buffer]" })
nmap_leader("ff", "<Cmd>FzfLua files<CR>", { desc = "Files [cwd]" })
nmap_leader("fg", "<Cmd>FzfLua live_grep<CR>", { desc = "Grep [live]" })
nmap_leader("fG", "<Cmd>FzfLua grep_cword<CR>", { desc = "Grep [word]" })
xmap_leader("fg", "<Cmd>FzfLua grep_visual<CR>", { desc = "Grep [selection]" })
nmap_leader("fh", "<Cmd>FzfLua help_tags<CR>", { desc = "Help tags" })
nmap_leader("fH", "<Cmd>FzfLua highlights<CR>", { desc = "Highlight groups" })
nmap_leader("fl", "<Cmd>FzfLua lines<CR>", { desc = "Lines [open buffers]" })
nmap_leader("fL", "<Cmd>FzfLua blines<CR>", { desc = "Lines [buffer]" })
nmap_leader("fr", "<Cmd>FzfLua resume<CR>", { desc = "Resume last picker" })
nmap_leader("fs", "<Cmd>FzfLua lsp_live_workspace_symbols<CR>", { desc = "Symbols [workspace]" })
nmap_leader("fS", "<Cmd>FzfLua lsp_document_symbols<CR>", { desc = "Symbols [document]" })
nmap_leader("fv", "<Cmd>FzfLua oldfiles cwd_only=true<CR>", { desc = "Recent files [cwd]" })
nmap_leader("fV", "<Cmd>FzfLua oldfiles<CR>", { desc = "Recent files [all]" })

-- `g` -> Git
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"
nmap_leader("ga", "<Cmd>Git diff --cached<CR>", { desc = "Diff [staged]" })
nmap_leader("gA", "<Cmd>Git diff --cached -- %<CR>", { desc = "Diff [staged buffer]" })
nmap_leader("gB", "<Cmd>FzfLua git_blame<CR>", { desc = "Blame [buffer]" })
nmap_leader("gc", "<Cmd>Git commit<CR>", { desc = "Commit" })
nmap_leader("gC", "<Cmd>Git commit --amend<CR>", { desc = "Commit [amend]" })
nmap_leader("gd", "<Cmd>Git diff<CR>", { desc = "Diff [repo]" })
nmap_leader("gD", "<Cmd>Git diff -- %<CR>", { desc = "Diff [buffer]" })
nmap_leader("gl", "<Cmd>" .. git_log_cmd .. "<CR>", { desc = "Log [repo]" })
nmap_leader("gL", "<Cmd>" .. git_log_buf_cmd .. "<CR>", { desc = "Log [buffer]" })
nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", { desc = "Hunk overlay [toggle]" })
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", { desc = "Git info [cursor]" })
xmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", { desc = "Git info [selection]" })

-- `q` -> Quickfix
nmap_leader("qq", explore_quickfix, { desc = "Quickfix [toggle]" })
nmap_leader("ql", explore_locations, { desc = "Location list [toggle]" })

-- `l` -> LSP
nmap_leader("la", "<Cmd>FzfLua lsp_code_actions<CR>", { desc = "Code actions" })
nmap_leader("ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Diagnostic [cursor]" })
nmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', { desc = "Format" })
nmap_leader("li", "<Cmd>FzfLua lsp_implementations<CR>", { desc = "Implementation" })
nmap_leader("lh", "<Cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover" })
nmap_leader("ll", "<Cmd>lua vim.lsp.codelens.run()<CR>", { desc = "Run CodeLens" })
nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })
nmap_leader("lR", "<Cmd>FzfLua lsp_references<CR>", { desc = "References" })
nmap_leader("ls", "<Cmd>FzfLua lsp_definitions<CR>", { desc = "Definition" })
nmap_leader("lt", "<Cmd>FzfLua lsp_typedefs<CR>", { desc = "Type definition" })
xmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', { desc = "Format selection" })

-- `w` -> Window
nmap_leader("wr", "<Cmd>lua MiniMisc.resize_window()<CR>", { desc = "Window width [reset]" })
nmap_leader("wz", "<Cmd>lua MiniMisc.zoom()<CR>", { desc = "Window [zoom toggle]" })

-- `u` -> Undo
nmap_leader("ut", "<Cmd>Undotree<CR>", { desc = "Undo tree" })

-- `t` -> Terminal
nmap_leader("th", "<Cmd>horizontal term<CR>", { desc = "Terminal [horizontal]" })
nmap_leader("tv", "<Cmd>vertical term<CR>", { desc = "Terminal [vertical]" })
vim.keymap.set("t", "<Leader>t<Esc>", "<C-\\><C-n>", { desc = "Exit terminal session" })

-- `v` -> Visit
local make_pick_core = function(cwd, desc)
	return function()
		local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
		local local_opts = { cwd = cwd, filter = "core", sort = sort_latest }
		MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
	end
end
nmap_leader("vc", make_pick_core("", "Core visits [all]"), { desc = "Core visits [all]" })
nmap_leader("vC", make_pick_core(nil, "Core visits [cwd]"), { desc = "Core visits [cwd]" })
nmap_leader("vv", '<Cmd>lua MiniVisits.add_label("core")<CR>', { desc = 'Core label [add]' })
nmap_leader("vV", '<Cmd>lua MiniVisits.remove_label("core")<CR>', { desc = 'Core label [remove]' })
nmap_leader("vl", "<Cmd>lua MiniVisits.add_label()<CR>", { desc = "Label [add]" })
nmap_leader("vL", "<Cmd>lua MiniVisits.remove_label()<CR>", { desc = "Label [remove]" })
