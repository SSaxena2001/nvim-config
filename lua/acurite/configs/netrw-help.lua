local help_text = [[
NETRW KEYBINDS

Navigation:
  -          Go up directory
  u          Go up directory (alt)
  ctrl-l     Refresh

Create:
  %          Create new file
  d          Create new directory

Delete/Rename:
  D          Delete file/dir
  R          Rename

Move/Copy:
  m          Move (cut)
  c          Copy
  p          Paste

Open:
  o          Open in split (horizontal)
  v          Open in split (vertical)
  t          Open in new tab

View:
  i          Toggle details/view mode
  s          Sort (name/date/size)
]]

local function show_help()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(help_text, "\n"))
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

  local width = 40
  local height = #vim.split(help_text, "\n")
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
  }

  vim.api.nvim_open_win(buf, true, opts)
  vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = buf, noremap = true })
  vim.keymap.set("n", "<esc>", "<cmd>bdelete<cr>", { buffer = buf, noremap = true })
end

vim.api.nvim_create_user_command("NetrwHelp", show_help, {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.keymap.set("n", "?", show_help, { buffer = true, noremap = true, desc = "Netrw help" })
  end,
})
