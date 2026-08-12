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
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  -- Upstream requires nvim-treesitter itself to stay eager. Parser startup is
  -- still deferred until FileType below, which is the expensive part.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

-- LSP executables are installed here, but Mason's UI and registry do not need
-- to be initialized during every editor startup.
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- Installed and tracked in the lockfile, but kept off the runtimepath until a
-- trigger below wakes them; see core/lazy.lua.
local deferred = {
  ["trouble.nvim"] = "https://github.com/folke/trouble.nvim",
  ["zen-mode.nvim"] = "https://github.com/folke/zen-mode.nvim",
  ["cloak.nvim"] = "https://github.com/laytan/cloak.nvim",
  ["atone.nvim"] = "https://github.com/XXiaoA/atone.nvim",
  ["leetcode.nvim"] = "https://github.com/kawre/leetcode.nvim",
  ["nui.nvim"] = "https://github.com/MunifTanjim/nui.nvim",
  ["render-markdown.nvim"] = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  ["mason.nvim"] = "https://github.com/mason-org/mason.nvim",
  ["mason-tool-installer.nvim"] = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  ["gitsigns.nvim"] = "https://github.com/lewis6991/gitsigns.nvim",
  ["diffview.nvim"] = "https://github.com/sindrets/diffview.nvim",
  ["nvim-treesitter-context"] = "https://github.com/nvim-treesitter/nvim-treesitter-context",
  ["nvim-treesitter-textobjects"] = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  ["nvim-ts-autotag"] = "https://github.com/windwp/nvim-ts-autotag",
}

local deferred_specs = vim.tbl_values(deferred)
vim.pack.add(deferred_specs, { load = false })
lazy.defer(vim.tbl_keys(deferred))

require("acurite.configs.colorschemes")
require("acurite.configs.ui")
require("acurite.configs.mini")
require("acurite.configs.lsp.diagnostics")
require("acurite.configs.conform")
require("acurite.configs.lint")
require("acurite.configs.lualine")
require("acurite.configs.snacks")

-- Command-triggered
lazy.on_command("Trouble", "trouble.nvim", "acurite.configs.trouble")
lazy.on_command("ZenMode", "zen-mode.nvim", "acurite.configs.zen-mode")
lazy.on_command("Atone", "atone.nvim", "acurite.configs.atone")
lazy.on_command("Leet", { "nui.nvim", "leetcode.nvim" }, "acurite.configs.leetcode")
lazy.on_commands(
  { "Mason", "MasonInstall", "MasonUninstall", "MasonToolsInstall", "MasonToolsUpdate" },
  { "mason.nvim", "mason-tool-installer.nvim" },
  "acurite.configs.mason"
)
lazy.on_commands(
  { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  "diffview.nvim",
  "acurite.configs.diffview"
)

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

lazy.on_event("BufReadPre", "gitsigns.nvim", "acurite.configs.gitsigns", {
  pattern = "*",
})

lazy.on_event(
  "FileType",
  { "nvim-treesitter-context", "nvim-treesitter-textobjects", "nvim-ts-autotag" },
  "acurite.configs.treesitter",
  { pattern = "*", defer = true }
)

local lsp_filetypes = {
  "astro",
  "c",
  "cpp",
  "css",
  "cuda",
  "go",
  "gomod",
  "gotmpl",
  "gowork",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "lua",
  "markdown",
  "markdown.mdx",
  "objc",
  "objcpp",
  "python",
  "sass",
  "scss",
  "svelte",
  "typescript",
  "typescriptreact",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = lsp_filetypes,
  once = true,
  desc = "Configure LSP after the first development buffer is drawn",
  callback = function(args)
    local buf = args.buf
    vim.schedule(function()
      require("acurite.configs.lsp")
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf, group = "nvim.lsp.enable" })
      end
    end)
  end,
})
