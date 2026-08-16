-- Treesitter textobjects. Modules are required inside the callbacks so this
-- file does not pull nvim-treesitter-textobjects in at startup.
local keymap = vim.keymap

local function select(obj)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(obj, "textobjects")
  end
end

local function move(fn, obj)
  return function()
    require("nvim-treesitter-textobjects.move")[fn](obj, "textobjects")
  end
end

keymap.set({ "x", "o" }, "af", select("@function.outer"), { desc = "Select outer function" })
keymap.set({ "x", "o" }, "if", select("@function.inner"), { desc = "Select inner function" })
keymap.set({ "x", "o" }, "ac", select("@class.outer"), { desc = "Select outer class" })
keymap.set({ "x", "o" }, "ic", select("@class.inner"), { desc = "Select inner class" })
keymap.set({ "x", "o" }, "aa", select("@parameter.outer"), { desc = "Select outer argument/parameter" })
keymap.set({ "x", "o" }, "ia", select("@parameter.inner"), { desc = "Select inner argument/parameter" })

keymap.set({ "n", "x", "o" }, "]m", move("goto_next_start", "@function.outer"), { desc = "Next function start" })
keymap.set(
  { "n", "x", "o" },
  "[m",
  move("goto_previous_start", "@function.outer"),
  { desc = "Previous function start" }
)
keymap.set({ "n", "x", "o" }, "]M", move("goto_next_end", "@function.outer"), { desc = "Next function end" })
keymap.set({ "n", "x", "o" }, "[M", move("goto_previous_end", "@function.outer"), { desc = "Previous function end" })
keymap.set({ "n", "x", "o" }, "]]", move("goto_next_start", "@class.outer"), { desc = "Next class start" })
keymap.set({ "n", "x", "o" }, "[[", move("goto_previous_start", "@class.outer"), { desc = "Previous class start" })
keymap.set({ "n", "x", "o" }, "][", move("goto_next_end", "@class.outer"), { desc = "Next class end" })
keymap.set({ "n", "x", "o" }, "[]", move("goto_previous_end", "@class.outer"), { desc = "Previous class end" })
