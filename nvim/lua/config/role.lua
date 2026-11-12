local role = vim.env.DOTFILES_ROLE
if not role or role == "" then
	local file = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") .. "/dotfiles/local/role"
	role = vim.fn.filereadable(file) == 1 and (vim.fn.readfile(file)[1] or "") or "workstation"
end
assert(role == "server" or role == "workstation", "Invalid dotfiles role: " .. role)
local M = { name = role, python = role == "workstation", typst = role == "workstation" }
function M.plugin_enabled(name)
	return name ~= "typst-preview.nvim" or M.typst
end
return M
