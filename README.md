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

Four, all with no native equivalent:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — Neovim ships parsers for
  only c/lua/markdown/query/vim/vimdoc
- `solarized-osaka.nvim` — colorscheme
- `gitsigns.nvim` — sign-column git hunks
- `supermaven-nvim` — AI inline completion

## External binaries

Language servers are launched by name off `$PATH`; there is no mason.

```
brew install lua-language-server gopls marksman llvm ripgrep lazygit stylua
npm i -g @typescript/native-preview vscode-langservers-extracted emmet-ls \
         @astrojs/language-server pyright prettier
uv tool install ruff
```
