local map = vim.keymap.set

-- Keep native commenting, buffer navigation, LSP keys, and snippet jumps.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down a display line" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up a display line" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("x", "<", "<gv", { desc = "Indent left" })
map("x", ">", ">gv", { desc = "Indent right" })

-- The same terminal-friendly navigation on macOS and Linux.
for key, direction in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
	map("n", "<C-" .. key .. ">", "<C-w>" .. direction, { desc = "Move to " .. direction .. " window" })
end
map("n", "<leader>fo", ":edit ", { desc = "File: open path" })
map("n", "<leader>fs", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New file" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Buffer: next" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Buffer: previous" })
map("n", "<leader>wh", "<C-w>s", { desc = "Window: horizontal split" })
map("n", "<leader>wv", "<C-w>v", { desc = "Window: vertical split" })
map("n", "<leader>wc", "<C-w>c", { desc = "Window: close" })
map("n", "<leader>qa", "<cmd>confirm qa<CR>", { desc = "Quit: all windows" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic details" })
map("n", "<leader>cs", vim.lsp.buf.document_symbol, { desc = "Document symbols" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
