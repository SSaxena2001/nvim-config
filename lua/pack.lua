-- Plugin installation via Neovim 0.12's built-in `vim.pack`. There is no
-- plugin manager here: vim.pack clones each repo into the site packpath and
-- Neovim's own `packadd` loads it. `:h vim.pack`
--
-- Only plugins with no native equivalent live here. Everything else -- fuzzy
-- file finding, grep, completion, LSP, statusline, formatting, the file
-- explorer -- is handled by Neovim itself in the modules beside this one.
vim.pack.add({
  -- Neovim ships parsers for c, lua, markdown, query, vim and vimdoc only.
  -- Every other language needs nvim-treesitter to fetch and build one.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },

  -- Colorscheme. `name` is set because the repo is called "neovim", which
  -- would otherwise be the plugin's directory and require() name.
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },

  -- Sign-column git hunks. No native equivalent.
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

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

  -- Filetype icons. Needed by oil's icon column and the statusline; requires a
  -- Nerd Font in the terminal.
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- File explorer as an editable buffer. Replaces netrw.
  { src = "https://github.com/stevearc/oil.nvim" },

  -- Quickfix styling, context lines and an editable quickfix buffer. This
  -- config routes grep, diagnostics and symbols through the quickfix list, so
  -- it is the window most of the pickers land in.
  { src = "https://github.com/stevearc/quicker.nvim" },
})

-- Mason first: it puts the server binaries on $PATH that lua/lsp/ launches.
require("plugins.mason")
require("plugins.treesitter")
require("plugins.gitsigns")
require("plugins.supermaven")
require("plugins.devicons")
require("plugins.oil")
require("plugins.quicker")
require("plugins.autopairs")
require("plugins.conform")
require("plugins.harpoon")
