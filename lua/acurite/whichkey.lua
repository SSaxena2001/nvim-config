local wk = require("which-key")

wk.setup({
  preset = "helix",

  -- Long enough that deliberate chords (ss, sv, ;f) do not flash the popup,
  -- short enough to be useful when hesitating.
  delay = 350,

  icons = {
    mappings = false,
    separator = "→",
  },

  win = {
    border = "rounded",
  },

  spec = {
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>h", group = "harpoon" },
    { "<leader>l", group = "lsp" },
    { "<leader>b", group = "buffer" },
    { "s", group = "split / explorer" },
    { ";", group = "picker" },

    -- These are operators, not prefixes. Without this which-key waits on them
    -- as if more keys were coming.
    { "<leader>c", desc = "Change into blackhole", mode = { "n", "v" } },
    { "<leader>d", desc = "Delete into blackhole", mode = { "n", "v" } },
    { "<leader>p", desc = "Paste from yank register" },
    { "<leader>e", desc = "File explorer" },
  },
})
