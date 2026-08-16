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

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("AcuriteTreesitter", { clear = true }),
        desc = "Start treesitter highlighting",
        callback = function(args)
          if vim.bo[args.buf].buftype ~= "" then
            return
          end

          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if not lang then
            return
          end

          -- A parser whose .so predates its queries raises at highlight time
          -- rather than returning an error, so guard the whole thing.
          pcall(vim.treesitter.start, args.buf, lang)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    keys = {
      { "af", select("@function.outer"), mode = { "x", "o" }, desc = "Outer function" },
      { "if", select("@function.inner"), mode = { "x", "o" }, desc = "Inner function" },
      { "ac", select("@class.outer"), mode = { "x", "o" }, desc = "Outer class" },
      { "ic", select("@class.inner"), mode = { "x", "o" }, desc = "Inner class" },
      { "aa", select("@parameter.outer"), mode = { "x", "o" }, desc = "Outer argument" },
      { "ia", select("@parameter.inner"), mode = { "x", "o" }, desc = "Inner argument" },

      { "]m", move("goto_next_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "Next function start" },
      { "[m", move("goto_previous_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "Prev function start" },
      { "]M", move("goto_next_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "Next function end" },
      { "[M", move("goto_previous_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "Prev function end" },
      { "]]", move("goto_next_start", "@class.outer"), mode = { "n", "x", "o" }, desc = "Next class start" },
      { "[[", move("goto_previous_start", "@class.outer"), mode = { "n", "x", "o" }, desc = "Prev class start" },
      { "][", move("goto_next_end", "@class.outer"), mode = { "n", "x", "o" }, desc = "Next class end" },
      { "[]", move("goto_previous_end", "@class.outer"), mode = { "n", "x", "o" }, desc = "Prev class end" },
    },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })
    end,
  },
}
