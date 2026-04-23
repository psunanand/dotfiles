return {
	settings = {
		basedpyright = {
			disableOrganizeImports = true, -- delegate to ruff
			typeCheckingMode = "off",
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
			},
		},
	},
}
