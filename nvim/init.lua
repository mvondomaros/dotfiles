-- Spell dictionaries, like plugins/parsers, are never downloaded on file open.
vim.g.loaded_spellfile_plugin = 1
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- The standalone Vim configuration works even on old/offline Neovim installs.
local config_home = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h")
vim.cmd("source " .. vim.fn.fnameescape(config_home .. "/vimrc"))
vim.g.dotfiles_full = false
if vim.fn.has("nvim-0.11") == 0 or vim.env.DOTFILES_NVIM_MODE == "basic" then
    return
end
require("config.options")
require("config.lsp")
require("config.python")
require("config.lint")
local data = vim.fn.stdpath("data") .. "/lazy/"
local complete = true
local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
for name in pairs(lock) do
    if vim.fn.isdirectory(data .. name) == 0 then
        complete = false
        break
    end
end
if complete or vim.env.DOTFILES_NVIM_SETUP == "1" then
    require("config.lazy")
    vim.g.dotfiles_full = true
end
require("config.autocommands")
require("config.keymaps")
