-- One semantic Python server; Ruff owns formatting through Conform and CLI lint.
if vim.fn.executable("ty") == 0 then
	return
end

vim.lsp.config("ty", {
	cmd = { "ty", "server" },
	filetypes = { "python" },
	root_markers = { "ty.toml", "pyproject.toml", "pixi.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	init_options = { experimental = { useUv = "off" } },
	settings = { ty = { configuration = {} } },
	before_init = function(_, config)
		-- Respect an explicitly activated environment, including named Pixi envs.
		-- Otherwise use the project's existing Pixi default without activating it.
		if vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX or not config.root_dir then
			return
		end
		local environment = config.root_dir .. "/.pixi/envs/default"
		if vim.fn.executable(environment .. "/bin/python") == 1 then
			config.settings.ty.configuration.environment = { python = environment }
		end
	end,
})
vim.lsp.enable("ty")
