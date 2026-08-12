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
    "tsgo",
    "html-lsp",
    "css-lsp",
    "json-lsp",
    "pyright",
    "ruff",
    "gopls",
    "goimports",
    "clangd",
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
