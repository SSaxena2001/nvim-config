-- Diagnostic presentation.
--
-- The gutter glyphs are the same codicons the statusline counts with, so a
-- severity looks the same wherever it appears. signcolumn is "yes:2" (see
-- lua/options.lua) so these and gitsigns' hunk markers each get a column
-- instead of the higher-priority one hiding the other.
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
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
