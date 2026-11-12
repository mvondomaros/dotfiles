local M = {}

function M.root(buffer)
	buffer = buffer or 0
	local name = vim.api.nvim_buf_get_name(buffer)
	local start = vim.bo[buffer].buftype == "" and name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
	return vim.fs.root(start, ".git") or vim.fs.root(start, { "pixi.toml", "pyproject.toml", "typst.toml" }) or start
end

return M
