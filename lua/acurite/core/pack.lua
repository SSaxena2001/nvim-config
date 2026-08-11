local lazy = require("acurite.core.lazy")

-- Plugins needed to draw the first screen or to service the first keystroke.
vim.pack.add({
  -- The repo is named `neovim`, so name it explicitly to keep `require`able as
  -- "rose-pine".
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  "https://github.com/folke/which-key.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/akinsho/bufferline.nvim",
  "https://github.com/b0o/incline.nvim",

  { src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/hrsh7th/vim-vsnip",

  -- mason prepends its bin directory to PATH. The LSP servers enabled below
  -- are resolved by name, so this cannot be deferred without breaking them.
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",

  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
})

-- Installed and tracked in the lockfile, but kept off the runtimepath until a
-- trigger below wakes them; see core/lazy.lua.
local deferred = {
  ["trouble.nvim"] = "https://github.com/folke/trouble.nvim",
  ["zen-mode.nvim"] = "https://github.com/folke/zen-mode.nvim",
  ["cloak.nvim"] = "https://github.com/laytan/cloak.nvim",
  ["nvim-highlight-colors"] = "https://github.com/brenoprata10/nvim-highlight-colors",
  ["atone.nvim"] = "https://github.com/XXiaoA/atone.nvim",
  ["leetcode.nvim"] = "https://github.com/kawre/leetcode.nvim",
  ["nui.nvim"] = "https://github.com/MunifTanjim/nui.nvim",
  ["render-markdown.nvim"] = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
}

vim.pack.add(vim.tbl_values(deferred), { load = false })
lazy.defer(vim.tbl_keys(deferred))

require("acurite.configs.colorschemes")
require("acurite.configs.ui")
require("acurite.configs.mini")
require("acurite.configs.blink-cmp")
require("acurite.configs.mason")
require("acurite.configs.lsp")
require("acurite.configs.treesitter")
require("acurite.configs.conform")
require("acurite.configs.lint")
require("acurite.configs.lualine")
require("acurite.configs.snacks")

-- Command-triggered
lazy.on_command("Trouble", "trouble.nvim", "acurite.configs.trouble")
lazy.on_command("ZenMode", "zen-mode.nvim", "acurite.configs.zen-mode")
lazy.on_command("Atone", "atone.nvim", "acurite.configs.atone")
lazy.on_command("Leet", { "nui.nvim", "leetcode.nvim" }, "acurite.configs.leetcode")

-- Event-triggered
lazy.on_event("FileType", "render-markdown.nvim", "acurite.configs.markdown", {
  pattern = "markdown",
})

lazy.on_event("BufReadPre", "cloak.nvim", "acurite.configs.cloak", {
  pattern = { ".env*", "*.env", "wrangler.toml", ".dev.vars" },
  after = function()
    -- cloak installs its own autocmds at setup time, so the buffer that
    -- triggered this load has already missed them.
    pcall(vim.cmd.CloakEnable)
  end,
})

lazy.on_event("FileType", "nvim-highlight-colors", "acurite.configs.highlight-colors", {
  pattern = {
    "css",
    "scss",
    "sass",
    "less",
    "html",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "svelte",
    "astro",
    "vue",
    "lua",
  },
})
