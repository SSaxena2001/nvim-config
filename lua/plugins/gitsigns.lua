-- Diagnostic signs are off (see lua/lsp/diagnostics.lua), so the sign column
-- stays dedicated to git changes.
require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "-" },
    topdelete = { text = "-" },
    changedelete = { text = "~" },
  },
})
