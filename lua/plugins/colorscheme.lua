return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = true,
        terminal_colors = true,
        styles = {
          keywords = { italic = true },
          constants = { italic = true, bold = true },
          functions = {},
          comments = { italic = true },
          sidebars = "transparent",
          floats = "transparent",
        },
        lualine_bold = true,
        sidebars = { "qf", "vista_kind", "terminal", "packer", "fzf" },
        on_highlights = function(hl, c)
          hl["DiagnosticVirtualTextError"] = { bg = "none", fg = c.red }
          hl["DiagnosticVirtualTextWarn"] = { bg = "none", fg = c.yellow }
          hl["DiagnosticVirtualTextInfo"] = { bg = "none", fg = c.blue }
          hl["DiagnosticVirtualTextHint"] = { bg = "none", fg = c.cyan500 }
        end,
      }
    end,
  },
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
    opts = function()
      return {
        options = {
          transparency = true,
          terminal_colors = true,
        },
        highlights = {
          ["DiagnosticVirtualTextError"] = { bg = "none", fg = "${red}" },
          ["DiagnosticVirtualTextWarn"] = { bg = "none", fg = "${yellow}" },
          ["DiagnosticVirtualTextInfo"] = { bg = "none", fg = "${blue}" },
          ["DiagnosticVirtualTextHint"] = { bg = "none", fg = "${green}" },
        },
      }
    end,
  },
  {
    "https://gitlab.com/motaz-shokry/gruvbox.nvim",
    name = "gruvbox",
    priority = 1000,
    opts = function()
      return {
        variant = "medium",
        dark_variant = "medium",
        styles = {
          transparency = true,
        },
      }
    end,
  },
}
