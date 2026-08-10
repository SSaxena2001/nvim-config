-- All keymaps live under this directory, split by domain. Plugin config files
-- in configs/ hold setup() only, with two deliberate exceptions: buffer-local
-- maps created inside an LSP on_attach (configs/lsp/servers.lua) and the
-- snacks input-window maps (configs/snacks.lua), both of which need a buffer
-- handle that only exists at callback time.
--
-- Loaded from init.lua after core/pack.lua so the plugins these reference are
-- on the runtimepath. Callbacks still require() lazily, keeping startup cheap.
require("acurite.core.keymaps.editor")
require("acurite.core.keymaps.window")
require("acurite.core.keymaps.lsp")
require("acurite.core.keymaps.picker")
require("acurite.core.keymaps.git")
require("acurite.core.keymaps.ui")
require("acurite.core.keymaps.textobj")

require("acurite.configs.which-key")
