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
	keys = {
		{
			"<leader>c",
			function()
				require("conform").format({
					async = true,
					lsp_fallback = true,
				})
			end,
			mode = { "n", "x" },
			desc = "Conform (format)",
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		vim.o.formatexpr = "v:conform.formatexpr()"
	end,
	config = function(_, opts)
		require("conform").setup(opts)

		vim.o.formatexpr = "v:conform.formatexpr()"
	end,
}
