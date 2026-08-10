require("nvim-highlight-colors").setup({
  render = "background",
  enable_hex = true,
  enable_short_hex = true,
  enable_rgb = true,
  enable_hsl = true,
  enable_hsl_without_function = true,
  enable_ansi = true,
  enable_var_usage = true,
  -- Tailwind color scanning is expensive on big projects; leave it to tailwindcss LSP.
  enable_tailwind = false,
})
