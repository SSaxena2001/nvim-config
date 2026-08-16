return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>bf",
        function()
          require("conform").format({ bufnr = 0 })
        end,
        desc = "Format buffer",
      },
    },
    config = function()
      -- prettierd is prettier behind a daemon, so it is tried first for speed
      -- and falls back to plain prettier when the daemon is unavailable.
      local prettier = { "prettierd", "prettier", stop_after_first = true }

      require("conform").setup({
        notify_on_error = true,
        format_on_save = {
          timeout_ms = 1000,
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          c = { "clang-format" },
          cpp = { "clang-format" },
          objc = { "clang-format" },
          objcpp = { "clang-format" },
          cuda = { "clang-format" },

          lua = { "stylua" },

          go = { "goimports" },
          gomod = { "gofmt" },
          gowork = { "gofmt" },

          javascript = prettier,
          javascriptreact = prettier,
          typescript = prettier,
          typescriptreact = prettier,
          json = prettier,
          jsonc = prettier,
          css = prettier,
          scss = prettier,
          less = prettier,
          html = prettier,
          svelte = prettier,
          vue = prettier,
          yaml = prettier,
          markdown = prettier,
          ["markdown.mdx"] = prettier,
          graphql = prettier,
          -- astro is intentionally absent: core prettier has no .astro parser,
          -- so lsp_format = "fallback" hands it to astro-language-server.

          python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
          rust = { "rustfmt", lsp_format = "fallback" },

          sh = { "shfmt" },
          bash = { "shfmt" },
          zsh = { "shfmt" },
        },
        formatters = {
          ["clang-format"] = {
            prepend_args = { "-style=file", "-fallback-style=LLVM" },
          },
          shfmt = {
            prepend_args = { "-i", "2", "-ci" },
          },
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("acurite.lint")
    end,
  },
  {
    "laytan/cloak.nvim",
    event = "BufReadPre",
    config = function()
      require("cloak").setup({
        enabled = true,
        cloak_character = "*",
        highlight_group = "Comment",
        patterns = {
          {
            file_pattern = { ".env*", "*.env", "wrangler.toml", ".dev.vars" },
            cloak_pattern = "=.+",
          },
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("acurite.whichkey")
    end,
  },
  {
    -- No `version`: mini.nvim's tags are not semver, so a version range makes
    -- lazy.nvim fail the checkout. Track main.
    "nvim-mini/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("acurite.mini")
    end,
  },
}
