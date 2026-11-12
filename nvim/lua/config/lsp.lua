-- Use global executables and Neovim's native client; never install on file open.
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- Avoid recursive watches over environments and shared cluster homes.
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
vim.lsp.config("*", { capabilities = capabilities })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("dotfiles_lsp", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
		end
	end,
})

local servers = {
	tinymist = {
		cmd = { "tinymist" },
		filetypes = { "typst" },
		root_markers = { "typst.toml", ".git" },
		settings = { formatterMode = "typstyle", exportPdf = "never" },
	},
	bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh", "bash" },
		root_markers = { ".git" },
		settings = { bashIde = { backgroundAnalysisMaxFiles = 0 } },
	},
	fish_lsp = {
		cmd = { "fish-lsp", "start" },
		filetypes = { "fish" },
		root_markers = { "config.fish", ".git" },
	},
}
for name, config in pairs(servers) do
	if vim.fn.executable(config.cmd[1]) == 1 then
		vim.lsp.config(name, config)
		vim.lsp.enable(name)
	end
end

vim.diagnostic.config({ severity_sort = true, float = { border = "rounded", source = true } })
