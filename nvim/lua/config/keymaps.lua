-- Shorten function name
local map = vim.keymap.set

-- Better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
	desc = "Move down",
	expr = true,
	silent = true,
})
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", {
	desc = "Move down",
	expr = true,
	silent = true,
})
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", {
	desc = "Move up",
	expr = true,
	silent = true,
})
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", {
	desc = "Move up",
	expr = true,
	silent = true,
})

-- Move to window
map("n", "<D-Left>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<D-Down>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<D-Up>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<D-Right>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window
map("n", "<D-S-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<D-S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<D-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<D-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move lines
map("n", "<M-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", {
	desc = "Move line down",
})
map("n", "<M-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", {
	desc = "Move line up",
})
map("i", "<M-Down>", "<esc><cmd>m .+1<cr>==gi", {
	desc = "Move line down",
})
map("i", "<M-Up>", "<esc><cmd>m .-2<cr>==gi", {
	desc = "Move line up",
})
map("v", "<M-Down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", {
	desc = "Move selection down",
})
map("v", "<M-Up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", {
	desc = "Move selection up",
})

-- Buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

map("n", "<leader>bb", "<cmd>e #<cr>", {
	desc = "Switch to alternate buffer",
})
map("n", "<leader>`", "<cmd>e #<cr>", {
	desc = "Switch to alternate buffer",
})

map("n", "<leader>bD", "<cmd>:bd<cr>", {
	desc = "Delete buffer and window",
})

-- Clear search
map({ "i", "n", "s" }, "<esc>", function()
	vim.cmd("noh")
	return "<esc>"
end, { expr = true, desc = "Escape and clear search highlight" })

-- Saner n / N
map("n", "n", "'Nn'[v:searchforward].'zv'", {
	expr = true,
	desc = "Next search result",
})
map("x", "n", "'Nn'[v:searchforward]", {
	expr = true,
	desc = "Next search result",
})
map("o", "n", "'Nn'[v:searchforward]", {
	expr = true,
	desc = "Next search result",
})
map("n", "N", "'nN'[v:searchforward].'zv'", {
	expr = true,
	desc = "Previous search result",
})
map("x", "N", "'nN'[v:searchforward]", {
	expr = true,
	desc = "Previous search result",
})
map("o", "N", "'nN'[v:searchforward]", {
	expr = true,
	desc = "Previous search result",
})

-- Better indenting
map("x", "<", "<gv", { desc = "Indent left" })
map("x", ">", ">gv", { desc = "Indent right" })

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", {
	desc = "Add comment below",
})
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", {
	desc = "Add comment above",
})

-- New file
map("n", "<leader>fn", "<cmd>enew<cr>", {
	desc = "New file",
})

-- Formatting
map({ "n", "x" }, "<leader>cf", function()
	require("conform").format({
		async = true,
		lsp_fallback = true,
	})
end, {
	desc = "Format (Conform)",
})

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", {
	desc = "Quit all",
})

-- Windows
map("n", "<leader>-", "<C-W>s", {
	desc = "Split window below",
	remap = true,
})
map("n", "<leader>|", "<C-W>v", {
	desc = "Split window right",
	remap = true,
})
map("n", "<leader>wd", "<C-W>c", {
	desc = "Close window",
	remap = true,
})

-- Tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", {
	desc = "Go to last tab",
})
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", {
	desc = "Close other tabs",
})
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", {
	desc = "Go to first tab",
})
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", {
	desc = "New tab",
})
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", {
	desc = "Next tab",
})
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", {
	desc = "Close tab",
})
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", {
	desc = "Previous tab",
})
