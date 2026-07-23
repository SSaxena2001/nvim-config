vim.pack.add({
  "https://github.com/craftzdog/solarized-osaka.nvim",
  "https://github.com/folke/trouble.nvim",
  "https://github.com/folke/zen-mode.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/akinsho/bufferline.nvim",
  "https://github.com/b0o/incline.nvim",
  "https://github.com/laytan/cloak.nvim",
  "https://github.com/brenoprata10/nvim-highlight-colors",
  "https://github.com/XXiaoA/atone.nvim",
  "https://github.com/kawre/leetcode.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/supermaven-inc/supermaven-nvim",

  { src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/hrsh7th/vim-vsnip",
  "https://codeberg.org/FelipeLema/blink-cmp-vsnip",

  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
})

require("acurite.configs.colorschemes")
require("acurite.configs.ui")
require("acurite.configs.coding")
require("acurite.configs.mini")
require("acurite.configs.blink-cmp")
require("acurite.configs.mason")
require("acurite.configs.lsp-config")
require("acurite.configs.treesitter")
require("acurite.configs.markdown")
require("acurite.configs.conform")
require("acurite.configs.lint")
require("acurite.configs.lualine")
require("acurite.configs.snacks")
