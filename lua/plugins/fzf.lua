-- fzf-lua, in place of the quickfix pickers this config used to hand-roll.
--
-- The native layer underneath is untouched: `:find` still runs find.lua's
-- findfunc and `:grep` still shells out to ripgrep through grepprg. These
-- pickers are an interactive front end over that, not a replacement for it.
--
-- The file-listing command is left to fzf-lua, which already picks fd over rg
-- over find and defaults to `hidden = true`. alt-h and alt-i toggle hidden and
-- ignored files, and only fzf-lua knows how to rewrite its own command for
-- that -- a hand-built `files.cmd` here is what breaks those toggles.
--
-- Matching happens in the fzf binary and the file/grep providers run in a
-- separate Neovim process, which is why this stays responsive on large trees
-- where an in-process Lua matcher would not.
require("fzf-lua").setup({
  -- Derive the fzf colors from the active colorscheme rather than carrying a
  -- second palette that has to be kept in sync with the colorscheme.
  fzf_colors = true,

  winopts = {
    height = 0.85,
    width = 0.85,
    -- Slightly above centre; a centred float sits low once the preview is up.
    row = 0.4,
    preview = {
      -- Horizontal when the window is wide enough, vertical when it is not.
      layout = "flex",
      scrollbar = false,
    },
  },

  keymap = {
    fzf = {
      -- `true` inherits the defaults; without it this table replaces them.
      true,
      -- What telescope bound ctrl-q to: send the whole result set to the
      -- quickfix list, which quicker.nvim styles and makes editable.
      ["ctrl-q"] = "select-all+accept",
    },
  },
})
