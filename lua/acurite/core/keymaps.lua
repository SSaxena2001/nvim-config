vim.g.mapleader = " "

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

keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

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
keymap.set("n", "te", ":tabedit<Return>", opts)
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

keymap.set("n", "<leader>bf", function()
  require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer" })

local function open_lazygit()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed or not in PATH", vim.log.levels.ERROR)
    return
  end

  local git_root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()

  local normal_float = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
  local title = vim.api.nvim_get_hl(0, { name = "FloatTitle", link = false })
  local info = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo", link = false })
  local float_bg = normal_float.bg or normal.bg or "NONE"
  local float_fg = normal_float.fg or normal.fg or "NONE"
  local border_fg = border.fg or info.fg or float_fg
  vim.api.nvim_set_hl(0, "LazyGitFloat", { fg = float_fg, bg = float_bg })
  vim.api.nvim_set_hl(0, "LazyGitBorder", { fg = border_fg, bg = float_bg })
  vim.api.nvim_set_hl(0, "LazyGitTitle", { fg = title.fg or info.fg or border_fg, bg = float_bg, bold = true })

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " lazygit ",
    title_pos = "center",
  })

  vim.bo[buf].bufhidden = "wipe"
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].winhighlight = table.concat({
    "Normal:LazyGitFloat",
    "NormalNC:LazyGitFloat",
    "EndOfBuffer:LazyGitFloat",
    "SignColumn:LazyGitFloat",
    "FloatBorder:LazyGitBorder",
    "FloatTitle:LazyGitTitle",
  }, ",")

  vim.fn.termopen("lazygit", {
    cwd = git_root,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })
  vim.cmd.startinsert()
end

keymap.set("n", "<leader>gg", open_lazygit, { desc = "Lazygit (git root)" })

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

keymap.set("n", "<leader>e", show_diagnostic_float, vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))

keymap.set("n", "<leader>i", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

keymap.set("i", "<C-h>", function()
  vim.lsp.buf.signature_help()
end, { desc = "Signature help" })
