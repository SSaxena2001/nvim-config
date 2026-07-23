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

-- Be explicit for React/TypeScript filetypes. This makes TSX resilient across
-- Neovim/nvim-treesitter changes and keeps the parser selection obvious.
vim.treesitter.language.register("tsx", "typescriptreact")
vim.treesitter.language.register("typescript", "typescript")
vim.treesitter.language.register("javascript", "javascript")
vim.treesitter.language.register("jsx", "javascriptreact")

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype

    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end

    if not parser_installed(lang) then
      -- Install only on demand for configured parsers. Vim syntax highlighting
      -- remains enabled as a fallback while the parser is missing/installing.
      install_or_update(lang, false)
      return
    end

    if not has_highlight_query(lang) then
      -- Repair stale/missing query symlinks, e.g. after moving from lazy.nvim to
      -- vim.pack. Without this, TS/TSX parsers can start but show no colors.
      install_or_update(lang, true)
      return
    end

    if is_large_file(buf) then
      return
    end

    -- start treesitter safely
    local ok = pcall(vim.treesitter.start, buf, lang)
    if not ok then
      return
    end

    -- enable indentation (skip yaml/markdown)
    if ft ~= "yaml" and ft ~= "markdown" then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.bo[buf].smartindent = false
      vim.bo[buf].cindent = false
    end
  end,
})

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  min_window_height = 20,
  multiline_threshold = 5,
  mode = "cursor",
  separator = nil,
})

vim.keymap.set("n", "<leader>tc", "<cmd>TSContext toggle<cr>", { desc = "Toggle Treesitter context" })

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

local ts_select = require("nvim-treesitter-textobjects.select")
local ts_move = require("nvim-treesitter-textobjects.move")
local ts_swap = require("nvim-treesitter-textobjects.swap")

vim.keymap.set({ "x", "o" }, "af", function()
  ts_select.select_textobject("@function.outer", "textobjects")
end, { desc = "Select outer function" })

vim.keymap.set({ "x", "o" }, "if", function()
  ts_select.select_textobject("@function.inner", "textobjects")
end, { desc = "Select inner function" })

vim.keymap.set({ "x", "o" }, "ac", function()
  ts_select.select_textobject("@class.outer", "textobjects")
end, { desc = "Select outer class" })

vim.keymap.set({ "x", "o" }, "ic", function()
  ts_select.select_textobject("@class.inner", "textobjects")
end, { desc = "Select inner class" })

vim.keymap.set({ "x", "o" }, "aa", function()
  ts_select.select_textobject("@parameter.outer", "textobjects")
end, { desc = "Select outer argument/parameter" })

vim.keymap.set({ "x", "o" }, "ia", function()
  ts_select.select_textobject("@parameter.inner", "textobjects")
end, { desc = "Select inner argument/parameter" })

vim.keymap.set("n", "<leader>a", function()
  ts_swap.swap_next("@parameter.inner")
end, { desc = "Swap with next argument/parameter" })

vim.keymap.set("n", "<leader>A", function()
  ts_swap.swap_previous("@parameter.outer")
end, { desc = "Swap with previous argument/parameter" })

vim.keymap.set({ "n", "x", "o" }, "]m", function()
  ts_move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })

vim.keymap.set({ "n", "x", "o" }, "[m", function()
  ts_move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function start" })

vim.keymap.set({ "n", "x", "o" }, "]M", function()
  ts_move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })

vim.keymap.set({ "n", "x", "o" }, "[M", function()
  ts_move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Previous function end" })

vim.keymap.set({ "n", "x", "o" }, "]]", function()
  ts_move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })

vim.keymap.set({ "n", "x", "o" }, "[[", function()
  ts_move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Previous class start" })

vim.keymap.set({ "n", "x", "o" }, "][", function()
  ts_move.goto_next_end("@class.outer", "textobjects")
end, { desc = "Next class end" })

vim.keymap.set({ "n", "x", "o" }, "[]", function()
  ts_move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "Previous class end" })

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
