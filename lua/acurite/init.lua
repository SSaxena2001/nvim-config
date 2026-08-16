require("acurite.set")
require("acurite.remap")
require("acurite.lazy_init")

local group = vim.api.nvim_create_augroup("Acurite", { clear = true })

-- Briefly highlight whatever was just yanked.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight on yank",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Native LSP. No nvim-lspconfig: vim.lsp.config / vim.lsp.enable do this
-- themselves in 0.12. Deferred to the first real file so an empty `nvim`
-- never pays for it.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = group,
  once = true,
  desc = "Configure LSP",
  callback = function(args)
    local buf = args.buf
    require("acurite.lsp")

    -- vim.lsp.enable() installs a FileType hook to start servers, but this
    -- buffer's FileType has already fired by now, so it would sit there with
    -- no client until the next file was opened. Re-fire it for this buffer.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = buf, group = "nvim.lsp.enable" })
      end
    end)
  end,
})

-- netrw. Kept as the file explorer; see lazy/netrw.lua for the icons and
-- lua/acurite/remap.lua for the <leader>e toggle.
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25
