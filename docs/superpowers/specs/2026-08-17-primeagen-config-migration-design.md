# Migrating to a Primeagen-shaped config

**Date:** 2026-08-17
**Branch:** `primeagen-migration`
**Status:** implemented and verified

## Goal

Restructure this Neovim config to follow ThePrimeagen's `init.lua` layout and
plugin manager, keeping the keymaps, colorscheme and per-plugin configuration
already tuned here, and stripping everything that was not earning its place.

References:

- <https://github.com/ThePrimeagen/init.lua> (layout, plugin manager, remaps)
- <https://github.com/craftzdog/dotfiles-public> (options baseline)

## Decisions

| Question | Decision |
| --- | --- |
| Plugin manager | Full swap to lazy.nvim. `vim.pack` and `core/lazy.lua` removed. |
| Directory layout | His layout under the `acurite` namespace. |
| Colorscheme | solarized-osaka, kept verbatim including local tuning. |
| Keymaps | All current ones kept. His added only where the key was free. |
| LSP framework | Native `vim.lsp.config` / `vim.lsp.enable`. No lspconfig, no mason-lspconfig. |
| LSP servers | All 12 kept. |
| LSP keymaps | Current ones kept. His `<leader>v*` set dropped. |
| DAP | Cut entirely as bloat. |
| Neotest | Not taken. |
| cmp sources | `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`, `friendly-snippets` added. |
| cmp mappings | Current ones kept. |
| Telescope | Current config kept, plus his `ts_highlighter` guard. |
| Treesitter | Current parser list kept, plus his `af`/`if` textobjects. |
| conform | Current config kept. |
| cloak | Current config kept. |
| LuaSnip | His config taken. |
| File explorer | **netrw**, with icons and the `<leader>e` toggle. snacks.nvim rejected. |
| Options | craftzdog's set plus a short list of keepers. |
| Trailing-whitespace strip on save | Not taken. |
| `guicursor` | His (`""`). |
| `undodir` | Current (`stdpath("data")/undodir`). |
| `inccommand` | `split` (craftzdog's), which is the live substitution preview. |

## Plugin inventory

28 plugins, down from 37.

**Added:** `lazy.nvim`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`,
`friendly-snippets`.

**Kept:** `solarized-osaka.nvim`, `telescope.nvim`, `telescope-fzf-native.nvim`,
`telescope-ui-select.nvim`, `nvim-treesitter`, `nvim-treesitter-textobjects`,
`nvim-cmp`, `cmp-nvim-lsp`, `LuaSnip`, `conform.nvim`, `nvim-lint`,
`cloak.nvim`, `gitsigns.nvim`, `diffview.nvim`, `harpoon`, `which-key.nvim`,
`mini.nvim`, `mason.nvim`, `mason-tool-installer.nvim`, `netrw.nvim`,
`nvim-web-devicons`, `plenary.nvim`.

**Cut as bloat:** the DAP stack (`nvim-dap`, `nvim-dap-ui`, `nvim-dap-go`,
`mason-nvim-dap`, `nvim-nio`), `fidget.nvim`, `undotree`, `nvim-lspconfig`,
`mason-lspconfig.nvim`, `snacks.nvim`.

**Not taken from his config:** neotest and its adapters, `FixCursorHold`,
`trouble.nvim`, `zen-mode.nvim`, `cellular-automaton.nvim`, `peek.nvim`,
`vim-be-good`, `golf`, `jai.vim`, `php.nvim`, `vim-fugitive`, his four
colorschemes, and his local `~/personal/` plugins (`55`, `99`, `harpoon`).

## Layout

```
init.lua                     -> require("acurite")
lua/acurite/init.lua         -> set, remap, lazy_init, autocmds
lua/acurite/lazy_init.lua    -> lazy.nvim bootstrap
lua/acurite/set.lua          -> options
lua/acurite/remap.lua        -> global keymaps
lua/acurite/lazy/            -> one file per plugin group
    init.lua colors.lua telescope.lua treesitter.lua
    cmp.lua lsp.lua editor.lua git.lua harpoon.lua netrw.lua
lua/acurite/lsp/             -> native server definitions (12 servers)
lua/acurite/{lint,mini,whichkey,lazygit,netrw-help}.lua
```

`plugin/supermaven-local.lua` stays untracked and outside lazy.nvim.

## Bugs found and fixed

1. **Dead cmp sources.** `buffer`, `path` and `luasnip` were declared in the
   sources list but no providing plugin was installed, so they contributed
   nothing. Fixed by adding `cmp-buffer`, `cmp-path` and `cmp_luasnip`.
2. **Mason binaries off `$PATH`.** The `mason/bin` prepend lived in the deleted
   `core/pack.lua`; without it no server or formatter could start. Restored in
   `set.lua`.
3. **LSP never attached to the triggering buffer.** `vim.lsp.enable()` installs
   a `FileType` hook, but that event had already fired for the buffer that
   caused the LSP module to load. Fixed by re-firing it for that buffer.
4. **lazy.nvim rewrites `packpath`.** This broke `:packadd` for the local
   Supermaven checkout (`E919`). Fixed by restoring the site directory before
   the `packadd`, and setting `performance.rtp.reset = false`.
5. **`mini.nvim` checkout failure.** `version = "stable"` is a `vim.pack`
   concept; lazy.nvim tried to parse it as a semver range and errored.
6. **`jsonc` is not a treesitter parser.** Removed from the parser list.

## Verification

All checks run headlessly against the built config.

| Check | Result |
| --- | --- |
| Startup messages | empty |
| Startup time | 16.2 ms mean over 10 runs |
| Plugins installed | 28, no failures |
| Keymaps probed | 26 of 26 present |
| Treesitter parsers | 37 installed, highlighting active |
| LSP: lua | `lua_ls` |
| LSP: typescript | `tsgo` |
| LSP: python | `pyright`, `ruff` |
| cmp sources registered | `nvim_lsp`, `luasnip`, `buffer`, `path`, `cmdline` |
| conform formatters | stylua, prettierd, prettier, shfmt, clang-format all available |
| netrw explorer | opens, 21 icon extmarks rendered |
| Supermaven | loads on InsertEnter, `<C-l>` accept bound |

## Rollback

`git checkout perf-lightweight-config` restores the previous config at
`5635f90`.
