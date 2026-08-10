require("leetcode").setup({
  lang = "python3",
})

-- leetcode.nvim initially creates a minimal :Leet command and replaces it with
-- the full command/completion table after entering its UI. Register the full
-- command immediately too, so command-line completion works for subcommands like
-- `:Leet lang`, `:Leet list`, etc. before opening LeetCode.
require("leetcode.command").setup()
