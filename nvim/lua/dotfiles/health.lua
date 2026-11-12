local M = {}
function M.check()
	local role = require("config.role")
	vim.health.start("Shared editor")
	vim.health.info("Role: " .. role.name)
	if vim.fn.has("nvim-0.12") == 1 then
		vim.health.ok("Neovim 0.12+")
	else
		vim.health.warn("Full setup requires Neovim 0.12+; using the basic editor")
	end
	local groups = {
		{
			"Code",
			{ "shfmt", "shellcheck", "stylua", "rg", "fd" },
			"tools/install-tools and tools/install-tools --editor",
		},
		{
			"Parsers",
			{ "tree-sitter" },
			"tools/install-tools --editor",
		},
		{ "Coding agents", { "codex", "claude" }, "tools/install-tools --agents" },
	}
	if role.python then
		groups[#groups + 1] = { "Python", { "ty", "ruff" }, "tools/install-tools" }
	end
	if role.typst then
		groups[#groups + 1] = { "Typst", { "typst", "tinymist", "websocat" }, "tools/install-tools --editor" }
	end
	for _, group in ipairs(groups) do
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
