-- lazygit in its own tab. A tab gives it the whole screen without the float
-- having to hand-match six highlight groups to the colorscheme.
vim.keymap.set("n", "<leader>gg", function()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not on $PATH", vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()

  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    cwd = root,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })
  vim.cmd.startinsert()
end, { desc = "Lazygit (git root)" })
