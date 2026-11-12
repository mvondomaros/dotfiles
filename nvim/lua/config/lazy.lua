-- Downloading and updating plugins is an explicit tools/setup-editor action.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	checker = { enabled = false },
	change_detection = { enabled = false },
	-- The lockfile selects exact commits; avoid a second, often stale tag filter.
	defaults = { version = false },
	install = { missing = vim.env.DOTFILES_NVIM_SETUP == "1", colorscheme = { "ayu-light" } },
	rocks = { enabled = false },
	spec = { { import = "plugins" } },
})
