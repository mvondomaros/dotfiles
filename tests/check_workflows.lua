-- Real Typst build/preview plus agent routing; never starts an agent conversation.
local scratch = vim.fn.tempname() .. "/project with spaces"
local original_executable, original_select = vim.fn.executable, vim.ui.select
local original_toggle, original_visit
local errors = {}
local original_notify = vim.notify
vim.notify = function(message, level, ...)
	if level == vim.log.levels.ERROR then
		errors[#errors + 1] = message
	end
	return original_notify(message, level, ...)
end
local ok, err = xpcall(function()
	assert(vim.g.dotfiles_full, "Full setup is required")
	for _, tool in ipairs({ "typst", "tinymist", "websocat" }) do
		assert(vim.fn.executable(tool) == 1, "Missing tool: " .. tool)
	end
	vim.fn.mkdir(scratch .. "/.git", "p")
	scratch = assert(vim.uv.fs_realpath(scratch))
	local file = scratch .. "/main.typ"
	vim.fn.writefile({ "= Workflow", "", "A short document." }, file)
	vim.cmd("edit " .. vim.fn.fnameescape(file))
	assert(
		require("config.project").root() == scratch,
		"Inconsistent project root: " .. require("config.project").root() .. " vs " .. scratch
	)
	assert(not vim.uv.fs_stat(scratch .. "/main.pdf"), "Unexpected PDF on file open")
	vim.env.TYPST_MAIN = "main.typ"
	assert(require("config.documents").main_file(scratch .. "/chapter.typ") == file, "Build/preview main files differ")
	vim.env.TYPST_MAIN = nil

	local snacks = require("snacks")
	original_toggle = snacks.terminal.toggle
	local launches = {}
	snacks.terminal.toggle = function(command, options)
		launches[#launches + 1] = { command = command, options = options }
	end
	vim.fn.executable = function(name)
		if name == "codex" or name == "claude" then
			return 1
		end
		return original_executable(name)
	end
	vim.cmd("Agent codex")
	assert(vim.deep_equal(launches[1].command, { "codex", "--no-alt-screen" }))
	assert(launches[1].options.cwd == scratch)
	vim.ui.select = function(items, _, choose)
		assert(vim.deep_equal(items, { "codex", "claude" }))
		choose("claude")
	end
	vim.cmd("Agent")
	assert(vim.deep_equal(launches[2].command, { "claude" }))
	assert(launches[2].options.cwd == scratch)
	assert(launches[2].options.env.DISABLE_AUTOUPDATER == "1")
	vim.fn.executable, vim.ui.select = original_executable, original_select
	snacks.terminal.toggle = original_toggle
	print("PASS: agent selection and per-project terminal routing without live agent calls")

	vim.cmd("DocumentBuild")
	assert(
		vim.wait(15000, function()
			return vim.uv.fs_stat(scratch .. "/main.pdf") ~= nil
		end, 50),
		"PDF build failed"
	)
	local pdf = assert(io.open(scratch .. "/main.pdf", "rb"))
	assert(pdf:read(5) == "%PDF-")
	pdf:close()
	local preview_config = require("typst-preview.config").opts
	assert(preview_config.dependencies_bin.tinymist == "tinymist")
	assert(preview_config.dependencies_bin.websocat == "websocat")
	assert(preview_config.host == "127.0.0.1")
	local utils = require("typst-preview.utils")
	original_visit = utils.visit
	local url
	utils.visit = function(link)
		url = link:match("^https?://") and link or ("http://" .. link)
	end
	vim.cmd("DocumentView")
	assert(
		vim.wait(15000, function()
			return url ~= nil
		end, 50),
		"Preview server failed to start"
	)
	local page = vim.system({ "curl", "-fsSL", "--max-time", "8", url }, { text = true }):wait()
	assert(page.code == 0 and #(page.stdout or "") > 100, "Preview did not serve its frontend")
	assert(require("config.documents").url() == url, "Preview URL command returned a different endpoint")
	local upgrade = vim.system({
		"curl",
		"-sS",
		"--http1.1",
		"--max-time",
		"1",
		"--dump-header",
		"-",
		"--output",
		"/dev/null",
		"-H",
		"Connection: Upgrade",
		"-H",
		"Upgrade: websocket",
		"-H",
		"Origin: http://localhost",
		"-H",
		"Sec-WebSocket-Version: 13",
		"-H",
		"Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==",
		url,
	}, { text = true }):wait()
	assert(
		(upgrade.stdout or ""):find(" 101 ", 1, true),
		"Preview HTTP/WebSocket ports differ; SSH forwarding would fail"
	)
	vim.cmd("DocumentSync")
	-- Exercise the registered preview-to-source route without a GUI browser.
	local server = assert(require("typst-preview.servers").get(file)).document
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	for _, listener in ipairs(server.listenerss.editorScrollTo or {}) do
		listener({ filepath = file, start = { 2, 1 }, ["end"] = { 2, 1 } })
	end
	assert(vim.api.nvim_win_get_cursor(0)[1] == 3, "Preview-to-source navigation failed")
	vim.wait(200)
	vim.cmd("DocumentStop")
	assert(not require("typst-preview.servers").get(file), "Preview did not stop")
	utils.visit = original_visit
	assert(#errors == 0, table.concat(errors, "\n"))
	assert(vim.v.errmsg == "", vim.v.errmsg)
	print("PASS: Typst PDF build, shared HTTP/WebSocket endpoint, source/preview navigation, and stop")
end, debug.traceback)
vim.fn.executable, vim.ui.select = original_executable, original_select
if original_toggle then
	require("snacks").terminal.toggle = original_toggle
end
if original_visit then
	require("typst-preview.utils").visit = original_visit
end
pcall(vim.cmd, "TypstPreviewStop")
vim.notify = original_notify
for _, client in ipairs(vim.lsp.get_clients()) do
	client:stop(true)
end
vim.wait(200)
vim.fn.delete(vim.fn.fnamemodify(scratch, ":h"), "rf")
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
else
	vim.cmd("qa!")
end
