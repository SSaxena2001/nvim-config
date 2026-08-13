local Mason = require("mason")
local MasonToolInstaller = require("mason-tool-installer")
local tools = require("acurite.configs.mason-tools")

Mason.setup({
  firewall = {
    enabled = true,
    auto_managed = true,
  },
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

MasonToolInstaller.setup({
  ensure_installed = tools.ensure_installed,
  -- The cold-start check in core/pack.lua loads this module only when a tool
  -- is absent. Delay registry work until after the first screen is drawn.
  start_delay = 250,
})

-- Native LSP may have seen a missing executable before a clean Mason install
-- completed. Replay its generated FileType autocmds for loaded buffers so the
-- freshly installed servers attach without requiring an editor restart.
vim.api.nvim_create_autocmd("User", {
  pattern = "MasonToolsUpdateCompleted",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
        pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = buf, group = "nvim.lsp.enable" })
      end
    end
  end,
})
