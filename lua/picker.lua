-- The ";" prefix: what telescope used to cover, rebuilt on Neovim's own
-- :find, :grep, quickfix and LSP handlers. Results land in the quickfix list,
-- which quicker.nvim styles and makes editable.

local find = require("find")
local map = vim.keymap.set

local function grep(pattern)
  if pattern == nil or pattern == "" then
    return
  end

  -- `-e` so a pattern starting with `-` is not read as a ripgrep flag, and an
  -- explicit path so the search covers the whole project rather than only cwd.
  -- The path is omitted when it would be redundant, which keeps the quickfix
  -- entries relative and readable.
  local args = { "-e", vim.fn.fnameescape(pattern) }
  local root = find.project_root()
  if root ~= vim.fn.getcwd() then
    args[#args + 1] = vim.fn.fnameescape(root)
  end

  -- `grep!` skips the jump to the first result; the quickfix window is the
  -- point.
  local ok, err = pcall(vim.cmd, "silent grep! " .. table.concat(args, " "))
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return
  end

  if vim.tbl_isempty(vim.fn.getqflist()) then
    vim.notify("No matches for " .. pattern, vim.log.levels.WARN)
    return
  end
  vim.cmd.copen()
end

local function selected_text()
  local saved = vim.fn.getreg("v")
  vim.cmd([[noautocmd normal! "vy]])
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", saved)
  return (text:gsub("\n.*", ""))
end

-- ;f -- find files, project root, hidden included -----------------------
map("n", ";f", function()
  find.scope = nil
  vim.api.nvim_feedkeys(":find ", "n", false)
end, { desc = "Find files" })

-- ;P -- find a file in the Neovim config --------------------------------
map("n", ";P", function()
  find.scope = vim.fn.stdpath("config")
  vim.api.nvim_feedkeys(":find ", "n", false)
end, { desc = "Find config file" })

-- ;r -- grep for a pattern ----------------------------------------------
map("n", ";r", function()
  vim.ui.input({ prompt = "Grep: " }, grep)
end, { desc = "Grep" })

-- ;w -- grep the word under the cursor, or the visual selection ----------
map("n", ";w", function()
  grep(vim.fn.expand("<cword>"))
end, { desc = "Grep word" })

map("x", ";w", function()
  grep(selected_text())
end, { desc = "Grep selection" })

-- ;g -- files changed against HEAD, plus untracked -----------------------
map("n", ";g", function()
  local root = vim.fs.root(0, ".git")
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local function git(args)
    local out = vim.system(vim.list_extend({ "git" }, args), { cwd = root, text = true }):wait()
    if out.code ~= 0 then
      return {}
    end
    return vim.split(out.stdout, "\n", { trimempty = true })
  end

  local seen, items = {}, {}
  local changed = git({ "diff", "--name-only", "HEAD" })
  vim.list_extend(changed, git({ "ls-files", "--others", "--exclude-standard" }))

  for _, rel in ipairs(changed) do
    if not seen[rel] then
      seen[rel] = true
      items[#items + 1] = { filename = vim.fs.joinpath(root, rel), lnum = 1, col = 1, text = rel }
    end
  end

  if vim.tbl_isempty(items) then
    vim.notify("No changed files", vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, " ", { title = "Git changed files", items = items })
  vim.cmd.copen()
end, { desc = "Git changed files" })

-- ;t -- help tags. The wildmenu is the picker. -------------------------
map("n", ";t", function()
  vim.api.nvim_feedkeys(":help ", "n", false)
end, { desc = "Help tags" })

-- ;; -- reopen the last quickfix list ------------------------------------
map("n", ";;", function()
  if vim.tbl_isempty(vim.fn.getqflist()) then
    vim.notify("Quickfix list is empty", vim.log.levels.INFO)
    return
  end
  vim.cmd.copen()
end, { desc = "Resume quickfix" })

-- ;e -- every diagnostic in the workspace --------------------------------
map("n", ";e", function()
  vim.diagnostic.setqflist()
end, { desc = "Diagnostics" })

-- ;s -- document symbols, routed to the quickfix list rather than the
-- location list vim.lsp.buf.document_symbol() uses by default.
map("n", ";s", function()
  vim.lsp.buf.document_symbol({
    on_list = function(list)
      vim.fn.setqflist({}, " ", { title = list.title, items = list.items })
      vim.cmd.copen()
    end,
  })
end, { desc = "Document symbols" })

-- \ -- buffers ----------------------------------------------------------
map("n", "\\", function()
  local bufs = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted and vim.api.nvim_buf_get_name(b) ~= ""
  end, vim.api.nvim_list_bufs())

  if vim.tbl_isempty(bufs) then
    vim.notify("No listed buffers", vim.log.levels.INFO)
    return
  end

  vim.ui.select(bufs, {
    prompt = "Buffers",
    format_item = function(b)
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":.")
    end,
  }, function(choice)
    if choice then
      vim.api.nvim_set_current_buf(choice)
    end
  end)
end, { desc = "Buffers" })
