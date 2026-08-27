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
| `lua/statusline.lua` | The statusline — mode, filename, unsaved marker |
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
which is what `autotrigger` fires on. There is no snippet library: a server's
own snippet completions still expand, through `vim.snippet`, but nothing here
supplies triggers of its own.

| Key | Mode | What |
|---|---|---|
| `<C-y>` | insert | Accept the selected item; a server's snippet expands on accept |
| `<C-e>` | insert | Dismiss the popup |
| `<C-h>` | insert | Signature help |
| `<C-x><C-o>` | insert | Open the popup by hand |

## Statusline

`lua/statusline.lua`, no plugin. `vim.o.statusline` is a format string; the two
parts that need logic are Lua functions reached through `v:lua`, wrapped in
`%{% %}` so what they return is re-read as format items and can carry its own
colours.

| Left to right | What |
|---|---|
| Mode | `NORMAL`, `INSERT`, `VISUAL`/`V-LINE`/`V-BLOCK`, `REPLACE`, `COMMAND`, `TERMINAL` … , coloured per mode |
| Filename | Relative to `:pwd`, `~`-shortened outside it. oil buffers show the directory, terminals show the command |
| `●` | Unsaved changes: the filename turns `DiagnosticWarn` and picks up a dot. `󰌾` marks readonly instead |
| `%l:%c` `%P` | Line:column and position in the file, pushed right |

Every colour is read out of the active colorscheme's own groups (`Function`,
`String`, `DiagnosticWarn` …) and rebuilt on `ColorScheme`, so there is no
second palette to keep in sync. Foregrounds only — `lua/colorscheme.lua` runs
transparent, and a background here would paint a solid bar back under it.

`laststatus = 3` in `lua/options.lua` makes it one line for the whole screen,
and `showmode = false` stops Neovim printing a second `-- INSERT --` below it.

## Plugins

Sixteen, all either without a native equivalent or required to install one:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — Neovim ships parsers for
  only c/lua/markdown/query/vim/vimdoc. Highlighting starts on `FileType`; the
  parser list lives in `lua/plugins/treesitter.lua`.
  Folds come from the tree (`foldexpr`, see `lua/options.lua`).
- `solarized-osaka.nvim` — the colorscheme, configured in
  `lua/colorscheme.lua`. Set `style = "vivid"` there for the higher-contrast
  variant. It runs transparent, so the terminal's own background shows
  through.
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
- `oil.nvim` — the file explorer, as an editable buffer. netrw is switched off
  outright in `init.lua`, before the runtime would source it, so oil owns every
  directory buffer. `-` walks to the parent, `<leader>e` opens the current
  file's directory and `<leader>E` opens `:pwd`.
- `which-key.nvim` — popup listing what a half-typed prefix can still become.
  It reads the `desc` already on each keymap, so only the prefixes themselves
  are named, in `lua/plugins/which-key.lua`.
- `quicker.nvim` — quickfix styling, context lines, and an editable quickfix
  buffer. `<C-q>` from any picker lands here.
- `nvim-web-devicons` — filetype icons for oil and the fzf-lua pickers. Needs a
  Nerd Font in the terminal.
- `mini.nvim` — for one module, `mini.statuscolumn`, set up in
  `lua/plugins/statuscolumn.lua`. It draws the column left of the text: line
  numbers, signs, fold markers, a `▏` separator, and dimming in inactive
  windows. `'statuscolumn'` is a native option, but the awkward parts are the
  ones around the sections — holding the width steady as signs appear, and
  marking wrapped and virtual lines instead of repeating a line number. The
  whole repository comes along because `mini.statuscolumn` has no standalone
  one yet; no other module in it runs, since a mini module does nothing until
  its own `setup()` is called.

## External binaries

Servers and formatters are installed by mason on first launch (see
`lua/plugins/mason.lua`) into `stdpath("data")/mason/bin`, which
`lua/options.lua` prepends to `$PATH`. `:Mason` opens the UI.

Not covered by mason, install these yourself:

```
brew install fd ripgrep fzf lazygit
```

`ols` and `odinfmt` do come from mason, but neither carries a compiler: ols
shells out to `odin check` for its diagnostics and reads the `core:` and
`vendor:` collections out of the Odin distribution. Only needed if you write
Odin:

```
brew install odin
```
