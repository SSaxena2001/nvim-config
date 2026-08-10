require("bufferline").setup({
  options = {
    mode = "tabs",
    show_buffer_close_icons = false,
    show_close_icon = false,
    tab_size = 18,
    max_name_length = 18,
  },
  highlights = {
    fill = {
      bg = "none",
    },
  },
})

-- `rose-pine.palette` reads the resolved variant from `rose-pine.config`, so it
-- must be required after colorschemes.lua has run setup().
local colors = require("rose-pine.palette")
require("incline").setup({
  highlight = {
    groups = {
      InclineNormal = { guibg = colors.foam, guifg = colors.base },
      InclineNormalNC = { guifg = colors.muted, guibg = "NONE" },
    },
  },
  window = { margin = { vertical = 0, horizontal = 1 } },
  hide = {
    cursorline = true,
  },
  render = function(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
    if vim.bo[props.buf].modified then
      filename = "[+] " .. filename
    end

    local icon, color = require("nvim-web-devicons").get_icon_color(filename)
    return { { icon, guifg = color }, { " " }, { filename } }
  end,
})
