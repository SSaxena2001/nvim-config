-- Auto-close brackets, quotes and tags.
--
-- check_ts uses the syntax tree to decide, so a quote typed inside a string or
-- a comment is left alone rather than being doubled.
require("nvim-autopairs").setup({
  check_ts = true,
  ts_config = {
    -- Node types where a pair should NOT be added, per language.
    lua = { "string" },
    javascript = { "template_string" },
  },

  -- oil buffers are a directory listing being edited as text; pairing there
  -- gets in the way of renaming files with brackets in their names.
  disable_filetype = { "oil" },

  -- <M-e> wraps the next word in the pair just typed.
  fast_wrap = {},
})
