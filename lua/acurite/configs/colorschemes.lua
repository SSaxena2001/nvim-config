local transparent = true

require("solarized-osaka").setup({
  style = "vivid",
  vivid_brightness = 0.2,
  transparent = transparent,
  terminal_colors = true,
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
    functions = {},
    variables = {},
    -- "transparent" here rather than "dark": with a transparent background the
    -- dark sidebar/float panels are the one thing that still paints over the
    -- terminal, which defeats the point.
    sidebars = transparent and "transparent" or "dark",
    floats = transparent and "transparent" or "dark",
  },
  sidebars = { "qf", "help", "floats" },
  hide_inactive_statusline = false,
  dim_inactive = false,
  on_highlights = function(hl, c)
    local prompt = "#2d3149"
    hl.TelescopeNormal = {
      bg = c.bg_dark,
      fg = c.fg_dark,
    }
    hl.TelescopeBorder = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
    hl.TelescopePromptNormal = {
      bg = prompt,
    }
    hl.TelescopePromptBorder = {
      bg = prompt,
      fg = prompt,
    }
    hl.TelescopePromptTitle = {
      bg = prompt,
      fg = prompt,
    }
    hl.TelescopePreviewTitle = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
    hl.TelescopeResultsTitle = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
  end,
})

vim.cmd.colorscheme("solarized-osaka")
