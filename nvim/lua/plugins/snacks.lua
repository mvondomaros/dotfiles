return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,

	opts = {
		animate = { enabled = true },
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true, replace_netrw = true, trash = true },
		dim = { enabled = true },
		git = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		lazygit = { enabled = true },
		notifier = { enabled = true },
		terminal = { enabled = true },
		picker = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		toggle = { map = vim.keymap.set },
		util = { enabled = true },
	},

	-- all Snacks-related keymaps
	keys = function()
		local Snacks = require("snacks")
		local picker = require("snacks.picker")

		local function project_root()
			if Snacks.util and Snacks.util.root then
				local ok, root = pcall(Snacks.util.root)
				if ok and root and root ~= "" then
					return root
				end
			end
			return vim.fn.getcwd()
		end

		return {
			-- Notifications ---------------------------------------------------------
			{
				"<leader>n",
				function()
					if Snacks.config.picker and Snacks.config.picker.enabled then
						picker.notifications()
					else
						Snacks.notifier.show_history()
					end
				end,
				desc = "Show notifications",
			},

			-- Buffers & bufdelete ---------------------------------------------------
			{
				"<leader>,",
				function()
					picker.buffers()
				end,
				desc = "Find buffers",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete buffer",
			},
			{
				"<leader>bo",
				function()
					Snacks.bufdelete.other()
				end,
				desc = "Delete other buffers",
			},

			-- Files / find ----------------------------------------------------------
			{
				"<leader><space>",
				function()
					picker.files({ cwd = project_root() })
				end,
				desc = "Find files (root)",
			},
			{
				"<leader>fe",
				function()
					Snacks.explorer.open()
				end,
				desc = "Explorer",
			},
			{
				"<leader>ff",
				function()
					picker.files({ cwd = project_root() })
				end,
				desc = "Find files (root)",
			},
			{
				"<leader>fF",
				function()
					picker.files({ cwd = vim.fn.getcwd() })
				end,
				desc = "Find files (cwd)",
			},
			{
				"<leader>fg",
				function()
					picker.git_files()
				end,
				desc = "Find git files",
			},
			{
				"<leader>fr",
				function()
					picker.oldfiles({ cwd = project_root() })
				end,
				desc = "Find recent files (root)",
			},
			{
				"<leader>fR",
				function()
					picker.recent({ filter = { cwd = true } })
				end,
				desc = "Find recent files (cwd)",
			},
			{
				"<leader>fp",
				function()
					picker.projects()
				end,
				desc = "Find projects",
			},

			-- Grep ------------------------------------------------------------------
			{
				"<leader>sf",
				function()
					picker.grep({ cwd = project_root() })
				end,
				desc = "Grep in files (root)",
			},
			{
				"<leader>sF",
				function()
					picker.grep({ cwd = vim.fn.getcwd() })
				end,
				desc = "Grep in files (cwd)",
			},
			{
				"<leader>sb",
				function()
					picker.grep_buffers()
				end,
				desc = "Grep in open buffers",
			},

			-- Search / misc pickers -------------------------------------------------
			{
				'<leader>s"',
				function()
					picker.registers()
				end,
				desc = "Search registers",
			},
			{
				"<leader>s/",
				function()
					picker.search_history()
				end,
				desc = "Search search history",
			},
			{
				"<leader>sC",
				function()
					picker.command_history()
				end,
				desc = "Search command history",
			},
			{
				"<leader>sc",
				function()
					picker.commands()
				end,
				desc = "Search commands",
			},
			{
				"<leader>sh",
				function()
					picker.help()
				end,
				desc = "Search help pages",
			},
			{
				"<leader>sk",
				function()
					picker.keymaps()
				end,
				desc = "Search keymaps",
			},

			-- Git pickers -----------------------------------------------------------
			{
				"<leader>gd",
				function()
					picker.git_diff()
				end,
				desc = "Git diff (local)",
			},
			{
				"<leader>gD",
				function()
					picker.git_diff({
						base = vim.fn.systemlist("git rev-parse --abbrev-ref --symbolic-full-name @{u}")[1],
						group = true,
					})
				end,
				desc = "Git diff (upstream)",
			},
			{
				"<leader>gs",
				function()
					picker.git_status()
				end,
				desc = "Git status",
			},
			{
				"<leader>gS",
				function()
					picker.git_stash()
				end,
				desc = "Git stash",
			},

			-- Extra git pickers -----------------------------------------------------
			{
				"<leader>gL",
				function()
					picker.git_log()
				end,
				desc = "Git log (cwd)",
			},
			{
				"<leader>gf",
				function()
					picker.git_log_file()
				end,
				desc = "Git log (file)",
			},
			{
				"<leader>gl",
				function()
					picker.git_log({ cwd = project_root() })
				end,
				desc = "Git log (root)",
			},

			-- Lazygit ---------------------------------------------------------------
			{
				"<leader>gg",
				function()
					if vim.fn.executable("lazygit") == 1 then
						Snacks.lazygit({ cwd = project_root() })
					else
						vim.notify("lazygit not found in PATH", vim.log.levels.WARN)
					end
				end,
				desc = "Open Lazygit (root)",
			},
			{
				"<leader>gG",
				function()
					if vim.fn.executable("lazygit") == 1 then
						Snacks.lazygit()
					else
						vim.notify("lazygit not found in PATH", vim.log.levels.WARN)
					end
				end,
				desc = "Open Lazygit (cwd)",
			},

			-- Terminals -------------------------------------------------------------
			{
				"<leader>fT",
				function()
					Snacks.terminal()
				end,
				desc = "Open terminal (cwd)",
			},
			{
				"<leader>ft",
				function()
					Snacks.terminal(nil, { cwd = project_root() })
				end,
				desc = "Open terminal (root)",
			},
			{
				"<c-/>",
				function()
					Snacks.terminal(nil, { cwd = project_root() })
				end,
				mode = { "n", "t" },
				desc = "Toggle terminal (root)",
			},
			{
				"<c-_>",
				function()
					Snacks.terminal(nil, { cwd = project_root() })
				end,
				mode = { "n", "t" },
				desc = "which_key_ignore",
			},
		}
	end,

	config = function(_, opts)
		local Snacks = require("snacks")
		Snacks.setup(opts)

		-- Simple toggles (you can prune these)
		Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
		Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
		Snacks.toggle.line_number():map("<leader>ul")
	end,
}
