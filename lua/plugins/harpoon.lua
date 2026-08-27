-- Harpoon: a short list of pinned files, jumped to by index.
local harpoon = require("harpoon")

harpoon:setup({
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
  },
})

local map = vim.keymap.set

map("n", "<leader>a", function()
  harpoon:list():add()
end, { desc = "Add file to Harpoon" })

map("n", "<leader>h", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon menu" })

map("n", "]h", function()
  harpoon:list():next()
end, { desc = "Next Harpoon file" })

map("n", "[h", function()
  harpoon:list():prev()
end, { desc = "Previous Harpoon file" })

for i = 1, 9 do
  map("n", "<leader>" .. i, function()
    harpoon:list():select(i)
  end, { desc = "Harpoon file " .. i })
end
