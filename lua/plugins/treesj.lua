-- Split a node across lines or join it back onto one, from the treesitter
-- tree rather than from the text. `J` joins lines and leaves the separators
-- wherever they land; this knows an argument list from a table constructor,
-- so the commas, the trailing comma and the indent all come out right.
require("treesj").setup({
  -- Off, and the one keymap this config wants is in lua/keymaps.lua instead.
  -- The defaults would take <leader>s, which is already Substitute word.
  use_default_keymaps = false,

  -- Refuse to join when the result would be longer than 'textwidth' (or 120
  -- when that is 0), rather than producing a line that the next format-on-save
  -- immediately splits again.
  max_join_length = 120,
})
