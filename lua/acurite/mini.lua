-- mini.nvim modules. Notifications use mini's own defaults; the previous ~80
-- lines of highlight wiring, level icons and per-level durations were doing
-- nothing the defaults do not.
local notify = require("mini.notify")

notify.setup({
  lsp_progress = {
    -- Pyright emits very chatty progress updates while typing, often repeated
    -- "100%" messages. Ordinary notifications stay useful without them.
    enable = false,
  },
  window = {
    config = { border = "single" },
  },
})

vim.notify = notify.make_notify()

require("mini.pairs").setup()

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color({ style = "full" }),
  },
})
