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
  sidebars = { "qf", "help", "terminal", "floats" },
  hide_inactive_statusline = false,
  dim_inactive = false,
})

vim.cmd.colorscheme("solarized-osaka")
