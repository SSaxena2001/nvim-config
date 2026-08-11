local Mason = require("mason")
local MasonToolInstaller = require("mason-tool-installer")

Mason.setup({
  firewall = {
    enabled = true,
    auto_managed = true,
  },
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

MasonToolInstaller.setup({
  ensure_installed = {
    "lua-language-server",
    "typescript-language-server",
    "html-lsp",
    "css-lsp",
    "tailwindcss-language-server",
    "eslint-lsp",
    "json-lsp",
    "pyright",
    "ruff",
    "gopls",
    "goimports",
    "clangd",
    "rust-analyzer",
    "astro-language-server",
    "emmet-ls",
    "marksman",
    "prettier",
    "prettierd",
    "stylua",
    "clang-format",
    "black",
    "isort",
    "pylint",
    "shfmt",
  },
})
