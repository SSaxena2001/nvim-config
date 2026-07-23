local notify = require("mini.notify")

local function hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function set_notify_highlights()
  local normal_float = hl("NormalFloat")
  local float_border = hl("FloatBorder")
  local diagnostic_error = hl("DiagnosticError")
  local diagnostic_warn = hl("DiagnosticWarn")
  local diagnostic_info = hl("DiagnosticInfo")
  local diagnostic_hint = hl("DiagnosticHint")

  local bg = normal_float.bg or hl("Normal").bg or "NONE"
  local fg = normal_float.fg or hl("Normal").fg or "NONE"

  vim.api.nvim_set_hl(0, "MiniNotifyNormal", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "MiniNotifyBorder", { fg = float_border.fg or diagnostic_info.fg or fg, bg = bg })
  vim.api.nvim_set_hl(0, "MiniNotifyTitle", { fg = diagnostic_info.fg or fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "MiniNotifyLspProgress", { fg = diagnostic_hint.fg or diagnostic_info.fg or fg, bg = bg })

  vim.api.nvim_set_hl(0, "AcuriteNotifyError", { fg = diagnostic_error.fg or fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "AcuriteNotifyWarn", { fg = diagnostic_warn.fg or fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "AcuriteNotifyInfo", { fg = diagnostic_info.fg or fg, bg = bg })
  vim.api.nvim_set_hl(0, "AcuriteNotifyDebug", { fg = diagnostic_hint.fg or fg, bg = bg })
end

local level_icons = {
  ERROR = "",
  WARN = "",
  INFO = "",
  DEBUG = "",
  TRACE = "✎",
}

notify.setup({
  content = {
    format = function(notif)
      local msg = vim.trim(notif.msg or "")

      if notif.data and notif.data.source == "lsp_progress" then
        local client = notif.data.client_name and (notif.data.client_name .. " ") or ""
        return string.format(" %s%s", client, msg)
      end

      local icon = level_icons[notif.level] or ""
      return string.format("%s %s", icon, msg)
    end,
    sort = function(notif_arr)
      table.sort(notif_arr, function(a, b)
        return a.ts_update > b.ts_update
      end)
      return notif_arr
    end,
  },
  lsp_progress = {
    -- Pyright emits very chatty progress updates while typing (often repeated
    -- "100%" messages). Disable LSP progress popups so normal notifications
    -- remain useful without constant noise in Python buffers.
    enable = false,
    level = "INFO",
    duration_last = 1200,
  },
  window = {
    max_width_share = 0.32,
    winblend = 0,
    config = function()
      local has_statusline = vim.o.laststatus > 0
      local pad = vim.o.cmdheight + (has_statusline and 1 or 0) + 1

      return {
        anchor = "SE",
        row = vim.o.lines - pad,
        col = vim.o.columns - 1,
        border = "single",
      }
    end,
  },
})

set_notify_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_notify_highlights,
})

vim.notify = notify.make_notify({
  ERROR = { duration = 7000, hl_group = "AcuriteNotifyError" },
  WARN = { duration = 5000, hl_group = "AcuriteNotifyWarn" },
  INFO = { duration = 3500, hl_group = "AcuriteNotifyInfo" },
  DEBUG = { duration = 2500, hl_group = "AcuriteNotifyDebug" },
  TRACE = { duration = 2500, hl_group = "AcuriteNotifyDebug" },
  OFF = { duration = 0, hl_group = "MiniNotifyNormal" },
})

require("mini.cmdline").setup({
  autocorrect = { enable = false },
})
require("mini.pairs").setup()
require("mini.surround").setup()
