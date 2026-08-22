local M = {}

require("oil").setup({
  default_file_explorer = true,

  columns = { "icon" },

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

function M.toggle_oil(dir)
  if vim.bo.filetype == "oil" then
    require("oil").close()
  else
    require("oil").open(dir)
  end
end

return M
