-- quicker.nvim: syntax-highlighted, editable quickfix with context lines.
-- Nearly every picker in lua/picker.lua ends in the quickfix list, so this is
-- the window that gets looked at most.
require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})
