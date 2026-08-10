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
    local floating = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).relative ~= ""

    if not floating then
      -- The buffer may still carry the mapping from an earlier float (zen-mode
      -- and picker previews both show real buffers in floating windows). Drop
      -- it, or `q` silently stops recording macros in a normal window.
      --
      -- Only ever delete a mapping this autocmd installed: help, qf, man and
      -- checkhealth ftplugins bind buffer-local `q` to close the window, and
      -- an unconditional delete would silently break all of them.
      if vim.b[args.buf].acurite_float_q then
        pcall(vim.keymap.del, "n", "q", { buffer = args.buf })
        vim.b[args.buf].acurite_float_q = nil
      end
      return
    end

    vim.keymap.set("n", "q", function()
      -- Resolve the window at press time; the captured handle would be stale
      -- if this buffer is shown in a different float later.
      pcall(vim.api.nvim_win_close, vim.api.nvim_get_current_win(), true)
    end, { buffer = args.buf, nowait = true, silent = true, desc = "Close floating window" })
    vim.b[args.buf].acurite_float_q = true
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
