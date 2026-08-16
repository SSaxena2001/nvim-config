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

local eslint_context_cache = {}

local function package_json_has_eslint_config(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return false
  end
  local decoded, package = pcall(vim.json.decode, table.concat(lines, "\n"))
  return decoded and type(package) == "table" and package.eslintConfig ~= nil
end

local function eslint_context(bufnr)
  if eslint_context_cache[bufnr] ~= nil then
    return eslint_context_cache[bufnr] or nil
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" or vim.fs.root(filename, { "deno.json", "deno.jsonc", "deno.lock" }) then
    eslint_context_cache[bufnr] = false
    return nil
  end

  local config = vim.fs.find(eslint_config_files, { path = filename, upward = true, type = "file" })[1]
  if not config then
    for _, package_json in
      ipairs(vim.fs.find("package.json", { path = filename, upward = true, type = "file", limit = math.huge }))
    do
      if package_json_has_eslint_config(package_json) then
        config = package_json
        break
      end
    end
  end

  if not config then
    eslint_context_cache[bufnr] = false
    return nil
  end

  local pnp = vim.fs.find({ ".pnp.cjs", ".pnp.js" }, { path = filename, upward = true, type = "file" })[1]
  local binaries = vim.fs.find("node_modules/.bin/eslint", { path = filename, upward = true, type = "file" })
  local context = {
    cwd = vim.fs.dirname(config),
    cmd = pnp and "yarn" or (binaries[1] or "eslint"),
    yarn_pnp = pnp ~= nil,
  }
  eslint_context_cache[bufnr] = context
  return context
end

local function lint_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].modifiable then
    return
  end
  local context
  if js_filetypes[vim.bo[bufnr].filetype] then
    context = eslint_context(bufnr)
    if not context then
      return
    end
  end

  vim.api.nvim_buf_call(bufnr, function()
    lint.try_lint(nil, {
      cwd = context and context.cwd or nil,
      wrap_linter = context and function(linter)
        linter.cmd = context.cmd
        if context.yarn_pnp then
          linter.args = vim.list_extend({ "exec", "eslint" }, linter.args or {})
        end
        return linter
      end or nil,
    })
  end)
end

-- Run after reading, leaving Insert mode, and saving. ESLint processes exit
-- after each run, trading a little latency for much lower idle memory.
vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("AcuriteLint", { clear = true }),
  callback = function(args)
    lint_buffer(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = "AcuriteLint",
  callback = function(args)
    eslint_context_cache[args.buf] = nil
  end,
})
