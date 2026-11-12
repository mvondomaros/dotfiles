local M = {}

function M.main_file(buffer_path)
	local main = vim.env.TYPST_MAIN or buffer_path or vim.api.nvim_buf_get_name(0)
	if not main:match("^/") then
		main = (vim.env.TYPST_ROOT or require("config.project").root()) .. "/" .. main
	end
	return vim.fs.normalize(main)
end

local function typst()
	if vim.bo.filetype == "typst" then
		return true
	end
	vim.notify("Document builds and previews are for Typst buffers")
end

local function preview_command(name)
	if not typst() then
		return
	end
	if vim.fn.executable("tinymist") == 0 or vim.fn.executable("websocat") == 0 then
		vim.notify("Run tools/install-tools --editor to install preview tools", vim.log.levels.WARN)
		return
	end
	if vim.fn.exists(":" .. name) == 0 then
		vim.notify("Run tools/setup-editor to provision Typst Preview", vim.log.levels.WARN)
		return
	end
	vim.cmd(name)
end

function M.build()
	if not typst() then
		return
	end
	if vim.fn.executable("typst") == 0 then
		vim.notify("Run tools/install-tools --editor to install Typst", vim.log.levels.WARN)
		return
	end
	vim.cmd("write")
	local file = M.main_file()
	local output = vim.fn.fnamemodify(file, ":r") .. ".pdf"
	vim.system(
		{ "typst", "compile", "--root", vim.env.TYPST_ROOT or require("config.project").root(), file, output },
		{ text = true },
		vim.schedule_wrap(function(result)
			vim.notify(
				result.code == 0 and ("Built " .. output) or (result.stderr or "Typst build failed"),
				result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
			)
		end)
	)
end
function M.view()
	preview_command("TypstPreviewToggle")
end
function M.sync()
	preview_command("TypstPreviewSyncCursor")
end
function M.stop()
	preview_command("TypstPreviewStop")
end
function M.url()
	local ok, servers = pcall(require, "typst-preview.servers")
	local file = vim.api.nvim_buf_get_name(0)
	local active = ok and servers.get(file)
	local server = active and active[servers.get_last_mode(file) or "document"]
	if not server then
		vim.notify("Start a preview with DocumentView first", vim.log.levels.WARN)
		return
	end
	local url = "http://" .. server.link
	vim.notify(url)
	return url
end

for name, action in pairs({
	DocumentBuild = M.build,
	DocumentView = M.view,
	DocumentSync = M.sync,
	DocumentStop = M.stop,
	DocumentUrl = M.url,
}) do
	vim.api.nvim_create_user_command(name, action, {})
end
vim.keymap.set("n", "<leader>db", M.build, { desc = "Build Typst PDF" })
vim.keymap.set("n", "<leader>dv", M.view, { desc = "Typst preview" })
vim.keymap.set("n", "<leader>df", M.sync, { desc = "Find source in preview" })
vim.keymap.set("n", "<leader>ds", M.stop, { desc = "Stop preview" })
vim.keymap.set("n", "<leader>du", M.url, { desc = "Show preview URL" })
return M
