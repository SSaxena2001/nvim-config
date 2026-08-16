local keymap = vim.keymap
local lazy = require("acurite.core.lazy")

local function harpoon()
  lazy.load("harpoon", "acurite.configs.harpoon")
  return require("harpoon")
end

keymap.set("n", "<leader>a", function()
  harpoon():list():add()
end, { desc = "Add file to Harpoon" })

keymap.set("n", "<leader>h", function()
  local hp = harpoon()
  hp.ui:toggle_quick_menu(hp:list())
end, { desc = "Harpoon menu" })

keymap.set("n", "]h", function()
  harpoon():list():next()
end, { desc = "Next Harpoon file" })

keymap.set("n", "[h", function()
  harpoon():list():prev()
end, { desc = "Previous Harpoon file" })

for i = 1, 3 do
  keymap.set("n", "<leader>" .. i, function()
    harpoon():list():select(i)
  end, { desc = "Harpoon file " .. i })
end
