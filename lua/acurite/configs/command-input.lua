_G.AcuriteCommandLine = _G.AcuriteCommandLine or {}

function _G.AcuriteCommandLine.complete(findstart, base)
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
  local line_before_cursor = line:sub(1, cursor_col)

  if findstart == 1 then
    local arg_start = line_before_cursor:match("^.*%s()")
    return arg_start and (arg_start - 1) or 0
  end

  local ok, completions = pcall(vim.fn.getcompletion, line_before_cursor, "cmdline")
  if not ok then
    return {}
  end

  local token = base ~= "" and base or (line_before_cursor:match("%S+$") or "")
  if token ~= "" then
    completions = vim.tbl_filter(function(item)
      return item:find(token, 1, true) == 1
    end, completions)
  end

  return completions
end

local function command_input()
  if vim.fn.getcmdwintype() ~= "" then
    return
  end

  local mode = vim.fn.mode()
  local default = (mode == "v" or mode == "V" or mode == "\22") and "'<,'>" or ""
  local parent_win = vim.api.nvim_get_current_win()
  local width = 40
  local height = 1
  local row = math.floor((vim.o.lines - height) / 2) - 8
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(row, 1),
    col = math.max(col, 0),
    style = "minimal",
    border = "rounded",
    title = " Command ",
    title_pos = "center",
  })

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].completefunc = "v:lua.AcuriteCommandLine.complete"
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default })
  vim.api.nvim_win_set_cursor(win, { 1, #default })

  local function close()
    if vim.fn.mode():match("^[iR]") then
      vim.cmd.stopinsert()
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_win_is_valid(parent_win) then
      vim.api.nvim_set_current_win(parent_win)
    end
    vim.schedule(function()
      if vim.fn.mode():match("^[iR]") then
        vim.cmd.stopinsert()
      end
    end)
  end

  local function confirm()
    local command = vim.trim(vim.api.nvim_get_current_line())
    close()
    if command == "" then
      return
    end

    command = command:gsub("^:", "")
    vim.fn.histadd("cmd", command)

    local cmd_ok, cmd_err = pcall(vim.cmd, command)
    if not cmd_ok then
      vim.notify(cmd_err, vim.log.levels.ERROR)
    end

    vim.schedule(function()
      if vim.fn.mode():match("^[iR]") then
        vim.cmd.stopinsert()
      end
    end)
  end

  vim.keymap.set({ "n", "i" }, "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i" }, "<CR>", confirm, { buffer = buf, nowait = true })
  vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-u>"
  end, { buffer = buf, expr = true, nowait = true })
  vim.keymap.set("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-x><C-u>"
  end, { buffer = buf, expr = true, nowait = true })

  vim.cmd.startinsert({ bang = true })
end

vim.keymap.set({ "n", "x" }, ":", command_input, { desc = "Centered command prompt" })
vim.keymap.set({ "n", "x" }, "<leader>:", command_input, { desc = "Centered command prompt" })
