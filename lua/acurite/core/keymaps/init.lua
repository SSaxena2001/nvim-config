-- Most keymaps live under this directory, split by domain. Buffer-local LSP
-- maps are created at attach time, and the centered command prompt owns its
-- local callbacks in configs/command-input.lua.
--
-- Loaded from init.lua after core/pack.lua so the plugins these reference are
-- on the runtimepath. Callbacks still require() lazily, keeping startup cheap.
require("acurite.core.keymaps.editor")
require("acurite.core.keymaps.window")
require("acurite.core.keymaps.lsp")
require("acurite.core.keymaps.picker")
require("acurite.core.keymaps.git")
require("acurite.core.keymaps.harpoon")
require("acurite.core.keymaps.ui")
require("acurite.core.keymaps.textobj")

require("acurite.configs.which-key")
