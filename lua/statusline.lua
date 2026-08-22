-- Statusline: path, modified/readonly flags, then diagnostics and position.
-- A plain 'statusline' string -- no palette readers, no async git lookup, no
-- redraw autocmds. `%f` is relative to :pwd, which is what `%{}` expansion
-- gives for free.

vim.o.statusline = table.concat({
  " %f", -- path, relative to cwd
  " %h%w%m%r", -- help / preview / modified / readonly flags
  "%=", -- right-align what follows
  "%{%v:lua.vim.diagnostic.status()%} ",
  "%y ", -- filetype
  "%l:%c ", -- line:column
})
