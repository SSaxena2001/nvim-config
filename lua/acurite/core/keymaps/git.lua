local function open_lazygit()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed or not in PATH", vim.log.levels.ERROR)
    return
  end

  local git_root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()

  local normal_float = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
  local title = vim.api.nvim_get_hl(0, { name = "FloatTitle", link = false })
  local info = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo", link = false })
  local float_bg = normal_float.bg or normal.bg or "NONE"
  local float_fg = normal_float.fg or normal.fg or "NONE"
  local border_fg = border.fg or info.fg or float_fg
  vim.api.nvim_set_hl(0, "LazyGitFloat", { fg = float_fg, bg = float_bg })
  vim.api.nvim_set_hl(0, "LazyGitBorder", { fg = border_fg, bg = float_bg })
  vim.api.nvim_set_hl(0, "LazyGitTitle", { fg = title.fg or info.fg or border_fg, bg = float_bg, bold = true })

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " lazygit ",
    title_pos = "center",
  })

  vim.bo[buf].bufhidden = "wipe"
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].winhighlight = table.concat({
    "Normal:LazyGitFloat",
    "NormalNC:LazyGitFloat",
    "EndOfBuffer:LazyGitFloat",
    "SignColumn:LazyGitFloat",
    "FloatBorder:LazyGitBorder",
    "FloatTitle:LazyGitTitle",
  }, ",")

  vim.fn.termopen("lazygit", {
    cwd = git_root,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })
  vim.cmd.startinsert()
end

vim.keymap.set("n", "<leader>gg", open_lazygit, { desc = "Lazygit (git root)" })
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open Git diff view" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close Git diff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current file Git history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repository Git history" })
