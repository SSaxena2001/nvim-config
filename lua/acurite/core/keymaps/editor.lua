local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"0p')
keymap.set("n", "<Leader>P", '"0P')

-- Paste over a selection without clobbering the unnamed register, so the same
-- text can be pasted repeatedly. Only meaningful in visual/select mode.
keymap.set("x", "<Leader>p", '"_dP', { desc = "Paste over selection (keep register)" })

keymap.set("n", "<Leader>c", '"_c')
keymap.set("n", "<Leader>C", '"_C')
keymap.set("v", "<Leader>c", '"_c')
keymap.set("v", "<Leader>C", '"_C')
keymap.set("n", "<Leader>d", '"_d')
keymap.set("n", "<Leader>D", '"_D')
keymap.set("v", "<Leader>d", '"_d')
keymap.set("v", "<Leader>D", '"_D')

-- Move the selection up/down and reindent
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep the cursor centred while walking search results, and reopen any fold
-- the match landed inside.
keymap.set("n", "n", "nzzzv", { desc = "Next search match (centred)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search match (centred)" })

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

keymap.set("n", "<leader>bf", function()
  require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer" })

-- tmux-sessionizer in a new tmux window.
--
-- This used to be `<cmd>silent !tmux neww tmux-sessionizer<CR>`. Two problems
-- with that: `:!` suspends the UI and forces a full redraw on return, and
-- `silent` discards stderr, so every failure mode -- no tmux server, script
-- crash, binary not on $PATH -- looked identical to the key doing nothing at
-- all. Run it as a detached job instead and surface whatever tmux complains
-- about.
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

    -- tmux writes "no server running on ..." and friends to stderr.
    local msg = vim.trim((result.stderr or "") .. (result.stdout or ""))
    vim.schedule(function()
      vim.notify(
        "tmux-sessionizer failed (exit " .. result.code .. ")" .. (msg ~= "" and ": " .. msg or ""),
        vim.log.levels.ERROR
      )
    end)
  end)
end, { desc = "tmux sessionizer" })
