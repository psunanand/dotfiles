vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear highlight" })

vim.keymap.set("n", "[p", '<Cmd>exe "iput! " . v:register<CR>', { desc = "Paste Above" })
vim.keymap.set("n", "]p", '<Cmd>exe "iput "  . v:register<CR>', { desc = "Paste Below" })
vim.keymap.set("n", "<C-H>", "<C-w>h", { desc = "Focus on left window" })
vim.keymap.set("n", "<C-J>", "<C-w>j", { desc = "Focus on below window" })
vim.keymap.set("n", "<C-K>", "<C-w>k", { desc = "Focus on above window" })
vim.keymap.set("n", "<C-L>", "<C-w>l", { desc = "Focus on right window" })
vim.keymap.set("x", "gp", '"+P', { desc = "Paste from system clipboard" })

-- Follow 2 key-leader mapping <Leader><1st><2nd>
-- <1st> = semantic group
-- <2nd> = action
-- - uppercase <2nd> for global and lowercase <2nd> for local
Config.leader_group_clues = {
	{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
	{ mode = "n", keys = "<Leader>e", desc = "+Explore/Edit" },
	{ mode = "n", keys = "<Leader>f", desc = "+Find" },
	{ mode = "n", keys = "<Leader>g", desc = "+Git" },
	{ mode = "n", keys = "<Leader>l", desc = "+LSP" },
	{ mode = "n", keys = "<Leader>m", desc = "+Map" },
	{ mode = "n", keys = "<Leader>o", desc = "+Other" },
	{ mode = "n", keys = "<Leader>s", desc = "+Session" },
	{ mode = "n", keys = "<Leader>t", desc = "+Terminal" },
	{ mode = "n", keys = "<Leader>v", desc = "+Visits" },

	{ mode = "x", keys = "<Leader>g", desc = "+Git" },
	{ mode = "x", keys = "<Leader>l", desc = "+LSP" },
}

local nmap_leader = function(suffix, rhs, opts)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, opts)
end
local xmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("x", "<Leader>" .. suffix, rhs, opts)
end

-- `b` -> Buffer
local new_scratch_buffer = function()
	vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader("ba", "<Cmd>b#<CR>", { desc = "Alternate" })
nmap_leader("bd", "<Cmd>lua MiniBufremove.delete()<CR>", { desc = "Delete" })
nmap_leader("bD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", { desc = "Delete!" })
nmap_leader("bs", new_scratch_buffer, { desc = "Scratch" })
nmap_leader("bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", { desc = "Wipeout" })
nmap_leader("bW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", { desc = "Wipeout!" })

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

nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", { desc = "Directory" })
nmap_leader("ef", explore_at_file, { desc = "File directory" })
nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>", { desc = "init.lua" })
nmap_leader("ek", edit_plugin_file("20_keymaps.lua"), { desc = "Keymaps config" })
nmap_leader("em", edit_plugin_file("30_mini.lua"), { desc = "MINI config" })
nmap_leader("en", "<Cmd>lua MiniNotify.show_history()<CR>", { desc = "Notifications" })
nmap_leader("eo", edit_plugin_file("10_options.lua"), { desc = "Options config" })
nmap_leader("ep", edit_plugin_file("40_plugins.lua"), { desc = "Plugins config" })
nmap_leader("eq", explore_quickfix, { desc = "Quickfix list" })
nmap_leader("eQ", explore_locations, { desc = "Location list" })

-- `f` -> Find
local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'

nmap_leader("f/", '<Cmd>Pick history scope="/"<CR>', { desc = '"/" history' })
nmap_leader("f:", '<Cmd>Pick history scope=":"<CR>', { desc = '":" history' })
nmap_leader("fa", '<Cmd>Pick git_hunks scope="staged"<CR>', { desc = "Added hunks (all)" })
nmap_leader("fA", pick_added_hunks_buf, { desc = "Added hunks (buf)" })
nmap_leader("fb", "<Cmd>Pick buffers<CR>", { desc = "Buffers" })
nmap_leader("fc", "<Cmd>Pick git_commits<CR>", { desc = "Commits (all)" })
nmap_leader("fC", '<Cmd>Pick git_commits path="%"<CR>', { desc = "Commits (buf)" })
nmap_leader("fd", '<Cmd>Pick diagnostic scope="all"<CR>', { desc = "Diagnostic workspace" })
nmap_leader("fD", '<Cmd>Pick diagnostic scope="current"<CR>', { desc = "Diagnostic buffer" })
nmap_leader("ff", "<Cmd>Pick files_fd<CR>", { desc = "Files" })
nmap_leader("fg", "<Cmd>Pick grep_live<CR>", { desc = "Grep live" })
nmap_leader("fG", '<Cmd>Pick grep pattern="<cword>"<CR>', { desc = "Grep current word" })
nmap_leader("fh", "<Cmd>Pick help<CR>", { desc = "Help tags" })
nmap_leader("fH", "<Cmd>Pick hl_groups<CR>", { desc = "Highlight groups" })
nmap_leader("fl", '<Cmd>Pick buf_lines scope="all"<CR>', { desc = "Lines (all)" })
nmap_leader("fL", '<Cmd>Pick buf_lines scope="current"<CR>', { desc = "Lines (buf)" })
nmap_leader("fm", "<Cmd>Pick git_hunks<CR>", { desc = "Modified hunks (all)" })
nmap_leader("fM", '<Cmd>Pick git_hunks path="%"<CR>', { desc = "Modified hunks (buf)" })
nmap_leader("fr", "<Cmd>Pick resume<CR>", { desc = "Resume" })
nmap_leader("fR", '<Cmd>Pick lsp scope="references"<CR>', { desc = "References (LSP)" })
nmap_leader("fs", pick_workspace_symbols_live, { desc = "Symbols workspace (live)" })
nmap_leader("fS", '<Cmd>Pick lsp scope="document_symbol"<CR>', { desc = "Symbols document" })
nmap_leader("fv", '<Cmd>Pick visit_paths cwd=""<CR>', { desc = "Visit paths (all)" })
nmap_leader("fV", "<Cmd>Pick visit_paths<CR>", { desc = "Visit paths (cwd)" })

