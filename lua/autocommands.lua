-- Highlight selection on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.hl.on_yank({ timeout = 200, visual = true })
  end,
})

-- Restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
  -- Grouped so re-sourcing this module replaces the autocmd instead of
  -- stacking another copy of it.
  group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
  callback = function(args)
    -- BufReadPost also fires for buffers read in the background -- `bufload`,
    -- `:vimgrep`, an LSP or picker touching a file -- and those have no window
    -- of their own. The cursor call below moves the *current* window, so
    -- without this guard a background read drags the cursor of whatever is on
    -- screen to a line number from a different file, and throws "Invalid
    -- cursor line: out of range" whenever that file is the longer of the two.
    if args.buf ~= vim.api.nvim_get_current_buf() then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
      vim.cmd("normal! zz")
    end
  end,
})
