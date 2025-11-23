return {
  {
    "XXiaoA/atone.nvim",
    cmd = "Atone",
    config = function()
      vim.keymap.set("n", "<leader>u", ":Atone toggle<CR>")
    end,
  },
}
