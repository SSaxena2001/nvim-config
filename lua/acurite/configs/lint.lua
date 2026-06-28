local lint = require("lint")

lint.linters_by_ft = {
  python = { "ruff" },
}

-- Lint on save only. Running Python linters on every InsertLeave/BufRead can create
-- many processes and consume a lot of memory in larger projects.
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(args)
    lint.try_lint(nil, { bufnr = args.buf })
  end,
})
