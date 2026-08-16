-- Plugins with no configuration of their own. Everything else lives in its
-- own file in this directory; lazy.nvim imports them all.
return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
