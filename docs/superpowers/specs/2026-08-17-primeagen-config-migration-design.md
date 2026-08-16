# Migrating to a Primeagen-shaped config

**Date:** 2026-08-17
**Branch:** `perf-lightweight-config`
**Status:** awaiting review

## Goal

Restructure this Neovim config to follow ThePrimeagen's `init.lua` layout and
plugin manager, while keeping the keymaps, colorscheme and per-plugin configs
that are already tuned here. Replace netrw with `snacks.explorer`.

Reference config: <https://github.com/ThePrimeagen/init.lua> (branch `master`).

## Decisions

Every item below was chosen explicitly. Nothing here is a default.

| Question | Decision |
| --- | --- |
| Plugin manager | **Full swap to lazy.nvim.** `vim.pack` + `core/lazy.lua` are removed. |
| Directory layout | His layout under the `acurite` namespace. |
| Colorscheme | Keep solarized-osaka. His per-filetype colorscheme autocmd is dropped. |
| Keymaps | Keep all current ones. His are added only where the key is free. |
| LSP framework | Switch to `nvim-lspconfig` + `mason-lspconfig`. |
| LSP servers | Carry over all 12 currently configured. |
| LSP keymaps | Keep current ones. His `<leader>v*` set is dropped. |
| DAP | Take the whole stack, rebound to `<leader>d*`. |
| Neotest | Not taken. |
| cmp sources | Add `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`, `friendly-snippets`. |
| cmp mappings | Keep current ones. |
| Telescope | Keep current config, plus his `ts_highlighter` guard. |
| Treesitter | Keep current config, plus his `af`/`if` textobject keymaps. |
| conform | Keep current config. No format-on-save. |
| cloak | Keep current config. |
| LuaSnip | Take his config. |
| File explorer | `snacks.explorer` only. No other snacks modules. |
| Trailing-whitespace strip on save | Not taken. |
| `guicursor` | Take his (`""`, block cursor in every mode). |
| `undodir` | Keep current (`stdpath("data")/undodir`). |

### Cost accepted

The full swap discards `core/pack.lua`, `core/lazy.lua` and the deferred-loading
work that this branch's five commits exist to build. This was raised before the
choice was made and accepted. Startup will be slower than the current config.

## Plugin inventory

### Added from his config (14)

`mfussenegger/nvim-dap`, `rcarriga/nvim-dap-ui`, `leoluz/nvim-dap-go`,
`jay-babu/mason-nvim-dap.nvim`, `nvim-neotest/nvim-nio`,
`neovim/nvim-lspconfig`, `williamboman/mason-lspconfig.nvim`,
`hrsh7th/cmp-buffer`, `hrsh7th/cmp-path`, `hrsh7th/cmp-cmdline`,
`saadparwaiz1/cmp_luasnip`, `rafamadriz/friendly-snippets`,
`mbbill/undotree`, `j-hui/fidget.nvim`.

### Added new (2)

`folke/lazy.nvim` (manager), `folke/snacks.nvim` (explorer module only).

### Kept from the current config (21)

`cloak.nvim`, `conform.nvim`, `telescope.nvim`, `telescope-fzf-native.nvim`,
`telescope-ui-select.nvim`, `nvim-treesitter`, `nvim-treesitter-textobjects`,
`nvim-cmp`, `cmp-nvim-lsp`, `LuaSnip`, `gitsigns.nvim`, `diffview.nvim`,
`harpoon` (harpoon2), `which-key.nvim`, `mini.nvim`, `nvim-lint`,
`mason.nvim`, `mason-tool-installer.nvim`, `nvim-web-devicons`,
`plenary.nvim`, `solarized-osaka.nvim`.

### Removed

One plugin, `prichrd/netrw.nvim`. Four files: `configs/netrw.lua`,
`configs/netrw-help.lua`, `core/pack.lua`, `core/lazy.lua`.
`nvim-pack-lock.json` is replaced by `lazy-lock.json`.

### Deliberately not taken from his config

`neotest`, `neotest-golang`, `FixCursorHold.nvim`, `trouble.nvim`,
`zen-mode.nvim`, `cellular-automaton.nvim`, `peek.nvim`, `vim-be-good`,
`golf`, `jai.vim`, `php.nvim`, `vim-fugitive`, his four colorschemes
(`gruvbox`, `brightburn`, `tokyonight`, `rose-pine`), and his local
development plugins `55`, `99` and `harpoon` (which live in `~/personal/`
and cannot transfer).

