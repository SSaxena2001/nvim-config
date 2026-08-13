local M = {}

M.ensure_installed = {
  "lua-language-server",
  "tsgo",
  "html-lsp",
  "css-lsp",
  "json-lsp",
  "pyright",
  "ruff",
  "gopls",
  "goimports",
  "clangd",
  "astro-language-server",
  "emmet-ls",
  "marksman",
  "prettier",
  "prettierd",
  "stylua",
  "clang-format",
  "black",
  "isort",
  "pylint",
  "shfmt",
}

---Return the first configured Mason package that is not installed.
---@param packages_dir? string
---@return string?
function M.first_missing(packages_dir)
  packages_dir = packages_dir or (vim.fn.stdpath("data") .. "/mason/packages")
  for _, package in ipairs(M.ensure_installed) do
    if not vim.uv.fs_stat(packages_dir .. "/" .. package .. "/mason-receipt.json") then
      return package
    end
  end
end

return M
