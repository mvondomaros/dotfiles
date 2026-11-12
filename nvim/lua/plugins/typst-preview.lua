return {
	"chomosuke/typst-preview.nvim",
	enabled = require("config.role").typst,
	ft = "typst",
	opts = {
		-- Use the explicit installer/updater, never plugin-managed downloads.
		dependencies_bin = { tinymist = "tinymist", websocat = "websocat" },
		host = "127.0.0.1",
		-- Current Tinymist serves HTTP and WebSocket on the same automatic port.
		port = 0,
		open_cmd = vim.env.DOTFILES_PREVIEW_COMMAND or (vim.env.SSH_CONNECTION and "true" or nil),
		get_root = function()
			return vim.env.TYPST_ROOT or require("config.project").root()
		end,
		get_main_file = function(buffer_path)
			return require("config.documents").main_file(buffer_path)
		end,
	},
}
