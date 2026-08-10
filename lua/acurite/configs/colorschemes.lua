require("rose-pine").setup({
  variant = "main",
  dark_variant = "main",

  -- Keep the terminal background visible, matching the previous setup. This
  -- also covers floats and sidebars, which rose-pine handles through the same
  -- transparency flag rather than per-area options.
  styles = {
    transparency = true,
    bold = false,
    italic = false,
  },

  extend_background_behind_borders = true,

  enable = {
    terminal = true,
    legacy_highlights = true,
    migrations = true,
  },

  -- rose-pine has no per-token `styles` table, so the italic/bold choices that
  -- used to live there are expressed as highlight overrides. Groups are merged
  -- with the defaults unless `inherit = false` is set.
  highlight_groups = {
    Keyword = { italic = true },
    ["@keyword"] = { italic = true },
    Constant = { italic = false, bold = true },
    ["@constant"] = { italic = false, bold = true },
    Comment = { italic = false },
    ["@comment"] = { italic = false },

    DiagnosticVirtualTextError = { bg = "none", fg = "love" },
    DiagnosticVirtualTextWarn = { bg = "none", fg = "gold" },
    DiagnosticVirtualTextInfo = { bg = "none", fg = "foam" },
    DiagnosticVirtualTextHint = { bg = "none", fg = "iris" },
  },
})

vim.cmd.colorscheme("rose-pine")
