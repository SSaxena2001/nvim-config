# nvim

Neovim config with no plugin manager. Structure follows
[smnatale/nvim_native](https://github.com/smnatale/nvim_native): everything
Neovim can do natively is done natively, and the handful of plugins that have
no built-in equivalent are installed by `vim.pack` (Neovim 0.12+).

## Layout

| Path | What |
|---|---|
| `init.lua` | Module load order |
| `lua/options.lua` | `vim.opt` settings |
| `lua/keymaps.lua` | Global keymaps |
| `lua/pack.lua` | `vim.pack.add` plugin list |
| `lua/plugins/` | Per-plugin setup |
| `lua/lsp/` | Native LSP: server configs, attach keymaps, diagnostics |
| `lua/find.lua` | `:find` via `findfunc` + `matchfuzzy` (replaces telescope) |
| `lua/grep.lua` | `grepprg=rg` into quickfix (replaces live_grep) |
| `lua/statusline.lua` | Hand-rolled statusline |
| `lua/formatting.lua` | `BufWritePre` shell formatter, LSP fallback |
| `lua/netrw.lua` | netrw settings |
| `lua/lazygit.lua` | lazygit in a terminal tab |

## Plugins

Six, all either without a native equivalent or required to install one:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — Neovim ships parsers for
  only c/lua/markdown/query/vim/vimdoc
- `solarized-osaka.nvim` — colorscheme
- `gitsigns.nvim` — sign-column git hunks
- `supermaven-nvim` — AI inline completion
- `mason.nvim` + `mason-tool-installer.nvim` — installs the language server and
  formatter binaries. Not an LSP layer: `vim.lsp.config`/`vim.lsp.enable` do
  that, and there is no nvim-lspconfig or mason-lspconfig.

## External binaries

Servers and formatters are installed by mason on first launch (see
`lua/plugins/mason.lua`) into `stdpath("data")/mason/bin`, which
`lua/options.lua` prepends to `$PATH`. `:Mason` opens the UI.

Not covered by mason, install these yourself:

```
brew install ripgrep lazygit
```
