-- Explicit provisioning: install missing parsers, reuse existing ones, never prompt.
local ok, err = xpcall(function()
	require("lazy").load({ plugins = { "nvim-treesitter" } })
	local languages = { "bash", "fish", "lua", "python", "markdown", "markdown_inline", "toml", "yaml" }
	if vim.uv.os_uname().sysname == "Darwin" then
		vim.list_extend(languages, { "bibtex", "typst" })
		if vim.fn.executable("tree-sitter") == 1 then
			languages[#languages + 1] = "latex"
		else
			print("reuse: built-in LaTeX syntax (no tree-sitter generator)")
		end
	end
	require("nvim-treesitter.install").ensure_installed_sync(languages)
	for _, language in ipairs(languages) do
		assert(vim.treesitter.language.add(language), "Parser unavailable: " .. language)
	end
	print("ready: " .. #languages .. " parsers")
end, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
end
