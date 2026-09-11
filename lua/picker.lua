-- The ";" prefix. fff answers the two things it is built for -- files and
-- content -- and Neovim answers the rest. `:find` and `:grep` still stand on
-- their own (see find.lua and grep.lua); these mappings are the interactive
-- front end for them.
--
-- The pickers that used to come from fzf-lua and now do not (buffers, help
-- tags, diagnostics, symbols, git status) are native below. Each either has a
-- built-in popup already -- 'wildoptions' carries `pum`, so command-line
-- completion is a real menu -- or ends in the quickfix list, which
-- quicker.nvim styles and makes editable. ";;" reopens it.

local fff = require("fff")
local map = vim.keymap.set

-- ;f -- find files ------------------------------------------------------
-- The index root is set once, at startup, in lua/plugins/fff.lua. Re-pointing
-- it is the expensive operation, so it does not belong on a key pressed this
-- often. `:FFFScan` rescans in place; change_indexing_directory moves the root
-- if a session really does outgrow one project.
map("n", ";f", fff.find_files, { desc = "Find files" })

-- ;P -- find a file in the Neovim config --------------------------------
map("n", ";P", function()
  fff.find_files_in_dir(vim.fn.stdpath("config"))
end, { desc = "Find config file" })

-- ;r -- grep for a pattern. Live: the content index is queried per keystroke.
map("n", ";r", fff.live_grep, { desc = "Grep" })

-- ;w -- grep the word under the cursor, or the visual selection ----------
-- One function for both: it reads the cword in normal mode and the selection
-- in visual.
map({ "n", "x" }, ";w", fff.live_grep_under_cursor, { desc = "Grep word/selection" })

-- ;g -- files changed against HEAD --------------------------------------
-- Fugitive's status buffer, which is a better answer than a picker was: the
-- same list, but staging, diffing and committing happen in place. <leader>gs
-- opens the same thing (lua/plugins/fugitive.lua).
map("n", ";g", function()
  if not vim.fs.root(0, ".git") then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  vim.cmd.Git()
end, { desc = "Git changed files" })

-- ;t -- help tags -------------------------------------------------------
-- `:help` completes over every tag natively and 'wildoptions' draws it as a
-- popup, so this is the picker -- left unexecuted for the pattern to be typed.
map("n", ";t", ":help ", { desc = "Help tags" })

-- ;e -- every diagnostic in the workspace --------------------------------
-- Straight to the quickfix list. No `open` flag: `copen` is called after so
-- the window is focused, which setqflist's own opener does not do.
map("n", ";e", function()
  vim.diagnostic.setqflist()
  vim.cmd.copen()
end, { desc = "Diagnostics" })

-- ;s -- document symbols -------------------------------------------------
-- `vim.lsp.buf.document_symbol` fills the quickfix list by default, so the
-- only thing to add is opening it.
map("n", ";s", function()
  vim.lsp.buf.document_symbol({
    on_list = function(list)
      vim.fn.setqflist({}, " ", list)
      vim.cmd.copen()
    end,
  })
end, { desc = "Document symbols" })

-- \ -- buffers ----------------------------------------------------------
-- One prompt rather than `:ls` followed by `:buffer`. vim.ui.select is the
-- native chooser, so whatever is registered as the handler draws this -- with
-- none registered it is Neovim's own numbered list.
map("n", "\\", function()
  local bufs = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b)
  end, vim.api.nvim_list_bufs())

  if vim.tbl_isempty(bufs) then
    vim.notify("No listed buffers", vim.log.levels.INFO)
    return
  end

  vim.ui.select(bufs, {
    prompt = "Buffers",
    format_item = function(b)
      local name = vim.api.nvim_buf_get_name(b)
      name = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
      -- Same two marks the statusline uses, for the same two states.
      return (vim.bo[b].modified and "● " or "  ") .. name
    end,
  }, function(buf)
    if buf then
      vim.api.nvim_set_current_buf(buf)
    end
  end)
end, { desc = "Buffers" })

-- ;; -- reopen the last quickfix list ------------------------------------
map("n", ";;", function()
  if vim.tbl_isempty(vim.fn.getqflist()) then
    vim.notify("Quickfix list is empty", vim.log.levels.INFO)
    return
  end
  vim.cmd.copen()
end, { desc = "Resume quickfix" })
