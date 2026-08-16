return {
  "craftzdog/solarized-osaka.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("solarized-osaka").setup({
      style = "vivid",
      vivid_brightness = 0.2,
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = false },
        keywords = { italic = false, bold = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "vista_kind", "terminal", "packer", "floats" },
      hide_inactive_statusline = false,
      dim_inactive = false,
      on_highlights = function(hl, c)
        hl.TelescopeNormal = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopePromptNormal = {
          bg = c.bg_dark,
        }
        hl.TelescopePromptBorder = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopePromptTitle = {
          bg = c.bg_dark,
          fg = c.fg_dark,
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
  end,
}
