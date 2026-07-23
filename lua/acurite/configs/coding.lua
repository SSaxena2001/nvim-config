require("cloak").setup({
  enabled = true,
  cloak_character = "*",
  highlight_group = "Comment",
  patterns = {
    {
      file_pattern = {
        ".env*",
        "wrangler.toml",
        ".dev.vars",
      },
      cloak_pattern = "=.+",
    },
  },
})

require("nvim-highlight-colors").setup({
  render = "background",
  enable_hex = true,
  enable_short_hex = true,
  enable_rgb = true,
  enable_hsl = true,
  enable_hsl_without_function = true,
  enable_ansi = true,
  enable_var_usage = true,
  -- Tailwind color scanning is expensive on big projects; leave it to tailwindcss LSP.
  enable_tailwind = false,
})

require("leetcode").setup({
  lang = "python3",
})

-- leetcode.nvim initially creates a minimal :Leet command and replaces it with
-- the full command/completion table after entering its UI. Register the full
-- command immediately too, so command-line completion works for subcommands like
-- `:Leet lang`, `:Leet list`, etc. before opening LeetCode.
require("leetcode.command").setup()

require("supermaven-nvim").setup({
  keymaps = {
    accept_suggestion = "<C-l>",
    clear_suggestion = "<C-]>",
  },
  color = {
    suggestion_color = "#ffffff",
    cterm = 244,
  },
})

vim.keymap.set("n", "<leader>u", "<cmd>Atone toggle<CR>", { desc = "Toggle Atone" })
