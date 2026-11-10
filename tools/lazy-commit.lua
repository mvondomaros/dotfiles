local lock = vim.json.decode(table.concat(vim.fn.readfile(arg[1]), "\n"))
io.write(lock["lazy.nvim"].commit)
