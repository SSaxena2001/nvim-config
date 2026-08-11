-- LSP entry point. Order matters: diagnostics and the wildcard config are set
-- up before servers.lua declares individual servers, and the enable list runs
-- last so every `vim.lsp.config` call it references already exists.
require("acurite.configs.lsp.diagnostics")
require("acurite.configs.lsp.commands")
require("acurite.configs.lsp.attach")

vim.lsp.config("*", {
  capabilities = require("acurite.configs.lsp.capabilities"),
  flags = {
    -- Reduce didChange traffic to language servers while typing.
    debounce_text_changes = 250,
  },
})

require("acurite.configs.lsp.servers")

-- Instead of using mason enable all configured LSP via `automatic_enable=true`
-- Prefer more control by enable manual server call below via vim.lsp.enable("")
-- mason config: lua/acurite/configs/mason.lua
vim.lsp.enable({
  "lua_ls",
  "cssls",
  "html",
  "emmet_ls",
  "ts_ls",
  "eslint",
  "jsonls",
  "pyright",
  "ruff",
  "gopls",
  "clangd",
  "rust_analyzer",
  "astro",
  "tailwindcss",
  "marksman",
})
