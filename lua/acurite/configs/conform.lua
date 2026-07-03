local js_formatters = { "biome", "prettierd", "prettier", stop_after_first = true }
local prettier_formatters = { "prettierd", "prettier", stop_after_first = true }

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

    -- JS/TS/CSS/JSON: prefer fast Biome when available, then daemonized Prettier, then Prettier.
    javascript = js_formatters,
    javascriptreact = js_formatters,
    typescript = js_formatters,
    typescriptreact = js_formatters,
    json = js_formatters,
    jsonc = js_formatters,
    css = js_formatters,

    -- Python: Ruff is fast and handles fixes, imports, and formatting.
    python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },

    -- Rust
    rust = { "rustfmt", lsp_format = "fallback" },

    -- Prettier ecosystem formats. prettierd is used first for speed.
    html = prettier_formatters,
    svelte = prettier_formatters,
    yaml = prettier_formatters,
    markdown = prettier_formatters,
    ["markdown.mdx"] = prettier_formatters,
    graphql = prettier_formatters,
    liquid = prettier_formatters,

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
