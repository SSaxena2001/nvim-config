local ensure_installed = {
  "json",
  "javascript",
  "typescript",
  "tsx",
  "go",
  "yaml",
  "html",
  "css",
  "python",
  "http",
  "prisma",
  "svelte",
  "graphql",
  "bash",
  "vim",
  "dockerfile",
  "gitignore",
  "query",
  "vimdoc",
  "markdown",
  "markdown_inline",
  "c",
  "cpp",
  "java",
  "rust",
  "ron",
}

local TreeSitter = require("nvim-treesitter")

-- The rewritten nvim-treesitter keeps its bundled queries under runtime/.
-- Add that directory directly so highlighting is independent of query
-- symlinks left behind by older plugin managers.
local treesitter_packages = vim.pack.get({ "nvim-treesitter" })
if treesitter_packages[1] then
  vim.opt.runtimepath:prepend(treesitter_packages[1].path .. "/runtime")
end

-- Be explicit for React/TypeScript filetypes. This makes TSX resilient across
-- Neovim/nvim-treesitter changes and keeps the parser selection obvious.
vim.treesitter.language.register("tsx", "typescriptreact")
vim.treesitter.language.register("typescript", "typescript")
vim.treesitter.language.register("javascript", "javascript")
-- JSX is parsed by the `javascript` grammar; there is no installed `jsx`
-- parser and it is not in ensure_installed, so naming it here would leave
-- .jsx files with no Treesitter highlighting at all.
vim.treesitter.language.register("javascript", "javascriptreact")

local ensure_lookup = {}
for _, lang in ipairs(ensure_installed) do
  ensure_lookup[lang] = true
end

local max_filesize = 200 * 1024
local installing = {}
local installed_parsers = nil
local highlight_queries = {}

local function is_large_file(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local ok, stats = pcall(vim.uv.fs_stat, name)
  return ok and stats and stats.size > max_filesize
end

local function parser_installed(lang)
  installed_parsers = installed_parsers or TreeSitter.get_installed("parsers")
  for _, installed_lang in ipairs(installed_parsers) do
    if installed_lang == lang then
      return true
    end
  end
  return false
end

local function has_highlight_query(lang)
  if highlight_queries[lang] ~= nil then
    return highlight_queries[lang]
  end

  -- `after/queries` files only extend a base query. If the base query symlink is
  -- stale, Neovim reports no Treesitter captures even though a theme extension
  -- query exists.
  for _, path in ipairs(vim.api.nvim_get_runtime_file("queries/" .. lang .. "/highlights.scm", true)) do
    if not path:find("/after/", 1, true) then
      highlight_queries[lang] = true
      return true
    end
  end

  highlight_queries[lang] = false
  return false
end

local function install_or_update(lang, update)
  if not ensure_lookup[lang] or installing[lang] then
    return
  end

  installing[lang] = true
  vim.schedule(function()
    if update then
      TreeSitter.update({ lang })
    else
      TreeSitter.install({ lang })
    end
    installed_parsers = nil
    highlight_queries[lang] = nil
    installing[lang] = nil
  end)
end

-- Do not install/update parsers on every startup. On large machines this can
-- spawn compiler jobs and make Neovim look like it is leaking memory.
vim.api.nvim_create_user_command("TSInstallConfigured", function()
  TreeSitter.install(ensure_installed, { force = true, summary = true })
end, { desc = "Install configured Treesitter parsers" })

vim.api.nvim_create_user_command("TSUpdateConfigured", function()
  TreeSitter.update(ensure_installed, { summary = true })
end, { desc = "Update configured Treesitter parsers and queries" })

local treesitter_group = vim.api.nvim_create_augroup("AcuriteTreesitter", { clear = true })

local function setup_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local initial_ft = vim.bo[buf].filetype
  if initial_ft == "" then
    return
  end

  -- Loading a parser shared library can take ~180 ms on its first use. Let
  -- Neovim draw the buffer with its syntax fallback before doing that work.
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    local ft = vim.bo[buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end

    if not parser_installed(lang) then
      install_or_update(lang, false)
      return
    end

    if not has_highlight_query(lang) then
      install_or_update(lang, true)
      return
    end

    if is_large_file(buf) then
      return
    end

    if not pcall(vim.treesitter.start, buf, lang) then
      return
    end

    -- Treesitter owns highlighting now; stop the duplicate regex syntax
    -- engine that supplied color while the parser was loading.
    vim.bo[buf].syntax = ""

    if ft ~= "yaml" and ft ~= "markdown" then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.bo[buf].smartindent = false
      vim.bo[buf].cindent = false
    end
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  group = treesitter_group,
  pattern = "*",
  callback = function(args)
    setup_buffer(args.buf)
  end,
})

-- This module itself is loaded from a FileType callback, so configure the
-- buffer whose original event triggered the load.
setup_buffer(vim.api.nvim_get_current_buf())

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  min_window_height = 20,
  multiline_threshold = 5,
  mode = "cursor",
  separator = nil,
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@parameter.outer"] = "v",
      ["@function.outer"] = "V",
      ["@class.outer"] = "V",
    },
    include_surrounding_whitespace = true,
  },
  move = {
    set_jumps = true,
  },
})

require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true, -- Auto-close tags
    enable_rename = true, -- Auto-rename pairs
    enable_close_on_slash = false, -- Disable auto-close on trailing `</`
  },
  per_filetype = {
    ["html"] = {
      enable_close = true,
    },
    ["typescriptreact"] = {
      enable_close = true,
    },
  },
})
