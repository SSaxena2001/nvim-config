-- LSP. Neovim 0.12's native vim.lsp.config / vim.lsp.enable does the work, so
-- there is no nvim-lspconfig and no mason-lspconfig here. Mason is kept purely
-- as the installer for the server and formatter binaries.
--
-- The actual server definitions live in lua/acurite/lsp/.
return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonLog" },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    config = function()
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
    end,
  },
}
