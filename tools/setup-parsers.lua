-- Explicit provisioning with the modern Tree-sitter API, shared on all platforms.
local ok, err = xpcall(function()
	require("lazy").load({ plugins = { "nvim-treesitter" } })
	local languages =
		{ "bash", "fish", "lua", "python", "json", "markdown", "markdown_inline", "regex", "toml", "yaml", "typst" }
	assert(vim.fn.executable("tree-sitter") == 1, "Install the parser generator with tools/install-tools --editor")
	-- The old master branch stored parsers inside its plugin checkout. Preserve
	-- them outside runtimepath so stale grammars cannot shadow the new install.
	local legacy = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/"
	if vim.fn.isdirectory(legacy .. "parser") == 1 then
		local backup = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state"))
			.. "/dotfiles/backups/parsers-"
			.. os.date("%Y%m%d-%H%M%S")
			.. "-"
			.. vim.fn.getpid()
		vim.fn.mkdir(backup, "p", 448)
		for _, name in ipairs({ "parser", "parser-info" }) do
			if vim.fn.isdirectory(legacy .. name) == 1 then
				assert(vim.fn.rename(legacy .. name, backup .. "/" .. name) == 0, "Could not preserve legacy parsers")
			end
		end
		print("backup: " .. backup)
	end
	require("nvim-treesitter").update(languages):wait(300000)
	require("nvim-treesitter").install(languages):wait(300000)
	for _, language in ipairs(languages) do
		assert(vim.treesitter.language.add(language), "Parser unavailable: " .. language)
	end
	print("ready: " .. #languages .. " parsers")
end, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
end
