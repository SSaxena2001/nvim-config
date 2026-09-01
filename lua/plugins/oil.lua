local M = {}

require("oil").setup({
  default_file_explorer = true,

  columns = { "icon" },

  float = {
    padding = 2,
    max_width = 0.8, -- 0-1 is a fraction of the screen; an integer is columns
    max_height = 0.8,
    border = "rounded",
    win_options = { winblend = 0 },
    preview_split = "right",
  },

  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "nvic",
  },

  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,

  lsp_file_methods = {
    enabled = true,
    timeout_ms = 1000,
    autosave_changes = "unmodified",
  },

  watch_for_changes = true,

  view_options = {
    show_hidden = true,
    natural_order = "fast",
    is_always_hidden = function(name)
      return name == ".DS_Store"
    end,
  },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "OilEnter",
  callback = function(args)
    if vim.api.nvim_get_current_buf() == args.data.buf then
      require("oil").open_preview()
    end
  end,
})

function M.toggle_oil(dir)
  require("oil").toggle_float(dir)
end

return M
