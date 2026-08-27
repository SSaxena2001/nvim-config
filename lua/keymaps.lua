-- Global keymaps. Keymaps that only make sense next to a feature live with it:
-- lua/find.lua, lua/grep.lua, lua/lazygit.lua, lua/lsp.lua, lua/picker.lua,
-- lua/plugins/treesitter.lua.

local map = vim.keymap.set

-- Registers --------------------------------------------------------------
-- Paste over a selection without clobbering the unnamed register, so the same
-- text can be pasted repeatedly.
map("x", "<leader>p", '"_dP', { desc = "Paste over selection (keep register)" })

map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete to blackhole" })

-- Movement ---------------------------------------------------------------
-- Move the selection up/down and reindent
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Join without moving the cursor to the join point.
map("n", "J", "mzJ`z")

-- Keep the cursor centred while scrolling and while walking search results,
-- reopening any fold the match landed inside.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Editing ----------------------------------------------------------------
map("i", "<C-c>", "<Esc>")

-- Ex mode is never what anyone wants.
map("n", "Q", "<nop>")

-- Substitute the word under the cursor everywhere
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word" })

-- `%:S` and not a bare `%`: the filename goes straight into a shell command,
-- so one with a space in it would arrive as two arguments and chmod would fail
-- on both.
map("n", "<leader>x", "<cmd>!chmod +x %:S<CR>", { silent = true, desc = "chmod +x this file" })

-- Windows ----------------------------------------------------------------
-- <C-l> is also supermaven's accept_suggestion, but that binding is insert
-- mode only, so the two never collide.
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Quickfix ---------------------------------------------------------------
map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix item" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix item" })

map("n", "<leader>q", function()
  require("quicker").toggle()
end, { desc = "Toggle quickfix" })

map("n", "<leader>d", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { silent = true, desc = "Diagnostics to quickfix" })

map("n", "<leader>i", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- File explorer ----------------------------------------------------------
-- oil edits a directory as a buffer, in a normal window -- there is no
-- sidebar. <leader>e opens the directory holding the current file, <leader>E
-- opens :pwd. Both toggle: pressing again from inside oil closes it.
map("n", "<leader>e", function()
  require("plugins.oil").toggle_oil()
end, { desc = "Oil: parent directory" })

map("n", "<leader>E", function()
  require("plugins.oil").toggle_oil(".")
end, { desc = "Oil: current directory" })

-- tmux -------------------------------------------------------------------
-- Deliberately not `<cmd>silent !...<CR>`: `:!` suspends the UI and forces a
-- redraw, and `silent` discards stderr, so a dead tmux server or a missing
-- binary would be indistinguishable from the key doing nothing.
map("n", "<C-f>", function()
  if vim.fn.executable("tmux-sessionizer") == 0 then
    vim.notify("tmux-sessionizer is not on $PATH", vim.log.levels.ERROR)
    return
  end
  vim.system({ "tmux", "neww", "tmux-sessionizer" }, { text = true }, function(result)
    if result.code == 0 then
      return
    end
    local msg = vim.trim((result.stderr or "") .. (result.stdout or ""))
    vim.schedule(function()
      vim.notify("tmux-sessionizer failed (exit " .. result.code .. ") " .. msg, vim.log.levels.ERROR)
    end)
  end)
end, { desc = "tmux sessionizer" })
