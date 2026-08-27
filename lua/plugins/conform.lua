-- Formatter dispatch. Replaces the BufWritePre autocmd that used to pipe the
-- buffer through a shell command: conform handles ranges, LSP fallback and
-- per-formatter arguments, and mason already installs every binary named here.

-- prettierd is prettier behind a daemon, so it is tried first for speed and
-- falls back to plain prettier when the daemon is unavailable.
local prettier = { "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
  notify_on_error = false,
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

    -- gofmt, not goimports. goimports is gofmt plus import management -- it
    -- adds missing imports and drops unused ones on save -- so this is the
    -- narrower of the two by choice.
    go = { "gofmt" },
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
    -- astro is intentionally absent: core prettier has no .astro parser, so
    -- lsp_format = "fallback" hands it to astro-language-server.

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

vim.keymap.set("n", "<leader>bf", function()
  require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer" })
