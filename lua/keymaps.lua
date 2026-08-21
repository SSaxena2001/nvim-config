-- Global keymaps. Keymaps that only make sense next to a feature live with it:
-- lua/find.lua, lua/grep.lua, lua/lazygit.lua, lua/lsp/attach.lua,
-- lua/plugins/treesitter.lua.

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Registers --------------------------------------------------------------
-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"0p')
keymap.set("n", "<Leader>P", '"0P')

-- Paste over a selection without clobbering the unnamed register, so the same
-- text can be pasted repeatedly.
keymap.set("x", "<Leader>p", '"_dP', { desc = "Paste over selection (keep register)" })

keymap.set({ "n", "v" }, "<Leader>c", '"_c')
keymap.set({ "n", "v" }, "<Leader>C", '"_C')
-- Blackhole delete is visual-mode only: normal-mode <leader>d is the
-- diagnostics-to-quickfix map below. <leader>D still covers normal mode.
keymap.set("v", "<Leader>d", '"_d')
keymap.set({ "n", "v" }, "<Leader>D", '"_D')

-- Movement ---------------------------------------------------------------
-- Move the selection up/down and reindent
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join without moving the cursor to the join point.
keymap.set("n", "J", "mzJ`z")

-- Keep the cursor centred while scrolling and while walking search results,
-- reopening any fold the match landed inside.
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv", { desc = "Next search match (centred)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search match (centred)" })

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- Editing ----------------------------------------------------------------
keymap.set("i", "<C-c>", "<Esc>")

-- Ex mode is never what anyone wants.
keymap.set("n", "Q", "<nop>")

-- Increment/decrement. `-` belongs to oil (open parent directory), so
-- decrement moves one key over.
keymap.set("n", "+", "<C-a>")
keymap.set("n", "<Leader>-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Open a line without continuing comments
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Substitute within the visual selection
keymap.set("v", "<leader>s", [[:s/\%V]])

-- Substitute the word under the cursor everywhere
keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word" })

-- Windows ----------------------------------------------------------------
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- <C-l> is also supermaven's accept_suggestion, but that binding is insert
-- mode only, so the two never collide.
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Quickfix ---------------------------------------------------------------
keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix item" })
keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next quickfix item" })

keymap.set("n", "<leader>q", function()
  require("quicker").toggle()
end, { desc = "Toggle quickfix" })

-- Diagnostics ------------------------------------------------------------
local diagnostic_float_opts = {
  border = "rounded",
  focusable = false,
  scope = "cursor",
  source = true,
  header = "",
  prefix = "",
}

local function show_diagnostic_float()
  vim.diagnostic.open_float(nil, diagnostic_float_opts)
end

local function diagnostic_jump(count)
  vim.diagnostic.jump({ count = count })
  vim.defer_fn(show_diagnostic_float, 50)
end

keymap.set("n", "]d", function()
  diagnostic_jump(1)
end, { desc = "Next diagnostic" })

keymap.set("n", "[d", function()
  diagnostic_jump(-1)
end, { desc = "Previous diagnostic" })

keymap.set("n", "<leader>ld", show_diagnostic_float, { desc = "Line diagnostics" })

keymap.set("n", "<leader>d", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { silent = true, desc = "Diagnostics to quickfix" })

keymap.set("n", "<leader>i", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- File explorer ----------------------------------------------------------
-- oil edits a directory as a buffer. `-` walks to the parent directory, which
-- is the usual way in; <leader>e opens the same thing in a float. netrw is
-- gone -- oil is registered as the default file explorer in
-- lua/plugins/oil.lua, so `nvim .` and `:e src/` open it too.
keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

keymap.set("n", "<leader>e", function()
  require("oil").toggle_float()
end, { desc = "File explorer (float)" })

-- tmux -------------------------------------------------------------------
-- Run tmux-sessionizer in a new tmux window. Deliberately not
-- `<cmd>silent !...<CR>`: `:!` suspends the UI and forces a redraw, and
-- `silent` discards stderr, so a dead tmux server or a missing binary would be
-- indistinguishable from the key doing nothing.
keymap.set("n", "<C-f>", function()
  if vim.fn.executable("tmux") == 0 then
    vim.notify("tmux is not on $PATH", vim.log.levels.ERROR)
    return
  end

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
      vim.notify(
        "tmux-sessionizer failed (exit " .. result.code .. ")" .. (msg ~= "" and ": " .. msg or ""),
        vim.log.levels.ERROR
      )
    end)
  end)
end, { desc = "tmux sessionizer" })
