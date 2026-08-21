require("monokai-nightasty").setup({
  -- Let the terminal's own background through. The plugin has no "vibrant"
  -- variant -- only dark/light plus this background setting.
  dark_style_background = "transparent",

  hl_styles = {
    -- Keep floats and sidebars opaque so oil's float and the completion popup
    -- stay readable over a transparent buffer.
    floats = "dark",
    sidebars = "dark",
  },

  -- Publish the palette to g:terminal_color_0..15, which is what :terminal
  -- buffers use -- lazygit opens in one.
  terminal_colors = true,

  on_highlights = function(hl, c)
    hl["@markup.italic"] = { italic = true }
    -- Make and/or/not stand out more
    hl["@keyword.operator"] = { link = "@keyword" }
    -- Make markdown links stand out. @markup.link is the current name for what
    -- used to be @text.reference; @text.* was renamed in Neovim 0.10 and no
    -- longer matches anything.
    hl["@markup.link"] = { link = "@keyword" }
    -- Don't italicize literals (formerly @text.literal)
    hl["@markup.raw"] = { italic = false }
    hl["@codeblock"] = { bg = c.bg_dark }
    hl["QuickFixLine"] = { bg = c.grey_dark }
  end,
})

vim.cmd.colorscheme("monokai-nightasty")
