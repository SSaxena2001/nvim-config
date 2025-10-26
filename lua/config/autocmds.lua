-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
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
