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

local eslint_config_files = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

local js_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  svelte = true,
  vue = true,
  astro = true,
}

local function eslint_config(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" or vim.fs.root(filename, { "deno.json", "deno.jsonc", "deno.lock" }) then
    return nil
  end
  return vim.fs.find(eslint_config_files, { path = filename, upward = true, type = "file" })[1]
end

-- Prefer each project's ESLint binary. This keeps rules/plugins aligned with
-- package.json and avoids a persistent eslint language-server process.
lint.linters.eslint.cmd = function()
  local filename = vim.api.nvim_buf_get_name(0)
  local binaries = vim.fs.find("node_modules/.bin/eslint", { path = filename, upward = true, type = "file" })
  return binaries[1] or "eslint"
end

local function lint_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].modifiable then
    return
  end
  local cwd
  if js_filetypes[vim.bo[bufnr].filetype] then
    local config = eslint_config(bufnr)
    if not config then
      return
    end
    cwd = vim.fs.dirname(config)
  end
  lint.try_lint(nil, { bufnr = bufnr, cwd = cwd })
end

-- Run after reading, leaving Insert mode, and saving. ESLint processes exit
-- after each run, trading a little latency for much lower idle memory.
vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("AcuriteLint", { clear = true }),
  callback = function(args)
    lint_buffer(args.buf)
  end,
})
