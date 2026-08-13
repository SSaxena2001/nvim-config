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

-- fzf-native may still be compiling during a brand-new installation. Telescope
-- remains functional with its Lua sorter and will use fzf on the next launch.
pcall(require("telescope").load_extension, "fzf")
require("telescope").load_extension("ui-select")