## Target layout

```
init.lua                      -> require("acurite")
lua/acurite/init.lua          -> set, remap, lazy_init + autocmds
lua/acurite/lazy_init.lua     -> lazy.nvim bootstrap
lua/acurite/set.lua           <- current core/options.lua
lua/acurite/remap.lua         <- current core/keymaps/* merged
lua/acurite/lazy/
    colors.lua      solarized-osaka
    snacks.lua      explorer only
    telescope.lua   + fzf-native, ui-select, ts_highlighter guard
    treesitter.lua  28 parsers, query guard, af/if textobjects
    lsp.lua         lspconfig + mason-lspconfig + cmp wiring
    completion.lua  cmp mappings and sources
    snippets.lua    LuaSnip (his config) + friendly-snippets
    conform.lua     current formatter mapping
    lint.lua        nvim-lint
    dap.lua         full stack, <leader>d* keymaps
    git.lua         gitsigns + diffview
    harpoon.lua     harpoon2 + current keymaps
    cloak.lua       current patterns
    which-key.lua   current groups
    mini.lua        current modules
    undotree.lua    <leader>u
    fidget.lua      LSP progress
    mason.lua       mason + mason-tool-installer (21 tools)
```

`plugin/supermaven-local.lua` is untouched. It loads from
`site/pack/local/opt` via `packadd` and never involved `vim.pack`, so it
survives the manager swap unchanged and stays out of git.

## Keymap resolution

Current keymaps always win. His are added only on free keys.

**Added (currently unbound):** `J`/`K` visual line move, `<leader>p` paste
keeping register, `<leader>y` yank to system clipboard, `<leader>s` substitute
word under cursor, `Q` to `<nop>`, `<C-d>`/`<C-u>` recentre, `J` normal-mode
join keeping cursor.

**Rebound to avoid collisions:**

| His key | Collides with | Moved to |
| --- | --- | --- |
| `<leader>b` breakpoint | `<leader>b` buffer group prefix | `<leader>db` |
| `<leader>B` cond. breakpoint | same prefix | `<leader>dB` |

**Dropped:** his `<leader>v*` LSP set, his `<leader>p*` Telescope set, his
`<C-p>`/`<C-n>`/`<C-y>` cmp mappings. All duplicate existing bindings.

**Unchanged:** `<C-f>` tmux-sessionizer, `<leader>e` explorer (now snacks),
all `;`-prefixed pickers, all `<leader>l*` LSP maps, harpoon maps.

## Landmines to strip when porting

1. `require("conform").setup({ formatters_by_ft = {} })` inside his `lsp.lua`
   would blank the formatter mapping. Remove the call.
2. `autocmd BufEnter -> colorscheme rose-pine-moon / tokyonight-night` would
   override solarized-osaka on every buffer enter. Remove.
3. `autocmd BufWritePre * %s/\s\+$//e` strips trailing whitespace repo-wide.
   Not taken.
4. His `cmp` sources list declares a `copilot` source with no provider plugin
   installed. Do not copy; it is the same dead-source bug being fixed here.
5. His Telescope is pinned to tag `0.1.5`. Do not pin; track the current
   release so fzf-native and ui-select keep working.

## Verification plan

Each step verified headlessly before moving on.

1. `nvim --headless -c 'qa!'` exits clean with no messages.
2. `:Lazy` reports every plugin installed, no failures.
3. `vim.lsp.get_clients()` attaches for each of the 12 servers on a matching
   buffer.
4. `require("cmp").get_registered_sources()` lists `nvim_lsp`, `luasnip`,
   `buffer`, `path` — the bug that motivated this section.
5. `mason_tools.first_missing()` returns `nil`.
6. `<leader>e` opens snacks.explorer; netrw no longer loads.
7. Every keymap in the resolution table above resolves via `maparg`.
8. `:DapContinue` loads the stack without error.
9. Startup time measured with `--startuptime` before and after, recorded here.

## Rollback

All current work is committed at `28dad82` on `perf-lightweight-config`. The
migration happens on a new branch so `git checkout perf-lightweight-config`
restores the working config at any point.
