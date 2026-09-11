-- Solarized Osaka. `use_background` reads 'background', so `light_style`
-- renders under `:set background=light` and `style` otherwise -- no reload and
-- no second colorscheme call to switch.
require("solarized-osaka").setup({
  -- "" is the default dark style; "vivid" is the higher-contrast variant that
  -- stays readable in a bright room.
  style = "vivid",
  vivid_brightness = 0.1,
  light_style = "light",
  transparent = true,
  terminal_colors = true,
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
    functions = {},
    variables = {},
    -- Floats and sidebars inherit the transparent background too, rather than
    -- the darker panel this scheme paints by default.
    sidebars = "transparent",
    floats = "transparent",
  },
})

vim.cmd.colorscheme("solarized-osaka")
