-- Rosé Pine. `variant = "auto"` reads 'background', so it renders as dawn
-- under `:set background=light` and as `dark_variant` otherwise -- no reload
-- and no second colorscheme call to switch.
require("rose-pine").setup({
  variant = "moon",
  dark_variant = "main",
  disable_italics = true,
  styles = {
    -- Let the terminal's own background through instead of painting the
    -- scheme's base over it.
    transparency = true,
    italics = false,
    bold = true,
  },
})

vim.cmd.colorscheme("rose-pine")
