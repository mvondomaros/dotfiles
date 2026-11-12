-- On-demand checks use the same global CLI tools, without a second Python LSP.
vim.api.nvim_create_user_command("Lint", function()
	local buffer = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[buffer].filetype
	local filename = vim.api.nvim_buf_get_name(buffer)
	local command
	if filetype == "python" then
		if not require("config.role").python then
			vim.notify("Python tooling is disabled in the server role", vim.log.levels.INFO)
			return
		end
		command = {
			"ruff",
			"check",
			"--output-format=json",
			"--stdin-filename",
			filename ~= "" and filename or "stdin.py",
			"-",
		}
	elseif filetype == "sh" or filetype == "bash" then
		command = { "shellcheck", "--format=json", "-" }
		if filetype == "bash" or vim.b[buffer].is_bash == 1 then
			table.insert(command, 2, "--shell=bash")
		elseif vim.b[buffer].is_sh == 1 then
			table.insert(command, 2, "--shell=sh")
		end
	elseif filetype == "fish" then
		command = { "fish", "--no-config", "--no-execute" }
	else
		vim.notify("Lint supports Python, Bash/sh, and Fish buffers", vim.log.levels.INFO)
		return
	end
	if vim.fn.executable(command[1]) == 0 then
		vim.notify(command[1] .. " is unavailable; install the editor tools explicitly", vim.log.levels.WARN)
		return
	end
	local tick = vim.api.nvim_buf_get_changedtick(buffer)
	local cwd = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
	local input = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n") .. "\n"
	vim.system(
		command,
		{ text = true, stdin = input, cwd = cwd },
		vim.schedule_wrap(function(result)
			if not vim.api.nvim_buf_is_valid(buffer) or vim.api.nvim_buf_get_changedtick(buffer) ~= tick then
				vim.notify("Buffer changed during lint; run :Lint again", vim.log.levels.INFO)
				return
			end
			local items = {}
			if filetype == "fish" then
				for line in (result.stderr or ""):gmatch("[^\n]+") do
					local number, message = line:match("^.-%(line (%d+)%)%: (.+)")
					if not number then
						message = line:match("^fish: (.+)")
						if message then
							number = "1"
						end
					end
					if number then
						items[#items + 1] =
							{ bufnr = buffer, lnum = tonumber(number), col = 1, type = "E", text = message }
					end
				end
			else
				local ok, findings = pcall(vim.json.decode, result.stdout or "")
				if not ok or type(findings) ~= "table" or result.code > 1 then
					vim.notify(
						command[1] .. " failed: " .. (result.stderr or result.stdout or ""),
						vim.log.levels.ERROR
					)
					return
				end
				for _, finding in ipairs(findings) do
					local python = filetype == "python"
					local location = python and finding.location or { row = finding.line, column = finding.column }
					items[#items + 1] = {
						bufnr = buffer,
						lnum = location.row,
						col = location.column,
						type = python and "W" or (finding.level == "error" and "E" or "W"),
						text = (python and finding.code or "SC" .. finding.code) .. ": " .. finding.message,
					}
				end
			end
			if result.code ~= 0 and #items == 0 then
				vim.notify(command[1] .. " failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
				return
			end
			vim.fn.setqflist(
				{},
				" ",
				{ title = command[1] .. ": " .. vim.fn.fnamemodify(filename, ":t"), items = items }
			)
			vim.cmd("cwindow")
			if #items == 0 then
				vim.notify("Lint: no findings")
			end
		end)
	)
end, { desc = "Lint current Python/shell buffer into quickfix (including unsaved edits)" })
vim.keymap.set("n", "<leader>cl", "<cmd>Lint<cr>", { desc = "Lint buffer" })
