-- Exercise the full editor and existing parser binaries before upgrading Neovim.
-- Run: nvim --headless -i NONE -c "lua dofile('tests/check_nvim.lua')"
local scratch = vim.fn.tempname()
local notifications = {}
local notify = vim.notify
vim.notify = function(message, level, ...)
	if level == vim.log.levels.ERROR then
		notifications[#notifications + 1] = message
	end
	return notify(message, level, ...)
end
local ok, err = xpcall(function()
	assert(vim.g.dotfiles_full == true, "Full plugin setup did not load")
	assert(vim.v.errmsg == "", vim.v.errmsg)
	assert(vim.g.colors_name == "ayu" and vim.o.background == "light", "Theme failed")
	local expected = vim.env.DOTFILES_TEST_NVIM_VERSION
	if expected then
		local v = vim.version()
		assert(string.format("%d.%d.%d", v.major, v.minor, v.patch) == expected)
	end
	require("lazy").load({
		plugins = {
			"nvim-treesitter",
			"conform.nvim",
			"gitsigns.nvim",
			"which-key.nvim",
		},
	})
	local parsers = {}
	for _, path in ipairs(vim.api.nvim_get_runtime_file("parser/*.so", true)) do
		local lang = vim.fn.fnamemodify(path, ":t:r")
		if not parsers[lang] then
			vim.treesitter.language.add(lang)
			assert(vim.treesitter.get_string_parser("local value = 1\n", lang):parse()[1])
			parsers[lang] = true
		end
	end
	vim.fn.mkdir(scratch, "p")
	local samples = {
		{ "sample.lua", "lua", "local value = 1\nprint(value)" },
		{ "sample.py", "python", "value = 1\nprint(value)" },
		{ "sample.sh", "sh", "#!/bin/bash\nprintf '%s\\n' hello" },
		{ "sample.md", "markdown", "# Test\n\nA paragraph." },
		{ "sample.toml", "toml", 'title = "Test"' },
		{ "sample.typ", "typst", "= Test\n\nA paragraph." },
		{ "sample.fish", "fish", "if true\n    echo hello\nend" },
		{ "sample.txt", "text", "A paragraph." },
	}
	for _, sample in ipairs(samples) do
		local path = scratch .. "/" .. sample[1]
		vim.fn.writefile(vim.split(sample[3], "\n", { plain = true }), path)
		vim.cmd("edit " .. vim.fn.fnameescape(path))
		assert(vim.bo.filetype == sample[2], "Incorrect filetype for " .. sample[1])
		local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
		if parsers[lang] then
			vim.treesitter.start(0, lang)
			assert(vim.treesitter.get_parser():parse()[1])
		end
		vim.cmd("normal! gg")
		vim.cmd("redraw")
		assert(vim.v.errmsg == "", vim.v.errmsg)
	end
	local conform = require("conform")
	conform.formatters.dotfiles_test_cat = { command = "/bin/cat", stdin = true }
	local finished = false
	conform.format({ formatters = { "dotfiles_test_cat" }, async = false, timeout_ms = 2000 }, function(e)
		assert(not e, tostring(e))
		finished = true
	end)
	assert(finished, "Formatter callback did not run")
	assert(type(vim.fn.eval(vim.o.formatexpr)) == "number", "Invalid formatter expression")
	vim.cmd("edit " .. vim.fn.fnameescape(scratch .. "/nested/notes.txt"))
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "saved by Neovim compatibility test" })
	vim.cmd("write")
	assert(vim.fn.readfile(scratch .. "/nested/notes.txt")[1] == "saved by Neovim compatibility test")
	vim.wait(200)
	assert(vim.v.errmsg == "", vim.v.errmsg)
	assert(#notifications == 0, table.concat(notifications, "\n"))
	print(
		"PASS: full plugins, theme, "
			.. vim.tbl_count(parsers)
			.. " installed parsers, eight filetypes, formatting, and save"
	)
end, debug.traceback)
vim.notify = notify
for _, client in ipairs(vim.lsp.get_clients()) do
	client:stop(true)
end
vim.wait(200)
vim.fn.delete(scratch, "rf")
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
else
	vim.cmd("qa!")
end
