-- `[`/`]` motions, one suffix per target: `[b`/`]b` walks buffers, `[u`/`]u`
-- walks undo states, `[i`/`]i` walks indent levels, and so on. Each pair also
-- takes a count and has `[B`/`]B` first/last variants.
--
-- No lazy-loading hook here the way a plugin-manager spec would carry: setup()
-- only creates keymaps, so there is nothing to defer.
require("mini.bracketed").setup({
  -- Targets switched off, each because something in this config already owns
  -- the suffix or does the job better:
  --   comment      -- [c/]c is the builtin diff-change motion, which fugitive's
  --                   :Gdiffsplit and every merge conflict depend on.
  --   file, window -- oil and <C-w> cover these.
  --   quickfix     -- lua/keymaps.lua maps [q/]q to cprev/cnext already.
  --   yank         -- the register maps in lua/keymaps.lua are the interface.
  comment = { suffix = "" },
  file = { suffix = "" },
  window = { suffix = "" },
  quickfix = { suffix = "" },
  yank = { suffix = "" },

  -- Treesitter nodes moved off the default `t` onto `n`, leaving `[t`/`]t` to
  -- Neovim's own tag stack.
  treesitter = { suffix = "n" },
})
