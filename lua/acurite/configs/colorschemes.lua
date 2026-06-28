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

    hl["Keyword"] = { fg = c.magenta500, italic = true }
    hl["Statement"] = { italic = true }
    hl["Conditional"] = { italic = true }
    hl["Repeat"] = { italic = true }
    hl["Exception"] = { italic = true }
    hl["@keyword"] = { italic = true }
    hl["@keyword.conditional"] = { italic = true }
    hl["@keyword.repeat"] = { italic = true }
    hl["@keyword.return"] = { italic = true }
    hl["@keyword.exception"] = { italic = true }
    hl["@keyword.import"] = { italic = true }

    hl["Type"] = { fg = c.yellow500, underline = true }
    hl["Typedef"] = { fg = c.yellow500, underline = true }
    hl["@type"] = { fg = c.yellow500, underline = true }
    hl["@type.builtin"] = { fg = c.yellow500, underline = true }
    hl["@type.definition"] = { fg = c.yellow500, underline = true }

    hl["@tag.tsx"] = { fg = c.blue, underline = false }
    hl["@constructor.tsx"] = { fg = c.yellow500, underline = false }
    hl["@type.tsx"] = { fg = c.yellow500, underline = false }
    hl["@type.builtin.tsx"] = { fg = c.yellow500, underline = false }
    hl["@type.definition.tsx"] = { fg = c.yellow500, underline = false }
  end,
})

require("rose-pine").setup({
  variant = "moon",
  dark_variant = "moon",
  extend_background_behind_borders = true,
  enable = {
    terminal = true,
    legacy_highlights = true,
    migrations = true,
  },
  styles = {
    bold = false,
    italic = true,
    transparency = true,
  },
  highlight_groups = {
    DiagnosticVirtualTextError = { bg = "none", fg = "love" },
    DiagnosticVirtualTextWarn = { bg = "none", fg = "gold" },
    DiagnosticVirtualTextInfo = { bg = "none", fg = "foam" },
    DiagnosticVirtualTextHint = { bg = "none", fg = "iris" },

    Keyword = { fg = "pine", italic = true },
    Statement = { italic = true },
    Conditional = { italic = true },
    Repeat = { italic = true },
    Exception = { italic = true },
    ["@keyword"] = { italic = true },
    ["@keyword.conditional"] = { italic = true },
    ["@keyword.repeat"] = { italic = true },
    ["@keyword.return"] = { italic = true },
    ["@keyword.exception"] = { italic = true },
    ["@keyword.import"] = { italic = true },

    Type = { fg = "gold", underline = true },
    Typedef = { fg = "gold", underline = true },
    ["@type"] = { fg = "gold", underline = true },
    ["@type.builtin"] = { fg = "gold", underline = true },
    ["@type.definition"] = { fg = "gold", underline = true },

    ["@tag.tsx"] = { fg = "foam", underline = false },
    ["@constructor.tsx"] = { fg = "gold", underline = false },
    ["@type.tsx"] = { fg = "gold", underline = false },
    ["@type.builtin.tsx"] = { fg = "gold", underline = false },
    ["@type.definition.tsx"] = { fg = "gold", underline = false },
  },
})

vim.cmd.colorscheme("solarized-osaka")
-- To switch back later: vim.cmd.colorscheme("rose-pine")
