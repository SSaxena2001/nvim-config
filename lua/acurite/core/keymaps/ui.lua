local keymap = vim.keymap

keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Zen Mode" })
keymap.set("n", "<leader>u", "<cmd>Atone toggle<CR>", { desc = "Toggle Atone" })
keymap.set("n", "<leader>tc", "<cmd>TSContext toggle<cr>", { desc = "Toggle Treesitter context" })

-- These plugins are deferred off the runtimepath (see core/lazy.lua), so a
-- bare require() errors until their trigger has fired. Guard every one.
keymap.set("n", "<leader>mr", function()
  local ok, render_markdown = pcall(require, "render-markdown")
  if not ok then
    vim.notify("render-markdown loads on markdown buffers", vim.log.levels.WARN)
    return
  end
  render_markdown.toggle()
end, { desc = "Toggle markdown render" })

-- Trouble lists. The LSP-flavoured Trouble views live in keymaps/lsp.lua under
-- the <leader>l group.
keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
keymap.set(
  "n",
  "<leader>xX",
  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  { desc = "Buffer Diagnostics (Trouble)" }
)
keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })

-- Trouble is deferred, so it is normally not loaded when these are pressed.
-- A failed require must fall through to the quickfix list, not error.
local function trouble_or_quickfix(trouble_fn, qf_cmd)
  return function()
    local ok, trouble = pcall(require, "trouble")
    if ok and trouble.is_open() then
      trouble[trouble_fn]({ skip_groups = true, jump = true })
      return
    end

    local ran, err = pcall(qf_cmd)
    if not ran then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

keymap.set("n", "[q", trouble_or_quickfix("prev", vim.cmd.cprev), { desc = "Previous Trouble/Quickfix Item" })
keymap.set("n", "]q", trouble_or_quickfix("next", vim.cmd.cnext), { desc = "Next Trouble/Quickfix Item" })
