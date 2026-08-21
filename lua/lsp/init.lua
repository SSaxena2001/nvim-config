-- LSP entry point. Order matters: diagnostics and the wildcard config are set
-- up before servers.lua declares individual servers, and the enable list runs
-- last so every `vim.lsp.config` call it references already exists.
require("lsp.diagnostics")
require("lsp.commands")
require("lsp.attach")

vim.lsp.config("*", {
  capabilities = require("lsp.capabilities"),
  flags = {
    -- Reduce didChange traffic to language servers while typing.
    debounce_text_changes = 250,
  },
})

require("lsp.servers")

-- Servers are launched by name off $PATH. mason is gone, so install them with
-- the system package manager:
--   brew install lua-language-server gopls marksman llvm
--   npm i -g @typescript/native-preview vscode-langservers-extracted \
--            emmet-ls @astrojs/language-server pyright
--   uv tool install ruff
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

-- Native completion, in place of nvim-cmp. Neovim drives the popup itself from
-- the server's completion items; `autotrigger` opens it as you type rather
-- than only on <C-x><C-o>.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspNativeCompletion", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.opt.completeopt:append({ "noselect", "popup" })
