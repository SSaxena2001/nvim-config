-- Diagnostic presentation.
--
-- Gutter signs are Neovim's own letters -- E, W, I and N -- which is what
-- ThePrimeagen's config shows, since it sets no sign text and takes the
-- defaults. Spelled out here rather than left implicit so the gutter and the
-- statusline counts are visibly the same set. Note HINT defaults to N, not H.
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "N",
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
