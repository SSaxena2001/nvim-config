-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"0p')
keymap.set("n", "<Leader>P", '"0P')
keymap.set("v", "<Leader>p", '"0p')
keymap.set("n", "<Leader>c", '"_c')
keymap.set("n", "<Leader>C", '"_C')
keymap.set("v", "<Leader>c", '"_c')
keymap.set("v", "<Leader>C", '"_C')
keymap.set("n", "<Leader>d", '"_d')
keymap.set("n", "<Leader>D", '"_D')
keymap.set("v", "<Leader>d", '"_d')
keymap.set("v", "<Leader>D", '"_D')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.get_next()
end, opts)

keymap.set("n", "<leader>i", function()
  require("craftzdog.lsp").toggleInlayHints()
end)

keymap.set("n", "gt", function()
  vim.cmd("tab split")
  local Snacks = require("snacks")
  Snacks.picker.lsp_definitions()
end, {})

keymap.set("i", "<C-h>", function()
  vim.lsp.buf.signature_help()
end, {})

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

keymap.set("n", ";s", function()
  -- Open telescope lsp_references picker
  require("telescope.builtin").lsp_references({
    attach_mappings = function(prompt_bufnr, map)
      -- Map <CR> in picker to open in new tab
      map("i", "<CR>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not selection then
          return
        end
        -- Open file in new tab at line and column
        vim.cmd("tabnew " .. selection.filename)
        vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
      end)
      return true
    end,
  })
end, { desc = "LSP references picker - enter to open in new tab" })
