require("rose-pine").setup({
  -- Moon, matching the palette this config's Ghostty theme has always used.
  -- "main" is darker, "dawn" is the light variant.
  variant = "moon",
  dark_variant = "moon",

  enable = {
    -- Publish the palette to g:terminal_color_0..15, which is what :terminal
    -- buffers use -- lazygit opens in one.
    terminal = true,
  },

  styles = {
    -- Let the terminal's own background through.
    transparency = true,
  },

  highlight_groups = {
    ["@markup.italic"] = { italic = true },
    -- Make and/or/not stand out more
    ["@keyword.operator"] = { link = "@keyword" },
    -- Make markdown links stand out. @markup.link is the current name for
    -- what used to be @text.reference; @text.* was renamed in Neovim 0.10 and
    -- no longer matches anything.
    ["@markup.link"] = { link = "@keyword" },
    -- Don't italicize literals (formerly @text.literal)
    ["@markup.raw"] = { italic = false },
    ["@codeblock"] = { bg = "surface" },
    ["QuickFixLine"] = { bg = "highlight_med" },
  },
})

vim.cmd.colorscheme("rose-pine")
