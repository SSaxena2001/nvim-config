-- Devicons for netrw. The plugin only decorates the listing; every netrw
-- keybind stays exactly as it was, so the :NetrwHelp table in netrw-help.lua
-- remains accurate.
--
-- `mappings` is deliberately left empty. netrw.nvim binds those buffer-locally
-- on every render, which would silently take precedence over the buffer-local
-- `?` map that netrw-help.lua installs.
-- Nerd Font codepoints, spelled numerically so the glyphs survive editors and
-- tooling that mangle private-use-area characters.
local nf = {
  folder = 0xf07b, -- nf-fa-folder
  link = 0xf0c1, -- nf-fa-link
  file = 0xf15b, -- nf-fa-file
}

require("netrw").setup({
  use_devicons = true,
  -- Fallbacks only. mini.icons (bundled in mini.nvim) supplies per-extension
  -- glyphs for files; netrw.nvim never asks it about directories or symlinks,
  -- so those two always come from here.
  icons = {
    symlink = vim.fn.nr2char(nf.link),
    directory = vim.fn.nr2char(nf.folder),
    file = vim.fn.nr2char(nf.file),
  },
})

local M = {}

--- Decorate a netrw buffer that rendered before setup() ran.
---
--- netrw.nvim hooks `OptionSet modified`, which netrw fires while it writes the
--- listing. The buffer that triggered the lazy load has already passed that
--- point, so it would stay bare until the next refresh. `embelish` keys its
--- extmarks by line number (`opts.id = i`), so running it again is idempotent.
function M.decorate_current()
  local buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "netrw" then
    return
  end

  -- Same liststyle guard the plugin's own autocmd uses: only the listing modes
  -- it knows how to parse get icons.
  local liststyle = vim.b[buf].netrw_liststyle
  if liststyle ~= 0 and liststyle ~= 1 and liststyle ~= 3 then
    return
  end

  vim.opt_local.signcolumn = "yes"
  pcall(require("netrw.ui").embelish, buf)
end

return M
