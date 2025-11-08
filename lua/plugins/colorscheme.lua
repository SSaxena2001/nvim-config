function ColorMyPencils(color)
  color = color or "rose-pine-moon"
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

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
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        disable_background = true,
        styles = {
          bold = false,
          italic = false,
          transparency = true,
        },
      })

      vim.cmd("colorscheme rose-pine-moon")

      ColorMyPencils()
    end,
  },
}
