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
| `lua/picker.lua` | The `;` prefix — fff pickers, and native ones |
| `lua/pack.lua` | `vim.pack.add` plugin list |
| `lua/plugins/` | Per-plugin setup |
| `lua/lsp.lua` | Native LSP: server configs, attach keymaps, diagnostics, completion |
| `lua/find.lua` | `findfunc` for `:find`, backed by fd (ripgrep, then a glob, as fallbacks); honours `.gitignore` and skips build output |
| `lua/statusline.lua` | The statusline — mode, filename, unsaved marker |
| `lua/grep.lua` | `grepprg=rg`, `grepformat` |
| `lua/lazygit.lua` | lazygit in a terminal tab |

## Pickers

The `;` prefix. `;f`/`;P` find files and `;r`/`;w` grep, all four on fff;
`<CR>` opens a selection, `<Tab>` multi-selects and `<C-q>` sends the result to
the quickfix list, which quicker.nvim styles and makes editable, and `;;`
reopens it. `;f` and the greps search from the project root `lua/find.lua`
resolves, the same root `:find` uses.

The rest are native. fff does files and content and nothing else, so `;t` rides
`:help`'s own tag completion, `\` rides `:buffer`'s — `wildoptions=pum` draws
both as popups — `;e` and `;s` fill the quickfix list from `vim.diagnostic` and
`vim.lsp.buf`, and `;g` opens fugitive's status buffer, where the changed files
can also be staged and committed.

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
which is what `autotrigger` fires on.

Snippets come from LuaSnip, stocked by friendly-snippets -- curated rather than
exhaustive, a few dozen per language across 129 of them. `vim.snippet` can
expand what a server sends back but has no store of its own, so
`lua/plugins/luasnip.lua` registers LuaSnip as an in-process LSP client -- a
table answering `initialize`, `completion` and `resolve`. Its triggers then
sort and render in the same popup as the servers'. Drop your own VS Code-format
JSON in `snippets/` beside this file and it is picked up too.

`jsregexp` backs the snippets that transform a tabstop with a regex rather than
mirroring it. LuaSnip ships the C source and does not build it, so
`lua/pack.lua` carries a `PackChanged` hook that runs `make install_jsregexp`
whenever LuaSnip is installed or updated.

| Key | Mode | What |
|---|---|---|
| `<Tab>` / `<S-Tab>` | insert | Walk the popup without accepting |
| `<CR>` / `<C-y>` | insert | Accept the selected item; a snippet expands on accept |
| `<C-e>` | insert | Dismiss the popup, or cycle a snippet's choice node |
| `<C-k>` | insert | Expand or jump to the next tabstop; signature help when no snippet is active |
| `<C-j>` | insert | Jump to the previous tabstop |
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

Eighteen, all either without a native equivalent or required to install one:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — Neovim ships parsers for
  only c/lua/markdown/query/vim/vimdoc. Highlighting starts on `FileType`; the
  parser list lives in `lua/plugins/treesitter.lua`.
  Folds come from the tree (`foldexpr`, see `lua/options.lua`).
- `treesj` — `<leader>m` splits the node under the cursor across lines, or
  joins it back onto one, configured in `lua/plugins/treesj.lua`. It reads the
  treesitter tree, so it knows an argument list from a table constructor and
  puts the separators, the trailing comma and the indent where they belong —
  `J` only sees lines. Its default keymaps are off; `<leader>s` is already
  Substitute word.
- `solarized-osaka.nvim` — the colorscheme, configured in
  `lua/colorscheme.lua`. Set `style = "vivid"` there for the higher-contrast
  variant; 'background' selects between it and `light_style`. It runs
  transparent, so the terminal's own background shows through.
  `tokyonight.nvim` (which it forks) and `rose-pine` stay installed but
  unconfigured, to switch back to.
- `nvim-autopairs` — auto-closes brackets, quotes and tags. Treesitter-aware,
  so it does not pair inside strings or comments.
- `fff` — the `;f`/`;P` file and `;r`/`;w` grep pickers, configured in
  `lua/plugins/fff.lua`. A Rust core holding its own file tree and content
  index, so repeated searches beat shelling out per keystroke, and ranking is
  frecency- and git-aware. Files and content only; the other `;` mappings are
  native. `:find` and `:grep` still work on their own underneath. The build
  hook in `lua/pack.lua` fetches its binary.
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
- `mini.bracketed` — `[`/`]` motions over buffers, comments, indent, jumps,
  undo states and more, one suffix per target, each taking a count. Set up in
  `lua/plugins/bracketed.lua`, which switches off the targets this config
  already answers (`[q`/`]q` stay on `cprev`/`cnext`) and moves treesitter onto
  `[n`/`]n` so `[t`/`]t` keep Neovim's tag stack. The standalone module, not
  the mini.nvim monorepo.
- `nvim-web-devicons` — filetype icons for oil. Needs a
  Nerd Font in the terminal.

## External binaries

Servers and formatters are installed by mason on first launch (see
`lua/plugins/mason.lua`) into `stdpath("data")/mason/bin`, which
`lua/options.lua` prepends to `$PATH`. `:Mason` opens the UI.

Not covered by mason, install these yourself:

```
brew install fd ripgrep lazygit
```

`ols` and `odinfmt` do come from mason, but neither carries a compiler: ols
shells out to `odin check` for its diagnostics and reads the `core:` and
`vendor:` collections out of the Odin distribution. Only needed if you write
Odin:

```
brew install odin
```
