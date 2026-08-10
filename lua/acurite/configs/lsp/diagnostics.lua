-- Diagnostic presentation. No glyphs anywhere: severity is conveyed by
-- highlight colour, the underline, and the message text itself.
vim.diagnostic.config({
  -- No gutter signs; the sign column is reserved for git diff markers.
  signs = false,
  float = {
    border = "rounded",
    style = "minimal",
    focusable = false,
    source = true,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "",
  },
})
