require("lualine").setup({
  options = {
    theme = "rose-pine",
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
