-- Server roles must stay lean even when workstation executables are on PATH.
local scratch = vim.fn.tempname()
local ok, err = xpcall(function()
	assert(require("config.role").name == "server", "Run with DOTFILES_ROLE=server")
	assert(vim.g.dotfiles_full, "Full shared editor did not load")
	assert(vim.fn.exists(":DocumentBuild") == 0, "Server exposes document integration")
	assert(vim.fn.exists(":Agent") == 2, "Server agent integration is missing")
	vim.fn.mkdir(scratch, "p")
	require("lazy").load({ plugins = { "conform.nvim" } })
	for _, sample in ipairs({
		{ "sample.py", "value=1", "ty" },
		{ "sample.typ", "#let value=1", "tinymist" },
	}) do
		local file = scratch .. "/" .. sample[1]
		vim.fn.writefile({ sample[2] }, file)
		vim.cmd("edit " .. vim.fn.fnameescape(file))
		vim.cmd("write")
		vim.wait(300)
		assert(#vim.lsp.get_clients({ name = sample[3] }) == 0, "Server started " .. sample[3])
		assert(vim.fn.readfile(file)[1] == sample[2], "Server formatted a workstation-only filetype")
	end
	vim.cmd("edit " .. vim.fn.fnameescape(scratch .. "/sample.py"))
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "import os" })
	vim.fn.setqflist({})
	vim.cmd("Lint")
	vim.wait(300)
	assert(#vim.fn.getqflist() == 0, "Server ran Python lint")
	vim.bo.modified = false
	assert(vim.fn.exists(":TypstPreview") == 0, "Server loaded Typst Preview")
	assert(vim.v.errmsg == "", vim.v.errmsg)
	print(
		"PASS: server editor and agents enabled; Python/Typst language servers, formatting, lint, and preview disabled"
	)
end, debug.traceback)
for _, client in ipairs(vim.lsp.get_clients()) do
	client:stop(true)
end
vim.fn.delete(scratch, "rf")
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
else
	vim.cmd("qa!")
end
