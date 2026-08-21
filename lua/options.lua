-- Options. Everything Neovim can do without a plugin is turned on here.

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

-- Folds follow the syntax tree. vim.treesitter.foldexpr returns 0 for any
-- buffer without a parser, so this degrades to "no folds" rather than
-- breaking. foldlevelstart keeps files opening fully unfolded -- `zc` folds
-- the node under the cursor when it is wanted.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevelstart = 99

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

-- Reload a buffer when the file changed underneath it and Neovim has no
-- unsaved edits of its own.
vim.opt.autoread = true

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

-- Deliberately no `shell` override. Neovim defaults it to $SHELL, which is the
-- login shell (zsh), and 'shell' is what :!, :terminal, system() and grepprg
-- all run through -- so it wants to stay POSIX-compatible and to follow the
-- shell actually in use rather than being pinned to one.

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
