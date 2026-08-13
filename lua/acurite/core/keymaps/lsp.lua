local keymap = vim.keymap
local opts = { noremap = true, silent = true }

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
end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

keymap.set("n", "[d", function()
  diagnostic_jump(-1)
end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))

keymap.set("n", "<C-j>", function()
  diagnostic_jump(1)
end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

-- Was <leader>e, which the file explorer also claimed. The
-- explorer won because it loaded last, leaving this one dead.
keymap.set("n", "<leader>ld", show_diagnostic_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))

keymap.set("n", "<leader>i", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- Signature help is Nvim's built-in insert-mode <C-s>; no mapping needed here.
-- gd / gt are buffer-local and live in configs/lsp/attach.lua so Vim's own
-- gd and gt keep working where no server is attached.

-- Capture the configured table once. `not current` would collapse it to a
-- bare boolean and lose spacing/source/prefix from the second press onward.
local virtual_text_opts = vim.diagnostic.config().virtual_text

keymap.set("n", "<leader>lx", function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = current and false or virtual_text_opts })
end, { desc = "Toggle LSP virtual text" })

keymap.set("n", "<leader>lc", function()
  vim.cmd("checkhealth vim.lsp")
end, { desc = "LSP info" })

-- Trouble's LSP views. These sat under <leader>c, which collides with the
-- <leader>c blackhole-change operator in editor.lua.
keymap.set("n", "<leader>ls", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols (Trouble)" })
keymap.set("n", "<leader>lS", "<cmd>Trouble lsp toggle<cr>", { desc = "LSP references/definitions (Trouble)" })
