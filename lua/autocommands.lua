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
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
      -- Centre inside the event buffer's own window. A plain `normal! zz`
      -- would run against whatever window is current, which for a background
      -- `bufload` is not this one.
      vim.api.nvim_buf_call(args.buf, function()
        vim.cmd("normal! zz")
      end)
    end
  end,
})
