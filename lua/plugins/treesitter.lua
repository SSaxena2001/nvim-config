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
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
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

-- What is already built, as a set. nvim-treesitter installs into
-- stdpath("data")/site/parser, which is on the runtimepath.
local installed = {}
for _, lang in ipairs(ts.get_installed("parsers")) do
  installed[lang] = true
end

-- Only ask for what is missing: install() re-fetches whatever it is handed, so
-- passing the whole list would rebuild every parser on every startup.
local missing = vim.tbl_filter(function(lang)
  return not installed[lang]
end, parsers)

if #missing > 0 then
  ts.install(missing)
end

-- Languages that can be built but are not in the list above. Checked once so a
-- filetype nobody anticipated still gets highlighted rather than silently
-- falling back to Vim's regex syntax.
local available = {}
for _, lang in ipairs(ts.get_available()) do
  available[lang] = true
end

local function start(buf, lang)
  -- A parser whose .so predates its queries raises at highlight time rather
  -- than returning an error, so guard the whole thing.
  pcall(vim.treesitter.start, buf, lang)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("Treesitter", { clear = true }),
  desc = "Start treesitter highlighting",
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if not lang then
      return
    end

    if installed[lang] then
      start(args.buf, lang)
      return
    end

    if not available[lang] then
      return
    end

    -- Build it now, then highlight when it lands. install() is async, so the
    -- buffer is already on screen with Vim's syntax highlighting by then.
    ts.install({ lang }):await(function()
      installed[lang] = true
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.schedule(function()
          start(args.buf, lang)
        end)
      end
    end)
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

map({ "n", "x", "o" }, "]m", move("goto_next_start", "@function.outer"), { desc = "Next function start" })
map({ "n", "x", "o" }, "[m", move("goto_previous_start", "@function.outer"), { desc = "Prev function start" })
map({ "n", "x", "o" }, "]M", move("goto_next_end", "@function.outer"), { desc = "Next function end" })
map({ "n", "x", "o" }, "[M", move("goto_previous_end", "@function.outer"), { desc = "Prev function end" })
map({ "n", "x", "o" }, "]]", move("goto_next_start", "@class.outer"), { desc = "Next class start" })
map({ "n", "x", "o" }, "[[", move("goto_previous_start", "@class.outer"), { desc = "Prev class start" })
map({ "n", "x", "o" }, "][", move("goto_next_end", "@class.outer"), { desc = "Next class end" })
map({ "n", "x", "o" }, "[]", move("goto_previous_end", "@class.outer"), { desc = "Prev class end" })
