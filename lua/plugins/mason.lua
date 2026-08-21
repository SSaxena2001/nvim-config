-- Mason is the installer for language server and formatter binaries, nothing
-- more: Neovim 0.12's native vim.lsp.config / vim.lsp.enable does the actual
-- LSP work, so there is no nvim-lspconfig and no mason-lspconfig here.
--
-- The server definitions live in lua/lsp/servers.lua. Mason's bin directory is
-- prepended to $PATH in lua/options.lua, before anything tries to launch a
-- server by name.
require("mason").setup()

require("mason-tool-installer").setup({
  ensure_installed = {
    -- Language servers
    "lua-language-server",
    "tsgo",
    "html-lsp",
    "css-lsp",
    "json-lsp",
    "pyright",
    "ruff",
    "gopls",
    "clangd",
    "astro-language-server",
    "emmet-ls",
    "marksman",
    -- Formatters
    "prettier",
    "prettierd",
    "stylua",
    "clang-format",
    "goimports",
    "shfmt",
  },
  run_on_start = true,
  start_delay = 3000,
})
