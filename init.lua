vim.g.mapleader = " "

-- netrw is off. oil.nvim (lua/plugins/oil.lua) owns directory buffers, and it
-- sets these two globals itself -- but only once its setup() runs, which is
-- long after Neovim has already sourced netrw's plugin and autoload files.
-- Setting them here, before runtimepath plugins load, stops netrw from being
-- read at all. `gx` still works: Neovim routes it through vim.ui.open now.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("options")
require("pack")
require("colorscheme")
require("lsp")
require("find")
require("grep")
require("picker")
require("autocommands")
require("lazygit")
require("keymaps")
