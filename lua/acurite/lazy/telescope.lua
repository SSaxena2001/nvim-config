local function project_root()
  return vim.fs.root(0, {
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "bun.lock",
    "go.work",
    "go.mod",
    "pyproject.toml",
    ".git",
    "package.json",
  }) or vim.fn.getcwd()
end

-- `rooted` pickers resolve the project root at press time, not at config time.
local function pick(name, opts)
  return function()
    require("telescope.builtin")[name](opts or {})
  end
end

local function rooted(name, opts)
  return function()
    require("telescope.builtin")[name](vim.tbl_extend("force", { cwd = project_root() }, opts or {}))
  end
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { ";f", rooted("find_files", { hidden = true }), desc = "Find files" },
    { ";r", rooted("live_grep"), desc = "Live grep" },
    { ";w", rooted("grep_string"), mode = { "n", "x" }, desc = "Grep word or selection" },
    { ";g", rooted("git_status"), desc = "Git changed files" },
    { ";t", pick("help_tags"), desc = "Help tags" },
    { ";;", pick("resume"), desc = "Resume picker" },
    { ";e", pick("diagnostics"), desc = "Diagnostics" },
    { ";s", pick("lsp_document_symbols"), desc = "Document symbols" },
    { "\\", pick("buffers"), desc = "Buffers" },
    {
      "<leader>fP",
      function()
        require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config"), hidden = true })
      end,
      desc = "Find config file",
    },
  },
  config = function()
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")

    local generated = {
      ".git",
      "node_modules",
      "dist",
      "build",
      "coverage",
      ".next",
      ".turbo",
      "target",
    }

    local find_command = { "fd", "--type", "f", "--type", "l", "--hidden", "--color", "never" }
    for _, dir in ipairs(generated) do
      vim.list_extend(find_command, { "--exclude", dir })
    end

    local vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--max-columns=500",
      "--max-filesize=1M",
    }
    for _, dir in ipairs(generated) do
      vim.list_extend(vimgrep_arguments, { "--glob", "!" .. dir })
    end
    vim.list_extend(vimgrep_arguments, {
      "--glob",
      "!*.lock",
      "--glob",
      "!package-lock.json",
      "--glob",
      "!pnpm-lock.yaml",
      "--glob",
      "!yarn.lock",
    })

    require("telescope").setup({
      defaults = {
        vimgrep_arguments = vimgrep_arguments,
        sorting_strategy = "ascending",
        selection_strategy = "reset",
        path_display = { "smart" },
        dynamic_preview_title = true,
        cache_picker = { num_pickers = 3 },
        layout_strategy = "horizontal",
        layout_config = {
          prompt_position = "top",
          width = 0.86,
          height = 0.82,
          horizontal = { preview_width = 0.52 },
        },
        mappings = {
          i = {
            ["<Esc>"] = actions.close,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = {
            ["<Esc>"] = actions.close,
            ["q"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = find_command,
          previewer = false,
        },
        live_grep = { max_results = 5000 },
        grep_string = { max_results = 5000 },
      },
      extensions = {
        ["ui-select"] = themes.get_dropdown({ previewer = false }),
      },
    })

    -- Preview highlighting must never take the whole picker down. A parser
    -- whose queries do not match the installed grammar raises at
    -- vim.treesitter.start; wrap it so the preview simply renders unhighlighted.
    local preview_utils = require("telescope.previewers.utils")
    preview_utils.ts_highlighter = function(bufnr, ft)
      local lang = vim.treesitter.language.get_lang(ft) or ft
      if not lang or lang == "" then
        return false
      end
      return pcall(vim.treesitter.start, bufnr, lang)
    end

    -- fzf-native may still be compiling on a brand-new installation.
    -- Telescope stays usable with its Lua sorter and picks fzf up next launch.
    pcall(require("telescope").load_extension, "fzf")
    require("telescope").load_extension("ui-select")
  end,
}
