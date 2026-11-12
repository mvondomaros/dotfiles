local M = {}
local commands = { codex = { "codex", "--no-alt-screen" }, claude = { "claude" } }

function M.open(provider)
	if not provider or provider == "" then
		local available = {}
		for _, name in ipairs({ "codex", "claude" }) do
			if vim.fn.executable(name) == 1 then
				available[#available + 1] = name
			end
		end
		if #available == 0 then
			vim.notify("Install agent CLIs with tools/install-tools --agents", vim.log.levels.WARN)
			return
		end
		vim.ui.select(available, { prompt = "Coding agent" }, function(choice)
			if choice then
				M.open(choice)
			end
		end)
		return
	end
	if not commands[provider] then
		vim.notify("Choose codex or claude", vim.log.levels.WARN)
		return
	end
	if vim.fn.executable(provider) == 0 then
		vim.notify(provider .. " is missing; run tools/install-tools --agents", vim.log.levels.WARN)
		return
	end
	local ok, snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("Run tools/setup-editor to enable the agent terminal", vim.log.levels.WARN)
		return
	end
	snacks.terminal.toggle(commands[provider], {
		cwd = require("config.project").root(),
		env = provider == "claude" and { DISABLE_AUTOUPDATER = "1" } or nil,
		win = { position = "right", width = 0.45 },
	})
end

vim.api.nvim_create_user_command("Agent", function(opts)
	M.open(opts.args)
end, {
	nargs = "?",
	complete = function()
		return { "codex", "claude" }
	end,
	desc = "Open a coding agent in this project",
})
vim.keymap.set("n", "<leader>ap", function()
	M.open()
end, { desc = "Agent: pick Codex or Claude" })
return M
