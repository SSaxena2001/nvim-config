-- Byte-compile and cache Lua modules. Must run before the first `require` to
-- cover every module below.
vim.loader.enable()

-- Snacks replaces netrw, and these archive/matching plugins are rarely useful
-- in a development session. Skipping them avoids hundreds of startup autocmds.
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_matchit = 1

require("acurite.core.options")
require("acurite.core.commands")
require("acurite.core.autocmds")

-- Plugins first: core/keymaps references them, and which-key needs to be on the
-- runtimepath before the mappings it documents are registered.
require("acurite.core.pack")
require("acurite.core.keymaps")
