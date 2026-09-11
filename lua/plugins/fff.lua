-- fff: fuzzy file and content search over a Rust core.
--
-- The native layer underneath is untouched, same as with the picker this
-- replaced: `:find` still runs find.lua's findfunc and `:grep` still shells
-- out to ripgrep through grepprg. This is an interactive front end over that,
-- not a replacement for it.
--
-- What it is not is a general picker framework. It does files and content and
-- nothing else, so buffers, help tags, diagnostics and symbols are answered by
-- Neovim itself in lua/picker.lua rather than by a plugin.
require("fff").setup({
  -- fff indexes a tree once and watches it from there, rather than rescanning
  -- per keystroke. So the root is set here, at startup, and not per call --
  -- re-pointing the index is the expensive operation, not the search.
  --
  -- The same root `:find` resolves, rather than fff's own default of `getcwd`,
  -- so `;f` and `:find` agree on what the project is.
  base_path = require("find").project_root(),

  -- Frecency ranking needs somewhere to keep its counts. Under `state`, not
  -- the default `cache`: cache is the first thing cleared by hand, and losing
  -- this costs weeks of ranking rather than a rescan.
  frecency = { db_path = vim.fn.stdpath("state") .. "/fff/frecency" },

  -- Roughly the float geometry the previous picker used, so the window still
  -- lands where the hands expect it.
  layout = { height = 0.85, width = 0.85 },

  -- Blend with the editor rather than reading as a separate panel. The
  -- colorscheme runs transparent (lua/colorscheme.lua) and the default here
  -- maps the picker onto NormalFloat, which would paint a solid background
  -- back under it.
  hl = { normal = "Normal" },
})
