local function harpoon()
  return require("harpoon")
end

local keys = {
  {
    "<leader>a",
    function()
      harpoon():list():add()
    end,
    desc = "Add file to Harpoon",
  },
  {
    "<leader>h",
    function()
      local hp = harpoon()
      hp.ui:toggle_quick_menu(hp:list())
    end,
    desc = "Harpoon menu",
  },
  {
    "]h",
    function()
      harpoon():list():next()
    end,
    desc = "Next Harpoon file",
  },
  {
    "[h",
    function()
      harpoon():list():prev()
    end,
    desc = "Previous Harpoon file",
  },
}

for i = 1, 3 do
  table.insert(keys, {
    "<leader>" .. i,
    function()
      harpoon():list():select(i)
    end,
    desc = "Harpoon file " .. i,
  })
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = keys,
  config = function()
    require("harpoon"):setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    })
  end,
}
