-- LSP entry point. Order matters: diagnostics and the wildcard config are set
-- up before servers.lua declares individual servers, and the enable list runs
-- last so every `vim.lsp.config` call it references already exists.
require("acurite.lsp.diagnostics")
require("acurite.lsp.commands")
require("acurite.lsp.attach")

vim.lsp.config("*", {
  capabilities = require("acurite.lsp.capabilities"),
  flags = {
    -- Reduce didChange traffic to language servers while typing.
    debounce_text_changes = 250,
  },
})

require("acurite.lsp.servers")

-- Instead of using mason enable all configured LSP via `automatic_enable=true`
-- Prefer more control by enable manual server call below via vim.lsp.enable("")
-- mason config: lua/acurite/configs/mason.lua
vim.lsp.enable({
  "lua_ls",
  "cssls",
  "html",
  "emmet_ls",
  "tsgo",
  "jsonls",
  "pyright",
  "ruff",
  "gopls",
  "clangd",
  "astro",
  "marksman",
})
