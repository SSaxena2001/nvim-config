-- Git diff markers in the sign column. LSP diagnostic signs are disabled (see
-- configs/lsp/diagnostics.lua), so the gutter remains dedicated to Git changes.
require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "-" },
    topdelete = { text = "-" },
    changedelete = { text = "~" },
  },
})
