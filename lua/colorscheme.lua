-- Solarized Osaka: a Solarized-derived dark scheme built on tokyonight's
-- engine, so it takes tokyonight's `styles`/`on_highlights` shape.
require("solarized-osaka").setup({
  -- "" is the default dark style; "vivid" brightens the text colors for
  -- reading in a bright room.
  style = "",

  -- Let the terminal's own background through.
  transparent = true,

  -- Publish the palette to g:terminal_color_0..15, which is what :terminal
  -- buffers use -- lazygit opens in one.
  terminal_colors = true,

  styles = {
    -- Upright comments and keywords; italics are reserved for markup below.
    comments = {},
    keywords = {},
    -- Floats and sidebar-like windows keep a real background even though the
    -- editor itself is transparent, so they read as separate surfaces.
    floats = "dark",
    sidebars = "dark",
  },
  sidebars = { "qf", "help" },

  ---@param highlights table
  ---@param colors table
  on_highlights = function(highlights, colors)
    highlights["@markup.italic"] = { italic = true }
    -- Make and/or/not stand out more
    highlights["@keyword.operator"] = { link = "@keyword" }
    -- Make markdown links stand out. @markup.link is the current name for
    -- what used to be @text.reference; @text.* was renamed in Neovim 0.10 and
    -- no longer matches anything.
    highlights["@markup.link"] = { link = "@keyword" }
    -- Don't italicize literals (formerly @text.literal)
    highlights["@markup.raw"] = { italic = false }
    highlights["@codeblock"] = { bg = colors.base03 }
    highlights["QuickFixLine"] = { bg = colors.base02 }
  end,
})

vim.cmd.colorscheme("solarized-osaka")
