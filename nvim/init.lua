--Remap space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.lazy")
require("config.autocommands")
require("config.keymaps")
