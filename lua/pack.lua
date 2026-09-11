-- Plugin installation via Neovim 0.12's built-in `vim.pack`. There is no
-- plugin manager here: vim.pack clones each repo into the site packpath and
-- Neovim's own `packadd` loads it. `:h vim.pack`
--
-- Plugins earn their place by doing something Neovim cannot, or by doing it
-- far better. Everything else -- completion, LSP, `:find` and `:grep`
-- themselves -- is handled by Neovim in the modules beside this one.

-- Build hooks. `vim.pack` clones a plugin and stops there -- it has no notion of
-- a build step -- so anything that ships native code has to be compiled here.
-- Registered before `vim.pack.add` below, because that call installs missing
-- plugins and fires `PackChanged` on the way; an autocmd created afterwards
-- would miss the install and only ever see later updates.
--
-- Async, both of them: these run on install and update only, and there is no
-- reason to hold up startup waiting for a compiler.
local builders = {
  -- `make install_jsregexp` builds the regex engine behind snippet
  -- transformations -- the tabstops that rewrite an earlier field rather than
  -- mirroring it. Without it those snippets error on expansion and the rest
  -- are unaffected, which is why LuaSnip treats it as optional and does not
  -- build it itself.
  LuaSnip = function(path)
    vim.system({ "make", "install_jsregexp" }, { cwd = path }, function(out)
      vim.schedule(function()
        if out.code == 0 then
          vim.notify("LuaSnip: jsregexp built", vim.log.levels.INFO)
        else
          vim.notify("LuaSnip: jsregexp build failed\n" .. (out.stderr or ""), vim.log.levels.ERROR)
        end
      end)
    end)
  end,

  -- fff is a Rust binary with a Lua shim over it, and the shim is useless
  -- without the binary. Its own downloader fetches a prebuilt one for this
  -- platform and falls back to `cargo build` when there is none.
  fff = function()
    require("fff.download").download_or_build_binary()
  end,
}

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("PackBuildHooks", { clear = true }),
  callback = function(e)
    local data = e.data
    local build = builders[data.spec.name]
    if not build or (data.kind ~= "install" and data.kind ~= "update") then
      return
    end

    -- A freshly installed plugin is not on the runtimepath yet, so anything
    -- that has to `require` its own Lua needs it added first.
    if not data.active then
      vim.cmd.packadd(data.spec.name)
    end
    build(data.path)
  end,
})

vim.pack.add({
  -- Neovim ships parsers for c, lua, markdown, query, vim and vimdoc only.
  -- Every other language needs nvim-treesitter to fetch and build one.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },

  -- The enclosing function/class pinned to the top of the window. Draws it in
  -- a float, which 'winbar' and the statusline cannot do, and works out what
  -- to name from the same parsers as above.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },

  -- Split a node onto several lines, or join it back onto one. Reads the same
  -- parsers as the two above, which is what lets it know where the separators
  -- and the trailing comma go -- `gq` and `J` only see lines and characters.
  { src = "https://github.com/Wansmer/treesj" },

  -- Colorscheme. Configured in lua/colorscheme.lua.
  { src = "https://github.com/craftzdog/solarized-osaka.nvim" },

  -- Previous colorschemes, kept installed to switch back to. Nothing sets
  -- either up: lua/colorscheme.lua loads solarized-osaka, which is a fork of
  -- tokyonight -- the two take the same options. The rose-pine repo is named
  -- `neovim`, which is what vim.pack would otherwise install it as, so `name`
  -- pins the directory to what `require("rose-pine")` expects.
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },

  -- Sign-column git hunks. No native equivalent.
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Git porcelain as Vim commands. The status buffer and `:Gdiffsplit` put
  -- git's state in real buffers, which lua/lazygit.lua's TUI cannot.
  { src = "https://github.com/tpope/vim-fugitive" },

  -- AI inline completion. No native equivalent.
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },

  -- Auto-close brackets, quotes and tags. Neovim has no built-in equivalent.
  { src = "https://github.com/windwp/nvim-autopairs" },

  -- Snippet engine. `vim.snippet` can expand an LSP snippet the server sends
  -- back, but it has no store of its own and no way to define one, so there is
  -- nothing to complete over until a plugin supplies the snippets.
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  -- The snippets themselves. LuaSnip ships an engine and zero content. Curated
  -- rather than exhaustive -- a few dozen per language, not the several hundred
  -- a bulk port of vim-snippets gives you, which only buries what the language
  -- server returned.
  { src = "https://github.com/rafamadriz/friendly-snippets" },

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

  -- Fuzzy file and content search. A Rust core holding its own file tree and
  -- content index, so repeated searches in one session beat shelling out to
  -- fd/rg per keystroke, and ranking is frecency- and git-aware rather than
  -- pure match order. Files and grep only -- the rest of the ";" prefix is
  -- native now: see lua/picker.lua. Built by the hook above.
  { src = "https://github.com/dmtrKovalenko/fff" },

  -- Popup listing what a half-typed prefix can still become. Neovim has no
  -- equivalent; the `desc` on every keymap here is what it reads.
  { src = "https://github.com/folke/which-key.nvim" },

  -- Quickfix styling, context lines and an editable quickfix buffer. This
  -- config routes grep, diagnostics and symbols through the quickfix list, so
  -- it is the window most of the pickers land in.
  { src = "https://github.com/stevearc/quicker.nvim" },

  -- `[`/`]` motions over buffers, comments, indent, jumps, undo states and
  -- more. Neovim ships a handful of these natively (`]c`, `]m`, `]s`) but only
  -- a handful, and each with its own quirks. The standalone module, not the
  -- mini.nvim monorepo: this one has its own repository.
  { src = "https://github.com/nvim-mini/mini.bracketed" },
})

-- Mason first: it puts the server binaries on $PATH that lua/lsp/ launches.
require("plugins.mason")
require("plugins.treesitter")
require("plugins.treesitter-context")
require("plugins.treesj")
require("plugins.gitsigns")
require("plugins.fugitive")
require("plugins.supermaven")
require("plugins.autopairs")
require("plugins.devicons")
require("plugins.oil")
require("plugins.quicker")
require("plugins.bracketed")
require("plugins.fff")
require("plugins.luasnip")
require("plugins.conform")
require("plugins.harpoon")
require("plugins.which-key")
