-- fzf-lua, in place of the quickfix pickers this config used to hand-roll.
--
-- The native layer underneath is untouched: `:find` still runs find.lua's
-- findfunc and `:grep` still shells out to ripgrep through grepprg. These
-- pickers are an interactive front end over that, not a replacement for it.
--
-- Matching happens in the fzf binary and the file/grep providers run in a
-- separate Neovim process, which is why this stays responsive on large trees
-- where an in-process Lua matcher would not.
local find = require("find")

-- fzf-lua runs `files.cmd` through `sh -c`, so the glob patterns need quoting.
-- The flags must stay bare, though: the alt-h/alt-i toggles rewrite the command
-- by matching a flag preceded by whitespace, and a quoted `'--hidden'` never
-- matches -- which turns those keys into silent no-ops.
local function shell_cmd(args)
  local out = vim.tbl_map(function(arg)
    return arg:match("^[%w%-%.=/]+$") and arg or vim.fn.shellescape(arg)
  end, args)
  -- Lets fzf-lua take its no-ANSI fast path when it parses the output.
  out[#out + 1] = "--color=never"
  return table.concat(out, " ")
end

require("fzf-lua").setup({
  -- Derive the fzf colors from the active colorscheme rather than carrying a
  -- second palette that has to be kept in sync with rose-pine.
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

  files = {
    -- Reuse the ripgrep invocation find.lua's findfunc already builds, so `;f`
    -- and `:find` list the same files: hidden ones included, .gitignore obeyed
    -- outside git repos, build output excluded.
    cmd = shell_cmd(find.rg_command()),
  },
})
