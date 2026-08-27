-- Neovim ships parsers for c, lua, markdown, query, vim and vimdoc only.
-- Everything else is built here.
local parsers = {
  "astro",
  "bash",
  "c",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "fish",
  "git_config",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "html",
  "jsx",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "odin",
  "python",
  "query",
  "regex",
  "rust",
  "scss",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

local ts = require("nvim-treesitter")

local installed = {}
for _, lang in ipairs(ts.get_installed("parsers")) do
  installed[lang] = true
end

-- Only ask for what is missing: install() re-fetches whatever it is handed, so
-- passing the whole list would rebuild every parser on every startup.
local missing = vim.tbl_filter(function(lang)
  return not installed[lang]
end, parsers)

local function start(buf)
  if not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" then
    return
  end
  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  -- A parser whose .so predates its queries raises at highlight time rather
  -- than returning an error, so guard the whole thing.
  if lang and installed[lang] then
    pcall(vim.treesitter.start, buf, lang)
  end
end

if #missing > 0 then
  -- install() is asynchronous, which makes `installed` a snapshot that goes
  -- stale the moment a parser lands. Without this the parsers fetched on one
  -- startup do not highlight until the next one: the FileType callback below
  -- reads the set from before the download. Refreshing it and sweeping the
  -- open buffers is what closes that gap.
  ts.install(missing):await(function()
    vim.schedule(function()
      for _, lang in ipairs(ts.get_installed("parsers")) do
        installed[lang] = true
      end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        start(buf)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("Treesitter", { clear = true }),
  desc = "Start treesitter highlighting",
  callback = function(args)
    start(args.buf)
  end,
})

require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

local function select(obj)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(obj, "textobjects")
  end
end

local function move(fn, obj)
  return function()
    require("nvim-treesitter-textobjects.move")[fn](obj, "textobjects")
  end
end

local map = vim.keymap.set

map({ "x", "o" }, "af", select("@function.outer"), { desc = "Outer function" })
map({ "x", "o" }, "if", select("@function.inner"), { desc = "Inner function" })
map({ "x", "o" }, "ac", select("@class.outer"), { desc = "Outer class" })
map({ "x", "o" }, "ic", select("@class.inner"), { desc = "Inner class" })
map({ "x", "o" }, "aa", select("@parameter.outer"), { desc = "Outer argument" })
map({ "x", "o" }, "ia", select("@parameter.inner"), { desc = "Inner argument" })

map({ "n", "x", "o" }, "]m", move("goto_next_start", "@function.outer"), { desc = "Next function" })
map({ "n", "x", "o" }, "[m", move("goto_previous_start", "@function.outer"), { desc = "Prev function" })
