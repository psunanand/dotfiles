-- Source: https://github.com/LuaLS/lua-language-server
return {
	on_attach = function(client, buf_id)
		client.server_capabilities.completionProvider.triggerCharacters = { ".", ":", "#", "(" }
	end,
	-- LuaLS Structure of these settings comes from LuaLS, not Neovim
	settings = {
		Lua = {
			runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
			workspace = {
				ignoreSubmodules = true,
				library = { vim.env.VIMRUNTIME },
			},
		},
	},
}
