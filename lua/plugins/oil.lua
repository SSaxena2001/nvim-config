-- oil.nvim: the file explorer is a normal buffer. Renames, deletes and
-- creations are ordinary text edits applied on :w.
--
-- No icon column: nvim-web-devicons and mini.icons are both gone, and oil's
-- icon column needs one of them.
require("oil").setup({
  -- Take over directory buffers, so `nvim .` and `:e src/` open oil. netrw is
  -- no longer configured at all.
  default_file_explorer = true,

  columns = {},

  win_options = {
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

  -- Rename a file and the language servers hear about it, so imports follow.
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

  float = {
    padding = 2,
    max_width = 0.6,
    max_height = 0.8,
    border = "rounded",
  },
})
