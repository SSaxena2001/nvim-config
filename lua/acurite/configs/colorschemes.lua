require("solarized-osaka").setup({
  transparent = true,
  terminal_colors = true,
  bold = false,
  italic = false,
  styles = {
    keywords = { italic = true },
    constants = { italic = false, bold = true },
    functions = {},
    comments = { italic = false },
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
})

vim.cmd.colorscheme("solarized-osaka")
