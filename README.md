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
| `lua/picker.lua` | The `;` prefix — fzf-lua pickers |
| `lua/pack.lua` | `vim.pack.add` plugin list |
| `lua/plugins/` | Per-plugin setup |
| `lua/lsp.lua` | Native LSP: server configs, attach keymaps, diagnostics, completion |
| `lua/find.lua` | `findfunc` for `:find`, backed by ripgrep; honours `.gitignore` and skips build output |
| `lua/grep.lua` | `grepprg=rg`, `grepformat` |
| `lua/statusline.lua` | A plain `'statusline'` string |
| `lua/lazygit.lua` | lazygit in a terminal tab |

## Pickers

The `;` prefix, on fzf-lua. `<CR>` opens a single selection, `<C-q>` sends the
whole result set to the quickfix list, which quicker.nvim styles and makes
editable, and `;;` reopens it. `;f` lists the same files `:find` completes over
— both build their ripgrep invocation from `lua/find.lua`.

| Key | What |
|---|---|
| `;f` | Find files — project root, hidden included |
| `;P` | Find a file in this config |
| `;r` | Grep for a pattern |
| `;w` | Grep the word under the cursor, or the visual selection |
| `;g` | Files changed against HEAD, plus untracked |
| `;t` | Help tags |
| `;;` | Reopen the last quickfix list |
| `\` | Buffers |
| `;e` | Every diagnostic in the workspace |
| `;s` | Document symbols |

## Plugins

Seventeen, all either without a native equivalent or required to install one:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — Neovim ships parsers for
  only c/lua/markdown/query/vim/vimdoc. Highlighting starts on `FileType`; the
  parser list lives in `lua/plugins/treesitter.lua`.
  Folds come from the tree (`foldexpr`, see `lua/options.lua`).
- `rose-pine` + `vague.nvim` — colorschemes. Both stay installed; the `active`
  local at the top of `lua/colorscheme.lua` picks which one loads. rose-pine is
  on `moon`; `main` and the light `dawn` are one word away. Both run
  transparent, so the terminal's own background shows through.
- `nvim-autopairs` — auto-closes brackets, quotes and tags. Treesitter-aware,
  so it does not pair inside strings or comments.
- `fzf-lua` — the `;` pickers. LSP navigation is Neovim's own `vim.lsp.buf.*`,
  not a picker.
  Matching runs in the `fzf` binary and the file/grep providers run in a
  separate Neovim process, so it stays responsive on large trees. `:find` and
  `:grep` still work on their own underneath.
- `conform.nvim` — formatter dispatch on save, with an LSP fallback
- `harpoon` (branch `harpoon2`) + `plenary.nvim` — pinned files, jumped to by
  index
- `mason.nvim` + `mason-tool-installer.nvim` — installs the language server and
  formatter binaries. Not an LSP layer: `vim.lsp.config`/`vim.lsp.enable` do
  that, and there is no nvim-lspconfig or mason-lspconfig.
- `gitsigns.nvim` — git hunks in the sign column.
- `supermaven-nvim` — inline AI completion. Separate from the LSP completion
  `lua/lsp.lua` sets up.
- `oil.nvim` — the file explorer, as an editable buffer. Replaces netrw.
- `which-key.nvim` — popup listing what a half-typed prefix can still become.
  It reads the `desc` already on each keymap, so only the prefixes themselves
  are named, in `lua/plugins/which-key.lua`.
- `quicker.nvim` — quickfix styling, context lines, and an editable quickfix
  buffer. `<C-q>` from any picker lands here.
- `nvim-web-devicons` — filetype icons for oil and the fzf-lua pickers. Needs a
  Nerd Font in the terminal.

## External binaries

Servers and formatters are installed by mason on first launch (see
`lua/plugins/mason.lua`) into `stdpath("data")/mason/bin`, which
`lua/options.lua` prepends to `$PATH`. `:Mason` opens the UI.

Not covered by mason, install these yourself:

```
brew install ripgrep fzf lazygit
```
