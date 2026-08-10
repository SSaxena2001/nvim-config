-- snacks.nvim pickers and explorer. `Snacks` is the plugin's global, set by its
-- setup() in configs/snacks.lua, so these are resolved lazily inside callbacks.
local keymap = vim.keymap

local function picker()
  return require("snacks").picker
end

keymap.set("n", ";f", function()
  picker().files({ hidden = true, ignored = false })
end, { desc = "Find files" })

keymap.set("n", "<leader>fP", function()
  picker().files({ cwd = vim.fn.stdpath("config"), hidden = true, ignored = false })
end, { desc = "Find config file" })

keymap.set("n", ";r", function()
  picker().grep({ hidden = false, ignored = false, need_search = true, limit_live = 5000 })
end, { desc = "Live grep" })

keymap.set({ "n", "x" }, ";w", function()
  picker().grep_word({ hidden = false, ignored = false, limit_live = 5000 })
end, { desc = "Grep word or selection" })

keymap.set("n", "\\", function()
  picker().buffers()
end, { desc = "Buffers" })

keymap.set("n", ";t", function()
  picker().help()
end, { desc = "Help tags" })

keymap.set("n", ";;", function()
  picker().resume()
end, { desc = "Resume picker" })

keymap.set("n", ";e", function()
  picker().diagnostics()
end, { desc = "Diagnostics" })

keymap.set("n", ";s", function()
  picker().lsp_symbols()
end, { desc = "Document symbols" })

keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "File explorer" })

keymap.set("n", "sf", function()
  Snacks.explorer({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "File explorer at buffer path" })
