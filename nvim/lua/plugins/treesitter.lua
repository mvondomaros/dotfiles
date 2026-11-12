return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	-- Parser compilation belongs to the explicit setup-editor --parsers step.
	config = function()
		require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
		local function enable(event)
			local buffer = event and event.buf or vim.api.nvim_get_current_buf()
			local ft = vim.bo[buffer].filetype
			if vim.bo[buffer].buftype ~= "" then
				return
			end
			local language = vim.treesitter.language.get_lang(ft)
			local ok, loaded = pcall(vim.treesitter.language.add, language or "")
			if ok and loaded then
				pcall(vim.treesitter.start, buffer, language)
				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			else
				vim.wo.foldmethod = "indent"
			end
		end
		vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
			group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true }),
			callback = enable,
		})
	end,
}
