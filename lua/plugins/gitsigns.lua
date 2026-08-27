-- Git hunks share the sign column with the diagnostic letters set in
-- lua/lsp.lua, which is why lua/options.lua asks for
-- `signcolumn = "yes:2"` -- one column each, so neither hides the other.
require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "-" },
    topdelete = { text = "-" },
    changedelete = { text = "~" },
  },
})
