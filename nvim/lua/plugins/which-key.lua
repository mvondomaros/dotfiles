return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = { preset = "helix" },
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)
		wk.add({
			{ "<leader>a", group = "agents" },
			{ "<leader>b", group = "buffers" },
			{ "<leader>c", group = "code" },
			{ "<leader>f", group = "files" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "help / history" },
			{ "<leader>s", group = "search" },
			{ "<leader>t", group = "terminal" },
			{ "<leader>u", group = "UI" },
			{ "<leader>w", group = "windows" },
			{ "<leader>q", group = "quit" },
		})
		if require("config.role").typst then
			wk.add({ { "<leader>d", group = "documents" } })
		end
	end,
}
