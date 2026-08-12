require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    merge_tool = {
      layout = "diff3_horizontal",
      disable_diagnostics = true,
      winbar_info = true,
    },
  },

  -- Keep Diffview's documented mappings. In a merge view, [x and ]x move
  -- between conflicts; <leader>co/ct/cb/ca choose ours/theirs/base/all for
  -- one conflict, while the uppercase variants apply to the whole file.
  keymaps = {
    disable_defaults = false,
  },
})
