-- Restore sources directly: Lazy's missing-plugin bootstrap can rewrite pins
-- from existing checkouts before its restore command runs during a migration.
local ok, err = xpcall(function()
	local repo = assert(arg[1])
	local lock = vim.json.decode(table.concat(vim.fn.readfile(repo .. "/nvim/lazy-lock.json"), "\n"))
	local sources = { ["lazy.nvim"] = "folke/lazy.nvim" }
	for _, file in ipairs(vim.fn.glob(repo .. "/nvim/lua/plugins/*.lua", false, true)) do
		local spec = dofile(file)
		sources[spec.name or spec[1]:match("[^/]+$")] = spec[1]
	end
	local function git(args)
		local result = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait(180000)
		return result.code == 0, result.stderr
	end
	local data = vim.fn.stdpath("data") .. "/lazy/"
	vim.fn.mkdir(data, "p")
	for _, name in ipairs(vim.fn.sort(vim.tbl_keys(lock))) do
		local path, commit = data .. name, lock[name].commit
		local source = assert(sources[name], "No plugin source configured for " .. name)
		if not vim.uv.fs_stat(path .. "/.git") then
			assert(
				git({ "clone", "--filter=blob:none", "--no-checkout", "https://github.com/" .. source .. ".git", path })
			)
		end
		if not git({ "-C", path, "cat-file", "-e", commit .. "^{commit}" }) then
			assert(git({ "-C", path, "fetch", "--filter=blob:none", "--depth=1", "origin", commit }))
		end
		assert(git({ "-C", path, "checkout", "--detach", commit }))
		print("ready: " .. name)
	end
end, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	os.exit(1)
end
