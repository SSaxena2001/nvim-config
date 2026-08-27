-- Filetype icons, used by oil's icon column. Every glyph
-- comes from a Nerd Font, so the terminal has to be running one.
require("nvim-web-devicons").setup({
  -- Fall back to a generic glyph rather than nothing for unknown filetypes.
  default = true,
})
