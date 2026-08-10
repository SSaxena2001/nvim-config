-- Shared helpers for resolving project roots and trimming server features.
-- Used by configs/lsp/servers.lua.

local function package_json_has_field(path, field)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return false
  end

  local ok_json, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  return ok_json and type(decoded) == "table" and decoded[field] ~= nil
end

local function root_with_package_field(bufnr, markers, package_field)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local found = vim.fs.find(markers, { path = fname, upward = true })[1]
  if found then
    return vim.fs.dirname(found)
  end

  local package_json = vim.fs.find("package.json", { path = fname, upward = true })[1]
  if package_json and package_json_has_field(package_json, package_field) then
    return vim.fs.dirname(package_json)
  end

  return nil
end

local function disable_semantic_tokens(client)
  -- Treesitter already handles syntax highlighting. Disabling semantic tokens
  -- avoids extra per-buffer LSP work, especially noticeable in large TS/JS projects.
  client.server_capabilities.semanticTokensProvider = nil
end

local function on_attach_disable_semantic_tokens(client)
  disable_semantic_tokens(client)
end

return {
  package_json_has_field = package_json_has_field,
  root_with_package_field = root_with_package_field,
  disable_semantic_tokens = disable_semantic_tokens,
  on_attach_disable_semantic_tokens = on_attach_disable_semantic_tokens,
}
