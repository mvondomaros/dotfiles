return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix",
	},

	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)

		wk.add({
			-- top-level leader groups (normal mode)
			{ "<leader>f", group = "file / find", mode = "n" },
			{ "<leader>g", group = "git", mode = "n" },
			{ "<leader>s", group = "search", mode = "n" },
			{ "<leader>b", group = "buffer", mode = "n" },
			{ "<leader>n", group = "notifications", mode = "n" },
			{ "<leader>u", group = "toggles", mode = "n" },
			{ "<leader>q", group = "quit / session", mode = "n" },
			{ "<leader>x", group = "lists", mode = "n" }, -- xl/xq etc
			{ "<leader>w", group = "windows", mode = "n" }, -- wd, -, |
			{ "<leader><tab>", group = "tabs", mode = "n" }, -- all tab mappings
			{ "<leader>c", group = "code / format", mode = "n" }, -- cf (Conform)

			-- nice aliases for specific mappings
			{ "<leader>,", desc = "Find buffers", mode = "n" },
			{ "<leader><space>", desc = "Find files (root)", mode = "n" },

			-- visual-mode search group
			{ "<leader>s", group = "search", mode = "x" },
		})
	end,
}
