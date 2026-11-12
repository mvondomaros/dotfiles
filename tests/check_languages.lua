-- Real tools, LSP attachment, formatting, prose settings, and unsaved-buffer lint.
local scratch = vim.fn.tempname()
local ok, err = xpcall(function()
	vim.fn.mkdir(scratch, "p")
	require("lazy").load({ plugins = { "conform.nvim", "nvim-treesitter" } })
	local conform = require("conform")
	local function edit(name, text)
		local path = scratch .. "/" .. name
		vim.fn.writefile(vim.split(text, "\n", { plain = true }), path)
		vim.cmd("edit " .. vim.fn.fnameescape(path))
		return vim.api.nvim_get_current_buf()
	end
	local function attached(name)
		assert(
			vim.wait(15000, function()
				local clients = vim.lsp.get_clients({ name = name, bufnr = 0 })
				return #clients == 1 and clients[1].initialized
			end, 50),
			name .. " did not attach"
		)
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		assert(#clients == 1, "Duplicate language servers")
		return clients[1]
	end
	local function lint(pattern)
		local buffer = vim.api.nvim_get_current_buf()
		vim.fn.setqflist({}, " ", { title = "waiting", items = {} })
		vim.cmd("Lint")
		assert(
			vim.wait(10000, function()
				local items = vim.fn.getqflist()
				for _, item in ipairs(items) do
					if item.bufnr == buffer and item.text:find(pattern, 1, true) then
						return true
					end
				end
				return false
			end, 50),
			"Missing lint finding: " .. pattern
		)
		vim.cmd("cclose")
	end
	edit("notes.txt", "Text stays on its original line.")
	assert(vim.wo.wrap and vim.wo.spell)
	assert(vim.wo.foldmethod == "indent", "Missing parser should retain indent folds")
	assert(vim.o.spelllang == "en,de", "English/German spelling not provisioned")
	assert(vim.fn.spellbadword("Rechtschreibung")[1] == "", "German dictionary failed")
	assert(vim.fn.spellbadword("qxzqxzqxz")[1] ~= "", "Spelling check inactive")

	edit("sample.sh", '#!/bin/bash\nif true;then\necho "$HOME"\nfi')
	if vim.fn.executable("bash-language-server") == 1 then
		attached("bashls")
	end
	assert(not vim.wo.spell and not vim.wo.wrap)
	vim.cmd("write")
	assert(
		table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find('    echo "$HOME"', 1, true),
		"shfmt did not format"
	)
	-- Lint must read unsaved contents, not just the clean file on disk.
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "#!/bin/bash", "echo $UNQUOTED" })
	lint("SC2086")
	vim.bo.modified = false

	edit("sample.fish", "if true\necho hello\nend")
	if vim.fn.executable("fish-lsp") == 1 then
		attached("fish_lsp")
	end
	vim.cmd("write")
	assert(vim.api.nvim_buf_get_lines(0, 1, 2, false)[1] == "    echo hello", "fish_indent did not format")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "if true" })
	lint("Missing end")
	vim.bo.modified = false

	if require("config.role").python then
		edit("sample.py", 'print("clean disk file")')
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "import os" })
		lint("F401")
		vim.bo.modified = false
	else
		print("SKIP: Python tooling disabled for server role")
	end

	if require("config.role").typst and vim.fn.executable("tinymist") == 1 then
		edit("sample.typ", "#let value=1\n#missing_name")
		local typst = attached("tinymist")
		assert(vim.wo.wrap and vim.wo.spell)
		assert(
			vim.wait(15000, function()
				return #vim.diagnostic.get(0) > 0
			end, 50),
			"Typst diagnostics missing"
		)
		vim.cmd("write")
		assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "#let value = 1", "Tinymist did not format on save")
		assert(not vim.uv.fs_stat(scratch .. "/sample.pdf"), "Unexpected PDF export")
		assert(typst.config.settings.exportPdf == "never")
	else
		print("SKIP: Typst tooling disabled or unavailable")
	end

	assert(vim.v.errmsg == "", vim.v.errmsg)
	print("PASS: enabled language features, formatting, bilingual spelling, and unsaved-buffer lint")
end, debug.traceback)
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
