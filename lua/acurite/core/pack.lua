local lazy = require("acurite.core.lazy")

local function build_fzf_native(path)
  if vim.fn.executable("make") == 0 then
    vim.notify("make is required to compile telescope-fzf-native", vim.log.levels.WARN)
    return
  end

  vim.system({ "make" }, { cwd = path }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("Failed to compile telescope-fzf-native", vim.log.levels.WARN)
      end)
    end
  end)
end

-- Build the native sorter whenever vim.pack installs or updates its source.
-- This must be registered before the first vim.pack.add() call so clean
-- installations are covered as well.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(args)
    local data = args.data
    if data and data.spec.name == "telescope-fzf-native.nvim" and (data.kind == "install" or data.kind == "update") then
      build_fzf_native(data.path)
    end
  end,
})

-- Plugins needed to draw the first screen or to service the first keystroke.
vim.pack.add({
  "https://github.com/craftzdog/solarized-osaka.nvim",
  "https://github.com/folke/which-key.nvim",

  { src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lua/plenary.nvim",
  -- Upstream requires nvim-treesitter itself to stay eager. Parser startup is
  -- still deferred until FileType below, which is the expensive part.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/L3MON4D3/LuaSnip",
})

-- LSP executables are installed here, but Mason's UI and registry do not need
-- to be initialized during every editor startup.
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- Installed and tracked in the lockfile, but kept off the runtimepath until a
-- trigger below wakes them; see core/lazy.lua.
local deferred = {
  ["cloak.nvim"] = "https://github.com/laytan/cloak.nvim",
  ["netrw.nvim"] = "https://github.com/prichrd/netrw.nvim",
  ["mason.nvim"] = "https://github.com/mason-org/mason.nvim",
  ["mason-tool-installer.nvim"] = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  ["gitsigns.nvim"] = "https://github.com/lewis6991/gitsigns.nvim",
  ["diffview.nvim"] = "https://github.com/sindrets/diffview.nvim",
  ["telescope.nvim"] = "https://github.com/nvim-telescope/telescope.nvim",
  ["telescope-fzf-native.nvim"] = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  ["telescope-ui-select.nvim"] = "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  ["harpoon"] = { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  ["nvim-treesitter-textobjects"] = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
}

local deferred_specs = vim.tbl_values(deferred)
vim.pack.add(deferred_specs, { load = false })
lazy.defer(vim.tbl_keys(deferred))

-- vim.pack intentionally has no build hook. Compile the native Telescope
-- sorter only when its shared library is absent; the normal startup path is a
-- single fs check and never starts make.
local fzf_native_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/telescope-fzf-native.nvim"
if vim.uv.fs_stat(fzf_native_path) and vim.fn.glob(fzf_native_path .. "/build/libfzf.*") == "" then
  build_fzf_native(fzf_native_path)
end

require("acurite.configs.colorschemes")
require("acurite.configs.mini")
require("acurite.configs.lsp.completion")
require("acurite.configs.conform")
require("acurite.configs.lint")
require("acurite.configs.command-input")
require("acurite.configs.netrw-help")

-- Command-triggered
lazy.on_command("Telescope", require("acurite.core.telescope").plugins, "acurite.configs.telescope")
lazy.on_commands(
  { "Mason", "MasonInstall", "MasonUninstall", "MasonToolsInstall", "MasonToolsUpdate" },
  { "mason.nvim", "mason-tool-installer.nvim" },
  "acurite.configs.mason"
)

-- Preserve the fast hot path: checking package directories costs no registry
-- initialization. On a fresh machine, automatically wake Mason after init so
-- mason-tool-installer can bootstrap every configured binary.
local mason_tools = require("acurite.configs.mason-tools")
local missing_mason_tool = mason_tools.first_missing()
if missing_mason_tool then
  vim.schedule(function()
    lazy.load({ "mason.nvim", "mason-tool-installer.nvim" }, "acurite.configs.mason")
    vim.notify("Bootstrapping missing Mason tools (first missing: " .. missing_mason_tool .. ")")
  end)
end
lazy.on_commands(
  { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  "diffview.nvim",
  "acurite.configs.diffview"
)

-- Event-triggered
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

-- `defer` matters here: netrw is still writing the listing when FileType
-- fires, so the decoration pass has to run after that returns.
lazy.on_event("FileType", "netrw.nvim", "acurite.configs.netrw", {
  pattern = "netrw",
  defer = true,
  after = function()
    require("acurite.configs.netrw").decorate_current()
  end,
})

lazy.on_event(
  "FileType",
  { "nvim-treesitter-textobjects" },
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
