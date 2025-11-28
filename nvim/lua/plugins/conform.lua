return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	opts = {
		formatters_by_ft = {
			bash = { "beautysh" },
			fish = { "fish_indent" },
			lua = { "stylua" },
			python = { "ruff" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)

		vim.o.formatexpr = "v:conform.formatexpr()"
	end,
}
