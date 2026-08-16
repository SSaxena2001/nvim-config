-- Options. Based on craftzdog's config, plus the handful of additions worth
-- keeping. Everything that was carrying its own weight elsewhere -- fold
-- settings, wildmenu tuning, completeopt, the JS/TS syntax fallback autocmds,
-- the long filetype table -- has been dropped.

vim.g.mapleader = " "

-- Mason installs its binaries here. Servers and formatters are launched by
-- name, so this has to be on $PATH before anything tries to start one.
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.termguicolors = true

-- Block cursor in every mode, as in ThePrimeagen's config.
vim.opt.guicursor = ""

vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }

-- "split" opens a preview window listing every match while a :s command is
-- being typed. This is the live substitution preview.
vim.opt.inccommand = "split"
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.backspace = { "start", "eol", "indent" }

-- Deliberately no `path:append("**")`. Recursive ** makes commands like `gf`
-- walk the entire repository.
vim.opt.wildignore:append({ "*/node_modules/*", "*/.git/*", "*/dist/*", "*/build/*" })

vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "cursor"

vim.opt.clipboard:append("unnamedplus")
vim.opt.mouse = ""
vim.opt.updatetime = 50
vim.opt.shell = "fish"
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })

vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
    astro = "astro",
  },
  filename = { Podfile = "ruby" },
})
