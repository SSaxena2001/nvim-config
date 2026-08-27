-- Popup listing what a half-typed prefix can still become. It reads the `desc`
-- already on every keymap in this config, so there is nothing to duplicate
-- here beyond naming the prefixes themselves.
local wk = require("which-key")

wk.setup({
  -- The floating variant. "classic" is the bottom-of-screen split.
  preset = "helix",
  -- Neovim's default 1000ms is long enough that the popup feels broken. Safe
  -- to shorten now that nothing here maps a multi-key normal-mode prefix that
  -- is also a complete command on its own.
  delay = 300,
  icons = {
    -- This config does not assume a Nerd Font anywhere else; the mappings read
    -- fine without glyphs.
    mappings = false,
  },
  spec = {
    { "<leader>l", group = "LSP" },
    { ";", group = "Pickers" },
    { "[", group = "Previous" },
    { "]", group = "Next" },
    { "g", group = "Goto" },
  },
})
