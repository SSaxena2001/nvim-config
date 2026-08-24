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
| `lua/find.lua` | `findfunc` for `:find`, backed by fd (ripgrep, then a glob, as fallbacks); honours `.gitignore` and skips build output |
| `lua/grep.lua` | `grepprg=rg`, `grepformat` |
| `lua/lazygit.lua` | lazygit in a terminal tab |

## Pickers

The `;` prefix, on fzf-lua. `<CR>` opens a single selection, `<C-q>` sends the
whole result set to the quickfix list, which quicker.nvim styles and makes
editable, and `;;` reopens it. `;f` searches from the project root that
`lua/find.lua` resolves, the same root `:find` uses; the listing itself is left
to fzf-lua, which already prefers fd and streams it from a separate process.

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

## Completion

Neovim's own `vim.lsp.completion`, not nvim-cmp. The popup opens as you type:
`lua/lsp.lua` adds the word characters to each server's `triggerCharacters`,
which is what `autotrigger` fires on. Snippets are in the same popup, marked
`Snippet`, because LuaSnip is registered as another LSP client.

| Key | Mode | What |
|---|---|---|
| `<C-y>` | insert | Accept the selected item; a snippet expands on accept |
| `<C-e>` | insert | Dismiss the popup, or cycle a snippet's choice node when one is active |
| `<C-k>` | insert, select | Expand the trigger before the cursor, or jump to the next field |
| `<C-j>` | insert, select | Jump to the previous field |
| `<C-h>` | insert | Signature help |
| `<C-x><C-o>` | insert | Open the popup by hand |

## Plugins

Seventeen, all either without a native equivalent or required to install one:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — Neovim ships parsers for
  only c/lua/markdown/query/vim/vimdoc. Highlighting starts on `FileType`; the
  parser list lives in `lua/plugins/treesitter.lua`.
  Folds come from the tree (`foldexpr`, see `lua/options.lua`).
- `solarized-osaka.nvim` — the colorscheme, configured in
  `lua/colorscheme.lua`. Set `style = "vivid"` there for the higher-contrast
  variant. It runs transparent, so the terminal's own background shows
  through.
- `lualine.nvim` — the statusline. `lua/plugins/lualine.lua` is craftzdog's
  own lualine, ported off LazyVim: his `pretty_path` and `root_dir` helpers are
  reimplemented there, and the sections that read snacks/noice/dap/lazy are
  dropped. `theme = "auto"` resolves to the lualine theme
  `solarized-osaka.nvim` ships, so it tracks the colorscheme.
- `nvim-autopairs` — auto-closes brackets, quotes and tags. Treesitter-aware,
  so it does not pair inside strings or comments.
- `LuaSnip` + `friendly-snippets` — snippets. `vim.snippet` can already expand
  what a language server sends back, but it has no library of its own; LuaSnip
  is the store and friendly-snippets is the content. `lua/plugins/luasnip.lua`
  also registers LuaSnip as an in-process LSP client so its snippets appear in
  the same completion popup as the servers' — there is no nvim-cmp here to merge
  a second source in. Put your own VS Code-format snippets in
  `snippets/` and they load alongside.
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
brew install fd ripgrep fzf lazygit
```
