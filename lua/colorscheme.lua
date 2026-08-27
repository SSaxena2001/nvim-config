-- Solarized Osaka: a Solarized-derived dark scheme built on tokyonight's
-- engine, so it takes tokyonight's `styles`/`on_highlights` shape.
require("solarized-osaka").setup({
  style = "",
  transparent = true,
  terminal_colors = true,

  styles = {
    comments = {},
    keywords = {},
    functions = {},
    floats = "transparent",
    sidebars = "transparent",
  },
  sidebars = { "qf", "help" },
})

vim.cmd.colorscheme("solarized-osaka")
