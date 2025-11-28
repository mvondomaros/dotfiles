return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix",
		sort = { "local", "order", "group" },
	},

	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)

		wk.add({
			-- top-level leader groups (normal mode)
			{ "<leader>b", group = "buffer", mode = "n" },
			{ "<leader>f", group = "file / find", mode = "n" },
			{ "<leader>g", group = "git", icon = "", mode = "n" },
			{ "<leader>s", group = "search", mode = "n" },
			{ "<leader>u", group = "ui", mode = "n" },
			{ "<leader><tab>", group = "tabs", mode = "n" }, -- all tab mappings
			{ "<leader>w", group = "windows", mode = "n" }, -- wd, -, |
			{ "<leader>q", group = "quit / session", mode = "n" },

			-- nice aliases for specific mappings
			{ "<leader>,", desc = "Find buffers", mode = "n" },
			{ "<leader><space>", desc = "Find files (root)", mode = "n" },

			-- visual-mode search group
			{ "<leader>s", group = "search", mode = "x" },
		})
	end,
}
