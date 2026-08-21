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
| `lua/picker.lua` | The `;` prefix — what telescope used to cover |
| `lua/pack.lua` | `vim.pack.add` plugin list |
| `lua/plugins/` | Per-plugin setup |
| `lua/lsp/` | Native LSP: server configs, attach keymaps, diagnostics |
| `lua/find.lua` | `findfunc` for `:find`, backed by ripgrep |
| `lua/grep.lua` | `grepprg=rg`, `grepformat` |
| `lua/statusline.lua` | Hand-rolled statusline, coloured from the active theme's palette |
| `lua/lazygit.lua` | lazygit in a terminal tab |

## Pickers

The `;` prefix, rebuilt on `:find`, `:grep`, the quickfix list and the LSP
handlers. quicker.nvim styles the quickfix window most of them land in.

| Key | What |
|---|---|
| `;f` | Find files — project root, hidden included |
| `;P` | Find a file in this config |
| `;r` | Grep for a pattern |
| `;w` | Grep the word under the cursor, or the visual selection |
| `;g` | Files changed against HEAD, plus untracked |
| `;t` | Help tags |
| `;;` | Reopen the last quickfix list |
| `;e` | Every diagnostic in the workspace |
| `;s` | Document symbols |
| `\` | Buffers |

## Plugins

Eleven, all either without a native equivalent or required to install one:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — Neovim ships parsers for
  only c/lua/markdown/query/vim/vimdoc. Highlighting starts on `FileType`, and
  a filetype whose parser is missing but buildable is installed on the spot.
  Folds come from the tree (`foldexpr`, see `lua/options.lua`).
- `monokai-nightasty.nvim` — colorscheme, active. Dark style with a
  transparent background; floats and sidebars stay opaque. There is no
  "vibrant" variant in this plugin.
- `rose-pine` — colorscheme, installed but not active. Swap the
  `vim.cmd.colorscheme` call in `lua/colorscheme.lua`; the statusline reads
  whichever is live.
- `gitsigns.nvim` — sign-column git hunks
- `supermaven-nvim` — AI inline completion
- `nvim-web-devicons` — filetype glyphs for oil's icon column and the
  statusline. Needs a Nerd Font in the terminal.
- `oil.nvim` — the file explorer as an editable buffer. Registered as the
  default file explorer, so `nvim .` and `:e src/` open it. `-` walks to the
  parent directory, `<leader>e` opens a float. netrw is not configured.
- `quicker.nvim` — quickfix styling, context lines (`>` / `<` inside the
  quickfix window) and an editable quickfix buffer
- `conform.nvim` — formatter dispatch on save, with an LSP fallback
- `harpoon` (branch `harpoon2`) + `plenary.nvim` — pinned files, jumped to by
  index
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
