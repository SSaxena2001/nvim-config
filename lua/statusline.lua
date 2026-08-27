-- Statusline, built out of Neovim's own pieces. No plugin.
--
-- `vim.o.statusline` is a format string (`:h 'statusline'`). Most of what it
-- needs is already a format item -- `%l`, `%c`, `%P` -- and the two parts that
-- need logic are Lua functions reached through `v:lua`. They are wrapped in
-- `%{% %}` rather than `%{ }`: the doubled form re-evaluates whatever comes
-- back as further format items, which is what lets them return their own
-- `%#Group#` colours instead of printing the escape literally.

local M = {}

-- `mode(1)` returns the short code plus the character that separates modes
-- sharing a first letter -- "no" (operator-pending) from "n", CTRL-V from "v".
-- The full table is in `:h mode()`. Second field is the highlight group the
-- colour is taken from, so the statusline follows the colorscheme instead of
-- carrying a palette that has to be kept in sync with it.
local modes = {
  n = { "NORMAL", "Function" },
  no = { "OP-PENDING", "Function" },
  v = { "VISUAL", "Statement" },
  V = { "V-LINE", "Statement" },
  ["\22"] = { "V-BLOCK", "Statement" }, -- CTRL-V
  s = { "SELECT", "Statement" },
  S = { "S-LINE", "Statement" },
  ["\19"] = { "S-BLOCK", "Statement" }, -- CTRL-S
  i = { "INSERT", "String" },
  R = { "REPLACE", "DiagnosticError" },
  c = { "COMMAND", "Constant" },
  r = { "PROMPT", "Constant" },
  ["!"] = { "SHELL", "Constant" },
  t = { "TERMINAL", "Constant" },
}

-- Highlights ---------------------------------------------------------------
--
-- Foreground only, no `bg`. lua/colorscheme.lua runs the scheme transparent,
-- and giving these a background would paint a solid bar back under the
-- statusline that the rest of the editor does not have.

local function fg_of(group)
  -- link = false resolves the chain, so a group defined only as a link to
  -- another still yields a real colour rather than an empty table.
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  return hl and hl.fg or nil
end

local function define_highlights()
  for _, mode in pairs(modes) do
    vim.api.nvim_set_hl(0, "StlMode" .. mode[2], { fg = fg_of(mode[2]), bold = true })
  end

  -- The filename when it matches what is on disk: bold, otherwise the
  -- statusline's own colour.
  vim.api.nvim_set_hl(0, "StlFile", { bold = true })
  -- Unsaved changes. Warn rather than error: nothing is wrong, there is just
  -- something to write.
  vim.api.nvim_set_hl(0, "StlModified", { fg = fg_of("DiagnosticWarn"), bold = true })
  vim.api.nvim_set_hl(0, "StlReadonly", { fg = fg_of("DiagnosticError"), bold = true })
end

define_highlights()
-- A colorscheme change replaces every highlight, including the ones just
-- defined from it, so they have to be rebuilt against the new palette.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("StatuslineHighlights", { clear = true }),
  callback = define_highlights,
})

-- Components ----------------------------------------------------------------

function M.mode()
  local code = vim.fn.mode(1)
  -- Fall back to the first character, then to the raw code: an unlisted mode
  -- renders as itself rather than as nothing.
  local mode = modes[code] or modes[code:sub(1, 1)]
  local label = mode and mode[1] or code:upper()
  local group = "StlMode" .. (mode and mode[2] or "Function")
  return "%#" .. group .. "# " .. label .. " %*"
end

-- Buffers that are not files get a name of their own. The path Neovim gives
-- them is either useless or actively misleading: a help buffer carries the
-- absolute path of a file inside $VIMRUNTIME, and the quickfix list carries a
-- generated `quickfix-5`.
local function special_name()
  local buftype = vim.bo.buftype

  if buftype == "help" then
    -- The tail is the whole of it -- `options.txt`, not the runtime directory
    -- it happens to be installed under.
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  end

  if buftype == "quickfix" then
    -- Both lists share the buftype; only the window knows which one it is.
    local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
    return (info and info.loclist == 1) and "[Location List]" or "[Quickfix]"
  end

  if buftype == "terminal" then
    -- Terminal buffers are `term://<cwd>//<pid>:<command>`; the command is the
    -- half worth showing.
    return vim.api.nvim_buf_get_name(0):match("^term://.*:(.*)$") or "[Terminal]"
  end

  return nil
end

local function buffer_name()
  local special = special_name()
  if special then
    return special
  end

  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return "[No Name]"
  end

  -- oil names its buffers `oil:///path/to/dir`, which is not worth reading as
  -- a URL. Show the directory being edited, shortened the way a file path is.
  local dir = name:match("^oil://(.*)$")
  if dir then
    return vim.fn.fnamemodify(dir, ":~:.")
  end

  -- `:~:.` is relative to :pwd when the file is underneath it, and `~/`-
  -- shortened when it is not, so the common case stays short without the
  -- uncommon one turning into an absolute path.
  return vim.fn.fnamemodify(name, ":~:.")
end

function M.file()
  local name = buffer_name()
  -- A `%` in a filename would otherwise be read as the start of a format item.
  name = name:gsub("%%", "%%%%")

  -- Modified is checked before readonly: a buffer can be both, and unsaved
  -- work is the more urgent of the two things to say.
  if vim.bo.modified then
    -- The dot is the signal; the colour is what makes it register without
    -- having to be read.
    return "%#StlModified#" .. name .. " ●%*"
  end

  -- Only real files can be readonly in a way worth reporting. Help, quickfix
  -- and terminal buffers are all unmodifiable by definition, and a lock on
  -- every one of them says nothing.
  if vim.bo.buftype == "" and (vim.bo.readonly or not vim.bo.modifiable) then
    return "%#StlReadonly#" .. name .. " 󰌾%*"
  end

  return "%#StlFile#" .. name .. "%*"
end

-- Assembly ------------------------------------------------------------------

vim.o.statusline = table.concat({
  "%{%v:lua.require'statusline'.mode()%}",
  -- Where the line gets cut when the window is too narrow for it. Without a
  -- marker Neovim truncates from the left, which eats the mode indicator
  -- before it touches the long path that was the reason it ran out of room.
  "%<",
  " ",
  "%{%v:lua.require'statusline'.file()%}",
  -- Everything after this is pushed to the right edge.
  "%=",
  -- Native items, no Lua needed: line:column, then position in the file as a
  -- percentage or as All/Top/Bot.
  "%l:%c  %P ",
})

-- Neovim redraws the statusline on its own for most events, but a bare mode
-- change is not always one of them -- without this, `%{%...mode()%}` can still
-- read NORMAL after `i` until something else forces a redraw.
vim.api.nvim_create_autocmd("ModeChanged", {
  group = vim.api.nvim_create_augroup("StatuslineRedraw", { clear = true }),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

return M
