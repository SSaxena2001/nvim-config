-- Prettier is the default formatter for everything in its ecosystem.
-- prettierd is the same formatter behind a daemon, so it is tried first for
-- speed and falls back to plain prettier when the daemon is unavailable.
local prettier = { "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
  notify_on_error = true,
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    -- C/C++: clang-format is the common fast formatter used with clangd.
    c = { "clang-format" },
    cpp = { "clang-format" },
    objc = { "clang-format" },
    objcpp = { "clang-format" },
    cuda = { "clang-format" },

    -- Lua
    lua = { "stylua" },

    -- Go: goimports includes gofmt and import organization.
    go = { "goimports" },
    gomod = { "gofmt" },
    gowork = { "gofmt" },

    -- JS/TS/CSS/JSON
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    json5 = prettier,
    css = prettier,
    scss = prettier,
    less = prettier,
    vue = prettier,
    -- astro is intentionally absent: core prettier has no .astro parser
    -- (that needs prettier-plugin-astro), so format_on_save's
    -- `lsp_format = "fallback"` hands it to astro-language-server instead.

    -- Python: Ruff is fast and handles fixes, imports, and formatting.
    python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },

    -- Rust
    rust = { "rustfmt", lsp_format = "fallback" },

    html = prettier,
    svelte = prettier,
    yaml = prettier,
    markdown = prettier,
    ["markdown.mdx"] = prettier,
    graphql = prettier,
    liquid = prettier,
    handlebars = prettier,

    -- Shell
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },

    elixir = { "mix" },
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
