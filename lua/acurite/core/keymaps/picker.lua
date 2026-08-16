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

-- Changed files only: git_status lists the working tree + index diff, so this
-- is the "what am I actually touching right now" picker.
keymap.set("n", ";g", function()
  telescope.builtin("git_status", { cwd = project_root() })
end, { desc = "Git changed files" })

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

-- Toggle rather than a plain :Ex. netrw replaces the file in the current
-- window, so "closing" it means going back — and going back deserves the same
-- key that opened it. Avoids mapping `q`, which netrw needs as the prefix for
-- qf, qb, qF and qL.
keymap.set("n", "<leader>e", function()
  if vim.bo.filetype ~= "netrw" then
    vim.cmd.Ex()
    return
  end

  -- :Rex returns to the buffer netrw replaced, but it is a silent no-op when
  -- there is nothing to return to (Neovim was started on a directory). Detect
  -- that by checking whether the window actually left netrw.
  pcall(vim.cmd.Rexplore)
  if vim.bo.filetype == "netrw" then
    vim.cmd.enew()
  end
end, { desc = "File explorer (toggle)" })
