local M = {}

local function notify_clients(method, params)
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method(method) then
      if method == "workspace/willRenameFiles" then
        local response = client:request_sync(method, params, 1000, 0)
        if response and response.result then
          vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
        end
      else
        client:notify(method, params)
      end
    end
  end
end

function M.rename_current_file()
  local old_name = vim.api.nvim_buf_get_name(0)
  if old_name == "" then
    return
  end

  local root = vim.fs.root(0, { ".git", "package.json", "go.mod", "pyproject.toml" }) or vim.fs.dirname(old_name)
  local relative = vim.fs.relpath(root, old_name) or vim.fs.basename(old_name)
  vim.ui.input({ prompt = "New file name: ", default = relative, completion = "file" }, function(value)
    if not value or value == "" or value == relative then
      return
    end

    local new_name = vim.fs.normalize(root .. "/" .. value)
    local params = { files = { { oldUri = vim.uri_from_fname(old_name), newUri = vim.uri_from_fname(new_name) } } }
    notify_clients("workspace/willRenameFiles", params)
    local ok, err = pcall(vim.lsp.util.rename, old_name, new_name)
    if not ok then
      vim.notify(tostring(err), vim.log.levels.ERROR)
      return
    end
    notify_clients("workspace/didRenameFiles", params)
  end)
end

return M
