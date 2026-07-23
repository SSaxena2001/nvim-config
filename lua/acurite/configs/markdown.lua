local ok, render_markdown = pcall(require, "render-markdown")
if not ok then
  return
end

render_markdown.setup({
  enabled = true,
  file_types = { "markdown" },

  -- Keep rendering out of insert mode so editing stays responsive and the raw
  -- markdown is visible while typing.
  render_modes = { "n", "c", "t" },
  debounce = 150,

  -- The plugin renders only the visible range, and this prevents expensive work
  -- for unusually large notes/docs.
  max_file_size = 2.0,

  completions = {
    blink = { enabled = false },
    lsp = { enabled = false },
  },
})

vim.keymap.set("n", "<leader>mr", function()
  render_markdown.toggle()
end, { desc = "Toggle markdown render" })
