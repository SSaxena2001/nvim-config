-- The ";" prefix: what telescope used to cover, now fzf-lua over the native
-- layer. `:find` and `:grep` still stand on their own -- see find.lua and
-- grep.lua -- these mappings are the interactive front end for them.
--
-- ctrl-q in any picker sends the whole result set to the quickfix list, which
-- quicker.nvim styles and makes editable; ";;" reopens it.

local fzf = require("fzf-lua")
local find = require("find")
local map = vim.keymap.set

-- Resolved per call rather than once at load, so the picker follows the
-- buffer instead of the directory Neovim happened to start in.
local function in_root(opts)
  return vim.tbl_extend("force", { cwd = find.project_root() }, opts or {})
end

-- ;f -- find files, project root, hidden included -----------------------
map("n", ";f", function()
  fzf.files(in_root())
end, { desc = "Find files" })

-- ;P -- find a file in the Neovim config --------------------------------
map("n", ";P", function()
  fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find config file" })

-- ;r -- grep for a pattern. Live: ripgrep reruns per keystroke rather than
-- fzf filtering one fixed result set.
map("n", ";r", function()
  fzf.live_grep(in_root())
end, { desc = "Grep" })

-- ;w -- grep the word under the cursor, or the visual selection ----------
map("n", ";w", function()
  fzf.grep_cword(in_root())
end, { desc = "Grep word" })

map("x", ";w", function()
  fzf.grep_visual(in_root())
end, { desc = "Grep selection" })

-- ;g -- files changed against HEAD, plus untracked. fzf-lua does resolve the
-- git root itself, but from `cwd`, which defaults to Neovim's -- so pass the
-- buffer's, the way every other picker here does.
map("n", ";g", function()
  local root = vim.fs.root(0, ".git")
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  fzf.git_status({ cwd = root })
end, { desc = "Git changed files" })

-- ;t -- help tags -------------------------------------------------------
map("n", ";t", fzf.helptags, { desc = "Help tags" })

-- ;e -- every diagnostic in the workspace --------------------------------
map("n", ";e", fzf.diagnostics_workspace, { desc = "Diagnostics" })

-- ;s -- document symbols -------------------------------------------------
map("n", ";s", fzf.lsp_document_symbols, { desc = "Document symbols" })

-- \ -- buffers ----------------------------------------------------------
map("n", "\\", fzf.buffers, { desc = "Buffers" })

-- ;; -- reopen the last quickfix list ------------------------------------
map("n", ";;", function()
  if vim.tbl_isempty(vim.fn.getqflist()) then
    vim.notify("Quickfix list is empty", vim.log.levels.INFO)
    return
  end
  vim.cmd.copen()
end, { desc = "Resume quickfix" })
