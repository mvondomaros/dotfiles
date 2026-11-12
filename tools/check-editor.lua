-- Fail provisioning if a download/checkout failed, even if Lazy returned zero.
local lock = vim.json.decode(table.concat(vim.fn.readfile(arg[1]), "\n"))
local role = dofile(vim.fn.fnamemodify(arg[1], ":h") .. "/lua/config/role.lua")
local failed = false
for name, spec in pairs(lock) do
	if role.plugin_enabled(name) then
		local path = vim.fn.stdpath("data") .. "/lazy/" .. name
		local head = vim.fn.system({ "git", "-C", path, "rev-parse", "HEAD" }):gsub("%s+$", "")
		if vim.v.shell_error ~= 0 or head ~= spec.commit then
			io.stderr:write("Plugin not provisioned at pinned commit: " .. name .. "\n")
			failed = true
		end
	end
end
if failed then
	os.exit(1)
end
