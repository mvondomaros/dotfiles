return {
	"Shatur/neovim-ayu",
	lazy = false,
	priority = 1000,
	config = function()
		vim.opt.background = "light"
		vim.cmd.colorscheme("ayu-light")
	end,
}
