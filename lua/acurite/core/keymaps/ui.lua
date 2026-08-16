local keymap = vim.keymap

-- Use quickfix directly (removed trouble.nvim)
keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix Item" })
keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix Item" })
