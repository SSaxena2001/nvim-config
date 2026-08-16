-- Devicons for netrw. The plugin only decorates the listing; every netrw
-- keybind stays exactly as it was, so the :NetrwHelp table in netrw-help.lua
-- remains accurate.
return {
  "prichrd/netrw.nvim",
  ft = "netrw",
  config = function()
    -- Nerd Font codepoints, spelled numerically so the glyphs survive editors
    -- and tooling that mangle private-use-area characters.
    local nf = {
      folder = 0xf07b, -- nf-fa-folder
      link = 0xf0c1, -- nf-fa-link
      file = 0xf15b, -- nf-fa-file
    }

    -- `mappings` is deliberately left empty. netrw.nvim binds those
    -- buffer-locally on every render, which would silently take precedence
    -- over the buffer-local `?` map that netrw-help.lua installs.
    require("netrw").setup({
      use_devicons = true,
      -- Fallbacks only. mini.icons supplies per-extension glyphs for files;
      -- netrw.nvim never asks it about directories or symlinks.
      icons = {
        symlink = vim.fn.nr2char(nf.link),
        directory = vim.fn.nr2char(nf.folder),
        file = vim.fn.nr2char(nf.file),
      },
    })

    require("acurite.netrw-help")

    -- netrw.nvim hooks `OptionSet modified`, which netrw fires while it writes
    -- the listing. The buffer that triggered this lazy load has already passed
    -- that point, so decorate it by hand. `embelish` keys its extmarks by line
    -- number, so running it again is idempotent.
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "netrw" then
        return
      end

      -- Same liststyle guard the plugin's own autocmd uses.
      local liststyle = vim.b[buf].netrw_liststyle
      if liststyle ~= 0 and liststyle ~= 1 and liststyle ~= 3 then
        return
      end

      vim.opt_local.signcolumn = "yes"
      pcall(require("netrw.ui").embelish, buf)
    end)
  end,
}
