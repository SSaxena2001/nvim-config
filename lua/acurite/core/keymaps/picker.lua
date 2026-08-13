local keymap = vim.keymap
local telescope = require("acurite.core.telescope")

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

keymap.set("n", ";f", function()
  telescope.builtin("find_files", { cwd = project_root(), hidden = true })
end, { desc = "Find files" })

keymap.set("n", "<leader>fP", function()
  telescope.builtin("find_files", { cwd = vim.fn.stdpath("config"), hidden = true })
end, { desc = "Find config file" })

keymap.set("n", ";r", function()
  telescope.builtin("live_grep", { cwd = project_root() })
end, { desc = "Live grep" })

keymap.set({ "n", "x" }, ";w", function()
  telescope.builtin("grep_string", { cwd = project_root() })
end, { desc = "Grep word or selection" })

keymap.set("n", "\\", function()
  telescope.builtin("buffers")
end, { desc = "Buffers" })

keymap.set("n", ";t", function()
  telescope.builtin("help_tags")
end, { desc = "Help tags" })

keymap.set("n", ";;", function()
  telescope.builtin("resume")
end, { desc = "Resume picker" })

keymap.set("n", ";e", function()
  telescope.builtin("diagnostics")
end, { desc = "Diagnostics" })

keymap.set("n", ";s", function()
  telescope.builtin("lsp_document_symbols")
end, { desc = "Document symbols" })

keymap.set("n", "<leader>e", function()
  MiniFiles.open(project_root())
end, { desc = "File explorer" })

keymap.set("n", "sf", function()
  local path = vim.api.nvim_buf_get_name(0)
  MiniFiles.open(path ~= "" and path or vim.fn.getcwd())
end, { desc = "File explorer at buffer path" })
