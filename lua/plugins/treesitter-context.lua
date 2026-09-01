-- The enclosing function, class and branch pinned to the top of the window, so
-- the header of whatever you are inside stays on screen after you have scrolled
-- past it. Reads the same parsers lua/plugins/treesitter.lua installs; it needs
-- no coordination with them beyond that.
require("treesitter-context").setup({
  -- Unbounded by default, which in deeply nested code hands most of the window
  -- to the context. Three lines is enough for the usual class > method > branch
  -- chain, and `trim_scope` defaults to dropping the outermost first, so what
  -- survives the cut is the part nearest the cursor.
  max_lines = 3,
  -- A signature wrapped across several lines is collapsed to its first line.
  -- The default keeps up to 20, which alone would overrun max_lines.
  multiline_threshold = 1,
})

-- No highlight overrides. `TreesitterContext` links to `NormalFloat`, which the
-- colorscheme already renders transparent, so the context reads as ordinary
-- code held in place rather than as a panel sitting on top of it.

-- Jump to the context line above. The context is the one part of the file the
-- window shows but `<C-o>`/`{` cannot reach, since it is a float rather than
-- buffer text -- this is how you get to what it names. `[m` (Prev function,
-- lua/plugins/treesitter.lua) is the nearest sibling; that one is textobject
-- driven and stops at functions only.
vim.keymap.set("n", "[c", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Jump to context above" })
