-- Invoked by check_python.py with an isolated project and existing global tools.
local ok, err = xpcall(function()
    local file = assert(vim.env.DOTFILES_PYTHON_TEST_FILE)
    vim.cmd("edit " .. vim.fn.fnameescape(file))
    assert(vim.wait(10000, function()
        local clients = vim.lsp.get_clients({ name = "ty", bufnr = 0 })
        return #clients == 1 and clients[1].initialized
    end, 50), "ty did not attach")
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    assert(#clients == 1 and clients[1].name == "ty", "Unexpected duplicate Python language server")
    local client = clients[1]
    assert(vim.wait(10000, function()
        for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
            if diagnostic.code == "invalid-assignment" then return true end
        end
        return false
    end, 50), "Expected type error was not reported")
    for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        assert(diagnostic.code ~= "unresolved-import", "Project Python environment was not resolved")
    end
    local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    local response = client:request_sync("textDocument/hover", {
        textDocument = { uri = vim.uri_from_bufnr(0) },
        position = { line = 0, character = assert(line:find("answer", 1, true)) - 1 },
    }, 5000, 0)
    assert(response and response.result and response.result.contents, "Python hover failed")
    vim.cmd("write")
    local text = table.concat(vim.fn.readfile(file), "\n")
    assert(text:find("number: int = answer()", 1, true), "Ruff did not format on save")
    assert(vim.v.errmsg == "", vim.v.errmsg)
    print("PASS: one ty client, project imports, type diagnostics, hover, Ruff format on save")
end, debug.traceback)
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
