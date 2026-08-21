-- oh-my-monokai is the Neovim answer to the Monokai Vibrant VS Code theme,
-- which it credits as its inspiration; monokai-vibrant itself has no Neovim
-- port. Built on monokai-pro.nvim's structure.
require("oh-my-monokai").setup({
  -- Let the terminal's own background through.
  transparent_background = true,

  -- Publish the palette to g:terminal_color_0..15, which is what :terminal
  -- buffers use -- lazygit opens in one.
  terminal_colors = true,

  palette = "default",

  -- Keep these panels opaque so they stay readable over a transparent buffer.
  background_clear = {},

  ---@param c Colorscheme
  override = function(c)
    return {
      ["@markup.italic"] = { italic = true },
      -- Make and/or/not stand out more
      ["@keyword.operator"] = { link = "@keyword" },
      -- Make markdown links stand out. @markup.link is the current name for
      -- what used to be @text.reference; @text.* was renamed in Neovim 0.10
      -- and no longer matches anything.
      ["@markup.link"] = { link = "@keyword" },
      -- Don't italicize literals (formerly @text.literal)
      ["@markup.raw"] = { italic = false },
      ["@codeblock"] = { bg = c.base.dark1 },
      ["QuickFixLine"] = { bg = c.base.dimmed5 },
    }
  end,
})

vim.cmd.colorscheme("oh-my-monokai")
