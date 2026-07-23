require("blink.cmp").setup({
  fuzzy = {
    implementation = "prefer_rust",
  },
  snippets = {
    preset = "vsnip",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      vsnip = {
        name = "vsnip",
        module = "blink-cmp-vsnip",
        opts = {},
      },
      lsp = {
        opts = {
          tailwind_color_icon = "󱓻",
        },
      },
      buffer = {
        opts = {
          get_bufnrs = function()
            return { vim.api.nvim_get_current_buf() }
          end,
        },
      },
    },
  },
  completion = {
    ghost_text = { enabled = true },
    menu = {
      winblend = vim.o.pumblend,
      border = "single",
      auto_show = true,
    },
    list = { selection = { preselect = false, auto_insert = false } },
    documentation = {
      auto_show = false,
      auto_show_delay_ms = 300,
      window = {
        border = "single",
      },
    },
  },
  signature = {
    enabled = true,
    window = {
      winblend = vim.o.pumblend,
      border = "single",
    },
  },
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
  cmdline = {
    enabled = true,
    -- The cmdline preset keeps command-line completion close to Vim defaults:
    -- <Tab> opens/inserts completion and cycles, <S-Tab> cycles backwards.
    keymap = { preset = "cmdline" },
    sources = { default = { "cmdline", "buffer" } },
    completion = {
      menu = {
        -- Do not pop up while typing; press <Tab> to request suggestions.
        auto_show = false,
      },
      ghost_text = { enabled = true },
    },
  },
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },
})
