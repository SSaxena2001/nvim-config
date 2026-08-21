require("nightfox").setup({
  options = {
    -- Let the terminal's own background show through.
    transparent = true,
    -- Publish the palette to g:terminal_color_0..15, so :terminal buffers and
    -- lazygit use the same colours as everything else.
    terminal_colors = true,
  },
  groups = {
    all = {
      ["@markup.italic"] = { style = "italic" },
      -- Make and/or/not stand out more
      ["@keyword.operator"] = { link = "@keyword" },
      -- Make markdown links stand out
      ["@text.reference"] = { link = "@keyword" },
      ["@text.literal"] = { style = "" }, -- Don't italicize
      ["@codeblock"] = { bg = "palette.bg0" },
      ["QuickFixLine"] = { bg = "palette.sel1" },
    },
  },
})

vim.cmd.colorscheme("nightfox")
