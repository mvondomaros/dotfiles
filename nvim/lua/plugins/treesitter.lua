return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },

	opts = {
		install = { use_ts_cli = false },
		ensure_installed = {
			"bash",
			"bibtex",
			"c",
			"cpp",
			"css",
			"csv",
			"diff",
			"fish",
			"fortran",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"html",
			"json",
			"julia",
			"lua",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"printf",
			"python",
			"regex",
			"ssh_config",
			"tcl",
			"toml",
			"yaml",
		},

		sync_install = false,
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
	},

	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
	end,
}
