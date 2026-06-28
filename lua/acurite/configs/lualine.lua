require("lualine").setup({
  options = {
    theme = "solarized-osaka",
  },
  sections = {
    lualine_c = {
      {
        "filename",
        path = 1,
        symbols = {
          modified = "",
          readonly = " 󰌾 ",
          unnamed = "[No Name]",
          newfile = "[New]",
        },
      },
    },
  },
})
