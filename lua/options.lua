-- Options. Everything Neovim can do without a plugin is turned on here.

-- Mason installs its binaries here. Servers and formatters are launched by
-- name, so this has to be on $PATH before anything tries to start one.
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

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
-- Two columns: gitsigns takes one, diagnostics the other. With a single
-- column the higher-priority sign wins and the other is invisible.
vim.opt.signcolumn = "yes:2"
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
vim.opt.ignorecase = true -- Case insensitive searching UNLESS \C or a capital
vim.opt.smartcase = true -- ... but a capital in the pattern makes it sensitive
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

-- lua/statusline.lua draws the mode, so Neovim's own -- INSERT -- line is
-- a second copy of it.
vim.opt.showmode = false
-- One statusline for the whole editor rather than one per window, drawn on the
-- row directly above the command line.
vim.opt.laststatus = 3
-- A row kept for the command line. `cmdheight = 0` reclaims it, but then there
-- is nowhere to draw a message, and Neovim raises a hit-enter prompt for each
-- one instead -- which is what typing felt like, since completion talks on
-- every keypress. Neovim also documents 0 as experimental.
vim.opt.cmdheight = 1

-- Completion narrates itself: "match 1 of 103" every time the popup opens,
-- plus the "scanning" notes under it. There is a row for that now, but it is
-- still a line of flicker reporting what the popup is already showing.
-- `c` and `C` silence those two groups (`:h shm-c`, `:h shm-C`) and leave
-- every other message alone.
vim.opt.shortmess:append("cC")

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
