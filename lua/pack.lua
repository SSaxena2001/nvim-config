-- Plugin installation via Neovim 0.12's built-in `vim.pack`. There is no
-- plugin manager here: vim.pack clones each repo into the site packpath and
-- Neovim's own `packadd` loads it. `:h vim.pack`
--
-- Plugins earn their place by doing something Neovim cannot, or by doing it
-- far better. Everything else -- completion, LSP, `:find` and `:grep`
-- themselves -- is handled by Neovim in the modules beside this one.
vim.pack.add({
  -- Neovim ships parsers for c, lua, markdown, query, vim and vimdoc only.
  -- Every other language needs nvim-treesitter to fetch and build one.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },

  -- The enclosing function/class pinned to the top of the window. Draws it in
  -- a float, which 'winbar' and the statusline cannot do, and works out what
  -- to name from the same parsers as above.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },

  -- Colorscheme. Configured in lua/colorscheme.lua. The repo is named
  -- `neovim`, which is what vim.pack would otherwise install it as, so `name`
  -- pins the directory to what `require("rose-pine")` expects.
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },

  -- Previous colorscheme, kept installed to switch back to. Nothing sets it
  -- up: lua/colorscheme.lua loads rose-pine.
  { src = "https://github.com/craftzdog/solarized-osaka.nvim" },

  -- Sign-column git hunks. No native equivalent.
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Git porcelain as Vim commands. The status buffer and `:Gdiffsplit` put
  -- git's state in real buffers, which lua/lazygit.lua's TUI cannot.
  { src = "https://github.com/tpope/vim-fugitive" },

  -- AI inline completion. No native equivalent.
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },

  -- Auto-close brackets, quotes and tags. Neovim has no built-in equivalent.
  { src = "https://github.com/windwp/nvim-autopairs" },

  -- Formatter dispatch on save, with an LSP fallback. Replaces the hand-rolled
  -- BufWritePre autocmd this config used to carry.
  { src = "https://github.com/stevearc/conform.nvim" },

  -- Pinned files, jumped to by index. Needs plenary.
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },

  -- Installer for language server and formatter binaries. Not an LSP layer:
  -- see lua/plugins/mason.lua.
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

  -- Filetype icons. Needed by oil's icon column; requires a
  -- Nerd Font in the terminal.
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- File explorer as an editable buffer. Replaces netrw.
  { src = "https://github.com/stevearc/oil.nvim" },

  -- Fuzzy picker. Matching runs in the fzf binary and the file/grep providers
  -- run in a separate Neovim process, so it stays responsive where an
  -- in-process Lua matcher would not. Sits on top of the native layer rather
  -- than replacing it: see lua/picker.lua.
  { src = "https://github.com/ibhagwan/fzf-lua" },

  -- Popup listing what a half-typed prefix can still become. Neovim has no
  -- equivalent; the `desc` on every keymap here is what it reads.
  { src = "https://github.com/folke/which-key.nvim" },

  -- 'statuscolumn' with the sign, fold and wrapped-line handling worked out.
  -- The whole of mini.nvim for one module is the only way to get it: unlike
  -- the rest of the family, mini.statuscolumn has no standalone repository
  -- yet. Nothing else in here runs -- a mini module does nothing until its own
  -- setup() is called, and lua/plugins/statuscolumn.lua calls exactly one.
  { src = "https://github.com/echasnovski/mini.nvim" },

  -- Quickfix styling, context lines and an editable quickfix buffer. This
  -- config routes grep, diagnostics and symbols through the quickfix list, so
  -- it is the window most of the pickers land in.
  { src = "https://github.com/stevearc/quicker.nvim" },
})

-- Mason first: it puts the server binaries on $PATH that lua/lsp/ launches.
require("plugins.mason")
require("plugins.treesitter")
require("plugins.treesitter-context")
require("plugins.gitsigns")
require("plugins.fugitive")
require("plugins.supermaven")
require("plugins.devicons")
require("plugins.oil")
require("plugins.statuscolumn")
require("plugins.quicker")
require("plugins.fzf")
require("plugins.autopairs")
require("plugins.conform")
require("plugins.harpoon")
require("plugins.which-key")
