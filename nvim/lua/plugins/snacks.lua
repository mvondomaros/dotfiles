return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		explorer = { enabled = true, replace_netrw = true },
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		terminal = { enabled = true },
	},
	keys = function()
		local root = require("config.project").root
		local picker = require("snacks.picker")
		return {
			{
				"<leader>st",
				function()
					picker.grep({ cwd = root() })
				end,
				desc = "Search project text",
			},
			{
				"<leader>bl",
				function()
					picker.buffers()
				end,
				desc = "Buffer: list",
			},
			{
				"<leader>fe",
				function()
					Snacks.explorer.open({ cwd = root() })
				end,
				desc = "File: explorer",
			},
			{
				"<leader>ff",
				function()
					picker.files({ cwd = root() })
				end,
				desc = "Find project files",
			},
			{
				"<leader>fr",
				function()
					picker.recent({ filter = { cwd = root() } })
				end,
				desc = "Recent project files",
			},
			{ "<leader>bb", "<cmd>buffer #<CR>", desc = "Buffer: back" },
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Close buffer",
			},
			{
				"<leader>gs",
				function()
					if vim.fn.executable("lazygit") == 1 then
						Snacks.lazygit({ cwd = root() })
					else
						picker.git_status({ cwd = root() })
					end
				end,
				desc = "Git: status",
			},
			{
				"<leader>gd",
				function()
					picker.git_diff({ cwd = root() })
				end,
				desc = "Git diff",
			},
			{
				"<leader>gl",
				function()
					picker.git_log({ cwd = root() })
				end,
				desc = "Git history",
			},
			{
				"<leader>sd",
				function()
					picker.diagnostics()
				end,
				desc = "Find diagnostics",
			},
			{
				"<leader>hs",
				function()
					picker.help()
				end,
				desc = "Search help",
			},
			{
				"<leader>hk",
				function()
					picker.keymaps()
				end,
				desc = "Search keybindings",
			},
			{
				"<leader>tt",
				function()
					Snacks.terminal.toggle(nil, { cwd = root() })
				end,
				desc = "Terminal: toggle for project",
			},
			{
				"<leader>hn",
				function()
					picker.notifications()
				end,
				desc = "History: notifications",
			},
			{
				"<leader>uw",
				function()
					vim.wo.wrap = not vim.wo.wrap
				end,
				desc = "Toggle wrapping",
			},
			{
				"<leader>us",
				function()
					vim.wo.spell = not vim.wo.spell
				end,
				desc = "Toggle spelling",
			},
		}
	end,
}
