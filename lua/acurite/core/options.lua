vim.g.mapleader = " "

vim.g.netrw_banner = 0

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Make sure filetype plugins, indent scripts, and Vim's syntax fallback are
-- enabled before opening the first buffer. Treesitter provides the main
-- highlighting, but this keeps TS/TSX files colored even if a parser is
-- missing or still installing.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

local function enable_js_ts_syntax_fallback(buf)
  local ft = vim.bo[buf].filetype
  if not vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, ft) then
    return
  end
  if vim.bo[buf].syntax == "" then
    vim.bo[buf].syntax = "ON"
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function(args)
    enable_js_ts_syntax_fallback(args.buf)
  end,
})

enable_js_ts_syntax_fallback(vim.api.nvim_get_current_buf())
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    enable_js_ts_syntax_fallback(vim.api.nvim_get_current_buf())
  end,
})

vim.opt.number = true
vim.opt.relativenumber = true

-- indentation
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true
vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.breakindent = true

-- search
vim.opt.inccommand = "split"
vim.opt.hlsearch = true
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.backspace = { "start", "eol", "indent" }
-- Avoid recursive `**` in 'path'; it can make commands like `gf` scan huge repos.
vim.opt.wildignore:append({ "*/node_modules/*", "*/.git/*", "*/dist/*", "*/build/*", "*/coverage/*" })

-- UI
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- folding
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldlevel = 99
vim.o.foldcolumn = "0"

-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- shell
vim.opt.shell = "fish"

-- misc
vim.opt.isfname:append("@-@")
vim.opt.colorcolumn = "0"
vim.opt.clipboard:append("unnamedplus")
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.mouse = ""
vim.o.guicursor = "n-v-c-sm:block,i:block"
vim.opt.updatetime = 250
vim.o.winborder = "rounded"
vim.opt.showcmd = true
vim.opt.termguicolors = true
vim.opt.completeopt = "menuone,noselect,fuzzy,nosort"
vim.opt.shortmess:append("c")

-- Hightlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Custom filetypes
vim.filetype.add({
  extension = {
    astro = "astro",
    h = "c",
    hh = "cpp",
    hpp = "cpp",
    hxx = "cpp",
    c = "c",
    cc = "cpp",
    cpp = "cpp",
    cxx = "cpp",
  },
  filename = { Podfile = "ruby" },
})

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })
