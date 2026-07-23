vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  callback = function(args)
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)

    if config.relative == "" then
      return
    end

    vim.keymap.set("n", "q", function()
      pcall(vim.api.nvim_win_close, win, true)
    end, { buffer = args.buf, nowait = true, silent = true, desc = "Close floating window" })
  end,
})

local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

vim.api.nvim_create_augroup("JSLogMacro", { clear = true })
vim.api.nvim_create_augroup("PythonLogMacro", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "JSLogMacro",
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    vim.fn.setreg("l", "yoconsole.log('" .. esc .. "pa:" .. esc .. "la, " .. esc .. "pl")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = "PythonLogMacro",
  pattern = { "python" },
  callback = function()
    vim.fn.setreg("l", "print('" .. esc .. "pa:" .. esc .. "la, " .. esc .. "pl")
  end,
})
