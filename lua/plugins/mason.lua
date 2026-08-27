-- Mason is the installer for language server and formatter binaries, nothing
-- more: Neovim 0.12's native vim.lsp.config / vim.lsp.enable does the actual
-- LSP work, so there is no nvim-lspconfig and no mason-lspconfig here.
--
-- The server definitions live in lua/lsp.lua. Mason's bin directory is
-- prepended to $PATH in lua/options.lua, before anything tries to launch a
-- server by name.
require("mason").setup()

require("mason-tool-installer").setup({
  -- tsc is here for the case where a project pins nothing of its own: mason's
  -- copy is TypeScript 7, which is what lua/lsp.lua needs to serve `--lsp`.
  -- A project's own node_modules still wins -- see the version check there --
  -- and mason's is only the fallback, so this line is what keeps that fallback
  -- new enough to be a language server at all.
  ensure_installed = {
    -- Language servers
    "lua-language-server",
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
    "ols",
    -- Formatters
    "prettier",
    "prettierd",
    "stylua",
    "clang-format",
    "shfmt",
    -- odinfmt is not a package of its own -- mason has no entry by that name.
    -- The ols release carries both binaries, so the "ols" line above is what
    -- puts odinfmt on $PATH for conform (lua/plugins/conform.lua).
    "tsc",
  },
  run_on_start = true,
  start_delay = 3000,
})
