return {
  {
    "saghen/blink.cmp",
    dependencies = { "hrsh7th/vim-vsnip", "https://codeberg.org/FelipeLema/bink-cmp-vsnip.git" },
    opts = {
      snippets = {
        preset = "vsnip",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        ghost_text = { enabled = true },
        menu = {
          winblend = vim.o.pumblend,
          draw = { treesitter = { "lsp" } },
        },
        list = { selection = { auto_insert = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      signature = {
        enabled = true,
        window = {
          winblend = vim.o.pumblend,
        },
      },
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },
    },
  },

  {
    "nvim-mini/mini.snippets",
    enabled = false,
  },
}
