return {
	"stevearc/conform.nvim",
	cmd = { "ConformInfo" },
	event = { "BufWritePre" },
	opts = {
		formatters_by_ft = {
			sh = { "shfmt" },
			bash = { "shfmt" },
			fish = { "fish_indent" },
			lua = { "stylua" },
			python = require("config.role").python and { "ruff_format" } or nil,
		},
		default_format_opts = { lsp_format = "fallback" },
		format_on_save = function(buffer)
			-- Preserve authored prose line breaks; format explicitly when wanted.
			if vim.tbl_contains({ "text", "markdown" }, vim.bo[buffer].filetype) then
				return
			end
			local formatters, lsp = require("conform").list_formatters_to_run(buffer)
			if #formatters > 0 or lsp then
				return { timeout_ms = 1000, lsp_format = "fallback" }
			end
		end,
	},
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({
					async = true,
					lsp_format = "fallback",
				})
			end,
			mode = { "n", "x" },
			desc = "Conform (format)",
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
