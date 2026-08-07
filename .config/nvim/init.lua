_G.Config = {}

-- "mini.nvim" Swiss-army-knife all-in-one plugin.
-- Load now to have "mini.misc" available for custom loading helpers.
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

-- `:h MiniMisc.safely()`
local misc = require("mini.misc")
Config.now = function(f)
	misc.safely("now", f)
end
Config.later = function(f)
	misc.safely("later", f)
end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f)
	misc.safely("event:" .. ev, f)
end
Config.on_filetype = function(ft, f)
	misc.safely("filetype:" .. ft, f)
end

-- `:h autocommand`
-- `:h nvim_create_augroup()`
-- `:h nvim_create_autocmd()`
local gr = vim.api.nvim_create_augroup("custom-config", {})
Config.new_autocmd = function(event, pattern, callback, desc)
	local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
	vim.api.nvim_create_autocmd(event, opts)
end

-- Custom `vim.pack.add()` hook
-- `:h vim.pack-events`.
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
	local f = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback()
	end
	Config.new_autocmd("PackChanged", "*", f, desc)
end

-- vim.pack helper
local function all_packages(match)
	return vim.iter(vim.pack.get())
		:map(function(pack)
			return pack.spec.name
		end)
		:filter(function(pack)
			return pack:find(match)
		end)
		:totable()
end

vim.api.nvim_create_user_command("PackUpdate", function(opts)
	if #opts.fargs ~= 0 then
		vim.pack.update(opts.fargs)
	else
		vim.pack.update()
	end
end, {
	nargs = "*",
	complete = all_packages,
})

vim.api.nvim_create_user_command("PackDelete", function(opts)
	vim.pack.del(opts.fargs)
end, {
	nargs = "+",
	complete = all_packages,
})
