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

  -- Colorscheme.
  { src = "https://github.com/craftzdog/solarized-osaka.nvim" },

  -- Sign-column git hunks. No native equivalent.
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- AI inline completion. No native equivalent.
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },

  -- Installer for language server and formatter binaries. Not an LSP layer:
  -- see lua/plugins/mason.lua.
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

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
require("plugins.oil")
require("plugins.quicker")
