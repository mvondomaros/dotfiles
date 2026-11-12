local M = {}
function M.check()
	vim.health.start("Shared editor")
	if vim.fn.has("nvim-0.12") == 1 then
		vim.health.ok("Neovim 0.12+")
	else
		vim.health.warn("Full setup requires Neovim 0.12+; using the basic editor")
	end
	for _, group in ipairs({
		{
			"Code",
			{ "ty", "ruff", "shfmt", "shellcheck", "stylua", "rg", "fd" },
			"tools/install-tools and tools/install-tools --editor",
		},
		{
			"Parsers and Typst preview",
			{ "tree-sitter", "typst", "tinymist", "websocat" },
			"tools/install-tools --editor",
		},
		{ "Coding agents", { "codex", "claude" }, "tools/install-tools --agents" },
	}) do
		vim.health.start(group[1])
		for _, tool in ipairs(group[2]) do
			if vim.fn.executable(tool) == 1 then
				vim.health.ok(tool .. ": " .. vim.fn.exepath(tool))
			else
				vim.health.warn(tool .. " missing", { group[3] })
			end
		end
	end
end
return M
