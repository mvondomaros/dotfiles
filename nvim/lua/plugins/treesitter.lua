return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },

	opts = {
		install = { use_ts_cli = false },
		ensure_installed = {},

		sync_install = false,
		auto_install = false,
		highlight = { enable = true },
		indent = { enable = true },
	},

	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		local function folds()
			local language = vim.treesitter.language.get_lang(vim.bo.filetype)
			local ok, loaded = pcall(vim.treesitter.language.add, language or "")
			if ok and loaded then
				vim.opt_local.foldmethod = "expr"
				vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
			else
				vim.opt_local.foldmethod = "indent"
			end
		end
		vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
			group = vim.api.nvim_create_augroup("dotfiles_folds", { clear = true }),
			callback = folds,
		})
		folds()
	end,
}