-- `g` -> Git
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"
nmap_leader("ga", "<Cmd>Git diff --cached<CR>", { desc = "Added diff" })
nmap_leader("gA", "<Cmd>Git diff --cached -- %<CR>", { desc = "Added diff buffer" })
nmap_leader("gc", "<Cmd>Git commit<CR>", { desc = "Commit" })
nmap_leader("gC", "<Cmd>Git commit --amend<CR>", { desc = "Commit amend" })
nmap_leader("gd", "<Cmd>Git diff<CR>", { desc = "Diff" })
nmap_leader("gD", "<Cmd>Git diff -- %<CR>", { desc = "Diff buffer" })
nmap_leader("gl", "<Cmd>" .. git_log_cmd .. "<CR>", { desc = "Log" })
nmap_leader("gL", "<Cmd>" .. git_log_buf_cmd .. "<CR>", { desc = "Log buffer" })
nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", { desc = "Toggle overlay" })
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", { desc = "Show at cursor" })
xmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", { desc = "Show at selection" })

-- `l` -> LSP
nmap_leader("la", "<Cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Actions" })
nmap_leader("ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Diagnostic popup" })
nmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', { desc = "Format" })
nmap_leader("li", "<Cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Implementation" })
nmap_leader("lh", "<Cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover" })
nmap_leader("ll", "<Cmd>lua vim.lsp.codelens.run()<CR>", { desc = "Lens" })
nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })
nmap_leader("lR", "<Cmd>lua vim.lsp.buf.references()<CR>", { desc = "References" })
nmap_leader("ls", "<Cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Source definition" })
nmap_leader("lt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "Type definition" })
xmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', { desc = "Format selection" })

-- `m` -> Map
nmap_leader("mf", "<Cmd>lua MiniMap.toggle_focus()<CR>", { desc = "Focus (toggle)" })
nmap_leader("mr", "<Cmd>lua MiniMap.refresh()<CR>", { desc = "Refresh" })
nmap_leader("ms", "<Cmd>lua MiniMap.toggle_side()<CR>", { desc = "Side (toggle)" })
nmap_leader("mt", "<Cmd>lua MiniMap.toggle()<CR>", { desc = "Toggle" })

-- `o` -> Other
nmap_leader("or", "<Cmd>lua MiniMisc.resize_window()<CR>", { desc = "Resize to default width" })
nmap_leader("oz", "<Cmd>lua MiniMisc.zoom()<CR>", { desc = "Zoom toggle" })

-- `s` -> Session
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'
nmap_leader("sd", '<Cmd>lua MiniSessions.select("delete")<CR>', { desc = "Delete" })
nmap_leader("sn", "<Cmd>lua " .. session_new .. "<CR>", { desc = "New" })
nmap_leader("sr", '<Cmd>lua MiniSessions.select("read")<CR>', { desc = "Read" })
nmap_leader("sw", "<Cmd>lua MiniSessions.write()<CR>", { desc = "Write current" })

-- `t` -> Terminal
nmap_leader("tT", "<Cmd>horizontal term<CR>", { desc = "Terminal (horizontal)" })
nmap_leader("tt", "<Cmd>vertical term<CR>", { desc = "Terminal (vertical)" })
vim.keymap.set("t", "<Leader>t<Esc>", "<C-\\><C-n>", { desc = "Exit terminal session" })
vim.keymap.set("n", "<C-H>", "<Cmd>TmuxNavigateLeft<CR>", { desc = "Tmux-navigate left" })
vim.keymap.set("n", "<C-J>", "<Cmd>TmuxNavigateDown<CR>", { desc = "Tmux-navigate down" })
vim.keymap.set("n", "<C-K>", "<Cmd>TmuxNavigateUp<CR>", { desc = "Tmux-navigate up" })
vim.keymap.set("n", "<C-L>", "<Cmd>TmuxNavigateRight<CR>", { desc = "Tmux-navigate right" })

-- `v` -> Visit
local make_pick_core = function(cwd, desc)
	return function()
		local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
		local local_opts = { cwd = cwd, filter = "core", sort = sort_latest }
		MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
	end
end
nmap_leader("vc", make_pick_core("", "Core visits (all)"), { desc = "Core visits (all)" })
nmap_leader("vC", make_pick_core(nil, "Core visits (cwd)"), { desc = "Core visits (cwd)" })
nmap_leader("vv", '<Cmd>lua MiniVisits.add_label("core")<CR>', { desc = 'Add "core" label' })
nmap_leader("vV", '<Cmd>lua MiniVisits.remove_label("core")<CR>', { desc = 'Remove "core" label' })
nmap_leader("vl", "<Cmd>lua MiniVisits.add_label()<CR>", { desc = "Add label" })
nmap_leader("vL", "<Cmd>lua MiniVisits.remove_label()<CR>", { desc = "Remove label" })
