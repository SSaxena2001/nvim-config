local lint = require("lint")

lint.linters_by_ft = {
  python = { "ruff" },
  javascript = { "eslint" },
  javascriptreact = { "eslint" },
  typescript = { "eslint" },
  typescriptreact = { "eslint" },
  svelte = { "eslint" },
  vue = { "eslint" },
  astro = { "eslint" },
}

local eslint_configs = {
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.json",
  ".eslintrc.yaml",
  ".eslintrc.yml",
}

-- Running eslint in a project that has no eslint config just produces errors,
-- so skip those buffers entirely.
local function eslint_configured(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    return false
  end
  return vim.fs.find(eslint_configs, { path = fname, upward = true, type = "file" })[1] ~= nil
end

vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("AcuriteLint", { clear = true }),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local linters = lint.linters_by_ft[ft]
    if not linters or not vim.bo[args.buf].modifiable then
      return
    end

    if vim.tbl_contains(linters, "eslint") and not eslint_configured(args.buf) then
      return
    end

    vim.api.nvim_buf_call(args.buf, function()
      lint.try_lint()
    end)
  end,
})
